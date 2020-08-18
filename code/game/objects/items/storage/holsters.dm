
/obj/item/storage/belt/holster
	name = "shoulder holster"
	desc = "A rather plain but still badass looking holster that can hold a small firearm."
	icon_state = "holster"
	inhand_icon_state = "holster"
	worn_icon_state = "holster"
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
		/obj/item/gun/ballistic/automatic/toy/pistol,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling
		))

/obj/item/storage/belt/holster/detective
	name = "detective's holster"
	desc = "A holster able to carry a small firearm and some ammo. WARNING: Badasses only."

/obj/item/storage/belt/holster/detective/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/c38,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a762,
		/obj/item/gun/ballistic/automatic/toy/pistol,
		/obj/item/ammo_casing/caseless/foam_dart,
		/obj/item/gun/energy/e_gun/mini,	
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
	desc = "A hip holster that uses chameleon technology to disguise itself, it can hold a small firearm and its ammo."
	icon_state = "syndicate_holster"
	inhand_icon_state = "syndicate_holster"
	worn_icon_state = "syndicate_holster"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/holster/chameleon/Initialize()
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/belt
	chameleon_action.chameleon_name = "Belt"
	chameleon_action.initialize_disguises()

/obj/item/storage/belt/holster/chameleon/ComponentInitialize()
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
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/c38,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a762,
		/obj/item/gun/ballistic/automatic/toy/pistol,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/ammo_casing/caseless/foam_dart,
		/obj/item/gun/energy/kinetic_accelerator/crossbow,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling
		))

/obj/item/storage/belt/holster/nukie
	name = "operative holster"
	desc = "A deep shoulder holster capable of holding almost any form of firearm and its ammo."
	icon_state = "syndicate_holster"
	inhand_icon_state = "syndicate_holster"
	worn_icon_state = "syndicate_holster"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/holster/nukie/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 2
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.set_holdable(list(
		/obj/item/gun/ballistic/automatic,
		/obj/item/ammo_box/magazine/m75,
		/obj/item/ammo_box/magazine/m10mm/rifle,
		/obj/item/ammo_box/magazine/sniper_rounds,
		/obj/item/ammo_box/magazine/mm712x82,
		/obj/item/ammo_box/magazine/m556,
		/obj/item/ammo_box/magazine/tommygunm45,
		/obj/item/ammo_box/magazine/uzim9mm,
		/obj/item/ammo_box/magazine/plastikov9mm,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/smgm9mm,
		/obj/item/ammo_box/magazine/smgm45,
		/obj/item/ammo_box/magazine/recharge,
		/obj/item/gun/ballistic/automatic/toy/pistol,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/gun/ballistic/automatic/toy,
		/obj/item/ammo_box/magazine/toy/smg,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/c38,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a762,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/pulse/carbine,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/ballistic/shotgun,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box/magazine/m12g,
		/obj/item/gun/ballistic/rocketlauncher,
		/obj/item/ammo_casing/caseless/rocket,
		/obj/item/gun/energy/kinetic_accelerator/crossbow
		))
