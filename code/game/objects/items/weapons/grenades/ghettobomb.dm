//improvised explosives//

//iedcasing assembly crafting//
/obj/item/weapon/reagent_containers/food/drinks/dr_gibb/attackby(var/obj/item/I, mob/user as mob)
        if(istype(I, /obj/item/device/assembly/igniter))
                var/obj/item/device/assembly/igniter/G = I
                var/obj/item/weapon/grenade/iedcasing/W = new /obj/item/weapon/grenade/iedcasing
                user.before_take_item(G)
                user.before_take_item(src)
                user.put_in_hands(W)
                user << "<span  class='notice'>You stuff the igniter in the soda can, emptying the contents beforehand.</span>"
                del(I)
                del(src)
                ..()


/obj/item/weapon/grenade/iedcasing
	name = "improvised explosive assembly"
	desc = "An igniter stuffed into a can of Dr. Gibb."
	w_class = 2.0
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	var/assembled = 0
	active = 1


/obj/item/weapon/grenade/iedcasing/afterattack(atom/target, mob/user , flag) //Filling up the can
	if(assembled == 0)
		if( istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,target) <= 1 && target.reagents.total_volume > 30)
			var/obj/structure/reagent_dispensers/fueltank/F = target
			F.reagents.remove_reagent("fuel", 30, 1)//Deleting the fuel from the welding fuel tank should be here
			assembled = 1
			user << "<span  class='notice'>You've filled the makeshift explosive with welding fuel.</span>"
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			icon_state = "improvised_grenade_filled"
			desc = "An improvised explosive assembly. Filled to the brim with 'Explosive flavor'"
			return

/obj/item/weapon/grenade/iedcasing/attackby(var/obj/item/I, mob/user as mob) //Wiring the can for ignition
	if(istype(I, /obj/item/weapon/cable_coil))
		if(assembled == 1)
			var/obj/item/weapon/cable_coil/C = I
			C.amount -= 1
			assembled = 2
			user << "<span  class='notice'>You wire the igniter to detonate the fuel.</span>"
			icon_state = "improvised_grenade_wired"
			desc = "A weak, improvised explosive."
			active = 0

/obj/item/weapon/grenade/iedcasing/prime() //Blowing that can up
	update_mob()
	explosion(src.loc,-1,0,2)
	del(src)