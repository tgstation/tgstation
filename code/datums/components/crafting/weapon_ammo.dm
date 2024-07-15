/datum/crafting_recipe/meteorslug
	name = "Meteorslug Shell"
	result = /obj/item/ammo_casing/shotgun/meteorslug
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/rcd_ammo = 1,
		/datum/reagent/gunpowder = 10,
		/datum/reagent/consumable/ethanol/rum = 10,
		/obj/item/stock_parts/servo = 2,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/paperball
	name = "Paper Ball"
	result = /obj/item/ammo_casing/rebar/paperball
	reqs = list(
		/obj/item/paper = 1,
	)
	time = 0.1 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/rebarsyndie
	name = "jagged iron rod"
	result = /obj/item/ammo_casing/rebar/syndie
	reqs = list(
		/obj/item/stack/rods = 1,
	)
	tool_behaviors = list(TOOL_WIRECUTTER)
	time = 0.1 SECONDS
	category = CAT_WEAPON_AMMO
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/healium_bolt
	name = "healium crystal crossbow bolt"
	result = /obj/item/ammo_casing/rebar/healium
	reqs = list(
		/obj/item/grenade/gas_crystal/healium_crystal = 1
	)
	time = 0.1 SECONDS
	category = CAT_WEAPON_AMMO
	crafting_flags = CRAFT_CHECK_DENSITY

/datum/crafting_recipe/pulseslug
	name = "Pulse Slug Shell"
	result = /obj/item/ammo_casing/shotgun/pulseslug
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/stock_parts/capacitor/adv = 2,
		/obj/item/stock_parts/micro_laser/ultra = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/dragonsbreath
	name = "Dragonsbreath Shell"
	result = /obj/item/ammo_casing/shotgun/dragonsbreath
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/datum/reagent/phosphorus = 5,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/frag12
	name = "FRAG-12 Slug Shell"
	result = /obj/item/ammo_casing/shotgun/frag12
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/datum/reagent/glycerol = 5,
		/datum/reagent/toxin/acid/fluacid = 10,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/ionslug
	name = "Ion Scatter Shell"
	result = /obj/item/ammo_casing/shotgun/ion
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/stock_parts/micro_laser/ultra = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/improvisedslug
	name = "Junk Shell"
	result = /obj/effect/spawner/random/junk_shell
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/shard = 1,
		/datum/reagent/fuel = 10,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 1.2 SECONDS
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/trashball
	name = "Trashball"
	result = /obj/item/stack/cannonball/trashball
	reqs = list(
		/obj/item/stack/sheet = 5,
		/datum/reagent/consumable/space_cola = 10,
	)
	category = CAT_WEAPON_AMMO
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/arrow
	name = "Arrow"
	result = /obj/item/ammo_casing/arrow
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	tool_paths = list(
		/obj/item/hatchet,
	)
	time = 5 SECONDS
	category = CAT_WEAPON_AMMO
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/plastic_arrow
	name = "Plastic Arrow"
	result = /obj/item/ammo_casing/arrow/plastic
	reqs = list(
		/obj/item/stack/sheet/plastic = 1,
	)
	tool_paths = list(
		/obj/item/hatchet,
	)
	time = 5 SECONDS
	category = CAT_WEAPON_AMMO
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED


/datum/crafting_recipe/holy_arrow
	name = "Holy Arrow"
	result = /obj/item/ammo_casing/arrow/holy
	reqs = list(
		/obj/item/ammo_casing/arrow = 1,
		/datum/reagent/water/holywater = 10,
	)
	tool_paths = list(
		/obj/item/gun/ballistic/bow/divine,
	)
	time = 5 SECONDS
	category = CAT_WEAPON_AMMO
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED
