/*Crafting recipes for stuff made out of the blacksmtihing tools*/

/datum/crafting_recipe/dwarf/broadsword
	name = "Smithed Broadsword"
	result = /obj/item/weapon/smithed_sword
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/blade = 1)
	parts = list(/obj/item/weapon/mold_result/blade = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/warhammer
	name = "Smithed Warhammer"
	result = /obj/item/weapon/twohanded/smithed_warhammer
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/hammer_head = 1)
	parts = list(/obj/item/weapon/mold_result/hammer_head = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/shield
	name = "Smithed Buckler"
	result = /obj/item/weapon/shield/riot/buckler/smith
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/shield_backing = 1)
	parts = list(/obj/item/weapon/mold_result/shield_backing = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/pickaxe
	name = "Smithed Pickaxe"
	result = /obj/item/weapon/pickaxe/smithed_pickaxe
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/pickaxe_head = 1)
	parts = list(/obj/item/weapon/mold_result/pickaxe_head = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/shovel
	name = "Smithed Shovel"
	result = /obj/item/weapon/shovel/smithed_shovel
	reqs = list(/obj/item/weapon/grown/log = 1,
				/obj/item/weapon/mold_result/shovel_head = 1)
	parts = list(/obj/item/weapon/mold_result/shovel_head = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/smith_armor
	name = "Smithed Armor"
	result = /obj/item/clothing/suit/armor/vest/dwarf
	reqs = list(/obj/item/stack/sheet/leather = 4,
				/obj/item/weapon/mold_result/armor_plating = 1)
	parts = list(/obj/item/weapon/mold_result/armor_plating = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/smith_helmet
	name = "Smithed Helmet"
	result = /obj/item/clothing/head/helmet/dwarf
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/weapon/mold_result/helmet_plating = 1)
	parts = list(/obj/item/weapon/mold_result/helmet_plating = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/bolts
	name = "Crossbow Bolts(5)(Stand next to anvil)"
	result = /obj/item/crossbow_bolt_spawner
	reqs = list(/obj/item/stack/sheet/metal = 10)
	tools = list(/obj/machinery/anvil)
	time = 10
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/crossbow
	name = "Smithed Crossbow"
	result = /obj/item/weapon/gun/ballistic/automatic/speargun/crossbow
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/weapon/mold_result/crossbow_base = 1)
	parts = list(/obj/item/weapon/mold_result/crossbow_base = 1)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/smeltery // Smelt shit.
	name = "Fort-In-A-Box (Smeltery) (Stand next to anvil)"
	result = /obj/item/weapon/survivalcapsule/fort_in_a_box/smeltery
	reqs = list(/obj/item/stack/sheet/metal = 10, /obj/item/stack/sheet/mineral/wood = 5)
	tools = list(/obj/machinery/anvil)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/throne_room // Make nobles.
	name = "Fort-In-A-Box (Throne Room)"
	result = /obj/item/weapon/survivalcapsule/fort_in_a_box/throne_room
	reqs = list(/obj/item/stack/sheet/mineral/gold = 50)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/dining_hall // A place to gather.
	name = "Fort-In-A-Box (Dining Hall)"
	result = /obj/item/weapon/survivalcapsule/fort_in_a_box/dining_hall
	reqs = list(/obj/item/stack/sheet/metal = 20, /obj/item/stack/sheet/mineral/wood = 20)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/brewery // Mandatory.
	name = "Fort-In-A-Box (Brewery)"
	result = /obj/item/weapon/survivalcapsule/fort_in_a_box/brewery
	reqs = list(/obj/item/stack/sheet/metal = 5, /obj/item/stack/sheet/mineral/wood = 10, /obj/item/stack/sheet/mineral/sandstone = 5)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/dorm // Allow new migrants.
	name = "Fort-In-A-Box (Dorm)"
	result = /obj/item/weapon/survivalcapsule/fort_in_a_box/dorm
	reqs = list(/obj/item/stack/sheet/metal = 10, /obj/item/stack/sheet/mineral/wood = 5, /obj/item/stack/sheet/leather = 6)
	time = 40
	category = CAT_SMITH

/datum/crafting_recipe/dwarf/farm // Grow ale supplies.
	name = "Fort-In-A-Box (Farm)"
	result = /obj/item/weapon/survivalcapsule/fort_in_a_box/farm
	reqs = list(/obj/item/stack/sheet/metal = 15, /obj/item/stack/sheet/mineral/sandstone = 30)
	time = 40
	category = CAT_SMITH