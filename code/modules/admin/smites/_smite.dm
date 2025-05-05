/// A smite, used by admins to punish players, or for their own amusement
/datum/smite
	/// The name of the smite, shown in the menu
	var/name
	/// Flags which modify how the smite fires
	var/smite_flags = NONE
	/// Should this smite write to logs?
	var/should_log = TRUE

/// Called once after either choosing the option to smite a player, or when selected in smite build mode.
/// Use this to prompt the user configuration options.
/// Return FALSE if the smite should not be used.
/datum/smite/proc/configure(client/user)

/// Invoked externally to actually perform the smite
/datum/smite/proc/do_effect(client/user, mob/living/target)
	if(smite_flags & SMITE_DIVINE)
		playsound(target, 'sound/effects/pray.ogg', 50, FALSE, -1)
		target.apply_status_effect(
			/datum/status_effect/spotlight_light/divine,
			3 SECONDS,
			mutable_appearance('icons/mob/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER),
		)

	if(smite_flags & SMITE_STUN)
		target.Stun(3 SECONDS, ignore_canstun = TRUE)
	if(smite_flags & SMITE_DELAY)
		addtimer(CALLBACK(src, PROC_REF(delayed_effect), user, target), 2 SECONDS, TIMER_UNIQUE)
	else
		effect(user, target)

/// Called after a delay if the smite has the SMITE_DELAY flag
/datum/smite/proc/delayed_effect(client/user, mob/living/target)
	if(QDELETED(target))
		return
	effect(user, target)

/// The effect of the smite, make sure to call this in your own smites
/datum/smite/proc/effect(client/user, mob/living/target)
	if (should_log)
		user.punish_log(target, name)
