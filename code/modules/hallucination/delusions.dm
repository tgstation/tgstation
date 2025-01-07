/// A hallucination that makes us and (possibly) other people look like something else.
/datum/hallucination/delusion
	abstract_hallucination_parent = /datum/hallucination/delusion

	/// The duration of the delusions
	var/duration = 30 SECONDS

	/// If TRUE, this delusion affects us
	var/affects_us = TRUE
	/// If TRUE, this hallucination affects all humans in existence
	var/affects_others = FALSE
	/// If TRUE, people in view of our hallcuinator won't be affected (requires affects_others)
	var/skip_nearby = FALSE
	/// If TRUE, we will play the wabbajack sound effect to the hallucinator
	var/play_wabbajack = FALSE

	/// The file the delusion image is made from
	var/delusion_icon_file
	/// The icon state of the delusion image
	var/delusion_icon_state

	/// Do we use an appearance/generated icon? If yes no icon file or state needed.
	var/dynamic_delusion = FALSE
	/// Appearance to use as a source for our image
	/// If this exists we'll ignore the icon/state from above
	var/mutable_appearance/delusion_appearance

	/// The name of the delusion image
	var/delusion_name

	/// A list of all images we've made
	var/list/image/delusions

/datum/hallucination/delusion/New(
	mob/living/hallucinator,
	duration,
	affects_us,
	affects_others,
	skip_nearby,
	play_wabbajack,
)

	if(isnum(duration))
		src.duration = duration
	if(!isnull(affects_us))
		src.affects_us = affects_us
	if(!isnull(affects_others))
		src.affects_others = affects_others
	if(!isnull(skip_nearby))
		src.skip_nearby = skip_nearby
	if(!isnull(play_wabbajack))
		src.play_wabbajack = play_wabbajack

	return ..()

/datum/hallucination/delusion/Destroy()
	if(!QDELETED(hallucinator) && LAZYLEN(delusions))
		hallucinator.client?.images -= delusions
		LAZYNULL(delusions)

	return ..()

/datum/hallucination/delusion/start()
	if(!hallucinator.client)
		return FALSE

	feedback_details += "Delusion: [delusion_name]"

	var/list/mob/living/carbon/human/funny_looking_mobs = list()

	// The delusion includes others - all humans
	if(affects_others)
		funny_looking_mobs |= GLOB.human_list.Copy()

	// The delusion includes us - we might be in it already, we might not
	if(affects_us)
		funny_looking_mobs |= hallucinator

	// The delusion should not inlude us
	else
		funny_looking_mobs -= hallucinator

	// The delusion shouldn not include anyone in view of us
	if(skip_nearby)
		for(var/mob/living/carbon/human/nearby_human in view(hallucinator))
			if(nearby_human == hallucinator) // Already handled by affects_us
				continue
			funny_looking_mobs -= nearby_human

	for(var/mob/living/carbon/human/found_human in funny_looking_mobs)
		var/image/funny_image = make_delusion_image(found_human)
		LAZYADD(delusions, funny_image)
		hallucinator.client.images |= funny_image

	if(play_wabbajack)
		to_chat(hallucinator, span_hear("...wabbajack...wabbajack..."))
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/magic/staff_change.ogg', 50, TRUE)

	if(duration > 0)
		QDEL_IN(src, duration)
	return TRUE

/datum/hallucination/delusion/proc/make_delusion_image(mob/over_who)
	var/image/funny_image
	if(delusion_appearance)
		funny_image = image(delusion_appearance, over_who)
	else
		funny_image = image(delusion_icon_file, over_who, delusion_icon_state)
	funny_image.name = delusion_name
	funny_image.override = TRUE
	return funny_image

/// Used for making custom delusions.
/datum/hallucination/delusion/custom
	random_hallucination_weight = 0

/datum/hallucination/delusion/custom/New(
	mob/living/hallucinator,
	duration,
	affects_us,
	affects_others,
	skip_nearby,
	play_wabbajack,
	custom_icon_file,
	custom_icon_state,
	custom_name,
)

	if(!custom_icon_file || !custom_icon_state)
		stack_trace("Custom delusion hallucination was created without any custom icon information passed.")

	src.delusion_icon_file = custom_icon_file
	src.delusion_icon_state = custom_icon_state
	src.delusion_name = custom_name

	return ..()

/datum/hallucination/delusion/preset
	abstract_hallucination_parent = /datum/hallucination/delusion/preset
	random_hallucination_weight = 2

/datum/hallucination/delusion/preset/nothing
	delusion_icon_file = 'icons/effects/effects.dmi'
	delusion_icon_state = "nothing"
	delusion_name = "..."

/datum/hallucination/delusion/preset/curse
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "curseblob"
	delusion_name = "???"

/datum/hallucination/delusion/preset/monkey
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "monkey"
	delusion_name = "monkey"

/datum/hallucination/delusion/preset/monkey/start()
	delusion_name += " ([rand(1, 999)])"
	return ..()

/datum/hallucination/delusion/preset/corgi
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "corgi"
	delusion_name = "corgi"

/datum/hallucination/delusion/preset/carp
	delusion_icon_file = 'icons/mob/simple/carp.dmi'
	delusion_icon_state = "carp"
	delusion_name = "carp"

/datum/hallucination/delusion/preset/skeleton
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "skeleton"
	delusion_name = "skeleton"

/datum/hallucination/delusion/preset/zombie
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "zombie"
	delusion_name = "zombie"

/datum/hallucination/delusion/preset/demon
	delusion_icon_file = 'icons/mob/simple/demon.dmi'
	delusion_icon_state = "slaughter_demon"
	delusion_name = "demon"

/datum/hallucination/delusion/preset/cyborg
	delusion_icon_file = 'icons/mob/silicon/robots.dmi'
	delusion_icon_state = "robot"
	delusion_name = "cyborg"
	play_wabbajack = TRUE

/datum/hallucination/delusion/preset/cyborg/make_delusion_image(mob/over_who)
	. = ..()
	hallucinator.playsound_local(get_turf(over_who), 'sound/mobs/non-humanoids/cyborg/liveagain.ogg', 75, TRUE)

/datum/hallucination/delusion/preset/ghost
	delusion_icon_file = 'icons/mob/simple/mob.dmi'
	delusion_icon_state = "ghost"
	delusion_name = "ghost"
	affects_others = TRUE

/datum/hallucination/delusion/preset/ghost/make_delusion_image(mob/over_who)
	var/image/funny_image = ..()
	funny_image.name = over_who.name
	DO_FLOATING_ANIM(funny_image)
	return funny_image

/datum/hallucination/delusion/preset/syndies
	dynamic_delusion = TRUE
	random_hallucination_weight = 1
	delusion_name = "Syndicate"
	affects_others = TRUE
	affects_us = FALSE

/datum/hallucination/delusion/preset/syndies/make_delusion_image(mob/over_who)
	delusion_appearance = get_dynamic_human_appearance(
		mob_spawn_path = pick(
			/obj/effect/mob_spawn/corpse/human/syndicatesoldier,
			/obj/effect/mob_spawn/corpse/human/syndicatecommando,
			/obj/effect/mob_spawn/corpse/human/syndicatestormtrooper,
		),
		r_hand = pick(
			/obj/item/knife/combat/survival,
			/obj/item/melee/energy/sword/saber,
			/obj/item/gun/ballistic/automatic/pistol,
			/obj/item/gun/ballistic/automatic/c20r,
			/obj/item/gun/ballistic/shotgun/bulldog,
		),
	)

	return ..()

/datum/hallucination/delusion/preset/seccies
	dynamic_delusion = TRUE
	random_hallucination_weight = 0
	delusion_name = "Security"
	affects_others = TRUE
	affects_us = FALSE

/datum/hallucination/delusion/preset/seccies/make_delusion_image(mob/over_who)
	delusion_appearance = get_dynamic_human_appearance(
		outfit_path = /datum/outfit/job/security,
		bloody_slots = prob(5) ? ALL : NONE,
		r_hand = prob(15) ? /obj/item/melee/baton/security/loaded : null,
		l_hand = prob(15) ? /obj/item/melee/baton/security/loaded : null,
	)
	return ..()

/// Hallucination used by the nightmare vision goggles to turn everyone except you into mares
/datum/hallucination/delusion/preset/mare
	delusion_icon_file = 'icons/obj/clothing/masks.dmi'
	delusion_icon_state = "horsehead"
	delusion_name = "mare"
	affects_us = FALSE
	affects_others = TRUE
	random_hallucination_weight = 0

/// Hallucination used by the path of moon heretic to turn everyone into a lunar mass
/datum/hallucination/delusion/preset/moon
	delusion_icon_file = 'icons/mob/nonhuman-player/eldritch_mobs.dmi'
	delusion_icon_state = "moon_mass"
	delusion_name = "moon"
	duration = 15 SECONDS
	affects_others = TRUE
	random_hallucination_weight = 0

// Hallucination used by heretic paintings
/datum/hallucination/delusion/preset/heretic
	dynamic_delusion = TRUE
	random_hallucination_weight = 0
	delusion_name = "Heretic"
	affects_others = TRUE
	affects_us = FALSE
	duration = 11 SECONDS

/datum/hallucination/delusion/preset/heretic/make_delusion_image(mob/over_who)
	// This code is dummy hot for DUMB reasons so let's not make a mob constantly yeah?
	var/static/mutable_appearance/heretic_appearance
	if(isnull(heretic_appearance))
		heretic_appearance = get_dynamic_human_appearance(/datum/outfit/heretic, r_hand = NO_REPLACE)
	delusion_appearance = heretic_appearance
	return ..()

/datum/hallucination/delusion/preset/heretic/gate
	delusion_name = "Mind Gate"
	duration = 60 SECONDS
	affects_us = TRUE
