/*
CONTAINS:
RSF

*/
/obj/item/weapon/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0
	flags = NOBLUDGEON
	var/matter = 0
	var/mode = 1
	w_class = 3

/obj/item/weapon/rsf/New()
	desc = "A RSF. It currently holds [matter]/30 fabrication-units."
	return

/obj/item/weapon/rsf/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/rcd_ammo))
		if ((matter + 10) > 30)
			user << "The RSF can't hold any more matter."
			return
		qdel(W)
		matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		user << "The RSF now holds [matter]/30 fabrication-units."
		desc = "A RSF. It currently holds [matter]/30 fabrication-units."
	else
		return ..()

/obj/item/weapon/rsf/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if (mode == 1)
		mode = 2
		user << "Changed dispensing mode to 'Drinking Glass'"
		return
	if (mode == 2)
		mode = 3
		user << "Changed dispensing mode to 'Paper'"
		return
	if (mode == 3)
		mode = 4
		user << "Changed dispensing mode to 'Pen'"
		return
	if (mode == 4)
		mode = 5
		user << "Changed dispensing mode to 'Dice Pack'"
		return
	if (mode == 5)
		mode = 6
		user << "Changed dispensing mode to 'Cigarette'"
		return
	if (mode == 6)
		mode = 1
		user << "Changed dispensing mode to 'Dosh'"
		return
	// Change mode

/obj/item/weapon/rsf/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || istype(A, /turf/open/floor)))
		return

	if(matter < 1)
		user << "<span class='warning'>\The [src] doesn't have enough matter left.</span>"
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 200)
			user << "<span class='warning'>You do not have enough power to use [src].</span>"
			return

	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	switch(mode)
		if(1)
			user << "Dispensing Dosh..."
			new /obj/item/stack/spacecash/c10(T)
			use_matter(200, user)
		if(2)
			user << "Dispensing Drinking Glass..."
			new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(T)
			use_matter(20, user)
		if(3)
			user << "Dispensing Paper Sheet..."
			new /obj/item/weapon/paper(T)
			use_matter(10, user)
		if(4)
			user << "Dispensing Pen..."
			new /obj/item/weapon/pen(T)
			use_matter(50, user)
		if(5)
			user << "Dispensing Dice Pack..."
			new /obj/item/weapon/storage/pill_bottle/dice(T)
			use_matter(200, user)
		if(6)
			user << "Dispensing Cigarette..."
			new /obj/item/clothing/mask/cigarette(T)
			use_matter(10, user)

/obj/item/weapon/rsf/proc/use_matter(charge, mob/user)
	if (isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= charge
	else
		matter--
		user << "The RSF now holds [matter]/30 fabrication-units."
		desc = "A RSF. It currently holds [matter]/30 fabrication-units."
