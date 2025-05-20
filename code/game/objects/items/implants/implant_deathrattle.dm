/datum/deathrattle_group
	var/name
	var/list/implants = list()
	var/verbose = FALSE
	var/station_only = FALSE

/datum/deathrattle_group/New(name)
	if(name)
		src.name = name
	else
		// Give the group a unique name for debugging, and possible future
		// use for making custom linked groups.
		src.name = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"

/*
 * Proc called by new implant being added to the group. Listens for the
 * implant being implanted, removed and destroyed.
 *
 * If implant is already implanted in a person, then trigger the implantation
 * code.
 */
/datum/deathrattle_group/proc/register(obj/item/implant/deathrattle/implant)
	if(implant in implants)
		return
	RegisterSignal(implant, COMSIG_IMPLANT_IMPLANTED, PROC_REF(on_implant_implantation))
	RegisterSignal(implant, COMSIG_IMPLANT_REMOVED, PROC_REF(on_implant_removal))
	RegisterSignal(implant, COMSIG_QDELETING, PROC_REF(on_implant_destruction))

	implants += implant

	if(implant.imp_in)
		on_implant_implantation(implant.imp_in)

/datum/deathrattle_group/proc/on_implant_implantation(obj/item/implant/implant, mob/living/target, mob/user, silent = FALSE, force = FALSE)
	SIGNAL_HANDLER

	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_user_statchange))

/datum/deathrattle_group/proc/on_implant_removal(obj/item/implant/implant, mob/living/source, silent = FALSE, special = 0)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOB_STATCHANGE)

/datum/deathrattle_group/proc/on_implant_destruction(obj/item/implant/implant)
	SIGNAL_HANDLER

	implants -= implant

/datum/deathrattle_group/proc/on_user_statchange(mob/living/owner, new_stat)
	SIGNAL_HANDLER

	if(new_stat != DEAD)
		return

	var/name = owner.mind ? owner.mind.name : owner.real_name
	var/area = get_area_name(get_turf(owner))
	// All "hearers" hear the same sound.
	var/sound = pick(
		'sound/items/knell/knell1.ogg',
		'sound/items/knell/knell2.ogg',
		'sound/items/knell/knell3.ogg',
		'sound/items/knell/knell4.ogg',
	)


	var/turf/death_loc = get_turf(owner)
	for(var/obj/item/implant/deathrattle/implant as anything in implants)
		// Skip the unfortunate soul, and any unimplanted implants
		if(implant.imp_in == owner || isnull(implant.imp_in) || implant.imp_in.stat == DEAD)
			continue
		var/turf/hear_loc = get_turf(implant.imp_in)
		if(station_only && is_station_level(hear_loc.z) != is_station_level(death_loc.z))
			continue

		// Deliberately the same message framing as ghost deathrattle
		if(verbose)
			to_chat(implant.imp_in, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("<b>[name]</b> has died at <b>[area]</b>.")]\"")
		else if(is_station_level(death_loc.z))
			to_chat(implant.imp_in, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("<b>[name]</b> has died on deck <b>[death_loc.z - 1]</b>.")]\"")
		else
			to_chat(implant.imp_in, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("<b>[name]</b> has died.")]\"")
		implant.imp_in.playsound_local(hear_loc, sound, vol = 75, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/obj/item/implant/deathrattle
	name = "deathrattle implant"
	desc = "Hope no one else dies, prepare for when they do."

	actions_types = null

/obj/item/implant/deathrattle/can_be_implanted_in(mob/living/target)
	// Can be implanted in anything that's a mob. Syndicate cyborgs, talking fish, humans...
	return TRUE

/obj/item/implantcase/deathrattle
	name = "implant case - 'Deathrattle'"
	desc = "A glass case containing a deathrattle implant."
	imp_type = /obj/item/implant/deathrattle
