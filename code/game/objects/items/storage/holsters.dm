
/obj/item/storage/belt/holster
	name = "shoulder holster"
	desc = "A rather plain but still cool looking holster that can hold a handgun."
	icon_state = "holster"
	inhand_icon_state = "holster"
	worn_icon_state = "holster"
	alternate_worn_layer = UNDER_SUIT_LAYER

/obj/item/storage/belt/holster/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_BELT || ITEM_SLOT_SUITSTORE)
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
		/obj/item/gun/energy/dueling,
		/obj/item/food/grown/banana,
		))

/obj/item/storage/belt/holster/detective
	name = "detective's holster"
	desc = "A holster able to carry handguns and some ammo. WARNING: Badasses only."

/obj/item/storage/belt/holster/detective/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm, // Pistol magazines.
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/c38, // Revolver speedloaders.
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a762,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/dueling,
		))

/obj/item/storage/belt/holster/detective/full/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/revolver/detective = 1,
		/obj/item/ammo_box/c38/match/bouncy = 2,
	),src)

/obj/item/storage/belt/holster/detective/full/ert
	name = "marine's holster"
	desc = "Wearing this makes you feel badass, but you suspect it's just a repainted detective's holster from the NT surplus."
	icon_state = "syndicate_holster"
	inhand_icon_state = "syndicate_holster"
	worn_icon_state = "syndicate_holster"

/obj/item/storage/belt/holster/detective/full/ert/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 1,
		/obj/item/ammo_box/magazine/m45 = 2,
	),src)

/obj/item/storage/belt/holster/chameleon
	name = "syndicate holster"
	desc = "A hip holster that uses chameleon technology to disguise itself, due to the added chameleon tech, it cannot be mounted onto armor."
	icon_state = "syndicate_holster"
	inhand_icon_state = "syndicate_holster"
	worn_icon_state = "syndicate_holster"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/holster/chameleon/Initialize(mapload)
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

/obj/item/storage/belt/holster/chameleon/broken/Initialize(mapload)
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
		/obj/item/ammo_box/magazine/toy/pistol,
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
		/obj/item/gun, // ALL guns.
		/obj/item/ammo_box/magazine, // ALL magazines.
		/obj/item/ammo_box/c38, //There isn't a speedloader parent type, so I just put these three here by hand.
		/obj/item/ammo_box/a357, //I didn't want to just use /obj/item/ammo_box, because then this could hold huge boxes of ammo.
		/obj/item/ammo_box/a762,
		/obj/item/ammo_casing, // For shotgun shells, rockets, launcher grenades, and a few other things.
		/obj/item/grenade, // All regular grenades, the big grenade launcher fires these.
		))
