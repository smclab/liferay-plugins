<%--
/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */
--%>

<%@ include file="/init.jsp" %>

<%
int month = ParamUtil.getInteger(request, "month");
int day = ParamUtil.getInteger(request, "day");
int year = ParamUtil.getInteger(request, "year");
String headerPattern = ParamUtil.getString(request, "headerPattern");
Format headerFormat = (Format) request.getAttribute("headerFormat");
String dataValue = ParamUtil.getString(request, "data", StringPool.BLANK);
boolean showAllPotentialWeeks = GetterUtil.getBoolean((String) request.getAttribute("showAllPotentialWeeks"));

List<Integer> data = new ArrayList<Integer>();
for (String dataValueBit : dataValue.split(StringPool.COMMA)) {
	if (Validator.isNull(dataValueBit)) {
		continue;
	}
	data.add(Integer.valueOf(dataValueBit));
}

java.util.Calendar selectedCal = CalendarFactoryUtil.getCalendar(timeZone, locale);

selectedCal.set(java.util.Calendar.MONTH, month);
selectedCal.set(java.util.Calendar.DATE, day);
selectedCal.set(java.util.Calendar.YEAR, year);

int selectedMonth = selectedCal.get(java.util.Calendar.MONTH);
int selectedDay = selectedCal.get(java.util.Calendar.DATE);
int selectedYear = selectedCal.get(java.util.Calendar.YEAR);

int maxDayOfMonth = selectedCal.getActualMaximum(java.util.Calendar.DATE);

selectedCal.set(java.util.Calendar.DATE, 1);
int dayOfWeek = selectedCal.get(java.util.Calendar.DAY_OF_WEEK);
selectedCal.set(java.util.Calendar.DATE, selectedDay);

java.util.Calendar prevCal = (java.util.Calendar) selectedCal.clone();

prevCal.add(java.util.Calendar.MONTH, -1);

int maxDayOfPrevMonth = prevCal.getActualMaximum(java.util.Calendar.DATE);
int weekNumber = 1;

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

Format monthDateFormat = FastDateFormatFactoryUtil.getSimpleDateFormat("MMMM yyyy", locale);
%>

<div class="taglib-calendar">

	<c:if test="<%= Validator.isNotNull(headerPattern) || Validator.isNotNull(headerFormat) %>">

		<%
		Format dateFormat = headerFormat;

			if (Validator.isNotNull(headerPattern)) {
				dateFormat = FastDateFormatFactoryUtil.getSimpleDateFormat(headerPattern, locale);
			}

			if (Validator.isNull(dateFormat)) {
				dateFormat = FastDateFormatFactoryUtil.getDate(locale);
			}
		%>

		<ul class="inline calendar-header">
			<li>
				<%= dateFormat.format(selectedCal.getTime()) %>
			</li>
		</ul>

	</c:if>

	<ul class="inline portlet-section-header results-header">

		<%
		for (int i = 0; i < 7; i++) {
			int daysIndex = (selectedCal.getFirstDayOfWeek() + i - 1) % 7;

			String className = StringPool.BLANK;

			if (i == 0) {
				className = "first";
			}
			else if (i == 6) {
				className = "last";
			}
		%>

		<li class="<%= className %>" colspan="7">
			<%= LanguageUtil.get(pageContext,CalendarUtil.DAYS_ABBREVIATION[daysIndex]) %>
		</li>

		<%
		}
		%>

	</ul>
	<ul class="inline">

		<%
		if (selectedCal.getFirstDayOfWeek() == java.util.Calendar.MONDAY) {
			if (dayOfWeek == 1) {
				dayOfWeek += 6;
			}
			else {
				dayOfWeek--;
			}
		}

		maxDayOfPrevMonth = (maxDayOfPrevMonth - dayOfWeek) + 1;

		for (int i = 1; i < dayOfWeek; i++) {
			String className = "calendar-inactive calendar-previous-month";

			if (i == 1) {
				className += " first";
			}
			else if (i == 7) {
				className += " last";
			}
		%>

		<li class="<%= className %>"><%= maxDayOfPrevMonth + i %></li>

		<%
		}

		for (int i = 1; i <= maxDayOfMonth; i++) {
			if (dayOfWeek > 7) {
		%>

				</ul>
				<ul class="inline">

		<%
					dayOfWeek = 1;
					weekNumber++;
			}

			java.util.Calendar tempCal = (java.util.Calendar) selectedCal.clone();

			tempCal.set(java.util.Calendar.MONTH, selectedMonth);
			tempCal.set(java.util.Calendar.DATE, i);
			tempCal.set(java.util.Calendar.YEAR, selectedYear);

			boolean hasData = (data != null) && data.contains(new Integer(i));

			StringBundler sb = new StringBundler(namespace);

			sb.append("-calendar-day calendar-day ");

			if ((selectedMonth == curMonth) && (i == curDay) && (selectedYear == curYear)) {

				sb.append("calendar-current-day portlet-section-selected");
			}

			if (hasData) {
				sb.append(" has-events");
			}

			if (dayOfWeek == 1) {
				sb.append(" first");
			}
			else if (dayOfWeek == 7) {
				sb.append(" last");
			}

			dayOfWeek++;

			long startTimeDay = new GregorianCalendar(selectedYear, selectedMonth, i, 0, 0, 0).getTimeInMillis();

			long endTimeDay = new GregorianCalendar(selectedYear, selectedMonth, i, 23, 59, 59).getTimeInMillis();

			List<CalendarBooking> calendarBookingsOfDay =
				CalendarBookingServiceUtil.search(
					company.getCompanyId(), null, calendarIds, null,
					-1, null, (startTimeDay-gmtOffset), (endTimeDay-gmtOffset), true,
					new int[] { WorkflowConstants.STATUS_APPROVED, WorkflowConstants.STATUS_PENDING },
					QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);

			int totalCalendarBookingOfDay = calendarBookingsOfDay.size();

			for (CalendarBooking calendarBooking : calendarBookingsOfDay) {
				String colorEvent = Integer.toHexString(CalendarLocalServiceUtil.getCalendar(calendarBooking.getCalendarId()).getColor());
				String titleEvent = StringPool.SPACE + calendarBooking.getTitle(locale) + StringPool.SPACE;
			}

			if ((totalCalendarBookingOfDay > 0) && (calendarIds.length > 0)) {
				sb.append(" calendar-daylist");
			}
		%>

					<li class="<%= sb.toString() %>" data-target="#data-daylist-<%= i %>" data-value="<%= i %>">

			<%
			if ((totalCalendarBookingOfDay > 0) && (calendarIds.length > 0)) {
			%>

						<strong>

			<%
			}
			%>

							<span><%= i %></span>

			<%
			if ((totalCalendarBookingOfDay > 0) && (calendarIds.length > 0)) {
			%>

						</strong>

						<div class="data-calendar-daylist" id="data-daylist-<%= i %>">

							<div class="title-datalist-event-tooltip">
								<%= i %> <%= monthDateFormat.format(selCal) %>
							</div>
							<div class="datalist-event-tooltip">

				<%
				for (CalendarBooking calendarBooking : calendarBookingsOfDay) {
					String colorEvent = Integer.toHexString(CalendarLocalServiceUtil.getCalendar(calendarBooking.getCalendarId()).getColor());
					String titleEvent = StringPool.SPACE + calendarBooking.getTitle(locale) + StringPool.SPACE;
				%>

								<div class="markerEvent" style="background-color:#<%= colorEvent %>;"></div>
								<p class="datalist-singleevent-tooltip ">
									<%= titleEvent %>
								</p>

				<%
				}
				%>

							</div>
						</div>

			<%
			}
			%>

					</li>

		<%
		}

		int dayOfNextMonth = 1;

		for (int i = 7; i >= dayOfWeek; i--) {
			String className = "calendar-inactive calendar-next-month";

			if (dayOfWeek == 1) {
				className += " first";
			}
			else if (i == dayOfWeek) {
				className += " last";
			}
		%>

					<li class="<%= className %>"><%= dayOfNextMonth++ %></li>

		<%
		}

		if (showAllPotentialWeeks && (weekNumber < 6)) {
		%>

					<ul class="inline">

						<%
						for (int i = 1; i <= 7; i++) {
							String className = "calendar-inactive calendar-next-month";

							if (i == 1) {
								className += " first";
							}
							else if (i == 7) {
								className += " last";
							}
						%>

						<li class="<%= className %>"><%= dayOfNextMonth++ %></li>

						<%
						}
						%>

					</ul>

		<%
		}
		%>

	</ul>
</div>