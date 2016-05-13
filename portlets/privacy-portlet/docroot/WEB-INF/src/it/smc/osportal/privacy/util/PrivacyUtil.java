/**
 * Copyright (c) SMC Treviso Srl. All rights reserved.
 */

package it.smc.osportal.privacy.util;

import java.util.Locale;

import javax.servlet.http.HttpServletRequest;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.CookieKeys;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portlet.journal.model.JournalArticle;
import com.liferay.portlet.journal.service.JournalArticleLocalServiceUtil;

/**
 * @author Andrea Carra'
 * @author Rudi Giacomini Pilon
 */
public class PrivacyUtil {

	public  static final String PRIVACY_READ = "PRIVACY_READ";

	public static JournalArticle getPrivacyPolicy(
		long groupId, String privacyPolicyArticleId) {

		if (Validator.isNull(privacyPolicyArticleId) ||
			Validator.isNull(groupId)) {

			return null;
		}

		try {
			return JournalArticleLocalServiceUtil.getArticle(
				groupId, privacyPolicyArticleId);
		}
		catch (Exception e) {
			_log.error(e, e);
		}

		return null;
	}

	public static boolean showPrivacyInfoMessage(
		boolean signedIn, boolean privacyEnabled, JournalArticle privacyPolicy,
		HttpServletRequest request, long usedGroupId, Locale locale,
		String nameExtend) {

		if (signedIn) {
			return false;
		}
		else if (!privacyEnabled) {
			if (_log.isDebugEnabled()) {
				_log.debug("Privacy is NOT enabled.");
			}

			return false;
		}

		if (Validator.isNull(privacyPolicy)) {
			if (_log.isWarnEnabled()) {
				_log.warn(
					"Privacy is enabled but no web content is set for " +
						"Privacy Policy!");
			}

			return false;
		}

		long cookieValidationDateMillis = GetterUtil.getLong(
			CookieKeys.getCookie(request, PRIVACY_READ+nameExtend));

		if (Validator.isNull(cookieValidationDateMillis)) {
			return true;
		}

		return false;
	}

	private static Log _log = LogFactoryUtil.getLog(PrivacyUtil.class);

}