// Simple define to avoid copy-pasting the same code 3 times
#define ABDUCTOR_SUBTYPE_UNLOCKS(X) \
	##X/New() { \
		. = ..(); \
		required_items_to_unlock += subtypesof(/obj/item/abductor); \
		required_items_to_unlock += subtypesof(/obj/item/circuitboard/machine/abductor); \
	}

/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list(/datum/techweb_node/bluespace_travel)
	required_items_to_unlock = list(
		/obj/item/stack/sheet/mineral/abductor,
		/obj/item/cautery/alien,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/hemostat/alien,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	design_ids = list(
		/datum/design/alloy/alien,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	hidden = TRUE

ABDUCTOR_SUBTYPE_UNLOCKS(/datum/techweb_node/alientech)

/datum/techweb_node/alientech/on_station_research()
	. = ..()
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_ALIENTECH] = TRUE

/datum/techweb_node/alien_engi
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list(/datum/techweb_node/alientech, /datum/techweb_node/exp_tools)
	design_ids = list(
		/datum/design/aliencrowbar,
		/datum/design/alienmultitool,
		/datum/design/alienscrewdriver,
		/datum/design/alienwelder,
		/datum/design/alienwirecutters,
		/datum/design/alienwrench,
	)
	required_items_to_unlock = list(
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/screwdriver/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

ABDUCTOR_SUBTYPE_UNLOCKS(/datum/techweb_node/alien_engi)

/datum/techweb_node/alien_surgery
	display_name = "Alien Surgery"
	description = "Abductors did nothing wrong."
	prereq_ids = list(/datum/techweb_node/alientech, /datum/techweb_node/surgery_tools)
	design_ids = list(
		/datum/design/aliencautery,
		/datum/design/aliendrill,
		/datum/design/alienhemostat,
		/datum/design/alienretractor,
		/datum/design/aliensaw,
		/datum/design/alienscalpel,
		/datum/design/medibot_upgrade/tier_four,
		/datum/design/surgery/brainwashing,
		/datum/design/surgery/brainwashing/mechanic,
		/datum/design/surgery/tend_wounds_combo/upgrade/femto,
		/datum/design/surgery/necrotic_revival,
	)
	required_items_to_unlock = list(
		/obj/item/cautery/alien,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/hemostat/alien,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/slime/hard = TECHWEB_TIER_5_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

ABDUCTOR_SUBTYPE_UNLOCKS(/datum/techweb_node/alien_surgery)

#undef ABDUCTOR_SUBTYPE_UNLOCKS
