/obj/structure/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	anchored = 1.0
	flags = FPRINT
	pressure_resistance = 15

/obj/structure/stool/piano
	name = "piano stool"
	desc = "Apply butt. Become Mozart."
	icon_state = "stool_piano"
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	anchored = 0

/obj/structure/stool/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
	return

/obj/structure/stool/cultify()
	var/obj/structure/stool/bed/chair/wood/wings/I = new /obj/structure/stool/bed/chair/wood/wings(loc)
	I.dir = dir
	..()

/obj/structure/stool/blob_act()
	if(prob(75))
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 1
		qdel(src)

/obj/structure/stool/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 1
		qdel(src)
	return

/obj/structure/stool/piano/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/wood, get_turf(src))
		M.amount = 1
		qdel(src)
	return

/obj/structure/stool/hologram/blob_act()
	return

/obj/structure/stool/hologram/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/obj/structure/stool/MouseDrop(atom/over_object)
	if (istype(over_object, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = over_object
		if (!H.restrained() && !H.stat && in_range(src, over_object))
			var/obj/item/weapon/stool/S = new/obj/item/weapon/stool()
			S.origin = src
			src.loc = S
			H.put_in_hands(S)
			H.visible_message("<span class='warning'>[H] grabs [src] from the floor!</span>", "<span class='warning'>You grab [src] from the floor!</span>")

/obj/structure/stool/piano/MouseDrop(atom/over_object)
	return

/obj/item/weapon/stool
	name = "stool"
	desc = "Uh-hoh, bar is heating up."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	force = 10
	throwforce = 10
	w_class = 5.0
	var/obj/structure/stool/origin = null

/obj/item/weapon/stool/attack_self(mob/user as mob)
	..()
	if(origin)
		origin.loc = get_turf(src)
	user.u_equip(src)
	user.visible_message("<span class='notice'>[user] puts [src] down.</span>", "<span class='notice'>You put [src] down.</span>")
	del src

/obj/item/weapon/stool/attack(mob/M as mob, mob/user as mob)
	if (prob(5) && istype(M,/mob/living))
		user.visible_message("<span class='warning'>[user] breaks [src] over [M]'s back!.</span>")
		user.u_equip(src)
		if(!istype(origin,/obj/structure/stool/hologram))
			var/obj/item/stack/sheet/metal/MM = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
			MM.amount = 1
			qdel(src)
		var/mob/living/T = M
		T.Weaken(10)
		T.apply_damage(20)
		return
	..()
