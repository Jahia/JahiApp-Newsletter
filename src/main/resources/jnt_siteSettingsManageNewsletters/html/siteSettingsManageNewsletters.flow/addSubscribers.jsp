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
<%--@elvariable id="users" type="java.util.Set<org.jahia.services.usermanager.JahiaUser>"--%>

<template:addResources type="javascript" resources="jquery.min.js,jquery-ui.min.js,jquery.blockUI.js,workInProgress.js,admin-bootstrap.js"/>
<template:addResources type="css" resources="admin-bootstrap.css,jquery-ui.smoothness.css,jquery-ui.smoothness-jahia.css"/>
<c:set var="usersCount" value="${fn:length(users)}"/>
<c:set var="usersFound" value="${usersCount > 0}"/>

<c:set var="memberDisplayLimit" value="${newsletterProperties.memberDisplayLimit}"/>
<c:set var="multipleProvidersAvailable" value="${fn:length(providersList) > 1}"/>

<script type="text/javascript">
    $(document).ready(function() {
        function activeSaveButton(){
            if($(':checkbox[name="selectedUsers"]:checked').length > 0){
                $("#saveButton").removeAttr("disabled");
            }else {
                $("#saveButton").attr("disabled", "disabled");
            }
        }

        $(':checkbox[name="selectedUsers"]').click(function() {
            if (!this.checked) {
                $('#cbSelectedAllUsers').prop('checked', false);
            }else {
                if($(':checkbox[name="selectedUsers"]:checked').length == $(':checkbox[name="selectedUsers"]').length){
                    $('#cbSelectedAllUsers').prop('checked', true);
                }
            }

            activeSaveButton();
        });
        $('#cbSelectedAllUsers').click(function() {
            var state = this.checked;
            $.each($(':checkbox[name="selectedUsers"]'), function() {
                this.checked=state;
            });

            activeSaveButton();
        });
    })
</script>

<div>
    <form action="${flowExecutionUrl}" method="post" style="display: inline;">
        <div>
            <button class="btn" type="submit" name="_eventId_cancel">
                <i class="icon-arrow-left"></i>
                &nbsp;<fmt:message key="newsletter.subscription.backToSubscriptionList"/>
            </button>
        </div>
    </form>
</div>

<div class="box-1">
    <form class="form-inline " action="${flowExecutionUrl}" id="searchForm" method="post">
        <input type="hidden" id="searchIn" name="searchIn" value="allProps"/>
        <fieldset>
            <h2><fmt:message key="label.search"/></h2>

            <div class="input-append">
                <label style="display: none;" for="searchString"><fmt:message key="label.search"/></label>
                <input class="span6" type="text" id="searchString" name="searchString"
                       value='${searchCriteria.searchString}'
                       onkeydown="if (event.keyCode == 13) submitForm('search');"/>
                <button class="btn btn-primary" type="submit" name="_eventId_search">
                    <i class="icon-search icon-white"></i>
                    &nbsp;<fmt:message key='label.search'/>
                </button>
            </div>
            <c:if test="${multipleProvidersAvailable}">
                <br/>
                <label for="storedOn"><span class="badge badge-info"><fmt:message key="label.on"/></span></label>
                <%--@elvariable id="providersList" type="java.util.List"--%>
                <input type="radio" name="storedOn" id="storeOnEverywhere" value="everywhere"
                       <c:if test="${empty searchCriteria.storedOn or searchCriteria.storedOn eq 'everywhere'}">checked</c:if>
                       onclick="$('.provCheck').attr('disabled',true);">&nbsp;<label for="storeOnEverywhere"><fmt:message
                    key="label.everyWhere"/></label>

                <input type="radio" id="storedOn" name="storedOn" value="providers"
                <c:if test="${searchCriteria.storedOn eq 'providers'}">
                       checked </c:if>
                       onclick="$('.provCheck').removeAttr('disabled');">&nbsp;<label for="storedOn"><fmt:message key="label.providers"/></label>:&nbsp;

                <c:forEach items="${providersList}" var="curProvider">
                    <input type="checkbox" class="provCheck" name="providers" id="provider-${curProvider.key}" value="${curProvider.key}"
                           <c:if test="${fn:length(providersList) le 1 or searchCriteria.storedOn ne 'providers'}">disabled </c:if>
                    <c:if test="${fn:length(providersList) le 1 or (not empty searchCriteria.providers and functions:contains(searchCriteria.providers, curProvider.key))}">
                           checked </c:if>>
                    <label for="provider-${curProvider.key}">
                        <fmt:message var="i18nProviderLabel" key="providers.${curProvider.key}.label"/>
                            ${fn:escapeXml(fn:contains(i18nProviderLabel, '???') ? curProvider.key : i18nProviderLabel)}
                    </label>
                </c:forEach>
            </c:if>
        </fieldset>
    </form>
</div>

<form action="${flowExecutionUrl}" method="post" id="saveForm">
    <div>
        <button class="btn btn-primary" type="submit" name="_eventId_save" id="saveButton" disabled="disabled">
            <i class="icon-ok"></i>
            &nbsp;<fmt:message key="label.save"/>
        </button>

        <c:if test="${usersCount > memberDisplayLimit}">
            <div class="alert alert-info">
                <fmt:message key="newsletter.subscriptions.users.found">
                    <fmt:param value="${usersCount}"/>
                    <fmt:param value="${memberDisplayLimit}"/>
                </fmt:message>
            </div>
        </c:if>

        <table class="table table-bordered table-striped table-hover">
            <thead>
            <tr>
                <th width="2%"><input type="checkbox" id="cbSelectedAllUsers"/></th>
                <th><fmt:message key="label.name"/></th>
                <c:if test="${multipleProvidersAvailable}">
                    <th width="10%"><fmt:message key="column.provider.label"/></th>
                </c:if>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${!usersFound}">
                    <tr>
                        <td colspan="${multipleProvidersAvailable ? '3' : '2'}"><fmt:message
                                key="label.noItemFound"/></td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${users}" var="user" end="${memberDisplayLimit - 1}"
                               varStatus="loopStatus">
                        <tr>
                            <td>
                                <input class="selectedUser" type="checkbox" name="selectedUsers" value="${user.userKey}"/>
                            </td>
                            <td>
                                ${fn:escapeXml(user:displayName(user))}
                            </td>
                            <c:if test="${multipleProvidersAvailable}">
                                <fmt:message var="i18nProviderLabel" key="providers.${user.providerName}.label"/>
                                <td>${fn:escapeXml(fn:contains(i18nProviderLabel, '???') ? user.providerName : i18nProviderLabel)}</td>
                            </c:if>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>

    </div>

</form>