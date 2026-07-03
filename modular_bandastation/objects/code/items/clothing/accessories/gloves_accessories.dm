/obj/item/clothing/accessory/gloves_accessory
	name = "gloves accessory"
	abstract_type = /obj/item/clothing/accessory/gloves_accessory
	desc = "An accessory that can be worn on gloves."
	icon = 'modular_bandastation/objects/icons/obj/items/rings.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/inhands/rings-hands.dmi'
	slot_flags = ITEM_SLOT_GLOVES
	attachment_slot = HANDS
	icon_state_is_worn = FALSE
	body_parts_covered = 0
	icon_state = "ringgold"
	worn_icon_state = "gring"

/obj/item/clothing/accessory/gloves_accessory/can_attach_accessory(obj/item/clothing/gloves/attach_to, mob/living/user)
	if(!istype(attach_to))
		CRASH("[type] - can_attach_accessory called with an invalid item to attach to. (got: [attach_to])")

	if(atom_storage && attach_to.atom_storage)
		if(user)
			attach_to.balloon_alert(user, "несовместимо с этим!")
		return FALSE

	if(attachment_slot && !(attach_to.body_parts_covered & attachment_slot))
		if(user)
			attach_to.balloon_alert(user, "нельзя надеть сюда!")
		return FALSE

	if(length(attach_to.attached_accessories) >= attach_to.max_number_of_accessories)
		if(user)
			attach_to.balloon_alert(user, "слишком много аксессуаров!")
		return FALSE

	return TRUE

/obj/item/clothing/accessory/gloves_accessory/update_greyscale()
	. = ..()

	var/obj/item/clothing/gloves/attached_to = loc

	if(!istype(attached_to))
		return

	var/mob/living/carbon/human/wearer = attached_to.loc

	if(!istype(wearer))
		return

	attached_to.update_accessory_overlay()

/obj/item/clothing/accessory/gloves_accessory/try_attach(obj/item/clothing/gloves/attach_to, mob/living/attacher)
	. = ..()
	if(!minimize_when_attached)
		return
	pixel_z = -pixel_z
	return .

/obj/item/clothing/accessory/gloves_accessory/on_uniform_equipped(obj/item/clothing/gloves/source, mob/living/user, slot)
	if(slot & source.slot_flags)
		accessory_equipped(source, user)

/obj/item/clothing/accessory/gloves_accessory/on_uniform_dropped(obj/item/clothing/gloves/source, mob/living/user)
	accessory_dropped(source, user)

/obj/item/clothing/accessory/gloves_accessory/accessory_equipped(obj/item/clothing/gloves/clothes, mob/living/user)
	equipped(user, user.get_slot_by_item(clothes))
	user.update_clothing(ITEM_SLOT_GLOVES)
	return

/obj/item/clothing/accessory/gloves_accessory/accessory_dropped(obj/item/clothing/gloves/clothes, mob/living/user)
	dropped(user)
	return

// MARK: rings
/obj/item/clothing/accessory/gloves_accessory/ring
	icon = 'modular_bandastation/objects/icons/obj/items/rings.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/inhands/rings-hands.dmi'
	name = "gold ring"
	desc = "Маленькое золотое колечко, размером, чтобы надеть на палец."
	gender = NEUTER
	w_class = WEIGHT_CLASS_TINY
	icon_state = "ringgold"
	inhand_icon_state = null
	worn_icon_state = "gring"
	strip_delay = 4 SECONDS
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 1

/obj/item/clothing/accessory/gloves_accessory/ring/diamond
	name = "diamond ring"
	desc = "Дорогое кольцо, украшенное бриллиантом. В разных культурах такие кольца использовались для ухаживания уже тысячелетия."
	icon_state = "ringdiamond"
	worn_icon_state = "dring"

/obj/item/clothing/accessory/gloves_accessory/ring/silver
	name = "silver ring"
	desc = "Маленькое серебряное колечко, размером, чтобы надеть на палец."
	icon_state = "ringsilver"
	worn_icon_state = "sring"
