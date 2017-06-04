///////SMELTABLE ALLOYS///////

/datum/design/plasteel_alloy
	name = "Plasma + Iron alloy"
	id = "plasteel"
	build_type = SMELTER
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT / 2, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT / 2)
	build_path = /obj/item/stack/sheet/plasteel
	category = list("initial")


/datum/design/plastitanium_alloy
	name = "Plasma + Titanium alloy"
	id = "plastitanium"
	build_type = SMELTER
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT / 2, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT / 2)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list("initial")

/datum/design/alienalloy
	name = "Alien Alloy"
	desc = "A sheet of reverse-engineered alien alloy."
	id = "alienalloy"
	req_tech = list("abductor" = 1, "materials" = 7, "plasmatech" = 2)
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list("Stock Parts")

//Design disk for test purposes.
/obj/item/weapon/disk/design_disk/alienalloy
	name = "Alloy Design Disk"
	desc = "A disk containing details on the creation of alloys."
	icon_state = "datadisk1"
	max_blueprints = 5

/obj/item/weapon/disk/design_disk/alienalloy/Initialize()
	. = ..()
	var/datum/design/alienalloy/A = new
	var/datum/design/plastitanium_alloy/B = new
	var/datum/design/plasteel_alloy/C = new
	var/datum/design/board/ore_redemption/D = new
	blueprints[1] = A
	blueprints[2] = B
	blueprints[3] = C
	blueprints[4] = D