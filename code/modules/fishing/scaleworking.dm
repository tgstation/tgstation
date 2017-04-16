/obj/item/fishingPole
	name = "fishing pole"
	desc = "para pescar pescaditos"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_rod"
	var/obj/machinery/carpFisher/fisher

/obj/item/fishingPole/attack_self(mob/living/user)
	if(fisher)
		if(fisher.active)
			user << "<spanclass = 'warning'>the machine is working</span>"
		else
			if(fisher.checkPen())
				fisher.fish()
			else
				user << "failed"

/mob/simple_animal/fishing
	var/possibleDirs = 15
	var/stepCooldown = 0

/mob/simple_animal/fishing/proc/escapeStruggle()
	var/C = cardinal
	for(var/i=0;i<4;i++)
		var/D = pick(C)
		if(D & possibleDirs)
			step(src,D)
			if(possibleDirs == 15) //at the middle
				possibleDirs &= ~D
			else
				possibleDirs &= D
			return
		else
			C -= D

/obj/machinery/carpFisher
	name = "carp fisha"
	desc = "aaaaaah"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "rod_holster_empty"
	anchored = 1
	dir = 4
	var/obj/item/fishingPole/pole
	var/active = 0
	var/mob/simple_animal/fishing/animal

/obj/machinery/carpFisher/process()
	if(active && checkPen())
		if(animal.stepCooldown == 0)
			animal.escapeStruggle()
		return

/obj/machinery/carpFisher/attack_hand(mob/living/user)
	if(pole && pole.loc == src)
		pole.loc = loc
	update_icon()

/obj/machinery/carpFisher/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/fishingPole))
		if(active)
			user << "<spanclass = 'warning'>the machine is working</span>"
			return
		var/obj/item/fishingPole/P = I
		if(pole)
			if(pole == P)
				placeRod(P, user)
			else
				placeOtherRod(P, user)
		else
			placeOtherRod(P, user)

/obj/machinery/carpFisher/proc/placeOtherRod(obj/item/fishingPole/P, mob/living/user)
	if(P.fisher)
		if(P.fisher.active)
			user << "<spanclass = 'warning'>this rod is linked to an active machine</span>"
			return
		P.fisher.pole = null
	pole = P
	P.fisher = src
	placeRod(P, user)


/obj/machinery/carpFisher/proc/placeRod(obj/item/fishingPole/P, mob/living/user)
	user.drop_item()
	P.loc = src
	user << "<spanclass = 'notice'>placed</span>"
	update_icon()

/obj/machinery/carpFisher/proc/fishEscape()
	return

/obj/machinery/carpFisher/update_icon()
	if(pole && pole.loc == src)
		icon_state = "rod_holster_equip"
	else
		icon_state = "rod_holster_empty"

/obj/machinery/carpFisher/proc/checkPen() // checks for a 3x3 space behind the machine, without density objects and only by space tiles
	var/list/L = list()
	var/D = turn(dir,180)
	var/turf/U = get_turf(src)
	while(L.len != 9)
		U = get_step(U, D)
		L += U
		var/turf/R = get_step(U, turn(D,90))
		L += R
		R = get_step(U, turn(D,-90))
		L += R

	for(var/turf/T in L)
		if(!istype(T,/turf/space))
			return
		for(var/atom/movable/A in T)
			if(A.density)
				if(!istype(A, /obj/structure/fishingNet))
					return
		T.maptext = "success"
	return 1

/obj/machinery/carpFisher/proc/fish()
	var/turf/T = get_step(get_step(loc, turn(dir, 180)), turn(dir, 180)) //two steps behind the machine
	animal = new(T)

/obj/structure/fishingNet
	name = "fishing net"
	desc = "para pescar pescaditos"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_net"
	density = 1
	anchored = 1

/obj/structure/fishingNet/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1




/obj/item/weapon/fishNetSPAWNER //spawner, this will be removed

/obj/item/weapon/fishNetSPAWNER/New()
	for(var/D in alldirs)
		var/turf/T = get_step(src, D)
		var/obj/structure/fishingNet/N = new(T)
		N.dir = D
	var/turf/T = locate(x+2, y, z)
	new /obj/machinery/carpFisher(T)
	new /obj/item/fishingPole(T)
	qdel(src)


//if you're reading this, this doesn't work.