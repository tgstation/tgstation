/// from base of [/client/proc/handle_spam_prevention] (message, mute_type)
#define SIGNAL_CLIENT_AUTOMUTE_CHECK "client_automute_check"
	/// Prevents the automute system checking this client for repeated messages.
	#define WAIVE_AUTOMUTE_CHECK (1<<0)
