//Cleanbot
/mob/living/simple_animal/bot/hygienebot
	name = "\improper Hygienebot"
	desc = "A flying cleaning robot, he'll chase down people who can't shower properly!"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "drone"
	density = FALSE
	anchored = FALSE
	health = 100
	maxHealth = 100
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_type = HYGIENE_BOT
	model = "Cleanbot"
	bot_core_type = /obj/machinery/bot_core/hygienebot
	window_id = "autoclean"
	window_name = "Automatic Crew Cleaner X2"
	pass_flags = PASSMOB
	path_image_color = "#993299"
	allow_pai = FALSE
	layer = ABOVE_MOB_LAYER

	var/mob/living/carbon/human/target
	var/currentspeed = 5
	var/washing = FALSE
	var/mad = FALSE
	var/last_found
	var/oldtarget_name

	var/mutable_appearance/water_overlay
	var/mutable_appearance/fire_overlay

/mob/living/simple_animal/bot/hygienebot/Initialize()
	. = ..()
	update_icon()
	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/hygienebot/explode()
	walk_to(src,0)
	visible_message("<span class='boldannounce'>[src] blows apart in a foamy explosion!</span>")
	do_sparks(3, TRUE, src)
	on = FALSE
	new /obj/effect/particle_effect/foam(loc)

	..()

/mob/living/simple_animal/bot/hygienebot/Cross(atom/movable/AM)
	. = ..()
	if(washing)
		wash_atom(AM)

/mob/living/simple_animal/bot/hygienebot/Crossed(atom/movable/AM)
	. = ..()
	if(washing)
		wash_atom(AM)

/mob/living/simple_animal/bot/hygienebot/update_icon()
	cut_overlays()

	if(on)
		var/mutable_appearance/fire_overlay = mutable_appearance(icon,"flame")
		add_overlay(fire_overlay)
		icon_state = "drone-on"
	else
		icon_state = "drone"
	if(washing)
		var/mutable_appearance/water_overlay = mutable_appearance(icon, emagged ? "dronefire" : "dronewater")
		add_overlay(water_overlay)

/mob/living/simple_animal/bot/hygienebot/turn_off()
	..()
	mode = BOT_IDLE

/mob/living/simple_animal/bot/hygienebot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	walk_to(src,0)
	last_found = world.time


/mob/living/simple_animal/bot/hygienebot/Crossed(atom/movable/AM)
	. = ..()
	if(washing)
		wash_atom(AM)

/mob/living/simple_animal/bot/hygienebot/Moved()
	. = ..()
	if(washing && isturf(loc) && !emagged)
		var/turf/open/OT = loc
		OT.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

/mob/living/simple_animal/bot/hygienebot/handle_automated_action()
	if(!..())
		return

	if(washing)
		wash_atom(loc)
		for(var/AM in loc)
			wash_atom(AM)
		if(isopenturf(loc) && !emagged)
			var/turf/open/tile = loc
			tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

	switch(mode)
		if(BOT_IDLE)		// idle
			walk_to(src,0)
			look_for_lowhygiene()	// see if any disgusting fucks are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for stinkman
			// if can't reach stinkman for long enough, don't give up, try harder.
			if(emagged) //lol fuck em up
				currentspeed = 8
				start_washing()
				mad = TRUE
			else
				switch(frustration)
					if(0 to 4)
						currentspeed = 5
						stop_washing()
						mad = FALSE
					if(4 to INFINITY)
						currentspeed = 2.5
						start_washing()
						mad = TRUE
			if(target)
				if(target.loc == loc && isturf(target.loc)) //LADIES AND GENTLEMAN WE GOTEM PREPARE TO DUMP
					start_washing()
					if(mad)
						speak("Well about fucking time you degenerate", "Fucking finally", "Thank god, you finally stopped")
						playsound(loc, 'sound/effects/hygienebot_angry.ogg', 60, 1)
						mad = FALSE
					mode = BOT_SHOWERSTANCE
				else
					var/turf/olddist = get_dist(src, target)
					walk_to(src, target,0, currentspeed)
					if(mad && prob(60))
						playsound(loc, 'sound/effects/hygienebot_angry.ogg', 60, 1)
						speak(pick("Get back here you foul smelling fucker.", "If you don't get back here right now I'm going to give you a fucking vasectomy.", "STOP RUNNING OR I WILL CUT YOUR ARTERIES!", "Just fucking let me clean you you arsehole!", "STOP. RUNNING.", "Either you stop running or I will fucking drag you out of an airlock.", "I just want to fucking clean you you troglodyte.", "If you don't come back here I'll put a green cloud around you cunt."))
					if((get_dist(src, target)) >= (olddist))
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
			if(target.loc != loc && !isturf(target.loc))
				back_to_hunt()

		if(BOT_START_PATROL)
			look_for_lowhygiene()
			start_patrol()

		if(BOT_PATROL)
			look_for_lowhygiene()
			bot_patrol()

/mob/living/simple_animal/bot/hygienebot/proc/back_to_idle()
	mode = BOT_IDLE
	walk_to(src,0)
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
	update_icon()

/mob/living/simple_animal/bot/hygienebot/proc/stop_washing()
	washing = FALSE
	update_icon()



/mob/living/simple_animal/bot/hygienebot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>Hygienebot X2 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel is [open ? "opened" : "closed"]"},

"<A href='?src=[REF(src)];power=[TRUE]'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += text({"<BR> Auto Patrol: []"},

"<A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )
	return	dat

/mob/living/simple_animal/bot/hygienebot/proc/check_purity(mob/living/L)
	if(emagged && L.stat != DEAD)
		return FALSE

	var/obj/item/head = L.get_item_by_slot(ITEM_SLOT_HEAD)
	if(head)
		if(HAS_BLOOD_DNA(head))
			return FALSE

	var/obj/item/mask = L.get_item_by_slot(ITEM_SLOT_MASK)
	if(mask)
		if(HAS_BLOOD_DNA(mask))
			return FALSE

	var/obj/item/uniform = L.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	if(uniform)
		if(HAS_BLOOD_DNA(uniform))
			return FALSE

	var/obj/item/suit = L.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(suit)
		if(HAS_BLOOD_DNA(suit))
			return FALSE

	var/obj/item/feet = L.get_item_by_slot(ITEM_SLOT_FEET)
	if(feet)
		if(HAS_BLOOD_DNA(feet))
			return FALSE
	return TRUE

/mob/living/simple_animal/bot/hygienebot/proc/wash_atom(atom/A)
	SEND_SIGNAL(A, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	if(emagged)
		A.fire_act()
		return //lol pranked no cleaning besides that
	if(isobj(A))
		wash_obj(A)
	else if(isturf(A))
		wash_turf(A)
	else if(isliving(A))
		wash_mob(A)

	contamination_cleanse(A)

/mob/living/simple_animal/bot/hygienebot/proc/wash_obj(obj/O)
	. = SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)


/mob/living/simple_animal/bot/hygienebot/proc/wash_turf(turf/tile)
	SEND_SIGNAL(tile, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	tile.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	for(var/obj/effect/E in tile)
		if(is_cleanable(E))
			qdel(E)

/mob/living/simple_animal/bot/hygienebot/proc/wash_mob(mob/living/L)
	SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	L.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower)
	if(iscarbon(L))
		var/mob/living/carbon/M = L
		. = TRUE

		for(var/obj/item/I in M.held_items)
			wash_obj(I)

		if(M.back && wash_obj(M.back))
			M.update_inv_back(0)

		var/list/obscured = M.check_obscured_slots()

		if(M.head && wash_obj(M.head))
			M.update_inv_head()

		if(M.glasses && !(ITEM_SLOT_EYES in obscured) && wash_obj(M.glasses))
			M.update_inv_glasses()

		if(M.wear_mask && !(ITEM_SLOT_MASK in obscured) && wash_obj(M.wear_mask))
			M.update_inv_wear_mask()

		if(M.ears && !(HIDEEARS in obscured) && wash_obj(M.ears))
			M.update_inv_ears()

		if(M.wear_neck && !(ITEM_SLOT_NECK in obscured) && wash_obj(M.wear_neck))
			M.update_inv_neck()

		if(M.shoes && !(HIDESHOES in obscured) && wash_obj(M.shoes))
			M.update_inv_shoes()

		var/washgloves = FALSE
		if(M.gloves && !(HIDEGLOVES in obscured))
			washgloves = TRUE

		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_suit && wash_obj(H.wear_suit))
				H.update_inv_wear_suit()
			else if(H.w_uniform && wash_obj(H.w_uniform))
				H.update_inv_w_uniform()

			if(washgloves)
				SEND_SIGNAL(H, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

			if(!H.is_mouth_covered())
				H.lip_style = null
				H.update_body()

			if(H.belt && wash_obj(H.belt))
				H.update_inv_belt()
		else
			SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	else
		SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

/mob/living/simple_animal/bot/hygienebot/proc/contamination_cleanse(atom/thing)
	var/datum/component/radioactive/healthy_green_glow = thing.GetComponent(/datum/component/radioactive)
	if(!healthy_green_glow || QDELETED(healthy_green_glow))
		return
	var/strength = healthy_green_glow.strength
	if(strength <= RAD_BACKGROUND_RADIATION)
		qdel(healthy_green_glow)
		return
	healthy_green_glow.strength -= max(0, (healthy_green_glow.strength - (RAD_BACKGROUND_RADIATION * 2)) * 0.2)

/obj/machinery/bot_core/hygienebot
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)
