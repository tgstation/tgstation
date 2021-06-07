/obj/item/documents
	name = "secret documents"
	desc = "\"Top Secret\" documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	inhand_icon_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = MOB_LAYER
	pressure_resistance = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/documents/nanotrasen
	desc = "\"Top Secret\" Nanotrasen documents, filled with complex diagrams and lists of names, dates and coordinates."
	icon_state = "docs_verified"

/obj/item/documents/syndicate
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence."

/obj/item/documents/syndicate/red
	name = "red secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. These documents are verified with a red wax seal."
	icon_state = "docs_red"

/obj/item/documents/syndicate/blue
	name = "blue secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. These documents are verified with a blue wax seal."
	icon_state = "docs_blue"

/obj/item/documents/syndicate/mining
	desc = "\"Top Secret\" documents detailing Syndicate plasma mining operations."

/obj/item/documents/photocopy
	desc = "A copy of some top-secret documents. Nobody will notice they aren't the originals... right?"
	var/forgedseal = 0
	var/copy_type = null

/obj/item/documents/photocopy/New(loc, obj/item/documents/copy=null)
	..()
	if(copy)
		copy_type = copy.type
		if(istype(copy, /obj/item/documents/photocopy)) // Copy Of A Copy Of A Copy
			var/obj/item/documents/photocopy/C = copy
			copy_type = C.copy_type

/obj/item/documents/photocopy/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/toy/crayon/red) || istype(O, /obj/item/toy/crayon/blue))
		if (forgedseal)
			to_chat(user, "<span class='warning'>You have already forged a seal on [src]!</span>")
		else
			var/obj/item/toy/crayon/C = O
			name = "[C.crayon_color] secret documents"
			icon_state = "docs_[C.crayon_color]"
			forgedseal = C.crayon_color
			to_chat(user, "<span class='notice'>You forge the official seal with a [C.crayon_color] crayon. No one will notice... right?</span>")
			update_appearance()

/**
 * # N-spect scanner
 *
 * Creates reports for area inspection bounties.
 */
/obj/item/inspector
	name = "\improper N-spect scanner"
	desc = "Central Command-issued inspection device. Performs inspections according to Nanotrasen protocols when activated, then \
			prints an encrypted report regarding the maintenance of the station. Hard to replace."
	icon = 'icons/obj/device.dmi'
	icon_state = "inspector"
	worn_icon_state = "salestagger"
	inhand_icon_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	///How long it takes to print on time each mode, ordered NORMAL, FAST, HONK
	var/list/time_list = list(5 SECONDS, 1 SECONDS, 0.1 SECONDS)
	///Which print time mode we're on.
	var/time_mode = INSPECTOR_TIME_MODE_SLOW
	///determines the sound that plays when printing a report
	var/print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL
	///Power cell used to power the scanner. Paths g
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/crap
	///Cell cover status
	var/cell_cover_open = FALSE
	///Power used per print in cell units
	var/power_per_print = INSPECTOR_POWER_USAGE_NORMAL
	///Power used to say an error message
	var/power_to_speak = 1

/obj/item/inspector/Initialize()
	. = ..()
	if(ispath(cell))
		cell = new cell(src)

// Clean up the cell on destroy
/obj/item/clothing/suit/space/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

// Clean up the cell on destroy
/obj/item/inspector/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
	return ..()

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
	balloon_alert(user, "You [cell_cover_open ? "open" : "close"] the cell cover on \the [src].")
	return TRUE


/obj/item/inspector/attackby(obj/item/I, mob/user, params)
	if(cell_cover_open && istype(I, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell installed.</span>")
			return
		if(user.transferItemToLoc(I, src))
			cell = I
			to_chat(user, "<span class='notice'>You successfully install \the [cell] into [src].</span>")
			return
	return ..()

/obj/item/inspector/CtrlClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)) || !cell_cover_open || !cell)
		return ..()
	user.visible_message("<span class='notice'>[user] removes \the [cell] from [src]!</span>", \
		"<span class='notice'>You remove [cell].</span>")
	cell.add_fingerprint(user)
	user.put_in_hands(cell)
	cell = null


/obj/item/inspector/examine(mob/user)
	. = ..()
	if(!cell_cover_open)
		. += "Its cell cover is closed. It looks like it could be <strong>pried</strong> out, but doing so would require an appropriate tool."
		return
	. += "It's cell cover is open, exposing the cell slot. It looks like it could be <strong>pried</strong> in, but doing so would require an appropriate tool."
	if(!cell)
		. += "The slot for a cell is empty."
	else
		. += "\The [cell] is firmly in place. <span class='info'>Ctrl-click with an empty hand to remove it.</span>"

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
		to_chat(user, "<span class='info'>\The [src] doesn't seem to be on... It feels quite light. Perhaps it lacks a power cell?")
		return
	if(cell.charge == 0)
		to_chat(user, "<span class='info'>\The [src] doesn't seem to be on... Perhaps it ran out of power?")
		return
	if(!cell.use(power_per_print))
		if(cell.use(power_to_speak))
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
	icon = 'icons/obj/bureaucracy.dmi'
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

	info = random_string(rand(180,220), characters)
	info += "[prob(50) ? "=" : "=="]" //Based64 encoding

/obj/item/paper/report/examine(mob/user)
	. = ..()
	if(scanned_area?.name)
		. += "<span class='notice'>\The [src] contains data on [scanned_area.name].</span>"
	else if(scanned_area)
		. += "<span class='notice'>\The [src] contains data on a vague area on station, you should throw it away.</span>"
	else if(info)
		icon_state = "slipfull"
		. += "<span class='notice'>Wait a minute, this isn't an encrypted inspection report! You should throw it away.</span>"
	else
		. += "<span class='notice'>Wait a minute, this thing's blank! You should throw it away.</span>"

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
	. = list("<span class='notice'>Both setting dials are flush with the surface of the battery compartment, and seem to be impossible to move with bare hands.</span>")
	. += "\t<span class='info'>The first dial is labeled \"SPEED\" and looks a bit like a <strong>screw</strong> head.</span>"
	. += "\t<span class='info'>The second dial is labeled \"SOUND\". It has four small holes in it. Perhaps it can be turned with a fork?</span>"
	. += "\t<span class='info'>A small bananium part labeled \"ADVANCED WATER CHIP 23000000\" is visible within the battery compartment. It looks completely unlike normal modern electronics, disturbing it would be rather unwise.</span>"


/obj/item/inspector/clown/proc/cycle_print_time(mob/user)
	var/message
	if(time_mode == INSPECTOR_TIME_MODE_FAST)
		time_mode = INSPECTOR_TIME_MODE_SLOW
		message = "SLOW."
	else
		time_mode = INSPECTOR_TIME_MODE_FAST
		message = "LIGHTNING FAST."

	balloon_alert(user, "You turn the screw-like dial, setting the device's scanning speed to [message]")

/obj/item/inspector/clown/proc/cycle_sound(mob/user)
	print_sound_mode++
	if(print_sound_mode > max_mode)
		print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL
	balloon_alert(user, "You turn the dial with holes in it, setting the device's bleep setting to [mode_names[print_sound_mode]] mode.")

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
 * origami master. Printing at full power costs INSPECTOR_POWER_USAGE_HONK cell units
 * instead of INSPECTOR_POWER_USAGE_NORMAL cell units.
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
		if(cell.use(power_to_speak))
			say("Setting combination forbidden by Geneva convention revision CCXXIII selected, reverting to defaults")
		time_mode = INSPECTOR_TIME_MODE_SLOW
		print_sound_mode = INSPECTOR_PRINT_SOUND_MODE_NORMAL
		power_per_print = INSPECTOR_POWER_USAGE_NORMAL

/obj/item/inspector/clown/bananium/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	check_settings_legality()
	return TRUE

/obj/item/inspector/clown/bananium/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(cell_cover_open)
		check_settings_legality()
	if(istype(I, /obj/item/paper/fake_report) || paper_charges >= max_paper_charges)
		to_chat(user, "<span class='info'>\The [src] refuses to consume \the [I]!</span>")
		return
	if(istype(I, /obj/item/paper))
		to_chat(user, "<span class='info'>\The [src] consumes \the [I]!</span>")
		paper_charges = min(paper_charges + charges_per_paper, max_paper_charges)
		qdel(I)

/obj/item/inspector/clown/bananium/Initialize()
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
		if(cell.use(power_to_speak))
			say("ERROR! OUT OF PAPER! MAXIMUM PRINTING SPEED UNAVAIBLE! SWITCH TO A SLOWER SPEED TO OR PROVIDE PAPER!")
		else
			to_chat(user, "<span class='info'>\The [src] doesn't seem to be on... Perhaps it ran out of power?")
		return
	paper_charges--
	return ..()

/obj/item/inspector/clown/bananium/cycle_print_time(mob/user)
	var/message
	switch(time_mode)
		if(INSPECTOR_TIME_MODE_HONK)
			power_per_print = INSPECTOR_POWER_USAGE_NORMAL
			time_mode = INSPECTOR_TIME_MODE_SLOW
			message = "SLOW."
		if(INSPECTOR_TIME_MODE_SLOW)
			time_mode = INSPECTOR_TIME_MODE_FAST
			message = "LIGHTNING FAST."
		else
			time_mode = INSPECTOR_TIME_MODE_HONK
			power_per_print = INSPECTOR_POWER_USAGE_HONK
			message = "HONK!"
	balloon_alert(user, "You turn the screw-like dial, setting the device's scanning speed to [message]")

/**
 * Reports printed by fake N-spect scanner
 *
 * Not valid for the bounty.
 */
/obj/item/paper/fake_report
	name = "encrypted station inspection"
	desc = "Contains no information about the station's current status."
	icon = 'icons/obj/bureaucracy.dmi'
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
	info += new_info.Join()

/obj/item/paper/fake_report/examine(mob/user)
	. = ..()
	if(scanned_area?.name)
		. += "<span class='notice'>\The [src] contains no data on [scanned_area.name].</span>"
	else if(scanned_area)
		. += "<span class='notice'>\The [src] contains no data on a vague area on station, you should throw it away.</span>"
	else if(info)
		. += "<span class='notice'>Wait a minute, this isn't an encrypted inspection report! You should throw it away.</span>"
	else
		. += "<span class='notice'>Wait a minute, this thing's blank! You should throw it away.</span>"

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

/obj/item/paper/fake_report/water/AltClick(mob/living/user, obj/item/I)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	var/datum/action/innate/origami/origami_action = locate() in user.actions
	if(origami_action?.active) //Origami masters can fold water
		make_plane(user, I, /obj/item/paperplane/syndicate)
	else if(do_after(user, 1 SECONDS, target = src, progress=TRUE))
		var/turf/open/target = get_turf(src)
		target.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)
		to_chat(user, "<span class='notice'>As you try to fold [src] into the shape of a plane, it disintegrates into water!</span>")
		qdel(src)
