/datum/deathrattle_group
	var/name
	var/list/implants = list()

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
	RegisterSignal(implant, COMSIG_IMPLANT_IMPLANTED, .proc/on_implant_implantation)
	RegisterSignal(implant, COMSIG_IMPLANT_REMOVED, .proc/on_implant_removal)
	RegisterSignal(implant, COMSIG_PARENT_QDELETING, .proc/on_implant_destruction)

	implants += implant

	if(implant.imp_in)
		on_implant_implantation(implant.imp_in)

/datum/deathrattle_group/proc/on_implant_implantation(obj/item/implant/implant, mob/living/target, mob/user, silent = FALSE, force = FALSE)
	SIGNAL_HANDLER

	RegisterSignal(target, COMSIG_MOB_STATCHANGE, .proc/on_user_statchange)

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
		'sound/items/knell1.ogg',
		'sound/items/knell2.ogg',
		'sound/items/knell3.ogg',
		'sound/items/knell4.ogg',
	)


	for(var/_implant in implants)
		var/obj/item/implant/deathrattle/implant = _implant

		// Skip the unfortunate soul, and any unimplanted implants
		if(implant.imp_in == owner || !implant.imp_in)
			continue

		// Deliberately the same message framing as nanite message + ghost deathrattle
		var/mob/living/recipient = implant.imp_in
		to_chat(recipient, "<i>You hear a strange, robotic voice in your head...</i> \"<span class='robot'><b>[name]</b> has died at <b>[area]</b>.</span>\"")
		recipient.playsound_local(get_turf(recipient), sound, vol = 75, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/obj/item/implant/deathrattle
	name = "deathrattle implant"
	desc = "Hope no one else dies, prepare for when they do."

	activated = FALSE

/obj/item/implant/deathrattle/can_be_implanted_in(mob/living/target)
	// Can be implanted in anything that's a mob. Syndicate cyborgs, talking fish, humans...
	return TRUE

/obj/item/implantcase/deathrattle
	name = "implant case - 'Deathrattle'"
	desc = "A glass case containing a deathrattle implant."
	imp_type = /obj/item/implant/deathrattle
