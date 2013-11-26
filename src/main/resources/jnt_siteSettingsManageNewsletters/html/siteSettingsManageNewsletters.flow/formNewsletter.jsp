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
<%--@elvariable id="newsletter" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="newslettersRootNode" type="org.jahia.services.content.JCRNodeWrapper"--%>

<template:addResources type="javascript" resources="jquery.min.js,jquery.form.js,jquery-ui.min.js,jquery.blockUI.js,workInProgress.js,admin-bootstrap.js"/>
<template:addResources type="css" resources="admin-bootstrap.css"/>
<template:addResources type="css" resources="jquery-ui.smoothness.css,jquery-ui.smoothness-jahia.css"/>

<fmt:message var="i18nNameMandatory" key="newsletter.errors.name.mandatory"/><c:set var="i18nNameMandatory" value="${fn:escapeXml(i18nNameMandatory)}"/>
<fmt:message var="i18nSubscriptionPageMandatory" key="newsletter.errors.subscriptionPage.mandatory"/><c:set var="i18nSubscriptionPageMandatory" value="${fn:escapeXml(i18nSubscriptionPageMandatory)}"/>
<fmt:message var="i18nCreationFailed" key="newsletter.errors.create.failed"/><c:set var="i18nCreationFailed" value="${fn:escapeXml(i18nCreationFailed)}"/>
<fmt:message var="i18nUpdateFailed" key="newsletter.errors.update.failed"/><c:set var="i18nUpdateFailed" value="${fn:escapeXml(i18nUpdateFailed)}"/>


<c:set var="site" value="${renderContext.mainResource.node.resolveSite}"/>
<c:set var="isUpdate" value="false"/>
<c:if test="${not empty newsletterUUID}">
    <jcr:node var="newsletter" uuid="${newsletterUUID}"/>
    <c:set var="isUpdate" value="${newsletter != null}"/>
</c:if>

<script type="text/javascript">
    function showNewsletterErrors(messages, separator) {
        var message = "";
        for(var i = 0; i < messages.length; i++){
            if(i == 0){
                message = messages[i];
            }else {
                message += (separator + messages[i]);
            }
        }
        $("#newsletterFormErrorMessages").html(message);
        $("#newsletterFormErrorContainer").show();
    }

    function hideNewsletterErrors() {
        $("#newsletterFormErrorMessages").empty();
        $("#newsletterFormErrorContainer").hide();
    }

    function submitNewsletterForm(act, name, type) {
        $('#newsletterFormAction').val(act);
        if(name){
            $('#newsletterActionName').val(name);
        }
        if(type){
            $('#newsletterActionType').val(type);
        }

        $('#newsletterWebflowForm').submit();
    }

    $(document).ready(function() {
        $("#newsletterFormErrorClose").bind("click", function(){
            hideNewsletterErrors();
        });

        var newsletterFormOptions = {
            beforeSubmit: function(arr, $form, options) {
                // validate fields
                var messages = [];
                if(!$("#newsletterName").val()) {
                    messages.push("${i18nNameMandatory}");
                }
                if(!$("#newsletterSubscriptionPage").val()) {
                    messages.push("${i18nSubscriptionPageMandatory}");
                }
                if(messages.length > 0){
                    showNewsletterErrors(messages, "</br>");
                    return false;
                }
                arr.push({name:"j:allowUnregisteredUsers",value:$("#newsletterIsPublic").is(":checked")});
            },
            success: function() {
                submitNewsletterForm("actionPerformed", $("#newsletterName").val(), "${isUpdate ? 'updated' : 'created'}");
            },
            error: function() {
                <c:choose>
                    <c:when test="${isUpdate}">
                        showNewsletterErrors("${i18nUpdateFailed}");
                    </c:when>
                    <c:otherwise>
                        showNewsletterErrors("${i18nCreationFailed}");
                    </c:otherwise>
                </c:choose>
            }
        };

        $('#newsletterForm').ajaxForm(newsletterFormOptions);
    });
</script>

<div>
    <form action="${flowExecutionUrl}" method="post" style="display: inline;" id="newsletterWebflowForm">
        <input type="hidden" name="name" id="newsletterActionName"/>
        <input type="hidden" name="type" id="newsletterActionType"/>
        <input type="hidden" name="model" value="newsletter"/>
        <input type="hidden" name="_eventId" id="newsletterFormAction"/>
    </form>

    <c:choose>
        <c:when test="${isUpdate}">
            <c:url var="actionUrl" value="${url.baseEdit}${newsletter.path}"/>
            <h2><fmt:message key="newsletter.edit"/> - ${fn:escapeXml(newsletter.displayableName)}</h2>
        </c:when>
        <c:otherwise>
            <c:url var="actionUrl" value="${url.baseEdit}${newslettersRootNode.path}/*"/>
            <h2><fmt:message key="newsletter.create"/></h2>
        </c:otherwise>
    </c:choose>

    <div class="box-1">
        <div class="alert alert-error" style="display: none" id="newsletterFormErrorContainer">
            <button type="button" class="close" id="newsletterFormErrorClose">&times;</button>
            <span id="newsletterFormErrorMessages"></span>
        </div>

        <form action="${actionUrl}" method="POST" id="newsletterForm">
            <input type="hidden" name="jcrNodeType" value="jnt:newsletter">

            <fieldset>
                <div class="container-fluid">
                    <div class="row-fluid">
                        <div class="span4">
                            <c:set var="newsletterName" value="${isUpdate ? newsletter.displayableName : ''}"/>
                            <label for="newsletterName"><fmt:message key="label.name"/> <span class="text-error"><strong>*</strong></span></label>
                            <input type="text" name="jcr:title" class="span12" id="newsletterName" value="${fn:escapeXml(newsletterName)}"/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <div class="span4">
                            <c:set var="newsletterIsPublic" value="${isUpdate ? newsletter.properties['j:allowUnregisteredUsers'].boolean : true}"/>
                            <label for="newsletterIsPublic"><fmt:message key="jmix_subscribable.j_allowUnregisteredUsers"/></label>
                            <input type="checkbox" id="newsletterIsPublic" ${newsletterIsPublic ? 'checked="checked"' : ''}/>
                        </div>
                    </div>
                    <div class="row-fluid">
                        <div class="span4">
                            <c:if test="${isUpdate}">
                                <jcr:node var="subscriptionPage" uuid="${newsletter.properties['j:subscriptionPage'].string}"/>
                            </c:if>
                            <label for="newsletterSubscriptionPage"><fmt:message key="jnt_newsletter.j_subscriptionPage"/> <span class="text-error"><strong>*</strong></span></label>
                            <input type="hidden" id="newsletterSubscriptionPage" name="j:subscriptionPage" value="${isUpdate ? subscriptionPage.identifier : ''}"/>
                            <input type="text" id="newsletterSubscriptionPageDecoy" value="${isUpdate ? subscriptionPage.displayableName : ''}"/>
                            <ui:pageSelector fieldId="newsletterSubscriptionPage" displayFieldId="newsletterSubscriptionPageDecoy" displayIncludeChildren="false" valueType="identifier"/>
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
                            <button class="btn" onclick="submitNewsletterForm('cancel'); return false;">
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



