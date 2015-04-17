//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	var/obj/item/clothing/head/winterhood/hood
	var/hoodtype = /obj/item/clothing/head/winterhood //so the chaplain hoodie or other hoodies can override this

/obj/item/clothing/suit/hooded/New()
	MakeHood()
	..()

/obj/item/clothing/suit/hooded/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/winterhood/W = new hoodtype(src)
		hood = W

/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/equipped(mob/user, slot)
	if(slot != slot_wear_suit)
		RemoveHood()
	..()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	src.icon_state = "[initial(icon_state)]"
	suittoggled = 0
	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.unEquip(hood, 1)
		H.update_inv_wear_suit()
	hood.loc = src

/obj/item/clothing/suit/hooded/dropped()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!suittoggled)
		if(ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if(H.wear_suit != src)
				H << "You must be wearing [src] to put up the hood."
				return
			if(H.head)
				H << "You're already wearing something on your head."
				return
			else
				H.equip_to_slot_if_possible(hood,slot_head,0,0,1)
				suittoggled = 1
				src.icon_state = "[initial(icon_state)]_t"
				H.update_inv_wear_suit()
	else
		RemoveHood()

//Toggle exosuits for different aesthetic styles (hoodies, suit jacket buttons, etc)

/obj/item/clothing/suit/toggle/AltClick()
	..()
	suit_toggle()

/obj/item/clothing/suit/toggle/ui_action_click()
	suit_toggle()

/obj/item/clothing/suit/toggle/proc/suit_toggle()
	set src in usr

	if(!can_use(usr))
		return 0

	usr << "You toggle [src]'s [togglename]."
	if(src.suittoggled)
		src.icon_state = "[initial(icon_state)]"
		src.suittoggled = 0
	else if(!src.suittoggled)
		src.icon_state = "[initial(icon_state)]_t"
		src.suittoggled = 1
	usr.update_inv_wear_suit()

/obj/item/clothing/suit/toggle/examine(mob/user)
	..()
	user << "Alt-click on [src] to toggle the [togglename]."

//Hardsuit toggle code

/obj/item/clothing/suit/space/hardsuit/New()
	MakeHelmet()
	if(!jetpack)
		verbs -= /obj/item/clothing/suit/space/hardsuit/verb/Jetpack
		verbs -= /obj/item/clothing/suit/space/hardsuit/verb/Jetpack_Rockets
	..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		helmet = W

/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	..()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	if(!helmettype)
		return
	if(slot != slot_wear_suit)
		RemoveHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	if(!helmettype)
		return
	suittoggled = 0
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self(H)
		H.unEquip(helmet, 1)
		H.update_inv_wear_suit()
	helmet.loc = src

/obj/item/clothing/suit/space/hardsuit/dropped()
	RemoveHelmet()

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	var/mob/living/carbon/human/H = src.loc
	if(!helmettype)
		return
	if(!suittoggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				H << "You must be wearing [src] to engage the helmet."
				return
			if(H.head)
				H << "You're already wearing something on your head."
				return
			else
				H << "You engage the helmet on the hardsuit."
				H.equip_to_slot_if_possible(helmet,slot_head,0,0,1)
				suittoggled = 1
				H.update_inv_wear_suit()
				playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		H << "You disengage the helmet on the hardsuit."
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
		RemoveHelmet()
