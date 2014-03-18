/**
 * This file is part of Jahia, next-generation open source CMS:
 * Jahia's next-generation, open source CMS stems from a widely acknowledged vision
 * of enterprise application convergence - web, search, document, social and portal -
 * unified by the simplicity of web content management.
 *
 * For more information, please visit http://www.jahia.com.
 *
 * Copyright (C) 2002-2014 Jahia Solutions Group SA. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * As a special exception to the terms and conditions of version 2.0 of
 * the GPL (or any later version), you may redistribute this Program in connection
 * with Free/Libre and Open Source Software ("FLOSS") applications as described
 * in Jahia's FLOSS exception. You should have received a copy of the text
 * describing the FLOSS exception, and it is also available here:
 * http://www.jahia.com/license
 *
 * Commercial and Supported Versions of the program (dual licensing):
 * alternatively, commercial and supported versions of the program may be used
 * in accordance with the terms and conditions contained in a separate
 * written agreement between you and Jahia Solutions Group SA.
 *
 * If you are unsure which license is appropriate for your use,
 * please contact the sales department at sales@jahia.com.
 */

package org.jahia.modules.newsletter.sitesettings;

import org.jahia.api.Constants;
import org.jahia.data.viewhelper.principal.PrincipalViewHelper;
import org.jahia.modules.newsletter.service.NewsletterService;
import org.jahia.modules.newsletter.service.SubscriptionService;
import org.jahia.modules.newsletter.service.model.Subscription;
import org.jahia.modules.newsletter.sitesettings.form.CSVFileForm;
import org.jahia.modules.newsletter.sitesettings.form.TestNewsletterIssueForm;
import org.jahia.services.content.JCRNodeWrapper;
import org.jahia.services.content.JCRPublicationService;
import org.jahia.services.content.JCRSessionFactory;
import org.jahia.services.content.JCRSessionWrapper;
import org.jahia.services.content.decorator.JCRSiteNode;
import org.jahia.services.render.RenderContext;
import org.jahia.services.usermanager.JahiaUser;
import org.jahia.services.usermanager.JahiaUserManagerProvider;
import org.jahia.services.usermanager.JahiaUserManagerService;
import org.jahia.services.usermanager.SearchCriteria;
import org.jahia.utils.LanguageCodeConverters;
import org.jahia.utils.PaginatedList;
import org.jahia.utils.i18n.Messages;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.binding.message.MessageBuilder;
import org.springframework.binding.message.MessageContext;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.webflow.execution.RequestContext;

import javax.jcr.RepositoryException;
import java.io.Serializable;
import java.security.Principal;
import java.util.*;

/**
 * Created with IntelliJ IDEA.
 * User: kevan
 * Date: 08/11/13
 * Time: 17:47
 * To change this template use File | Settings | File Templates.
 */
public class ManageNewsletterFlowHandler implements Serializable {

    private static final Logger logger = LoggerFactory.getLogger(ManageNewsletterFlowHandler.class);

    private static final long serialVersionUID = 4588193889585173288L;
    private static final String ACTION_TYPE_CREATED = "created";
    private static final String ACTION_TYPE_UPDATED = "updated";
    private static final String BUNDLE = "resources.JahiaNewsletter";


    @Autowired
    private transient NewsletterService newsletterService;
    @Autowired
    private transient SubscriptionService subscriptionService;
    @Autowired
    private transient JahiaUserManagerService userManagerService;

    // models
    private TestNewsletterIssueForm testNewsletterIssueForm;

    /* Newsletters */
    public List<JCRNodeWrapper> getSiteNewsletters(RequestContext ctx) {
        JCRSiteNode currentSite = getRenderContext(ctx).getSite();
        return newsletterService.getSiteNewsletters(currentSite, null, false, getCurrentUserSession(ctx));
    }

    public JCRNodeWrapper getNewsletter(RequestContext ctx, String identifier) {
        return getNodeByUUID(identifier, getCurrentUserSession(ctx));
    }

    public boolean removeNewsletter(RequestContext ctx, MessageContext msgCtx, String selectedNewsletter) {
        JCRNodeWrapper newsletterToRemove = getNodeByUUID(selectedNewsletter, getCurrentUserSession(ctx));
        String name = newsletterToRemove.getDisplayableName();
        boolean newsletterRemoved = removeNode(newsletterToRemove);
        setActionMessage(msgCtx, newsletterRemoved, "newsletter", "removed", name);
        return newsletterRemoved;
    }

    public JCRNodeWrapper getNewslettersRootNode(RequestContext ctx) {
        JCRSiteNode currentSite = getRenderContext(ctx).getSite();
        return newsletterService.getNewslettersRootNode(currentSite, getCurrentUserSession(ctx));
    }

    /* Newsletter issues */
    public List<JCRNodeWrapper> getIssues(RequestContext ctx, String selectedNewsletter) {
        return newsletterService.getNewsletterIssues(selectedNewsletter, null, false, getCurrentUserSession(ctx));
    }

    public JCRNodeWrapper getIssue(RequestContext ctx, String identifier) {
        return getNodeByUUID(identifier, getCurrentUserSession("live"));
    }

    public TestNewsletterIssueForm initTestIssueForm(String selectedIssue) {
        testNewsletterIssueForm = new TestNewsletterIssueForm(selectedIssue);
        testNewsletterIssueForm.setUser("guest");
        testNewsletterIssueForm.setLocale(LocaleContextHolder.getLocale().toString());
        return testNewsletterIssueForm;
    }

    public boolean testIssue(RequestContext ctx, MessageContext msgCtx) {
        final Map<String, String> newsletterVersions = new HashMap<String, String>();

        JCRNodeWrapper node = getNodeByUUID(testNewsletterIssueForm.getIssueUUID(), getCurrentUserSession(ctx));
        boolean testIssueSent = false;
        try {
            testIssueSent = newsletterService.sendIssue(getRenderContext(ctx), node, testNewsletterIssueForm.getTestmail(), testNewsletterIssueForm.getUser(), "html",
                    LanguageCodeConverters.languageCodeToLocale(testNewsletterIssueForm.getLocale()), "live",
                    newsletterVersions);
        } catch (RepositoryException e) {
            logger.warn("Unable to update properties for node " + node.getPath(), e);
        }
        setActionMessage(msgCtx, testIssueSent, "newsletter.issue", "sent", node.getDisplayableName());
        return testIssueSent;
    }

    public boolean sendIssue(RequestContext ctx, MessageContext msgCtx, String selectedIssue) {
        final Map<String, String> newsletterVersions = new HashMap<String, String>();
        final RenderContext renderContext = getRenderContext(ctx);
        final JCRNodeWrapper node = getNodeByUUID(selectedIssue, getCurrentUserSession(ctx));

        boolean issueSent = false;
        try {
            issueSent = newsletterService.sendIssueToSubscribers(node, renderContext, newsletterVersions);
        } catch (Exception e) {
            logger.error("Error sending issue with path: " + node.getPath(), e);
        }
        setActionMessage(msgCtx, issueSent, "newsletter.issue", "sent", node.getDisplayableName());
        return issueSent;
    }

    public boolean removeIssue(RequestContext ctx, MessageContext msgCtx, String selectedIssue) {
        JCRNodeWrapper issueToRemove = getNodeByUUID(selectedIssue, getCurrentUserSession(ctx));
        String name = issueToRemove.getDisplayableName();
        boolean issueRemoved = removeNode(issueToRemove);
        setActionMessage(msgCtx, issueRemoved, "newsletter.issue", "removed", name);
        return issueRemoved;
    }

    public boolean publishNewsletter(RequestContext ctx, MessageContext msgCtx, String selectedNewsletter) {
        JCRNodeWrapper newsletterToPublish = getNodeByUUID(selectedNewsletter, getCurrentUserSession(ctx));
        return publishItem(newsletterToPublish, msgCtx, "newsletter");
    }

    public boolean publishIssue(RequestContext ctx, MessageContext msgCtx, String selectedIssue) {
        JCRNodeWrapper issueToPublish = getNodeByUUID(selectedIssue, getCurrentUserSession(ctx));
        return publishItem(issueToPublish, msgCtx, "newsletter.issue");
    }

    private boolean publishItem(JCRNodeWrapper nodeWrapper, MessageContext msgCtx, String itemKey){
        boolean published = false;
        JCRPublicationService publicationService = JCRPublicationService.getInstance();
        String name = nodeWrapper.getDisplayableName();
        if(publicationService != null){
            try {
                publicationService.publish(Collections.singletonList(nodeWrapper.getIdentifier()),
                        nodeWrapper.getSession().getWorkspace().getName(),
                        Constants.LIVE_WORKSPACE, Collections.singletonList(""));

                //in case of newsletter publish j:subscriptions sub node
                if(nodeWrapper.isNodeType("jnt:newsletter")){
                    JCRNodeWrapper subscriptionsNode = nodeWrapper.getNode("j:subscriptions");
                    if(!subscriptionsNode.hasProperty("j:lastPublished")){
                        publicationService.publish(Collections.singletonList(subscriptionsNode.getIdentifier()),
                                nodeWrapper.getSession().getWorkspace().getName(),
                                Constants.LIVE_WORKSPACE, Collections.singletonList(""));
                    }
                }

                setActionMessage(msgCtx, true, itemKey, "published", name);
                published = true;
            } catch (RepositoryException e) {
                logger.error(e.getMessage(), e);
                setActionMessage(msgCtx, false, itemKey, "published", name);
            }
        }else {
            setActionMessage(msgCtx, false, itemKey, "published", name);
        }

        return published;
    }

    /* Subscriptions */
    public PaginatedList<Subscription> getSubscriptions(String selectedNewsletter) {
        JCRSessionWrapper session = getCurrentUserSession("live");
        return subscriptionService.getSubscriptions(selectedNewsletter, null, false, 0, Integer.MAX_VALUE, session);
    }

    public void removeSubscriptions(MessageContext msgCtx, String[] subscriptions){
        JCRSessionWrapper session = getCurrentUserSession("live");
        subscriptionService.cancel(Arrays.asList(subscriptions), session);
        setActionMessage(msgCtx, true, "newsletter.subscription", "removed", subscriptions.length);
    }

    public void suspendSubscriptions(MessageContext msgCtx, String[] subscriptions){
        JCRSessionWrapper session = getCurrentUserSession("live");
        subscriptionService.suspend(Arrays.asList(subscriptions), session);
        setActionMessage(msgCtx, true, "newsletter.subscription", "suspended", subscriptions.length);
    }

    public void resumeSubscriptions(MessageContext msgCtx, String[] subscriptions){
        JCRSessionWrapper session = getCurrentUserSession("live");
        subscriptionService.resume(Arrays.asList(subscriptions), session);
        setActionMessage(msgCtx, true, "newsletter.subscription", "resumed", subscriptions.length);
    }

    /* Subscribers */
    public List<? extends JahiaUserManagerProvider> getProvidersList() {
        return userManagerService.getProviderList();
    }

    public Set<JahiaUser> searchUsers(String newsletterUUID, SearchCriteria searchCriteria){
        Set<JahiaUser> notSubscribeUsers = new LinkedHashSet<JahiaUser>();
        JCRNodeWrapper newsletter = getNodeByUUID(newsletterUUID, getCurrentUserSession("live"));

        Set<Principal> searchResult = PrincipalViewHelper.getSearchResult(searchCriteria.getSearchIn(),
                searchCriteria.getSearchString(), searchCriteria.getProperties(), searchCriteria.getStoredOn(),
                searchCriteria.getProviders());

        if(newsletter != null){
            for (Principal user : searchResult){
                if(user instanceof JahiaUser){
                    JahiaUser jahiaUser = (JahiaUser) user;
                    try {
                        if(subscriptionService.getSubscription(newsletter, jahiaUser.getUserKey(), getCurrentUserSession("live")) == null){
                            notSubscribeUsers.add(jahiaUser);
                        }
                    } catch (RepositoryException e) {
                        logger.warn("Error testing if user: " + jahiaUser.getUserKey() + " has subscribed to node: " + newsletterUUID);
                    }
                }
            }    
        }

        return notSubscribeUsers;
    }

    public void subscribeUsers(String newsletterUUID, String[] users, MessageContext msgCtx){
        subscriptionService.subscribe(newsletterUUID, Arrays.asList(users), getCurrentUserSession("live"));
        setActionMessage(msgCtx, true, "newsletter.subscription", "created", users.length);
    }

    public void bulkSubscribeUsers(String newsletterUUID, CSVFileForm csvFileForm, MessageContext msgCtx){
        subscriptionService.importSubscriptions(newsletterUUID, csvFileForm.getCsvFile(), getCurrentUserSession("live"), csvFileForm.getCsvSeparator().charAt(0));
        setActionMessage(msgCtx, true, "newsletter.subscription", "imported", null);
    }

    /* Commons */
    public CSVFileForm initCSVFileForm() {
        CSVFileForm csvFileForm = new CSVFileForm();
        csvFileForm.setCsvSeparator(",");
        return csvFileForm;
    }

    public SearchCriteria initCriteria(RequestContext ctx) {
        return new SearchCriteria(getRenderContext(ctx).getSite().getID());
    }

    public boolean setActionMessage(RequestContext ctx, MessageContext msgCtx, String action, String name, String item) {
        setActionMessage(msgCtx, true, !item.equals("newsletter") ? "newsletter." + item : item, action, name);
        return true;
    }

    private void setActionMessage(MessageContext msgCtx,  boolean success, String item, String action, Object name){
        Locale locale = LocaleContextHolder.getLocale();
        if (success) {
            String message = Messages.get(BUNDLE, item + ".successfully." + action, locale);
            msgCtx.addMessage(new MessageBuilder()
                    .info()
                    .defaultText(Messages.format(message, name)).build());
        } else {
            msgCtx.addMessage(new MessageBuilder()
                    .error()
                    .defaultText(
                            Messages.get(BUNDLE, "newsletter." + action + ".failed", locale) + " " + name).build());
        }
    }

    private boolean removeNode(JCRNodeWrapper node) {
        try {
            JCRNodeWrapper parentNode = node.getParent();
            node.remove();
            node.getSession().save();

            JCRPublicationService publicationService = JCRPublicationService.getInstance();
            if(publicationService != null){
                publicationService.publish(Collections.singletonList(parentNode.getIdentifier()),
                        node.getSession().getWorkspace().getName(),
                        Constants.LIVE_WORKSPACE, Collections.singletonList(""));
            }
            
            return true;
        } catch (RepositoryException e) {
            logger.error("Error removing node " + node.getDisplayableName(), e);
            return false;
        }
    }

    private JCRSessionWrapper getCurrentUserSession(RequestContext ctx) {
        try {
            RenderContext renderContext = getRenderContext(ctx);
            return JCRSessionFactory.getInstance().getCurrentUserSession(renderContext.getMainResource().getWorkspace(), renderContext.getMainResourceLocale());
        } catch (RepositoryException e) {
            logger.error("Error retrieving current user session", e);
        }
        return null;
    }

    private JCRSessionWrapper getCurrentUserSession(String workspace) {
        try {
            return JCRSessionFactory.getInstance().getCurrentUserSession(workspace);
        } catch (RepositoryException e) {
            logger.error("Error retrieving current user session", e);
        }
        return null;
    }

    private JCRNodeWrapper getNodeByUUID(String identifier, JCRSessionWrapper session) {
        try {
            return session.getNodeByUUID(identifier);
        } catch (RepositoryException e) {
            logger.error("Error retrieving node with UUID " + identifier, e);
        }
        return null;
    }

    private RenderContext getRenderContext(RequestContext ctx) {
        return (RenderContext) ctx.getExternalContext().getRequestMap().get("renderContext");
    }

    public TestNewsletterIssueForm getTestNewsletterIssueForm() {
        return testNewsletterIssueForm;
    }

    public void setTestNewsletterIssueForm(TestNewsletterIssueForm testNewsletterIssueForm) {
        this.testNewsletterIssueForm = testNewsletterIssueForm;
    }

    public NewsletterService getNewsletterService() {
        return newsletterService;
    }

    public void setNewsletterService(NewsletterService newsletterService) {
        this.newsletterService = newsletterService;
    }
}