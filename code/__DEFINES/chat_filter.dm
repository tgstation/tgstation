/// The index of the word that was filtered in a is_*_filtered proc
#define CHAT_FILTER_INDEX_WORD 1

/// The index of the reason why a word was filtered in a is_*_filtered proc
#define CHAT_FILTER_INDEX_REASON 2

/// Given a chat filter result, will send a to_chat to the user telling them about why their message was blocked
#define REPORT_CHAT_FILTER_TO_USER(user, filter_result) \
	to_chat(user, span_warning("The word <b>[html_encode(filter_result[CHAT_FILTER_INDEX_WORD])]</b> is prohibited: [html_encode(filter_result[CHAT_FILTER_INDEX_REASON])]"))

/// Given a user, returns TRUE if they are allowed to bypass the filter.
#define CAN_BYPASS_FILTER(user) (!isnull(user?.client?.holder))
