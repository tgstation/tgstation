/obj/item/clothing/suit/apron/chef/red
	name = "красный фартук"
	icon = 'modular_bandastation/objects/icons/obj/clothing/accessories.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/accessories.dmi'
	icon_state = "apron_red"
	worn_icon_state = "apron_red"

/obj/item/clothing/accessory/ammo_vest
	name = "ammo vest"
	desc = "Тактическая разгрузка для хранения магазинов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/webbings.dmi'
	icon_state = "webbing"
	worn_icon = 'modular_bandastation/objects/icons/onbody/webbings.dmi'
	worn_icon_state = "webbing"
	w_class = WEIGHT_CLASS_BULKY

/datum/storage/pockets/ammo_webbing
	max_slots = 4
	max_total_storage = 9
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/ammo_webbing/New()
	. = ..()
	set_holdable(list(
		/obj/item/ammo_box/magazine,
		/obj/item/ammo_box/speedloader
	))

/obj/item/clothing/accessory/ammo_vest/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/ammo_webbing)

/obj/item/clothing/accessory/ammo_vest/can_attach_accessory(obj/item/clothing/under/attach_to, mob/living/user)
	. = ..()
	if(!.)
		return

	if(!isnull(attach_to.atom_storage))
		if(user)
			attach_to.balloon_alert(user, "Этот предмет не помещается!")
		return FALSE
	return TRUE

/obj/item/clothing/accessory/ammo_vest/black
	name = "black ammo vest"
	desc = "Тактическая тёмная разгрузка для хранения магазинов."
	icon_state = "webbing_black"
	worn_icon_state = "webbing_black"
