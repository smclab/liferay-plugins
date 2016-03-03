<%--
/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */
--%>

<%@ include file="/init.jsp" %>

<liferay-portlet:actionURL portletConfiguration="true" var="configurationActionURL" />

<%

// If not all calendars are selected remove from avaiable selected calendars
// else reinizialize with a empty array the list of selected

if (!allCalendars) {
	for (int i = 0; i < calendarIds.length; i++) {
		if (calendars.contains(
			CalendarLocalServiceUtil.getCalendar(calendarIds[i]))) {

			calendars.remove(CalendarLocalServiceUtil.getCalendar(calendarIds[i]));
		}
	}
}
else {
	calendarIds = new long[calendars.size()];
}

long[] availableCalendarIds = new long[calendars.size()];

// Generate an array of Calendar Id
for (int i = 0; i < calendars.size(); i++) {
	Calendar calendar = calendars.get(i);
	availableCalendarIds[i] = calendar.getCalendarId();
}

String displayStyle =
	portletPreferences.getValue("displayStyle",StringPool.BLANK);
long displayStyleGroupId =
	GetterUtil.getLong(
		portletPreferences.getValue("displayStyleGroupId", null),
		themeDisplay.getScopeGroupId());
%>

<liferay-portlet:actionURL portletConfiguration="true" var="configurationURL" />

<aui:form action="<%= configurationActionURL %>" method="post" name="fm" onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "saveConfiguration();" %>'>
	<aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>" />
	<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
	<aui:select label="limit-items" name="pageDelta">
		<aui:option label="no-limit" selected="<%= (pageDelta == -1) %>" value="-1" />
		<aui:option selected="<%= (pageDelta == 5) %>" value="5">5</aui:option>
		<aui:option selected="<%= (pageDelta == 10) %>" value="10">10</aui:option>
		<aui:option selected="<%= (pageDelta == 15) %>" value="15">15</aui:option>
		<aui:option selected="<%= (pageDelta == 20) %>" value="20">20</aui:option>
		<aui:option selected="<%= (pageDelta == 25) %>" value="25">25</aui:option>
	</aui:select>

	<br />

	<aui:input label="all-events-url" name="allEventsUrl" value="<%= allEventsUrl %>" />

	<aui:fieldset>
		<aui:select label="calendars" name="allCalendars">
			<aui:option label="all" selected="<%= allCalendars %>" value="<%= true %>" />
			<aui:option label="filter[action]" selected="<%= !allCalendars %>" value="<%= false %>" />
		</aui:select>

		<aui:input name="calendarIds" type="hidden" />

		<%
		Set<Long> availableCalendarIdsSet = SetUtil.fromArray(availableCalendarIds);

		// Left list

		List<KeyValuePair> typesLeftList = new ArrayList<KeyValuePair>();

		for (long calendarId : calendarIds) {
			try {
				Calendar calendar = CalendarLocalServiceUtil.getCalendar(calendarId);

				calendar = calendar.toEscapedModel();

				typesLeftList.add(new KeyValuePair(String.valueOf(calendarId), calendar.getName(locale)));
			}
			catch (Exception e) {
			}
		}

		// Right list

		List<KeyValuePair> typesRightList = new ArrayList<KeyValuePair>();

		for (long calendarId : availableCalendarIdsSet) {
			if (Arrays.binarySearch(calendarIds, calendarId) < 0) {
				Calendar calendar = CalendarLocalServiceUtil.getCalendar(calendarId);

				calendar = calendar.toEscapedModel();

				typesRightList.add(new KeyValuePair(String.valueOf(calendarId), calendar.getName(locale)));
			}
		}
		%>

		<div class="<%= allCalendars ? "hide" : "" %>" id="<portlet:namespace />CalendarsBoxes">

			<liferay-ui:input-move-boxes
				leftBoxName="currentCalendarIds"
				leftList="<%= typesLeftList %>"
				leftReorder="true"
				leftTitle="current"
				rightBoxName="availableCalendarIds"
				rightList="<%= typesRightList %>"
				rightTitle="available"
			/>

		</div>

		<div class="display-template">

			<%
				/*TemplateHandler templateHandler =
					TemplateHandlerRegistryUtil.getTemplateHandler(
											Category.class.getName());
			*/ %>

		</div>
	</aui:fieldset>

	<aui:button-row>
		<aui:button type="submit" />
	</aui:button-row>
</aui:form>

<aui:script>
	Liferay.provide(
		window,
		'<portlet:namespace />saveConfiguration',
		function() {
			var A = AUI();

			var calendarIds = A.one('#<portlet:namespace />calendarIds');
			var currentCalendarIds = A.one('#<portlet:namespace />currentCalendarIds');

			if (calendarIds && currentCalendarIds) {
				calendarIds.val(Liferay.Util.listSelect(currentCalendarIds));
			}

			submitForm(document.<portlet:namespace />fm);
		},
		['liferay-util-list-fields', 'aui-base']
	);

	Liferay.Util.toggleSelectBox('<portlet:namespace />allCalendars', 'false', '<portlet:namespace />CalendarsBoxes');
</aui:script>