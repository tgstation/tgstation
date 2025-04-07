/obj/item/storage/backpack/duffelbag
	name = "duffel bag"
	desc = "A large duffel bag for holding extra things."
	icon_state = "duffel"
	inhand_icon_state = "duffel"
	actions_types = list(/datum/action/item_action/zipper)
	action_slots = ALL
	storage_type = /datum/storage/duffel
	// How much to slow you down if your bag isn't zipped up
	var/zip_slowdown = 1
	/// If this bag is zipped (contents hidden) up or not
	/// Starts enabled so you're forced to interact with it to "get" it
	var/zipped_up = TRUE
	// How much time it takes to zip up (close) the duffelbag
	var/zip_up_duration = 0.5 SECONDS
	// Audio played during zipup
	var/zip_up_sfx = 'sound/items/zip/zip_up.ogg'
	// How much time it takes to unzip the duffel
	var/unzip_duration = 2.1 SECONDS
	// Audio played during unzip
	var/unzip_sfx = 'sound/items/zip/un_zip.ogg'

/obj/item/storage/backpack/duffelbag/Initialize(mapload)
	. = ..()
	set_zipper(TRUE)

/obj/item/storage/backpack/duffelbag/update_desc(updates)
	. = ..()
	desc = "[initial(desc)]<br>[zipped_up ? "It's zipped up, preventing you from accessing its contents." : "It's unzipped, and harder to move in."]"

/obj/item/storage/backpack/duffelbag/attack_self(mob/user, modifiers)
	if(loc != user) // God fuck TK
		return ..()
	if(zipped_up)
		return attack_hand(user, modifiers)
	else
		return attack_hand_secondary(user, modifiers)

/obj/item/storage/backpack/duffelbag/attack_self_secondary(mob/user, modifiers)
	attack_self(user, modifiers)
	return ..()

// If we're zipped, click to unzip
/obj/item/storage/backpack/duffelbag/attack_hand(mob/user, list/modifiers)
	if(loc != user)
		// Hacky, but please don't be cringe yeah?
		atom_storage.silent = TRUE
		. = ..()
		atom_storage.silent = initial(atom_storage.silent)
		return
	if(!zipped_up)
		return ..()

	balloon_alert(user, "unzipping...")
	playsound(src, unzip_sfx, 100, FALSE)
	var/datum/callback/can_unzip = CALLBACK(src, PROC_REF(zipper_matches), TRUE)
	if(!do_after(user, unzip_duration, src, extra_checks = can_unzip))
		user.balloon_alert(user, "unzip failed!")
		return
	balloon_alert(user, "unzipped")
	set_zipper(FALSE)
	return TRUE

// Vis versa
/obj/item/storage/backpack/duffelbag/attack_hand_secondary(mob/user, list/modifiers)
	if(loc != user)
		return ..()
	if(zipped_up)
		return SECONDARY_ATTACK_CALL_NORMAL

	balloon_alert(user, "zipping...")
	playsound(src, zip_up_sfx, 100, FALSE)
	var/datum/callback/can_zip = CALLBACK(src, PROC_REF(zipper_matches), FALSE)
	if(!do_after(user, zip_up_duration, src, extra_checks = can_zip))
		user.balloon_alert(user, "zip failed!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	balloon_alert(user, "zipped")
	set_zipper(TRUE)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/// Checks to see if the zipper matches the passed in state
/// Returns true if so, false otherwise
/obj/item/storage/backpack/duffelbag/proc/zipper_matches(matching_value)
	return zipped_up == matching_value

/obj/item/storage/backpack/duffelbag/proc/set_zipper(new_zip)
	zipped_up = new_zip
	SEND_SIGNAL(src, COMSIG_DUFFEL_ZIP_CHANGE, new_zip)
	if(zipped_up)
		slowdown = initial(slowdown)
		atom_storage.locked = STORAGE_SOFT_LOCKED
		atom_storage.display_contents = FALSE
		for(var/obj/item/weapon as anything in get_all_contents_type(/obj/item)) //close ui of this and all items inside dufflebag
			weapon.atom_storage?.close_all() //not everything has storage initialized
	else
		slowdown = zip_slowdown
		atom_storage.locked = STORAGE_NOT_LOCKED
		atom_storage.display_contents = TRUE

	if(isliving(loc))
		var/mob/living/wearer = loc
		wearer.update_equipment_speed_mods()
	update_appearance()

/obj/item/storage/backpack/duffelbag/cursed
	name = "living duffel bag"
	desc = "A cursed clown duffel bag that hungers for food of any kind. A warning label suggests that it eats food inside. \
		If that food happens to be a horribly ruined mess or the chef scrapped out of the microwave, or poisoned in some way, \
		then it might have negative effects on the bag..."
	icon_state = "duffel-curse"
	inhand_icon_state = "duffel-curse"
	zip_slowdown = 2
	max_integrity = 100

/obj/item/storage/backpack/duffelbag/cursed/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/curse_of_hunger, add_dropdel = TRUE)

/obj/item/storage/backpack/duffelbag/captain
	name = "captain's duffel bag"
	desc = "A large duffel bag for holding extra captainly goods."
	icon_state = "duffel-captain"
	inhand_icon_state = "duffel-captain"

/obj/item/storage/backpack/duffelbag/med
	name = "medical duffel bag"
	desc = "A large duffel bag for holding extra medical supplies."
	icon_state = "duffel-medical"
	inhand_icon_state = "duffel-med"

/obj/item/storage/backpack/duffelbag/coroner
	name = "coroner duffel bag"
	desc = "A large duffel bag for holding large amounts of organs at once."
	icon_state = "duffel-coroner"
	inhand_icon_state = "duffel-coroner"

/obj/item/storage/backpack/duffelbag/explorer
	name = "explorer duffel bag"
	desc = "A large duffel bag for holding extra exotic treasures."
	icon_state = "duffel-explorer"
	inhand_icon_state = "duffel-explorer"

/obj/item/storage/backpack/duffelbag/hydroponics
	name = "hydroponic's duffel bag"
	desc = "A large duffel bag for holding extra gardening tools."
	icon_state = "duffel-hydroponics"
	inhand_icon_state = "duffel-hydroponics"

/obj/item/storage/backpack/duffelbag/chemistry
	name = "chemistry duffel bag"
	desc = "A large duffel bag for holding extra chemical substances."
	icon_state = "duffel-chemistry"
	inhand_icon_state = "duffel-chemistry"

/obj/item/storage/backpack/duffelbag/genetics
	name = "geneticist's duffel bag"
	desc = "A large duffel bag for holding extra genetic mutations."
	icon_state = "duffel-genetics"
	inhand_icon_state = "duffel-genetics"

/obj/item/storage/backpack/duffelbag/science
	name = "scientist's duffel bag"
	desc = "A large duffel bag for holding extra scientific components."
	icon_state = "duffel-science"
	inhand_icon_state = "duffel-sci"

/obj/item/storage/backpack/duffelbag/virology
	name = "virologist's duffel bag"
	desc = "A large duffel bag for holding extra viral bottles."
	icon_state = "duffel-virology"
	inhand_icon_state = "duffel-virology"

/obj/item/storage/backpack/duffelbag/sec
	name = "security duffel bag"
	desc = "A large duffel bag for holding extra security supplies and ammunition."
	icon_state = "duffel-security"
	inhand_icon_state = "duffel-sec"

/obj/item/storage/backpack/duffelbag/sec/surgery
	name = "surgical duffel bag"
	desc = "A large duffel bag for holding extra supplies - this one has a material inlay with space for various sharp-looking tools."

/obj/item/storage/backpack/duffelbag/sec/surgery/PopulateContents()
	return list(
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/surgicaldrill,
		/obj/item/cautery,
		/obj/item/surgical_drapes,
		/obj/item/clothing/mask/surgical,
		/obj/item/blood_filter,
	)

/obj/item/storage/backpack/duffelbag/engineering
	name = "industrial duffel bag"
	desc = "A large duffel bag for holding extra tools and supplies."
	icon_state = "duffel-engineering"
	inhand_icon_state = "duffel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/drone
	name = "drone duffel bag"
	desc = "A large duffel bag for holding tools and hats."
	icon_state = "duffel-drone"
	inhand_icon_state = "duffel-drone"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/drone/PopulateContents()
	return list(
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/crowbar,
		/obj/item/stack/cable_coil,
		/obj/item/wirecutters,
		/obj/item/multitool,
	)

/obj/item/storage/backpack/duffelbag/clown
	name = "clown's duffel bag"
	desc = "A large duffel bag for holding lots of funny gags!"
	icon_state = "duffel-clown"
	inhand_icon_state = "duffel-clown"

/obj/item/storage/backpack/duffelbag/clown/cream_pie/PopulateContents()
	return list(
		/obj/item/food/pie/cream,
		/obj/item/food/pie/cream,
		/obj/item/food/pie/cream,
		/obj/item/food/pie/cream,
	)

/obj/item/storage/backpack/fireproof
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/syndie
	name = "suspicious looking duffel bag"
	desc = "A large duffel bag for holding extra tactical supplies. It contains an oiled plastitanium zipper for maximum speed tactical zipping, and is better balanced on your back than an average duffelbag. Can hold two bulky items!"
	icon_state = "duffel-syndie"
	inhand_icon_state = "duffel-syndieammo"
	resistance_flags = FIRE_PROOF
	// Less slowdown while unzipped. Still bulky, but it won't halve your movement speed in an active combat situation.
	zip_slowdown = 0.3
	// Faster unzipping. Utilizes the same noise as zipping up to fit the unzip duration.
	unzip_duration = 0.5 SECONDS
	unzip_sfx = 'sound/items/zip/zip_up.ogg'
	storage_type = /datum/storage/duffel/syndicate

/obj/item/storage/backpack/duffelbag/syndie/hitman
	desc = "A large duffel bag for holding extra things. There is a Nanotrasen logo on the back."
	icon_state = "duffel-syndieammo"
	inhand_icon_state = "duffel-syndieammo"

/obj/item/storage/backpack/duffelbag/syndie/hitman/PopulateContents()
	return list(
		/obj/item/clothing/under/costume/buttondown/slacks/service,
		/obj/item/clothing/neck/tie/red/hitman,
		/obj/item/clothing/accessory/waistcoat,
		/obj/item/clothing/suit/toggle/lawyer/black,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/head/fedora,
	)

/obj/item/storage/backpack/duffelbag/syndie/med
	name = "medical duffel bag"
	desc = "A large duffel bag for holding extra tactical medical supplies."
	icon_state = "duffel-syndiemed"
	inhand_icon_state = "duffel-syndiemed"

/obj/item/storage/backpack/duffelbag/syndie/surgery
	name = "surgery duffel bag"
	desc = "A suspicious looking duffel bag for holding surgery tools."
	icon_state = "duffel-syndiemed"
	inhand_icon_state = "duffel-syndiemed"

/obj/item/storage/backpack/duffelbag/syndie/surgery/PopulateContents()
	return list(
		/obj/item/scalpel/advanced,
		/obj/item/retractor/advanced,
		/obj/item/cautery/advanced,
		/obj/item/surgical_drapes,
		/obj/item/reagent_containers/medigel/sterilizine,
		/obj/item/bonesetter,
		/obj/item/blood_filter,
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/emergency_bed,
		/obj/item/clothing/suit/jacket/straight_jacket,
		/obj/item/clothing/mask/muzzle,
		/obj/item/mmi/syndie,
	)

/obj/item/storage/backpack/duffelbag/syndie/ammo
	name = "ammunition duffel bag"
	desc = "A large duffel bag for holding extra weapons ammunition and supplies."
	icon_state = "duffel-syndieammo"
	inhand_icon_state = "duffel-syndieammo"

/obj/item/storage/backpack/duffelbag/syndie/ammo/mech
	desc = "A large duffel bag, packed to the brim with various exosuit ammo."
	storage_type = /datum/storage/duffel/syndicate/ammo_mech

/obj/item/storage/backpack/duffelbag/syndie/ammo/mech/PopulateContents()
	return list(
		/obj/item/mecha_ammo/scattershot,
		/obj/item/mecha_ammo/scattershot,
		/obj/item/mecha_ammo/scattershot,
		/obj/item/mecha_ammo/scattershot,
		/obj/item/storage/belt/utility/syndicate,
	)

/obj/item/storage/backpack/duffelbag/syndie/ammo/mauler
	desc = "A large duffel bag, packed to the brim with various exosuit ammo."
	storage_type = /datum/storage/duffel/syndicate/ammo_mauler

/obj/item/storage/backpack/duffelbag/syndie/ammo/mauler/PopulateContents()
	return list(
		/obj/item/mecha_ammo/lmg,
		/obj/item/mecha_ammo/lmg,
		/obj/item/mecha_ammo/lmg,
		/obj/item/mecha_ammo/scattershot,
		/obj/item/mecha_ammo/scattershot,
		/obj/item/mecha_ammo/scattershot,
		/obj/item/mecha_ammo/missiles_srm,
		/obj/item/mecha_ammo/missiles_srm,
		/obj/item/mecha_ammo/missiles_srm,
	)

/obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	desc = "A large duffel bag containing a medical equipment, a Donksoft LMG, a big jumbo box of riot darts, and a magboot MODsuit module."

/obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle/PopulateContents()
	return list(
		/obj/item/mod/module/magboot,
		/obj/item/storage/medkit/tactical/premium,
		/obj/item/gun/ballistic/automatic/l6_saw/toy,
		/obj/item/ammo_box/foambox/riot,
	)

/obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle
	desc = "A large duffel bag containing deadly chemicals, a handheld chem sprayer, Bioterror foam grenade, a Donksoft assault rifle, box of riot grade darts, a dart pistol, and a box of syringes."

/obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle/PopulateContents()
	var/list/obj/item/stuff = list(
		/obj/item/reagent_containers/spray/chemsprayer/bioterror,
		/obj/item/storage/box/syndie_kit/chemical,
		/obj/item/gun/syringe/syndicate,
		/obj/item/gun/ballistic/automatic/c20r/toy,
		/obj/item/storage/box/syringes,
		/obj/item/ammo_box/foambox/riot,
		/obj/item/grenade/chem_grenade/bioterrorfoam,
	)

	if(prob(5))
		stuff += /obj/item/food/pizza/pineapple

	return stuff

/obj/item/storage/backpack/duffelbag/syndie/c4/PopulateContents()
	. = list()
	for(var/_ in 1 to 10)
		. += /obj/item/grenade/c4

/obj/item/storage/backpack/duffelbag/syndie/x4/PopulateContents()
	. = list()
	for(var/_ in 1 to 10)
		. += /obj/item/grenade/c4/x4

/obj/item/storage/backpack/duffelbag/syndie/firestarter
	desc = "A large duffel bag containing a New Russian pyro backpack sprayer, Elite MODsuit, a Stechkin APS pistol, minibomb, ammo, and other equipment."
	storage_type = /datum/storage/duffel/syndicate/firestarter

/obj/item/storage/backpack/duffelbag/syndie/firestarter/PopulateContents(datum/storage_config/config)
	config.compute_max_item_weight = TRUE

	return list(
		/obj/item/clothing/under/syndicate/soviet,
		/obj/item/mod/control/pre_equipped/elite/flamethrower,
		/obj/item/gun/ballistic/automatic/pistol/aps,
		/obj/item/ammo_box/magazine/m9mm_aps/fire,
		/obj/item/ammo_box/magazine/m9mm_aps/fire,
		/obj/item/reagent_containers/cup/glass/bottle/vodka/badminka,
		/obj/item/reagent_containers/hypospray/medipen/stimulants,
		/obj/item/grenade/syndieminibomb,
	)

// For ClownOps.
/obj/item/storage/backpack/duffelbag/clown/syndie
	storage_type = /datum/storage/duffel/syndicate

/obj/item/storage/backpack/duffelbag/clown/syndie/PopulateContents()
	return list(
		/obj/item/modular_computer/pda/clown,
		/obj/item/clothing/under/rank/civilian/clown,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/bikehorn,
		/obj/item/implanter/sad_trombone,
	)
