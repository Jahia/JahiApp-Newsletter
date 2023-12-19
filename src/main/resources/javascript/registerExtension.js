//window.jahia.i18n.loadNamespaces('calvados-menu');

window.jahia.uiExtender.registry.add('adminRoute', 'newsletter', {
    targets: ['jcontent:40'],
    icon: window.jahia.moonstone.toIconComponent('MenuIcon'),
    label: 'NewsLetter',
    isSelectable: true,
    requireModuleInstalledOnSite: 'newsletter',
    iframeUrl: window.contextJsParameters.contextPath + '/cms/edit/default/$lang/sites/$site-key.newsletterManager.html?redirect=false&fullscreen'
});
