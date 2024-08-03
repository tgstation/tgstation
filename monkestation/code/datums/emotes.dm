/datum/emote
    /// Message displayed if the user is an IPC.
	var/message_ipc = ""
	/// Message displayed if the user is an insect.
	var/message_insect = ""

// Whether this emote should vary in pitch every time it's played.
//
// By default, this returns the `vary` variable, so you should set that if it will always be TRUE or
// FALSE. However, if your emote only varies under certain calling conditions (such as the user
// being a human despite the emote applying to all living creatures), then you should override this
// proc.
/datum/emote/proc/should_vary(mob/living/user)
	return vary

/// Returns the mixer channel that sound emotes should use.
/datum/emote/proc/get_mixer_channel(mob/user, params, type_override, intentional = FALSE)
	return issilicon(user) ? CHANNEL_SILICON_EMOTES : CHANNEL_MOB_EMOTES
