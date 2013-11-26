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
<%--@elvariable id="subscriptions" type="org.jahia.utils.PaginatedList<org.jahia.services.notification.Subscription>"--%>

<c:set var="subscriptionDisplayLimit" value="${functions:default(fn:escapeXml(param.displayLimit), newsletterProperties.subscriptionDisplayLimit)}"/>
<fmt:message key="label.workInProgressTitle" var="i18nWaiting"/><c:set var="i18nWaiting" value="${functions:escapeJavaScript(i18nWaiting)}"/>
<fmt:message var="i18nSingleRemove" key="newsletter.subscriptions.single.remove"/><c:set var="i18nSingleRemove" value="${fn:escapeXml(i18nSingleRemove)}"/>
<fmt:message var="i18nSingleSuspend" key="newsletter.subscriptions.single.suspend"/><c:set var="i18nSingleSuspend" value="${fn:escapeXml(i18nSingleSuspend)}"/>
<fmt:message var="i18nSingleResume" key="newsletter.subscriptions.single.resume"/><c:set var="i18nSingleResume" value="${fn:escapeXml(i18nSingleResume)}"/>
<fmt:message var="i18nMultipleRemove" key="newsletter.subscriptions.multiple.remove"/><c:set var="i18nMultipleRemove" value="${fn:escapeXml(i18nMultipleRemove)}"/>
<fmt:message var="i18nMultipleSuspend" key="newsletter.subscriptions.multiple.suspend"/><c:set var="i18nMultipleSuspend" value="${fn:escapeXml(i18nMultipleSuspend)}"/>
<fmt:message var="i18nMultipleResume" key="newsletter.subscriptions.multiple.resume"/><c:set var="i18nMultipleResume" value="${fn:escapeXml(i18nMultipleResume)}"/>
<fmt:message var="i18nNothingSelected" key="newsletter.subscriptions.multiple.nothingSelected"/><c:set var="i18nNothingSelected" value="${fn:escapeXml(i18nNothingSelected)}"/>

<template:addResources type="javascript" resources="jquery.min.js,jquery-ui.min.js,jquery.blockUI.js,workInProgress.js,admin-bootstrap.js"/>
<template:addResources type="css" resources="admin-bootstrap.css"/>
<template:addResources type="css" resources="jquery-ui.smoothness.css,jquery-ui.smoothness-jahia.css"/>
<template:addResources>
    <script type="text/javascript">
        function doSubscriptionSingleAction(confirmMsg, id) {
            if (confirm(confirmMsg)) {
                $.each($(':checkbox[name=selectedSubscriptions]'), function() {
                    this.checked=$(this).val() == id;
                });
                workInProgress('${i18nWaiting}');
                return true;
            } else {
                return false;
            }
        }

        function doSubscriptionMultipleAction(confirmMsg) {
            if ($('input:checked[name=selectedSubscriptions]').length == 0) {
                alert("${i18nNothingSelected}");
                return false;
            }
            if (confirm(confirmMsg)) {
                workInProgress('${i18nWaiting}');
                return true;
            }
            return false;
        }

        $(document).ready(function() {
            $(':checkbox[name="selectedSubscriptions"]').click(function() {
                if (!this.checked) {
                    $('#cbSelectedAllSubscriptions').checked = false;
                }
            });
            $('#cbSelectedAllSubscriptions').click(function() {
                var state = this.checked;
                $.each($(':checkbox[name="selectedSubscriptions"]'), function() {
                    this.checked=state;
                });
            });
        })
    </script>
</template:addResources>

<h2>
    <fmt:message key="newsletter.subscritpions.manage">
        <fmt:param value="${fn:escapeXml(newsletter.displayableName)}"/>
    </fmt:message>
</h2>

<c:set var="subscriptionsFound" value="${subscriptions.totalSize > 0}"/>

<form action="${flowExecutionUrl}" method="post" style="display: inline;">
    <div>
        <div>
            <button class="btn" type="submit" name="_eventId_cancel">
                <i class="icon-arrow-left"></i>
                &nbsp;<fmt:message key="newsletter.backToNewsletterList"/>
            </button>

            <button class="btn" type="submit" name="_eventId_addSubscribers">
                <i class="icon-plus"></i>
                &nbsp;<fmt:message key="newsletter.subscriptions.addSubscribers"/>
            </button>

            <button class="btn" type="submit" name="_eventId_bulkAddSubscribers">
                <i class="icon-download"></i>
                &nbsp;<fmt:message key="newsletter.subscriptions.bulkAddSubscribers"/>
            </button>

            <c:if test="${subscriptionsFound}">
                <button class="btn" type="submit" name="_eventId_removeSubscriptions" onclick="return doSubscriptionMultipleAction('${i18nMultipleRemove}')">
                    <i class="icon-remove"></i>
                    &nbsp;<fmt:message key="newsletter.subscriptions.removeSubscriptions"/>
                </button>

                <button class="btn" type="submit" name="_eventId_suspendSubscriptions" onclick="return doSubscriptionMultipleAction('${i18nMultipleSuspend}')">
                    <i class="icon-pause"></i>
                    &nbsp;<fmt:message key="newsletter.subscriptions.suspendSubscriptions"/>
                </button>

                <button class="btn" type="submit" name="_eventId_resumeSubscriptions" onclick="return doSubscriptionMultipleAction('${i18nMultipleResume}')">
                    <i class="icon-play"></i>
                    &nbsp;<fmt:message key="newsletter.subscriptions.resumeSubscriptions"/>
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
            <h2><fmt:message key="newsletter.subscriptions.label"/> (${subscriptions.totalSize})</h2>
            <c:if test="${subscriptions.totalSize > subscriptionDisplayLimit}">
                <div class="alert alert-info">
                    <fmt:message key="newsletter.subscriptions.found">
                        <fmt:param value="${subscriptions.totalSize}"/>
                        <fmt:param value="${subscriptionDisplayLimit}"/>
                    </fmt:message>
                    <form action="${flowExecutionUrl}" method="post" style="display: inline;">
                        <input type="hidden" name="displayLimit" value="<%= Integer.MAX_VALUE %>"/>
                        <button class="btn" type="submit" name="refresh">
                            <i class="icon-search"></i>
                            &nbsp;<fmt:message key="newsletter.subscriptions.showAll"/>
                        </button>
                    </form>
                </div>
            </c:if>

            <table class="table table-bordered table-striped table-hover">
                <thead>
                <tr>
                    <th width="2%"><input type="checkbox" name="selectedAllSubscriptions" id="cbSelectedAllSubscriptions"/></th>
                    <th width="3%">#</th>
                    <th width="3%">&nbsp;</th>
                    <th><fmt:message key="newsletter.subscription.name"/></th>
                    <th><fmt:message key="newsletter.subscription.firstname"/></th>
                    <th><fmt:message key="newsletter.subscription.lastname"/></th>
                    <th><fmt:message key="newsletter.subscription.email"/></th>
                    <th><fmt:message key="newsletter.subscription.provider"/></th>
                    <th><fmt:message key="newsletter.subscription.confirmed"/></th>
                    <th><fmt:message key="newsletter.subscription.suspended"/></th>
                    <th width="20%"><fmt:message key="label.actions"/></th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${!subscriptionsFound}">
                        <tr>
                            <td colspan="11"><fmt:message key="label.noItemFound"/></td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <fmt:message var="i18nYes" key="label.yes"/>
                        <fmt:message var="i18nNo" key="label.no"/>
                        <c:forEach items="${subscriptions.data}" var="subscription" end="${subscriptionDisplayLimit - 1}" varStatus="loopStatus">
                            <tr>
                                <td>
                                    <input type="checkbox" name="selectedSubscriptions" value="${subscription.id}"/>
                                </td>
                                <td>
                                    ${loopStatus.count}
                                </td>
                                <td>
                                    <i class="icon-user"></i>
                                </td>
                                <td>
                                    ${fn:escapeXml(subscription.subscriber)}
                                </td>
                                <td>
                                    ${fn:escapeXml(subscription.firstName)}
                                </td>
                                <td>
                                    ${fn:escapeXml(subscription.lastName)}
                                </td>
                                <td>
                                    ${fn:escapeXml(subscription.email)}
                                </td>
                                <td>
                                    <fmt:message var="i18nProviderLabel"
                                                 key="providers.${subscription.provider}.label"/>
                                        ${fn:escapeXml(fn:contains(i18nProviderLabel, '???') ? subscription.provider : i18nProviderLabel)}
                                </td>
                                <td>
                                   <span class="label ${subscription.confirmed ? 'label-info' : 'label-important'}">
                                        ${subscription.confirmed ? i18nYes : i18nNo}
                                   </span>
                                </td>
                                <td>
                                    <span class="label ${subscription.suspended ? 'label-important' : 'label-info'}">
                                            ${subscription.suspended ? i18nYes : i18nNo}
                                    </span>
                                </td>
                                <td>
                                    <button style="margin-bottom:0;" class="btn btn-danger btn-small" type="submit"
                                            name="_eventId_removeSubscriptions" onclick="return doSubscriptionSingleAction('${i18nSingleRemove}', '${subscription.id}')">
                                        <i class="icon-remove icon-white"></i>
                                    </button>
                                    <c:choose>
                                        <c:when test="${subscription.suspended}">
                                            <button style="margin-bottom:0;" class="btn btn-info btn-small" type="submit"
                                                    name="_eventId_resumeSubscriptions" onclick="return doSubscriptionSingleAction('${i18nSingleResume}', '${subscription.id}')">
                                                <i class="icon-play icon-white"></i>
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button style="margin-bottom:0;" class="btn btn-info btn-small" type="submit"
                                                    name="_eventId_suspendSubscriptions" onclick="return doSubscriptionSingleAction('${i18nSingleSuspend}', '${subscription.id}')">
                                                <i class="icon-pause icon-white"></i>
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</form>