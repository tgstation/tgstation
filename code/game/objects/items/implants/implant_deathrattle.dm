/datum/deathrattle_group
	/// The name of our deathrattle group.
	var/name
	/// The associated implants in this deathrattle group.
	var/list/implants = list()
	/// The area whitelist: if someone dies in an area marked with this, they don't cause an alert.
	var/list/area/area_whitelist = list()

/datum/deathrattle_group/New(name)
	if(name)
		src.name = name
	else
		// Give the group a unique name for debugging, and possible future
		// use for making custom linked groups.
		src.name = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"

/datum/deathrattle_group/offsite
	area_whitelist = list(
		/area/station,
		/area/mine,
	)

/datum/deathrattle_group/offsite/New(name)
	if(name)
		src.name = name
	else
		// Give the group a unique name for debugging, and possible future
		// use for making custom linked groups.
		src.name = "OS-[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"

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
	implant.current_group = src

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
	var/area/death_area = get_area(owner)
	if(is_type_in_list(death_area, area_whitelist))
		return // don't alert a death if it's in the area whitelist
	var/area_name = get_area_name(get_turf(owner))
	// All "hearers" hear the same sound.
	var/sound = pick(
		'sound/items/knell/knell1.ogg',
		'sound/items/knell/knell2.ogg',
		'sound/items/knell/knell3.ogg',
		'sound/items/knell/knell4.ogg',
	)


	for(var/_implant in implants)
		var/obj/item/implant/deathrattle/implant = _implant

		// Skip the unfortunate soul, and any unimplanted implants
		if(implant.imp_in == owner || !implant.imp_in)
			continue

		// Deliberately the same message framing as ghost deathrattle
		var/mob/living/recipient = implant.imp_in
		to_chat(recipient, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("<b>[name]</b> has died at <b>[area_name]</b>.")]\"")
		recipient.playsound_local(get_turf(recipient), sound, vol = 75, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/obj/item/implant/deathrattle
	name = "deathrattle implant"
	desc = "Hope no one else dies, prepare for when they do."

	actions_types = null
	allow_multiple = TRUE
	var/deathrattle_group_type = /datum/deathrattle_group

	/// Associated deathrattle group, for future configuration.
	var/datum/deathrattle_group/current_group

	implant_info = "Requires configuration before implanting. Automatically activates upon implantation. \
		Notifies the host of deaths that occur in other deathrattle implant hosts linked to the same deathrattle group."

	implant_lore = "The Robust Corp Fatality Notification System, colloquially the \"deathrattle\" implant, \
		is a subcutaneous hybrid vitals tracker and encrypted transmitter, \
		designed to communicate with other FNS units implanted within other hosts. Upon detecting a lack of vital signs, \
		the FNS will relay the fatality and its rough estimated location to the other hosts. How it can communicate \
		over such long distances is a trade secret that both Nanotrasen and the Syndicate are quite curious about."

/obj/item/implant/deathrattle/can_be_implanted_in(mob/living/target)
	if(!current_group)
		balloon_alert(target, "deathrattle needs configuration!")
		return FALSE
	// Can be implanted in anything that's a mob. Syndicate cyborgs, talking fish, humans...
	return TRUE

/obj/item/implant/deathrattle/offstation
	name = "expeditionary deathrattle implant"

	deathrattle_group_type = /datum/deathrattle_group/offsite

	implant_info = "ONLY TRIGGERS ON NON-STATION DEATHS. \
		Requires configuration before implanting. Automatically activates upon implantation. \
		Notifies the host of deaths that occur in other deathrattle implant hosts linked to the same deathrattle group."

/obj/item/implantcase/deathrattle
	name = "implant case - 'Deathrattle'"
	desc = "A glass case containing a deathrattle implant."
	imp_type = /obj/item/implant/deathrattle

/obj/item/implantcase/deathrattle/offstation
	name = "implant case - 'Expeditionary Deathrattle'"
	desc = "A glass case containing an expeditionary deathrattle implant. Only alerts to deaths outside of the station and mining outpost."
	imp_type = /obj/item/implant/deathrattle/offstation
