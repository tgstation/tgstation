/*
 * Job related
 */

//Botanist
/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	icon = 'icons/obj/clothing/suits/utility.dmi'
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	inhand_icon_state = null
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	allowed = list(
		/obj/item/cultivator,
		/obj/item/geneshears,
		/obj/item/graft,
		/obj/item/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/secateurs,
		/obj/item/seeds,
		/obj/item/storage/bag/plants,
	)
	species_exception = list(/datum/species/golem)
	armor_type = /datum/armor/suit_apron

/datum/armor/suit_apron
	bio = 50

/obj/item/clothing/suit/apron/waders
	name = "horticultural waders"
	desc = "A pair of heavy duty leather waders, perfect for insulating your soft flesh from spills, soil and thorns."
	icon_state = "hort_waders"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS

//Captain
/obj/item/clothing/suit/jacket/capjacket
	name = "captain's parade jacket"
	desc = "Worn by a Captain to show their class."
	icon_state = "capjacket"
	inhand_icon_state = "bio_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/mask/cigarette,
		/obj/item/disk,
		/obj/item/lighter,
		/obj/item/melee,
		/obj/item/reagent_containers/cup/glass/flask,
		/obj/item/stamp,
		/obj/item/storage/box/matches,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/lockbox/medal,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
	)

//Chef
/obj/item/clothing/suit/toggle/chef
	name = "chef's apron"
	desc = "An apron-jacket used by a high class chef."
	icon_state = "chef"
	inhand_icon_state = "chef"
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	armor_type = /datum/armor/toggle_chef
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(
		/obj/item/kitchen,
		/obj/item/knife/kitchen,
		/obj/item/storage/bag/tray,
	)
	toggle_noun = "sleeves"
	species_exception = list(/datum/species/golem)

//Cook
/datum/armor/toggle_chef
	bio = 50

/obj/item/clothing/suit/apron/chef
	name = "cook's apron"
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	inhand_icon_state = null
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	allowed = list(
		/obj/item/kitchen,
		/obj/item/knife/kitchen,
		/obj/item/storage/bag/tray,
	)

//Detective
/obj/item/clothing/suit/jacket/det_suit
	name = "trenchcoat"
	desc = "A 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	inhand_icon_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|GROIN|ARMS
	armor_type = /datum/armor/jacket_det_suit
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS

/datum/armor/jacket_det_suit
	melee = 25
	bullet = 10
	laser = 25
	energy = 35
	acid = 45

/obj/item/clothing/suit/jacket/det_suit/Initialize(mapload)
	. = ..()
	allowed = GLOB.detective_vest_allowed

/obj/item/clothing/suit/jacket/det_suit/dark
	name = "noir trenchcoat"
	desc = "A hard-boiled private investigator's dark trenchcoat."
	icon_state = "noirdet"
	inhand_icon_state = null

/obj/item/clothing/suit/jacket/det_suit/noir
	name = "noir suit coat"
	desc = "A dapper private investigator's dark suit coat."
	icon_state = "detsuit"
	inhand_icon_state = null

/obj/item/clothing/suit/jacket/det_suit/kim
	name = "aerostatic bomber jacket"
	desc = "A jacket once worn by the revolutionary air brigades during the Antecentennial Revolution. There are quite a few pockets on the inside, mostly for storing notebooks and compasses."
	icon_state = "aerostatic_bomber_jacket"
	inhand_icon_state = null

/obj/item/clothing/suit/jacket/det_suit/disco
	name = "disco ass blazer"
	desc = "Looks like someone skinned this blazer off some long extinct disco-animal. It has an enigmatic white rectangle on the back and the right sleeve."
	icon_state = "jamrock_blazer"
	inhand_icon_state = null

//Engineering
/obj/item/clothing/suit/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	icon = 'icons/obj/clothing/suits/utility.dmi'
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	inhand_icon_state = null
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/flashlight,
		/obj/item/radio,
		/obj/item/storage/bag/construction,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/t_scanner,
		/obj/item/gun/ballistic/rifle/boltaction/pipegun/prime,
	)
	resistance_flags = NONE
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/hazardvest/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

//Lawyer
/obj/item/clothing/suit/toggle/lawyer
	name = "blue suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue"
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	inhand_icon_state = null
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/toggle/lawyer/purple
	name = "purple suit jacket"
	desc = "A foppish dress jacket."
	icon_state = "suitjacket_purp"
	inhand_icon_state = null

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
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	worn_icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here
	toggle_noun = "straps"
	species_exception = list(/datum/species/golem)
	greyscale_config = /datum/greyscale_config/suspenders
	greyscale_config_worn = /datum/greyscale_config/suspenders/worn
	greyscale_colors = "#972A2A"
	flags_1 = IS_PLAYER_COLORABLE_1

//Security
/obj/item/clothing/suit/jacket/officer/blue
	name = "security officer's jacket"
	desc = "This jacket is for those special occasions when a security officer isn't required to wear their armor."
	icon_state = "officerbluejacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/officer/tan
	name = "security officer's jacket"
	desc = "This jacket is for those special occasions when a security officer isn't required to wear their armor."
	icon_state = "officertanjacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/warden/blue
	name = "warden's jacket"
	desc = "Perfectly suited for the warden that wants to leave an impression of style on those who visit the brig."
	icon_state = "wardenbluejacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/warden/tan
	name = "warden's jacket"
	desc = "Perfectly suited for the warden that wants to leave an impression of style on those who visit the brig."
	icon_state = "wardentanjacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/hos/blue
	name = "head of security's jacket"
	desc = "This piece of clothing was specifically designed for asserting superior authority."
	icon_state = "hosbluejacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/hos/tan
	name = "head of security's jacket"
	desc = "This piece of clothing was specifically designed for asserting superior authority."
	icon_state = "hostanjacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

//Surgeon
/obj/item/clothing/suit/apron/surgical
	name = "surgical apron"
	desc = "A sterile blue surgical apron."
	icon_state = "surgical"
	allowed = list(
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/hemostat,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/surgical_drapes,
		/obj/item/storage/pill_bottle,
		/obj/item/tank/internals/emergency_oxygen,
	)

//Curator
/obj/item/clothing/suit/jacket/curator
	name = "treasure hunter's coat"
	desc = "Both fashionable and lightly armoured, this jacket is favoured by treasure hunters the galaxy over."
	icon_state = "curator"
	inhand_icon_state = null
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(
		/obj/item/melee/curator_whip,
		/obj/item/storage/bag/books,
		/obj/item/tank/internals,
	)
	armor_type = /datum/armor/jacket_curator
	cold_protection = CHEST|ARMS
	heat_protection = CHEST|ARMS

//Robotocist
/datum/armor/jacket_curator
	melee = 25
	bullet = 10
	laser = 25
	energy = 35
	acid = 45

/obj/item/clothing/suit/hooded/techpriest
	name = "techpriest robes"
	desc = "For those who REALLY love their toasters."
	icon_state = "techpriest"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/techpriest

/obj/item/clothing/head/hooded/techpriest
	name = "techpriest's hood"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	desc = "A hood for those who REALLY love their toasters."
	icon_state = "techpriesthood"
	inhand_icon_state = null
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

// Research Director

/obj/item/clothing/suit/jacket/research_director
	name = "research director's coat"
	desc = "A mix between a labcoat and just a regular coat. It's made out of a special anti-bacterial, anti-acidic, and anti-biohazardous synthetic fabric."
	icon_state = "labcoat_rd"
	armor_type = /datum/armor/jacket_research_director
	body_parts_covered = CHEST|GROIN|ARMS

/datum/armor/jacket_research_director
	bio = 75
	fire = 75
	acid = 75

/obj/item/clothing/suit/jacket/research_director/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/xeno
