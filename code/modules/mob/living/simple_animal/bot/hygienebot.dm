//Cleanbot
/mob/living/simple_animal/bot/hygienebot
	name = "\improper Hygienebot"
	desc = "A flying cleaning robot, he'll chase down people who can't shower properly!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "hygienebot"
	base_icon_state = "hygienebot"
	pass_flags = PASSMOB | PASSFLAPS | PASSTABLE
	layer = MOB_UPPER_LAYER
	density = FALSE
	anchored = FALSE
	health = 100
	maxHealth = 100

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_mode_flags = ~BOT_MODE_PAI_CONTROLLABLE
	bot_type = HYGIENE_BOT
	hackables = "cleaning service protocols"
	path_image_color = "#993299"

	///The human target the bot is trying to wash.
	var/mob/living/carbon/human/target
	///The mob's current speed, which varies based on how long the bot chases it's target.
	var/currentspeed = 5
	///Is the bot currently washing it's target/everything else that crosses it?
	var/washing = FALSE
	///Have the target evaded the bot for long enough that it will swear at it like kirk did to kahn?
	var/mad = FALSE
	///The last time that the previous/current target was found.
	var/last_found
	///Name of the previous target the bot was pursuing.
	var/oldtarget_name
	///Visual overlay of the bot spraying water.
	var/mutable_appearance/water_overlay
	///Visual overlay of the bot commiting warcrimes.
	var/mutable_appearance/fire_overlay

/mob/living/simple_animal/bot/hygienebot/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/jani_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/janitor]
	access_card.add_access(jani_trim.access + jani_trim.wildcard_access)
	prev_access = access_card.access.Copy()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	ADD_TRAIT(src, TRAIT_SPRAY_PAINTABLE, INNATE_TRAIT)

/mob/living/simple_animal/bot/hygienebot/explode()
	new /obj/effect/particle_effect/fluid/foam(loc)

	return ..()

/mob/living/simple_animal/bot/hygienebot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(washing)
		do_wash(AM)

/mob/living/simple_animal/bot/hygienebot/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][bot_mode_flags & BOT_MODE_ON ? "-on" : null]"


/mob/living/simple_animal/bot/hygienebot/update_overlays()
	. = ..()
	if(bot_mode_flags & BOT_MODE_ON)
		. += mutable_appearance(icon, "hygienebot-flame")

	if(washing)
		. += mutable_appearance(icon, bot_cover_flags & BOT_COVER_EMAGGED ? "hygienebot-fire" : "hygienebot-water")


/mob/living/simple_animal/bot/hygienebot/turn_off()
	..()
	mode = BOT_IDLE

/mob/living/simple_animal/bot/hygienebot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	SSmove_manager.stop_looping(src)
	last_found = world.time

/mob/living/simple_animal/bot/hygienebot/handle_automated_action()
	if(!..())
		return

	if(washing)
		do_wash(loc)
		for(var/AM in loc)
			if (AM == src)
				continue
			do_wash(AM)
		if(isopenturf(loc) && !(bot_cover_flags & BOT_COVER_EMAGGED))
			var/turf/open/tile = loc
			tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

	switch(mode)
		if(BOT_IDLE) // idle
			SSmove_manager.stop_looping(src)
			look_for_lowhygiene() // see if any disgusting fucks are in range
			if(!mode && bot_mode_flags & BOT_MODE_AUTOPATROL) // still idle, and set to patrol
				mode = BOT_START_PATROL // switch to patrol mode

		if(BOT_HUNT) // hunting for stinkman
			if(bot_cover_flags & BOT_COVER_EMAGGED) //lol fuck em up
				currentspeed = 3.5
				start_washing()
				mad = TRUE
			else
				switch(frustration)
					if(0 to 4)
						currentspeed = 5
						mad = FALSE
					if(5 to INFINITY)
						currentspeed = 2.5
						mad = TRUE
			if(target && !check_purity(target))
				if(target.loc == loc && isturf(target.loc)) //LADIES AND GENTLEMAN WE GOTEM PREPARE TO DUMP
					start_washing()
					if(mad)
						speak("Well about fucking time you degenerate.", "Fucking finally.", "Thank god, you finally stopped.")
						playsound(loc, 'sound/effects/hygienebot_angry.ogg', 60, 1)
						mad = FALSE
					mode = BOT_SHOWERSTANCE
				else
					stop_washing()
					var/olddist = get_dist(src, target)
					if(olddist > 20 || frustration > 100) // Focus on something else
						back_to_idle()
						return
					SSmove_manager.move_to(src, target, 0, currentspeed)
					if(mad && prob(min(frustration * 2, 60)))
						playsound(loc, 'sound/effects/hygienebot_angry.ogg', 60, 1)
						speak(pick("Get back here you foul smelling fucker.", "STOP RUNNING OR I WILL CUT YOUR ARTERIES!", "Just fucking let me clean you you arsehole!", "STOP. RUNNING.", "Either you stop running or I will fucking drag you out of an airlock.", "I just want to fucking clean you you troglodyte.", "If you don't come back here I'll put a green cloud around you cunt."))
					if((get_dist(src, target)) >= olddist)
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_SHOWERSTANCE)
			if(check_purity(target))
				speak("Enjoy your clean and tidy day!")
				playsound(loc, 'sound/effects/hygienebot_happy.ogg', 60, 1)
				back_to_idle()
				return
			if(!target)
				last_found = world.time
			if(target.loc != loc || !isturf(target.loc))
				back_to_hunt()

		if(BOT_START_PATROL)
			look_for_lowhygiene()
			start_patrol()

		if(BOT_PATROL)
			look_for_lowhygiene()
			bot_patrol()

/mob/living/simple_animal/bot/hygienebot/proc/back_to_idle()
	mode = BOT_IDLE
	SSmove_manager.stop_looping(src)
	target = null
	frustration = 0
	last_found = world.time
	stop_washing()
	INVOKE_ASYNC(src, .proc/handle_automated_action)

/mob/living/simple_animal/bot/hygienebot/proc/back_to_hunt()
	frustration = 0
	mode = BOT_HUNT
	stop_washing()
	INVOKE_ASYNC(src, .proc/handle_automated_action)

/mob/living/simple_animal/bot/hygienebot/proc/look_for_lowhygiene()
	for (var/mob/living/carbon/human/H in view(7,src)) //Find the NEET
		if((H.name == oldtarget_name) && (world.time < last_found + 100))
			continue
		if(!check_purity(H)) //Theyre impure
			target = H
			oldtarget_name = H.name
			speak("Unhygienic client found. Please stand still so I can clean you.")
			playsound(loc, 'sound/effects/hygienebot_happy.ogg', 60, 1)
			visible_message("<b>[src]</b> points at [H.name]!")
			mode = BOT_HUNT
			INVOKE_ASYNC(src, .proc/handle_automated_action)
			break
		else
			continue

/mob/living/simple_animal/bot/hygienebot/proc/start_washing()
	washing = TRUE
	update_appearance()

/mob/living/simple_animal/bot/hygienebot/proc/stop_washing()
	washing = FALSE
	update_appearance()

/mob/living/simple_animal/bot/hygienebot/proc/check_purity(mob/living/L)
	if((bot_cover_flags & BOT_COVER_EMAGGED) && L.stat != DEAD)
		return FALSE

	for(var/X in list(ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING, ITEM_SLOT_FEET))

		var/obj/item/I = L.get_item_by_slot(X)
		if(I && GET_ATOM_BLOOD_DNA_LENGTH(I))
			return FALSE
	return TRUE

/mob/living/simple_animal/bot/hygienebot/proc/do_wash(atom/A)
	if(bot_cover_flags & BOT_COVER_EMAGGED)
		A.fire_act()  //lol pranked no cleaning besides that
	else
		A.wash(CLEAN_WASH)
