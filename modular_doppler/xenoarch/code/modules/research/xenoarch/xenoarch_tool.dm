/obj/item/xenoarch
	name = "parent dev item"
	icon = 'modular_doppler/xenoarch/icons/xenoarch_items.dmi'

// HAMMERS

/obj/item/xenoarch/hammer
	name = "parent dev item"
	desc = "A hammer that can be used to remove dirt from strange rocks."
	tool_behaviour = TOOL_HAMMER
	var/dig_amount = 1
	var/dig_speed = 1 SECONDS
	var/advanced = FALSE

/obj/item/xenoarch/hammer/examine(mob/user)
	. = ..()
	if(advanced)
		. += span_notice("This is an advanced hammer. It can change its digging depth from 1 to 30. Click to change depth.")
	. += span_notice("Current Digging Depth: [dig_amount]cm")

/obj/item/xenoarch/hammer/attack_self(mob/user, modifiers)
	. = ..()
	if(!advanced)
		to_chat(user, span_warning("This is not an advanced hammer, it cannot change its digging depth."))
		return
	var/user_choice = input(user, "Choose the digging depth. 1 to 30", "Digging Depth Selection") as null|num
	if(!user_choice)
		dig_amount = 1
		dig_speed = 1
		return
	if(dig_amount <= 0)
		dig_amount = 1
		dig_speed = 1
		return
	var/round_dig = round(user_choice)
	if(round_dig >= 30)
		dig_amount = 30
		dig_speed = 30
		return
	dig_amount = round_dig
	dig_speed = round_dig * 0.5
	to_chat(user, span_notice("You change the hammer's digging depth to [round_dig]cm."))

/obj/item/xenoarch/hammer/cm1
	name = "hammer (1cm)"
	icon_state = "hammer1"
	dig_amount = 1
	dig_speed = 0.5 SECONDS

/obj/item/xenoarch/hammer/cm2
	name = "hammer (2cm)"
	icon_state = "hammer2"
	dig_amount = 2
	dig_speed = 1 SECONDS

/obj/item/xenoarch/hammer/cm3
	name = "hammer (3cm)"
	icon_state = "hammer3"
	dig_amount = 3
	dig_speed = 1.5 SECONDS

/obj/item/xenoarch/hammer/cm4
	name = "hammer (4cm)"
	icon_state = "hammer4"
	dig_amount = 4
	dig_speed = 2 SECONDS

/obj/item/xenoarch/hammer/cm5
	name = "hammer (5cm)"
	icon_state = "hammer5"
	dig_amount = 5
	dig_speed = 2.5 SECONDS

/obj/item/xenoarch/hammer/cm6
	name = "hammer (6cm)"
	icon_state = "hammer6"
	dig_amount = 6
	dig_speed = 3 SECONDS

/obj/item/xenoarch/hammer/cm10
	name = "hammer (10cm)"
	icon_state = "hammer10"
	dig_amount = 10
	dig_speed = 5 SECONDS

/obj/item/xenoarch/hammer/adv
	name = "advanced hammer"
	icon_state = "adv_hammer"
	dig_amount = 1
	dig_speed = 1
	advanced = TRUE

// BRUSHES

/obj/item/xenoarch/brush
	name = "brush"
	desc = "A brush that is used to uncover the secrets of the past from strange rocks."
	var/dig_speed = 3 SECONDS
	icon_state = "brush"

/obj/item/xenoarch/brush/adv
	name = "advanced brush"
	dig_speed = 0.5 SECONDS
	icon_state = "adv_brush"

// MISC.

/obj/item/xenoarch/tape_measure
	name = "measuring tape"
	desc = "A measuring tape specifically produced to measure the depth that has been dug into strange rocks."
	icon_state = "tape"

/obj/item/xenoarch/handheld_scanner
	name = "handheld scanner"
	desc = "A handheld scanner for strange rocks. It tags the depths to the rock."
	icon_state = "scanner"
	var/scanning_speed = 3 SECONDS
	var/scan_advanced = FALSE

/obj/item/xenoarch/handheld_scanner/advanced
	name = "advanced handheld scanner"
	icon_state = "adv_scanner"
	scanning_speed = 0.5 SECONDS
	scan_advanced = TRUE

/obj/item/xenoarch/handheld_recoverer
	name = "handheld recoverer"
	desc = "An item that has the capabilities to recover items lost due to time."
	icon_state = "recoverer"

/obj/item/xenoarch/handheld_recoverer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/turf/target_turf = get_turf(interacting_with)
	. = ITEM_INTERACT_SUCCESS
	if(istype(interacting_with, /obj/item/xenoarch/broken_item/tech))
		var/spawn_item = pick_weight(GLOB.tech_reward)
		new spawn_item(target_turf)
		qdel(interacting_with)
		return
	if(istype(interacting_with, /obj/item/xenoarch/broken_item/weapon))
		var/spawn_item = pick_weight(GLOB.weapon_reward)
		new spawn_item(target_turf)
		qdel(interacting_with)
		return
	if(istype(interacting_with, /obj/item/xenoarch/broken_item/illegal))
		var/spawn_item = pick_weight(GLOB.illegal_reward)
		new spawn_item(target_turf)
		qdel(interacting_with)
		return
	if(istype(interacting_with, /obj/item/xenoarch/broken_item/alien))
		var/spawn_item = pick_weight(GLOB.alien_reward)
		new spawn_item(target_turf)
		qdel(interacting_with)
		return
	if(istype(interacting_with, /obj/item/xenoarch/broken_item/plant))
		var/spawn_item = pick_weight(GLOB.plant_reward)
		new spawn_item(target_turf)
		qdel(interacting_with)
		return
	if(istype(interacting_with, /obj/item/xenoarch/broken_item/clothing))
		var/spawn_item = pick_weight(GLOB.clothing_reward)
		new spawn_item(target_turf)
		qdel(interacting_with)
		return
	if(istype(interacting_with, /obj/item/xenoarch/broken_item/animal))
		var/spawn_item
		var/turf/src_turf = get_turf(src)
		for(var/looptime in 1 to rand(1,4))
			spawn_item = pick_weight(GLOB.animal_reward)
			new spawn_item(src_turf)
		qdel(interacting_with)
		return
	return NONE

/obj/item/storage/belt/utility/xenoarch
	name = "xenoarch toolbelt"
	desc = "Holds tools."
	icon = 'modular_doppler/xenoarch/icons/xenoarch_items.dmi'
	icon_state = "xenoarch_belt"
	content_overlays = FALSE
	custom_premium_price = PAYCHECK_CREW * 2

/obj/item/storage/belt/utility/xenoarch/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 100
	atom_storage.max_slots = 15
	atom_storage.set_holdable(list(
		/obj/item/xenoarch/hammer,
		/obj/item/xenoarch/brush,
		/obj/item/xenoarch/tape_measure,
		/obj/item/xenoarch/handheld_scanner,
		/obj/item/xenoarch/handheld_recoverer,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/mining_scanner,
		/obj/item/gps
		))

/obj/item/storage/bag/xenoarch
	name = "xenoarch mining satchel"
	desc = "This little bugger can be used to store and transport strange rocks."
	icon = 'modular_doppler/xenoarch/icons/xenoarch_items.dmi'
	icon_state = "satchel"
	worn_icon_state = "satchel"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	var/insert_speed = 1 SECONDS
	var/mob/listeningTo
	var/range = null

	var/spam_protection = FALSE //If this is TRUE, the holder won't receive any messages when they fail to pick up ore through crossing it

/obj/item/storage/bag/xenoarch/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC
	atom_storage.allow_quick_empty = TRUE
	atom_storage.max_total_storage = 1000
	atom_storage.max_slots = 25
	atom_storage.numerical_stacking = FALSE
	atom_storage.can_hold = typecacheof(list(/obj/item/xenoarch/strange_rock))

/obj/item/storage/bag/xenoarch/equipped(mob/user)
	. = ..()
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(pickup_rocks))
	listeningTo = user

/obj/item/storage/bag/xenoarch/dropped(mob/user)
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	listeningTo = null

/obj/item/storage/bag/xenoarch/proc/pickup_rocks(mob/living/user)
	SIGNAL_HANDLER
	var/show_message = FALSE
	var/turf/tile = user.loc
	if (!isturf(tile))
		return

	if(atom_storage)
		for(var/A in tile)
			if (!is_type_in_typecache(A, atom_storage.can_hold))
				continue
			else if(atom_storage.attempt_insert(A, user))
				show_message = TRUE
			else
				if(!spam_protection)
					to_chat(user, span_warning("Your [name] is full and can't hold any more!"))
					spam_protection = TRUE
					continue
	if(show_message)
		playsound(user, SFX_RUSTLE, 50, TRUE)
		user.visible_message(span_notice("[user] scoops up the rocks beneath [user.p_them()]."), \
			span_notice("You scoop up the rocks beneath you with your [name]."))
	spam_protection = FALSE

/obj/item/storage/bag/xenoarch/adv
	name = "advanced xenoarch mining satchel"
	icon_state = "adv_satchel"
	insert_speed = 0.1 SECONDS

/obj/item/storage/bag/xenoarch/adv/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 50

/obj/structure/closet/xenoarch
	name = "xenoarchaeology equipment locker"
	icon_state = "science"

/obj/structure/closet/xenoarch/PopulateContents()
	. = ..()
	new /obj/item/xenoarch/hammer/cm1(src)
	new /obj/item/xenoarch/hammer/cm2(src)
	new /obj/item/xenoarch/hammer/cm3(src)
	new /obj/item/xenoarch/hammer/cm4(src)
	new /obj/item/xenoarch/hammer/cm5(src)
	new /obj/item/xenoarch/hammer/cm6(src)
	new /obj/item/xenoarch/hammer/cm10(src)
	new /obj/item/xenoarch/brush(src)
	new /obj/item/xenoarch/tape_measure(src)
	new /obj/item/xenoarch/handheld_scanner(src)
	new /obj/item/storage/bag/xenoarch(src)
	new /obj/item/storage/belt/utility/xenoarch(src)
	new /obj/item/t_scanner/adv_mining_scanner(src)
	new /obj/item/pickaxe(src)
	new /obj/item/paper/fluff/xenoarch_guide(src)

/obj/structure/closet/xenoarch/tribal_version
	name = "dusty xenoarchaeology equipment locker"

/obj/structure/closet/xenoarch/tribal_version/PopulateContents()
	. = ..()
	new /obj/item/xenoarch/handheld_recoverer(src)

/obj/item/skillchip/xenoarch_magnifier
	name = "R3T3N-T1VE skillchip"
	desc = "This biochip integrates with user's brain to enable the mastery of a specific skill. Consult certified Nanotrasen neurosurgeon before use. \
	There's a little face etched into the back of the skillchip, with buck teeth and goofy-looking glasses."
	auto_traits = list(TRAIT_XENOARCH_QUALIFIED)
	skill_name = "Xenoarchaeological Analysis"
	skill_description = "Allows for the more thorough magnification and notice of details on freshly-excavated xenoarchaeological garbage."
	skill_icon = "magnifying-glass"
	activate_message = span_notice("You feel the gleaned knowledge of a xenoarchaeological digsite internship reveal itself to your mind.")
	deactivate_message = span_notice("The knowledge from a digsite internship fades away into jumbled coffee orders from ungrateful supervisors.")
