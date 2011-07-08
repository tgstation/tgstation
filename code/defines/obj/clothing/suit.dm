// SUITS

/obj/item/clothing/suit
	icon = 'suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags = FPRINT | TABLEPASS
	var/list/allowed = list(/obj/item/weapon/tank/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	item_state = "bombsuit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.30
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 2
	armor = list(melee = 20, bullet = 10, laser = 10, taser = 5, bomb = 100, bio = 0, rad = 0)

/obj/item/clothing/suit/bomb_suit/security
	desc = "A suit designed for safety when handling explosives. Includes light armoring against non-explosive hazards as well."
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs)
	armor = list(melee = 50, bullet = 40, laser = 20, taser = 5, bomb = 100, bio = 0, rad = 0)

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio"
	item_state = "bio_suit"
//	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.30
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 1.3
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 100, rad = 20)

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio_general"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/security
	icon_state = "bio_security"
	desc = "A suit that protects against biological contamination. Includes basic armoring against non-bio hazards as well."
	armor = list(melee = 30, bullet = 20, laser = 10, taser = 5, bomb = 20, bio = 100, rad = 20)

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "Plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	item_state = "bio_suit"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL

/obj/item/clothing/suit/det_suit
	name = "coat"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/gun/projectile/detective,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/cigpacket,/obj/item/weapon/zippo,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	armor = list(melee = 50, bullet = 40, laser = 30, taser = 10, bomb = 20, bio = 0, rad = 0)

/obj/item/clothing/suit/det_suit/armor
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list(/obj/item/weapon/gun/projectile/detective,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/cigpacket,/obj/item/weapon/zippo,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	armor = list(melee = 75, bullet = 50, laser = 50, taser = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/cigpacket,/obj/item/weapon/spacecash)

/obj/item/clothing/suit/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat_open"
	item_state = "labcoat"
	permeability_coefficient = 0.25
	heat_transfer_coefficient = 0.75
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 50, rad = 5)

/obj/item/clothing/suit/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo_open"
	item_state = "labcoat_cmo"
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 55, rad = 5)

/obj/item/clothing/suit/labcoat/mad
	name = "The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen_open"
	item_state = "labgreen"

/obj/item/clothing/suit/labcoat/genetics
	name = "Geneticist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen_open"

/obj/item/clothing/suit/labcoat/chemist
	name = "Chemist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem_open"

/obj/item/clothing/suit/labcoat/virologist
	name = "Virologist Labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir_open"
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 55, rad = 5)

/obj/item/clothing/suit/labcoat/science
	name = "Scientist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_tox_open"

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that totally restrains an individual"
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "vest"
	item_state = "wcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/device/pda)

/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	item_state = "apron"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list (/obj/item/weapon/plantbgone,/obj/item/device/analyzer/plant_analyzer,/obj/item/seeds,/obj/item/nutrient,/obj/item/weapon/minihoe)

/obj/item/clothing/suit/chef
	name = "Chef's apron"
	desc = "An Apron used by a high class chef. The chef unfortunately retired."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	heat_transfer_coefficient = 0.50
	protective_temperature = 1000 //If you can't stand the heat, get back to the kitchen - Micro
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list (/obj/item/weapon/kitchenknife)

/obj/item/clothing/suit/wizrobe
	name = "wizard robe"
	desc = "A magnificant, gem-lined robe that seems to radiate power."
	icon_state = "wizard"
	item_state = "wizrobe"
	gas_transfer_coefficient = 0.01 // IT'S MAGICAL OKAY JEEZ +1 TO NOT DIE
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.01
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = FULL_BODY //It's magic, I ain't gotta explain shit. --NEO
	armor = list(melee = 30, bullet = 20, laser = 20, taser = 20, bomb = 20, bio = 20, rad = 20)
	allowed = list(/obj/item/weapon/teleportation_scroll)

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A magnificant, red, gem-lined robe that seems to radiate power."
	icon_state = "redwizard"
	item_state = "redwizrobe"

/obj/item/clothing/suit/wizrobe/fake
	name = "wizard robe"
	desc = "A rather dull, blue robe one could probably find in Space-Walmart."
	icon_state = "wizard-fake"
	item_state = "wizrobe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS //It's not magic, shit is reasonable. --NEO
	armor = list(melee = 5, bullet = 5, laser = 5, taser = 5, bomb = 5, bio = 5, rad = 5)

/obj/item/clothing/suit/wizrobe/marisa
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"

/obj/item/clothing/suit/hazardvest
	name = "hazard vest"
	desc = "A vest designed to make one more noticable. It's not very good at it though"
	icon_state = "hazard"
	item_state = "hazard"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL

/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play." //Meh -- Urist
	icon = 'belts.dmi'
	icon_state = "suspenders"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL

// ARMOR

/obj/item/clothing/suit/armor
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs)

/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	armor = list(melee = 75, bullet = 50, laser = 50, taser = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A greatcoat enchanced with a special alloy for some protection and style."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/suit/armor/a_i_a_ptank
	desc = "A wearable bomb with a health analyzer attached"
	name = "Analyzer/Igniter/Armor/Plasmatank Assembly"
	icon_state = "bomb"
	item_state = "bombvest"
	var/obj/item/device/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part4 = null
	var/obj/item/clothing/suit/armor/vest/part3 = null
	var/status = 0
	flags = FPRINT | TABLEPASS | CONDUCT | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	canremove = 0
	armor = list(melee = 75, bullet = 50, laser = 50, taser = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/suit/armor/captain
	name = "Captain's armor"
	desc = "Wearing this armor exemplifies who is in charge. You are in charge."
	icon_state = "caparmor"
	item_state = "caparmor"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	heat_transfer_coefficient = 0.02
	radiation_protection = 0.25
	protective_temperature = 1000
	flags = FPRINT | TABLEPASS | SUITSPACE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1.5
	armor = list(melee = 60, bullet = 50, laser = 50, taser = 25, bomb = 50, bio = 20, rad = 20)

/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = 4//bulky item
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 25, bomb = 50, bio = 10, rad = 0)

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/suit/armor/tdome/red
	name = "Thunderdome suit (red)"
	desc = "Reddish armor."
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "Thunderdome suit (green)"
	desc = "Pukish armor."
	icon_state = "tdgreen"
	item_state = "tdgreen"

/obj/item/clothing/suit/armor/swat
	name = "swat suit"
	desc = "A heavily armored suit that protects against moderate damage. Used in special operations."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 25, bomb = 50, bio = 10, rad = 0)

/obj/item/clothing/suit/armor/riot
	name = "Riot Suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 2.5
	armor = list(melee = 82, bullet = 5, laser = 2, taser = 2, bomb = 5, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/bulletproof
	name = "Bulletproof Vest"
	desc = "A vest that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 15, bullet = 70, laser = 20, taser = 10, bomb = 5, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/laserproof
	name = "Ablative Armor Vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 10, bullet = 5, laser = 65, taser = 25, bomb = 5, bio = 0, rad = 0)

// FIRE SUITS

/obj/item/clothing/suit/fire
	name = "firesuit"
	desc = "A suit that protects against fire and heat."
	icon_state = "fire"
	item_state = "fire_suit"
	//w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	heat_transfer_coefficient = 0.01
	protective_temperature = 4500
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/extinguisher)
	slowdown = 1.3

/obj/item/clothing/suit/fire/firefighter
	icon_state = "firesuit"
	item_state = "firefighter"

/obj/item/clothing/suit/radiation
	name = "Radiation suit"
	desc = "A suit that protects against radiation. Label: Made with lead, do not eat insulation."
	icon_state = "rad"
	item_state = "rad_suit"
	//w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	heat_transfer_coefficient = 0.30 //Not a fire suit
	radiation_protection = 0.75
	protective_temperature = 1000 // Not a fire suit
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1.3
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 100)

/obj/item/clothing/suit/fire/heavy
	name = "firesuit"
	desc = "A suit that protects against extreme fire and heat."
	//icon_state = "thermal"
	item_state = "ro_suit"
	w_class = 4//bulky item
	protective_temperature = 10000
	slowdown = 1.7

// SPACE SUITS

/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	heat_transfer_coefficient = 0.02
	radiation_protection = 0.25
	protective_temperature = 1000
	flags = FPRINT | TABLEPASS | SUITSPACE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 3
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 25, rad = 25)

/obj/item/clothing/suit/space/rig
	name = "rig suit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig"
	item_state = "rig_suit"
	radiation_protection = 0.50
	slowdown = 2
	armor = list(melee = 40, bullet = 30, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/satchel)

/obj/item/clothing/suit/space/syndicate
	name = "red space suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "Has a tag on it: Totally not property of of a hostile corporation, honest!"
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/syndicate/green
	name = "Green Space Suit"
	icon_state = "syndicate-green"
	item_state = "syndicate-green"

/obj/item/clothing/suit/space/syndicate/green/dark
	name = "Dark Green Space Suit"
	icon_state = "syndicate-green-dark"
	item_state = "syndicate-green-dark"

/obj/item/clothing/suit/space/syndicate/orange
	name = "Orange Space Suit"
	icon_state = "syndicate-orange"
	item_state = "syndicate-orange"

/obj/item/clothing/suit/space/syndicate/blue
	name = "Blue Space Suit"
	icon_state = "syndicate-blue"
	item_state = "syndicate-blue"

/obj/item/clothing/suit/space/syndicate/black
	name = "Black Space Suit"
	icon_state = "syndicate-black"
	item_state = "syndicate-black"

/obj/item/clothing/suit/space/syndicate/black/green
	name = "Black and Green Space Suit"
	icon_state = "syndicate-black-green"
	item_state = "syndicate-black-green"

/obj/item/clothing/suit/space/syndicate/black/blue
	name = "Black and Blue Space Suit"
	icon_state = "syndicate-black-blue"
	item_state = "syndicate-black-blue"

/obj/item/clothing/suit/space/syndicate/black/med
	name = "Green Space Suit"
	icon_state = "syndicate-black-med"
	item_state = "syndicate-black"

/obj/item/clothing/suit/space/syndicate/black/orange
	name = "Black and Orange Space Suit"
	icon_state = "syndicate-black-orange"
	item_state = "syndicate-black"

/obj/item/clothing/suit/space/syndicate/black/red
	name = "Black and Red Space Suit"
	icon_state = "syndicate-black-red"
	item_state = "syndicate-black-red"

/obj/item/clothing/suit/space/syndicate/black/engie
	name = "Black Engineering Space Suit"
	icon_state = "syndicate-black-engie"
	item_state = "syndicate-black"

/obj/item/clothing/suit/syndicatefake
	name = "red space suit replica"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "A plastic replica of the syndicate space suit, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = 3
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy)

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "A high tech, NASA Centcom branch designed, dark red Space suit. Used for AI satellite maintenance."
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1.5

/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/cell)
	radiation_protection = 0.75
	slowdown = 1
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 30, bio = 30, rad = 30)

	var
		//Important parts of the suit.
		mob/living/carbon/affecting = null//The wearer.
		obj/item/weapon/cell/cell//Starts out with a high-capacity cell using New().
		datum/effects/system/spark_spread/spark_system//To create sparks.
		reagent_list[] = list("tricordrazine","dexalinp","spaceacillin","anti_toxin","nutriment","radium","hyronalin")//The reagents ids which are added to the suit at New().
		stored_research[]//For stealing station research.
		obj/item/weapon/disk/tech_disk/t_disk//To copy design onto disk.

		//Other articles of ninja gear worn together, used to easily reference them after initializing.
		obj/item/clothing/head/helmet/space/space_ninja/n_hood
		obj/item/clothing/shoes/space_ninja/n_shoes
		obj/item/clothing/gloves/space_ninja/n_gloves

		//Main function variables.
		s_initialized = 0//Suit starts off.
		s_coold = 0//If the suit is on cooldown. Can be used to attach different cooldowns to abilities. Ticks down every second based on suit ntick().
		s_cost = 5.0//Base energy cost each ntick.
		s_acost = 25.0//Additional cost for additional powers active.
		k_cost = 200.0//Kamikaze energy cost each ntick.
		k_damage = 1.0//Brute damage potentially done by Kamikaze each ntick.
		s_delay = 40.0//How fast the suit does certain things, lower is faster. Can be overridden in specific procs. Also determines adverse probability.
		a_transfer = 20.0//How much reagent is transferred when injecting.
		r_maxamount = 80.0//How much reagent in total there is.

		//Support function variables.
		spideros = 0//Mode of SpiderOS. This can change so I won't bother listing the modes here (0 is hub). Check ninja_equipment.dm for how it all works.
		s_active = 0//Stealth off.
		s_busy = 0//Is the suit busy with a process? Like AI hacking. Used for safety functions.
		kamikaze = 0//Kamikaze on or off.
		k_unlock = 0//To unlock Kamikaze.

		//Ability function variables.
		s_bombs = 10.0//Number of starting ninja smoke bombs.
		a_boost = 3.0//Number of adrenaline boosters.

		//Onboard AI related variables.
		mob/living/silicon/ai/AI//If there is an AI inside the suit.
		obj/item/device/paicard/pai//A slot for a pAI device
		obj/overlay/hologram//Is the AI hologram on or off? Visible only to the wearer of the suit. This works by attaching an image to a blank overlay.
		flush = 0//If an AI purge is in progress.
		s_control = 1//If user in control of the suit.

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 0
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Used by irresponsible captains."
	icon_state = "captunic"
	item_state = "bio_suit"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/nun
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	item_state = "nun"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS

/obj/item/clothing/suit/chaplain_hoodie
	name = "chaplain hoodie"
	desc = "This suit says you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/imperium_monk
	name = "Imperium monk"
	desc = "Have YOU killed a xenos today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/suit
	name = "Blue Suit Jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue_open"
	item_state = "suitjacket_blue_open"
	body_parts_covered = UPPER_TORSO|ARMS
	armor = list(melee = 5, bullet = 2, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/suit
	name = "Chicken Suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET|HEAD
	armor = list(melee = 5, bullet = 2, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/holidaypriest
	name = "Holiday Priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	item_state = "holidaypriest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS



