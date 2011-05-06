// SUITS

/obj/item/clothing/suit
	icon = 'suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags = FPRINT | TABLEPASS
	var/list/allowed = list(/obj/item/weapon/tank/emergency_oxygen)

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

/obj/item/clothing/suit/bomb_suit/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/baton,/obj/item/weapon/handcuffs)

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

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio_general"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/security
	icon_state = "bio_security"

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
	allowed = list(/obj/item/weapon/gun/detectiverevolver,/obj/item/weapon/gun/revolver,/obj/item/weapon/ammo/a38,/obj/item/weapon/cigpacket,/obj/item/weapon/zippo,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)

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
	icon_state = "labcoat"
	item_state = "labcoat"
	permeability_coefficient = 0.25
	heat_transfer_coefficient = 0.75
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen)

/obj/item/clothing/suit/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo"
	item_state = "labcoat_cmo"

/obj/item/clothing/suit/labcoat/mad
	name = "The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen"
	item_state = "labgreen"

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that totally restrains an individual"
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	icon_state = "vest"
	item_state = "wcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/device/pda)

/obj/item/clothing/suit/apron
	name = "apron"
	icon_state = "apron"
	item_state = "apron"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list (/obj/item/weapon/plantbgone,/obj/item/device/analyzer/plant_analyzer,/obj/item/seeds,/obj/item/nutrient,/obj/item/weapon/minihoe)

/obj/item/clothing/suit/chef
	name = "Chef's apron"
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
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
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
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/revolver,/obj/item/weapon/baton,/obj/item/weapon/handcuffs)

/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A greatcoat enchanced with a special alloy for some protection and style."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL

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
	body_parts_covered = UPPER_TORSO
	canremove = 0

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
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1.5

/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = 4//bulky item
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/suit/armor/tdome/red
	name = "Thunderdome suit (red)"
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "Thunderdome suit (green)"
	icon_state = "tdgreen"
	item_state = "tdgreen"

/obj/item/clothing/suit/armor/swat
	name = "swat suit"
	desc = "A heavily armored suit that protects against moderate damage. Used in special operations."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/ammo,/obj/item/weapon/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1

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

/obj/item/clothing/suit/space/rig
	name = "rig suit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig"
	item_state = "rig_suit"
	radiation_protection = 0.50
	slowdown = 2

/obj/item/clothing/suit/space/syndicate
	name = "red space suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "Has a tag on it: Totally not property of of a hostile corporation, honest!"
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/ammo,/obj/item/weapon/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1

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
	slowdown = 1.3

/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/ammo,/obj/item/weapon/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	radiation_protection = 0.75
	var/affecting = null
	var/active = 0//Stealth off.
	var/kamikaze = 0//Kamikaze on or off.
	var/charge = 9000.0//Starts at 90% of normal capacity.
	var/maxcharge = 30000.0//I want the suit upgradable if the ninja is able to find the parts but for now this'll do.
	var/initialize = 0//Suit starts off.
	var/spideros = 0//Mode of SpiderOS. This can change so I won't bother listing the modes here (0 is hub). Check ninja_equipment.dm for how it all works.
	var/unlock = 0
	var/sbombs = 10.0//Number of starting ninja smoke bombs.
	var/aboost = 3.0//Number of adrenaline boosters.
	var/amount_per_transfer_from_this = 20//How much reagent is transferred.
	var/datum/effects/system/spark_spread/spark_system
	slowdown = 1

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/ammo,/obj/item/weapon/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 0


/obj/item/clothing/suit/captunic
	name = "Captain's parade tunic"
	icon_state = "captunic"
	item_state = "bio_suit"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/nun
	name = "Nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	item_state = "nun"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS

/obj/item/clothing/suit/chaplain_hoodie
	name = "Chaplain hoodie"
	desc = "This suit says you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/imperium_monk
	name = "Imperium monk everyday outfit"
	desc = "Are YOU killed a xenos today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

