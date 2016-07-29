/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 20, MAT_GLASS = 10)
	category = "Bluespace"
	build_path = /obj/item/beacon

/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250)
	reliability_base = 80
	category = "Bluespace"
	build_path = /obj/item/weapon/storage/backpack/holding

/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 1500, MAT_PLASMA = 1500)
	reliability = 100
	category = "Bluespace"
	build_path = /obj/item/bluespace_crystal/artificial

/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A newly-developed high-capacity beaker, courtesy of bluespace research. Can hold up to 200 units."
	id = "bluespacebeaker_small"
	req_tech = list("bluespace" = 2, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 6000, MAT_IRON = 6000)
	reliability = 100
	category = "Bluespace"
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace

/datum/design/bluespacebeaker_large
	name = "Large Bluespace Beaker"
	desc = "A prototype ultra-capacity beaker, courtesy of bluespace research. Can hold up to 300 units."
	id = "bluespacebeaker_large"
	req_tech = list("bluespace" = 3, "materials" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 1500, MAT_IRON = 6000, MAT_GLASS = 6000)
	reliability = 100
	category = "Bluespace"
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace/large

/datum/design/stasisbeaker
	name = "Stasis Beaker"
	desc = "A beaker powered by experimental bluespace technology. Chemicals are held in stasis and do not react inside of it. Can hold up to 50 units."
	id = "stasisbeaker_small"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_URANIUM = 1500, MAT_IRON = 3750, MAT_GLASS = 3750)
	reliability = 100
	category = "Bluespace"
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact

/datum/design/stasisbeaker_large
	name = "Large Stasis Beaker"
	desc = "A beaker powered by experimental bluespace technology. Chemicals are held in stasis and do not react inside of it. Can hold up to 100 units."
	id = "stasisbeaker_large"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 1500, MAT_IRON = 3750, MAT_GLASS = 3750, MAT_URANIUM = 1500)
	reliability = 100
	category = "Bluespace"
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact/large

/datum/design/gps
	name = "Global Positioning System"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	id = "gps"
	req_tech = list("bluespace" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 800, MAT_GLASS = 200)
	category = "Bluespace"
	build_path = /obj/item/device/gps/science
