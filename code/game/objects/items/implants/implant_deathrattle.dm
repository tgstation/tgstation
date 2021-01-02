/datum/deathrattle_group
	var/name
	var/list/datum/weakref/implant_refs = list()

/datum/deathrattle_group/New()
	// Give the group a unique name for debugging, and possible future
	// use for making custom linked groups.
	name = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"

/datum/deathrattle_group/proc/rattle(obj/item/implant/deathrattle/origin, mob/living/owner)
	var/name = owner.mind ? owner.mind.name : owner.real_name
	var/area = get_area_name(get_turf(owner))

	for(var/r in implant_refs)
		var/datum/weakref/R = r

		var/obj/item/implant/deathrattle/implant = R.resolve()
		if(!implant || implant == origin)
			continue

		// Not all the implants may be actually implanted in people.
		if(!implant.imp_in)
			continue

		// Deliberately the same message framing as nanite message + ghost deathrattle
		var/msg = "<i>You hear a strange, robotic voice in your head...</i> \"<span class='robot'><b>[name]</b> has died at <b>[area]</b>.</span>\""
		to_chat(implant.imp_in, msg)

/datum/deathrattle_group/proc/register(obj/item/implant/deathrattle/implant)
	implant.group = src
	implant_refs += WEAKREF(implant)


/obj/item/implant/deathrattle
	name = "deathrattle implant"
	desc = "Hope no one else dies, prepare for when they do."

	activated = FALSE

	var/datum/deathrattle_group/group = null

/obj/item/implant/deathrattle/Destroy()
	group = null
	. = ..()

/obj/item/implant/deathrattle/can_be_implanted_in(mob/living/target)
	// Can be implanted in anything that's a mob. Syndicate cyborgs, talking fish, humans...
	return TRUE

/obj/item/implant/deathrattle/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	if(group)
		group.rattle(origin = src, owner = source)

/obj/item/implant/deathrattle/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, .proc/on_death)

		if(!group)
			var/msg = "<i>You hear a strange, robotic voice in your head...</i> \"<span class='robot'>Warning: No other linked implants detected.</span>\""
			to_chat(target, msg)


/obj/item/implantcase/deathrattle
	name = "implant case - 'Deathrattle'"
	desc = "A glass case containing a deathrattle implant."
	imp_type = /obj/item/implant/deathrattle
