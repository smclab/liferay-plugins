<%--
/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */
--%>
<%@ include file="/init.jsp" %>

<div id="<portlet:namespace />privacy-policy">
	<c:if test="<%= Validator.isNotNull(privacyPolicyArticleId) %>">
		<liferay-ui:journal-article
			articleId="<%= privacyPolicyArticleId %>"
			groupId="<%= groupId %>"
		/>
	</c:if>
</div>