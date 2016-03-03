<%--
/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */
--%>

<%@ include file="/init.jsp" %>

<%

String pageNumberSent = request.getParameter("pageNumber");
String dayBreakSent = request.getParameter("dayBreak");

String todayStartSent= request.getParameter("todayStart");
boolean todayStart = true;

if (Validator.isNotNull(todayStartSent)) {
	todayStart = Boolean.valueOf(todayStartSent);
}

int dayBreak = 0;
int dayBreakFinal = 0;
int pageNumber = 1;
if (pageNumberSent != null) {
	pageNumber = Integer.valueOf(pageNumberSent);
}
if (dayBreakSent != null) {
	dayBreakFinal = Integer.valueOf(dayBreakSent);
}

String backURL = request.getParameter("backURL");
int originalPageDelta = pageDelta;
pageDelta = pageDelta * pageNumber;

Format monthDateFormat = FastDateFormatFactoryUtil.getSimpleDateFormat("MMMM yyyy", locale);

int calendarDate = java.util.Calendar.DATE;
int calendarMonth = java.util.Calendar.MONTH;
int calendarYear = java.util.Calendar.YEAR;
int maxDayOfMonth = selCal.getActualMaximum(calendarDate);

java.util.Calendar prevCal = (java.util.Calendar) selCal.clone();
prevCal.add(calendarMonth, -1);

java.util.Calendar nextCal = (java.util.Calendar) selCal.clone();
nextCal.add(calendarMonth, +1);

if (!allCalendars) {
	calendars = new ArrayList<Calendar>();
	for (int i = 0; i < calendarIds.length; i++) {
		calendars.add(CalendarLocalServiceUtil.getCalendar(calendarIds[i]));
	}
}
else {
	calendarIds = new long[calendars.size()];
	for (int i = 0; i < calendars.size(); i++) {
		Calendar calendar = calendars.get(i);
		calendarIds[i] = calendar.getCalendarId();
	}
}

int dayInMonthWithEvents = 0;
int startDayInMonth = 1;

if ((selMonth == curMonth) && (pageDelta != -1) && ((pageNumberSent == null) || ((pageNumberSent != null) && todayStart))) {
	startDayInMonth = curDay;
}

long startTimeMonth = new GregorianCalendar(selYear, selMonth, 0, 0, 0, 0).getTimeInMillis();
long startTimeMonthFromStartDay = new GregorianCalendar(selYear, selMonth, startDayInMonth, 0, 0, 0).getTimeInMillis();

long endTimeMonth = new GregorianCalendar(selYear, selMonth, maxDayOfMonth, 23, 59, 59).getTimeInMillis();

List<CalendarBooking> calendarBookingsOfMonth =
	new ArrayList<CalendarBooking>();

List<CalendarBooking> calendarBookingsOfMonthFromStartDay =
	new ArrayList<CalendarBooking>();

if (calendarIds.length > 0) {

		calendarBookingsOfMonth =
			CalendarBookingServiceUtil.search(
				company.getCompanyId(), null, calendarIds, null,
				-1, null, (startTimeMonth-gmtOffset), (endTimeMonth-gmtOffset),
				true, new int[] {WorkflowConstants.STATUS_APPROVED,
				WorkflowConstants.STATUS_PENDING },
				QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);

		calendarBookingsOfMonthFromStartDay =
			CalendarBookingServiceUtil.search(
				company.getCompanyId(), null, calendarIds, null,
				-1, null, (startTimeMonthFromStartDay-gmtOffset),
				(endTimeMonth-gmtOffset), true,
				new int[] {WorkflowConstants.STATUS_APPROVED,
				WorkflowConstants.STATUS_PENDING },
				QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);
	}

int totalCalendarBookingOfMonth = calendarBookingsOfMonth.size();
int totalCalendarBookingOfMonthFromStartDay = calendarBookingsOfMonthFromStartDay.size();

boolean multiPage = false;
if (pageNumber > 1) {
	multiPage = true;
}

StringBundler sb = new StringBundler();
%>

<portlet:renderURL var="prevMonthURL">
	<portlet:param name="day" value="<%= String.valueOf(prevCal.get(calendarDate)) %>" />
	<portlet:param name="month" value="<%= String.valueOf(prevCal.get(calendarMonth)) %>" />
	<portlet:param name="year" value="<%= String.valueOf(prevCal.get(calendarYear)) %>" />
	<portlet:param name="todayStart" value="<%= String.valueOf(todayStart) %>" />
</portlet:renderURL>

<portlet:renderURL var="prevSelfMonthURL">
	<portlet:param name="day" value="<%= String.valueOf(selDay) %>" />
	<portlet:param name="month" value="<%= String.valueOf(selMonth) %>" />
	<portlet:param name="year" value="<%= String.valueOf(selYear) %>" />
	<portlet:param name="pageNumber" value='<%= (pageNumber == 1) ? String.valueOf(1) : String.valueOf(pageNumber -1) %>'/>
	<portlet:param name="backURL" value="<%= currentURL %>" />
	<portlet:param name="dayBreak" value="<%= String.valueOf(dayBreak) %>" />
	<portlet:param name="todayStart" value='<%= ((pageNumber == 1)) ? "false" : String.valueOf(todayStart) %>' />
</portlet:renderURL>

<portlet:renderURL var="nextMonthURL">
	<portlet:param name="day" value="<%= String.valueOf(nextCal.get(calendarDate)) %>" />
	<portlet:param name="month" value="<%= String.valueOf(nextCal.get(calendarMonth)) %>" />
	<portlet:param name="year" value="<%= String.valueOf(nextCal.get(calendarYear)) %>" />
	<portlet:param name="todayStart" value="<%= String.valueOf(todayStart) %>" />
</portlet:renderURL>

<div class="simple-calendar-header">

	<div class="simple-calendar-prev">
		<a href="<%= prevMonthURL.toString() %>">
			<div id="triangle-left"></div>
			<div id="triangle-left"></div>
		</a>
	</div>

	<div class="simple-calendar-month">
		<%= monthDateFormat.format(selCal) %>
	</div>

	<div class="simple-calendar-next">
		<a href="<%= nextMonthURL.toString() %>">
			<div id="triangle-right"></div>
			<div id="triangle-right"></div>
		</a>
	</div>

</div>

<liferay-util:include page="/html/partials/calendar.jsp" servletContext="<%= application %>">
	<liferay-util:param name="day" value="<%= String.valueOf(selDay) %>" />
	<liferay-util:param name="month" value="<%= String.valueOf(selMonth) %>" />
	<liferay-util:param name="year" value="<%= String.valueOf(selYear) %>" />
	<liferay-util:param name="data" value="<%= sb.toString() %>" />
</liferay-util:include>

<c:choose>
	<c:when test="<%= multiPage %>">
		<div class="navButton">
			<a href="<%= backURL %>">
				<div id="triangle1"></div>
			</a>
		</div>
	</c:when>
	<c:otherwise>
		<c:choose>
			<c:when test="<%= (totalCalendarBookingOfMonthFromStartDay >= totalCalendarBookingOfMonth) || ((pageNumber == 1) && (curMonth != selMonth)) %>">
				<div class="navButton">
					<a href="<%= prevMonthURL.toString() %>">
						<div id="triangle1"></div>
					</a>
				</div>
			</c:when>
			<c:otherwise>
				<div class="navButton">
					<a href="<%= prevSelfMonthURL.toString() %>">
						<div id="triangle1"></div>
					</a>
				</div>
			</c:otherwise>
		</c:choose>
	</c:otherwise>
</c:choose>

<c:if test="<%= calendarIds.length > 0 %>">

	<div id="resultCalendarBooking">
		<%
		boolean startCicleEvent = false;

		int bookingNumber = 0;
		boolean stopSearching = false;
		int startDayValue = 1;
		if ((selMonth == curMonth) && (pageDelta != -1) && ((pageNumberSent == null) || ((pageNumberSent != null) && todayStart))) {
			startDayValue = curDay;
		}

		//-------- START CICLE FOR MONTH DAY ----------//
		for (int i = startDayValue; i <= maxDayOfMonth; i++) {

			long startTime = new GregorianCalendar(selYear, selMonth, i, 0, 0, 0).getTimeInMillis();

			long endTime = new GregorianCalendar(selYear, selMonth, i, 23, 59, 59).getTimeInMillis();

			DateFormat format = new SimpleDateFormat("yyyy/MM/dd");
			format.setTimeZone(user.getTimeZone());

			DateFormat formatNameMonth = new SimpleDateFormat("MMM", locale);
			formatNameMonth.setTimeZone(user.getTimeZone());

			DateFormat formatWeekDay = new SimpleDateFormat("EEE", locale);
			formatWeekDay.setTimeZone(user.getTimeZone());

			String dateEventDay = formatWeekDay.format(startTime);
			String dateEventNumber = String.valueOf(i);

			List<CalendarBooking> calendarBookings =
				CalendarBookingServiceUtil.search(
					company.getCompanyId(), null, calendarIds, null,
					-1, null, (startTime-gmtOffset), (endTime-gmtOffset), true,
					new int[] {WorkflowConstants.STATUS_APPROVED,
					WorkflowConstants.STATUS_PENDING },
					QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);

			if ((calendarBookings.size() > 0) && ((pageDelta == -1) || (pageDelta > bookingNumber))) {

				if ((bookingNumber >= (pageDelta - originalPageDelta)) || (i == dayBreakFinal)) {
		%>

					<c:if test="<%= startCicleEvent %>">
						<div class="eventSeparator"></div>
					</c:if>

					<div class="dayOfCalendar">
						<i><%= dateEventDay %></i>
						<h4><%= dateEventNumber %></h4>
					</div>

					<ul class="eventOfCalendar" id="myTooltipDelegate">

		<%
				}

				List<String[]> eventDayList = new ArrayList<String[]>();

				for (CalendarBooking calendarBooking : calendarBookings) {

					if ((pageDelta == -1) || ((pageDelta != -1) && (pageDelta > bookingNumber))) {

						DateFormat formatDateTimeEvent = new SimpleDateFormat(" hh:mm - dd/MM/yyyy");
						formatDateTimeEvent.setTimeZone(user.getTimeZone());

						DateFormat formatSimpleTimeEvent = new SimpleDateFormat(" hh:mm");
						formatSimpleTimeEvent.setTimeZone(user.getTimeZone());

						DateFormat formatSimpleDateEvent = new SimpleDateFormat("dd/MM/yyyy");
						formatSimpleDateEvent.setTimeZone(user.getTimeZone());

						String colorEvent = Integer.toHexString(CalendarLocalServiceUtil.getCalendar(calendarBooking.getCalendarId()).getColor());
						String titleEvent = StringPool.SPACE + calendarBooking.getTitle(locale) + StringPool.SPACE;

						bookingNumber++;

						dayInMonthWithEvents = i + 1;
						startCicleEvent = true;
						if (bookingNumber > (pageDelta - originalPageDelta)) {
		%>

							<li class="trigger" data-target="#data-<%= bookingNumber %>">

								<div class="markerEvent" style="background-color:#<%= colorEvent %>;"></div>
								<p><%= titleEvent %></p>

								<div class="data-martkerEvent" id="data-<%= bookingNumber %>">
									<div class="tooltip-booking" style="background-color:#<%= colorEvent %>;">
										<h4 class="booking-title-tooltip" style="background-color:#<%= colorEvent %>;">
											<%= titleEvent %>
										</h4>

										<dl>
											<dt>
												<%= LanguageUtil.get(pageContext, "from") %> :
											</dt>
											<dd>
												<%= CalendarLocalServiceUtil.getCalendar(calendarBooking.getCalendarId()).getName(locale) %>
											</dd>
											<dt>
												<%= LanguageUtil.get(pageContext, "start") %> :
											</dt>
											<dd>
												<i class="icon-time"></i>
												<%= formatSimpleTimeEvent.format(calendarBooking.getStartTime()) %>
												<br />
												<i class="icon-calendar"></i>
												<%= formatSimpleDateEvent.format(calendarBooking.getStartTime()) %>
											</dd>
											<dt>
												<%= LanguageUtil.get(pageContext, "end") %> :
											</dt>
											<dd>
												<i class="icon-time"></i>
												<%= formatSimpleTimeEvent.format(calendarBooking.getEndTime()) %>
												<br />
												<i class="icon-calendar"></i>
												<%= formatSimpleDateEvent.format(calendarBooking.getEndTime()) %>
											</dd>
											<dt>
												<%= LanguageUtil.get(pageContext, "description") %> :
											</dt>
											<dd>
												<%= calendarBooking.getDescription(locale) %>
											</dd>
										</dl>

									</div>
								</div>
							</li>

		<%
						}
					}
					else {
						stopSearching = true;
						break;
					}
				}

				if (stopSearching) {
					dayBreak = Integer.valueOf(dateEventNumber);
					break;
				}
		%>

			</ul>

		<%
			}
		}
		%>

	</div>
</c:if>

<%
boolean navButtonMore = false;

long startRestTimeMonth = new GregorianCalendar(selYear, selMonth, dayInMonthWithEvents, 0, 0, 0).getTimeInMillis();

long endRestTimeMonth = new GregorianCalendar(selYear, selMonth, maxDayOfMonth, 23, 59, 59).getTimeInMillis();

List<CalendarBooking> calendarBookingsRestInMonth =
	CalendarBookingServiceUtil.search(
		company.getCompanyId(), null, calendarIds, null,
		-1, null, (startRestTimeMonth-gmtOffset), (endRestTimeMonth-gmtOffset),
		true, new int[] { WorkflowConstants.STATUS_APPROVED,
		WorkflowConstants.STATUS_PENDING },
		QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);

int restCalendarBookingOfMonth = calendarBookingsRestInMonth.size();

if (( ((pageDelta != -1) && ((maxDayOfMonth >= dayInMonthWithEvents) && (restCalendarBookingOfMonth > 0))) || ((pageDelta != -1)  && ((totalCalendarBookingOfMonth > (pageNumber * pageDelta)) || ((maxDayOfMonth >= dayInMonthWithEvents) && (restCalendarBookingOfMonth > 0)))))) {
		navButtonMore = true;
}
%>

<c:choose>
	<c:when test="<%= navButtonMore %>">

		<portlet:renderURL var="selfMonthURL">
			<portlet:param name="day" value="<%= String.valueOf(selDay) %>" />
			<portlet:param name="month" value="<%= String.valueOf(selMonth) %>" />
			<portlet:param name="year" value="<%= String.valueOf(selYear) %>" />
			<portlet:param name="pageNumber" value="<%= String.valueOf(pageNumber + 1) %>"/>
			<portlet:param name="backURL" value="<%= currentURL %>" />
			<portlet:param name="dayBreak" value="<%= String.valueOf(dayBreak) %>" />
			<portlet:param name="todayStart" value="<%= String.valueOf(todayStart) %>" />
		</portlet:renderURL>

		<div class="navButton">
			<a href="<%= selfMonthURL.toString() %>">
				<div id="triangle2"></div>
			</a>
		</div>
	</c:when>
	<c:otherwise>
		<div class="navButton">
			<a href="<%= nextMonthURL.toString() %>">
				<div id="triangle2"></div>
			</a>
		</div>
	</c:otherwise>
</c:choose>

<div id="linkSpace">
	<c:if test="<%= Validator.isNotNull(allEventsUrl) %>">
		<p class="goto-events">
			<a href="<%= allEventsUrl %>">
				<liferay-ui:message key="goto-all-events" />
			</a>
		</p>
	</c:if>

	<portlet:renderURL var="todayURL" >
		<portlet:param name="todayStart" value="true" />
	</portlet:renderURL>

	<ul class="inline">
		<li>
			<p class="goto-events">
				<a href="<%= todayURL %>">
					<i class="icon-bookmark"></i>
					<liferay-ui:message key="today" />
				</a>
			</p>
		</li>
		<li>
			<p class="goto-events">
				<a data-target="#show-legend" href="#" id="legend">
					<i class="icon-th-list"></i>
					<liferay-ui:message key="legend" />
				</a>
			</p>
		</li>
	</ul>

	<div id="show-legend">
		<div id="show-legend-tooltip">
			<h4>
				<liferay-ui:message key="calendars" />
				:
			</h4>
			<ul>

				<%
					for (long calendarId : calendarIds) {
						Calendar calendar = CalendarLocalServiceUtil.getCalendar(calendarId);
						String colorEvent = Integer.toHexString(calendar.getColor());
				%>

						<li>
							<div class="markerEvent" style="background-color:#<%= colorEvent %>;"
							>
							</div>
							<p><%= calendar.getName(locale) %></p>
						</li>

				<%
					}
				%>

			</ul>
		</div>
	</div>
</div>

<aui:script>
	AUI().use('aui-tooltip', 'node', function(Y) {
		Y.all('.trigger').each(function(trigger) {
			new Y.Tooltip({
				bodyContent : Y.one(trigger.getAttribute('data-target')),
				trigger : trigger,
				cssClass : 'tooltip-help',
				opacity : 1,
				position : 'top'
			}).render().hide().suggestAlignment(trigger);

		});
	});
</aui:script>

<aui:script>
	AUI().use('aui-tooltip', 'node', function(A) {
		var legend = A.one('#legend');
		new A.Tooltip({
			bodyContent : A.one(legend.getAttribute('data-target')),
			trigger : legend,
			cssClass : 'tooltip-help',
			opacity : 1,
			position : 'top'
		}).render().hide().suggestAlignment(legend);
	});
</aui:script>

<aui:script>
	AUI().use('aui-tooltip', 'node', function(X) {
		X.all('.calendar-daylist').each(function(calendarDaylist) {
			new X.Tooltip({
				bodyContent : X.one(calendarDaylist.getAttribute('data-target')),
				trigger : calendarDaylist,
				cssClass : 'tooltip-help',
				opacity : 1,
				position : 'top'
			}).render().hide().suggestAlignment(calendarDaylist);

		});
	});
</aui:script>