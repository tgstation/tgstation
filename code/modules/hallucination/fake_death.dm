// This hallucinations makes us suddenly think we died, stopping us / changing our hud / sending a fake deadchat message.
/datum/hallucination/death
	random_hallucination_weight = 1
	/// Determines whether we floor them or just immobilize them
	var/floor_them = TRUE

/datum/hallucination/death/Destroy()
	if(!QDELETED(hallucinator))
		// Really make sure these go away, would be bad if they stuck around
		hallucinator.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	return ..()

/datum/hallucination/death/start()
	if(floor_them)
		hallucinator.Paralyze(30 SECONDS)
	else
		hallucinator.Immobilize(30 SECONDS)

	hallucinator.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, REF(src))
	hallucinator.add_traits(list(TRAIT_MUTE, TRAIT_EMOTEMUTE), REF(src))

	to_chat(hallucinator, span_deadsay("<b>[hallucinator.real_name]</b> has died at <b>[get_area_name(hallucinator)]</b>."))

	var/delay = 0

	if(prob(50))
		var/mob/who_is_salting
		if(length(GLOB.dead_player_list))
			who_is_salting = pick(GLOB.dead_mob_list)

		if(who_is_salting)
			delay = rand(2 SECONDS, 5 SECONDS)

			var/static/list/things_to_hate = list(
				"admins",
				"batons",
				"blood cult",
				"coders",
				"heretics",
				"myself",
				"revenants",
				"revs",
				"sec",
				"ss13",
				"this game",
				"this round",
				"this shift",
				"this shit",
				"this",
				"wizards",
				"you",
			)

			var/list/dead_chat_salt = list(
				"...",
				"FUCK",
				"git gud",
				"god damn it",
				"hey [first_name(hallucinator.name)]",
				"i[prob(50) ? " fucking" : ""] hate [pick(things_to_hate)]",
				"is the AI rogue?",
				"rip",
				"shitsec",
				"why did i just drop dead?",
				"why was i gibbed",
				"wizard?",
				"you too?",
			)

			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), hallucinator, span_deadsay("<b>DEAD: [who_is_salting.name]</b> says, \"[pick(dead_chat_salt)]\"")), delay)

	addtimer(CALLBACK(src, PROC_REF(wake_up)), delay + rand(7 SECONDS, 9 SECONDS))
	return TRUE

/datum/hallucination/death/proc/wake_up()
	if(!QDELETED(hallucinator))
		hallucinator.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, REF(src))
		if(floor_them)
			hallucinator.SetParalyzed(0 SECONDS)
		else
			hallucinator.SetImmobilized(0 SECONDS)
		hallucinator.remove_traits(list(TRAIT_MUTE, TRAIT_EMOTEMUTE), REF(src))

	if(!QDELETED(src))
		qdel(src)

// A subtype of death which plays a dusted animation.
/datum/hallucination/death/dust
	floor_them = FALSE
	/// List of all images we created to convey the effect to the hallucinator (so we can remove them after)
	var/list/image/created_images

/datum/hallucination/death/dust/Destroy()
	if(!QDELETED(hallucinator) && LAZYLEN(created_images))
		hallucinator.client?.images -= created_images
		LAZYNULL(created_images)

	return ..()

/datum/hallucination/death/dust/start()
	. = ..()
	if(!.)
		return

	LAZYINITLIST(created_images)
	// Makes hallucinator invisible, we create a clone image to animate on
	var/image/make_them_invisible = image(loc = hallucinator)
	make_them_invisible.override = TRUE
	created_images += make_them_invisible
	// Makes remains, only visible if on a turf
	if(isturf(hallucinator.loc))
		created_images += image(/obj/effect/decal/remains/human, hallucinator.loc)
	// Makes a ghost
	var/image/fake_ghost = image(/mob/dead/observer, get_turf(hallucinator))
	DO_FLOATING_ANIM(fake_ghost)
	created_images += fake_ghost

	hallucinator.client?.images |= created_images

	// Does the actual animation here
	if(isturf(hallucinator.loc))
		new /obj/effect/temp_visual/dust_hallucination(hallucinator.loc, hallucinator)

/obj/effect/temp_visual/dust_hallucination
	// duration doesn't really matter - it just needs to be longer than the dust animation
	// for all non-hallucinating mobs, we're invisible
	// for the hallucinating mob, we animate into invisibility
	duration = 10 SECONDS
	randomdir = FALSE

/obj/effect/temp_visual/dust_hallucination/Initialize(mapload, mob/hallucinator)
	. = ..()
	if(isnull(hallucinator))
		return INITIALIZE_HINT_QDEL

	dir = hallucinator.dir
	appearance = hallucinator.appearance
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	// make it invisible to everyone else
	var/image/invisible = image(loc = src)
	invisible.override = TRUE
	add_alt_appearance(
		/* type = *//datum/atom_hud/alternate_appearance/basic/one_person/reversed,
		/* key = */"[REF(src)]",
		/* image = */invisible,
		/* options = */null,
		/* non-seer = */hallucinator,
	)

	// do the dust animation, only the hallucinator can see it now
	dust_animation()
