/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	flags = NOBLUDGEON
	origin_tech = "materials=6;syndicate=1"

/obj/item/stack/telecrystal/attack(mob/target, mob/user)
	if(target == user)
		var/obj/item/weapon/implant/uplink/I = locate() in target
		if(I)
			GET_COMPONENT_FROM(uplink, /datum/component/uplink, I)
			if(uplink && uplink.enabled) //You can't go around smacking people with crystals to find out if they have an uplink or not.
				to_chat(user, "<span class='notice'>You press [src] onto yourself and charge your hidden uplink.</span>")
				uplink.LoadTC(user, src, TRUE)
				return
	return ..()

/obj/item/stack/telecrystal/afterattack(obj/item/I, mob/user, proximity)
	if(!proximity)
		return
	if(istype(I, /obj/item/weapon/cartridge/virus/frame))
		var/obj/item/weapon/cartridge/virus/frame/cart = I
		if(!cart.charges)
			to_chat(user, "<span class='notice'>[cart] is out of charges, it's refusing to accept [src]</span>")
			return
		cart.telecrystals += amount
		use(amount)
		to_chat(user, "<span class='notice'>You slot [src] into [cart]. The next time it's used, it will also give telecrystals</span>")

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty
	amount = 20
