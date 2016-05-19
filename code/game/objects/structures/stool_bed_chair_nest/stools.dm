/obj/item/weapon/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/stools-chairs-beds.dmi'
	icon_state = "stool"
	force = 10
	throwforce = 10
	w_class = W_CLASS_HUGE
	var/sheet_path = /obj/item/stack/sheet/metal

/obj/item/weapon/stool/bar
	name = "bar stool"
	icon_state = "bar-stool"

/obj/item/weapon/stool/hologram
	sheet_path = null

/obj/item/weapon/stool/piano
	name = "piano stool"
	desc = "Apply butt. Become Mozart."
	icon_state = "stool_piano"
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	sheet_path = /obj/item/stack/sheet/wood

//So they don't get picked up.
/obj/item/weapon/stool/piano/attack_hand()
	return

/obj/item/weapon/stool/attackby(var/obj/item/weapon/W, var/mob/user)
	if(iswrench(W) && sheet_path)
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		getFromPool(sheet_path, get_turf(src), 1)
		qdel(src)

	. = ..()

/obj/item/weapon/stool/cultify()
	var/obj/structure/bed/chair/wood/wings/I = new /obj/structure/bed/chair/wood/wings(loc)
	I.dir = dir
	. = ..()

/obj/item/weapon/stool/attack(mob/M as mob, mob/user as mob)
	if(prob(5) && istype(M, /mob/living) && sheet_path)
		user.visible_message("<span class='warning'>[user] breaks \the [src] over [M]'s back!.</span>")
		user.u_equip(src, 0)

		getFromPool(sheet_path, get_turf(src), 1)
		qdel(src)

		var/mob/living/T = M
		T.Weaken(10)
		T.apply_damage(20)
		return

	. = ..()
