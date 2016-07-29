/obj/structure/grille
<<<<<<< HEAD
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
=======
	name = "grille"
	desc = "A matrice of metal rods, usually used as a support for window bays, with screws to secure it to the floor."
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = 1
	anchored = 1
<<<<<<< HEAD
	flags = CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = BELOW_OBJ_LAYER
	var/health = 10
	var/destroyed = 0
	var/obj/item/stack/rods/stored

/obj/structure/grille/New()
	..()
	stored = new/obj/item/stack/rods(src)
	stored.amount = 2

/obj/structure/grille/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		else
			take_damage(rand(5,10), BRUTE, 0)

/obj/structure/grille/ratvar_act()
	if(prob(20))
		if(destroyed)
			new /obj/structure/grille/ratvar/broken(src.loc)
		else
			new /obj/structure/grille/ratvar(src.loc)
		qdel(src)

/obj/structure/grille/blob_act(obj/effect/blob/B)
	qdel(src)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user))
		shock(user, 70)


/obj/structure/grille/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/grille/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	shock(user, 70)
	take_damage(5)

/obj/structure/grille/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='warning'>[user] hits [src].</span>", \
						 "<span class='danger'>You hit [src].</span>", \
						 "<span class='italics'>You hear twisting metal.</span>")
	if(!shock(user, 70))
		take_damage(rand(1,2))

/obj/structure/grille/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
						 "<span class='danger'>You mangle [src].</span>", \
						 "<span class='italics'>You hear twisting metal.</span>")
	if(!shock(user, 70))
		take_damage(5)

/obj/structure/grille/attack_slime(mob/living/simple_animal/slime/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!user.is_adult)
		return

	user.visible_message("<span class='warning'>[user] smashes against [src].</span>", \
						 "<span class='danger'>You smash against [src].</span>", \
						 "<span class='italics'>You hear twisting metal.</span>")
	take_damage(rand(1,2))

/obj/structure/grille/attack_animal(var/mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	if(M.melee_damage_upper == 0 || (M.melee_damage_type != BRUTE && M.melee_damage_type != BURN))
		return
	M.do_attack_animation(src)
	M.visible_message("<span class='warning'>[M] smashes against [src].</span>", \
					  "<span class='danger'>You smash against [src].</span>", \
					  "<span class='italics'>You hear twisting metal.</span>")
	take_damage(M.melee_damage_upper, M.melee_damage_type)


/obj/structure/grille/mech_melee_attack(obj/mecha/M)
	if(..())
		take_damage(M.force * 0.5, M.damtype)

/obj/structure/grille/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile) && density)
			return prob(30)
		else
			return !density

/obj/structure/grille/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSGRILLE)

/obj/structure/grille/bullet_act(var/obj/item/projectile/Proj)
	. = ..()
	take_damage(Proj.damage*0.3, Proj.damage_type)

/obj/structure/grille/Deconstruct()
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(!(flags&NODECONSTRUCT))
		transfer_fingerprints_to(stored)
		var/turf/T = loc
		stored.loc = T
	..()

/obj/structure/grille/proc/Break()
	icon_state = "broken[initial(icon_state)]"
	density = 0
	destroyed = 1
	stored.amount = 1
	if(!(flags&NODECONSTRUCT))
		var/obj/item/stack/rods/newrods = new(loc)
		transfer_fingerprints_to(newrods)

/obj/structure/grille/attackby(obj/item/weapon/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(istype(W, /obj/item/weapon/wirecutters))
		if(!shock(user, 100))
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			Deconstruct()
	else if((istype(W, /obj/item/weapon/screwdriver)) && (istype(loc, /turf) || anchored))
		if(!shock(user, 90))
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] [src].</span>", \
								 "<span class='notice'>You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor.</span>")
			return
	else if(istype(W, /obj/item/stack/rods) && destroyed)
		var/obj/item/stack/rods/R = W
		if(!shock(user, 90))
			user.visible_message("<span class='notice'>[user] rebuilds the broken grille.</span>", \
								 "<span class='notice'>You rebuild the broken grille.</span>")
			health = 10
			density = 1
			destroyed = 0
			icon_state = initial(icon_state)
			R.use(1)
			return

//window placing begin
	else if(istype(W, /obj/item/stack/sheet/rglass) || istype(W, /obj/item/stack/sheet/glass))
		if (!destroyed)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 2)
				user << "<span class='warning'>You need at least two sheets of glass for that!</span>"
				return
			var/dir_to_set = SOUTHWEST
			if(!anchored)
				user << "<span class='warning'>[src] needs to be fastened to the floor first!</span>"
				return
			for(var/obj/structure/window/WINDOW in loc)
				user << "<span class='warning'>There is already a window there!</span>"
				return
			user << "<span class='notice'>You start placing the window...</span>"
			if(do_after(user,20, target = src))
				if(!src.loc || !anchored) //Grille destroyed or unanchored while waiting
					return
				for(var/obj/structure/window/WINDOW in loc) //Another window already installed on grille
					return
				var/obj/structure/window/WD
				if(istype(W, /obj/item/stack/sheet/rglass))
					WD = new/obj/structure/window/reinforced/fulltile(loc) //reinforced window
				else
					WD = new/obj/structure/window/fulltile(loc) //normal window
				WD.setDir(dir_to_set)
				WD.ini_dir = dir_to_set
				WD.anchored = 0
				WD.state = 0
				ST.use(2)
				user << "<span class='notice'>You place [WD] on [src].</span>"
			return
//window placing end

	else if(istype(W, /obj/item/weapon/shard) || !shock(user, 70))
		return ..()


/obj/structure/grille/attacked_by(obj/item/I, mob/living/user)
	..()
	take_damage(I.force * 0.3, I.damtype)

/obj/structure/grille/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BURN)
			if(sound_effect)
				playsound(loc, 'sound/items/welder.ogg', 80, 1)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		else
			return
	health -= damage
	if(health <= 0)
		if(!destroyed)
			Break()
		else
			if(health <= -6)
				Deconstruct()


// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return 0
	if(!prob(prb))
		return 0
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return 0
=======
	flags = FPRINT
	siemens_coefficient = 1
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = 2.9
	explosion_resistance = 5
	var/health = 20 //Relatively "strong" since it's hard to dismantle via brute force
	var/broken = 0

/obj/structure/grille/examine(mob/user)

	..()
	if(!anchored)
		to_chat(user, "Its screws are loose.")
	if(broken) //We're not going to bother with the damage
		to_chat(user, "It has been completely smashed apart, only a few rods are still holding together")

/obj/structure/grille/cultify()
	new /obj/structure/grille/cult(get_turf(src))
	returnToPool(src)
	..()

/obj/structure/grille/proc/healthcheck(var/hitsound = 0) //Note : Doubles as the destruction proc()
	if(hitsound)
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	if(health <= (0.25*initial(health)) && !broken) //Modular, 1/4th of original health. Do make sure the grille isn't broken !
		broken = 1
		icon_state = "[initial(icon_state)]-b"
		density = 0 //Not blocking anything anymore
		getFromPool(/obj/item/stack/rods, get_turf(src)) //One rod set
	else if(health >= (0.25*initial(health)) && broken) //Repair the damage to this bitch
		broken = 0
		icon_state = initial(icon_state)
		density = 1
	if(health <= 0) //Dead
		getFromPool(/obj/item/stack/rods, get_turf(src)) //Drop the second set of rods
		returnToPool(src)

/obj/structure/grille/ex_act(severity)
	switch(severity)
		if(1)
			health -= rand(30, 50)
		if(2)
			health -= rand(15, 30)
		if(3)
			health -= rand(5, 15)
	healthcheck(hitsound = 1)
	return

/obj/structure/grille/blob_act()
	..()
	health -= rand(initial(health)*0.8, initial(health)*3) //Grille will always be blasted, but chances of leaving things over
	healthcheck(hitsound = 1)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user))
		shock(user, 60) //Give the user the benifit of the doubt

/obj/structure/grille/attack_paw(mob/user as mob)
	attack_hand(user)

/obj/structure/grille/attack_hand(mob/user as mob)
	var/humanverb = pick(list("kick", "slam", "elbow")) //Only verbs with a third person "s", thank you
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] [humanverb]s \the [src].</span>", \
	"<span class='warning'>You [humanverb] \the [src].</span>", \
	"<span class='warning'>You hear twisting metal.</span>")
	if(M_HULK in user.mutations)
		health -= 5 //Fair hit
	else
		health -= 3 //Do decent damage, still not as good as using a real tool
	healthcheck(hitsound = 1)
	shock(user, 100) //If there's power running in the grille, allow the attack but grill the user

/obj/structure/grille/attack_alien(mob/user as mob)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	var/alienverb = pick(list("slam", "rip", "claw")) //See above
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] [alienverb]s \the [src].</span>", \
						 "<span class='warning'>You [alienverb] \the [src].</span>", \
						 "You hear twisting metal.")
	health -= 5
	healthcheck(hitsound = 1)
	shock(user, 75) //Ditto above

/obj/structure/grille/attack_slime(mob/user as mob)
	if(!istype(user, /mob/living/carbon/slime/adult))
		return
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] smashes against \the [src].</span>", \
						 "<span class='warning'>You smash against \the [src].</span>", \
						 "You hear twisting metal.")
	health -= 3
	healthcheck(hitsound = 1)
	shock(user, 100)
	return

/obj/structure/grille/attack_animal(var/mob/living/simple_animal/M as mob)
	M.delayNextAttack(8)
	if(M.melee_damage_upper == 0)
		return
	M.visible_message("<span class='warning'>[M] smashes against \the [src].</span>", \
					  "<span class='warning'>You smash against \the [src].</span>", \
					  "You hear twisting metal.")
	health -= rand(M.melee_damage_lower, M.melee_damage_upper)
	healthcheck(hitsound = 1)
	shock(M, 100)
	return


/obj/structure/grille/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || (height == 0))
		return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			var/obj/item/projectile/projectile = mover
			return prob(projectile.grillepasschance) //Fairly hit chance
		else
			return !density

/obj/structure/grille/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	health -= Proj.damage //Just use the projectile damage, it already has high odds of "missing"
	healthcheck(hitsound = 1)
	return 0

/obj/structure/grille/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if(iswirecutter(W))
		if(!shock(user, 100)) //Prevent user from doing it if he gets shocked
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			getFromPool(/obj/item/stack/rods, get_turf(src), broken ? 1 : 2) //Drop the rods, taking account on whenever the grille is broken or not !
			returnToPool(src)
			return
		return //Return in case the user starts cutting and gets shocked, so that it doesn't continue downwards !
	else if((isscrewdriver(W)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille [anchored ? "to" : "from"] the floor.</span>", \
			"<span class='notice'>You [anchored ? "fasten" : "unfasten"] the grille [anchored ? "to" : "from"] the floor.</span>")
			return

//Window placement
	else if(istype(W, /obj/item/stack/sheet/glass))
		var/dir_to_set
		if(loc == user.loc)
			dir_to_set = user.dir //Whatever the user is doing, return the "normal" window placement output
		else
			if((x == user.x) || (y == user.y)) //Only supposed to work for cardinal directions, aka can't lay windows in diagonal directions
				if(x == user.x) //User is on the same vertical plane
					if(y > user.y)
						dir_to_set = 2 //User is laying from the bottom
					else
						dir_to_set = 1 //User is laying from the top
				else if(y == user.y) //User is on the same horizontal plane
					if (x > user.x)
						dir_to_set = 8 //User is laying from the left
					else
						dir_to_set = 4 //User is laying from the right
			else
				to_chat(user, "<span class='warning'>You can't reach far enough.</span>")
				return
		for(var/obj/structure/window/P in loc)
			if(P.dir == dir_to_set)
				to_chat(user, "<span class='warning'>There's already a window here.</span>")//You idiot

				return
		user.visible_message("<span class='notice'>[user] starts placing a window on \the [src].</span>", \
		"<span class='notice'>You start placing a window on \the [src].</span>")
		if(do_after(user, src, 20))
			for(var/obj/structure/window/P in loc)
				if(P.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
					to_chat(user, "<span class='warning'>There's already a window here.</span>")
					return
			var/obj/item/stack/sheet/glass/glass/G = W //This fucking stacks code holy shit
			var/obj/structure/window/WD = new G.created_window(loc, 0)
			WD.dir = dir_to_set
			WD.ini_dir = dir_to_set
			WD.anchored = 0
			WD.d_state = 0
			var/obj/item/stack/ST = W //HOLY FUCKING SHIT !
			ST.use(1)
			user.visible_message("<span class='notice'>[user] places \a [WD] on \the [src].</span>", \
			"<span class='notice'>You place \a [WD] on \the [src].</span>")
		return

	if(istype(W, /obj/item/weapon/fireaxe)) //Fireaxes instantly kill grilles
		health = 0
		healthcheck()

	switch(W.damtype)
		if("fire")
			health -= W.force //Fire-based tools like welding tools are ideal to work through small metal rods !
		if("brute")
			health -= W.force * 0.5 //Rod matrices have an innate resistance to brute damage
	shock(user, 100 * W.siemens_coefficient) //Chance of getting shocked is proportional to conductivity
	healthcheck(hitsound = 1)
	..()
	return

//Shock user with probability prb (if all connections & power are working)
//Returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user as mob, prb)
	if(!anchored || broken)	//De-anchored and destroyed grilles are never connected to the powernet !
		return 0
	if(!prob(prb)) //If the probability roll failed, don't go further
		return 0
	if(!in_range(src, user)) //To prevent TK and mech users from getting shocked
		return 0
	//Process the shocking via powernet, our job is done here
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src))
<<<<<<< HEAD
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
=======
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			s.set_up(3, 1, src)
			s.start()
			return 1
		else
			return 0
	return 0

<<<<<<< HEAD
/obj/structure/grille/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!destroyed)
		if(exposed_temperature > T0C + 1500)
			take_damage(1)
	..()

/obj/structure/grille/hitby(AM as mob|obj)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 5
	else if(isobj(AM))
		if(prob(50))
			var/obj/item/I = AM
			tforce = max(0, I.throwforce * 0.5)
		else if(anchored && !destroyed)
			var/turf/T = get_turf(src)
			var/obj/structure/cable/C = T.get_cable_node()
			if(C)
				playsound(src.loc, 'sound/magic/LightningShock.ogg', 100, 1, extrarange = 5)
				tesla_zap(src, 3, C.powernet.avail * 0.08) //ZAP for 1/5000 of the amount of power, which is from 15-25 with 200000W
	take_damage(tforce)

/obj/structure/grille/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0

/obj/structure/grille/broken // Pre-broken grilles for map placement
	icon_state = "brokengrille"
	density = 0
	health = 0
	destroyed = 1

/obj/structure/grille/broken/New()
	..()
	stored.amount = 1
	icon_state = "brokengrille"

/obj/structure/grille/ratvar
	icon_state = "ratvargrille"
	desc = "A strangely-shaped grille."

/obj/structure/grille/ratvar/New()
	..()
	change_construction_value(1)
	if(destroyed)
		PoolOrNew(/obj/effect/overlay/temp/ratvar/grille/broken, get_turf(src))
	else
		PoolOrNew(/obj/effect/overlay/temp/ratvar/grille, get_turf(src))
		PoolOrNew(/obj/effect/overlay/temp/ratvar/beam/grille, get_turf(src))

/obj/structure/grille/ratvar/Destroy()
	change_construction_value(-1)
	return ..()

/obj/structure/grille/ratvar/narsie_act()
	take_damage(rand(1, 3), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/structure/grille/ratvar/ratvar_act()
	return

/obj/structure/grille/ratvar/broken
	density = 0
	health = 0
	destroyed = 1

/obj/structure/grille/ratvar/broken/New()
	..()
	stored.amount = 1
	icon_state = "brokenratvargrille"
=======
/obj/structure/grille/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 1500)
		health -= 1
		healthcheck() //Note : This healthcheck is silent, and it's going to stay that way
	..()

//Mapping entities and alternatives !

/obj/structure/grille/broken //THIS IS ONLY TO BE USED FOR MAPPING, THANK YOU FOR YOUR UNDERSTANDING

	//We need to set all variables for broken grilles manually, notably to have those show up nicely in mapmaker
	icon_state = "grille-b"
	broken = 1
	density = 0 //Not blocking anything anymore

/obj/structure/grille/broken/New()
	health -= rand(initial(health)*0.8, initial(health)*0.9) //Largely under broken threshold, this is used to adjust the health, NOT to break it
	healthcheck() //Send this to healthcheck just in case we want to do something else with it

/obj/structure/grille/broken/healthcheck(var/hitsound = 0) //needed because initial icon_state for broken is grille-b for mapping
	..()
	if(broken)
		icon_state = "grille-b"
	else
		icon_state = "grille"

/obj/structure/grille/cult //Used to get rid of those ugly fucking walls everywhere while still blocking air

	name = "cult grille"
	desc = "A matrice built out of an unknown material, with some sort of force field blocking air around it"
	icon_state = "grillecult"
	health = 40 //Make it strong enough to avoid people breaking in too easily

/obj/structure/grille/cult/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || !broken)
		return 0 //Make sure air doesn't drain
	..()


/obj/structure/grille/invulnerable
	desc = "A reinforced grille made with advanced alloys and techniques. It's impossible to break one without the use of heavy machinery."

/obj/structure/grille/invulnerable/healthcheck(hitsound)
	return

/obj/structure/grille/invulnerable/ex_act()
	return

/obj/structure/grille/invulnerable/attackby()
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
