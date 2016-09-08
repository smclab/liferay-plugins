<%--
/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */
--%>

<%@ include file="/init.jsp" %>

<c:if test="<%= privacyInfoMessage %>">

	<div class="privacy-info-message" id="<portlet:namespace />privacy-info-message">
		<c:if test="<%= Validator.isNotNull(privacyInfoMessageArticleId) %>">
			<aui:layout>
				<aui:column columnWidth="100" first="true" last="true">
						<liferay-ui:journal-article
							articleId="<%= privacyInfoMessageArticleId %>"
							groupId="<%= groupId %>"
							showTitle="false"
						/>

						<liferay-portlet:renderURL var="viewPrivacyPolicyURL" windowState="<%= LiferayWindowState.MAXIMIZED.toString() %>">
						    <portlet:param name="jspPage" value="/display/view_privacy_policy.jsp" />
						</liferay-portlet:renderURL>

						<liferay-portlet:renderURL var="viewPrivacyPolicyPopUpURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
						    <portlet:param name="jspPage" value="/display/view_privacy_policy.jsp" />
						</liferay-portlet:renderURL>

						<a
						    class="btn"
						    data-href="<%= HtmlUtil.escapeAttribute(viewPrivacyPolicyPopUpURL) %>"
						    href="<%= HtmlUtil.escapeAttribute(viewPrivacyPolicyURL) %>"
						    id="<portlet:namespace />readMore"
						    title="<%= HtmlUtil.escapeAttribute(privacyPolicy.getTitle(locale)) %>"
						>
						    <liferay-ui:message key="read-more" />
						</a>
						<aui:button cssClass="btn btn-primary" name="okButton" value="ok" />

				</aui:column>
			</aui:layout>
		</c:if>
	</div>

	<liferay-portlet:renderURL var="viewPrivacyPolicyURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
		<portlet:param name="jspPage" value="/display/view_privacy_policy.jsp" />
	</liferay-portlet:renderURL>

	<aui:script use="aui-base,aui-io-deprecated,cookie,liferay-util-window">
		var okButton = A.one('#<portlet:namespace />okButton');
		var readMore = A.one('#<portlet:namespace />readMore');

		okButton.on('click', function(e) {

			hidePrivacyMessage();

			e.halt();
		});

		readMore.on(
			'click',
			function(event) {
				if (!event.metaKey && !event.ctrlKey) {
					Liferay.Util.openInDialog(event);
				}
			}
		);

		var wrapper = A.one('#wrapper');

		var privacyInfoMessage = A.one('.smc-privacy-portlet .privacy-info-message');

		if (privacyInfoMessage) {
			wrapper.addClass('wrapper-for-privacy-portlet');

			var hideStripPrivacyInfoMessage = privacyInfoMessage.one('.hide-strip-privacy-info-message');

			var hidePrivacyMessage = function() {

				privacyInfoMessage.ancestor('.smc-privacy-portlet').hide();
					// renewal
					var today = new Date();
					var expire = new Date();
					var nDays=<%= cookieExpiration %>;
					expire.setTime(today.getTime() + 3600000*24*nDays);
					var expString="expires="+expire.toGMTString();
					cookieName = "<%= PrivacyUtil.PRIVACY_READ %><%=nameExtend %>";
					cookieValue =today.getTime();
					document.cookie = cookieName+"="+escape(cookieValue)+ ";expires="+expire.toGMTString();

				wrapper.removeClass('wrapper-for-privacy-portlet');
			}

			if (hideStripPrivacyInfoMessage) {

				hideStripPrivacyInfoMessage.on('click', hidePrivacyMessage);
			}

		}
	</aui:script>

</c:if>