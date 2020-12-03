/// A smite, used by admins to punish players, or for their own amusement
/datum/smite
	/// The name of the smite, shown in the menu
	var/name

	/// Should this smite write to logs?
	var/should_log = TRUE

/// The effect of the smite, make sure to call this in your own smites
/datum/smite/proc/effect(client/user, mob/living/target)
	if (should_log)
		user.punish_log(target, name)
