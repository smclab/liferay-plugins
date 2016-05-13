<%--
/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %><%@
taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %><%@
taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %><%@
taglib uri="http://liferay.com/tld/aui" prefix="aui" %><%@
taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %><%@
taglib uri="http://liferay.com/tld/security" prefix="liferay-security" %><%@
taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %><%@
taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %><%@
taglib uri="http://liferay.com/tld/util" prefix="liferay-util" %>

<%@ page import="com.liferay.portal.kernel.portlet.LiferayWindowState" %><%@
page import="com.liferay.portal.kernel.util.GetterUtil" %><%@
page import="com.liferay.portal.kernel.util.ParamUtil" %><%@
page import="com.liferay.portal.kernel.util.Validator" %><%@
page import="com.liferay.portal.util.PortalUtil" %><%@
page import="com.liferay.portlet.journal.model.JournalArticle" %>

<%@ page import="it.smc.osportal.privacy.util.PrivacyUtil" %><%@
page import="com.liferay.portal.service.PortletPreferencesLocalServiceUtil" %><%@
page import="com.liferay.portal.kernel.util.StringPool" %><%@
page import="com.liferay.portlet.PortletPreferencesFactoryUtil" %><%@
page import="com.liferay.portal.kernel.util.Validator" %><%@
page import="com.liferay.portal.kernel.util.ParamUtil" %><%@
page import="javax.portlet.PortletPreferences" %>

<%@page import="it.smc.osportal.privacy.util.PortletKeys"%>
<%@ page import="com.liferay.portal.service.CompanyLocalServiceUtil" %>
<%@ page import="java.util.Calendar" %>

<%@ page import="javax.portlet.WindowState" %>

<portlet:defineObjects />

<liferay-theme:defineObjects />

<%
WindowState windowState = renderRequest.getWindowState();
String currentURL = PortalUtil.getCurrentURL(request);
String redirect = ParamUtil.getString(request, "redirect", currentURL);

// long groupId = themeDisplay.getScopeGroupId();

long groupId = themeDisplay.getSiteGroupId();

PortletPreferences preferences =
	PortletPreferencesLocalServiceUtil.getPreferences(
		themeDisplay.getCompanyId(),groupId,
		PortletKeys.PREFS_OWNER_TYPE_GROUP, 0,
		PortletKeys.PRIVACY_DISPLAY);

boolean privacyEnabled = false;
if (Validator.isNotNull(preferences.getValue("privacyEnabled", StringPool.BLANK))) {
	privacyEnabled=GetterUtil.getBoolean(
			preferences.getValue("privacyEnabled", StringPool.BLANK));
}


//get privacy settings from theme

//get privacy settings from portlet preferences:
String privacyInfoMessageArticleId=
			preferences.getValue("privacyInfoId", StringPool.BLANK);

String privacyPolicyArticleId =
			preferences.getValue("privacyPolicyId", StringPool.BLANK);

int cookieExpiration = GetterUtil.getInteger(
			preferences.getValue("cookieExpiration", StringPool.BLANK),30);

String nameExtend = preferences.getValue("nameExtend", StringPool.BLANK);
nameExtend= String.valueOf(groupId)+nameExtend;

JournalArticle privacyPolicy =
	PrivacyUtil.getPrivacyPolicy(groupId, privacyPolicyArticleId);

boolean privacyInfoMessage = PrivacyUtil.showPrivacyInfoMessage(
	themeDisplay.isSignedIn(), privacyEnabled, privacyPolicy, request,
	groupId, locale,nameExtend);
%>