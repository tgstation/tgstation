///Energy used to say an error message.
#define ENERGY_TO_SPEAK (0.001 * STANDARD_CELL_CHARGE)

/**
 * # N-spect scanner
 *
 * Creates reports for area inspection bounties.
 */
/obj/item/inspector
	name = "\improper N-spect scanner"
	desc = "Central Command standard issue inspection device. \
	Performs wide area scan reports for inspectors to use to verify the security and integrity of the station. \
	Can additionally be used for precision scans to determine if an item contains, or is itself, contraband."
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "inspector"
	worn_icon_state = "salestagger"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	interaction_flags_click = NEED_DEXTERITY
	throw_range = 1
	throw_speed = 1
	///How long it takes to print on time each mode, ordered NORMAL, FAST, HONK
	var/list/time_list = list(5 SECONDS, 1 SECONDS, 0.1 SECONDS)
	///Which print time mode we're on.
	var/time_mode = INSPECTOR_TIME_MODE_SLOW
	///determines the sound that plays when printing a report
	var/print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL
	///Power cell used to power the scanner. Paths g
	var/obj/item/stock_parts/power_store/cell = /obj/item/stock_parts/power_store/cell/crap
	///Cell cover status
	var/cell_cover_open = FALSE
	///Energy used per print.
	var/energy_per_print = INSPECTOR_ENERGY_USAGE_NORMAL
	///Does this item scan for contraband correctly? If not, will provide a flipped response.
	var/scans_correctly = TRUE

/obj/item/inspector/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	register_context()
	register_item_context()

// Clean up the cell on destroy
/obj/item/inspector/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null

// support for items that interact with the cell
/obj/item/inspector/get_cell()
	return cell

/obj/item/inspector/attack_self(mob/user)
	. = ..()
	if(do_after(user, time_list[time_mode], target = user, progress=TRUE))
		print_report(user)

/obj/item/inspector/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.combat_mode)
		return
	cell_cover_open = !cell_cover_open
	balloon_alert(user, "[cell_cover_open ? "opened" : "closed"] cell cover")
	return TRUE

/obj/item/inspector/attackby(obj/item/I, mob/user, params)
	if(cell_cover_open && istype(I, /obj/item/stock_parts/power_store/cell))
		if(cell)
			to_chat(user, span_warning("[src] already has a cell installed."))
			return
		if(user.transferItemToLoc(I, src))
			cell = I
			to_chat(user, span_notice("You successfully install \the [cell] into [src]."))
			return
	return ..()

/obj/item/inspector/item_ctrl_click(mob/user)
	if(!cell_cover_open || !cell)
		return CLICK_ACTION_BLOCKING
	user.visible_message(span_notice("[user] removes \the [cell] from [src]!"), \
		span_notice("You remove [cell]."))
	cell.add_fingerprint(user)
	user.put_in_hands(cell)
	cell = null
	return CLICK_ACTION_SUCCESS

/obj/item/inspector/examine(mob/user)
	. = ..()
	. += span_info("Use in-hand to scan the local area, creating an encrypted security inspection.")
	. += span_info("Use on an item to scan if it contains, or is, contraband.")
	if(!cell_cover_open)
		. += span_notice("Its cell cover is closed. It looks like it could be <strong>pried</strong> out, but doing so would require an appropriate tool.")
		return
	. += span_notice("Its cell cover is open, exposing the cell slot. It looks like it could be <strong>pried</strong> in, but doing so would require an appropriate tool.")
	if(!cell)
		. += span_notice("The slot for a cell is empty.")
	else
		. += span_notice("\The [cell] is firmly in place. Ctrl-click with an empty hand to remove it.")

/obj/item/inspector/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!user.Adjacent(interacting_with))
		return ITEM_INTERACT_BLOCKING
	if(cell_cover_open)
		balloon_alert(user, "close cover first!")
		return ITEM_INTERACT_BLOCKING
	if(!cell || !cell.use(INSPECTOR_ENERGY_USAGE_LOW))
		balloon_alert(user, "check cell!")
		return ITEM_INTERACT_BLOCKING

	if(iscarbon(interacting_with)) // Prevents scanning people
		return

	if(contraband_scan(interacting_with, user))
		playsound(src, 'sound/machines/uplink/uplinkerror.ogg', 40)
		balloon_alert(user, "contraband detected!")
		return ITEM_INTERACT_SUCCESS
	else
		playsound(src, 'sound/machines/ping.ogg', 20)
		balloon_alert(user, "clear")
		return ITEM_INTERACT_SUCCESS


/obj/item/inspector/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	var/update_context = FALSE
	if(cell_cover_open && cell)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove cell"
		update_context = TRUE

	if(cell_cover_open && !cell && istype(held_item, /obj/item/stock_parts/power_store/cell))
		context[SCREENTIP_CONTEXT_LMB] = "Install cell"
		update_context = TRUE

	if(held_item?.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "[cell_cover_open ? "close" : "open"] battery panel"
		update_context = TRUE

	if(update_context)
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/item/inspector/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(cell_cover_open || !cell)
		return NONE
	if(isitem(target))
		context[SCREENTIP_CONTEXT_LMB] = "Contraband Scan"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/**
 * Scans the carbon or item for contraband.
 *
 * Arguments:
 * - scanned - what or who is scanned?
 * - user - who is performing the scanning?
 */
/obj/item/inspector/proc/contraband_scan(scanned, user)
	if(iscarbon(scanned))
		var/mob/living/carbon/scanned_carbon = scanned
		for(var/obj/item/content in scanned_carbon.get_all_contents_skipping_traits(TRAIT_CONTRABAND_BLOCKER))
			var/contraband_content = content.is_contraband()
			if((contraband_content && scans_correctly) || (!contraband_content && !scans_correctly))
				return TRUE

	if(isitem(scanned))
		var/obj/item/contraband_item = scanned
		var/contraband_status = contraband_item.is_contraband()
		if((contraband_status && scans_correctly) || (!contraband_status && !scans_correctly))
			return TRUE

	return FALSE

/**
 * Create our report
 *
 * Arguments:
 */
/obj/item/inspector/proc/create_slip()
	var/obj/item/paper/report/slip = new(get_turf(src))
	slip.generate_report(get_area(src))

/**
 * Prints out a report for bounty purposes, and plays a short audio blip.
 *
 * Arguments:
*/
/obj/item/inspector/proc/print_report(mob/user)
	if(!cell)
		to_chat(user, span_info("\The [src] doesn't seem to be on... It feels quite light. Perhaps it lacks a power cell?"))
		return
	if(cell.charge == 0)
		to_chat(user, span_info("\The [src] doesn't seem to be on... Perhaps it ran out of power?"))
		return
	if(!cell.use(energy_per_print))
		if(cell.use(ENERGY_TO_SPEAK))
			say("ERROR! POWER CELL CHARGE LEVEL TOO LOW TO PRINT REPORT!")
		return

	create_slip()
	switch(print_sound_mode)
		if(INSPECTOR_PRINT_SOUND_MODE_NORMAL)
			playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)
		if(INSPECTOR_PRINT_SOUND_MODE_CLASSIC)
			playsound(src, 'sound/items/biddledeep.ogg', 50, FALSE)
		if(INSPECTOR_PRINT_SOUND_MODE_HONK)
			playsound(src, 'sound/items/bikehorn.ogg', 50, FALSE)
		if(INSPECTOR_PRINT_SOUND_MODE_FAFAFOGGY)
			playsound(src, pick(list('sound/items/robofafafoggy.ogg', 'sound/items/robofafafoggy2.ogg')), 50, FALSE)

/obj/item/paper/report
	name = "encrypted station inspection"
	desc = "Contains no information about the station's current status."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "slip"
	///What area the inspector scanned when the report was made. Used to verify the security bounty.
	var/area/scanned_area
	show_written_words = FALSE

/obj/item/paper/report/proc/generate_report(area/scan_area)
	scanned_area = scan_area
	icon_state = "slipfull"
	desc = "Contains detailed information about the station's current status."

	var/list/characters = list()
	characters += GLOB.alphabet
	characters += GLOB.alphabet_upper
	characters += GLOB.numerals

	var/report_text = random_string(rand(180,220), characters)
	report_text += "[prob(50) ? "=" : "=="]" //Based64 encoding

	add_raw_text(report_text)
	update_appearance()

/obj/item/paper/report/examine(mob/user)
	. = ..()
	if(scanned_area?.name)
		. += span_notice("\The [src] contains data on [scanned_area.name].")
	else if(scanned_area)
		. += span_notice("\The [src] contains data on a vague area on station, you should throw it away.")
	else if(get_total_length())
		icon_state = "slipfull"
		. += span_notice("Wait a minute, this isn't an encrypted inspection report! You should throw it away.")
	else
		. += span_notice("Wait a minute, this thing's blank! You should throw it away.")

/**
 * # Fake N-spect scanner
 *
 * A clown variant of the N-spect scanner
 *
 * This prints fake reports with garbage in them,
 * can be set to print them instantly with a screwdriver.
 * By default it plays the old "woody" scanning sound, scanning sounds can be cycled by clicking with a multitool.
 * Can be crafted into a bananium HONK-spect scanner
 */
/obj/item/inspector/clown
	scans_correctly = FALSE
	///will only cycle through modes with numbers lower than this
	var/max_mode = CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST
	///names of modes, ordered first to last
	var/list/mode_names = list("normal", "classic", "honk", "fafafoggy")

/obj/item/inspector/clown/attack(mob/living/M, mob/living/user)
	. = ..()
	print_report(user)

/obj/item/inspector/clown/screwdriver_act(mob/living/user, obj/item/tool)
	if(!cell_cover_open)
		return ..()
	cycle_print_time(user)
	return TRUE

/obj/item/inspector/clown/attackby(obj/item/I, mob/user, params)
	if(cell_cover_open && istype(I, /obj/item/kitchen/fork))
		cycle_sound(user)
		return
	return ..()

/obj/item/inspector/clown/examine(mob/user)
	. = ..()
	if(cell_cover_open)
		. += "Two weird settings dials are visible within the battery compartment."

/obj/item/inspector/clown/examine_more(mob/user)
	if(!cell_cover_open)
		return ..()
	. = list(span_notice("Both setting dials are flush with the surface of the battery compartment, and seem to be impossible to move with bare hands."))
	. += "\t[span_info("The first dial is labeled \"SPEED\" and looks a bit like a <strong>screw</strong> head.")]"
	. += "\t[span_info("The second dial is labeled \"SOUND\". It has four small holes in it. Perhaps it can be turned with a fork?")]"
	. += "\t[span_info("A small bananium part labeled \"ADVANCED WATER CHIP 23000000\" is visible within the battery compartment. It looks completely unlike normal modern electronics, disturbing it would be rather unwise.")]"


/obj/item/inspector/clown/proc/cycle_print_time(mob/user)
	var/message
	if(time_mode == INSPECTOR_TIME_MODE_FAST)
		time_mode = INSPECTOR_TIME_MODE_SLOW
		message = "SLOW."
	else
		time_mode = INSPECTOR_TIME_MODE_FAST
		message = "LIGHTNING FAST."

	balloon_alert(user, "scanning speed set to [message]")

/obj/item/inspector/clown/proc/cycle_sound(mob/user)
	print_sound_mode++
	if(print_sound_mode > max_mode)
		print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL
	balloon_alert(user, "bleep setting set to [mode_names[print_sound_mode]]")

/obj/item/inspector/clown/create_slip()
	var/obj/item/paper/fake_report/slip = new(get_turf(src))
	slip.generate_report(get_area(src))

/**
 * # Bananium HONK-spect scanner
 *
 * An upgraded version of the fake N-spect scanner
 *
 * Can print things way faster, at full power the reports printed by this will destroy
 * themselves and leave water behind when folding is attempted by someone who isn't an
 * origami master. Printing at full power costs INSPECTOR_ENERGY_USAGE_HONK cell units
 * instead of INSPECTOR_ENERGY_USAGE_NORMAL cell units.
 */
/obj/item/inspector/clown/bananium
	name = "\improper Bananium HONK-spect scanner"
	desc = "Honkmother-blessed inspection device. Performs inspections according to Clown protocols when activated, then \
			prints a clowncrypted report regarding the maintenance of the station. Hard to replace."
	icon = 'icons/obj/tools.dmi'
	icon_state = "bananium_inspector"
	w_class = WEIGHT_CLASS_SMALL
	max_mode = BANANIUM_CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST
	///How many more times can we print?
	var/paper_charges = 32
	///Max value of paper_charges
	var/max_paper_charges = 32
	///How much charges are restored per paper consumed
	var/charges_per_paper = 1

/obj/item/inspector/clown/bananium/proc/check_settings_legality()
	if(print_sound_mode == INSPECTOR_PRINT_SOUND_MODE_NORMAL && time_mode == INSPECTOR_TIME_MODE_HONK)
		if(cell.use(ENERGY_TO_SPEAK))
			say("Setting combination forbidden by Geneva convention revision CCXXIII selected, reverting to defaults")
		time_mode = INSPECTOR_TIME_MODE_SLOW
		print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL
		energy_per_print = INSPECTOR_ENERGY_USAGE_NORMAL

/obj/item/inspector/clown/bananium/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	check_settings_legality()
	return TRUE

/obj/item/inspector/clown/bananium/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(cell_cover_open)
		check_settings_legality()
	if(istype(I, /obj/item/paper/fake_report) || paper_charges >= max_paper_charges)
		to_chat(user, span_info("\The [src] refuses to consume \the [I]!"))
		return
	if(istype(I, /obj/item/paper))
		to_chat(user, span_info("\The [src] consumes \the [I]!"))
		paper_charges = min(paper_charges + charges_per_paper, max_paper_charges)
		qdel(I)

/obj/item/inspector/clown/bananium/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/effects/angryboat.ogg', 150, FALSE)

/obj/item/inspector/clown/bananium/create_slip()
	if(time_mode == INSPECTOR_TIME_MODE_HONK)
		var/obj/item/paper/fake_report/water/slip = new(get_turf(src))
		slip.generate_report(get_area(src))
		return
	return ..()

/obj/item/inspector/clown/bananium/print_report(mob/user)
	if(time_mode != INSPECTOR_TIME_MODE_HONK)
		return ..()
	if(paper_charges == 0)
		if(cell.use(ENERGY_TO_SPEAK))
			say("ERROR! OUT OF PAPER! MAXIMUM PRINTING SPEED UNAVAIBLE! SWITCH TO A SLOWER SPEED TO OR PROVIDE PAPER!")
		else
			to_chat(user, span_info("\The [src] doesn't seem to be on... Perhaps it ran out of power?"))
		return
	paper_charges--
	return ..()

/obj/item/inspector/clown/bananium/cycle_print_time(mob/user)
	var/message
	switch(time_mode)
		if(INSPECTOR_TIME_MODE_HONK)
			energy_per_print = INSPECTOR_ENERGY_USAGE_NORMAL
			time_mode = INSPECTOR_TIME_MODE_SLOW
			message = "SLOW."
		if(INSPECTOR_TIME_MODE_SLOW)
			time_mode = INSPECTOR_TIME_MODE_FAST
			message = "LIGHTNING FAST."
		else
			time_mode = INSPECTOR_TIME_MODE_HONK
			energy_per_print = INSPECTOR_ENERGY_USAGE_HONK
			message = "HONK!"
	balloon_alert(user, "scanning speed set to [message]")

/**
 * Reports printed by fake N-spect scanner
 *
 * Not valid for the bounty.
 */
/obj/item/paper/fake_report
	name = "encrypted station inspection"
	desc = "Contains no information about the station's current status."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "slip"
	show_written_words = FALSE
	///What area the inspector scanned when the report was made. Used to generate the examine text of the report
	var/area/scanned_area

/obj/item/paper/fake_report/proc/generate_report(area/scan_area)
	scanned_area = scan_area
	icon_state = "slipfull"

	var/list/new_info = list()
	for(var/i in 1 to rand(23, 123))
		var/roll = rand(0, 1000)
		switch(roll)
			if(0 to 900)
				new_info += pick_list_replacements(CLOWN_NONSENSE_FILE, "honk")
			if(901 to 999)
				new_info += pick_list_replacements(CLOWN_NONSENSE_FILE, "non-honk-clown-words")
			if(1000)
				new_info += pick_list_replacements(CLOWN_NONSENSE_FILE, "rare")
	add_raw_text(new_info.Join())
	update_appearance()

/obj/item/paper/fake_report/examine(mob/user)
	. = ..()
	if(scanned_area?.name)
		. += span_notice("\The [src] contains no data on [scanned_area.name].")
	else if(scanned_area)
		. += span_notice("\The [src] contains no data on a vague area on station, you should throw it away.")
	else if(get_total_length())
		. += span_notice("Wait a minute, this isn't an encrypted inspection report! You should throw it away.")
	else
		. += span_notice("Wait a minute, this thing's blank! You should throw it away.")

/**
 * # Fake report made of water
 *
 * Fake report but it turns into water under certain circumstances.
 *
 * If someone who isn't an origami master tries to fold it into a paper plane, it will make the floor it's on wet and disappear.
 * If it is ground, it will turn into 5u water.
 */
/obj/item/paper/fake_report/water
	grind_results = list(/datum/reagent/water = 5)
	interaction_flags_click = NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING

/obj/item/paper/fake_report/water/click_alt(mob/living/user)
	var/datum/action/innate/origami/origami_action = locate() in user.actions
	if(origami_action?.active) //Origami masters can fold water
		make_plane(user, /obj/item/paperplane/syndicate)
	else if(do_after(user, 1 SECONDS, target = src, progress=TRUE))
		var/turf/open/target = get_turf(src)
		target.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)
		to_chat(user, span_notice("As you try to fold [src] into the shape of a plane, it disintegrates into water!"))
		qdel(src)
	return CLICK_ACTION_SUCCESS

#undef ENERGY_TO_SPEAK
