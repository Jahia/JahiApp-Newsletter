<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
<%--@elvariable id="searchCriteria" type="org.jahia.services.usermanager.SearchCriteria"--%>
<%--@elvariable id="newsletters" type="java.util.List<org.jahia.services.content.JCRNodeWrapper>"--%>

<template:addResources type="javascript" resources="jquery.min.js,jquery-ui.min.js,jquery.blockUI.js,workInProgress.js,admin-bootstrap.js"/>
<template:addResources type="css" resources="admin-bootstrap.css"/>
<template:addResources type="css" resources="jquery-ui.smoothness.css,jquery-ui.smoothness-jahia.css"/>
<template:addResources>
    <script type="text/javascript">
        function submitNewsletterForm(act, newsletter) {
            $('#newsletterFormAction').val(act);
            if(newsletter){
                $('#newsletterFormSelected').val(newsletter);
            }
            $('#newsletterForm').submit();
        }
    </script>
</template:addResources>

<c:set var="site" value="${renderContext.mainResource.node.resolveSite}"/>

<h2><fmt:message key="newsletter.manage"/> - ${fn:escapeXml(site.displayableName)}</h2>

<form action="${flowExecutionUrl}" method="post" style="display: inline;" id="newsletterForm">
    <input type="hidden" name="selectedNewsletter" id="newsletterFormSelected"/>
    <input type="hidden" name="_eventId" id="newsletterFormAction"/>
</form>

<div>
    <div>
        <c:if test="${jcr:hasPermission(currentNode,'jcr:write')}" >
            <button class="btn" onclick="submitNewsletterForm('editNewsletter')">
                <i class="icon-plus"></i>
                &nbsp;<fmt:message key="newsletter.create"/>
            </button>
        </c:if>
    </div>

    <p>
    <c:forEach items="${flowRequestContext.messageContext.allMessages}" var="message">
        <c:if test="${message.severity eq 'INFO'}">
            <div class="alert alert-success">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${message.text}
            </div>
        </c:if>
        <c:if test="${message.severity eq 'ERROR'}">
            <div class="alert alert-error">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${message.text}
            </div>
        </c:if>
    </c:forEach>
    </p>

    <div>
        <c:set var="newslettersCount" value="${fn:length(newsletters)}"/>
        <c:set var="newslettersFound" value="${newslettersCount > 0}"/>

        <table class="table table-bordered table-striped table-hover">
            <thead>
            <tr>
                <th width="3%">#</th>
                <th><fmt:message key="newsletter.label"/></th>
                <th width="5%"><fmt:message key="newsletter.public"/></th>
                <th width="5%"><fmt:message key="newsletter.issues"/></th>
                <th width="20%"><fmt:message key="label.actions"/></th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${!newslettersFound}">
                    <tr>
                        <td colspan="5"><fmt:message key="label.noItemFound"/></td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <fmt:message var="i18nYes" key="label.yes"/>
                    <fmt:message var="i18nNo" key="label.no"/>
                    <fmt:message var="i18nRemoveConfirm" key="newsletter.remove"/><c:set var="i18nRemoveConfirm" value="${functions:escapeJavaScript(i18nRemoveConfirm)}"/>
                    <fmt:message var="i18nRemove" key="label.remove"/><c:set var="i18nRemove" value="${functions:escapeJavaScript(i18nRemove)}"/>
                    <fmt:message var="i18nEdit" key="label.edit"/><c:set var="i18nEdit" value="${functions:escapeJavaScript(i18nEdit)}"/>
                    <fmt:message var="i18nSubscriptions" key="newsletter.subscriptions.label"/><c:set var="i18nSubscriptions" value="${functions:escapeJavaScript(i18nSubscriptions)}"/>
                    <fmt:message var="i18nIssues" key="newsletter.issues"/><c:set var="i18nIssues" value="${functions:escapeJavaScript(i18nIssues)}"/>
                    <fmt:message var="i18nPublish" key="newsletter.issue.publish"/><c:set var="i18nPublish" value="${functions:escapeJavaScript(i18nPublish)}"/>
                    <fmt:message var="i18nNeedPublish" key="newsletter.needPublish"/><c:set var="i18nNeedPublish" value="${functions:escapeJavaScript(i18nNeedPublish)}"/>

                    <c:forEach items="${newsletters}" var="newsletter" varStatus="loopStatus">
                        <c:if test="${jcr:hasPermission(newsletter,'jcr:write')}" >
                            <c:set var="hasPublication" value="${not empty newsletter.properties['j:lastPublished']}"/>
                            <c:set var="needPublication" value="${jcr:needPublication(newsletter, renderContext.mainResourceLocale.language, false, false, false)}"/>

                            <tr>
                                <td>${loopStatus.count}</td>
                                <td>
                                    <a title="${i18nEdit}" href="#details" onclick="submitNewsletterForm('manageIssues', '${newsletter.identifier}')">${fn:escapeXml(newsletter.displayableName)}</a>
                                </td>
                                <td>
                                    <span class="label ${newsletter.properties["j:allowUnregisteredUsers"].boolean ? 'label-info' : 'label-important'}">
                                            ${newsletter.properties["j:allowUnregisteredUsers"].boolean ? i18nYes : i18nNo}
                                    </span>
                                </td>
                                <td>
                                    <jcr:sql var="numberOfIssuesQuery" sql="select [jcr:uuid] from [jnt:newsletterIssue] as i where isdescendantnode(i,['${newsletter.path}'])"/>
                                    ${numberOfIssuesQuery.rows.size}
                                </td>
                                <td>
                                    <a style="margin-bottom:0;" class="btn btn-small" title="${i18nEdit}" href="#edit" onclick="submitNewsletterForm('editNewsletter', '${newsletter.identifier}')">
                                        <i class="icon-edit"></i>
                                    </a>

                                    <a style="margin-bottom:0;" class="btn btn-small" title="${i18nIssues}" href="#issues" onclick="submitNewsletterForm('manageIssues', '${newsletter.identifier}')">
                                        <i class="icon-envelope"></i>
                                    </a>

                                    <c:choose>
                                        <c:when test="${hasPublication}">
                                            <a style="margin-bottom:0;" class="btn btn-small" title="${i18nSubscriptions}" href="#subscriptions" onclick="submitNewsletterForm('manageSubscriptions', '${newsletter.identifier}')">
                                                <i class="icon-user"></i>
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a style="margin-bottom:0;" class="btn btn-small disabled" title="${i18nSubscriptions} - ${i18nNeedPublish}" href="#subscriptions" onclick="return false;">
                                                <i class="icon-user"></i>
                                            </a>
                                        </c:otherwise>
                                    </c:choose>

                                    <a style="margin-bottom:0;" class="btn btn-danger btn-small" title="${i18nRemove}" href="#delete" onclick="if (confirm('${i18nRemoveConfirm}')) { submitNewsletterForm('removeNewsletter', '${newsletter.identifier}');} return false;">
                                        <i class="icon-remove icon-white"></i>
                                    </a>

                                    <c:if test="${needPublication}">
                                        <a style="margin-bottom:0;" class="btn btn-success btn-small" title="${i18nPublish}" href="#publish" onclick="submitNewsletterForm('publishNewsletter', '${newsletter.identifier}')">
                                            <i class="icon-white icon-globe"></i>${i18nPublish}
                                        </a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:if>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</div>
