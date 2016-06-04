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

/obj/item/weapon/cookiesynth
	name = "Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	var/matter = 10
	var/toxin = 0
	var/emagged = 0
	w_class = 3

/obj/item/weapon/cookiesynth/New()
	desc = "A self recharging cookie fabricator. It currently holds [matter]/10 cookie-units."

/obj/item/weapon/cookiesynth/attackby()
	return

/obj/item/weapon/cookiesynth/emag_act(mob/user)
	emagged = !emagged
	if(emagged)
		user << "<span class='warning'>You short out the [src]'s reagent safety checker!</span>"
	else
		user << "<span class='warning'>You reset the [src]'s reagent safety checker!</span>"
		toxin = 0

/obj/item/weapon/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(isrobot(user))
		P = user
	if(emagged&&!toxin)
		toxin = 1
		user << "Cookie Synthesizer Hacked"
	else if(P.emagged&&!toxin)
		toxin = 1
		user << "Cookie Synthesizer Hacked"
	else
		toxin = 0
		user << "Cookie Synthesizer Reset"

/obj/item/weapon/cookiesynth/process()
	if (matter < 10)
		matter++

/obj/item/weapon/cookiesynth/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || istype(A, /turf/open/floor)))
		return
	if(matter < 1)
		user << "<span class='warning'>The [src] doesn't have enough matter left. Wait for it to recharge!</span>"
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 400)
			user << "<span class='warning'>You do not have enough power to use [src].</span>"
			return
	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	user << "Fabricating Cookie.."
	var/obj/item/weapon/reagent_containers/food/snacks/cookie/S = new /obj/item/weapon/reagent_containers/food/snacks/cookie(T)
	if(toxin)
		S.reagents.add_reagent("chloralhydrate2", 10)
	if (isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 100
	else
		matter--
		desc = "A self recharging cookie fabricator. It currently holds [matter]/10 cookie-units."