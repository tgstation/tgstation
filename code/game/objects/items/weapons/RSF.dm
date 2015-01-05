/*
CONTAINS:
RSF

*/
/obj/item/weapon/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/items.dmi'
	icon_state = "rsf"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/matter_respawn = 0
	var/mode = 1
	var/list/modes
	w_class = 3.0

/obj/item/weapon/rsf/New()
	..()
	update_desc()
	modes = list(
		"glass",
		"paper",
		"a pen",
		"dice",
		"a cigarette",
		)
	return

/obj/item/weapon/rsf/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/rcd_ammo))
		if ((matter + 30) > 60)
			user << "The RSF can't hold any more matter."
			return
		del(W)
		matter += 30
		playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
		user << "The RSF now holds [matter]/60 fabrication-units."
		update_desc()
		return

/obj/item/weapon/rsf/attack_self(mob/user as mob)
	playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
	mode++
	if(mode>modes.len) mode = 1
	user << "Now dispensing [modes[mode]]!"

/obj/item/weapon/rsf/proc/pay(var/mob/user, var/amount) //spend matter or energy
	if(isrobot(user)) //if the user is a robot, take power from its cell
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			return R.cell.use(amount * 50)
		return 0

	if(amount <= matter)
		matter -= amount
		user << "The RSF now holds [matter]/60 fabrication-units."
		return 1
	return 0

/obj/item/weapon/rsf/proc/update_desc()
	desc = "An RSF. It currently holds [matter]/60 fabrication-units."

/obj/item/weapon/rsf/afterattack(atom/A, mob/user as mob)
	if (!(istype(A, /obj/structure/table) || istype(A, /turf/simulated/floor))) //Must click on a table or floor to spawn stuff
		return

	switch(modes[mode])
		if("dosh")
			if(pay(user,4))
				user << "Dispensing Dosh..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/weapon/spacecash/c10(get_turf(A))
				return
		if("glass")
			if(pay(user,1))
				user << "Dispensing Glass..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(get_turf(A))
		if("paper")
			if(pay(user,1))
				user << "Dispensing Paper..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/weapon/paper(get_turf(A))
		if("a pen")
			if(pay(user,1))
				user << "Dispensing a Pen..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/weapon/pen(get_turf(A))
		if("dice")
			if(pay(user,1))
				user << "Dispensing Dice Pack..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/weapon/storage/pill_bottle/dice(get_turf(A))
		if("a cigarette")
			if(pay(user,1))
				user << "Dispensing a Cigarette..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/clothing/mask/cigarette(get_turf(A))
	update_desc()

/obj/item/weapon/rsf/cyborg/New()
	..()
	modes |= "dosh" //cyborg rsfs get money
	desc = "A device used to rapidly deploy service items."

/obj/item/weapon/rsf/cyborg/process()
	return //Borg RSF doesn't need matter

/obj/item/weapon/rsf/cyborg/update_desc()
	return //Borg RSF doesn't need matter