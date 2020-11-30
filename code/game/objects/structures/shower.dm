#define SHOWER_FREEZING "freezing"
#define SHOWER_FREEZING_TEMP 100
#define SHOWER_NORMAL "normal"
#define SHOWER_NORMAL_TEMP 300
#define SHOWER_BOILING "boiling"
#define SHOWER_BOILING_TEMP 400
#define SHOWER_REACTION_MULTIPLIER 0.05


/obj/machinery/shower
	name = "shower"
	desc = "The HS-452. Installed in the 2550s by the Nanotrasen Hygiene Division, now with 2560 lead compliance! Passively replenishes itself with water when not in use."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	use_power = NO_POWER_USE
	///Is the shower on or off?
	var/on = FALSE
	///What temperature the shower reagents are set to.
	var/current_temperature = SHOWER_NORMAL
	///What sound will be played on loop when the shower is on and pouring water.
	var/datum/looping_sound/showering/soundloop
	///What reagent should the shower be filled with when initially built.
	var/reagent_id = /datum/reagent/water
	///How much reagent capacity should the shower begin with when built.
	var/reaction_volume = 200

/obj/machinery/shower/Initialize()
	. = ..()
	create_reagents(reaction_volume)
	reagents.add_reagent(reagent_id, reaction_volume)
	soundloop = new(list(src), FALSE)
	AddComponent(/datum/component/plumbing/simple_demand)

/obj/machinery/shower/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[reagents.total_volume]/[reagents.maximum_volume] liquids remaining.</span>"

/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(reagents)
	return ..()

/obj/machinery/shower/interact(mob/M)
	if(reagents.total_volume < 5)
		to_chat(M,"<span class='notice'>\The [src] is dry.</span>")
		return FALSE
	on = !on
	update_icon()
	handle_mist()
	add_fingerprint(M)
	if(on)
		START_PROCESSING(SSmachines, src)
		process(SSMACHINES_DT)
		soundloop.start()
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
	..()
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
		user.log_message("has wrenched a shower at [AREACOORD(src)] to [current_temperature].", LOG_ATTACK)
		add_hiddenprint(user)
	handle_mist()
	return TRUE


/obj/machinery/shower/update_overlays()
	. = ..()
	if(on)
		var/mutable_appearance/water_falling = mutable_appearance('icons/obj/watercloset.dmi', "water", ABOVE_MOB_LAYER)
		water_falling.color = mix_color_from_reagents(reagents.reagent_list)
		. += water_falling

/obj/machinery/shower/proc/handle_mist()
	// If there is no mist, and the shower was turned on (on a non-freezing temp): make mist in 5 seconds
	// If there was already mist, and the shower was turned off (or made cold): remove the existing mist in 25 sec
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		addtimer(CALLBACK(src, .proc/make_mist), 5 SECONDS)

	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		addtimer(CALLBACK(src, .proc/clear_mist), 25 SECONDS)

/obj/machinery/shower/proc/make_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		var/obj/effect/mist/new_mist = new /obj/effect/mist(loc)
		new_mist.color = mix_color_from_reagents(reagents.reagent_list)

/obj/machinery/shower/proc/clear_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		qdel(mist)


/obj/machinery/shower/Crossed(atom/movable/AM)
	..()
	if(on)
		wash_atom(AM)

/obj/machinery/shower/proc/wash_atom(atom/A)
	A.wash(CLEAN_RAD | CLEAN_TYPE_WEAK) // Clean radiation non-instantly
	A.wash(CLEAN_WASH)
	SEND_SIGNAL(A, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower)
	reagents.expose(A, TOUCH)
	if(isliving(A))
		check_heat(A)

/obj/machinery/shower/process()
	if(on && reagents.total_volume >= 5)
		reagents.remove_any(5)
		wash_atom(loc)
		for(var/am in loc)
			var/atom/movable/movable_content = am
			reagents.expose(movable_content, TOUCH, SHOWER_REACTION_MULTIPLIER) //There's not many reagents leaving the sink at once! This should make for a 10 unit reaction
			if(!ismopable(movable_content)) // Mopables will be cleaned anyways by the turf wash above
				wash_atom(movable_content)
	else
		reagents.add_reagent(reagent_id, 1)
		on = FALSE
		soundloop.stop()
		handle_mist()
		update_icon()
	if(reagents.total_volume == reagents.maximum_volume)
		return PROCESS_KILL

/obj/machinery/shower/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 3)
	qdel(src)

/obj/machinery/shower/proc/check_heat(mob/living/L)
	var/mob/living/carbon/C = L

	if(current_temperature == SHOWER_FREEZING)
		if(iscarbon(L))
			C.adjust_bodytemperature(-80, 80)
		to_chat(L, "<span class='warning'>[src] is freezing!</span>")
	else if(current_temperature == SHOWER_BOILING)
		if(iscarbon(L))
			C.adjust_bodytemperature(35, 0, 500)
		L.adjustFireLoss(5)
		to_chat(L, "<span class='danger'>[src] is searing!</span>")


/obj/structure/showerframe
	name = "shower frame"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower_frame"
	desc = "A shower frame, that needs a water recycler to finish construction."
	anchored = FALSE

/obj/structure/showerframe/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stock_parts/water_recycler))
		qdel(I)
		var/obj/machinery/shower/new_shower = new /obj/machinery/shower(loc)
		new_shower.setDir(dir)
		qdel(src)
		return
	return ..()

/obj/structure/showerframe/Initialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, .proc/can_be_rotated))

/obj/structure/showerframe/proc/can_be_rotated(mob/user, rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
	return !anchored

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

#undef SHOWER_REACTION_MULTIPLIER
