<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>

<c:set var="target" value="${currentNode.properties['j:target'].node}"/>
<c:set var="doDisplaySubscription" value="${not empty target && (renderContext.loggedIn || target.properties['j:allowUnregisteredUsers'].boolean)}"/>
<c:if test="${doDisplaySubscription}">
	<c:set var="availableInLive" value="${not empty target.properties['j:lastPublished']}"/>
	<c:if test="${availableInLive}">
		<%-- Subscriptions are available in live mode only --%>
		<template:addResources type="css" resources="jquery.fancybox.css"/>
		<template:addResources type="css" resources="jahia.fancybox-form.css"/>
		<template:addResources type="javascript" resources="jquery.min.js,jquery.fancybox.pack.js"/>
		
		<template:addResources>
			<script type="text/javascript">
			function jahiaSubscribe(subscribeActionUrl, formData) {
				$.ajax({
					type: "POST",
					url: subscribeActionUrl,
					cache: false,
					data: formData,
					success: function (data, textStatus, xhr) {
						var doClose=true;
						if (data.status == "ok") {
					    	<fmt:message key="messsage.subscriptions.successfullySubscribed" var="msg"/>
					        alert("${functions:escapeJavaScript(msg)}");
						} else if (data.status == "already-subscribed") {
					    	<fmt:message key="messsage.subscriptions.alreadySubscribed" var="msg"/>
					        alert("${functions:escapeJavaScript(msg)}");
						} else if (data.status == "invalid-email") {
					    	<fmt:message key="messsage.subscriptions.invalidEmailAddress" var="msg"/>
					        alert("${functions:escapeJavaScript(msg)}");
					        doClose=false;
						} else if (data.status == 'no-valid-email') {
					    	<fmt:message key="messsage.subscriptions.provideEmailAddress" var="msg"/>
					        alert("${functions:escapeJavaScript(msg)}");
						} else {
					        alert(data.status);
						}
						if (doClose) {
							$.fancybox.close();
						} else {
							$.fancybox.hideActivity();
						}
					},
					error: function (xhr, textStatus, errorThrown) {
						if (xhr.status == 401) {
					    	<fmt:message key="label.httpUnauthorized" var="msg"/>
					        alert("${functions:escapeJavaScript(msg)}");
							$.fancybox.close();
						} else {
							alert(xhr.status + ": " + xhr.statusText);
							$.fancybox.close();
						}
					},
					dataType: "json"
				});
			}
			$(document).ready(function() {
		        $(".showSubscriptionForm").fancybox({
		            'centerOnScroll'     : true,
		            'overlayOpacity'     : 0.6,
		            'titleShow'          : false,
		            'transitionIn'       : 'none',
		            'transitionOut'      : 'none',
		            'onStart'            : function(selectedArray, selectedIndex, selectedOpts) {
		            	$('#subscribeForm-' + $(selectedArray).attr('rel') + '-email').val('');
		            }
		        });
		        $("form.jahiaSubscribeForm").submit(function() {
		        	if (this.email.value.length == 0) {
				    	<fmt:message key="messsage.subscriptions.provideEmailAddress" var="msg"/>
				        alert("${functions:escapeJavaScript(msg)}");
			        	return false;
		        	}
		        	
		            $.fancybox.showActivity();
		            jahiaSubscribe(this.action, $(this).serialize());
		        	return false;
		        });
		    });
			</script> 
		</template:addResources>
	
			<c:set var="subscribeTitle" value="${fn:escapeXml(functions:default(currentNode.propertiesAsString['jcr:title'], target.displayableName))}"/>
		<p>
			${subscribeTitle}
		<c:if test="${renderContext.loggedIn}">
			&nbsp;<a href="#subscribe" onclick="jahiaSubscribe('${url.base}${target.path}.subscribe.do'); return false;" title="<fmt:message key='label.subscribe'/>"><img src="<c:url value='/icons/jnt_subscriptions.png' context='${url.currentModule}'/>" alt="<fmt:message key='label.subscribe'/>" title="<fmt:message key='label.subscribe'/>" height="16" width="16"/></a>		
			</p>
		</c:if>
		<c:if test="${not renderContext.loggedIn}">
			&nbsp;<a href="#subscribeFormPanel-${currentNode.identifier}" rel="${currentNode.identifier}" class="showSubscriptionForm" title="<fmt:message key='label.subscribe'/>"><img src="<c:url value='/icons/jnt_subscriptions.png' context='${url.currentModule}'/>" alt="<fmt:message key='label.subscribe'/>" title="<fmt:message key='label.subscribe'/>" height="16" width="16"/></a>
			</p>
			<div id="subscribeFormPanel-${currentNode.identifier}" class="jahiaFancyboxForm" style="width: 350px;height: ${130 + fn:length(currentNode.properties['j:fields'])*50}px;">
			    <div class="popup-bodywrapper">
			        <h3 class="boxmessage-title">${subscribeTitle}</h3>
			        <form class="formMessage jahiaSubscribeForm" id="subscribeForm-${currentNode.identifier}" method="post" action="<c:url value='${target.path}.subscribe.do' context='${url.base}'/>">
			            <input type="hidden" name="j:to" id="destinationUserKey" value="" />
			            <fieldset>
			                <p>
			                	<label for="subscribeForm-${currentNode.identifier}-email" class="left"><fmt:message key="label.email"/>*</label>
			                    <input type="text" name="email" id="subscribeForm-${currentNode.identifier}-email" class="field" value="" tabindex="20"/>
			                </p>
			                <c:forEach items="${currentNode.properties['j:fields']}" var="fld" varStatus="status">
	                			<c:set var="fldKey" value="${fn:replace(fld.string, ':', '_')}"/>
				                <p>
				                	<label for="subscribeForm-${currentNode.identifier}-${fldKey}" class="left"><fmt:message key="jnt_subscriptionComponent.j_fields.${fldKey}"/></label>
				                    <input type="text" name="${fld.string}" id="subscribeForm-${currentNode.identifier}-${fldKey}" class="field" value="" tabindex="${20 + status.count}"/>
				                </p>
			                </c:forEach>
			                
			                <input class="button" type="button" value=" <fmt:message key="label.subscribe"/> "
			                       tabindex="30" onclick="$('#subscribeForm-${currentNode.identifier}').submit();">
			            </fieldset>
			        </form>
			    </div>
			</div>			
		</c:if>
	</c:if>
	<c:if test="${not availableInLive}">
		<p>
		${fn:escapeXml(functions:default(currentNode.propertiesAsString['jcr:title'], target.displayableName))}
		<fmt:message key="label.subscriptions.notAvailableInliveMode" var="msg"/>
		&nbsp;<a href="#subscribe" onclick="alert('${functions:escapeJavaScript(msg)}'); return false;" title="<fmt:message key='label.subscribe'/>"><img src="<c:url value='/icons/jnt_subscriptions.png' context='${url.currentModule}'/>" alt="<fmt:message key='label.subscribe'/>" title="<fmt:message key='label.subscribe'/>" height="16" width="16"/></a>
		</p>
	</c:if>
</c:if>
<c:if test="${not doDisplaySubscription && empty target && !renderContext.liveMode}">
	<p><fmt:message key="label.subscriptions.noTarget"/></p>
</c:if>