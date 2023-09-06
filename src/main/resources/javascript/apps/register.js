// Declare the namespace to find the translations for my module, put the name of your module and reuse it in your labels
window.jahia.i18n.loadNamespaces('newsletter');

window.jahia.uiExtender.registry.add('adminRoute', 'newsletter', {
    targets: ['administration-sites:90'],
    label: 'newsletter:label.title',
    icon: window.jahia.moonstone.toIconComponent('/modules/newsletter/icons/jnt_newsletter.png'),
    isSelectable: true,
    requiredPermission: 'siteAdminNewsletter',
    requireModuleInstalledOnSite: 'newsletter',
    iframeUrl: window.contextJsParameters.contextPath + '/cms/editframe/default/$lang/sites/$site-key.newsletterManager.html'
});
