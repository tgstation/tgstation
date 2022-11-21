// This hallucinations makes us suddenly think we died, stopping us / changing our hud / sending a fake deadchat message.
/datum/hallucination/death
	random_hallucination_weight = 1

/datum/hallucination/death/Destroy()
	if(!QDELETED(hallucinator))
		// Really make sure these go away, would be bad if they stuck around
		hallucinator.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	return ..()

/datum/hallucination/death/start()
	hallucinator.Paralyze(30 SECONDS)
	hallucinator.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_dead, REF(src))
	ADD_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
	ADD_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

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
				"hey [hallucinator.first_name()]",
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
		hallucinator.SetParalyzed(0 SECONDS)
		REMOVE_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	if(!QDELETED(src))
		qdel(src)

// A subtype of death which plays a dusted animation.
/datum/hallucination/death/dust
	/// List of all images we created to convey the effect to the hallucinator (so we can remove them after)
	var/list/image/created_images

/datum/hallucination/death/dust/Destroy()
	if(!QDELETED(hallucinator) && LAZYLEN(created_images))
		hallucinator.client?.images -= created_images
		LAZYNULL(created_images)

	return ..()

/datum/hallucination/death/dust/start()

	if(!ishuman(hallucinator))
		return FALSE

	var/mob/living/carbon/human/hallucinating_human = hallucinator
	var/dust_icon_state = hallucinating_human.dna?.species?.dust_anim
	if(!dust_icon_state)
		return FALSE

	. = ..()
	if(!.)
		return

	created_images = list()
	var/turf/below_hallucinating = get_turf(hallucinator)

	// Apply a blank / empty image to make them look invisible to themselves
	var/image/make_them_invisible = image(loc = hallucinator)
	make_them_invisible.override = TRUE
	created_images += make_them_invisible

	// Grab the typepath of the dust animation visual so we can steal its icon (for consistency and futureproofing)
	var/obj/effect/temp_visual/dust_animation/dust_source = /obj/effect/temp_visual/dust_animation
	var/image/fake_dust_animation = image(initial(dust_source.icon), below_hallucinating, dust_icon_state, layer = ABOVE_MOB_LAYER)
	created_images += fake_dust_animation

	// Grab the typepath of remains so we can steal its icon and state (futureproofing)
	var/obj/effect/decal/remains/human/remains_source = /obj/effect/decal/remains/human
	var/image/fake_remains_image = image(initial(remains_source.icon), below_hallucinating, initial(remains_source.icon_state))
	created_images += fake_remains_image

	// Grab the typepath of an observer so we can steal its icon and state (futureproofing)
	var/mob/dead/observer/observer_source = /mob/dead/observer
	var/image/fake_ghost = image(initial(observer_source.icon), below_hallucinating, initial(observer_source.icon_state))
	DO_FLOATING_ANIM(fake_ghost)
	created_images += fake_ghost

	hallucinator.client?.images |= created_images
