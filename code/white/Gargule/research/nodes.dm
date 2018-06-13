/datum/techweb_node/alien_bio_adv
	id = "alien_bio_adv"
	display_name = "Advanced Alien Biological Tools"
	description = "Advanced biological tools MK2."
	prereq_ids = list("alien_bio")
	design_ids = list("ci-aliensurgery")
//	boost_item_paths = list(/obj/item/gun/energy/alien = 0, /obj/item/scalpel/alien = 0, /obj/item/hemostat/alien = 0, /obj/item/retractor/alien = 0, /obj/item/circular_saw/alien = 0,
//	/obj/item/cautery/alien = 0, /obj/item/surgicaldrill/alien = 0, /obj/item/screwdriver/abductor = 0, /obj/item/wrench/abductor = 0, /obj/item/crowbar/abductor = 0, /obj/item/multitool/abductor = 0,
//	/obj/item/weldingtool/abductor = 0, /obj/item/wirecutters/abductor = 0, /obj/item/circuitboard/machine/abductor = 0, /obj/item/abductor_baton = 0, /obj/item/abductor = 0)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 20000
	hidden = FALSE