//Every time you got lost looking for keycards, increment: 2

//**************
//*****Keys*****
//**************
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

/obj/item/keycard/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

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
	/// Make sure that the puzzle has the same puzzle_id as the keycard door! (If this is null, queuelinks dont happen!)
	var/puzzle_id = null
	/// do we use queue_links?
	var/uses_queuelinks = TRUE
	/// Message that occurs when the door is opened
	var/open_message = "The door beeps, and slides opens."

/obj/machinery/door/puzzle/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

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

/obj/machinery/door/puzzle/Initialize(mapload)
	. = ..()
	if(!isnull(puzzle_id) && uses_queuelinks)
		SSqueuelinks.add_to_queue(src, puzzle_id)
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/machinery/door/puzzle/MatchedLinks(id, list/partners)
	for(var/partner in partners)
		RegisterSignal(partner, COMSIG_PUZZLE_COMPLETED, PROC_REF(try_signal))

/obj/machinery/door/puzzle/proc/try_signal(datum/source, try_id)
	SIGNAL_HANDLER

	puzzle_id = null //honestly these cant be closed anyway and im not fucking around with door code anymore
	INVOKE_ASYNC(src, PROC_REF(try_puzzle_open), null)

/obj/machinery/door/puzzle/Bumped(atom/movable/AM)
	return !density && ..()

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
	uses_queuelinks = FALSE

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

/obj/item/pressure_plate/hologrid/get_save_vars()
	return ..() + NAMEOF(src, reward)

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
	/// queue size, must match count of objects this activates!
	var/queue_size = 2

/obj/structure/light_puzzle/get_save_vars()
	return ..() + list(NAMEOF(src, queue_size), NAMEOF(src, puzzle_id))

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
	if(!isnull(puzzle_id))
		SSqueuelinks.add_to_queue(src, puzzle_id, queue_size)

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
	SEND_SIGNAL(src, COMSIG_PUZZLE_COMPLETED)
	playsound(src, 'sound/machines/synth_yes.ogg', 100, TRUE)

//
// literally just buttons
//

/obj/machinery/puzzle
	name = "abstract puzzle gizmo"
	icon = 'icons/obj/machines/wallmounts.dmi'
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	/// have we been pressed already?
	var/used = FALSE
	/// can we be pressed only once?
	var/single_use = TRUE
	/// puzzle id we send on press
	var/id //null would literally open every puzzle door without an id
	/// queue size, must match count of objects this activates!
	var/queue_size = 2
	/// should the puzzle machinery perform the final step of the queue link on LateInitialize? An alternative to queue size
	var/late_initialize_pop = FALSE

/obj/machinery/puzzle/get_save_vars()
	return ..() + list(NAMEOF(src, queue_size), NAMEOF(src, id))

/obj/machinery/puzzle/Initialize(mapload)
	. = ..()
	if(!isnull(id))
		SSqueuelinks.add_to_queue(src, id, late_initialize_pop ? 0 : queue_size)
		return late_initialize_pop ? INITIALIZE_HINT_LATELOAD : .

/obj/machinery/puzzle/post_machine_initialize()
	. = ..()
	if(late_initialize_pop && id && SSqueuelinks.queues[id])
		SSqueuelinks.pop_link(id)

/obj/machinery/puzzle/proc/on_puzzle_complete() //incase someone wants to make this do something else for some reason
	SEND_SIGNAL(src, COMSIG_PUZZLE_COMPLETED)

/obj/machinery/puzzle/update_icon_state()
	icon_state = "[base_icon_state][used]"
	return ..()

/obj/machinery/puzzle/button
	name = "control panel"
	desc = "A panel that controls something nearby. I'm sure it being covered in hazard stripes is fine."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "lockdown0"
	base_icon_state = "lockdown"

/obj/machinery/puzzle/button/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(used && single_use)
		return
	used = single_use
	update_icon_state()
	visible_message(span_notice("[user] presses a button on [src]."), span_notice("You press a button on [src]."))
	playsound(src, 'sound/machines/terminal_button07.ogg', 45, TRUE)
	on_puzzle_complete()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/puzzle/button, 32)

/obj/machinery/puzzle/keycardpad
	name = "keycard panel"
	desc = "A panel that controls something nearby. Accepts keycards."
	icon_state = "keycardpad0"
	base_icon_state = "keycardpad"

/obj/machinery/puzzle/keycardpad/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/keycard) || used)
		return
	var/obj/item/keycard/key = attacking_item
	var/correct_card = key.puzzle_id == id
	balloon_alert_to_viewers("[correct_card ? "correct" : "incorrect"] card swiped[correct_card ? "" : "!"]")
	playsound(src, 'sound/machines/card_slide.ogg', 45, TRUE)
	if(!correct_card)
		return
	used = TRUE
	update_icon_state()
	playsound(src, 'sound/machines/beep.ogg', 45, TRUE)
	on_puzzle_complete()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/puzzle/keycardpad, 32)

/obj/machinery/puzzle/password
	name = "password panel"
	desc = "A panel that controls something nearby. This one requires a (case-sensitive) password, and it's not \"Swordfish\"."
	icon_state = "passpad0"
	base_icon_state = "passpad"
	///The password to this door.
	var/password = ""
	///The text shown in the tgui input popup
	var/tgui_text = "Please enter the password."
	///The title of the tgui input popup
	var/tgui_title = "What's the password?"
	///Decides whether the max length of the input is MAX_NAME_LEN or the length of the password.
	var/input_max_len_is_pass = FALSE

/obj/machinery/puzzle/password/get_save_vars()
	return ..() + list(NAMEOF(src, password), NAMEOF(src, tgui_text), NAMEOF(src, tgui_title), NAMEOF(src, input_max_len_is_pass))

/obj/machinery/puzzle/password/interact(mob/user, list/modifiers)
	if(used && single_use)
		return
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH) || !user.can_interact_with(src))
		return
	var/pass_input = tgui_input_text(user, tgui_text, tgui_title, max_length = input_max_len_is_pass ? length(password) : MAX_NAME_LEN)
	if(isnull(pass_input) || !user.can_perform_action(src, ALLOW_SILICON_REACH) || !user.can_interact_with(src))
		return
	var/correct = pass_input == password
	balloon_alert_to_viewers("[correct ? "correct" : "wrong"] password[correct ? "" : "!"]")
	if(!correct)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 45, TRUE)
		return
	used = single_use
	update_icon_state()
	playsound(src, 'sound/machines/terminal_button07.ogg', 45, TRUE)
	on_puzzle_complete()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/puzzle/password, 32)

/obj/machinery/puzzle/password/pin
	desc = "A panel that controls something nearby. This one requires a PIN password, so let's start by typing in 1234..."
	tgui_text = "Please enter the PIN code."
	tgui_title = "What's the PIN code?"
	input_max_len_is_pass = TRUE
	///The length of the PIN. Suggestion: something between 4 and 12.
	var/pin_length = 6
	///associate a color to each digit that may be found in the password.
	var/list/digit_to_color = list()

/obj/machinery/puzzle/password/pin/get_save_vars()
	return ..() + NAMEOF(src, pin_length)

/obj/machinery/puzzle/password/pin/Initialize(mapload)
	. = ..()

	for(var/iteration in 1 to pin_length)
		password += "[rand(1, 9)]"

	var/list/possible_colors = list(
			"white",
			"black",
			"red",
			"green",
			"blue",
			"yellow",
			"orange",
			"brown",
			"gray",
		)
	for(var/digit in 0 to 9)
		digit_to_color["[digit]"] = pick_n_take(possible_colors)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/puzzle/password/pin, 32)

//
// blockade
//

///blockades destroy themselves if they receive COMSIG_GLOB_PUZZLE_COMPLETED with their ID
/obj/structure/puzzle_blockade
	name = "shield gate"
	desc = "A wall of solid light, likely defending something important. Virtually indestructible, must be a way around, or to disable it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "wave2"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	move_resist = MOVE_FORCE_OVERPOWERING
	opacity = FALSE
	density = TRUE
	anchored = TRUE
	/// if we receive a puzzle signal with this id we get destroyed
	var/id

/obj/structure/puzzle_blockade/get_save_vars()
	return ..() + NAMEOF(src, id)

/obj/structure/puzzle_blockade/Initialize(mapload)
	. = ..()
	if(!isnull(id))
		SSqueuelinks.add_to_queue(src, id)

/obj/structure/puzzle_blockade/MatchedLinks(id, list/partners)
	for(var/partner in partners)
		RegisterSignal(partner, COMSIG_PUZZLE_COMPLETED, PROC_REF(try_signal))

/obj/structure/puzzle_blockade/proc/try_signal(datum/source)
	SIGNAL_HANDLER
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	qdel(src)

/obj/structure/puzzle_blockade/oneway
	name = "one-way gate"
	desc = "A wall of solid light, likely defending something important. Virtually indestructible."
	icon = 'icons/obj/structures.dmi'
	icon_state = "oneway"
	base_icon_state = "oneway"
	light_color = COLOR_BIOLUMINESCENCE_BLUE
	light_range = 1
	density = FALSE

/obj/structure/puzzle_blockade/oneway/update_icon_state()
	icon_state = "[base_icon_state][density ? "" : "-off"]"
	return ..()

/obj/structure/puzzle_blockade/oneway/CanAllowThrough(atom/movable/mover, border_dir)
	return ..() && (REVERSE_DIR(border_dir) == dir || get_turf(mover) == get_turf(src))

/obj/structure/puzzle_blockade/oneway/CanAStarPass(border_dir, datum/can_pass_info/pass_info)
	return REVERSE_DIR(border_dir) == dir

/obj/structure/puzzle_blockade/oneway/try_signal(datum/source)
	density = FALSE
	update_appearance(UPDATE_ICON)

/obj/effect/puzzle_poddoor_open
	name = "puzzle-poddoor relay"
	desc = "activates poddoors if activated with a puzzle signal."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	/// if we receive a puzzle signal with this we do our thing
	var/queue_id
	/// door id
	var/id

/obj/effect/puzzle_poddoor_open/get_save_vars()
	return ..() + list(NAMEOF(src, queue_id), NAMEOF(src, id))

/obj/effect/puzzle_poddoor_open/Initialize(mapload)
	. = ..()
	if(isnull(id) || isnull(queue_id))
		log_mapping("[src] id:[id] has no id or door id and has been deleted")
		return INITIALIZE_HINT_QDEL

	SSqueuelinks.add_to_queue(src, queue_id)

/obj/effect/puzzle_poddoor_open/MatchedLinks(id, list/partners)
	for(var/partner in partners)
		RegisterSignal(partner, COMSIG_PUZZLE_COMPLETED, PROC_REF(try_signal))

/obj/effect/puzzle_poddoor_open/proc/try_signal(datum/source)
	SIGNAL_HANDLER
	var/openclose
	for(var/obj/machinery/door/poddoor/door as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/poddoor))
		if(door.id != id)
			continue
		if(isnull(openclose))
			openclose = door.density
		INVOKE_ASYNC(door, openclose ? TYPE_PROC_REF(/obj/machinery/door/poddoor, open) : TYPE_PROC_REF(/obj/machinery/door/poddoor, close))

#define MAX_PUZZLE_DOTS_PER_ROW 4
#define PUZZLE_DOTS_VERTICAL_OFFSET 7
#define PUZZLE_DOTS_HORIZONTAL_OFFSET 7

///A dotted board that can be used as clue for PIN puzzle machinery
/obj/effect/decal/puzzle_dots
	name = "dotted board"
	desc = "A board filled with colored dots. What could this mean?"
	icon = 'icons/obj/fluff/puzzle_small.dmi'
	icon_state = "puzzle_dots"
	plane = GAME_PLANE //visible over walls
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | UNACIDABLE | LAVA_PROOF
	flags_1 = UNPAINTABLE_1
	///The id of the puzzle we're linked to.
	var/id

/obj/effect/decal/puzzle_dots/get_save_vars()
	return ..() + NAMEOF(src, id)

/obj/effect/decal/puzzle_dots/Initialize(mapload)
	. = ..()
	if(id)
		SSqueuelinks.add_to_queue(src, id)

/obj/effect/decal/puzzle_dots/MatchedLinks(id, partners)
	var/obj/machinery/puzzle/password/pin/pad = locate() in partners
	var/list/pass_digits = splittext(pad.password, "")
	var/pass_len = length(pass_digits)
	var/extra_rows = CEILING((pass_len/MAX_PUZZLE_DOTS_PER_ROW)-1, 1)
	if(extra_rows)
		pixel_y += round(extra_rows*(PUZZLE_DOTS_VERTICAL_OFFSET*0.5))
		for(var/i in 1 to extra_rows)
			var/mutable_appearance/row = mutable_appearance(icon, icon_state)
			row.pixel_y = -i*PUZZLE_DOTS_VERTICAL_OFFSET
			add_overlay(row)
	for(var/i in 1 to pass_len)
		var/mutable_appearance/colored_dot = mutable_appearance(icon, "puzzle_dot_single")
		colored_dot.color = pad.digit_to_color[pass_digits[i]]
		colored_dot.pixel_x = PUZZLE_DOTS_HORIZONTAL_OFFSET * ((i-1)%MAX_PUZZLE_DOTS_PER_ROW)
		colored_dot.pixel_y -= CEILING((i/MAX_PUZZLE_DOTS_PER_ROW)-1, 1)*PUZZLE_DOTS_VERTICAL_OFFSET
		add_overlay(colored_dot)

#undef MAX_PUZZLE_DOTS_PER_ROW
#undef PUZZLE_DOTS_VERTICAL_OFFSET
#undef PUZZLE_DOTS_HORIZONTAL_OFFSET


/obj/effect/decal/cleanable/crayon/puzzle
	name = "Password character"
	icon_state = "0"
	///The id of the puzzle we're linked to.
	var/puzzle_id

/obj/effect/decal/cleanable/crayon/puzzle/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

/obj/effect/decal/cleanable/crayon/puzzle/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null)
	. = ..()
	name = "number"
	if(puzzle_id)
		SSqueuelinks.add_to_queue(src, puzzle_id)

/obj/effect/decal/cleanable/crayon/puzzle/MatchedLinks(id, partners)
	var/obj/machinery/puzzle/password/pad = locate() in partners
	var/list/pass_character = splittext(pad.password, "")
	var/chosen_character = icon_state
	if(!findtext(chosen_character, GLOB.is_alphanumeric))
		qdel(src)
		return FALSE
	icon_state = pick(pass_character)
	if(!text2num(icon_state))
		name = "letter"
		desc = "A letter vandalizing the station."
	return TRUE

/obj/effect/decal/cleanable/crayon/puzzle/pin
	name = "PIN number"

/obj/effect/decal/cleanable/crayon/puzzle/pin/MatchedLinks(id, partners)
	. = ..()
	var/obj/machinery/puzzle/password/pin/pad = locate() in partners
	add_atom_colour(pad.digit_to_color[icon_state], FIXED_COLOUR_PRIORITY)

/obj/item/paper/fluff/scrambled_pass
	name = "gibberish note"
	icon_state = "scrap"
	///The ID associated to the puzzle we're part of.
	var/puzzle_id

/obj/item/paper/fluff/scrambled_pass/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

/obj/item/paper/fluff/scrambled_pass/Initialize(mapload)
	. = ..()
	if(mapload && puzzle_id)
		SSqueuelinks.add_to_queue(src, puzzle_id)

/obj/item/paper/fluff/scrambled_pass/MatchedLinks(id, partners)
	var/obj/machinery/puzzle/password/pad = locate() in partners
	var/scrambled_text = ""
	var/list/pass_characters = splittext(pad.password, "")
	for(var/i in 1 to rand(200, 300))
		scrambled_text += pick(pass_characters)
	add_raw_text(scrambled_text)
