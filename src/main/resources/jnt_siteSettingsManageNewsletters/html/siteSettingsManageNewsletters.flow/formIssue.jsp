<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
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
<%--@elvariable id="issueTemplate" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="issue" type="org.jahia.services.content.JCRNodeWrapper"--%>

<template:addResources type="javascript" resources="jquery.min.js,jquery.form.js,jquery-ui.min.js,jquery.blockUI.js,workInProgress.js,admin-bootstrap.js"/>
<template:addResources type="css" resources="admin-bootstrap.css"/>
<template:addResources type="css" resources="jquery-ui.smoothness.css,jquery-ui.smoothness-jahia.css"/>
<fmt:message var="i18nNameMandatory" key="newsletter.issue.errors.name.mandatory"/><c:set var="i18nNameMandatory" value="${fn:escapeXml(i18nNameMandatory)}"/>
<fmt:message var="i18nCreationFailed" key="newsletter.issue.errors.create.failed"/><c:set var="i18nCreationFailed" value="${fn:escapeXml(i18nCreationFailed)}"/>
<fmt:message var="i18nUpdateFailed" key="newsletter.issue.errors.update.failed"/><c:set var="i18nUpdateFailed" value="${fn:escapeXml(i18nUpdateFailed)}"/>

<c:set var="isUpdate" value="false"/>
<jcr:node var="newsletter" uuid="${newsletterUUID}"/>
<c:if test="${not empty issueUUID}">
    <jcr:node var="issue" uuid="${issueUUID}"/>
    <c:set var="isUpdate" value="${issue != null}"/>
</c:if>

<script type="text/javascript">
    function emptyIssueSchedule(){
        $("#issueScheduleDateDecoy").val("");
        $("#issueScheduleDate").val("");
    }

    function showIssueErrors(message) {
        $("#issueFormErrorMessages").text(message);
        $("#issueFormErrorContainer").show();
    }

    function hideIssueErrors() {
        $("#issueFormErrorMessages").empty();
        $("#issueFormErrorContainer").hide();
    }

    function submitIssueForm(act, name, type) {
        $('#issueFormAction').val(act);
        if(name){
            $('#issueActionName').val(name);
        }
        if(type){
            $('#issueActionType').val(type);
        }

        $('#issueWebflowForm').submit();
    }

    $(document).ready(function() {
        $("#issueFormErrorClose").bind("click", function(){
            hideIssueErrors();
        });

        var issueFormOptions = {
            beforeSubmit: function(arr, $form, options) {
                // validate fields
                if(!$("#issueName").val()) {
                    showIssueErrors("${i18nNameMandatory}");
                    return false;
                }
                arr.push({name:"j:personalized",value:$("#issueIsPersonalized").is(":checked")});
            },
            success: function() {
                submitIssueForm("actionPerformed", $("#issueName").val(), "${isUpdate ? 'updated' : 'created'}");
            },
            error: function() {
                <c:choose>
                    <c:when test="${isUpdate}">
                        showIssueErrors("${i18nUpdateFailed}");
                    </c:when>
                    <c:otherwise>
                        showIssueErrors("${i18nCreationFailed}");
                    </c:otherwise>
                </c:choose>
            }
        };

        $('#issueForm').ajaxForm(issueFormOptions);
    });
</script>

<div>
    <form action="${flowExecutionUrl}" method="post" style="display: inline;" id="issueWebflowForm">
        <input type="hidden" name="name" id="issueActionName"/>
        <input type="hidden" name="type" id="issueActionType"/>
        <input type="hidden" name="model" value="issue"/>
        <input type="hidden" name="_eventId" id="issueFormAction"/>
    </form>

    <c:choose>
        <c:when test="${isUpdate}">
            <c:url var="actionUrl" value="${url.baseEdit}${issue.path}"/>
            <h2><fmt:message key="newsletter.issue.edit"/> - ${fn:escapeXml(issue.displayableName)}</h2>
        </c:when>
        <c:otherwise>
            <c:url var="actionUrl" value="${url.baseEdit}${newsletter.path}/*"/>
            <h2><fmt:message key="newsletter.issue.create"/></h2>
        </c:otherwise>
    </c:choose>

    <div class="box-1">
        <div class="alert alert-error" style="display: none" id="issueFormErrorContainer">
            <button type="button" class="close" id="issueFormErrorClose">&times;</button>
            <span id="issueFormErrorMessages"></span>
        </div>

        <form action="${actionUrl}" method="POST" id="issueForm">
            <input type="hidden" name="jcrNodeType" value="jnt:newsletterIssue">

            <fieldset>
                <div class="container-fluid">
                    <div class="row-fluid">
                        <div class="span4">
                            <c:set var="issueName" value="${isUpdate ? issue.displayableName : ''}"/>
                            <label for="issueName"><fmt:message key="label.name"/> <span class="text-error"><strong>*</strong></span></label>
                            <input type="text" name="jcr:title" class="span12" id="issueName" value="${fn:escapeXml(issueName)}"/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <div class="span4">
                            <c:set var="issueIsPersonalized" value="${isUpdate ? issue.properties['j:personalized'].boolean : false}"/>
                            <label for="issueIsPersonalized"><fmt:message key="newsletter.issue.personalised"/></label>
                            <input type="checkbox" id="issueIsPersonalized" ${issueIsPersonalized ? 'checked="checked"' : ''}/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <div class="span4">
                            <label for="issueTemplate"><fmt:message key="newsletter.issue.template"/></label>
                            <c:set var="issueTemplateName" value="${isUpdate ? issue.properties['j:templateName'].string : ''}"/>
                            <jcr:sql var="issueTemplates" sql="select * from [jnt:contentTemplate] where [j:applyOn] = 'jnt:newsletterIssue'"/>
                            <select name="j:templateName" id="issueTemplate">
                                <c:forEach items="${issueTemplates.nodes}" var="issueTemplate">
                                    <c:set var="currentIssueTemplateName" value="${issueTemplate.properties['j:nodename'].string}"/>
                                    <option value="${currentIssueTemplateName}" ${isUpdate and (issueTemplateName eq currentIssueTemplateName) ? 'selected' : ''}>${issueTemplate.displayableName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="row-fluid">
                        <c:set var="isScheduled" value="${isUpdate and not empty issue.properties['j:scheduled'].string}"/>
                        <c:if test="${isScheduled}">
                            <fmt:formatDate value="${issue.properties['j:scheduled'].date.time}" type="both" pattern="yyyy.MM.dd HH:mm" var="currentSchedule"/>
                        </c:if>
                        <label for="issueScheduleDateDecoy"><fmt:message key="newsletter.issue.scheduled"/></label>
                        <input id="issueScheduleDateDecoy" type="text" class="span4" value="${isScheduled ? currentSchedule : ''}"/>
                        <input id="issueScheduleDate" type="hidden" name="j:scheduled" value="${isScheduled ? issue.properties["j:scheduled"].string : ''}"/>
                        <a class="label label-important" id="emptyIssueSchedule" href="#" onclick="emptyIssueSchedule(); return false;"><i class="icon-remove icon-white"></i></a>
                        <ui:dateSelector fieldId="issueScheduleDateDecoy" time="true" >
                            {
                                dateFormat: 'dd.mm.yy',
                                showButtonPanel: true,
                                showOn:'focus',
                                <%-- Below is the conf for a good date time format for date properties
                                 TODO externalize this in dateSelector tag --%>
                                altField: "#issueScheduleDate",
                                altFieldTimeOnly: false,
                                altFormat: "yy-mm-dd",
                                altTimeFormat: "HH:mm:ss.lZ",
                                altSeparator: "T",
                                showSecond: false,
                                showMillisec: false,
                                showMicrosec: false,
                                showTimezone: false
                            }
                        </ui:dateSelector>
                        </div>
                    </div>

                </div>
            </fieldset>

            <fieldset>
                <div class="container-fluid">
                    <div class="row-fluid">
                        <div class="span12">
                            <button class="btn btn-primary" type="submit">
                                <i class="icon-${isUpdate ? 'share' : 'plus'} icon-white"></i>
                                &nbsp;<fmt:message key="label.${isUpdate ? 'update' : 'add'}"/>
                            </button>
                            <button class="btn" onclick="submitIssueForm('cancel'); return false;">
                                <i class="icon-ban-circle"></i>
                                &nbsp;<fmt:message key="label.cancel"/>
                            </button>
                        </div>
                    </div>
                </div>
            </fieldset>
        </form>
    </div>
</div>