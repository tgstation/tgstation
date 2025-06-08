/// Mob which can become evil when exposed to a certain ability
/datum/element/regal_rat_minion
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Typepath of converted mob
	var/converted_path
	/// Balloon string to output on conversion
	var/success_balloon
	/// Commands to give this mob on conversion
	var/list/pet_commands

/datum/element/regal_rat_minion/Attach(datum/target, converted_path, success_balloon = "squeak", list/pet_commands)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.converted_path = converted_path
	src.success_balloon = success_balloon
	src.pet_commands = pet_commands

	RegisterSignal(target, COMSIG_REGAL_RAT_RIOTED, PROC_REF(on_rioted))

/datum/element/regal_rat_minion/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_REGAL_RAT_RIOTED)

/// Makes a mob into a minion
/datum/element/regal_rat_minion/proc/on_rioted(mob/living/minion, mob/living/master)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(do_conversion), minion, master)

/// Actually turn the mob into a different mob
/datum/element/regal_rat_minion/proc/do_conversion(mob/living/minion, mob/living/master)
	if (minion.stat == DEAD)
		return

	var/mob/living/result = converted_path
	var/new_name = minion.name == initial(minion.name) ? result::name : minion.name
	var/mob/living/new_minion = minion.change_mob_type(converted_path, new_name = new_name, delete_old_mob = TRUE)
	if (length(pet_commands))
		new_minion.AddComponent(/datum/component/obeys_commands, pet_commands)

	qdel(new_minion.GetComponent(/datum/component/tameable)) // Rats don't share

	new_minion.befriend(master)
	new_minion.faction = master.faction.Copy()
	new_minion.balloon_alert_to_viewers(success_balloon)
