/*
CONTAINS:
DONUT BOX
EGG BOX
YOUR MUMS BOX

*/


/mob/living/carbon/var/last_eating = 0

/obj/item/kitchen/donut_box
	var/amount = 6
	icon = 'food.dmi'
	icon_state = "donutbox"
	name = "donut box"
/obj/item/kitchen/egg_box
	var/amount = 12
	icon = 'food.dmi'
	icon_state = "eggbox"
	name = "egg box"

/obj/item/kitchen/donut_box/proc/update()
	src.icon_state = text("donutbox[]", src.amount)
	return

/obj/item/kitchen/donut_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/donut))
		user.drop_item()
		W.loc = src
		usr << "You place a donut back into the box."
	src.update()
	return

/obj/item/kitchen/donut_box/MouseDrop(mob/user as mob)
	if ((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || in_range(src, usr))))))
		if (usr.hand)
			if (!( usr.l_hand ))
				spawn( 0 )
					src.attack_hand(usr, 1, 1)
					return
		else
			if (!( usr.r_hand ))
				spawn( 0 )
					src.attack_hand(usr, 0, 1)
					return
	return

/obj/item/kitchen/donut_box/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/kitchen/donut_box/attack_hand(mob/user as mob, unused, flag)
	if (flag)
		return ..()
	src.add_fingerprint(user)
	if (locate(/obj/item/weapon/reagent_containers/food/snacks/donut, src))
		for(var/obj/item/weapon/reagent_containers/food/snacks/donut/P in src)
			if (!usr.l_hand)
				P.loc = usr
				P.layer = 20
				usr.l_hand = P
				usr.update_clothing()
				usr << "You take a donut out of the box."
				break
			else if (!usr.r_hand)
				P.loc = usr
				P.layer = 20
				usr.r_hand = P
				usr.update_clothing()
				usr << "You take a donut out of the box."
				break
	else
		if (src.amount >= 1)
			src.amount--
			new /obj/item/weapon/reagent_containers/food/snacks/donut( src.loc )
			usr << "You take a donut out of the box."
	src.update()
	return

/obj/item/kitchen/donut_box/examine()
	set src in oview(1)

	src.amount = round(src.amount)
	var/n = src.amount
	for(var/obj/item/weapon/reagent_containers/food/snacks/donut/P in src)
		n++
	if (n <= 0)
		n = 0
		usr << "There are no donuts left in the box."
	else
		if (n == 1)
			usr << "There is one donut left in the box."
		else
			usr << text("There are [] donuts in the box.", n)
	return

/obj/item/kitchen/egg_box/proc/update()
	src.icon_state = text("eggbox[]", src.amount)
	return


/obj/item/kitchen/egg_box/MouseDrop(mob/user as mob)
	if ((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || in_range(src, usr))))))
		if (usr.hand)
			if (!( usr.l_hand ))
				spawn( 0 )
					src.attack_hand(usr, 1, 1)
					return
		else
			if (!( usr.r_hand ))
				spawn( 0 )
					src.attack_hand(usr, 0, 1)
					return
	return

/obj/item/kitchen/egg_box/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/kitchen/egg_box/attack_hand(mob/user as mob, unused, flag)
	if (flag)
		return ..()
	src.add_fingerprint(user)
	if (locate(/obj/item/weapon/reagent_containers/food/snacks/egg, src))
		for(var/obj/item/weapon/reagent_containers/food/snacks/egg/P in src)
			if (!usr.l_hand)
				P.loc = usr.loc
				P.layer = 20
				usr.l_hand = P
				P = null
				usr.update_clothing()
				usr << "You take an egg out of the box."
				break
			else if (!usr.r_hand)
				P.loc = usr.loc
				P.layer = 20
				usr.r_hand = P
				P = null
				usr.update_clothing()
				usr << "You take an egg out of the box."
				break
	else
		if (src.amount >= 1)
			src.amount--
			new /obj/item/weapon/reagent_containers/food/snacks/egg( src.loc )
			usr << "You take an egg out of the box."
	src.update()
	return

/obj/item/kitchen/egg_box/examine()
	set src in oview(1)

	src.amount = round(src.amount)
	var/n = src.amount
	for(var/obj/item/weapon/reagent_containers/food/snacks/egg/P in src)
		n++
	if (n <= 0)
		n = 0
		usr << "There are no eggs left in the box."
	else
		if (n == 1)
			usr << "There is one egg left in the box."
		else
			usr << text("There are [] eggs in the box.", n)
	return


