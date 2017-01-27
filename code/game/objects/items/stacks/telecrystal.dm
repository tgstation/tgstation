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
	if(target == user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		for(var/obj/item/weapon/implant/uplink/I in target)
			if(I && I.imp_in)
				I.hidden_uplink.telecrystals += amount
				use(amount)
				user << "<span class='notice'>You press [src] onto yourself and charge your hidden uplink.</span>"

/obj/item/stack/telecrystal/afterattack(obj/item/I, mob/user, proximity)
	if(!proximity)
		return
	if(istype(I, /obj/item))
		if(I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
			I.hidden_uplink.telecrystals += amount
			use(amount)
			user << "<span class='notice'>You slot [src] into the [I] and charge its internal uplink.</span>"

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty
	amount = 20
