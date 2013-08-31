/obj/item/weapon/reagent_containers/food/drinks/dr_gibb/attackby(var/obj/item/I, mob/user as mob)

        ..()
        if(istype(I, /obj/item/device/assembly/igniter))
                var/obj/item/device/assembly/igniter/G = I
                var/obj/item/weapon/iedcasing/W = new /obj/item/weapon/iedcasing

                user.before_take_item(G)
                user.before_take_item(src)

                user.put_in_hands(W)
                user << "<span  class='notice'>You stuff the igniter in the soda can.</span>"

                del(I)
                del(src)
                ..()


/obj/item/weapon/iedcasing
	name = "Improvised Explosive Assembly"
	desc = "An igniter stuffed into a can of Dr. Gibb."
	w_class = 2.0
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT


/obj/item/weapon/iedcasing/afterattack(atom/target, mob/user , flag)
	if( istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,target) <= 1 && target.reagents.total_volume > 0)
		var/obj/item/weapon/iedcasing_filled/T = new /obj/item/weapon/iedcasing_filled

		user.before_take_item(src)

		user.put_in_hands(T)
		user << "<span  class='notice'>You've filled the makeshift explosive with welding fuel.</span>"
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)

		del(src)
		return

/obj/item/weapon/iedcasing_filled
	name = "Improvised Explosive Assembly"
	desc = "Filled to the brim with 'Explosive Flavor'"
	w_class = 2.0
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade_filled"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT

/obj/item/weapon/iedcasing_filled/attackby(var/obj/item/I, mob/user as mob)

        ..()
        if(istype(I, /obj/item/weapon/cable_coil))
                var/obj/item/weapon/grenade/improvisedbomb/W = new /obj/item/weapon/grenade/improvisedbomb
                var/obj/item/weapon/cable_coil/C = I
                C.amount -= 1
                user.before_take_item(src)
                user.put_in_hands(W)
                user << "<span  class='notice'>You wire the igniter to detonate the fuel.</span>"

                del(src)


/obj/item/weapon/grenade/improvisedbomb
	desc = "A weak, improvised explosive."
	name = "Improvised explosive"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade_wired"
	item_state = "flashbang"

/obj/item/weapon/grenade/improvisedbomb/prime()
	update_mob()
	explosion(src.loc,-1,0,2)
	del(src)

