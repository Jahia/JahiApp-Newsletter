/**
 * ==========================================================================================
 * =                   JAHIA'S DUAL LICENSING - IMPORTANT INFORMATION                       =
 * ==========================================================================================
 *
 *                                 http://www.jahia.com
 *
 *     Copyright (C) 2002-2017 Jahia Solutions Group SA. All rights reserved.
 *
 *     THIS FILE IS AVAILABLE UNDER TWO DIFFERENT LICENSES:
 *     1/GPL OR 2/JSEL
 *
 *     1/ GPL
 *     ==================================================================================
 *
 *     IF YOU DECIDE TO CHOOSE THE GPL LICENSE, YOU MUST COMPLY WITH THE FOLLOWING TERMS:
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *     2/ JSEL - Commercial and Supported Versions of the program
 *     ===================================================================================
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
import org.jahia.bin.Render;
import org.jahia.modules.newsletter.service.NewsletterService;
import org.jahia.params.valves.TokenAuthValveImpl;
import org.jahia.services.content.JCRNodeWrapper;
import org.jahia.services.content.JCRSessionWrapper;
import org.jahia.services.content.rules.BackgroundAction;
import org.jahia.services.notification.HttpClientService;
import org.jahia.services.render.RenderContext;
import org.jahia.services.render.Resource;
import org.jahia.services.render.URLResolver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * An action and a background task that sends the content of the specified node as a newsletter
 * to its subscribers.
 * 
 * @author Thomas Draier
 * @author Sergiy Shyrkov
 */
public class SendAsNewsletterAction extends Action implements BackgroundAction {

    private static final Logger logger = LoggerFactory.getLogger(SendAsNewsletterAction.class);

    @Autowired
    private transient HttpClientService httpClientService;
    @Autowired
    private transient NewsletterService newsletterService;
    private String localServerURL;

    public ActionResult doExecute(final HttpServletRequest req, final RenderContext renderContext,
                                  Resource resource, JCRSessionWrapper session, Map<String, List<String>> parameters, URLResolver urlResolver)
            throws Exception {
        JCRNodeWrapper node = resource.getNode();
        Map<String, String> newsletterVersions = new HashMap<String, String>();

        boolean newsletterSent = newsletterService.sendIssueToSubscribers(node, renderContext, newsletterVersions);

        if(newsletterSent){
            return ActionResult.OK;
        }else {
            return ActionResult.INTERNAL_ERROR;
        }
    }

    public void executeBackgroundAction(JCRNodeWrapper node) {
        // do local post on node.getPath/sendAsNewsletter.do
        try {
            Map<String,String> headers = new HashMap<String,String>();
            headers.put("jahiatoken",TokenAuthValveImpl.addToken(node.getSession().getUser()));
            headers.put("accept", "text/plain");
            String out = httpClientService.executePost(localServerURL + Render.getRenderServletPath() + "/live/"
                            + node.getResolveSite().getDefaultLanguage() + node.getPath()
                            + ".sendAsNewsletter.do", null, headers);
            logger.info(out);
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
    }

    public HttpClientService getHttpClientService() {
        return httpClientService;
    }

    public void setHttpClientService(HttpClientService httpClientService) {
        this.httpClientService = httpClientService;
    }

    public NewsletterService getNewsletterService() {
        return newsletterService;
    }

    public void setNewsletterService(NewsletterService newsletterService) {
        this.newsletterService = newsletterService;
    }

    public String getLocalServerURL() {
        return localServerURL;
    }

    public void setLocalServerURL(String localServerURL) {
        this.localServerURL = localServerURL;
    }
}
