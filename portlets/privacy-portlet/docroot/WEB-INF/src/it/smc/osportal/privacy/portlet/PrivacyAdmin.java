/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */

package it.smc.osportal.privacy.portlet;

import it.smc.osportal.privacy.util.PortletKeys;

import java.io.IOException;
import java.util.Date;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.PortletPreferences;

import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.service.PortletPreferencesLocalServiceUtil;
import com.liferay.portal.theme.ThemeDisplay;
import com.liferay.util.bridges.mvc.MVCPortlet;

/**
 * @author Rudi Giacomini Pilon
 */
public class PrivacyAdmin extends MVCPortlet {

	public void savePolicyPreferences(
			ActionRequest actionRequest, ActionResponse actionResponse)
		throws IOException, PortletException {

			ThemeDisplay themeDisplay =
				(ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);

			long groupId = themeDisplay.getSiteGroupId();

			String privacyPolicyId =
					ParamUtil.getString(
							actionRequest,"privacy-policy-web-content-id");

			String privacyInfoId =
					ParamUtil.getString(
							actionRequest,"privacy-info-web-content-id");

			String privacyEnabled = ParamUtil.getString(
					actionRequest,"privacy-enabled");

			String cookieExpiration = ParamUtil.getString(
					actionRequest,"cookie-expiration");

			boolean resetPreviousCookies=ParamUtil.getBoolean(
					actionRequest, "reset-previous-cookies");

			try {
				PortletPreferences preferences =
					PortletPreferencesLocalServiceUtil.getPreferences(
						themeDisplay.getCompanyId(),groupId,
						PortletKeys.PREFS_OWNER_TYPE_GROUP, 0,
						PortletKeys.PRIVACY_DISPLAY);

				preferences.setValue("privacyPolicyId", privacyPolicyId);
				preferences.setValue("privacyInfoId", privacyInfoId);
				preferences.setValue("privacyEnabled", privacyEnabled);
				preferences.setValue("cookieExpiration", cookieExpiration);

				if (resetPreviousCookies){
					Date now=new Date();
					long millisec=now.getTime();
					String nameExtend = String.valueOf(millisec);

					preferences.setValue("nameExtend", nameExtend);
				}

				preferences.store();
			}
			catch (SystemException e) {
				e.printStackTrace();
			}
	}

	private static Log _log = LogFactoryUtil.getLog(PrivacyAdmin.class);

}