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
	///time required to print a report
	var/print_time = 5 SECONDS

/obj/item/inspector/attack_self(mob/user)
	. = ..()
	if(do_after(user, print_time, target = user, progress=TRUE))
		print_report()

/**
 * Create our report
 *
 * Arguments:
 */
/obj/item/inspector/proc/create_slip()
	var/obj/item/paper/report/slip = new(get_turf(src))
	slip.generate_report(get_area(src))

/obj/item/inspector/proc/play_sound()
	playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)

/**
 * Prints out a report for bounty purposes, and plays a short audio blip.
 *
 * Arguments:
*/
/obj/item/inspector/proc/print_report()
	create_slip()
	play_sound()

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
	///determines the sound that plays when printing a report
	var/print_sound_mode = CLOWN_INSPECTOR_PRINT_SOUND_MODE_CLASSIC
	///will only cycle through modes with numbers lower than this
	var/max_mode = CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST
	///names of modes, ordered first to last
	var/mode_names = list("normal", "classic", "honk", "bababooey", "bababooey (varied)", "bwoink")

/obj/item/inspector/clown/attack(mob/living/M, mob/living/user)
	. = ..()
	print_report()

/obj/item/inspector/clown/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		cycle_sound(user)
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		cycle_print_time(user)

/obj/item/inspector/clown/proc/cycle_print_time(mob/user)
	if(print_time == 1 SECONDS)
		print_time = 5 SECONDS
		to_chat(user, "<span class='notice'>You set the device's scanning speed to SLOW.")
	else
		print_time = 1 SECONDS
		to_chat(user, "<span class='notice'>You set the device's scanning speed setting to LIGHTNING FAST.")

/obj/item/inspector/clown/proc/cycle_sound(mob/user)
	print_sound_mode++
	if(print_sound_mode > max_mode)
		print_sound_mode = CLOWN_INSPECTOR_PRINT_SOUND_MODE_NORMAL
	to_chat(user, "<span class='notice'>You set the device's bleep setting to [mode_names[print_sound_mode]] mode")

/obj/item/inspector/clown/create_slip()
	var/obj/item/paper/fake_report/slip = new(get_turf(src))
	slip.generate_report(get_area(src))

/obj/item/inspector/clown/play_sound()
	switch(print_sound_mode)
		if(CLOWN_INSPECTOR_PRINT_SOUND_MODE_NORMAL)
			playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)
		if(CLOWN_INSPECTOR_PRINT_SOUND_MODE_CLASSIC)
			playsound(src, 'sound/items/biddledeep.ogg', 50, FALSE)
		if(CLOWN_INSPECTOR_PRINT_SOUND_MODE_HONK)
			playsound(src, 'sound/items/bikehorn.ogg', 50, FALSE)
		if(CLOWN_INSPECTOR_PRINT_SOUND_MODE_BABABOOEY)
			playsound(src, pick(list('sound/items/bababooey.ogg', 'sound/items/bababooey2.ogg')), 50, FALSE)
		if(CLOWN_INSPECTOR_PRINT_SOUND_MODE_BABABOOEY_ALT)
			playsound(src, pick(list('sound/items/bababooey.ogg', 'sound/items/bababooey2.ogg')), 50, TRUE)
		if(BANANIUM_INSPECTOR_PRINT_SOUND_MODE_BWOINK)
			playsound(src, 'sound/effects/adminhelp.ogg', 50, FALSE)

/**
 * # Bananium HONK-spect scanner
 *
 * An upgraded version of the fake N-spect scanner
 *
 * Can print things way faster, at full power the reports printed by this will destroy
 * themselves and leave water behind when folding is attempted by someone who isn't an
 * origami master.
 */
/obj/item/inspector/clown/bananium
	name = "\improper Bananium HONK-spect scanner"
	desc = "Honkmother-blessed inspection device. Performs inspections according to Clown protocols when activated, then \
			prints a clowncrypted report regarding the maintenance of the station. Hard to replace."
	icon_state = "bananium_inspector"
	w_class = WEIGHT_CLASS_SMALL
	max_mode = BANANIUM_INSPECTOR_PRINT_SOUND_MODE_LAST

/obj/item/inspector/clown/bananium/Initialize()
	. = ..()
	playsound(src, 'sound/effects/angryboat.ogg', 150, FALSE)

/obj/item/inspector/clown/bananium/create_slip()
	if(print_time == 0.1 SECONDS)
		var/obj/item/paper/fake_report/water/slip = new(get_turf(src))
		slip.generate_report(get_area(src))
	else
		..()

/obj/item/inspector/clown/bananium/cycle_print_time(mob/user)
	if(print_time == 0.1 SECONDS)
		print_time = 5 SECONDS
		to_chat(user, "<span class='notice'>You set the device's scanning speed to SLOW.")
	else if(print_time == 5 SECONDS)
		print_time = 1 SECONDS
		to_chat(user, "<span class='notice'>You set the device's scanning speed setting to LIGHTNING FAST.")
	else
		print_time = 0.1 SECONDS
		to_chat(user, "<span class='notice'>You set the device's scanning speed setting to HONK.")

/obj/item/inspector/clown/bananium/examine_more(mob/user)
	return list("<span class='info'>You can adjust [src]'s scanning sound with a multitool</span>", "<span class='info'>You can adjust [src]'s scanning speed with a screwdriver</span>")

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
	///What area the inspector scanned when the report was made. Used to generate the examine text of the report
	var/area/scanned_area
	show_written_words = FALSE

/obj/item/paper/fake_report/proc/generate_report(area/scan_area)
	scanned_area = scan_area
	icon_state = "slipfull"

	var/list/characters = list()
	characters += GLOB.alphabet
	characters += GLOB.alphabet_upper
	characters += GLOB.numerals

	var/length = rand(23, 123)
	var/i
	for(i = 0; i<length; i++)
		if(prob(90))
			info += pick_list_replacements(CLOWN_NONSENSE_FILE, "honk")
		else if(prob(1))
			info += pick_list_replacements(CLOWN_NONSENSE_FILE, "rare")
		else
			info += pick_list_replacements(CLOWN_NONSENSE_FILE, "bad")

/obj/item/paper/fake_report/examine(mob/user)
	. = ..()
	if(scanned_area?.name)
		. += "<span class='notice'>\The [src] contains no data on [scanned_area.name].</span>"
	else if(scanned_area)
		. += "<span class='notice'>\The [src] contains no data on a vague area on station, you should throw it away.</span>"
	else if(info)
		icon_state = "slipfull"
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
		to_chat(user, "<span class='notice'>You fold [src] into the shape of a plane!</span>")
		user.temporarilyRemoveItemFromInventory(src)
		I = new /obj/item/paperplane/syndicate(loc, src)
		if(user.Adjacent(I))
			user.put_in_hands(I)
	else
		var/turf/open/target = get_turf(src)
		target.MakeSlippery(TURF_WET_WATER, min_wet_time = 100, wet_time_to_add = 50)
		to_chat(user, "<span class='notice'>As you try to fold [src] into the shape of a plane, it disintegrates into water!</span>")
		qdel(src)
