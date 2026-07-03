/mob/living/carbon/human/proc/is_accessory_covered()
	if(!wear_suit)
		return FALSE

	return !!(wear_suit.flags_inv & HIDEJUMPSUIT)

//MARK: Standart holster, empty
/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "Обычная, ничем не примечательная кобура под одно небольшое оружие."
	icon = 'modular_bandastation/objects/icons/obj/clothing/holsters.dmi'
	icon_state = "holster"
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "holster"
	alternate_worn_layer = UNDER_SUIT_LAYER
	w_class = WEIGHT_CLASS_BULKY
	above_suit = FALSE
	icon_state_is_worn = FALSE
	var/check_covering = TRUE

/obj/item/clothing/accessory/holster/proc/PopulateContents()
	return

/obj/item/clothing/accessory/holster/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/holster)
	PopulateContents()

/obj/item/clothing/accessory/holster/Entered(atom/movable/I)
	. = ..()

	if(istype(I, /obj/item/gun))
		playsound(src, 'modular_bandastation/weapon/sound/ranged/holster_getting.ogg', 50, TRUE)

/obj/item/clothing/accessory/holster/Exited(atom/movable/I)
	. = ..()

	if(istype(I, /obj/item/gun))
		playsound(src, 'modular_bandastation/weapon/sound/ranged/holster_putting.ogg', 50, TRUE)

/obj/item/clothing/accessory/holster/attach(obj/item/clothing/under/attach_to, mob/living/attacher)
	. = ..()
	flags_1 &= ~HAS_DISASSOCIATED_STORAGE_1

/obj/item/clothing/accessory/holster/proc/can_access_holster(mob/user)
	if(!check_covering)
		return TRUE
	if(!ishuman(user))
		return TRUE

	var/mob/living/carbon/human/H = user
	if(H.is_accessory_covered())
		return FALSE
	return TRUE

/obj/item/clothing/accessory/holster/attack_hand(mob/user)
	if(user != loc)
		var/mob/living/carbon/human/H = null
		if(ishuman(loc))
			H = loc
		else if(ishuman(loc?.loc))
			H = loc.loc
		if(H)
			H.visible_message(
				span_userdanger("[user] пытается сорвать кобуру с [H]!"),
				span_userdanger("[user] пытается сорвать вашу кобуру!")
			)
			return

	return ..()

/obj/item/clothing/accessory/holster/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	..()
	if(user)
		ADD_CLOTHING_TRAIT(user, TRAIT_GUNFLIP)

/obj/item/clothing/accessory/holster/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	..()
	if(user)
		REMOVE_CLOTHING_TRAIT(user, TRAIT_GUNFLIP)

// Empty energy holster
/obj/item/clothing/accessory/holster/energy
	name = "energy shoulder holsters"
	desc = "Обычная, ничем не примечательная кобура под несколько энергетических пистолетов."
	check_covering = TRUE

/obj/item/clothing/accessory/holster/energy/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/holster/energy)

// Energy holster with one disabler
/obj/item/clothing/accessory/holster/energy/disabler

/obj/item/clothing/accessory/holster/energy/disabler/PopulateContents()
	new /obj/item/gun/energy/disabler(src)

// Energy holster with one laser pistol
/obj/item/clothing/accessory/holster/energy/laser_pistol

/obj/item/clothing/accessory/holster/energy/laser_pistol/PopulateContents()
	new /obj/item/gun/energy/laser/pistol(src)

// Energy holster with two smoothborne disablers
/obj/item/clothing/accessory/holster/energy/smoothborne

/obj/item/clothing/accessory/holster/energy/smoothborne/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/energy/disabler/smoothbore = 2,
	), src)

// Energy holster with two nano-pistols
/obj/item/clothing/accessory/holster/energy/thermal

/obj/item/clothing/accessory/holster/energy/thermal/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/energy/laser/thermal/inferno = 1,
		/obj/item/gun/energy/laser/thermal/cryo = 1,
	), src)

// Detective holster
/obj/item/clothing/accessory/holster/detective
	name = "detective's holster"
	desc = "Улучшенная кобура, специально созданная для проведения самых громких и выдающихся расследований. Имеет дополнительные кармашки для магазинов."
	check_covering = TRUE

/obj/item/clothing/accessory/holster/detective/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/holster/detective)

// One gun logic
/obj/item/clothing/accessory/holster/detective/Entered(atom/movable/I)
	. = ..()

	if(!istype(I, /obj/item/gun))
		return

	var/obj/item/gun/new_gun = I
	var/obj/item/gun/existing_gun = null

	for(var/obj/item/gun/G in src)
		if(G != new_gun)
			existing_gun = G
			break

	if(existing_gun)
		var/mob/user = null

		if(ismob(src.loc))
			user = src.loc
		else if(ismob(src.loc?.loc))
			user = src.loc.loc
		new_gun.forceMove(user ? user : get_turf(src))

		if(user)
			user.put_in_hands(new_gun)
			to_chat(user, span_warning("В кобуре уже есть оружие!"))

// Full detective holster
/obj/item/clothing/accessory/holster/detective/full

/obj/item/clothing/accessory/holster/detective/full/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/revolver/c38/detective = 1,
		/obj/item/ammo_box/speedloader/c38 = 2,
	), src)

// Veteran advisor version
/obj/item/clothing/accessory/holster/detective/veteran_advisor

/obj/item/clothing/accessory/holster/detective/veteran_advisor/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 1,
		/obj/item/ammo_box/magazine/m45 = 2,
	), src)

// Psyker holster
/obj/item/clothing/accessory/holster/psyker
	name = "psyker holster"
	desc = "Кобура, специально дополненная различными карманами для осуществления священной миссии псайкер-оперативников."
	check_covering = FALSE

/datum/storage/pockets/holster/psyker
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/holster/psyker/New()
	. = ..()
	set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/disabler/smoothbore,
		/obj/item/gun/energy/pulse/pistol,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/ammo_box/magazine,
		/obj/item/ammo_box/speedloader
	))

/obj/item/clothing/accessory/holster/psyker/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/psyker)
	new /obj/item/gun/ballistic/revolver/c38(src)
	new /obj/item/ammo_box/speedloader/c38(src)
	new /obj/item/ammo_box/speedloader/c38(src)
	new /obj/item/ammo_box/speedloader/c38(src)

// Traitor holster
/obj/item/clothing/accessory/holster/chameleon
	name = "pocket protector"
	desc = "Может защитить вашу одежду от чернильных пятен, но вы будете выглядеть как зануда, если будете им пользоваться."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "pocketprotector"
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	worn_icon_state = "pocketprotector"
	w_class = WEIGHT_CLASS_SMALL
	above_suit = TRUE
	check_covering = FALSE

/datum/storage/pockets/holster/traitor
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_NORMAL
	silent = TRUE

/datum/storage/pockets/holster/traitor/New()
	. = ..()
	set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser/pistol,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/disabler/smoothbore,
		/obj/item/gun/energy/pulse/pistol,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/energy/eg_14,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/e_gun/mini
	))

/obj/item/clothing/accessory/holster/chameleon/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/holster/traitor)

// Tacticool holster
/obj/item/clothing/accessory/holster/tacticool
	name = "tacticool holster"
	desc = "Тёмная тактическая кобура с двумя карманами, предназначенная для выполнения специальных задач. Особые крепления позволяют надеть её поверх униформы."
	icon_state = "operative_holster"
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "syndicate_holster"
	check_covering = FALSE

/obj/item/clothing/accessory/holster/tacticool/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/holster/nukie)

/obj/item/clothing/accessory/holster/tacticool/cowboy

/obj/item/clothing/accessory/holster/tacticool/cowboy/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/revolver/cowboy/nuclear = 1,
		/obj/item/ammo_box/speedloader/c357 = 1,
	), src)

/obj/item/clothing/accessory/holster/tacticool/ert_gp93r

/obj/item/clothing/accessory/holster/tacticool/ert_gp93r/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/automatic/pistol/gp9/spec = 1,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap = 1,
	), src)

/obj/item/clothing/accessory/holster/tacticool/ert_gammacom

/obj/item/clothing/accessory/holster/tacticool/ert_gammacom/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/automatic/cm5/compact = 1,
		/obj/item/gun/ballistic/automatic/pistol/cm357 = 1,
	), src)

/obj/item/clothing/accessory/holster/tacticool/tsf_commander

/obj/item/clothing/accessory/holster/tacticool/tsf_commander/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/automatic/pistol/deagle/regal = 1,
		/obj/item/ammo_box/magazine/r45 = 1,
	), src)

/obj/item/clothing/accessory/holster/tacticool/ussp_commander
	icon_state = "holster"
	worn_icon_state = "holster"
	desc = "Коричневая тактическая кобура с двумя карманами, предназначенная для выполнения специальных задач. Особые крепления позволяют надеть её поверх униформы."

/obj/item/clothing/accessory/holster/tacticool/ussp_commander/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/revolver/nagant = 1,
		/obj/item/ammo_box/speedloader/n762_cylinder = 1,
	), src)
