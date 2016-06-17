/obj/item/clothing/monkeyclothes
	name = "monkey-sized waiter suit"
	desc = "Adorable. comes with green contact lens."
	icon = 'icons/mob/monkey.dmi'
	icon_state = "punpunsuit_icon"
	item_state = "punpunsuit_item"
	force = 0
	throwforce = 0
	throw_speed = 2
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	slot_flags = SLOT_ICLOTHING
	body_parts_covered = FULL_BODY

/obj/item/clothing/monkeyclothes/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	. = ..() //Default return value. If 1, item can be equipped. If 0, it can't be.
	if(!.) return //Well if it already can't be equipped, we've got nothing else to do here folks, time to call it quits

	if(!ismonkey(M))
		if(!disable_warning)
			to_chat(M, "<span class='warning'>These clothes won't fit.</span>")
		return CANNOT_EQUIP

/obj/item/clothing/monkeyclothes/attack(mob/living/carbon/C as mob, mob/user as mob)	//I thought I'd give people a fast way to put clothes on monkey.
	if(ismonkey(C))																	//They can do it by opening the monkey's "show inventory" like you'd do for an human as well.
		var/mob/living/carbon/monkey/M = C
		if(!M.equip_to_slot_if_possible(src, slot_w_uniform))
			to_chat(user, "Those clothes won't fit.")
			return
	..()

/obj/item/clothing/monkeyclothes/cultrobes
	name = "size S cult robes"
	desc = "Adorably crazy."
	icon_state = "cult_icon"
	item_state = "cult_item"
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/monkeyclothes/jumpsuit_red
	name = "monkey-sized red jumpsuit"
	desc = "They wear these at the thunderdome."
	icon_state = "redsuit_icon"
	item_state = "redsuit_item"

/obj/item/clothing/monkeyclothes/jumpsuit_green
	name = "monkey-sized green jumpsuit"
	desc = "They wear these at the thunderdome."
	icon_state = "greensuit_icon"
	item_state = "greensuit_item"

/obj/item/clothing/monkeyclothes/doctor
	name = "monkey-sized doctor clothes"
	desc = "Sterile latex gloves included."
	icon_state = "doctor_icon"
	item_state = "doctor_item"

/obj/item/clothing/monkeyclothes/space
	name = "monkey-sized space suit"
	desc = "A small step for a monkey, but a giant leap for bananas."
	icon_state = "space_icon"
	item_state = "space_item"
