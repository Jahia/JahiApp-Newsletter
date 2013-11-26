package org.jahia.modules.newsletter.sitesettings.form;

import java.io.Serializable;

/**
 * Created with IntelliJ IDEA.
 * User: kevan
 * Date: 18/11/13
 * Time: 09:39
 * To change this template use File | Settings | File Templates.
 */
public class TestNewsletterIssueForm implements Serializable{

    private static final long serialVersionUID = -372924372635884450L;
    private String issueUUID;
    private String testmail;
    private String user;
    private String locale;

    public TestNewsletterIssueForm(String issueUUID) {
        this.issueUUID = issueUUID;
    }

    public String getIssueUUID() {
        return issueUUID;
    }

    public void setIssueUUID(String issueUUID) {
        this.issueUUID = issueUUID;
    }

    public String getTestmail() {
        return testmail;
    }

    public void setTestmail(String testmail) {
        this.testmail = testmail;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public String getLocale() {
        return locale;
    }

    public void setLocale(String locale) {
        this.locale = locale;
    }
}
