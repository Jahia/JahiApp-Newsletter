package org.jahia.modules.newsletter.sitesettings.form;

import org.springframework.web.multipart.MultipartFile;

import java.io.Serializable;

/**
 * Created with IntelliJ IDEA.
 * User: kevan
 * Date: 21/11/13
 * Time: 17:54
 * To change this template use File | Settings | File Templates.
 */
public class CSVFileForm implements Serializable{
    private static final long serialVersionUID = -8157399476713576533L;
    private String csvSeparator;
    private MultipartFile csvFile;

    public String getCsvSeparator() {
        return csvSeparator;
    }

    public void setCsvSeparator(String csvSeparator) {
        this.csvSeparator = csvSeparator;
    }

    public MultipartFile getCsvFile() {
        return csvFile;
    }

    public void setCsvFile(MultipartFile csvFile) {
        this.csvFile = csvFile;
    }
}
