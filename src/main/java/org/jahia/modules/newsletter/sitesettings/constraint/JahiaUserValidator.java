package org.jahia.modules.newsletter.sitesettings.constraint;

import org.apache.commons.lang.StringUtils;
import org.jahia.taglibs.user.User;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

/**
 * Created by kevan on 18/03/14.
 */
public class JahiaUserValidator implements ConstraintValidator<JahiaUser, String> {

    @Override
    public void initialize(JahiaUser jahiaUser) {
        //
    }

    @Override
    public boolean isValid(String s, ConstraintValidatorContext constraintValidatorContext) {

        return StringUtils.isEmpty(s) || User.lookupUser(s) != null;
    }
}
