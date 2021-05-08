// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/light)

#define LIGHT_EMERGENCY_POWER_USE 0.2 //How much power emergency lights will consume per tick
// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

#define BROKEN_SPARKS_MIN (3 MINUTES)
#define BROKEN_SPARKS_MAX (9 MINUTES)

#define LIGHT_DRAIN_TIME 25
#define LIGHT_POWER_GAIN 35

//How many reagents the lights can hold
#define LIGHT_REAGENT_CAPACITY 5

/obj/item/wallframe/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	result_path = /obj/structure/light_construct
	inverse = TRUE

/obj/item/wallframe/light_fixture/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-item"
	result_path = /obj/structure/light_construct/small
	custom_materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT)

/obj/item/wallframe/light_fixture/try_build(turf/on_wall, user)
	if(!..())
		return
	var/area/A = get_area(user)
	if(!IS_DYNAMIC_LIGHTING(A))
		to_chat(user, "<span class='warning'>You cannot place [src] in this area!</span>")
		return
	return TRUE


/obj/structure/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 200
	armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 50)

	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null
	var/obj/item/stock_parts/cell/cell

	var/cell_connectors = TRUE

/obj/structure/light_construct/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)

/obj/structure/light_construct/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/structure/light_construct/get_cell()
	return cell

/obj/structure/light_construct/examine(mob/user)
	. = ..()
	switch(stage)
		if(1)
			. += "It's an empty frame."
		if(2)
			. += "It's wired."
		if(3)
			. += "The casing is closed."
	if(cell_connectors)
		if(cell)
			. += "You see [cell] inside the casing."
		else
			. += "The casing has no power cell for backup power."
	else
		. += "<span class='danger'>This casing doesn't support power cells for backup power.</span>"

/obj/structure/light_construct/attack_hand(mob/user, list/modifiers)
	if(cell)
		user.visible_message("<span class='notice'>[user] removes [cell] from [src]!</span>", "<span class='notice'>You remove [cell].</span>")
		user.put_in_hands(cell)
		cell.update_icon()
		cell = null
		add_fingerprint(user)


/obj/structure/light_construct/attack_tk(mob/user)
	if(!cell)
		return
	to_chat(user, "<span class='notice'>You telekinetically remove [cell].</span>")
	var/obj/item/stock_parts/cell/cell_reference = cell
	cell = null
	cell_reference.forceMove(drop_location())
	return cell_reference.attack_tk(user)


/obj/structure/light_construct/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stock_parts/cell))
		if(!cell_connectors)
			to_chat(user, "<span class='warning'>This [name] can't support a power cell!</span>")
			return
		if(HAS_TRAIT(W, TRAIT_NODROP))
			to_chat(user, "<span class='warning'>[W] is stuck to your hand!</span>")
			return
		if(cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed!</span>")
		else if(user.temporarilyRemoveItemFromInventory(W))
			user.visible_message("<span class='notice'>[user] hooks up [W] to [src].</span>", \
			"<span class='notice'>You add [W] to [src].</span>")
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			W.forceMove(src)
			cell = W
			add_fingerprint(user)
		return
	else if (istype(W, /obj/item/light))
		to_chat(user, "<span class='warning'>This [name] isn't finished being setup!</span>")
		return

	switch(stage)
		if(1)
			if(W.tool_behaviour == TOOL_WRENCH)
				if(cell)
					to_chat(user, "<span class='warning'>You have to remove the cell first!</span>")
					return
				else
					to_chat(user, "<span class='notice'>You begin deconstructing [src]...</span>")
					if (W.use_tool(src, user, 30, volume=50))
						new /obj/item/stack/sheet/iron(drop_location(), sheets_refunded)
						user.visible_message("<span class='notice'>[user.name] deconstructs [src].</span>", \
							"<span class='notice'>You deconstruct [src].</span>", "<span class='hear'>You hear a ratchet.</span>")
						playsound(src, 'sound/items/deconstruct.ogg', 75, TRUE)
						qdel(src)
					return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.use(1))
					icon_state = "[fixture_type]-construct-stage2"
					stage = 2
					user.visible_message("<span class='notice'>[user.name] adds wires to [src].</span>", \
						"<span class='notice'>You add wires to [src].</span>")
				else
					to_chat(user, "<span class='warning'>You need one length of cable to wire [src]!</span>")
				return
		if(2)
			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(usr, "<span class='warning'>You have to remove the wires first!</span>")
				return

			if(W.tool_behaviour == TOOL_WIRECUTTER)
				stage = 1
				icon_state = "[fixture_type]-construct-stage1"
				new /obj/item/stack/cable_coil(drop_location(), 1, "red")
				user.visible_message("<span class='notice'>[user.name] removes the wiring from [src].</span>", \
					"<span class='notice'>You remove the wiring from [src].</span>", "<span class='hear'>You hear clicking.</span>")
				W.play_tool_sound(src, 100)
				return

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("<span class='notice'>[user.name] closes [src]'s casing.</span>", \
					"<span class='notice'>You close [src]'s casing.</span>", "<span class='hear'>You hear screwing.</span>")
				W.play_tool_sound(src, 75)
				switch(fixture_type)
					if("tube")
						newlight = new /obj/machinery/light/built(loc)
					if("bulb")
						newlight = new /obj/machinery/light/small/built(loc)
				newlight.setDir(dir)
				transfer_fingerprints_to(newlight)
				if(cell)
					newlight.cell = cell
					cell.forceMove(newlight)
					cell = null
				qdel(src)
				return
	return ..()

/obj/structure/light_construct/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)


/obj/structure/light_construct/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, sheets_refunded)
	qdel(src)

/obj/structure/light_construct/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-stage1"
	fixture_type = "bulb"
	sheets_refunded = 1

// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/overlayicon = 'icons/obj/lighting_overlay.dmi'
	var/base_state = "tube" // base description and icon_state
	icon_state = "tube"
	desc = "A lighting fixture."
	layer = WALL_OBJ_LAYER
	max_integrity = 100
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = AREA_USAGE_LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	var/on = FALSE // 1 if on, 0 if off
	var/on_gs = FALSE
	var/static_power_used = 0
	var/brightness = 8 // luminosity when on, also used in power calculation
	var/bulb_power = 1 // basically the alpha of the emitted light source
	var/bulb_colour = "#f3fffa" // befault colour of the light.
	var/status = LIGHT_OK // LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/flickering = FALSE
	var/light_type = /obj/item/light/tube // the type of light item
	var/fitting = "tube"
	var/switchcount = 0 // count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = FALSE // true if rigged to explode

	var/obj/item/stock_parts/cell/cell
	var/start_with_cell = TRUE // if true, this fixture generates a very weak cell at roundstart

	var/nightshift_enabled = FALSE //Currently in night shift mode?
	var/nightshift_allowed = TRUE //Set to FALSE to never let this light get switched to night mode.
	var/nightshift_brightness = 8
	var/nightshift_light_power = 0.45
	var/nightshift_light_color = "#FFDDCC"

	var/emergency_mode = FALSE // if true, the light is in emergency mode
	var/no_emergency = FALSE // if true, this light cannot ever have an emergency mode
	var/bulb_emergency_brightness_mul = 0.25 // multiplier for this light's base brightness in emergency power mode
	var/bulb_emergency_colour = "#FF3232" // determines the colour of the light while it's in emergency mode
	var/bulb_emergency_pow_mul = 0.75 // the multiplier for determining the light's power in emergency mode
	var/bulb_emergency_pow_min = 0.5 // the minimum value for the light's power in emergency mode

/obj/machinery/light/broken
	status = LIGHT_BROKEN
	icon_state = "tube-broken"

/obj/machinery/light/built
	icon_state = "tube-empty"
	start_with_cell = FALSE

/obj/machinery/light/built/Initialize()
	. = ..()
	status = LIGHT_EMPTY
	update(0)

/obj/machinery/light/no_nightlight
	nightshift_enabled = FALSE

/obj/machinery/light/warm
	bulb_colour = "#fae5c1"

/obj/machinery/light/warm/no_nightlight
	nightshift_allowed = FALSE

/obj/machinery/light/cold
	bulb_colour = "#deefff"
	nightshift_light_color = "#deefff"

/obj/machinery/light/cold/no_nightlight
	nightshift_allowed = FALSE

/obj/machinery/light/red
	bulb_colour = "#FF3232"
	nightshift_allowed = FALSE
	no_emergency = TRUE
	brightness = 2
	bulb_power = 0.7

/obj/machinery/light/blacklight
	bulb_colour = "#A700FF"
	nightshift_allowed = FALSE
	brightness = 2
	bulb_power = 0.8

/obj/machinery/light/dim
	nightshift_allowed = FALSE
	bulb_colour = "#FFDDCC"
	bulb_power = 0.6

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 4
	nightshift_brightness = 4
	bulb_colour = "#FFD6AA"
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb

/obj/machinery/light/small/broken
	status = LIGHT_BROKEN
	icon_state = "bulb-broken"

/obj/machinery/light/small/built
	icon_state = "bulb-empty"
	start_with_cell = FALSE

/obj/machinery/light/small/built/Initialize()
	. = ..()
	status = LIGHT_EMPTY
	update(0)

/obj/machinery/light/small/red
	bulb_colour = "#FF3232"
	no_emergency = TRUE
	nightshift_allowed = FALSE
	brightness = 1
	bulb_power = 0.8

/obj/machinery/light/small/blacklight
	bulb_colour = "#A700FF"
	nightshift_allowed = FALSE
	brightness = 1
	bulb_power = 0.9

/obj/machinery/light/Move()
	if(status != LIGHT_BROKEN)
		break_light_tube(1)
	return ..()

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload)
	. = ..()

	if(!mapload) //sync up nightshift lighting for player made lights
		var/area/A = get_area(src)
		var/obj/machinery/power/apc/temp_apc = A.get_apc()
		nightshift_enabled = temp_apc?.nightshift_lights

	if(start_with_cell && !no_emergency)
		cell = new/obj/item/stock_parts/cell/emergency_light(src)

	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, .proc/on_light_eater)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/LateInitialize()
	. = ..()
	switch(fitting)
		if("tube")
			brightness = 8
			if(prob(2))
				break_light_tube(1)
		if("bulb")
			brightness = 4
			if(prob(5))
				break_light_tube(1)
	addtimer(CALLBACK(src, .proc/update, 0), 1)

/obj/machinery/light/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/atmos_sensitive)

/obj/machinery/light/Destroy()
	var/area/A = get_area(src)
	if(A)
		on = FALSE
// A.update_lights()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/light/update_icon_state()
	switch(status) // set icon_states
		if(LIGHT_OK)
			var/area/A = get_area(src)
			if(emergency_mode || (A?.fire))
				icon_state = "[base_state]_emergency"
			else
				icon_state = "[base_state]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"

/obj/machinery/light/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	if(on && status == LIGHT_OK)
		var/area/A = get_area(src)
		if(emergency_mode || (A?.fire))
			SSvis_overlays.add_vis_overlay(src, overlayicon, "[base_state]_emergency", layer, plane, dir)
		else if (nightshift_enabled)
			SSvis_overlays.add_vis_overlay(src, overlayicon, "[base_state]_nightshift", layer, plane, dir)
		else
			SSvis_overlays.add_vis_overlay(src, overlayicon, base_state, layer, plane, dir)

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = TRUE)
	switch(status)
		if(LIGHT_BROKEN,LIGHT_BURNED,LIGHT_EMPTY)
			on = FALSE
	emergency_mode = FALSE
	if(on)
		var/BR = brightness
		var/PO = bulb_power
		var/CO = bulb_colour
		if(color)
			CO = color
		var/area/A = get_area(src)
		if (A?.fire)
			CO = bulb_emergency_colour
		else if (nightshift_enabled)
			BR = nightshift_brightness
			PO = nightshift_light_power
			if(!color)
				CO = nightshift_light_color
		var/matching = light && BR == light.light_range && PO == light.light_power && CO == light.light_color
		if(!matching)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)
					explode()
			else if( prob( min(60, (switchcount^2)*0.01) ) )
				if(trigger)
					burn_out()
			else
				use_power = ACTIVE_POWER_USE
				set_light(BR, PO, CO)
	else if(has_emergency_power(LIGHT_EMERGENCY_POWER_USE) && !turned_off())
		use_power = IDLE_POWER_USE
		emergency_mode = TRUE
		START_PROCESSING(SSmachines, src)
	else
		use_power = IDLE_POWER_USE
		set_light(0)
	update_icon()

	active_power_usage = (brightness * 10)
	if(on != on_gs)
		on_gs = on
		if(on)
			static_power_used = brightness * 20 //20W per unit luminosity
			addStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)

	broken_sparks(start_only=TRUE)

/obj/machinery/light/update_atom_colour()
	..()
	update()

/obj/machinery/light/proc/broken_sparks(start_only=FALSE)
	if(!QDELETED(src) && status == LIGHT_BROKEN && has_power() && Master.current_runlevel)
		if(!start_only)
			do_sparks(3, TRUE, src)
		var/delay = rand(BROKEN_SPARKS_MIN, BROKEN_SPARKS_MAX)
		addtimer(CALLBACK(src, .proc/broken_sparks), delay, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)

/obj/machinery/light/process()
	if (!cell)
		return PROCESS_KILL
	if(has_power())
		if (cell.charge == cell.maxcharge)
			return PROCESS_KILL
		cell.charge = min(cell.maxcharge, cell.charge + LIGHT_EMERGENCY_POWER_USE) //Recharge emergency power automatically while not using it
	if(emergency_mode && !use_emergency_power(LIGHT_EMERGENCY_POWER_USE))
		update(FALSE) //Disables emergency mode and sets the color to normal

/obj/machinery/light/proc/burn_out()
	if(status == LIGHT_OK)
		status = LIGHT_BURNED
		icon_state = "[base_state]-burned"
		on = FALSE
		set_light(0)

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(s)
	on = (s && status == LIGHT_OK)
	update()

/obj/machinery/light/get_cell()
	return cell

// examine verb
/obj/machinery/light/examine(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_OK)
			. += "It is turned [on? "on" : "off"]."
		if(LIGHT_EMPTY)
			. += "The [fitting] has been removed."
		if(LIGHT_BURNED)
			. += "The [fitting] is burnt out."
		if(LIGHT_BROKEN)
			. += "The [fitting] has been smashed."
	if(cell)
		. += "Its backup power charge meter reads [round((cell.charge / cell.maxcharge) * 100, 0.1)]%."



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/living/user, params)

	//Light replacer code
	if(istype(W, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/LR = W
		LR.ReplaceLight(src, user)

	// attempt to insert light
	else if(istype(W, /obj/item/light))
		if(status == LIGHT_OK)
			to_chat(user, "<span class='warning'>There is a [fitting] already inserted!</span>")
		else
			src.add_fingerprint(user)
			var/obj/item/light/L = W
			if(istype(L, light_type))
				if(!user.temporarilyRemoveItemFromInventory(L))
					return

				src.add_fingerprint(user)
				if(status != LIGHT_EMPTY)
					drop_light_tube(user)
					to_chat(user, "<span class='notice'>You replace [L].</span>")
				else
					to_chat(user, "<span class='notice'>You insert [L].</span>")
				status = L.status
				switchcount = L.switchcount
				rigged = L.rigged
				brightness = L.brightness
				on = has_power()
				update()

				qdel(L)

				if(on && rigged)
					explode()
			else
				to_chat(user, "<span class='warning'>This type of light requires a [fitting]!</span>")

	// attempt to stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		if(W.tool_behaviour == TOOL_SCREWDRIVER) //If it's a screwdriver open it.
			W.play_tool_sound(src, 75)
			user.visible_message("<span class='notice'>[user.name] opens [src]'s casing.</span>", \
				"<span class='notice'>You open [src]'s casing.</span>", "<span class='hear'>You hear a noise.</span>")
			deconstruct()
		else
			to_chat(user, "<span class='userdanger'>You stick \the [W] into the light socket!</span>")
			if(has_power() && (W.flags_1 & CONDUCT_1))
				do_sparks(3, TRUE, src)
				if (prob(75))
					electrocute_mob(user, get_area(src), src, (rand(7,10) * 0.1), TRUE)
	else
		return ..()

/obj/machinery/light/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/light_construct/newlight = null
		var/cur_stage = 2
		if(!disassembled)
			cur_stage = 1
		switch(fitting)
			if("tube")
				newlight = new /obj/structure/light_construct(src.loc)
				newlight.icon_state = "tube-construct-stage[cur_stage]"

			if("bulb")
				newlight = new /obj/structure/light_construct/small(src.loc)
				newlight.icon_state = "bulb-construct-stage[cur_stage]"
		newlight.setDir(src.dir)
		newlight.stage = cur_stage
		if(!disassembled)
			newlight.obj_integrity = newlight.max_integrity * 0.5
			if(status != LIGHT_BROKEN)
				break_light_tube()
			if(status != LIGHT_EMPTY)
				drop_light_tube()
			new /obj/item/stack/cable_coil(loc, 1, "red")
		transfer_fingerprints_to(newlight)
		if(cell)
			newlight.cell = cell
			cell.forceMove(newlight)
			cell = null
	qdel(src)

/obj/machinery/light/attacked_by(obj/item/I, mob/living/user)
	..()
	if(status == LIGHT_BROKEN || status == LIGHT_EMPTY)
		if(on && (I.flags_1 & CONDUCT_1))
			if(prob(12))
				electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, TRUE)
				else
					playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

// returns if the light has power /but/ is manually turned off
// if a light is turned off, it won't activate emergency power
/obj/machinery/light/proc/turned_off()
	var/area/A = get_area(src)
	return !A.lightswitch && A.power_light || flickering

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

// returns whether this light has emergency power
// can also return if it has access to a certain amount of that power
/obj/machinery/light/proc/has_emergency_power(pwr)
	if(no_emergency || !cell)
		return FALSE
	if(pwr ? cell.charge >= pwr : cell.charge)
		return status == LIGHT_OK

// attempts to use power from the installed emergency cell, returns true if it does and false if it doesn't
/obj/machinery/light/proc/use_emergency_power(pwr = LIGHT_EMERGENCY_POWER_USE)
	if(!has_emergency_power(pwr))
		return FALSE
	if(cell.charge > 300) //it's meant to handle 120 W, ya doofus
		visible_message("<span class='warning'>[src] short-circuits from too powerful of a power cell!</span>")
		burn_out()
		return FALSE
	cell.use(pwr)
	set_light(brightness * bulb_emergency_brightness_mul, max(bulb_emergency_pow_min, bulb_emergency_pow_mul * (cell.charge / cell.maxcharge)), bulb_emergency_colour)
	return TRUE


/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	set waitfor = FALSE
	if(flickering)
		return
	flickering = TRUE
	if(on && status == LIGHT_OK)
		for(var/i = 0; i < amount; i++)
			if(status != LIGHT_OK)
				break
			on = !on
			update(0)
			sleep(rand(5, 15))
		on = (status == LIGHT_OK)
		update(0)
	flickering = FALSE

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	no_emergency = !no_emergency
	to_chat(user, "<span class='notice'>Emergency lights for this fixture have been [no_emergency ? "disabled" : "enabled"].</span>")
	update(FALSE)
	return

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, "<span class='warning'>There is no [fitting] in this light!</span>")
		return

	// make it burn hands unless you're wearing heat insulated gloves or have the RESISTHEAT/RESISTHEATHANDS traits
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))
			var/datum/species/ethereal/eth_species = H.dna?.species
			if(istype(eth_species))
				var/datum/species/ethereal/E = H.dna.species
				if(E.drain_time > world.time)
					return
				to_chat(H, "<span class='notice'>You start channeling some power through the [fitting] into your body.</span>")
				E.drain_time = world.time + LIGHT_DRAIN_TIME
				if(do_after(user, LIGHT_DRAIN_TIME, target = src))
					var/obj/item/organ/stomach/ethereal/stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
					if(istype(stomach))
						to_chat(H, "<span class='notice'>You receive some charge from the [fitting].</span>")
						stomach.adjust_charge(LIGHT_POWER_GAIN)
					else
						to_chat(H, "<span class='warning'>You can't receive charge from the [fitting]!</span>")
				return

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
			to_chat(user, "<span class='notice'>You remove the light [fitting].</span>")
		else if(istype(user) && user.dna.check_mutation(TK))
			to_chat(user, "<span class='notice'>You telekinetically remove the light [fitting].</span>")
		else
			var/obj/item/bodypart/affecting = H.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting?.receive_damage( 0, 5 )) // 5 burn damage
				H.update_damage_overlays()
			if(HAS_TRAIT(user, TRAIT_LIGHTBULB_REMOVER))
				to_chat(user, "<span class='notice'>You feel like you're burning, but you can push through.</span>")
				if(!do_after(user, 5 SECONDS, target = src))
					return
				if(affecting?.receive_damage( 0, 10 )) // 10 more burn damage
					H.update_damage_overlays()
				to_chat(user, "<span class='notice'>You manage to remove the light [fitting], shattering it in process.</span>")
				break_light_tube()
			else
				to_chat(user, "<span class='warning'>You try to remove the light [fitting], but you burn your hand on it!</span>")
				return
	else
		to_chat(user, "<span class='notice'>You remove the light [fitting].</span>")
	// create a light tube/bulb item and put it in the user's hand
	drop_light_tube(user)

/obj/machinery/light/proc/drop_light_tube(mob/user)
	var/obj/item/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness = brightness

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.forceMove(loc)

	if(user) //puts it in our active hand
		L.add_fingerprint(user)
		user.put_in_active_hand(L)

	status = LIGHT_EMPTY
	update()
	return L

/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, "<span class='warning'>There is no [fitting] in this light!</span>")
		return

	to_chat(user, "<span class='notice'>You telekinetically remove the light [fitting].</span>")
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/light_tube = drop_light_tube()
	return light_tube.attack_tk(user)


// break the light and make sparks if was on

/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
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
		explosion(src,0,0,0,flame_range = 5, adminlog = FALSE)
		qdel(src)

// called when area power state changes
/obj/machinery/light/power_change()
	SHOULD_CALL_PARENT(FALSE)
	var/area/A = get_area(src)
	seton(A.lightswitch && A.power_light)

// called when heated

/obj/machinery/light/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 673

/obj/machinery/light/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		break_light_tube()

// explode the light

/obj/machinery/light/proc/explode()
	set waitfor = 0
	var/turf/T = get_turf(src.loc)
	break_light_tube() // break it first to give a warning
	sleep(2)
	explosion(T, 0, 0, 2, 2)
	sleep(1)
	qdel(src)

/obj/machinery/light/proc/on_light_eater(obj/machinery/light/source, datum/light_eater)
	SIGNAL_HANDLER
	. = COMPONENT_BLOCK_LIGHT_EATER
	if(status == LIGHT_EMPTY)
		return
	var/obj/item/light/tube = drop_light_tube()
	tube?.burn()
	return

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	var/status = LIGHT_OK // LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0 // number of times switched
	custom_materials = list(/datum/material/glass=100)
	grind_results = list(/datum/reagent/silicon = 5, /datum/reagent/nitrogen = 10) //Nitrogen is used as a cheaper alternative to argon in incandescent lighbulbs
	var/rigged = FALSE // true if rigged to explode
	var/brightness = 2 //how much light it gives off

/obj/item/light/suicide_act(mob/living/carbon/user)
	if (status == LIGHT_BROKEN)
		user.visible_message("<span class='suicide'>[user] begins to stab [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		return BRUTELOSS
	else
		user.visible_message("<span class='suicide'>[user] begins to eat \the [src]! It looks like [user.p_theyre()] not very bright!</span>")
		shatter()
		return BRUTELOSS

/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	inhand_icon_state = "c_tube"
	brightness = 8
	custom_price = PAYCHECK_EASY * 0.5

/obj/item/light/tube/broken
	status = LIGHT_BROKEN

/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	inhand_icon_state = "contvapour"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	brightness = 4
	custom_price = PAYCHECK_EASY * 0.4

/obj/item/light/bulb/broken
	status = LIGHT_BROKEN

/obj/item/light/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //not caught by a mob
		shatter()

// update the icon state and description of the light

/obj/item/light/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			desc = "A broken [name]."

/obj/item/light/Initialize()
	. = ..()
	create_reagents(LIGHT_REAGENT_CAPACITY, INJECTABLE | DRAINABLE)
	AddElement(/datum/element/caltrop, min_damage = force)
	update()

/obj/item/light/Crossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(!(L.movement_type & (FLYING|FLOATING)) || L.buckled)
		playsound(src, 'sound/effects/glass_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 30 : 50, TRUE)
		if(status == LIGHT_BURNED || status == LIGHT_OK)
			shatter()

/obj/item/light/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), .proc/on_reagent_change)
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, .proc/on_reagents_del)

/**
 * Handles rigging the cell if it contains enough plasma.
 */
/obj/item/light/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	rigged = (reagents.has_reagent(/datum/reagent/toxin/plasma, LIGHT_REAGENT_CAPACITY)) ? TRUE : FALSE //has_reagent returns the reagent datum, we don't want to hold a reference to prevent hard dels
	return NONE

/**
 * Handles the reagent holder datum being deleted for some reason. Probably someone making pizza lights.
 */
/obj/item/light/proc/on_reagents_del(datum/reagents/holder)
	SIGNAL_HANDLER
	UnregisterSignal(holder, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_REAGENTS_NEW_REAGENT,
		COMSIG_REAGENTS_ADD_REAGENT,
		COMSIG_REAGENTS_REM_REAGENT,
		COMSIG_REAGENTS_DEL_REAGENT,
	))
	return NONE

#undef LIGHT_REAGENT_CAPACITY

/obj/item/light/attack(mob/living/M, mob/living/user, def_zone)
	..()
	shatter()

/obj/item/light/attack_obj(obj/O, mob/living/user)
	..()
	shatter()

/obj/item/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		visible_message("<span class='danger'>[src] shatters.</span>","<span class='hear'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(rigged)
			atmos_spawn_air("plasma=5") //5u of plasma are required to rig a light bulb/tube
		update()


/obj/machinery/light/floor
	name = "floor light"
	icon = 'icons/obj/lighting.dmi'
	base_state = "floor" // base description and icon_state
	icon_state = "floor"
	brightness = 4
	layer = 2.5
	light_type = /obj/item/light/bulb
	fitting = "bulb"

// -------- Directional presets
// The directions are backwards on the lights we have now
/obj/machinery/light/directional/north
	dir = NORTH

/obj/machinery/light/directional/south
	dir = SOUTH

/obj/machinery/light/directional/east
	dir = EAST

/obj/machinery/light/directional/west
	dir = WEST

// ---- Broken tube
/obj/machinery/light/broken/directional/north
	dir = NORTH

/obj/machinery/light/broken/directional/south
	dir = SOUTH

/obj/machinery/light/broken/directional/east
	dir = EAST

/obj/machinery/light/broken/directional/west
	dir = WEST

// ---- Tube construct
/obj/structure/light_construct/directional/north
	dir = NORTH

/obj/structure/light_construct/directional/south
	dir = SOUTH

/obj/structure/light_construct/directional/east
	dir = EAST

/obj/structure/light_construct/directional/west
	dir = WEST

// ---- Tube frames
/obj/machinery/light/built/directional/north
	dir = NORTH

/obj/machinery/light/built/directional/south
	dir = SOUTH

/obj/machinery/light/built/directional/east
	dir = EAST

/obj/machinery/light/built/directional/west
	dir = WEST

// ---- No nightlight tubes
/obj/machinery/light/no_nightlight/directional/north
	dir = NORTH

/obj/machinery/light/no_nightlight/directional/south
	dir = SOUTH

/obj/machinery/light/no_nightlight/directional/east
	dir = EAST

/obj/machinery/light/no_nightlight/directional/west
	dir = WEST

// ---- Warm light tubes
/obj/machinery/light/warm/directional/north
	dir = NORTH

/obj/machinery/light/warm/directional/south
	dir = SOUTH

/obj/machinery/light/warm/directional/east
	dir = EAST

/obj/machinery/light/warm/directional/west
	dir = WEST

// ---- No nightlight warm light tubes
/obj/machinery/light/warm/no_nightlight/directional/north
	dir = NORTH

/obj/machinery/light/warm/no_nightlight/directional/south
	dir = SOUTH

/obj/machinery/light/warm/no_nightlight/directional/east
	dir = EAST

/obj/machinery/light/warm/no_nightlight/directional/west
	dir = WEST

// ---- Cold light tubes
/obj/machinery/light/cold/directional/north
	dir = NORTH

/obj/machinery/light/cold/directional/south
	dir = SOUTH

/obj/machinery/light/cold/directional/east
	dir = EAST

/obj/machinery/light/cold/directional/west
	dir = WEST

// ---- No nightlight cold light tubes
/obj/machinery/light/cold/no_nightlight/directional/north
	dir = NORTH

/obj/machinery/light/cold/no_nightlight/directional/south
	dir = SOUTH

/obj/machinery/light/cold/no_nightlight/directional/east
	dir = EAST

/obj/machinery/light/cold/no_nightlight/directional/west
	dir = WEST

// ---- Red tubes
/obj/machinery/light/red/directional/north
	dir = NORTH

/obj/machinery/light/red/directional/south
	dir = SOUTH

/obj/machinery/light/red/directional/east
	dir = EAST

/obj/machinery/light/red/directional/west
	dir = WEST

// ---- Blacklight tubes
/obj/machinery/light/blacklight/directional/north
	dir = NORTH

/obj/machinery/light/blacklight/directional/south
	dir = SOUTH

/obj/machinery/light/blacklight/directional/east
	dir = EAST

/obj/machinery/light/blacklight/directional/west
	dir = WEST

// ---- Dim tubes
/obj/machinery/light/dim/directional/north
	dir = NORTH

/obj/machinery/light/dim/directional/south
	dir = SOUTH

/obj/machinery/light/dim/directional/east
	dir = EAST

/obj/machinery/light/dim/directional/west
	dir = WEST


// -------- Bulb lights
/obj/machinery/light/small/directional/north
	dir = NORTH

/obj/machinery/light/small/directional/south
	dir = SOUTH

/obj/machinery/light/small/directional/east
	dir = EAST

/obj/machinery/light/small/directional/west
	dir = WEST

// ---- Bulb construct
/obj/structure/light_construct/small/directional/north
	dir = NORTH

/obj/structure/light_construct/small/directional/south
	dir = SOUTH

/obj/structure/light_construct/small/directional/east
	dir = EAST

/obj/structure/light_construct/small/directional/west
	dir = WEST

// ---- Bulb frames
/obj/machinery/light/small/built/directional/north
	dir = NORTH

/obj/machinery/light/small/built/directional/south
	dir = SOUTH

/obj/machinery/light/small/built/directional/east
	dir = EAST

/obj/machinery/light/small/built/directional/west
	dir = WEST

// ---- Broken bulbs
/obj/machinery/light/small/broken/directional/north
	dir = NORTH

/obj/machinery/light/small/broken/directional/south
	dir = SOUTH

/obj/machinery/light/small/broken/directional/east
	dir = EAST

/obj/machinery/light/small/broken/directional/west
	dir = WEST

// ---- Red bulbs
/obj/machinery/light/small/red/directional/north
	dir = NORTH

/obj/machinery/light/small/red/directional/south
	dir = SOUTH

/obj/machinery/light/small/red/directional/east
	dir = EAST

/obj/machinery/light/small/red/directional/west
	dir = WEST

// ---- Blacklight bulbs
/obj/machinery/light/small/blacklight/directional/north
	dir = NORTH

/obj/machinery/light/small/blacklight/directional/south
	dir = SOUTH

/obj/machinery/light/small/blacklight/directional/east
	dir = EAST

/obj/machinery/light/small/blacklight/directional/west
	dir = WEST

#undef LIGHT_DRAIN_TIME
#undef LIGHT_POWER_GAIN
