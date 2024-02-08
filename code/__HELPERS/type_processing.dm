/proc/make_types_fancy(list/types)
	if (ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		// Longest paths comes first
		var/static/list/TYPES_SHORTCUTS = list(
			/obj/effect/decal/cleanable = "CLEANABLE",
			/obj/item/bodypart = "BODYPART",
			/obj/item/radio/headset = "HEADSET",
			/obj/item/clothing/accessory = "ACCESSORY",
			/obj/item/clothing/mask/gas = "GASMASK",
			/obj/item/clothing/mask = "MASK",
			/obj/item/clothing/gloves = "GLOVES",
			/obj/item/clothing/shoes = "SHOES",
			/obj/item/clothing/under/plasmaman = "PLASMAMAN_SUIT",
			/obj/item/clothing/under = "JUMPSUIT",
			/obj/item/clothing/suit/armor = "ARMOR",
			/obj/item/clothing/suit = "SUIT",
			/obj/item/clothing/head/helmet = "HELMET",
			/obj/item/clothing/head = "HEAD",
			/obj/item/clothing/neck = "NECK",
			/obj/item/clothing = "CLOTHING",
			/obj/item/storage/backpack = "BACKPACK",
			/obj/item/storage/belt = "BELT",
			/obj/item/book/manual = "MANUAL",
			/obj/item/storage/pill_bottle = "PILL_BOTTLE",
			/obj/item/reagent_containers/pill/patch = "MEDPATCH",
			/obj/item/reagent_containers/pill = "PILL",
			/obj/item/reagent_containers/hypospray/medipen = "MEDIPEN",
			/obj/item/reagent_containers/cup/glass = "DRINK",
			/obj/item/food = "FOOD",
			/obj/item/reagent_containers = "REAGENT_CONTAINERS",
			/obj/machinery/atmospherics = "ATMOS_MECH",
			/obj/machinery/portable_atmospherics = "PORT_ATMOS",
			/obj/item/mecha_parts/mecha_equipment/weapon = "MECHA_WEAPON",
			/obj/item/mecha_parts/mecha_equipment = "MECHA_EQUIP",
			/obj/item/organ = "ORGAN",
			/obj/item/mod/control = "MODSUIT",
			/obj/item/mod/module = "MODSUIT_MOD",
			/obj/item/gun/ballistic/automatic = "GUN_AUTOMATIC",
			/obj/item/gun/ballistic/revolver = "GUN_REVOLVER",
			/obj/item/gun/ballistic/rifle = "GUN_RIFLE",
			/obj/item/gun/ballistic/shotgun = "GUN_SHOTGUN",
			/obj/item/gun/ballistic = "GUN_BALLISTIC",
			/obj/item/gun/energy/laser = "GUN_LASER",
			/obj/item/gun/energy = "GUN_ENERGY",
			/obj/item/gun/magic = "GUN_MAGIC",
			/obj/item/gun = "GUN",
			/obj/item/stack/sheet/mineral = "MINERAL_SHEET",
			/obj/item/stack/sheet = "SHEET",
			/obj/item/stack/ore = "ORE",
			/obj/item/ai_module = "AI_LAW_MODULE",
			/obj/item/circuitboard/machine = "MACHINE_BOARD",
			/obj/item/circuitboard/computer = "COMPUTER_BOARD",
			/obj/item/circuitboard = "CIRCUITBOARD",
			/obj/item = "ITEM",
			/obj/structure/closet/crate/secure = "LOCKED_CRATE",
			/obj/structure/closet/crate = "CRATE",
			/obj/structure/closet/secure_closet = "LOCKED_CLOSET",
			/obj/structure/closet = "CLOSET",
			/obj/structure = "STRUCTURE",
			/obj/machinery/door/airlock = "AIRLOCK",
			/obj/machinery/door = "DOOR",
			/obj/machinery/rnd/production = "RND_FABRICATOR",
			/obj/machinery/computer/camera_advanced/shuttle_docker = "DOCKING_COMPUTER",
			/obj/machinery/computer = "COMPUTER",
			/obj/machinery/vending/wardrobe = "JOBDROBE",
			/obj/machinery/vending = "VENDING",
			/obj/machinery = "MACHINERY",
			/obj/effect = "EFFECT",
			/obj/projectile = "PROJECTILE",
			/obj = "O",
			/datum = "D",
			/turf/open = "OPEN",
			/turf/closed = "CLOSED",
			/turf = "T",
			/mob/living/carbon/human = "HUMANOID",
			/mob/living/carbon = "CARBON",
			/mob/living/simple_animal = "SIMPLE",
			/mob/living/basic = "BASIC",
			/mob/living/silicon/robot = "CYBORG",
			/mob/living/silicon = "SILICON",
			/mob/living = "LIVING",
			/mob = "M",
		)
		for (var/tn in TYPES_SHORTCUTS)
			if(copytext(typename, 1, length("[tn]/") + 1) == "[tn]/" /*findtextEx(typename,"[tn]/",1,2)*/ )
				typename = TYPES_SHORTCUTS[tn] + copytext(typename, length("[tn]/"))
				break
		.[typename] = type

/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_list
	if (!pre_generated_list) //init
		pre_generated_list = make_types_fancy(typesof(/atom))
	return pre_generated_list


/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_list
	if (!pre_generated_list) //init
		pre_generated_list = make_types_fancy(sort_list(typesof(/datum) - typesof(/atom)))
	return pre_generated_list


/proc/filter_fancy_list(list/L, filter as text)
	var/list/matches = new
	var/end_len = -1
	var/list/endcheck = splittext(filter, "!")
	if(endcheck.len > 1)
		filter = endcheck[1]
		end_len = length_char(filter)

	for(var/key in L)
		var/value = L[key]
		if(findtext("[key]", filter, -end_len) || findtext("[value]", filter, -end_len))
			matches[key] = value
	return matches

/proc/return_typenames(type)
	return splittext("[type]", "/")
