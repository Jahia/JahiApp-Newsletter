/**
 * ==========================================================================================
 * =                        DIGITAL FACTORY v7.0 - Community Distribution                   =
 * ==========================================================================================
 *
 *     Rooted in Open Source CMS, Jahia's Digital Industrialization paradigm is about
 *     streamlining Enterprise digital projects across channels to truly control
 *     time-to-market and TCO, project after project.
 *     Putting an end to "the Tunnel effect", the Jahia Studio enables IT and
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
 *
 * JAHIA'S DUAL LICENSING IMPORTANT INFORMATION
 * ============================================
 *
 *     Copyright (C) 2002-2014 Jahia Solutions Group SA. All rights reserved.
 *
 *     THIS FILE IS AVAILABLE UNDER TWO DIFFERENT LICENSES:
 *     1/GPL OR 2/JSEL
 *
 *     1/ GPL
 *     ==========================================================
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
 *     describing the FLOSS exception, and it is also available here:
 *     http://www.jahia.com/license"
 *
 *     2/ JSEL - Commercial and Supported Versions of the program
 *     ==========================================================
 *
 *     IF YOU DECIDE TO CHOOSE THE JSEL LICENSE, YOU MUST COMPLY WITH THE FOLLOWING TERMS:
 *
 *     Alternatively, commercial and supported versions of the program - also known as
 *     Enterprise Distributions - must be used in accordance with the terms and conditions
 *     contained in a separate written agreement between you and Jahia Solutions Group SA.
 *
 *     If you are unsure which license is appropriate for your use,
 *     please contact the sales department at sales@jahia.com.
 */
package org.jahia.modules.newsletter.action;

import org.jahia.bin.Action;
import org.jahia.bin.ActionResult;
import org.jahia.bin.Jahia;
import org.jahia.bin.Render;
import org.jahia.modules.newsletter.service.SubscriptionService;
import org.jahia.services.content.JCRCallback;
import org.jahia.services.content.JCRNodeWrapper;
import org.jahia.services.content.JCRSessionWrapper;
import org.jahia.services.content.JCRTemplate;
import org.jahia.services.mail.MailService;
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
import java.util.Map;

import static javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
import static javax.servlet.http.HttpServletResponse.SC_OK;

/**
 * An action for subscribing a user to the target node.
 * 
 * @author Sergiy Shyrkov
 */
public class UnsubscribeAction extends Action {

	private static final Logger logger = LoggerFactory.getLogger(UnsubscribeAction.class);

	private boolean forceConfirmationForRegisteredUsers;

    private String mailConfirmationTemplate = null;

    @Autowired
    private MailService mailService;
    @Autowired
	private SubscriptionService subscriptionService;
	
	public static String generateUnsubscribeLink(JCRNodeWrapper newsletterNode, String confirmationKey,
	        HttpServletRequest req) throws RepositoryException {
		return req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort()
		        + Jahia.getContextPath() + Render.getRenderServletPath() + "/live/"
		        + newsletterNode.getLanguage() + newsletterNode.getPath()
		        + ".confirm.do?key=" + confirmationKey + "&exec=rem";
	}

    public ActionResult doExecute(final HttpServletRequest req, final RenderContext renderContext,
                                  final Resource resource, JCRSessionWrapper session, final Map<String, List<String>> parameters, URLResolver urlResolver)
            throws Exception {

        return JCRTemplate.getInstance().doExecuteWithSystemSession(null, "live", new JCRCallback<ActionResult>() {
            public ActionResult doInJCR(JCRSessionWrapper session) throws RepositoryException {
                try {
                    String email = getParameter(parameters, "email");
                    final JCRNodeWrapper node = resource.getNode();
                    session.checkout(node);
                    if (email != null) {
                        // consider as non-registered user
                        JCRNodeWrapper subscription = subscriptionService.getSubscription(node, email, session);

                        if (subscription == null) {
                            return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"invalid-user\"}"));
                        } else if (sendConfirmationMail(session, email, node, subscription, resource, req)) {
                            return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"mail-sent\"}"));
                        }

                        subscriptionService.cancel(subscription.getIdentifier(), session);
                    } else {
                        JahiaUser user = renderContext.getUser();
                        if (JahiaUserManagerService.isGuest(user)) {
                            // anonymous users are not allowed (and no email was provided)
                            return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"invalid-user\"}"));
                        }

                        JCRNodeWrapper subscription = subscriptionService.getSubscription(node, user.getUsername(), session);

                        if (subscription == null) {
                            return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"invalid-user\"}"));
                        } else if (forceConfirmationForRegisteredUsers && sendConfirmationMail(session, user.getProperty("j:email"), node, subscription, resource, req)) {
                        	return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"mail-sent\"}"));
                        }

                        subscriptionService.cancel(subscription.getIdentifier(), session);
                    }
                    return new ActionResult(SC_OK, null, new JSONObject("{\"status\":\"ok\"}"));
                } catch (JSONException e) {
                    logger.error("Error",e);
                    return new ActionResult(SC_INTERNAL_SERVER_ERROR, null, null);
                }
            }
        });

    }

    private boolean sendConfirmationMail(JCRSessionWrapper session, String email, JCRNodeWrapper node, JCRNodeWrapper subscription,
                                         Resource resource, HttpServletRequest req) throws RepositoryException, JSONException {
        if (mailConfirmationTemplate != null) {
            session.checkout(subscription);
            String confirmationKey = subscriptionService.generateConfirmationKey(subscription);
            subscription.setProperty("j:confirmationKey", confirmationKey);
            session.save();

            Map<String, Object> bindings = new HashMap<String, Object>();
            bindings.put("newsletter", node);
            bindings.put("confirmationlink", generateUnsubscribeLink(node, confirmationKey, req));
            try {
                mailService.sendMessageWithTemplate(mailConfirmationTemplate, bindings, email, mailService.defaultSender(), null, null, resource.getLocale(), "Jahia Newsletter");
            } catch (ScriptException e) {
                logger.error("Cannot generate confirmation mail",e);
            }

            return true;
        }
        return false;
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

	public void setForceConfirmationForRegisteredUsers(boolean forceConfirmationForRegisteredUsers) {
    	this.forceConfirmationForRegisteredUsers = forceConfirmationForRegisteredUsers;
    }

}