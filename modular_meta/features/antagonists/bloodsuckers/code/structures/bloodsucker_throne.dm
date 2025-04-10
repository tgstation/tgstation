/// Blood Throne - Allows Bloodsuckers to remotely speak with their Vassals. - Code (Mostly) stolen from comfy chairs (armrests) and chairs (layers)

/obj/structure/bloodsucker/bloodthrone
	name = "wicked throne"
	desc = "Twisted metal shards jut from the arm rests, making it appear very uncomfortable. Still, it might sell well at an antique shop."
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj_64.dmi'
	icon_state = "throne"
	buckle_lying = 0
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	ghost_desc = "This is a Bloodsucker's throne, any Bloodsucker sitting on it can remotely speak to their vassals by attempting to speak aloud."
	vamp_desc = "This is a blood throne, sitting on it will allow you to telepathically broadcast messages to all of your vassals by simply speaking. \n\
		Unlike other blood structures this throne may be unsecured by a <b>right-click</b> (just make sure it's unoccupied first)."
	vassal_desc = "This is a blood throne, it allows your master to telepathically speak to you and others who work under them."
	hunter_desc = "This blood-red seat allows vampires to telepathically communicate with those in their fold."

	///The static armrest that the throne has while someone is buckled onto it.
	var/static/mutable_appearance/armrest

// Add rotating and armrest
/obj/structure/bloodsucker/bloodthrone/Initialize()
	AddComponent(/datum/component/simple_rotation, ROTATION_IGNORE_ANCHORED)
	if(!armrest)
		armrest = mutable_appearance('fulp_modules/icons/antagonists/bloodsuckers/vamp_obj_64.dmi', "thronearm")
		armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/bloodsucker/bloodthrone/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/bloodsucker/bloodthrone/bolt()
	. = ..()
	anchored = TRUE

/obj/structure/bloodsucker/bloodthrone/unbolt()
	. = ..()
	anchored = FALSE

/obj/structure/bloodsucker/bloodthrone/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(length(buckled_mobs))
		return
	if(anchored)
		prompt_unsecure(user)

/obj/structure/bloodsucker/bloodthrone/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		. += armrest

// Rotating
/obj/structure/bloodsucker/bloodthrone/setDir(newdir)
	. = ..()
	if(has_buckled_mobs())
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.setDir(newdir)

	if(dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

// Buckling
/obj/structure/bloodsucker/bloodthrone/buckle_mob(mob/living/user, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	. = ..()
	user.visible_message(
		span_notice("[user] sits down on [src]."),
		span_boldnotice("You sit down onto [src]."),
	)
	RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/obj/structure/bloodsucker/bloodthrone/post_buckle_mob(mob/living/target)
	. = ..()
	target.pixel_y += 3
	update_appearance(UPDATE_ICON)

// Unbuckling
/obj/structure/bloodsucker/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	UnregisterSignal(user, COMSIG_MOB_SAY)
	return ..()

/obj/structure/bloodsucker/bloodthrone/post_unbuckle_mob(mob/living/target)
	. = ..()
	target.pixel_y -= 2
	update_appearance(UPDATE_OVERLAYS)

// The speech itself
/obj/structure/bloodsucker/bloodthrone/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/user = source
	if(!user.mind || !IS_BLOODSUCKER(user))
		return
	var/message = speech_args[SPEECH_MESSAGE]
	var/rendered = span_cult_large("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag=ROLE_BLOODSUCKER)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	for(var/datum/antagonist/vassal/receiver as anything in bloodsuckerdatum.vassals)
		if(!receiver.owner.current)
			continue
		var/mob/receiver_mob = receiver.owner.current
		to_chat(receiver_mob, rendered)
	to_chat(user, rendered) // tell yourself, too.

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""
