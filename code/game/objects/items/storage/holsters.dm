
/obj/item/storage/belt/holster
	name = "shoulder holster"
	desc = "A rather plain but still badass looking holster with a single pouch that can hold a small firearm."
	icon_state = "holster"
	item_state = "holster"
	alternate_worn_layer = UNDER_SUIT_LAYER

/obj/item/storage/belt/holster/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_BELT)
		ADD_TRAIT(user, TRAIT_GUNFLIP, CLOTHING_TRAIT)

/obj/item/storage/belt/holster/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_GUNFLIP, CLOTHING_TRAIT)

/obj/item/storage/belt/holster/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/pulse/carbine,
		/obj/item/gun/energy/dueling
		))

/obj/item/storage/belt/holster/detective
	name = "detective's holster"
	desc = "A holster to carry a handgun and ammo. WARNING: Badasses only."

/obj/item/storage/belt/holster/detective/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling
		))

/obj/item/storage/belt/holster/detective/full/PopulateContents()
	var/static/items_inside = list(
		/obj/item/gun/ballistic/revolver/detective = 1,
		/obj/item/ammo_box/c38 = 2)
	generate_items_inside(items_inside,src)

/obj/item/storage/belt/holster/chameleon
	name = "syndicate holster"
	desc = "A two pouched hip holster that uses chameleon technology to disguise itself and any guns in it."
	icon_state = "syndicate_holster"
	item_state = "syndicate_holster"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/holster/chameleon/Initialize()
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/belt
	chameleon_action.chameleon_name = "Belt"
	chameleon_action.initialize_disguises()

/obj/item/storage/belt/chameleon/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.silent = TRUE

/obj/item/storage/belt/holster/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/belt/holster/chameleon/broken/Initialize()
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/belt/holster/chameleon/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 2
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/pulse/carbine,
		/obj/item/gun/energy/dueling
		))

/obj/item/storage/belt/holster/nukie
	name = "operative holster"
	desc = "A deep shoulder holster capable of holding almost any form of ballistic weaponry."
	icon_state = "syndicate_holster"
	item_state = "syndicate_holster"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/holster/nukie/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 2
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.set_holdable(list(
		/obj/item/gun/ballistic/automatic,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/pulse/carbine,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/ballistic/shotgun,
		/obj/item/gun/ballistic/rocketlauncher
		))
