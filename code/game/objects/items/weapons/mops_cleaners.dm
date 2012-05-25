/obj/item/weapon/cleaner
	desc = "Space Cleaner!"
	icon = 'janitor.dmi'
	name = "space cleaner"
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10

/obj/item/weapon/cleaner/New()
	var/datum/reagents/R = new/datum/reagents(250)
	reagents = R
	R.my_atom = src
	R.add_reagent("cleaner", 250)

/obj/item/weapon/cleaner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/cleaner/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/storage ))
		return
	if (istype(A, /obj/effect/proc_holder/spell ))
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue [src] is empty!"
		return

	var/obj/effect/decal/D = new/obj/effect/decal(get_turf(src))
	D.create_reagents(5)
	src.reagents.trans_to(D, 5)

	var/list/rgbcolor = list(0,0,0)
	var/finalcolor
	for(var/datum/reagent/re in D.reagents.reagent_list) // natural color mixing bullshit/algorithm
		if(!finalcolor)
			rgbcolor = GetColors(re.color)
			finalcolor = re.color
		else
			var/newcolor[3]
			var/prergbcolor[3]
			prergbcolor = rgbcolor
			newcolor = GetColors(re.color)

			rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
			rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
			rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

			finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])
			// This isn't a perfect color mixing system, the more reagents that are inside,
			// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
			// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
			// If you add brighter colors to it it'll eventually get lighter, though.

	D.name = "chemicals"
	D.icon = 'chempuff.dmi'

	D.icon += finalcolor

	playsound(src.loc, 'spray2.ogg', 50, 1, -6)

	spawn(0)
		for(var/i=0, i<3, i++)
			step_towards(D,A)
			D.reagents.reaction(get_turf(D))
			for(var/atom/T in get_turf(D))
				D.reagents.reaction(T)
			sleep(3)
		del(D)

	if(isrobot(user)) //Cyborgs can clean forever if they keep charged
		var/mob/living/silicon/robot/janitor = user
		janitor.cell.charge -= 20
		var/refill = src.reagents.get_master_reagent_id()
		spawn(600)
			src.reagents.add_reagent(refill, 10)

	if(src.reagents.has_reagent("pacid"))
		message_admins("[key_name_admin(user)] fired Polyacid from a Cleaner bottle.")
		log_game("[key_name(user)] fired Polyacid from a Cleaner bottle.")
	if(src.reagents.has_reagent("lube"))
		message_admins("[key_name_admin(user)] fired Space lube from a Cleaner bottle.")
		log_game("[key_name(user)] fired Space lube from a Cleaner bottle.")
	return

/obj/item/weapon/cleaner/examine()
	set src in usr
	for(var/datum/reagent/R in reagents.reagent_list)
		usr << text("\icon[] [] units of [] left!", src, round(R.volume), R.name)
	//usr << text("\icon[] [] units of cleaner left!", src, src.reagents.total_volume)
	..()
	return



/obj/item/weapon/chemsprayer//Another copy paste with a tiny change it seems
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'gun.dmi'
	name = "chem sprayer"
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	flags = TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	origin_tech = "combat=3;materials=3;engineering=3"

/obj/item/weapon/chemsprayer/New()
	var/datum/reagents/R = new/datum/reagents(600)
	reagents = R
	R.my_atom = src

/obj/item/weapon/chemsprayer/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/chemsprayer/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/storage ))
		return
	if (istype(A, /obj/effect/proc_holder/spell ))
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue [src] is empty!"
		return

	playsound(src.loc, 'spray2.ogg', 50, 1, -6)

	var/Sprays[3]
	for(var/i=1, i<=3, i++) // intialize sprays
		if(src.reagents.total_volume < 1) break
		var/obj/effect/decal/D = new/obj/effect/decal(get_turf(src))
		D.name = "chemicals"
		D.icon = 'chempuff.dmi'
		D.create_reagents(5)
		src.reagents.trans_to(D, 5)

		var/rgbcolor[3]
		var/finalcolor
		for(var/datum/reagent/re in D.reagents.reagent_list)
			if(!finalcolor)
				rgbcolor = GetColors(re.color)
				finalcolor = re.color
			else
				var/newcolor[3]
				var/prergbcolor[3]
				prergbcolor = rgbcolor
				newcolor = GetColors(re.color)

				rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
				rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
				rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

				finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])

		D.icon += finalcolor

		Sprays[i] = D

	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/effect/decal/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for(var/j=1, j<=rand(6,8), j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					D.reagents.reaction(t)
				sleep(2)
			del(D)
	sleep(1)

	if(isrobot(user)) //Cyborgs can clean forever if they keep charged
		var/mob/living/silicon/robot/janitor = user
		janitor.cell.charge -= 20
		var/refill = src.reagents.get_master_reagent_id()
		spawn(600)
			src.reagents.add_reagent(refill, 10)

	if((src.reagents.has_reagent("pacid")) || (src.reagents.has_reagent("lube")))  				// Messages admins if someone sprays polyacid or space lube from a Chem Sprayer.
		message_admins("[key_name_admin(user)] fired Polyacid/Space lube from a Chem Sprayer.")			// Polymorph
		log_game("[key_name(user)] fired Polyacid/Space lube from a Chem Sprayer.")
	return



//A direct copy paste of the cleaner, fantastic.
/obj/item/weapon/pepperspray
	desc = "Manufactured by UhangInc., used to blind and down an opponent quickly. It has three spray settings, and is currently set to 'low'."
	icon = 'weapons.dmi'
	name = "pepperspray"
	icon_state = "pepperspray"
	item_state = "pepperspray"
	flags = TABLEPASS|FPRINT|USEDELAY
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/setting = 1


/obj/item/weapon/pepperspray/New()
	var/datum/reagents/R = new/datum/reagents(45)
	reagents = R
	R.my_atom = src
	R.add_reagent("condensedcapsaicin", 45)

/obj/item/weapon/pepperspray/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/pepperspray/attack_self( mob/user as mob)
	src.setting += 1
	switch ( src.setting )
		if (2)
			user << "You change the spray to 'medium'."
			src.desc = "Manufactured by UhangInc., used to blind and down an opponent quickly. It has three spray settings, and is currently set to 'medium'."
		if (3)
			user << "You change the spray to 'high'."
			src.desc = "Manufactured by UhangInc., used to blind and down an opponent quickly. It has three spray settings, and is currently set to 'high'."
		if (4)
			src.setting = 1
			user << "You change the spray to 'low'."
			src.desc = "Manufactured by UhangInc., used to blind and down an opponent quickly. It has three spray settings, and is currently set to 'low'."
	return

/obj/item/weapon/pepperspray/afterattack(atom/A as mob|obj, mob/user as mob)
	if ( A == src )
		return
	if ( src.setting < 1 || src.setting > 3 ) // Stop var editing from breaking some maths further down
		src.setting = 1
	if (istype(A, /obj/item/weapon/storage ))
		return
	if (istype(A, /obj/effect/proc_holder/spell ))
		return
	else if (istype(A, /obj/structure/reagent_dispensers/peppertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 45)
		user << "\blue Pepper spray refilled"
		playsound(src.loc, 'refill.ogg', 50, 1, -6)
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue [src] is empty!"
		return
	playsound(src.loc, 'spray2.ogg', 50, 1, -6)

	var/Sprays[1] // BubbleWrap - single spray
	for(var/i=1, i<=1, i++) // intialize sprays
		if(src.reagents.total_volume < 1) break
		var/obj/effect/decal/D = new/obj/effect/decal(get_turf(src))
		D.name = "chemicals"
		D.icon = 'chempuff.dmi'
		var/xfer_volume = round(45/(4-src.setting)) // Use more spray per spray on higher settings
		D.create_reagents(xfer_volume)
		src.reagents.trans_to(D, xfer_volume)

		var/rgbcolor[3]
		var/finalcolor
		for(var/datum/reagent/re in D.reagents.reagent_list)
			if(!finalcolor)
				rgbcolor = GetColors(re.color)
				finalcolor = re.color
			else
				var/newcolor[3]
				var/prergbcolor[3]
				prergbcolor = rgbcolor
				newcolor = GetColors(re.color)

				rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
				rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
				rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

				finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])

		D.icon += finalcolor

		Sprays[i] = D

	//var/direction = get_dir(src, A)
	//var/turf/T = get_turf(A)
	//var/turf/T1 = get_step(T,turn(direction, 90))
	//var/turf/T2 = get_step(T,turn(direction, -90))
	//var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/effect/decal/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = get_turf(A) //pick(the_targets)
			//the_targets -= my_target

			var/list/affected = new()	// BubbleWrap
			for(var/j=1, j<=rand(6,8), j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					if ( !(t in affected) )	// Only spray each person once, removes chat spam
						D.reagents.reaction(t)
						affected += t
				sleep(2)
			del(D)
	sleep(1)

	if(isrobot(user)) //Cyborgs can clean forever if they keep charged
		var/mob/living/silicon/robot/janitor = user
		janitor.cell.charge -= 20
		var/refill = src.reagents.get_master_reagent_id()
		spawn(600)
			src.reagents.add_reagent(refill, 45)
	return


/obj/item/weapon/pepperspray/examine()
	set src in usr
	usr << "\icon[src] [src.reagents.total_volume] units of spray left!"
	..()
	return



// MOP
/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'janitor.dmi'
	icon_state = "mop"
	var/mopping = 0
	var/mopcount = 0
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	flags = FPRINT | TABLEPASS


/obj/item/weapon/mop/New()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src


obj/item/weapon/mop/proc/clean(turf/simulated/A as turf)
	src.reagents.reaction(A,1,10)
	A.clean_blood()
	for(var/obj/effect/rune/R in A)
		del(R)
	for(var/obj/effect/decal/cleanable/R in A)
		del(R)
	for(var/obj/effect/overlay/R in A)
		del(R)


/obj/effect/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mop))
		return
	..()


/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if (src.reagents.total_volume < 1 || mopcount >= 5)
		user << "\blue Your mop is dry!"
		return

	if (istype(A, /turf/simulated))
		for(var/mob/O in viewers(user, null))
			O.show_message("\red <B>[user] begins to clean \the [A]</B>", 1)
		sleep(40)
		if(A)
			clean(A)
		user << "\blue You have finished mopping!"
		mopcount++
	else if (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		for(var/mob/O in viewers(user, null))
			O.show_message("\red <B>[user] begins to clean \the [get_turf(A)]</B>", 1)
		sleep(40)
		if(A)
			clean(get_turf(A))
		user << "\blue You have finished mopping!"
		mopcount++

	if(mopcount >= 5) //Okay this stuff is an ugly hack and i feel bad about it.
		spawn(5)
			src.reagents.clear_reagents()
			mopcount = 0
	return



/*
 *  Hope it's okay to stick this shit here: it basically just turns a hexadecimal color into rgb
 */

/proc/GetColors(hex)
	hex = uppertext(hex)
	var
		hi1 = text2ascii(hex, 2)
		lo1 = text2ascii(hex, 3)
		hi2 = text2ascii(hex, 4)
		lo2 = text2ascii(hex, 5)
		hi3 = text2ascii(hex, 6)
		lo3 = text2ascii(hex, 7)
	return list(((hi1>= 65 ? hi1-55 : hi1-48)<<4) | (lo1 >= 65 ? lo1-55 : lo1-48),
		((hi2 >= 65 ? hi2-55 : hi2-48)<<4) | (lo2 >= 65 ? lo2-55 : lo2-48),
		((hi3 >= 65 ? hi3-55 : hi3-48)<<4) | (lo3 >= 65 ? lo3-55 : lo3-48))









