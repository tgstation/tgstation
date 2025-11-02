// Simple define to avoid copy-pasting the same code 3 times
#define ABDUCTOR_SUBTYPE_UNLOCKS(X) \
	##X/New() { \
		. = ..(); \
		required_items_to_unlock += subtypesof(/obj/item/abductor); \
		required_items_to_unlock += subtypesof(/obj/item/circuitboard/machine/abductor); \
	}

/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = TECHWEB_NODE_ALIENTECH
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list(TECHWEB_NODE_BLUESPACE_TRAVEL)
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
		"alienalloy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	hidden = TRUE

ABDUCTOR_SUBTYPE_UNLOCKS(/datum/techweb_node/alientech)

/datum/techweb_node/alientech/on_station_research()
	. = ..()
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_ALIENTECH] = TRUE

/datum/techweb_node/alien_engi
	id = TECHWEB_NODE_ALIEN_ENGI
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list(TECHWEB_NODE_ALIENTECH, TECHWEB_NODE_EXP_TOOLS)
	design_ids = list(
		"alien_crowbar",
		"alien_multitool",
		"alien_screwdriver",
		"alien_welder",
		"alien_wirecutters",
		"alien_wrench",
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
	id = TECHWEB_NODE_ALIEN_SURGERY
	display_name = "Alien Surgery"
	description = "Abductors did nothing wrong."
	prereq_ids = list(TECHWEB_NODE_ALIENTECH, TECHWEB_NODE_SURGERY_TOOLS)
	design_ids = list(
		"alien_cautery",
		"alien_drill",
		"alien_hemostat",
		"alien_retractor",
		"alien_saw",
		"alien_scalpel",
		"medibot_upgrade_four",
		"surgery_brainwashing",
		"surgery_brainwashing_mechanic",
		"surgery_heal_combo_upgrade_femto",
		"surgery_zombie",
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
