/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	_color = "holster"
	var/obj/item/weapon/gun/holstered = null
	accessory_exclusion = HOLSTER

/obj/item/clothing/accessory/holster/proc/can_holster(obj/item/weapon/gun/W)
	if(!W || !istype(W))
		return
	return W.isHandgun()

/obj/item/clothing/accessory/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"
	_color = "holster"

/obj/item/clothing/accessory/holster/waist
	name = "shoulder holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"
	_color = "holster_low"

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user as mob)
	if (!istype(I, /obj/item/weapon/gun))
		to_chat(user, "<span class='warning'>Only guns can be holstered!</span>")
		return

	if(holstered)
		to_chat(user, "<span class='warning'>There is already a [holstered] holstered here!</span>")
		return

	var/obj/item/weapon/gun/W = I
	if (!can_holster(W))
		to_chat(user, "<span class='warning'>This [W] won't fit in the [src]!</span>")
		return

	holstered = W
	user.drop_from_inventory(holstered)
	holstered.loc = src
	holstered.add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] holsters the [holstered].</span>", "<span class='notice'>You holster the [holstered].</span>")
	return 1

/obj/item/clothing/accessory/holster/proc/unholster(mob/user as mob)
	if(!holstered)
		return

	if(user.get_active_hand() && user.get_inactive_hand())
		to_chat(user, "<span class='warning'>You need an empty hand to draw the [holstered]!</span>")
	else
		if(user.a_intent == I_HURT)
			usr.visible_message("<span class='warning'>[user] draws the [holstered], ready to shoot!</span></span>", \
			"<span class='warning'>You draw the [holstered], ready to shoot!</span>")
		else
			user.visible_message("<span class='notice'>[user] draws the [holstered], pointing it at the ground.</span>", \
			"<span class='notice'>You draw the [holstered], pointing it at the ground.</span>")
		user.put_in_hands(holstered)
		holstered.add_fingerprint(user)
		holstered = null

/obj/item/clothing/accessory/holster/verb/holster_verb()
	set name = "Holster"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat || (usr.status_flags & FAKEDEATH)) return

	var/obj/item/clothing/accessory/holster/H = null
	if (istype(src, /obj/item/clothing/accessory/holster))
		H = src
	else if (istype(src, /obj/item/clothing/under))
		var/obj/item/clothing/under/S = src
		if (S.accessories.len)
			H = locate() in S.accessories

	if (!H)
		to_chat(usr, "<span class='warning'>Something is very wrong.</span>")

	if(!H.holstered)
		if(!istype(usr.get_active_hand(), /obj/item/weapon/gun))
			to_chat(usr, "<span class='warning'>You need your gun equiped to holster it.</span>")
			return
		var/obj/item/weapon/gun/W = usr.get_active_hand()
		H.holster(W, usr)
	else
		H.unholster(usr)

/obj/item/clothing/accessory/holster/attack_hand(mob/user as mob)
	if(holstered && src.loc == user)
		return unholster(user)
	..(user)

/obj/item/clothing/accessory/holster/on_accessory_interact(mob/user, delayed)
	if (holstered && !delayed)
		unholster(user)
		return 1
	return ..()

/obj/item/clothing/accessory/holster/attackby(obj/item/W as obj, mob/user as mob)
	return holster(W, user)

/obj/item/clothing/accessory/holster/emp_act(severity)
	if (holstered)
		holstered.emp_act(severity)
	..()

/obj/item/clothing/accessory/holster/examine(mob/user)
	..(user)
	if (holstered)
		to_chat(user, "A [holstered] is holstered here.")
	else
		to_chat(user, "It is empty.")

/obj/item/clothing/accessory/holster/on_attached(obj/item/clothing/under/S, mob/user as mob)
	..()
	has_suit.verbs += /obj/item/clothing/accessory/holster/verb/holster_verb

/obj/item/clothing/accessory/holster/on_removed(mob/user as mob)
	has_suit.verbs -= /obj/item/clothing/accessory/holster/verb/holster_verb
	..()