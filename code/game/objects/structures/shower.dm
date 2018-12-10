#define SHOWER_FREEZING "freezing"
#define SHOWER_NORMAL "normal"
#define SHOWER_BOILING "boiling"

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	use_power = NO_POWER_USE
	var/on = FALSE
	var/current_temperature = SHOWER_NORMAL
	var/datum/looping_sound/showering/soundloop

/obj/machinery/shower/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE)

/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/shower/interact(mob/M)
	on = !on
	update_icon()
	handle_mist()
	add_fingerprint(M)
	if(on)
		START_PROCESSING(SSmachines, src)
		soundloop.start()
		wash_turf()
		for(var/atom/movable/G in loc)
			SEND_SIGNAL(G, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
			if(isliving(G))
				var/mob/living/L = G
				wash_mob(L)
			else if(isobj(G)) // Skip the light objects
				wash_obj(G)
	else
		soundloop.stop()
		if(isopenturf(loc))
			var/turf/open/tile = loc
			tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 5 SECONDS, wet_time_to_add = 1 SECONDS)

/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, "<span class='notice'>The water temperature seems to be [current_temperature].</span>")
	else
		return ..()

/obj/machinery/shower/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to adjust the temperature valve with \the [I]...</span>")
	if(I.use_tool(src, user, 50))
		switch(current_temperature)
			if(SHOWER_NORMAL)
				current_temperature = SHOWER_FREEZING
			if(SHOWER_FREEZING)
				current_temperature = SHOWER_BOILING
			if(SHOWER_BOILING)
				current_temperature = SHOWER_NORMAL
		user.visible_message("<span class='notice'>[user] adjusts the shower with \the [I].</span>", "<span class='notice'>You adjust the shower with \the [I] to [current_temperature] temperature.</span>")
		log_game("[key_name(user)] has wrenched a shower to [current_temperature] at ([x],[y],[z])")
		add_hiddenprint(user)
	handle_mist()
	return TRUE


/obj/machinery/shower/update_icon()
	cut_overlays()

	if(on)
		add_overlay(mutable_appearance('icons/obj/watercloset.dmi', "water", ABOVE_MOB_LAYER))

/obj/machinery/shower/proc/handle_mist()
	// If there is no mist, and the shower was turned on (on a non-freezing temp): make mist in 5 seconds
	// If there was already mist, and the shower was turned off (or made cold): remove the existing mist in 25 sec
	var/obj/effect/mist/mist = locate() in loc
	if(on && !mist && current_temperature != SHOWER_FREEZING)
		addtimer(CALLBACK(src, .proc/make_mist), 5 SECONDS)

	if(!on && mist)
		addtimer(CALLBACK(src, .proc/clear_mist), 25 SECONDS)

/obj/machinery/shower/proc/make_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		new /obj/effect/mist(loc)

/obj/machinery/shower/proc/clear_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		qdel(mist)


/obj/machinery/shower/Crossed(atom/movable/AM)
	..()
	if(on)
		if(isliving(AM))
			var/mob/living/L = AM
			wash_mob(L)
			check_heat(L)

			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.slip(80, null, NO_SLIP_WHEN_WALKING)

		else if(isobj(AM))
			wash_obj(AM)


/obj/machinery/shower/proc/wash_obj(obj/O)
	. = SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	if(isitem(O))
		var/obj/item/I = O
		I.acid_level = 0
		I.extinguish()


/obj/machinery/shower/proc/wash_turf()
	if(isturf(loc))
		var/turf/tile = loc
		SEND_SIGNAL(tile, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
		tile.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		for(var/obj/effect/E in tile)
			if(is_cleanable(E))
				qdel(E)


/obj/machinery/shower/proc/wash_mob(mob/living/L)
	SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	L.wash_cream()
	L.ExtinguishMob()
	L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily
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

		if(M.glasses && !(SLOT_GLASSES in obscured) && wash_obj(M.glasses))
			M.update_inv_glasses()

		if(M.wear_mask && !(SLOT_WEAR_MASK in obscured) && wash_obj(M.wear_mask))
			M.update_inv_wear_mask()

		if(M.ears && !(HIDEEARS in obscured) && wash_obj(M.ears))
			M.update_inv_ears()

		if(M.wear_neck && !(SLOT_NECK in obscured) && wash_obj(M.wear_neck))
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

/obj/machinery/shower/proc/contamination_cleanse(atom/movable/thing)
	var/datum/component/radioactive/healthy_green_glow = thing.GetComponent(/datum/component/radioactive)
	if(!healthy_green_glow || QDELETED(healthy_green_glow))
		return
	var/strength = healthy_green_glow.strength
	if(strength <= RAD_BACKGROUND_RADIATION)
		qdel(healthy_green_glow)
		return
	healthy_green_glow.strength -= max(0, (healthy_green_glow.strength - (RAD_BACKGROUND_RADIATION * 2)) * 0.2)

/obj/machinery/shower/process()
	if(on)
		wash_turf()
		for(var/atom/movable/AM in loc)
			if(isliving(AM))
				wash_mob(AM)
			else if(isobj(AM))
				wash_obj(AM)
			contamination_cleanse(AM)
	else
		return PROCESS_KILL

/obj/machinery/shower/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(loc, 3)
	qdel(src)

/obj/machinery/shower/proc/check_heat(mob/living/L)
	var/mob/living/carbon/C = L

	if(current_temperature == SHOWER_FREEZING)
		if(iscarbon(L))
			C.adjust_bodytemperature(-80, 80)
		to_chat(L, "<span class='warning'>The water is freezing!</span>")
	else if(current_temperature == SHOWER_BOILING)
		if(iscarbon(L))
			C.adjust_bodytemperature(35, 0, 500)
		L.adjustFireLoss(5)
		to_chat(L, "<span class='danger'>The water is searing!</span>")

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
