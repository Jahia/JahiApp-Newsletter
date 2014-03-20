<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="mailSettings" type="org.jahia.services.mail.MailSettings"--%>
<%--@elvariable id="flowRequestContext" type="org.springframework.webflow.execution.RequestContext"--%>
<%--@elvariable id="flowExecutionUrl" type="java.lang.String"--%>
<%--@elvariable id="issue" type="org.jahia.services.content.JCRNodeWrapper"--%>

<template:addResources type="javascript" resources="jquery.min.js"/>
<template:addResources type="css" resources="jquery.autocomplete.css"/>
<template:addResources type="javascript" resources="jquery.autocomplete.js"/>

<c:set var="site" value="${renderContext.mainResource.node.resolveSite}"/>
<script type="text/javascript">
    $(document).ready(function() {
        function getUserDisplayName(node) {
            var value = node['j:firstName'] || '';
            if (value.length != 0) {
                value += ' ';
            }
            value += node['j:lastName'] || '';
            var title = value.length > 0 ? value : node['username'];
            var username = node['username'];
            return username != title ? title + " (" + username + ")" : username;
        }

        $("#user").autocomplete("<c:url value='${url.findUser}' />", {
            dataType: "json",
            cacheLength: 1,
            parse: function (data) {
                return $.map(data, function(row) {
                    return {
                        data: row,
                        value: row['username'],
                        result: getUserDisplayName(row)
                    }
                });
            },
            formatItem: function(item) {
                return getUserDisplayName(item);
            }
        }).result(function(event, item, formatted) {
            if (!item) {
                return;
            }
            $('#assignee_hidden').val(item['username'])
        });
    });
</script>

<h2><fmt:message key="newsletter.issue.test"/> fdfd- ${fn:escapeXml(issue.displayableName)}</h2>

<c:forEach var="msg" items="${flowRequestContext.messageContext.allMessages}">
    <div class="${msg.severity == 'ERROR' ? 'validationError' : ''} alert ${msg.severity == 'ERROR' ? 'alert-error' : 'alert-success'}">
        <button type="button" class="close" data-dismiss="alert">&times;</button>
            ${fn:escapeXml(msg.text)}</div>
</c:forEach>

<div class="box-1">
    <form:form modelAttribute="formTestIssue" class="form" autocomplete="off">
        <form:hidden path="issueUUID"/>

        <div class="row-fluid">
            <div class="span4">
                <label for="testmail"><fmt:message key="label.email"/> <span class="text-error"><strong>*</strong></span></label>
                <form:input class="span12" type="text" id="testmail" path="testmail"/>
                <label for="user"><fmt:message key="label.user"/> <span class="text-error"><strong>*</strong></span></label>
                <form:input class="span12" type="text" id="user" path="user"/>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span4">
                <label for="locale"><fmt:message key="label.locale"/></label>
                <form:select id="locale" path="locale">
                    <c:forEach items="${site.languagesAsLocales}" var="language">
                        <form:option value="${language}">${functions:displayLocaleNameWith(language, renderContext.UILocale)}</form:option>
                    </c:forEach>
                </form:select>
            </div>
        </div>

        <div class="container-fluid">
            <div class="row-fluid">
                <div class="span12" style="margin-top:15px;">
                    <button class="btn btn-primary" id="submit" type="submit" name="_eventId_submit"><i
                            class="icon-ok icon-white"></i>&nbsp;<fmt:message key="label.send"/></button>
                    <button class="btn" id="cancel" type="submit" name="_eventId_cancel">
                        <i class="icon-ban-circle"></i>
                        &nbsp;<fmt:message key="label.cancel"/>
                    </button>
                </div>
            </div>
        </div>
    </form:form>
</div>