/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = /obj/item/melee/baton/security/cattleprod
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/rods = 1,
		/obj/item/assembly/igniter = 1,
	)
	time = 4 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/teleprod
	name = "Teleprod"
	result = /obj/item/melee/baton/security/cattleprod/teleprod
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/rods = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)
	time = 4 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/telecrystalprod
	name = "Snatcherprod"
	result = /obj/item/melee/baton/security/cattleprod/telecrystalprod
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/rods = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/telecrystal = 1,
	)
	time = 4 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/tailclub
	name = "Tail Club"
	result = /obj/item/tailclub
	reqs = list(
		/obj/item/organ/external/tail/lizard = 1,
		/obj/item/stack/sheet/iron = 1,
	)
	blacklist = list(/obj/item/organ/external/tail/lizard/fake)
	time = 4 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/tailwhip
	name = "Liz O' Nine Tails"
	result = /obj/item/melee/chainofcommand/tailwhip
	reqs = list(
		/obj/item/organ/external/tail/lizard = 1,
		/obj/item/stack/cable_coil = 1,
	)
	blacklist = list(/obj/item/organ/external/tail/lizard/fake)
	time = 4 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/catwhip
	name = "Cat O' Nine Tails"
	result = /obj/item/melee/chainofcommand/tailwhip/kitty
	reqs = list(
		/obj/item/organ/external/tail/cat = 1,
		/obj/item/stack/cable_coil = 1,
	)
	time = 4 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/chainsaw
	name = "Chainsaw"
	result = /obj/item/chainsaw
	reqs = list(
		/obj/item/circular_saw = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/plasteel = 5,
	)
	tool_behaviors = list(TOOL_WELDER)
	time = 5 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/spear
	name = "Spear"
	result = /obj/item/spear
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/shard = 1,
		/obj/item/stack/rods = 1,
	)
	parts = list(/obj/item/shard = 1)
	time = 4 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/toysword
	name = "Toy Sword"
	reqs = list(
		/obj/item/light/bulb = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/plastic = 4,
	)
	result = /obj/item/toy/sword
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/bonedagger
	name = "Bone Dagger"
	result = /obj/item/knife/combat/bone
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 2)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/bonespear
	name = "Bone Spear"
	result = /obj/item/spear/bonespear
	time = 3 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 4,
		/obj/item/stack/sheet/sinew = 1,
	)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/boneaxe
	name = "Bone Axe"
	result = /obj/item/fireaxe/boneaxe
	time = 5 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 6,
		/obj/item/stack/sheet/sinew = 3,
	)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/house_edge
	name = "House Edge"
	result = /obj/item/house_edge
	always_available = FALSE
	tool_behaviors = list(TOOL_WRENCH, TOOL_SCREWDRIVER, TOOL_WELDER)
	reqs = list(
		/obj/item/v8_engine = 1,
		/obj/item/weaponcrafting/receiver = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/knife = 1,
		/obj/item/weldingtool = 1,
		/obj/item/roulette_wheel_beacon = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/giant_wrench
	name = "Big Slappy"
	result = /obj/item/shovel/giant_wrench
	tool_behaviors = list(TOOL_CROWBAR, TOOL_SCREWDRIVER, TOOL_WELDER)
	reqs = list(
		/obj/item/wrench = 4,
		/obj/item/weaponcrafting/giant_wrench = 1,
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/rods = 10,
		/obj/item/pickaxe/drill = 1,
	)
	time = 10 SECONDS
	category = CAT_WEAPON_MELEE
