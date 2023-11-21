//Every time you got lost looking for keycards, incriment: 1
//**************
//*****Keys*******************
//************** **  **
/obj/item/keycard
	name = "security keycard"
	desc = "This feels like it belongs to a door."
	icon = 'icons/obj/fluff/puzzle_small.dmi'
	icon_state = "keycard"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 7
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	var/puzzle_id = null

//Two test keys for use alongside the two test doors.
/obj/item/keycard/yellow
	name = "yellow keycard"
	desc = "A yellow keycard. How fantastic. Looks like it belongs to a high security door."
	color = "#f0da12"
	puzzle_id = "yellow"

/obj/item/keycard/blue
	name = "blue keycard"
	desc = "A blue keycard. How terrific. Looks like it belongs to a high security door."
	color = "#3bbbdb"
	puzzle_id = "blue"

//***************
//*****Doors*****
//***************

/obj/machinery/door/puzzle
	name = "locked door"
	desc = "This door only opens under certain conditions. It looks virtually indestructible."
	icon = 'icons/obj/doors/puzzledoor/default.dmi'
	icon_state = "door_closed"
	explosion_block = 3
	heat_proof = TRUE
	max_integrity = 600
	armor_type = /datum/armor/door_puzzle
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	move_resist = MOVE_FORCE_OVERPOWERING
	damage_deflection = 70
	can_open_with_hands = FALSE
	/// Make sure that the puzzle has the same puzzle_id as the keycard door!
	var/puzzle_id = null
	/// Message that occurs when the door is opened
	var/open_message = "The door beeps, and slides opens."

//Standard Expressions to make keycard doors basically un-cheeseable
/datum/armor/door_puzzle
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/obj/machinery/door/puzzle/Bumped(atom/movable/AM)
	return !density && ..()

/obj/machinery/door/puzzle/emp_act(severity)
	return

/obj/machinery/door/puzzle/ex_act(severity, target)
	return FALSE

/obj/machinery/door/puzzle/try_to_activate_door(mob/user, access_bypass = FALSE)
	add_fingerprint(user)
	if(operating)
		return

/obj/machinery/door/puzzle/proc/try_puzzle_open(try_id)
	if(puzzle_id && puzzle_id != try_id)
		return FALSE
	if(!density)
		visible_message(span_warning("The door can't seem to be closed."))
		return TRUE
	if(open_message)
		visible_message(span_notice(open_message))
	open()
	return TRUE

/obj/machinery/door/puzzle/keycard
	desc = "This door only opens when a keycard is swiped. It looks virtually indestructible."

/obj/machinery/door/puzzle/keycard/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/keycard))
		return
	var/obj/item/keycard/key = attacking_item
	if(!try_puzzle_open(key.puzzle_id))
		to_chat(user, span_notice("[src] buzzes. This must not be the right key."))

//Test doors. Gives admins a few doors to use quickly should they so choose for events.
/obj/machinery/door/puzzle/keycard/yellow_required
	name = "blue airlock"
	desc = "It looks like it requires a yellow keycard."
	puzzle_id = "yellow"

/obj/machinery/door/puzzle/keycard/blue_required
	name = "blue airlock"
	desc = "It looks like it requires a blue keycard."
	puzzle_id = "blue"

/obj/machinery/door/puzzle/light
	desc = "This door only opens when a linked mechanism is powered. It looks virtually indestructible."

/obj/machinery/door/puzzle/light/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_LIGHT_MECHANISM_COMPLETED, PROC_REF(check_mechanism))

/obj/machinery/door/puzzle/light/proc/check_mechanism(datum/source, try_id)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(try_puzzle_open), try_id)

//*************************
//***Box Pushing Puzzles***
//*************************
//We're working off a subtype of pressureplates, which should work just a BIT better now.
/obj/structure/holobox
	name = "holobox"
	desc = "A hard-light box, containing a secure decryption key."
	icon = 'icons/obj/fluff/puzzle_small.dmi'
	icon_state = "laserbox"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF

//Uses the pressure_plate settings for a pretty basic custom pattern that waits for a specific item to trigger. Easy enough to retool for mapping purposes or subtypes.
/obj/item/pressure_plate/hologrid
	name = "hologrid"
	desc = "A high power, electronic input port for a holobox, which can unlock the hologrid's storage compartment. Safe to stand on."
	icon = 'icons/obj/fluff/puzzle_small.dmi'
	icon_state = "lasergrid"
	anchored = TRUE
	trigger_mob = FALSE
	trigger_item = TRUE
	specific_item = /obj/structure/holobox
	removable_signaller = FALSE //Being a pressure plate subtype, this can also use signals.
	roundstart_signaller_freq = FREQ_HOLOGRID_SOLUTION //Frequency is kept on it's own default channel however.
	active = TRUE
	trigger_delay = 10
	protected = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	undertile_pressureplate = FALSE
	var/reward = /obj/item/food/cookie
	var/claimed = FALSE

/obj/item/pressure_plate/hologrid/Initialize(mapload)
	. = ..()
	if(undertile_pressureplate)
		AddElement(/datum/element/undertile, tile_overlay = tile_overlay, use_anchor = FALSE) //we remove use_anchor here, so it ALWAYS stays anchored

/obj/item/pressure_plate/hologrid/examine(mob/user)
	. = ..()
	if(claimed)
		. += span_notice("This one appears to be spent already.")

/obj/item/pressure_plate/hologrid/trigger()
	if(!claimed)
		new reward(loc)
	flick("lasergrid_a",src)
	icon_state = "lasergrid_full"
	claimed = TRUE

/obj/item/pressure_plate/hologrid/on_entered(datum/source, atom/movable/AM)
	. = ..()
	if(trigger_item && istype(AM, specific_item) && !claimed)
		AM.set_anchored(TRUE)
		flick("laserbox_burn", AM)
		trigger()
		QDEL_IN(AM, 15)

//Light puzzle
/obj/structure/light_puzzle
	name = "light mechanism"
	desc = "It's a mechanism that seems to power something when all the lights are lit up. It looks virtually indestructible."
	icon = 'icons/obj/fluff/puzzle_small.dmi'
	icon_state = "light_puzzle"
	anchored = TRUE
	explosion_block = 3
	armor_type = /datum/armor/structure_light_puzzle
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_power = 3
	light_color = LIGHT_COLOR_ORANGE
	var/powered = FALSE
	var/puzzle_id = null
	var/list/light_list = list(
		0, 0, 0,
		0, 0, 0,
		0, 0, 0
	)
	/// Banned combinations of the list in decimal
	var/static/list/banned_combinations = list(-1, 47, 95, 203, 311, 325, 422, 473, 488, 500, 511)

/datum/armor/structure_light_puzzle
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/obj/structure/light_puzzle/Initialize(mapload)
	AddElement(/datum/element/blocks_explosives)
	. = ..()
	var/generated_board = -1
	while(generated_board in banned_combinations)
		generated_board = rand(0, 510)
	for(var/i in 0 to 8)
		var/position = !!(generated_board & (1<<i))
		light_list[i+1] = position
	update_icon(UPDATE_OVERLAYS)

/obj/structure/light_puzzle/update_overlays()
	. = ..()
	for(var/i in 1 to 9)
		if(!light_list[i])
			continue
		var/mutable_appearance/lit_image = mutable_appearance('icons/obj/fluff/puzzle_small.dmi', "light_lit")
		var/mutable_appearance/emissive_image = emissive_appearance('icons/obj/fluff/puzzle_small.dmi', "light_lit", src)
		lit_image.pixel_x = 8 * ((i % 3 || 3 ) - 1)
		lit_image.pixel_y = -8 * (ROUND_UP(i / 3) - 1)
		emissive_image.pixel_x = lit_image.pixel_x
		emissive_image.pixel_y = lit_image.pixel_y
		. += lit_image
		. += emissive_image

/obj/structure/light_puzzle/attack_hand(mob/living/user, list/modifiers)
	if(!modifiers || powered)
		return ..()
	var/light_clicked
	var/x_clicked = text2num(modifiers[ICON_X])
	var/y_clicked = text2num(modifiers[ICON_Y])
	if(x_clicked <= 4 || x_clicked >= 29 || y_clicked <= 4 || y_clicked >= 29)
		return ..()
	x_clicked = ROUND_UP((x_clicked - 4) / 8)
	y_clicked = (-(ROUND_UP((y_clicked - 4) / 8) - 4) - 1) * 3
	light_clicked = x_clicked + y_clicked
	switch_light(light_clicked)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

/obj/structure/light_puzzle/proc/switch_light(light)
	var/list/updating_lights = list()
	updating_lights += light
	if(light % 3 != 0)
		updating_lights += light + 1
	if(light % 3 != 1)
		updating_lights += light - 1
	if(light + 3 <= 9)
		updating_lights += light + 3
	if(light - 3 > 0)
		updating_lights += light - 3
	for(var/updating_light in updating_lights)
		light_list[updating_light] = !light_list[updating_light]
	update_icon(UPDATE_OVERLAYS)
	for(var/checking_light in light_list)
		if(!checking_light)
			return
	visible_message(span_boldnotice("[src] becomes fully charged!"))
	powered = TRUE
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_LIGHT_MECHANISM_COMPLETED, puzzle_id)
	playsound(src, 'sound/machines/synth_yes.ogg', 100, TRUE)
