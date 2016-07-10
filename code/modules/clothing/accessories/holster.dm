/obj/item/clothing/accessory/holster/
	name = "holster"
	icon_state = "holster"
	_color = "holster"
	origin_tech = "combat=2"
	var/obj/item/holstered = null
	accessory_exclusion = HOLSTER

/obj/item/clothing/accessory/holster/proc/can_holster(obj/item/weapon/gun/W)
	return

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user as mob)
	if(holstered)
		to_chat(user, "<span class='warning'>There is already \a [holstered] holstered here!</span>")
		return

	if (!can_holster(I))
		to_chat(user, "<span class='warning'>\The [I] won't fit in the [src]!</span>")
		return

	if(user.drop_item(I, src))
		holstered = I
		holstered.add_fingerprint(user)
		user.visible_message("<span class='notice'>[user] holsters \the [holstered].</span>", "<span class='notice'>You holster \the [holstered].</span>")
		update_icon()
		return 1
	else
		to_chat(user, "<span class='warning'>You can't let go of \the [I]!</span>")

/obj/item/clothing/accessory/holster/proc/unholster(mob/user as mob)
	if(!holstered)
		return

	if(user.put_in_hands(holstered))
		unholster_message(user)
		holstered.add_fingerprint(user)
		holstered = null
		update_icon()
	else
		to_chat(user, "<span class='warning'>You need an empty hand to draw \the [holstered]!</span>")

/obj/item/clothing/accessory/holster/proc/unholster_message(user)
	return

/obj/item/clothing/accessory/holster/verb/holster_verb()
	set name = "Holster"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	var/obj/item/clothing/accessory/holster/H = null
	if (istype(src, /obj/item/clothing/accessory/holster))
		H = src
	else if (istype(src, /obj/item/clothing/))
		var/obj/item/clothing/S = src
		if (S.accessories.len)
			H = locate() in S.accessories

	if (!H)
		to_chat(usr, "<span class='warning'>Something is very wrong.</span>")

	if(!H.holstered)
		var/obj/item/W = usr.get_active_hand()
		if(istype(W))
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
		to_chat(user, "A [holstered.name] is holstered here.")
	else
		to_chat(user, "It is empty.")

/obj/item/clothing/accessory/holster/on_attached(obj/item/clothing/under/S)
	..()
	attached_to.verbs += /obj/item/clothing/accessory/holster/verb/holster_verb

/obj/item/clothing/accessory/holster/on_removed(mob/user as mob)
	attached_to.verbs -= /obj/item/clothing/accessory/holster/verb/holster_verb
	..()

//
// Handguns
//
/obj/item/clothing/accessory/holster/handgun/can_holster(obj/item/weapon/gun/W)
	if(!istype(W))
		return
	return W.isHandgun()

/obj/item/clothing/accessory/holster/handgun/unholster_message(mob/user)
	if(user.a_intent == I_HURT)
		user.visible_message("<span class='warning'>[user] draws \the [holstered], ready to shoot!</span></span>", \
		"<span class='warning'>You draw \the [holstered], ready to shoot!</span>")
	else
		user.visible_message("<span class='notice'>[user] draws \the [holstered], pointing it at the ground.</span>", \
		"<span class='notice'>You draw \the [holstered], pointing it at the ground.</span>")

/obj/item/clothing/accessory/holster/handgun
	name = "shoulder holster"
	desc = "A handgun holster. Perfect for concealed carry."

/obj/item/clothing/accessory/holster/handgun/wornout
	desc = "A worn-out handgun holster. Perfect for concealed carry."

/obj/item/clothing/accessory/holster/handgun/biogenerator
	desc = "A leather handgun holster. It smells faintly of potato."

/obj/item/clothing/accessory/holster/handgun/waist
	name = "waistband holster"
	desc = "A handgun holster. Made of expensive leather."
	_color = "holster_low"

//
// Knives
//
/obj/item/clothing/accessory/holster/knife/can_holster(obj/item/weapon/W)
	if(!istype(W))
		return
	if(istype(W, /obj/item/weapon/kitchen/utensil/knife/large/butch))
		return
	return is_type_in_list(W, list(\
		/obj/item/weapon/kitchen/utensil, \
		/obj/item/weapon/hatchet/unathiknife, \
		/obj/item/weapon/screwdriver, \
		/obj/item/weapon/wirecutters))

/obj/item/clothing/accessory/holster/knife/unholster_message(mob/user)
	user.visible_message("<span class='warning'>[user] pulls \a [holstered] from it's holster!</span>", \
	"<span class='warning'>You draw your [holstered.name]!</span>")

/obj/item/clothing/accessory/holster/knife/boot
	name = "knife holster"
	desc = "A knife holster that can be attached to any pair of boots."
	item_state = "bootknife"
	icon_state = "bootknife"
	_color = "bootknife"

/obj/item/clothing/accessory/holster/knife/boot/can_attach_to(obj/item/clothing/C)
	return istype(C, /obj/item/clothing/shoes)

/obj/item/clothing/accessory/holster/knife/update_icon()
	if(holstered)
		icon_state = "[initial(icon_state)]_1"
		_color = "[initial(_color)]_1"
	else
		icon_state = "[initial(icon_state)]_0"
		_color = "[initial(_color)]_0"
	..()

/obj/item/clothing/accessory/holster/knife/boot/preloaded/New()
	..()
	if(!holstered)
		holstered = new /obj/item/weapon/kitchen/utensil/knife/tactical(src)
		update_icon()
