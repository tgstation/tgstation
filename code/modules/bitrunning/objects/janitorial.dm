GLOBAL_LIST_INIT(janitorial_reject_type_to_speech, list(
	/mob/living/basic = "Dead organic/synthetic being",
	/mob/living/carbon/human = "Dead humanoid body",
	/mob/living/carbon = "Dead carbon-based lifeform",
	/mob/living/silicon/ai = "Deactivated AI core",
	/mob/living/silicon/robot = "Deactivated cyborg",
	/obj/item/organ = "Organ-based viscera",
	/obj/item/bodypart = "Dismembered body part",
	/obj/item/ammo_casing = "Spent ammunition",
	/obj/item/gun = "Discarded firearm",
	/obj/effect/decal/cleanable/blood = "Blood splatter",
	/obj/effect/decal/cleanable/oil = "Oil splatter",
	/obj/effect/decal/cleanable/xenoblood = "Acidic blood splatter",
	/obj/effect/decal/cleanable/wrapping = "Torn wrapping paper",
	/obj/effect/decal/cleanable/vomit = "Vomit pool",
	/obj/effect/decal/cleanable/traitor_rune = "Subversive graffiti",
	/obj/effect/decal/cleanable/shreds = "Shredded clothing",
	/obj/effect/decal/cleanable/rubble = "Rubble and/or debris",
	/obj/effect/decal/cleanable/robot_debris = "Destroyed robots",
	/obj/effect/decal/cleanable/plastic = "Plastic waste shreds",
	/obj/effect/decal/cleanable/plasma = "Plasma spill",
	/obj/effect/decal/cleanable/molten_object = "Melted grey mass",
	/obj/effect/decal/cleanable/insectguts = "Bug residue",
	/obj/effect/decal/cleanable/greenglow = "Radioactive goo",
	/obj/effect/decal/cleanable/grand_remains = "Magical ritual leftovers",
	/obj/effect/decal/cleanable/glitter = "Glitter",
	/obj/effect/decal/cleanable/glass = "Glass shards",
	/obj/effect/decal/cleanable/food = "Food residue",
	/obj/effect/decal/cleanable/dirt = "Dirt build-up",
	/obj/effect/decal/cleanable/crayon = "Graffiti",
	/obj/effect/decal/cleanable/confetti = "Confetti pile",
	/obj/effect/decal/cleanable/cobweb = "Cobwebs",
	/obj/effect/decal/cleanable/garbage = "Garbage pile",
	/obj/effect/decal/cleanable/fuel_pool = "Fuel spill",
	/obj/effect/decal/cleanable/chem_pile = "Chemical spill",
	/obj/effect/decal/cleanable/brimdust = "Brimdemon dust pile",
	/obj/effect/decal/cleanable/ash = "Ash pile",
	/obj/effect/decal/cleanable/ants = "Anthill"
))

GLOBAL_LIST_EMPTY(janitorial_scanners)

/obj/machinery/janitorial_scanner
	name = "janitorial area scanner"
	desc = "Checks the area around it to see if it's been properly cleaned for the purposes of confirming the job is done."
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "scanner"
	icon_state = "scanner"
	/// What's the name of this area?
	var/area_name = "Debug, change me"
	/// What's our unique identifier? Used to prevent two of the same domain being loaded breaking things.
	var/unique_id = "we rollin' deep"
	/// Our room, shouldn't be modified.
	var/list/our_room

/obj/machinery/janitorial_scanner/Initialize(mapload)
	. = ..()
	GLOB.janitorial_scanners += src

/obj/machinery/janitorial_scanner/proc/scan_area()
	for(var/turf/floor in our_room)
		if(!isopenturf(floor))
			continue
		for(var/atom/possible_disqualifier in floor)
			if(GET_ATOM_BLOOD_DNA_LENGTH(possible_disqualifier))
				src.Beam(get_turf(possible_disqualifier), icon_state = "blood", time = 10 SECONDS)
				return "ERROR: Blood-stained [possible_disqualifier] detected in [area_name]!"
			for(var/path in GLOB.janitorial_reject_type_to_speech)
				if(istype(possible_disqualifier, path))
					src.Beam(get_turf(possible_disqualifier), icon_state = "blood", time = 10 SECONDS)
					return "ERROR: [GLOB.janitorial_reject_type_to_speech[path]] detected in [area_name]!"
			CHECK_TICK
		CHECK_TICK
	return null

/obj/machinery/janitorial_scanner/Destroy(force)
	GLOB.janitorial_scanners -= src
	. = ..()

/obj/machinery/janitorial_submit
	name = "janitorial clock-out plunger"
	desc = "Press this to see if you're ready to clock out. Will let you know what you forgot to clean, and the general area of it."
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "plunger"
	icon_state = "plunger"
	/// What's our unique identifier? Used to prevent two of the same domain being loaded breaking things.
	var/unique_id = "we rollin' deep"
	///Have we deposited a box already?
	var/deposited = FALSE
	///Are we currently scanning?
	var/scanning = FALSE

/obj/machinery/janitorial_submit/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(deposited)
		say("You already finished your job here!")
		return
	if(scanning)
		say("ERROR: Already scanning! Please wait!")
		return
	say("Beginning completion check...")
	scanning = TRUE
	for(var/obj/machinery/janitorial_scanner/scanner in GLOB.janitorial_scanners)
		if(unique_id == scanner.unique_id)
			say("Scanning [scanner.area_name]...")
			var/scanner_results = scanner.scan_area()
			if(!isnull(scanner_results))
				playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
				say(scanner_results)
				scanning = FALSE
				return
			playsound(src, 'sound/machines/ping.ogg', 100, FALSE)
	scanning = FALSE
	deposited = TRUE
	playsound(src, 'sound/machines/ping.ogg', 100, FALSE)
	say("No messes detected! Thank you for being a reformed employee!")
	say("Deposit this box to return to reality!")
	new /obj/structure/closet/crate/secure/bitrunning/encrypted(get_turf(src))

/obj/effect/bitrunner_exit_portal
	name = "exit portal"
	desc = "Exit the domain by clicking here with an empty hand!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "exit_portal"
	icon_state = "exit_portal"

/obj/effect/bitrunner_exit_portal/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	SEND_SIGNAL(user, COMSIG_BITRUNNER_ALERT_SEVER)
