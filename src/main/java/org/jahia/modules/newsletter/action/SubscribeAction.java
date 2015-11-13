/**
 * ==========================================================================================
 * =                   JAHIA'S DUAL LICENSING - IMPORTANT INFORMATION                       =
 * ==========================================================================================
 *
 *     Copyright (C) 2002-2015 Jahia Solutions Group SA. All rights reserved.
 *
 *     THIS FILE IS AVAILABLE UNDER TWO DIFFERENT LICENSES:
 *     1/GPL OR 2/JSEL
 *
 *     1/ GPL
 *     ======================================================================================
 *
 *     IF YOU DECIDE TO CHOSE THE GPL LICENSE, YOU MUST COMPLY WITH THE FOLLOWING TERMS:
 *
 *     "This program is free software; you can redistribute it and/or
 *     modify it under the terms of the GNU General Public License
 *     as published by the Free Software Foundation; either version 2
 *     of the License, or (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *     As a special exception to the terms and conditions of version 2.0 of
 *     the GPL (or any later version), you may redistribute this Program in connection
 *     with Free/Libre and Open Source Software ("FLOSS") applications as described
 *     in Jahia's FLOSS exception. You should have received a copy of the text
 *     describing the FLOSS exception, also available here:
 *     http://www.jahia.com/license"
 *
 *     2/ JSEL - Commercial and Supported Versions of the program
 *     ======================================================================================
 *
 *     IF YOU DECIDE TO CHOOSE THE JSEL LICENSE, YOU MUST COMPLY WITH THE FOLLOWING TERMS:
 *
 *     Alternatively, commercial and supported versions of the program - also known as
 *     Enterprise Distributions - must be used in accordance with the terms and conditions
 *     contained in a separate written agreement between you and Jahia Solutions Group SA.
 *
 *     If you are unsure which license is appropriate for your use,
 *     please contact the sales department at sales@jahia.com.
 *
 *
 * ==========================================================================================
 * =                                   ABOUT JAHIA                                          =
 * ==========================================================================================
 *
 *     Rooted in Open Source CMS, Jahia’s Digital Industrialization paradigm is about
 *     streamlining Enterprise digital projects across channels to truly control
 *     time-to-market and TCO, project after project.
 *     Putting an end to “the Tunnel effect”, the Jahia Studio enables IT and
 *     marketing teams to collaboratively and iteratively build cutting-edge
 *     online business solutions.
 *     These, in turn, are securely and easily deployed as modules and apps,
 *     reusable across any digital projects, thanks to the Jahia Private App Store Software.
 *     Each solution provided by Jahia stems from this overarching vision:
 *     Digital Factory, Workspace Factory, Portal Factory and eCommerce Factory.
 *     Founded in 2002 and headquartered in Geneva, Switzerland,
 *     Jahia Solutions Group has its North American headquarters in Washington DC,
 *     with offices in Chicago, Toronto and throughout Europe.
 *     Jahia counts hundreds of global brands and governmental organizations
 *     among its loyal customers, in more than 20 countries across the globe.
 *
 *     For more information, please visit http://www.jahia.com
 */
package org.jahia.modules.newsletter.action;

import org.apache.commons.lang.StringUtils;
import org.jahia.bin.Action;
import org.jahia.bin.ActionResult;
import org.jahia.bin.Jahia;
import org.jahia.bin.Render;
import org.jahia.data.templates.JahiaTemplatesPackage;
import org.jahia.modules.newsletter.service.SubscriptionService;
import org.jahia.registries.ServicesRegistry;
import org.jahia.services.content.JCRCallback;
import org.jahia.services.content.JCRNodeWrapper;
import org.jahia.services.content.JCRSessionWrapper;
import org.jahia.services.content.JCRTemplate;
import org.jahia.services.content.decorator.JCRUserNode;
import org.jahia.services.mail.MailService;
import org.jahia.services.content.decorator.JCRSiteNode;
import org.jahia.services.render.RenderContext;
import org.jahia.services.render.Resource;
import org.jahia.services.render.URLResolver;
import org.jahia.services.usermanager.JahiaUser;
import org.jahia.services.usermanager.JahiaUserManagerService;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import javax.jcr.RepositoryException;
import javax.script.ScriptException;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
import static javax.servlet.http.HttpServletResponse.SC_OK;

/**
 * An action for subscribing a user to the target node.
 * 
 * @author Sergiy Shyrkov
 */
public class SubscribeAction extends Action {

	private static final Logger logger = LoggerFactory.getLogger(SubscribeAction.class);

	private boolean forceConfirmationForRegisteredUsers;

	private boolean allowRegistrationWithoutEmail;

	private String mailConfirmationTemplate = null;

    @Autowired
    private MailService mailService;

    @Autowired
	private SubscriptionService subscriptionService;

    @Autowired
    private JahiaUserManagerService userManagerService;

    public ActionResult doExecute(final HttpServletRequest req, final RenderContext renderContext,
                                  final Resource resource, JCRSessionWrapper session, final Map<String, List<String>> parameters, URLResolver urlResolver)
	        throws Exception {

        return JCRTemplate.getInstance().doExecuteWithSystemSession(null, "live", new JCRCallback<ActionResult>() {
            public ActionResult doInJCR(JCRSessionWrapper session) throws RepositoryException {
                try {
                    String email = getParameter(parameters, "email");
                    final JCRNodeWrapper node = resource.getNode();
                    if (email != null) {
                        // consider as non-registered user
                        if (email.length() == 0 || !MailService.isValidEmailAddress(email, false)) {
                            // provided e-mail is empty
                            logger.warn("Invalid e-mail address '{}' provided for subscription to {}."
                                    + " Ignoring subscription request.", email, node.getPath());
                            return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"invalid-email\"}"));
                        }
                        Map<String, Object> props = new HashMap<String, Object>();
                        String[] extraProperties = req.getParameterValues("j:fields");
                        if (extraProperties != null) {
                        	for (String extraProperty : extraProperties) {
	                            if (req.getParameter(extraProperty) != null) {
	                            	props.put(extraProperty, req.getParameter(extraProperty));
	                            }
                            }
                        }

                        final JCRNodeWrapper subscription = subscriptionService.getSubscription(node, email, session);
                        if (subscription != null) {
                            if (!subscription.getProperty(SubscriptionService.J_CONFIRMED).getBoolean()) {
                                if (sendConfirmationMail(session, email, node, subscription, resource.getLocale(), req)) {
                                    return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"mail-sent\"}"));
                                }
                            }
                            return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"already-subscribed\"}"));
                        } else {
                            JCRNodeWrapper newSubscriptionNode = subscriptionService.subscribe(node.getIdentifier(), email, props, session);

                            if (sendConfirmationMail(session, email, node, newSubscriptionNode, resource.getLocale(),
                                    req)) {
                                return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"mail-sent\"}"));
                            }
                        }
                    } else {
                        JahiaUser user = renderContext.getUser();
                        JCRUserNode userNode = userManagerService.lookupUserByPath(user.getLocalPath());
                        if (JahiaUserManagerService.isGuest(user) || userNode == null) {
                            // anonymous users are not allowed (and no email was provided)
                            return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"invalid-email\"}"));
                        }
                        if (!allowRegistrationWithoutEmail) {
                            // checking if the user has a valid e-mail address
                            String userEmail = userNode.getPropertyAsString("j:email");
                            if (userEmail == null || !MailService.isValidEmailAddress(userEmail, false)) {
                                // no valid e-mail provided -> refuse
                                return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"no-valid-email\"}"));
                            }
                        }
                        if (subscriptionService.getSubscription(node.getIdentifier(), user.getUserKey(),
                                session) != null) {
                            return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"already-subscribed\"}"));
                        } else {
                            JCRNodeWrapper newSubscriptionNode = subscriptionService.subscribe(node.getIdentifier(), user.getUserKey(), forceConfirmationForRegisteredUsers, session);

                            if (forceConfirmationForRegisteredUsers) {
	                            if (sendConfirmationMail(session, userNode.getPropertyAsString("j:email"), node, newSubscriptionNode,
	                                    resource.getLocale(), req)) {
	                                return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"mail-sent\"}"));
	                            }
                            } else {
                            	return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"ok\"}"));
                            }

                        }
                    }
                    return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"ok\"}"));
                } catch (JSONException e) {
                    logger.error("Error",e);
                    return new ActionResult(SC_INTERNAL_SERVER_ERROR, null, null);
                }
            }
        });
	}

    private boolean sendConfirmationMail(JCRSessionWrapper session, String email, JCRNodeWrapper node,
                                         JCRNodeWrapper newSubscriptionNode, final Locale locale, HttpServletRequest req)
            throws RepositoryException, JSONException {
        if (mailConfirmationTemplate != null) {
            String confirmationKey = subscriptionService.generateConfirmationKey(newSubscriptionNode);
            newSubscriptionNode.setProperty(SubscriptionService.J_CONFIRMED, false);
            newSubscriptionNode.setProperty(SubscriptionService.J_CONFIRMATION_KEY, confirmationKey);
            session.save();
            Map<String, Object> bindings = new HashMap<String, Object>();
            bindings.put("newsletter", node);

            bindings.put("confirmationlink", req.getScheme() +"://" + req.getServerName() + ":" + req.getServerPort() +
                    Jahia.getContextPath() + Render.getRenderServletPath() + "/live/"
                    + node.getLanguage() + node.getPath() + ".confirm.do?key="+confirmationKey+"&exec=add");
            try {
            	String modulePackageNameToUse = getTemplateName(mailConfirmationTemplate,node, locale,"Jahia Newsletter");
				String mailSender = mailService.defaultSender();

		        try {
		            JCRSiteNode siteNode = node.getResolveSite();

		            if (siteNode.isNodeType("jmix:newsletterSender")) {
		                String newMailSender = siteNode.getPropertyAsString(
		                        "newsletterMailSender");

		                if ((newMailSender != null) &&
		                        !"".equals(newMailSender.trim())) {
		                    mailSender = newMailSender;
		                }
		            }
		        } catch (Exception ue) {
		            logger.debug(ue.getMessage(), ue);
		        }
                mailService.sendMessageWithTemplate(mailConfirmationTemplate, bindings, email, mailSender, null, null,
                        locale, modulePackageNameToUse);
            } catch (ScriptException e) {
                logger.error("Cannot generate confirmation mail",e);
            }

            return true;
        }
        return false;
    }

	/**
	* Check if templatSet has mail template
	*/
    private String getTemplateName(String template, JCRNodeWrapper node,  final Locale locale, String defaultTemplate){
    	String templateToReturn = defaultTemplate;

    	try {
	    	//try if it is multilingual
	        String suffix = StringUtils.substringAfterLast(template, ".");
	    	String languageMailConfTemplate = template.substring(0, template.length() - (suffix.length()+1)) + "_" + locale.toString() + "." + suffix;
	    	String templatePackageName = node.getResolveSite().getTemplatePackageName();
	    	JahiaTemplatesPackage templatePackage = ServicesRegistry.getInstance().getJahiaTemplateManagerService().getTemplatePackage(templatePackageName);
	    	org.springframework.core.io.Resource templateRealPath = templatePackage.getResource(languageMailConfTemplate);
	    	if(templateRealPath == null) {
	          templateRealPath = templatePackage.getResource(template);
	    	}
	    	if (templateRealPath!=null){
	    		templateToReturn = templatePackageName;
	    	}
    	} catch (Exception ue){
    		logger.error("Error resolving template for site");
    	}

    	return templateToReturn;
    }
    public void setAllowRegistrationWithoutEmail(boolean allowRegistrationWithoutEmail) {
		this.allowRegistrationWithoutEmail = allowRegistrationWithoutEmail;
	}

    public void setMailConfirmationTemplate(String mailConfirmationTemplate) {
        this.mailConfirmationTemplate = mailConfirmationTemplate;
    }

    public void setMailService(MailService mailService) {
        this.mailService = mailService;
    }

    public void setSubscriptionService(SubscriptionService subscriptionService) {
		this.subscriptionService = subscriptionService;
	}

    public void setUserManagerService(JahiaUserManagerService userManagerService) {
        this.userManagerService = userManagerService;
    }

    public void setForceConfirmationForRegisteredUsers(boolean forceConfirmationForRegisteredUsers) {
    	this.forceConfirmationForRegisteredUsers = forceConfirmationForRegisteredUsers;
    }

}