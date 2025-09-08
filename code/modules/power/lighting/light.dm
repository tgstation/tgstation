// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube"
	desc = "A lighting fixture."
	layer = WALL_OBJ_LAYER
	max_integrity = 100
	use_power = ACTIVE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	power_channel = AREA_USAGE_LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	always_area_sensitive = TRUE
	light_angle = 170
	///What overlay the light should use
	var/overlay_icon = 'icons/obj/lighting_overlay.dmi'
	///base description and icon_state
	var/base_state = "tube"
	///Is the light on?
	var/on = FALSE
	///Amount of power used
	var/static_power_used = 0
	///Luminosity when on, also used in power calculation
	var/brightness = 8
	///Basically the alpha of the emitted light source
	var/bulb_power = 1
	///Default colour of the light.
	var/bulb_colour = LIGHT_COLOR_DEFAULT
	///LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/status = LIGHT_OK
	///Should we flicker?
	var/flickering = FALSE
	///The type of light item
	var/light_type = /obj/item/light/tube
	///String of the light type, used in descriptions and in examine
	var/fitting = "tube"
	///Count of number of times switched on/off, this is used to calculate the probability the light burns out
	var/switchcount = 0
	///Cell reference
	var/obj/item/stock_parts/power_store/cell
	/// If TRUE, then cell is null, but one is pretending to exist.
	/// This is to defer emergency cell creation unless necessary, as it is very expensive.
	var/has_mock_cell = TRUE
	///If true, this fixture generates a very weak cell at roundstart
	var/start_with_cell = TRUE
	///Currently in night shift mode?
	var/nightshift_enabled = FALSE
	///Set to FALSE to never let this light get switched to night mode.
	var/nightshift_allowed = TRUE
	///Brightness of the nightshift light
	var/nightshift_brightness = 8
	///Alpha of the nightshift light
	var/nightshift_light_power = 0.45
	///Basecolor of the nightshift light
	var/nightshift_light_color = "#FFDDCC"
	///If true, the light is in low power mode
	var/low_power_mode = FALSE
	///If true, this light cannot ever be in low power mode
	var/no_low_power = FALSE
	///If true, overrides lights to use emergency lighting
	var/major_emergency = FALSE
	///Multiplier for this light's base brightness during a cascade
	var/bulb_major_emergency_brightness_mul = 0.75
	///Colour of the light when major emergency mode is on
	var/bulb_emergency_colour = "#ff4e4e"
	///Multiplier for this light's base brightness in low power power mode
	var/bulb_low_power_brightness_mul = 0.25
	///Determines the colour of the light while it's in low power mode
	var/bulb_low_power_colour = COLOR_VIVID_RED
	///The multiplier for determining the light's power in low power mode
	var/bulb_low_power_pow_mul = 0.75
	///The minimum value for the light's power in low power mode
	var/bulb_low_power_pow_min = 0.5
	///The Light range to use when working in fire alarm status
	var/fire_brightness = 9
	///The Light power to use when working in fire alarm status
	var/fire_power = 0.5
	///The Light colour to use when working in fire alarm status
	var/fire_colour = COLOR_FIRE_LIGHT_RED
	///Power usage - W per unit of luminosity
	var/power_consumption_rate = 20
	///break if moved, if false also makes it ignore if the wall its on breaks
	var/break_if_moved = TRUE

/obj/machinery/light/Move()
	if(status != LIGHT_BROKEN && break_if_moved)
		break_light_tube(TRUE)
	return ..()

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload)
	. = ..()

	// Detect and scream about double stacked lights
	if(PERFORM_ALL_TESTS(focus_only/stacked_lights))
		var/turf/our_location = get_turf(src)
		for(var/obj/machinery/light/on_turf in our_location)
			if(on_turf == src)
				continue
			if(on_turf.dir != dir)
				continue
			stack_trace("Conflicting double stacked light [on_turf.type] found at [get_area(our_location)] ([our_location.x],[our_location.y],[our_location.z])")
			qdel(on_turf)

	if(!mapload) //sync up nightshift lighting for player made lights
		var/area/our_area = get_room_area()
		var/obj/machinery/power/apc/temp_apc = our_area.apc
		nightshift_enabled = temp_apc?.nightshift_lights

	if(!start_with_cell || no_low_power)
		has_mock_cell = FALSE

	if(is_station_level(z))
		RegisterSignal(SSdcs, COMSIG_GLOB_GREY_TIDE_LIGHT, PROC_REF(grey_tide)) //Only put the signal on station lights

	// Light projects out backwards from the dir of the light
	set_light(l_dir = REVERSE_DIR(dir))
	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	AddElement(/datum/element/atmos_sensitive, mapload)
	AddElement(/datum/element/contextual_screentip_bare_hands, rmb_text = "Remove bulb")
	if(break_if_moved)
		find_and_hang_on_wall(custom_drop_callback = CALLBACK(src, PROC_REF(knock_down)))

/obj/machinery/light/post_machine_initialize()
	. = ..()
#ifndef MAP_TEST
	switch(fitting)
		if("tube")
			if(prob(2))
				break_light_tube(TRUE)
		if("bulb")
			if(prob(5))
				break_light_tube(TRUE)
#endif
	update(trigger = FALSE)

/obj/machinery/light/Destroy()
	var/area/local_area = get_room_area()
	if(local_area)
		on = FALSE
	QDEL_NULL(cell)
	return ..()

/obj/machinery/light/setDir(newdir)
	. = ..()
	set_light(l_dir = REVERSE_DIR(dir))

// If we're adjacent to the source, we make this sorta indentation for our light to ensure it stays lit (and to make distances look right)
// By shifting the light position we use forward a bit, towards something that isn't off by 0.5 from being in angle
// Because angle calculation is kinda harsh it's hard to find a happy point between fulldark and fullbright for the corners behind the light. this is good enough tho
/obj/machinery/light/get_light_offset()
	var/list/hand_back = ..()
	var/list/dir_offset = dir2offset(REVERSE_DIR(dir))
	hand_back[1] += dir_offset[1] * 0.5
	hand_back[2] += dir_offset[2] * 0.5
	return hand_back

/obj/machinery/light/update_icon_state()
	switch(status) // set icon_states
		if(LIGHT_OK)
			var/area/local_area = get_room_area()
			if(low_power_mode || major_emergency || (local_area?.fire))
				icon_state = "[base_state]_emergency"
			else
				icon_state = "[base_state]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
	return ..()

/obj/machinery/light/update_overlays()
	. = ..()
	if(!on || status != LIGHT_OK)
		return

	. += emissive_appearance(overlay_icon, "[base_state]", src, alpha = src.alpha)

	var/area/local_area = get_room_area()

	if(flickering)
		. += mutable_appearance(overlay_icon, "[base_state]_flickering")
		return
	if(low_power_mode || major_emergency || (local_area?.fire))
		. += mutable_appearance(overlay_icon, "[base_state]_emergency")
		return
	if(nightshift_enabled)
		. += mutable_appearance(overlay_icon, "[base_state]_nightshift")
		return
	. += mutable_appearance(overlay_icon, base_state)

// Area sensitivity is traditionally tied directly to power use, as an optimization
// But since we want it for fire reacting, we disregard that
/obj/machinery/light/setup_area_power_relationship()
	. = ..()
	if(!.)
		return
	var/area/our_area = get_room_area()
	RegisterSignal(our_area, COMSIG_AREA_FIRE_CHANGED, PROC_REF(handle_fire))

/obj/machinery/light/on_enter_area(datum/source, area/area_to_register)
	..()
	RegisterSignal(area_to_register, COMSIG_AREA_FIRE_CHANGED, PROC_REF(handle_fire))
	handle_fire(area_to_register, area_to_register.fire)

/obj/machinery/light/on_exit_area(datum/source, area/area_to_unregister)
	..()
	UnregisterSignal(area_to_unregister, COMSIG_AREA_FIRE_CHANGED)

/obj/machinery/light/proc/handle_fire(area/source, new_fire)
	SIGNAL_HANDLER
	update()

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = TRUE)
	switch(status)
		if(LIGHT_BROKEN,LIGHT_BURNED,LIGHT_EMPTY)
			on = FALSE
	low_power_mode = FALSE
	if(on)
		var/brightness_set = brightness
		var/power_set = bulb_power
		var/color_set = bulb_colour
		if(color)
			color_set = color
		if(reagents)
			START_PROCESSING(SSmachines, src)
		var/area/local_area = get_room_area()
		if (flickering)
			brightness_set = brightness * bulb_low_power_brightness_mul
			power_set = bulb_low_power_pow_mul
			color_set = nightshift_light_color
		else if (local_area?.fire)
			color_set = fire_colour
			power_set = fire_power
			brightness_set = fire_brightness
		else if (major_emergency)
			color_set = bulb_emergency_colour
			brightness_set = brightness * bulb_major_emergency_brightness_mul
		else if (nightshift_enabled)
			brightness_set = nightshift_brightness
			power_set = nightshift_light_power
			if(!color)
				color_set = nightshift_light_color
		if (cached_color_filter)
			color_set = apply_matrix_to_color(color_set, cached_color_filter["color"], cached_color_filter["space"] || COLORSPACE_RGB)
		var/matching = light && brightness_set == light.light_range && power_set == light.light_power && color_set == light.light_color
		if(!matching)
			switchcount++
			if( prob( min(60, (switchcount**2)*0.01) ) )
				if(trigger)
					burn_out()
			else
				use_power = ACTIVE_POWER_USE
				set_light(
					l_range = brightness_set,
					l_power = power_set,
					l_color = color_set
					)
	else if(has_emergency_power(LIGHT_EMERGENCY_POWER_USE) && !turned_off())
		use_power = IDLE_POWER_USE
		low_power_mode = TRUE
		START_PROCESSING(SSmachines, src)
	else
		use_power = IDLE_POWER_USE
		set_light(l_range = 0)
	update_appearance()
	update_current_power_usage()
	broken_sparks(start_only=TRUE)

/obj/machinery/light/update_current_power_usage()
	if(!on && static_power_used > 0) //Light is off but still powered
		removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
		static_power_used = 0
	else if(on) //Light is on, just recalculate usage
		var/static_power_used_new = 0
		var/area/local_area = get_room_area()
		if (nightshift_enabled && !local_area?.fire)
			static_power_used_new = nightshift_brightness * nightshift_light_power * power_consumption_rate
		else
			static_power_used_new = brightness * bulb_power * power_consumption_rate
		if(static_power_used != static_power_used_new) //Consumption changed - update
			removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
			static_power_used = static_power_used_new
			addStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)

/obj/machinery/light/update_atom_colour()
	..()
	update()

/obj/machinery/light/proc/broken_sparks(start_only=FALSE)
	if(!QDELETED(src) && status == LIGHT_BROKEN && has_power() && MC_RUNNING())
		if(!start_only)
			do_sparks(3, TRUE, src)
		var/delay = rand(BROKEN_SPARKS_MIN, BROKEN_SPARKS_MAX)
		addtimer(CALLBACK(src, PROC_REF(broken_sparks)), delay, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)

/obj/machinery/light/proc/is_full_charge()
	if(cell)
		return cell.charge == cell.maxcharge
	return TRUE

/obj/machinery/light/process(seconds_per_tick)
	if(has_power())
		// If the cell is done mooching station power, and reagents don't need processing, stop processing
		if(is_full_charge() && !reagents)
			return PROCESS_KILL
		if(cell)
			charge_cell(LIGHT_EMERGENCY_POWER_USE * seconds_per_tick, cell = cell) //Recharge emergency power automatically while not using it
	if(reagents) //with most reagents coming out at 300, and with most meaningful reactions coming at 370+, this rate gives a few seconds of time to place it in and get out of dodge regardless of input.
		reagents.adjust_thermal_energy(8 * reagents.total_volume * SPECIFIC_HEAT_DEFAULT * seconds_per_tick)
		reagents.handle_reactions()
	if(low_power_mode && !use_emergency_power(LIGHT_EMERGENCY_POWER_USE * seconds_per_tick))
		update(FALSE) //Disables emergency mode and sets the color to normal

/obj/machinery/light/proc/burn_out()
	if(status == LIGHT_OK)
		status = LIGHT_BURNED
		icon_state = "[base_state]-burned"
		on = FALSE
		set_light(l_range = 0)

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/set_on(turn_on)
	on = (turn_on && status == LIGHT_OK)
	update()

/obj/machinery/light/get_cell()
	if (has_mock_cell)
		cell = new /obj/item/stock_parts/power_store/cell/emergency_light(src)
		has_mock_cell = FALSE

	return cell

// examine verb
/obj/machinery/light/examine(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_OK)
			. += span_notice("It is turned [on? "on" : "off"].")
		if(LIGHT_EMPTY)
			. +=  span_notice("The [fitting] has been removed.")
		if(LIGHT_BURNED)
			. +=  span_danger("The [fitting] is burnt out.")
		if(LIGHT_BROKEN)
			. += span_danger("The [fitting] has been smashed.")
	if(cell || has_mock_cell)
		. +=  span_notice("Its backup power charge meter reads [has_mock_cell ? 100 : round((cell.charge / cell.maxcharge) * 100, 0.1)]%.")



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/tool, mob/living/user, list/modifiers, list/attack_modifiers)
	// attempt to insert light
	if(istype(tool, /obj/item/light))
		if(status == LIGHT_OK)
			to_chat(user, span_warning("There is a [fitting] already inserted!"))
			return
		add_fingerprint(user)
		var/obj/item/light/light_object = tool
		if(!istype(light_object, light_type))
			to_chat(user, span_warning("This type of light requires a [fitting]!"))
			return
		if(!user.temporarilyRemoveItemFromInventory(light_object))
			return

		add_fingerprint(user)
		if(status != LIGHT_EMPTY)
			drop_light_tube(user)
			to_chat(user, span_notice("You replace [light_object]."))
		else
			to_chat(user, span_notice("You insert [light_object]."))
		if(length(light_object.reagents.reagent_list))
			create_reagents(LIGHT_REAGENT_CAPACITY, SEALED_CONTAINER | TRANSPARENT)
			light_object.reagents.trans_to(reagents, LIGHT_REAGENT_CAPACITY)
		status = light_object.status
		switchcount = light_object.switchcount
		brightness = light_object.brightness
		on = has_power()
		update()

		qdel(light_object)

		return

	// attempt to stick weapon into light socket
	if(status != LIGHT_EMPTY)
		return ..()
	if(tool.tool_behaviour == TOOL_SCREWDRIVER) //If it's a screwdriver open it.
		tool.play_tool_sound(src, 75)
		user.visible_message(span_notice("[user.name] opens [src]'s casing."), \
			span_notice("You open [src]'s casing."), span_hear("You hear a noise."))
		deconstruct()
		return

	if(tool.item_flags & ABSTRACT)
		return

	to_chat(user, span_userdanger("You stick \the [tool] into the light socket!"))
	if(has_power() && (tool.obj_flags & CONDUCTS_ELECTRICITY))
		do_sparks(3, TRUE, src)
		if (prob(75))
			electrocute_mob(user, get_area(src), src, (rand(7,10) * 0.1), TRUE)

/obj/machinery/light/on_deconstruction(disassembled)
	var/obj/structure/light_construct/new_light = null
	var/current_stage = 2
	if(!disassembled)
		current_stage = 1
	switch(fitting)
		if("tube")
			new_light = new /obj/structure/light_construct(loc)
			new_light.icon_state = "tube-construct-stage[current_stage]"

		if("bulb")
			new_light = new /obj/structure/light_construct/small(loc)
			new_light.icon_state = "bulb-construct-stage[current_stage]"
	new_light.setDir(dir)
	new_light.stage = current_stage
	if(!disassembled)
		new_light.take_damage(new_light.max_integrity * 0.5, sound_effect=FALSE)
		if(status != LIGHT_BROKEN)
			break_light_tube()
		if(status != LIGHT_EMPTY)
			drop_light_tube()
		new /obj/item/stack/cable_coil(loc, 1, "red")
	transfer_fingerprints_to(new_light)

	var/obj/item/stock_parts/power_store/real_cell = get_cell()
	if(!QDELETED(real_cell))
		new_light.cell = real_cell
		real_cell.forceMove(new_light)
		cell = null

/obj/machinery/light/attacked_by(obj/item/attacking_object, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. <= 0)
		return
	if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)
		return
	if(!on || !(attacking_object.obj_flags & CONDUCTS_ELECTRICITY))
		return
	if(!prob(12))
		return
	electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/items/weapons/smash.ogg', 50, TRUE)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, TRUE)
				else
					playsound(loc, 'sound/effects/glass/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/tools/welder.ogg', 100, TRUE)

// returns if the light has power /but/ is manually turned off
// if a light is turned off, it won't activate emergency power
/obj/machinery/light/proc/turned_off()
	var/area/local_area = get_room_area()
	return !local_area.lightswitch && local_area.power_light || flickering

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/local_area = get_room_area()
	return local_area.lightswitch && local_area.power_light

// returns whether this light has emergency power
// can also return if it has access to a certain amount of that power
/obj/machinery/light/proc/has_emergency_power(power_usage_amount)
	if(no_low_power || (!cell && !has_mock_cell))
		return FALSE
	if (has_mock_cell)
		return status == LIGHT_OK
	if(power_usage_amount ? cell.charge >= power_usage_amount : cell.charge)
		return status == LIGHT_OK
	return FALSE

// attempts to use power from the installed emergency cell, returns true if it does and false if it doesn't
/obj/machinery/light/proc/use_emergency_power(power_usage_amount = LIGHT_EMERGENCY_POWER_USE)
	if(!has_emergency_power(power_usage_amount))
		return FALSE
	var/obj/item/stock_parts/power_store/real_cell = get_cell()
	if(real_cell.charge > 2.5 * /obj/item/stock_parts/power_store/cell/emergency_light::maxcharge) //it's meant to handle 120 W, ya doofus
		visible_message(span_warning("[src] short-circuits from too powerful of a power cell!"))
		burn_out()
		return FALSE
	real_cell.use(power_usage_amount)
	set_light(
		l_range = brightness * bulb_low_power_brightness_mul,
		l_power = max(bulb_low_power_pow_min, bulb_low_power_pow_mul * (real_cell.charge / real_cell.maxcharge)),
		l_color = bulb_low_power_colour
		)
	return TRUE

/obj/machinery/light/proc/flicker(amount = 1)
	set waitfor = FALSE
	if(flickering || !on || status != LIGHT_OK)
		return

	. = TRUE // did we actually flicker? Send this now because we expect immediate response, before sleeping.
	set_light(
		l_range = brightness * bulb_low_power_brightness_mul,
		l_power = bulb_low_power_pow_mul,
		l_color = nightshift_light_color,
	)
	cut_overlays(src)
	stoplag(0.7 SECONDS)
	if(prob(30))
		do_sparks(number = 2, cardinal_only = TRUE, source = src)

	for(var/i in 1 to amount)
		if(status != LIGHT_OK || !has_power())
			break
		flickering = !flickering
		update(FALSE)
		stoplag(pick(list(2 SECONDS, 4 SECONDS, 6 SECONDS)))

	if(has_power())
		on = (status == LIGHT_OK)
	else
		on = FALSE

	flickering = FALSE
	update(FALSE)

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	no_low_power = !no_low_power
	to_chat(user, span_notice("Emergency lights for this fixture have been [no_low_power ? "disabled" : "enabled"]."))
	update(FALSE)
	return

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand_secondary(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, span_warning("There is no [fitting] in this light!"))
		return

	// make it burn hands unless you're wearing heat insulated gloves or have the RESISTHEAT/RESISTHEATHANDS traits
	if(!on)
		to_chat(user, span_notice("You remove the light [fitting]."))
		// create a light tube/bulb item and put it in the user's hand
		drop_light_tube(user)
		return

	var/protected = FALSE

	if(istype(user))
		var/obj/item/organ/stomach/maybe_stomach = user.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(istype(maybe_stomach, /obj/item/organ/stomach/ethereal))
			var/obj/item/organ/stomach/ethereal/stomach = maybe_stomach
			if(stomach.drain_time > world.time)
				return
			to_chat(user, span_notice("You start channeling some power through the [fitting] into your body."))
			stomach.drain_time = world.time + LIGHT_DRAIN_TIME
			while(do_after(user, LIGHT_DRAIN_TIME, target = src))
				stomach.drain_time = world.time + LIGHT_DRAIN_TIME
				if(istype(stomach))
					to_chat(user, span_notice("You receive some charge from the [fitting]."))
					stomach.adjust_charge(LIGHT_POWER_GAIN)
				else
					to_chat(user, span_warning("You can't receive charge from the [fitting]!"))
			return

		if(user.gloves)
			var/obj/item/clothing/gloves/electrician_gloves = user.gloves
			if(electrician_gloves.max_heat_protection_temperature && electrician_gloves.max_heat_protection_temperature > 360)
				protected = TRUE
	else
		protected = TRUE

	if(protected || HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
		to_chat(user, span_notice("You remove the light [fitting]."))
	else if(istype(user) && user.dna.check_mutation(/datum/mutation/telekinesis))
		to_chat(user, span_notice("You telekinetically remove the light [fitting]."))
	else
		var/obj/item/bodypart/affecting = user.get_active_hand()
		user.apply_damage(5, BURN, affecting, wound_bonus = CANT_WOUND)
		if(HAS_TRAIT(user, TRAIT_LIGHTBULB_REMOVER))
			to_chat(user, span_notice("You feel your [affecting.plaintext_zone] burning, but the light begins to budge..."))
			if(!do_after(user, 5 SECONDS, target = src))
				return
			user.apply_damage(10, BURN, user.get_active_hand(), wound_bonus = CANT_WOUND)
			to_chat(user, span_notice("You manage to remove the light [fitting], shattering it in process."))
			break_light_tube()
		else
			to_chat(user, span_warning("You try to remove the light [fitting], but you burn your hand on it!"))
			return
	// create a light tube/bulb item and put it in the user's hand
	drop_light_tube(user)

/obj/machinery/light/proc/set_major_emergency_light()
	major_emergency = TRUE
	update()

/obj/machinery/light/proc/unset_major_emergency_light()
	major_emergency = FALSE
	update()

/obj/machinery/light/proc/drop_light_tube(mob/user)
	var/obj/item/light/light_object = new light_type()
	if(reagents)
		reagents.trans_to(light_object.reagents, LIGHT_REAGENT_CAPACITY)
		QDEL_NULL(reagents)
	light_object.status = status
	light_object.brightness = brightness

	// light item inherits the switchcount, then zero it
	light_object.switchcount = switchcount
	switchcount = 0

	light_object.update_appearance()
	light_object.forceMove(loc)

	if(user) //puts it in our active hand
		light_object.add_fingerprint(user)
		user.put_in_active_hand(light_object)

	status = LIGHT_EMPTY
	update()
	return light_object

/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, span_warning("There is no [fitting] in this light!"))
		return

	to_chat(user, span_notice("You telekinetically remove the light [fitting]."))
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/light_tube = drop_light_tube()
	return light_tube.attack_tk(user)

// break the light and make sparks if was on
/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = FALSE)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(loc, 'sound/effects/glass/glasshit.ogg', 75, TRUE)
		if(on)
			do_sparks(3, TRUE, src)
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	brightness = initial(brightness)
	on = TRUE
	update()

/obj/machinery/light/zap_act(power, zap_flags)
	var/explosive = zap_flags & ZAP_MACHINE_EXPLOSIVE
	zap_flags &= ~(ZAP_MACHINE_EXPLOSIVE | ZAP_OBJ_DAMAGE)
	. = ..()
	if(explosive)
		explosion(src, flame_range = 5, adminlog = FALSE)
		qdel(src)

// called when area power state changes
/obj/machinery/light/power_change()
	SHOULD_CALL_PARENT(FALSE)
	var/area/local_area = get_room_area()
	set_on(local_area.lightswitch && local_area.power_light)

// called when heated

/obj/machinery/light/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 673

/obj/machinery/light/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		break_light_tube()

/obj/machinery/light/proc/on_light_eater(obj/machinery/light/source, datum/light_eater)
	SIGNAL_HANDLER
	break_light_tube()
	return COMPONENT_BLOCK_LIGHT_EATER

/obj/machinery/light/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	break_light_tube()
	return TRUE

/obj/machinery/light/proc/grey_tide(datum/source, list/grey_tide_areas)
	SIGNAL_HANDLER

	for(var/area_type in grey_tide_areas)
		if(!istype(get_area(src), area_type))
			continue
		INVOKE_ASYNC(src, PROC_REF(flicker))

/**
 * All the effects that occur when a light falls off a wall that it was hung onto.
 */
/obj/machinery/light/proc/knock_down()
	if (fitting == "bulb")
		new /obj/item/wallframe/light_fixture/small(drop_location())
	else
		new /obj/item/wallframe/light_fixture(drop_location())
	new /obj/item/stack/cable_coil(drop_location(), 1, "red")
	if(status != LIGHT_BROKEN)
		break_light_tube(FALSE)
	if(status != LIGHT_EMPTY)
		drop_light_tube()
	if(cell)
		cell.forceMove(drop_location())
	qdel(src)

/obj/machinery/light/floor
	name = "floor light"
	desc = "A lightbulb you can walk on without breaking it, amazing."
	icon = 'icons/obj/lighting.dmi'
	base_state = "floor" // base description and icon_state
	icon_state = "floor"
	brightness = 4
	light_angle = 360
	layer = BELOW_CATWALK_LAYER
	plane = FLOOR_PLANE
	light_type = /obj/item/light/bulb
	fitting = "bulb"
	nightshift_brightness = 4
	fire_brightness = 4.5

/obj/machinery/light/floor/get_light_offset()
	return list(0, 0)

/obj/machinery/light/floor/broken
	status = LIGHT_BROKEN
	icon_state = "floor-broken"

/obj/machinery/light/floor/transport
	name = "transport light"
	break_if_moved = FALSE
	// has to render above tram things (trams are stupid)
	layer = BELOW_OPEN_DOOR_LAYER
	plane = GAME_PLANE
