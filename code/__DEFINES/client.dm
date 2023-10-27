/// Checks if the given target is either a client or a mock client
#define IS_CLIENT_OR_MOCK(target) (istype(target, /client) || istype(target, /datum/client_interface))

/// Ensures that the client has been fully initialized via New(), and can't somehow execute actions before that. Security measure.
/// WILL RETURN OUT OF THE ENTIRE PROC COMPLETELY IF THE CLIENT IS NOT FULLY INITIALIZED. BE WARNED IF YOU WANT RETURN VALUES.
#define VALIDATE_CLIENT(target)\
	if (!target.fully_created) {\
		to_chat(target, span_warning("You are not fully initialized yet! Please wait a moment."));\
		log_access("Client [key_name(target)] attempted to execute a verb before being fully initialized.");\
		return\
	}

/// Macro that does one thing, which is to set the `key` variable on a mob (target) to the `key` variable on an already extant mob (subject).
/// This is so that the "subject's" client will be able to assume direct control of the "target's" mob, which is useful for stuff like ghosts taking control of a mob, shapeshifting, etc.
/// The reason why we have it as a macro is because this pattern is highly utlitized in the codebase, and it's easier to grep for this macro in case revamps are being done.
/// It's also valuable in case future versions of BYOND somehow break this pattern, at which point this macro can be easily changed to propogate through the entire codebase.
#define KEY_TRANSFER(target, subject) target.key = subject.key
