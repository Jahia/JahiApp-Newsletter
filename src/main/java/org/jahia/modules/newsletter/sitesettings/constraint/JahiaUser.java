package org.jahia.modules.newsletter.sitesettings.constraint;

import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Created by kevan on 18/03/14.
 */
@Target({ElementType.METHOD, ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy=JahiaUserValidator.class)
public @interface JahiaUser {
    String message() default "{newsletter.user.constraint}";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
