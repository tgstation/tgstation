/obj/item/device/recoil_compensator
	name = "anti-grav stabilizer"
	desc = "A miniaturized gravity generator, capable of reducing the weight of a gun as well as reducing recoil."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "quadratic_capacitor"

/obj/item/device/recoil_compensator/afterattack(obj/item/weapon/gun/G, mob/user)
	..()
	if(!istype(G))
		user << "<span class='warning'>\The [src] can only be used on guns!</span>"
		return
	if(G.heavy_weapon == 0 && G.recoil == 0)
		user << "<span class='warning'>The gun can't be improved any further!</span>"
		return..()
	user <<"<span class='notice'>You carefully install \the [src]. \The [G] is now light as a feather.</span>"
	G.heavy_weapon = 0
	G.recoil = 0
	G.name = "stabilized [G.name]"
	qdel(src)