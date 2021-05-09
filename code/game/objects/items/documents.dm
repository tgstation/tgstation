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
	///sound that plays when printing a report
	var/print_sound = 'sound/machines/high_tech_confirm.ogg'
	///time required to print a report
	var/print_time = 5 SECONDS

/obj/item/inspector/attack_self(mob/user)
	. = ..()
	if(do_after(user, print_time, target = user, progress=TRUE))
		print_report()

/**
 * Prints out a report for bounty purposes, and plays a short audio blip.
 *
 * Arguments:
*/
/obj/item/inspector/proc/print_report()
	// Create our report
	var/obj/item/paper/report/slip = new(get_turf(src))
	slip.generate_report(get_area(src))
	playsound(src, print_sound, 50, FALSE)

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
 * By default it plays the old "woody" scanning sound, but it can be set
 * to play the normal N-spect scanner sound with a multitool
 */
/obj/item/inspector/clown
	print_sound = 'sound/items/biddledeep.ogg'

/obj/item/inspector/clown/attack(mob/living/M, mob/living/user)
	. = ..()
	print_report()

/obj/item/inspector/clown/print_report()
	// Create our report
	var/obj/item/paper/fake_report/slip = new(get_turf(src))
	slip.generate_report(get_area(src))
	playsound(src, print_sound, 50, FALSE)

/obj/item/inspector/clown/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(print_sound == 'sound/items/biddledeep.ogg')
			print_sound = 'sound/machines/high_tech_confirm.ogg'
			to_chat(user, "<span class='notice'>You set the device's bleep setting to normal mode")
		else if(print_sound == 'sound/machines/high_tech_confirm.ogg')
			print_sound = 'sound/items/bikehorn.ogg'
			to_chat(user, "<span class='notice'>You set the device's bleep setting to honk mode")
		else
			print_sound = 'sound/items/biddledeep.ogg'
			to_chat(user, "<span class='notice'>You set the device's bleep setting to classic mode")
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(print_time == 0)
			print_time = 5 SECONDS
			to_chat(user, "<span class='notice'>You set the device's scanning speed to SLOW.")
		else
			print_time = 0
			to_chat(user, "<span class='notice'>You set the device's scanning speed setting to LIGHTING FAST.")

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

	var/length = rand(23, 230)
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
