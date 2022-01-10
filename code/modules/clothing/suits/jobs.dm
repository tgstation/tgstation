/*
 * Job related
 */

//Botanist
/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	inhand_icon_state = "apron"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	allowed = list(/obj/item/reagent_containers/spray/plantbgone, /obj/item/plant_analyzer, /obj/item/seeds, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/cultivator, /obj/item/reagent_containers/spray/pestspray, /obj/item/hatchet, /obj/item/storage/bag/plants, /obj/item/graft, /obj/item/secateurs, /obj/item/geneshears)
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/apron/waders
	name = "horticultural waders"
	desc = "A pair of heavy duty leather waders, perfect for insulating your soft flesh from spills, soil and thorns."
	icon_state = "hort_waders"
	inhand_icon_state = "hort_waders"
	body_parts_covered = CHEST|GROIN|LEGS
	permeability_coefficient = 0.5

//Captain
/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captunic"
	inhand_icon_state = "bio_suit"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/disk, /obj/item/stamp, /obj/item/reagent_containers/food/drinks/flask, /obj/item/melee, /obj/item/storage/lockbox/medal, /obj/item/assembly/flash/handheld, /obj/item/storage/box/matches, /obj/item/lighter, /obj/item/clothing/mask/cigarette, /obj/item/storage/fancy/cigarettes, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)

//Chef
/obj/item/clothing/suit/toggle/chef
	name = "chef's apron"
	desc = "An apron-jacket used by a high class chef."
	icon_state = "chef"
	inhand_icon_state = "chef"
	permeability_coefficient = 0.5
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(/obj/item/kitchen, /obj/item/knife/kitchen, /obj/item/storage/bag/tray)
	toggle_noun = "sleeves"
	species_exception = list(/datum/species/golem)

//Cook
/obj/item/clothing/suit/apron/chef
	name = "cook's apron"
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	inhand_icon_state = "apronchef"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	allowed = list(/obj/item/kitchen, /obj/item/knife/kitchen, /obj/item/storage/bag/tray)

//Detective
/obj/item/clothing/suit/det_suit
	name = "trenchcoat"
	desc = "A 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	inhand_icon_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list(MELEE = 25, BULLET = 10, LASER = 25, ENERGY = 35, BOMB = 0, BIO = 0, FIRE = 0, ACID = 45)
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/suit/det_suit/Initialize(mapload)
	. = ..()
	allowed = GLOB.detective_vest_allowed

/obj/item/clothing/suit/det_suit/grey
	name = "noir trenchcoat"
	desc = "A hard-boiled private investigator's grey trenchcoat."
	icon_state = "greydet"
	inhand_icon_state = "greydet"

/obj/item/clothing/suit/det_suit/noir
	name = "noir suit coat"
	desc = "A dapper private investigator's grey suit coat."
	icon_state = "detsuit"
	inhand_icon_state = "detsuit"

//Engineering
/obj/item/clothing/suit/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	inhand_icon_state = "hazard"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/radio, /obj/item/storage/bag/construction)
	resistance_flags = NONE
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/hazardvest/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", alpha = src.alpha)

//Lawyer
/obj/item/clothing/suit/toggle/lawyer
	name = "blue suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue"
	inhand_icon_state = "suitjacket_blue"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/toggle/lawyer/purple
	name = "purple suit jacket"
	desc = "A foppish dress jacket."
	icon_state = "suitjacket_purp"
	inhand_icon_state = "suitjacket_purp"

/obj/item/clothing/suit/toggle/lawyer/black
	name = "black suit jacket"
	desc = "A professional suit jacket."
	icon_state = "suitjacket_black"
	inhand_icon_state = "ro_suit"


//Mime
/obj/item/clothing/suit/toggle/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	worn_icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here
	toggle_noun = "straps"
	species_exception = list(/datum/species/golem)
	greyscale_config = /datum/greyscale_config/suspenders
	greyscale_config_worn = /datum/greyscale_config/suspenders/worn
	greyscale_colors = "#ff0000"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/toggle/suspenders/blue
	name = "blue suspenders"
	desc = "The symbol of hard labor and dirty jobs."
	icon = 'icons/obj/clothing/belts.dmi'
	greyscale_colors = "#0000ff"

/obj/item/clothing/suit/toggle/suspenders/gray
	name = "gray suspenders"
	desc = "The symbol of hard labor and dirty jobs."
	icon = 'icons/obj/clothing/belts.dmi'
	greyscale_colors = "#888888"

//Security
/obj/item/clothing/suit/security/officer
	name = "security officer's jacket"
	desc = "This jacket is for those special occasions when a security officer isn't required to wear their armor."
	icon_state = "officerbluejacket"
	inhand_icon_state = "officerbluejacket"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/security/warden
	name = "warden's jacket"
	desc = "Perfectly suited for the warden that wants to leave an impression of style on those who visit the brig."
	icon_state = "wardenbluejacket"
	inhand_icon_state = "wardenbluejacket"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/security/hos
	name = "head of security's jacket"
	desc = "This piece of clothing was specifically designed for asserting superior authority."
	icon_state = "hosbluejacket"
	inhand_icon_state = "hosbluejacket"
	body_parts_covered = CHEST|ARMS

//Surgeon
/obj/item/clothing/suit/apron/surgical
	name = "surgical apron"
	desc = "A sterile blue surgical apron."
	icon_state = "surgical"
	allowed = list(
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/scalpel,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/bonesetter,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
		)

//Curator
/obj/item/clothing/suit/curator
	name = "treasure hunter's coat"
	desc = "Both fashionable and lightly armoured, this jacket is favoured by treasure hunters the galaxy over."
	icon_state = "curator"
	inhand_icon_state = "curator"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(/obj/item/tank/internals, /obj/item/melee/curator_whip, /obj/item/storage/bag/books)
	armor = list(MELEE = 25, BULLET = 10, LASER = 25, ENERGY = 35, BOMB = 0, BIO = 0, FIRE = 0, ACID = 45)
	cold_protection = CHEST|ARMS
	heat_protection = CHEST|ARMS


//Robotocist

/obj/item/clothing/suit/hooded/techpriest
	name = "techpriest robes"
	desc = "For those who REALLY love their toasters."
	icon_state = "techpriest"
	inhand_icon_state = "techpriest"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/techpriest

/obj/item/clothing/head/hooded/techpriest
	name = "techpriest's hood"
	desc = "A hood for those who REALLY love their toasters."
	icon_state = "techpriesthood"
	inhand_icon_state = "techpriesthood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/det_suit/kim
	name = "aerostatic bomber jacket"
	desc = "A jacket once worn by the revolutionary air brigades during the Antecentennial Revolution. There are quite a few pockets on the inside, mostly for storing notebooks and compasses."
	icon_state = "aerostatic_bomber_jacket"
	inhand_icon_state = "aerostatic_bomber_jacket"

/obj/item/clothing/suit/det_suit/disco
	name = "disco ass blazer"
	desc = "Looks like someone skinned this blazer off some long extinct disco-animal. It has an enigmatic white rectangle on the back and the right sleeve."
	icon_state = "jamrock_blazer"
	inhand_icon_state = "jamrock_blazer"

