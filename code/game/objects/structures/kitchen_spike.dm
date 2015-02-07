//////Kitchen Spike

/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = 0
	var/meattype = 0 // 0 - Nothing, 1 - Monkey, 2 - Xeno

/obj/structure/kitchenspike
	attack_paw(mob/user as mob)
		return src.attack_hand(usr)

/obj/structure/kitchenspike/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		if(occupied)
			user << "<span class='warning'>You can't disassemble [src] with meat and gore all over it.</span>"
			return
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 2
		qdel(src)
		return

	if(istype(W,/obj/item/weapon/grab))
		return handleGrab(W,user)

/obj/structure/kitchenspike/proc/handleGrab(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(!istype(G, /obj/item/weapon/grab))
		return

	if(istype(G.affecting, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/M = G.affecting
		if(M.wear_mask || M.l_hand || M.r_hand || M.back || M.uniform || M.hat)
			user << "<span class='warning'>Subject may not have abiotic items on.</span>"
		else
			if(src.occupied == 0)
				src.icon_state = "spikebloody"
				src.occupied = 1
				src.meat = 5
				src.meattype = 1
				for(var/mob/O in viewers(src, null))
					O.show_message(text("<span class='warning'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>"))
				del(G.affecting)
				del(G)

			else
				user << "<span class='warning'>The spike already has something on it, finish collecting its meat first!</span>"

	else if(istype(G.affecting, /mob/living/carbon/alien))
		if(src.occupied == 0)
			src.icon_state = "spikebloodygreen"
			src.occupied = 1
			src.meat = 5
			src.meattype = 2
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span class='warning'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>"))
			del(G.affecting)
			del(G)

		else
			user << "<span class='warning'>The spike already has something on it, finish collecting its meat first!</span>"

	else
		user << "<span class='warning'>They are too big for the spike, try something smaller!</span>"
		return

//	MouseDrop_T(var/atom/movable/C, mob/user)
//		if(istype(C, /obj/mob/carbon/monkey)
//		else if(istype(C, /obj/mob/carbon/alien) && !istype(C, /mob/living/carbon/alien/larva/slime))
//		else if(istype(C, /obj/livestock/spesscarp

/obj/structure/kitchenspike/attack_hand(mob/user as mob)
	if(..())
		return
	if(src.occupied)
		if(src.meattype == 1)
			if(src.meat > 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey( src.loc )
				usr << "You remove some meat from the monkey."
			else if(src.meat == 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey(src.loc)
				usr << "You remove the last piece of meat from the monkey!"
				src.icon_state = "spike"
				src.occupied = 0
		else if(src.meattype == 2)
			if(src.meat > 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/xenomeat( src.loc )
				usr << "You remove some meat from the alien."
			else if(src.meat == 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/xenomeat(src.loc)
				usr << "You remove the last piece of meat from the alien!"
				src.icon_state = "spike"
				src.occupied = 0
