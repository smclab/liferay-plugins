/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */

package it.smc.portlet.calendarevents.action;

import com.liferay.portal.kernel.portlet.DefaultConfigurationAction;
import com.liferay.portal.kernel.portlet.LiferayPortletConfig;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portlet.PortletPreferencesFactoryUtil;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletConfig;
import javax.portlet.PortletPreferences;

/**
 * @author Erika Bardellotto
 */
public class ConfigurationActionImpl extends DefaultConfigurationAction {

	@Override
	public void processAction(
			PortletConfig portletConfig, ActionRequest actionRequest,
			ActionResponse actionResponse)
		throws Exception {

		String cmd = ParamUtil.getString(actionRequest, Constants.CMD);

		if (!cmd.equals(Constants.UPDATE)) {
			return;
		}

		String allEventsUrl = ParamUtil.getString(
			actionRequest, "allEventsUrl");
		int pageDelta = ParamUtil.getInteger(actionRequest, "pageDelta");
		String calendarIdValues = ParamUtil.getString(
			actionRequest, "calendarIds");
		boolean calendarAll = ParamUtil.getBoolean(
			actionRequest, "allCalendars");

		String portletResource = ParamUtil.getString(
			actionRequest, "portletResource");

		PortletPreferences preferences =
			PortletPreferencesFactoryUtil.getPortletSetup(
				actionRequest, portletResource);

		preferences.setValue("all-events-url", allEventsUrl);
		preferences.setValue("pageDelta", String.valueOf(pageDelta));
		preferences.setValue("calendarIdValues", calendarIdValues);
		preferences.setValue("allCalendars", String.valueOf(calendarAll));

		if (SessionErrors.isEmpty(actionRequest)) {
			preferences.store();

			LiferayPortletConfig liferayPortletConfig =
				(LiferayPortletConfig)portletConfig;

			SessionMessages.add(
				actionRequest,
				liferayPortletConfig.getPortletId() +
					SessionMessages.KEY_SUFFIX_REFRESH_PORTLET,
				portletResource);

			SessionMessages.add(
				actionRequest,
				liferayPortletConfig.getPortletId() +
					SessionMessages.KEY_SUFFIX_UPDATED_CONFIGURATION);
		}
	}

}