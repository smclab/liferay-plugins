<%--
/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */
--%>

<%@ page import="com.liferay.calendar.model.Calendar" %><%@
page import="com.liferay.calendar.model.CalendarBooking" %><%@
page import="com.liferay.calendar.model.CalendarResource" %><%@
page import="com.liferay.calendar.service.CalendarLocalServiceUtil" %>

<%@ page
	import="com.liferay.calendar.service.CalendarBookingServiceUtil" %><%@
page
	import="com.liferay.calendar.service.CalendarResourceLocalServiceUtil" %><%@
page
	import="com.liferay.calendar.service.persistence.CalendarBookingFinderUtil" %>

<%@ page import="com.liferay.portal.kernel.dao.orm.QueryUtil" %><%@
page import="com.liferay.portal.kernel.language.LanguageUtil" %><%@
page import="com.liferay.portal.kernel.log.Log" %><%@
page import="com.liferay.portal.kernel.log.LogFactoryUtil" %><%@
page import="com.liferay.portal.kernel.search.Document" %><%@
page import="com.liferay.portal.kernel.template.TemplateHandler" %><%@
page
	import="com.liferay.portal.kernel.template.TemplateHandlerRegistryUtil" %>

<%@ page import="com.liferay.portal.kernel.util.CalendarUtil" %><%@
page import="com.liferay.portal.kernel.util.CalendarFactoryUtil" %><%@
page import="com.liferay.portal.kernel.util.Constants" %><%@
page import="com.liferay.portal.kernel.util.DateUtil" %><%@
page
	import="com.liferay.portal.kernel.util.FastDateFormatFactoryUtil" %><%@
page import="com.liferay.portal.kernel.util.GetterUtil" %><%@
page import="com.liferay.portal.kernel.util.KeyValuePair" %><%@
page import="com.liferay.portal.kernel.util.KeyValuePairComparator" %><%@
page import="com.liferay.portal.kernel.util.ListUtil" %><%@
page import="com.liferay.portal.kernel.util.HtmlUtil" %><%@
page import="com.liferay.portal.kernel.util.JavaConstants" %><%@
page import="com.liferay.portal.kernel.util.ParamUtil" %><%@
page import="com.liferay.portal.kernel.util.SetUtil" %><%@
page import="com.liferay.portal.kernel.util.StringBundler" %><%@
page import="com.liferay.portal.kernel.util.StringPool" %><%@
page import="com.liferay.portal.kernel.util.StringUtil" %><%@
page import="com.liferay.portal.kernel.util.Validator" %><%@
page import="com.liferay.portal.kernel.workflow.WorkflowConstants" %>

<%@ page import="com.liferay.portal.model.Organization" %><%@
page import="com.liferay.portal.model.Group" %><%@
page import="com.liferay.portal.model.User" %>

<%@ page import="com.liferay.portal.service.GroupLocalServiceUtil" %><%@
page
	import="com.liferay.portal.service.OrganizationLocalServiceUtil" %><%@
page import="com.liferay.portal.service.UserLocalServiceUtil" %>

<%@ page import="com.liferay.portal.theme.ThemeDisplay" %><%@
page import="com.liferay.portal.util.PortalUtil" %><%@
page import="com.liferay.portlet.PortletPreferencesFactoryUtil" %>

<%@ page import="javax.portlet.PortletResponse" %><%@
page import="javax.portlet.PortletPreferences" %>

<%@ page import="java.text.Format" %><%@
page import="java.text.DateFormat" %><%@
page import="java.text.SimpleDateFormat" %>

<%@ page import="java.util.ArrayList" %><%@
page import="java.util.Arrays" %><%@
page import="java.util.Collection" %><%@
page import="java.util.Date" %><%@
page import="java.util.GregorianCalendar" %><%@
page import="java.util.HashMap" %><%@
page import="java.util.Iterator" %><%@
page import="java.util.LinkedHashMap" %><%@
page import="java.util.List" %><%@
page import="java.util.Map" %><%@
page import="java.util.Set" %><%@
page import="java.util.TimeZone"%>

<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %>
<%@ taglib uri="http://liferay.com/tld/security"
	prefix="liferay-security" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@ taglib uri="http://liferay.com/tld/util" prefix="liferay-util" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>

<portlet:defineObjects />

<liferay-theme:defineObjects />

<%

// Variables

String currentURL = PortalUtil.getCurrentURL(request);

PortletResponse portletResponse = (PortletResponse) request.getAttribute(JavaConstants.JAVAX_PORTLET_RESPONSE);

PortletPreferences prefs = renderRequest.getPreferences();

String portletResource = ParamUtil.getString(request,"portletResource");

if (Validator.isNotNull(portletResource)) {
	prefs = PortletPreferencesFactoryUtil.getPortletSetup(request,portletResource);
}

int pageDelta = GetterUtil.getInteger(prefs.getValue("pageDelta", StringPool.BLANK), -1);

String allEventsUrl = prefs.getValue("all-events-url",StringPool.BLANK);

String calendarIdValues = prefs.getValue("calendarIdValues",StringPool.BLANK);
long[] calendarIds = StringUtil.split(calendarIdValues, 0L);

boolean allCalendars = GetterUtil.getBoolean(prefs.getValue("allCalendars", StringPool.BLANK));

// Genarate List of calendars

long classPK = scopeGroupId;
long classNameId = PortalUtil.getClassNameId(Group.class);

if (themeDisplay.getScopeGroup().getClassNameId() == PortalUtil.getClassNameId(User.class)) {
	classNameId = PortalUtil.getClassNameId(User.class);
	classPK = themeDisplay.getLayout().getUserId();
}

CalendarResource calendarResource = CalendarResourceLocalServiceUtil.fetchCalendarResource(classNameId, classPK);

//long[] calendarResourceIds = new long[] { calendarResource.getCalendarResourceId() };

List<Calendar> calendars = calendarResource.getCalendars();

// Today

java.util.Calendar curCal = CalendarFactoryUtil.getCalendar(timeZone, locale);

int curDay = curCal.get(java.util.Calendar.DAY_OF_MONTH);
int curMonth = curCal.get(java.util.Calendar.MONTH);
int curYear = curCal.get(java.util.Calendar.YEAR);

int selDay = ParamUtil.getInteger(request, "day", curDay);
int selMonth = ParamUtil.getInteger(request, "month", curMonth);
int selYear = ParamUtil.getInteger(request, "year", curYear);

java.util.Calendar selCal = CalendarFactoryUtil.getCalendar(timeZone, locale);
selCal.set(java.util.Calendar.YEAR, selYear);
selCal.set(java.util.Calendar.MONTH, selMonth);
selCal.set(java.util.Calendar.DATE, selDay);

String namespace = portletResponse.getNamespace();

String eventType = ParamUtil.getString(request, "eventType");

Format dateFormatDate = FastDateFormatFactoryUtil.getDate(locale);

List<Long> groupIds = new ArrayList<Long>();
groupIds.add(scopeGroupId);

Group group = GroupLocalServiceUtil.getGroup(themeDisplay.getScopeGroupId());

if (group.isStagingGroup()) {
	group = group.getLiveGroup();
}

User owner = null;

if (group.isUser()) {
	owner = UserLocalServiceUtil.getUserById(group.getClassPK());

	for (long groupId : user.getGroupIds()) {
		groupIds.add(groupId);
	}

	List<Organization> organizations = OrganizationLocalServiceUtil.getUserOrganizations(user.getUserId());

	for (Organization organization : organizations) {
		groupIds.add(organization.getGroup().getGroupId());
	}
}

//adjust selection start and end to  locale
int gmtOffset = user.getTimeZone().getRawOffset(); //locale
gmtOffset += user.getTimeZone().getDSTSavings(); //DST

String redirect = ParamUtil.getString(request, "redirect");
%>

<%!
private static Log _log = LogFactoryUtil.getLog("it.smc.portlet.calendarevents.view-jsp");
%>