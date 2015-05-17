<%@ include file="/html/portlet/sites_admin/site/analytics.portal.jsp" %>

<h3><liferay-ui:message key="verification" /></h3>

<%
String googleVerificationId = PropertiesParamUtil.getString(groupTypeSettings, request, "googleVerificationId");
%>

<aui:input helpMessage="set-the-google-verification-id-that-will-be-used-for-this-set-of-pages" label="google-verification-id" name="TypeSettingsProperties--googleVerificationId--" size="30" type="text" value="<%= googleVerificationId %>" />
