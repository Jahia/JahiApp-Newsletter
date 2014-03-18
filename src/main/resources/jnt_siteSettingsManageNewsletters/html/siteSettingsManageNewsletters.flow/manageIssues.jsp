<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%@ taglib prefix="newsletter" uri="http://www.jahia.org/tags/newsletter" %>
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
<%--@elvariable id="issues" type="java.util.List<org.jahia.services.content.JCRNodeWrapper>"--%>
<%--@elvariable id="newsletter" type="org.jahia.services.content.JCRNodeWrapper"--%>

<template:addResources type="javascript" resources="jquery.min.js,jquery-ui.min.js,jquery.blockUI.js,workInProgress.js,admin-bootstrap.js"/>
<template:addResources type="css" resources="admin-bootstrap.css"/>
<template:addResources type="css" resources="jquery-ui.smoothness.css,jquery-ui.smoothness-jahia.css"/>
<template:addResources>
    <script type="text/javascript">
        function submitIssueForm(act, issue) {
            $('#issueFormAction').val(act);
            if(issue){
                $('#issueFormSelected').val(issue);
            }
            $('#issueForm').submit();
        }
    </script>
</template:addResources>

<h2>
    <fmt:message key="newsletter.issue.manage">
        <fmt:param value="${fn:escapeXml(newsletter.displayableName)}"/>
    </fmt:message>

</h2>

<form action="${flowExecutionUrl}" method="post" style="display: inline;" id="issueForm">
    <input type="hidden" name="selectedIssue" id="issueFormSelected"/>
    <input type="hidden" name="_eventId" id="issueFormAction"/>
</form>

<div>
    <div>
        <button class="btn" onclick="submitIssueForm('cancel')">
            <i class="icon-arrow-left"></i>
            &nbsp;<fmt:message key="newsletter.backToNewsletterList"/>
        </button>

        <button class="btn" onclick="submitIssueForm('editIssue')">
            <i class="icon-plus"></i>
            &nbsp;<fmt:message key="newsletter.issue.create"/>
        </button>
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
        <c:set var="issuesCount" value="${fn:length(issues)}"/>
        <c:set var="issuesFound" value="${issuesCount > 0}"/>


        <table class="table table-bordered table-striped table-hover">
            <thead>
            <tr>
                <th width="3%">#</th>
                <th><fmt:message key="newsletter.issue"/></th>
                <th><fmt:message key="newsletter.issue.personalised"/></th>
                <th><fmt:message key="newsletter.issue.lastModified"/></th>
                <th><fmt:message key="newsletter.issue.lastSent"/></th>
                <th><fmt:message key="newsletter.issue.scheduled"/></th>
                <th width="25%"><fmt:message key="label.actions"/></th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${!issuesFound}">
                    <tr>
                        <td colspan="7"><fmt:message key="label.noItemFound"/></td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <fmt:message var="i18nYes" key="label.yes"/>
                    <fmt:message var="i18nNo" key="label.no"/>
                    <fmt:message var="i18nRemoveConfirm" key="newsletter.issue.remove.confirm"/><c:set var="i18nRemoveConfirm" value="${functions:escapeJavaScript(i18nRemoveConfirm)}"/>
                    <fmt:message var="i18nSendConfirm" key="newsletter.issue.send.confirm"/><c:set var="i18nSendConfirm" value="${functions:escapeJavaScript(i18nSendConfirm)}"/>
                    <fmt:message var="i18nRemove" key="label.remove"/><c:set var="i18nRemove" value="${functions:escapeJavaScript(i18nRemove)}"/>
                    <fmt:message var="i18nEdit" key="label.edit"/><c:set var="i18nEdit" value="${functions:escapeJavaScript(i18nEdit)}"/>
                    <fmt:message var="i18nEditMode" key="newsletter.issue.goToEditMode"/><c:set var="i18nEditMode" value="${functions:escapeJavaScript(i18nEditMode)}"/>
                    <fmt:message var="i18nTest" key="newsletter.issue.test"/><c:set var="i18nTest" value="${functions:escapeJavaScript(i18nTest)}"/>
                    <fmt:message var="i18nSend" key="newsletter.issue.send"/><c:set var="i18nSend" value="${functions:escapeJavaScript(i18nSend)}"/>
                    <fmt:message var="i18nPublish" key="newsletter.issue.publish"/><c:set var="i18nPublish" value="${functions:escapeJavaScript(i18nPublish)}"/>
                    <fmt:message var="i18nNeedPublish" key="newsletter.issue.needPublish"/><c:set var="i18nNeedPublish" value="${functions:escapeJavaScript(i18nNeedPublish)}"/>

                    <c:forEach items="${issues}" var="issue" varStatus="loopStatus">
                        <c:set var="hasPublication" value="${not empty issue.properties['j:lastPublished']}"/>
                        <c:set var="needPublication" value="${jcr:needPublication(issue, renderContext.mainResourceLocale.language, false, false, false)}"/>

                        <c:url var="issueEditModeURL" value="${url.baseEdit}${issue.path}.html"/>
                        <tr>
                            <td>${loopStatus.count}</td>
                            <td>
                                <a title="${i18nEditMode}" href="${issueEditModeURL}">${fn:escapeXml(issue.displayableName)}</a>
                            </td>
                            <td>
                                <span class="label ${issue.properties["j:personalized"].boolean ? 'label-important' : 'label-info'}">
                                    ${issue.properties["j:personalized"].boolean ? i18nYes : i18nNo}
                                </span>
                            </td>
                            <td>
                                <fmt:formatDate value="${issue.properties['jcr:lastModified'].date.time}"
                                                pattern="yyyy-MM-dd HH:mm"/>
                            </td>
                            <td>
                                <fmt:formatDate value="${issue.properties['j:lastSent'].date.time}"
                                                pattern="yyyy-MM-dd HH:mm"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${hasPublication}">
                                        <c:choose>
                                            <c:when test="${not empty issue.properties['j:scheduled']}">
                                                <fmt:formatDate value="${issue.properties['j:scheduled'].date.time}"
                                                                pattern="yyyy-MM-dd HH:mm"/>
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:message key="label.issueNotScheduled"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:message key="label.issueNotPublished"/>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <a style="margin-bottom:0;" class="btn btn-small" title="${i18nEditMode}" href="${issueEditModeURL}">
                                    <i class="icon-pencil"></i>
                                </a>

                                <a style="margin-bottom:0;" class="btn btn-small" title="${i18nEdit}" href="#edit" onclick="submitIssueForm('editIssue', '${issue.identifier}')">
                                    <i class="icon-edit"></i>
                                </a>

                                <c:choose>
                                    <c:when test="${hasPublication}">
                                        <a style="margin-bottom:0;" class="btn btn-small" title="${i18nTest}" href="#test" onclick="submitIssueForm('testIssue', '${issue.identifier}')">
                                            <i class="icon-check"></i>
                                        </a>

                                        <a style="margin-bottom:0;" class="btn btn-small" title="${i18nSend}" href="#send" onclick="if (confirm('${i18nSendConfirm}')) { submitIssueForm('sendIssue', '${issue.identifier}');} return false;">
                                            <i class="icon-share"></i>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a style="margin-bottom:0;" class="btn btn-small disabled" title="${i18nTest} - ${i18nNeedPublish}" href="#test" onclick="return false;">
                                            <i class="icon-check"></i>
                                        </a>

                                        <a style="margin-bottom:0;" class="btn btn-small disabled" title="${i18nSend} - ${i18nNeedPublish}" href="#send" onclick="return false;">
                                            <i class="icon-share"></i>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                                <a style="margin-bottom:0;" class="btn btn-danger btn-small" title="${i18nRemove}" href="#delete" onclick="if (confirm('${i18nRemoveConfirm}')) { submitIssueForm('removeIssue', '${issue.identifier}');} return false;">
                                    <i class="icon-remove icon-white"></i>
                                </a>
                                <c:if test="${needPublication}">
                                    <a style="margin-bottom:0;" class="btn btn-success btn-small" title="${i18nPublish}" href="#publish" onclick="submitIssueForm('publishIssue', '${issue.identifier}')">
                                        <i class="icon-white icon-globe"></i>${i18nPublish}
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</div>