/obj/item/weapon/cleaner
	desc = "A chemical that cleans messes."
	icon = 'janitor.dmi'
	name = "space cleaner"
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/catch = 1

/obj/item/weapon/cleaner/New()
	var/datum/reagents/R = new/datum/reagents(250)
	reagents = R
	R.my_atom = src
	R.add_reagent("cleaner", 250)

/obj/item/weapon/cleaner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/cleaner/attack_self(var/mob/user as mob)
	if(catch)
		user << "\blue You flip the safety off."
		catch = 0
		return
	else
		user << "\blue You flip the safety on."
		catch = 1
		return

/obj/item/weapon/cleaner/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/storage ))
		return
	if (istype(A, /obj/effect/proc_holder/spell ))
		return
	else if (catch == 1)
		user << "\blue The safety is on!"
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
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 3
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	origin_tech = "combat=3;materials=3;engineering=3"

/obj/item/weapon/chemsprayer/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	R.add_reagent("cleaner", 10)

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


	return

//Pepper spray, set up to make the 2 different types
/obj/item/weapon/pepperspray //This is riot control
	desc = "Manufactured by UhangInc., used to blind and down an opponent quickly."
	icon = 'weapons.dmi'
	name = "pepperspray"
	icon_state = "pepperspray"
	item_state = "pepperspray"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/catch = 1
	var/BottleSize = 1
	var/ReagentAmount = 30

/obj/item/weapon/pepperspray/small //And this is for personal defense.
	desc = "This appears to be a small, nonlethal, single use personal defense weapon.  Hurts like a bitch, though."
	icon = 'weapons.dmi'
	name = "mace"
	icon_state = "pepperspray"
	item_state = "pepperspray"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 3
	w_class = 1.0
	throw_speed = 2
	throw_range = 10
	catch = 1
	BottleSize = 0
	ReagentAmount = 1

/obj/item/weapon/pepperspray/New()
	var/datum/reagents/R = new/datum/reagents(ReagentAmount)
	reagents = R
	R.my_atom = src
	R.add_reagent("condensedcapsaicin", ReagentAmount)

/obj/item/weapon/pepperspray/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/pepperspray/attack_self(var/mob/user as mob)
	if(catch)
		user << "\blue You flip the safety off."
		catch = 0
		return
	else
		user << "\blue You flip the safety on."
		catch = 1
		return

/obj/item/weapon/pepperspray/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/storage ))
		return
	if (istype(A, /obj/effect/proc_holder/spell ))
		return
	else if (istype(A, /obj/structure/reagent_dispensers/peppertank) && get_dist(src,A) <= 1)
		if(src.reagents.total_volume < ReagentAmount)
			A.reagents.trans_to(src, ReagentAmount - src.reagents.total_volume)
			user << "\blue Pepper spray refilled"
			playsound(src.loc, 'refill.ogg', 50, 1, -6)
			return
		else
			user << "\blue Pepper spray is already full!"
			return
	else if (catch == 1)
		user << "\blue The safety is on!"
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue [src] is empty!"
		return
	playsound(src.loc, 'spray2.ogg', 50, 1, -6)

	var/SprayNum = 0 //Setting up the differentiation for the 2 bottles.   --SkyMarshal
	var/SprayAmt = 0
	if(BottleSize)
		SprayNum = 3
		SprayAmt = 5
	else
		SprayNum = 1
		SprayAmt = 1

	var/Sprays[SprayNum]
	for(var/i=1, i<=SprayNum, i++) // intialize sprays
		if(src.reagents.total_volume < 1) break
		var/obj/effect/decal/D = new/obj/effect/decal(get_turf(src))
		D.name = "chemicals"
		D.icon = 'chempuff.dmi'
		D.create_reagents(SprayAmt)
		src.reagents.trans_to(D, SprayAmt)

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

			var/turf/my_target = null
			// Spreads the sprays a little bit
			if(i == 1)
				my_target = T
			else
				my_target = pick(the_targets)

			the_targets -= my_target

			var/Dist = 0

			if(BottleSize)
				Dist = rand(6,8)
			else
				Dist = rand(2,3)

			for(var/j=1, j<=Dist, j++)
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

	return

/obj/item/weapon/pepperspray/examine()
	set src in usr
	if(BottleSize)
		usr << text("\icon[] [] units of pepperspray left!", src, src.reagents.total_volume)
		..()
		return
	else
		usr << text("\icon[] [] use(s) remaining!", src, src.reagents.total_volume)
		..()
		return

// MOP
/obj/item/weapon/mop
	desc = "The world of the janitor wouldn't be complete without a mop."
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
	if (isnull(A))
		user << "\red You've encountered a nasty bug. You should tell a developer what you were trying to clean with the mop."
		return

	if (src.reagents.total_volume < 1 || mopcount >= 5)
		user << "\blue Your mop is dry!"
		return

	if (istype(A, /turf/simulated))
		for(var/mob/O in viewers(user, null))
			O.show_message("\red <B>[user] begins to clean \the [A]</B>", 1)
		sleep(40)
		clean(A)
		user << "\blue You have finished mopping!"
		mopcount++
	else if (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		for(var/mob/O in viewers(user, null))
			O.show_message("\red <B>[user] begins to clean \the [get_turf(A)]</B>", 1)
		sleep(40)
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









