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
	starting_materials = list(MAT_IRON = 40000)
	var/matter = 0
	var/max_matter = 40
	var/matter_respawn = 0
	var/mode = 1
	var/list/modes
	w_class = 3.0

/obj/item/weapon/rsf/New()
	..()
	modes = list(
		"glass",
		"paper",
		"flask",
		"dice",
		"deck of cards",
		"candle",
		"cardboard sheet",
		)
	return

/obj/item/weapon/rsf/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/rcd_ammo))
		if (matter >= max_matter)
			user << "The RSF can't hold any more matter."
			return
		if ((matter+20) >= max_matter)
			qdel(W)
			matter = max_matter
			playsound(get_turf(src), 'sound/machines/click.ogg', 20, 1)
			user << "<span class='notice'>The RSF now holds [matter]/[max_matter] fabrication-units.</span>"
			return
		qdel(W)
		matter += 20
		playsound(get_turf(src), 'sound/machines/click.ogg', 20, 1)
		user << "<span class='notice'>The RSF now holds [matter]/[max_matter] fabrication-units.</span>"
		return

/obj/item/weapon/rsf/attack_self(mob/user as mob)
	playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
	mode++
	if(mode>modes.len) mode = 1
	user << "Now dispensing [modes[mode]]!"

/obj/item/weapon/rsf/examine(mob/user)
	..()
	if(istype(src, /obj/item/weapon/rsf/cyborg))
		user << "It's been set to draw power from a power cell."
	else
		user << "It currently holds [matter]/[max_matter] fabrication-units."

/obj/item/weapon/rsf/proc/pay(var/mob/user, var/amount) //spend matter or energy
	if(isrobot(user)) //if the user is a robot, take power from its cell
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			return R.cell.use(amount * 50)
		return 0

	if(amount <= matter)
		matter -= amount
		user << "The RSF now holds [matter]/[max_matter] fabrication-units."
		return 1
	return 0

/obj/item/weapon/rsf/afterattack(atom/A, mob/user as mob)
	if(!A.Adjacent(user))
		return
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
		if("flask")
			if(pay(user,1))
				user << "Dispensing Flask..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/weapon/reagent_containers/food/drinks/flask/barflask(get_turf(A))
		if("paper")
			if(pay(user,1))
				user << "Dispensing Paper..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/weapon/paper(get_turf(A))
		if("candle")
			if(pay(user,1))
				user << "Dispensing a Candle..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/candle(get_turf(A))
		if("dice")
			if(pay(user,1))
				user << "Dispensing Dice Pack..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/weapon/storage/pill_bottle/dice(get_turf(A))
		if("deck of cards")
			if(pay(user,1))
				user << "Dispensing a Deck of Cards..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/toy/cards(get_turf(A))
		if("cardboard sheet")
			if(pay(user,1))
				user << "Dispensing a Cardboard Sheet..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 10, 1)
				new /obj/item/stack/sheet/cardboard(get_turf(A))

/obj/item/weapon/rsf/cyborg/New()
	..()
	modes |= "dosh" //cyborg rsfs get money
	desc = "A device used to rapidly deploy service items."

/obj/item/weapon/rsf/cyborg/process()
	return //Borg RSF doesn't need matter