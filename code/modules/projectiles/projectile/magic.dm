/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	armour_penetration = 100
	flag = "magic"

/obj/item/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"

/obj/item/projectile/magic/death/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		M.death(0)

/obj/item/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = 0

	//explosion values
	var/exp_heavy = 0
	var/exp_light = 2
	var/exp_flash = 3
	var/exp_fire = 2

/obj/item/projectile/magic/fireball/Range()
	var/turf/T1 = get_step(src,turn(dir, -45))
	var/turf/T2 = get_step(src,turn(dir, 45))
	var/turf/T3 = get_step(src,dir)
	var/mob/living/L = locate(/mob/living) in T1 //if there's a mob alive in our front right diagonal, we hit it.
	if(L && L.stat != DEAD)
		Bump(L,1) //Magic Bullet #teachthecontroversy
		return
	L = locate(/mob/living) in T2
	if(L && L.stat != DEAD)
		Bump(L,1)
		return
	L = locate(/mob/living) in T3
	if(L && L.stat != DEAD)
		Bump(L,1)
		return
	..()

/obj/item/projectile/magic/fireball/on_hit(target)
	. = ..()
	var/turf/T = get_turf(target)
	explosion(T, -1, exp_heavy, exp_light, exp_flash, 0, flame_range = exp_fire)
	if(ismob(target)) //multiple flavors of pain
		var/mob/living/M = target
		M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately

/obj/item/projectile/magic/fireball/infernal
	name = "infernal fireball"
	exp_heavy = -1
	exp_light = -1
	exp_flash = 4
	exp_fire= 5


/obj/item/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"
	damage = 0
	damage_type = OXY
	nodamage = 1

/obj/item/projectile/magic/resurrection/on_hit(mob/living/carbon/target)
	. = ..()
	if(isliving(target))
		if(target.hellbound)
			return
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.regenerate_limbs()
			C.regenerate_organs()
		if(target.revive(full_heal = 1))
			target.grab_ghost(force = TRUE) // even suicides
			target << "<span class='notice'>You rise with a start, \
				you're alive!!!</span>"
		else if(target.stat != DEAD)
			target << "<span class='notice'>You feel great!</span>"

/obj/item/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = 1
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/item/projectile/magic/teleport/on_hit(mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc)
			if(do_teleport(stuff, stuff, 10))
				teleammount++
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(max(round(4 - teleammount),0), stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
				smoke.start()

/obj/item/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	var/list/door_types = list(/obj/structure/mineral_door/wood,/obj/structure/mineral_door/iron,/obj/structure/mineral_door/silver,\
		/obj/structure/mineral_door/gold,/obj/structure/mineral_door/uranium,/obj/structure/mineral_door/sandstone,/obj/structure/mineral_door/transparent/plasma,\
		/obj/structure/mineral_door/transparent/diamond)


/obj/item/projectile/magic/door/on_hit(atom/target)
	. = ..()
	if(istype(target, /obj/machinery/door))
		OpenDoor(target)
	else
		var/turf/T = get_turf(target)
		if(isclosedturf(T) && !istype(T, /turf/closed/indestructible))
			CreateDoor(T)

/obj/item/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/open/floor/plating)
	D.Open()

/obj/item/projectile/magic/door/proc/OpenDoor(var/obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = 0
	D.open()

/obj/item/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1

/obj/item/projectile/magic/change/on_hit(atom/change)
	. = ..()
	wabbajack(change)
	qdel(src)

/proc/wabbajack(mob/living/M)
	if(!istype(M) || M.stat == DEAD || M.notransform || (GODMODE & M.status_flags))
		return

	M.notransform = 1
	M.canmove = 0
	M.icon = null
	M.cut_overlays()
	M.invisibility = INVISIBILITY_ABSTRACT

	var/list/contents = M.contents.Copy()

	if(iscyborg(M))
		var/mob/living/silicon/robot/Robot = M
		if(Robot.mmi)
			qdel(Robot.mmi)
		Robot.notify_ai(1)
	else
		for(var/obj/item/W in contents)
			if(!M.unEquip(W))
				qdel(W)

	var/mob/living/new_mob

	var/randomize = pick("monkey","robot","slime","xeno","humanoid","animal")
	switch(randomize)
		if("monkey")
			new_mob = new /mob/living/carbon/monkey(M.loc)
		if("robot")
			var/robot = pick("cyborg","syndiborg","drone")
			switch(robot)
				if("cyborg")
					new_mob = new /mob/living/silicon/robot(M.loc)
				if("syndiborg")
					var/path
					if(prob(50))
						path = /mob/living/silicon/robot/syndicate
					else
						path = /mob/living/silicon/robot/syndicate/medical
					new_mob = new path(M.loc)
				if("drone")
					new_mob = new /mob/living/simple_animal/drone/polymorphed(M.loc)
			if(issilicon(new_mob))
				new_mob.gender = M.gender
				new_mob.invisibility = 0
				new_mob.job = "Cyborg"
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
		if("slime")
			new_mob = new /mob/living/simple_animal/slime/random(M.loc)
		if("xeno")
			if(prob(50))
				new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
			else
				new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)

		if("animal")
			var/path
			if(prob(50))
				var/beast = pick("carp","bear","mushroom","statue", "bat", "goat","killertomato", "spiderbase", "spiderhunter", "blobbernaut", "magicarp", "chaosmagicarp", "watcher", "goliath", "headcrab", "morph", "stickman", "stickdog", "lesserdragon")
				switch(beast)
					if("carp")
						path = /mob/living/simple_animal/hostile/carp
					if("bear")
						path = /mob/living/simple_animal/hostile/bear
					if("mushroom")
						path = /mob/living/simple_animal/hostile/mushroom
					if("statue")
						path = /mob/living/simple_animal/hostile/statue
					if("bat")
						path = /mob/living/simple_animal/hostile/retaliate/bat
					if("goat")
						path = /mob/living/simple_animal/hostile/retaliate/goat
					if("killertomato")
						path = /mob/living/simple_animal/hostile/killertomato
					if("spiderbase")
						path = /mob/living/simple_animal/hostile/poison/giant_spider
					if("spiderhunter")
						path = /mob/living/simple_animal/hostile/poison/giant_spider/hunter
					if("blobbernaut")
						path = /mob/living/simple_animal/hostile/blob/blobbernaut/independent
					if("magicarp")
						path = /mob/living/simple_animal/hostile/carp/ranged
					if("chaosmagicarp")
						path = /mob/living/simple_animal/hostile/carp/ranged/chaos
					if("watcher")
						path = /mob/living/simple_animal/hostile/asteroid/basilisk/watcher
					if("goliath")
						path = /mob/living/simple_animal/hostile/asteroid/goliath/beast
					if("headcrab")
						path = /mob/living/simple_animal/hostile/headcrab
					if("morph")
						path = /mob/living/simple_animal/hostile/morph
					if("stickman")
						path = /mob/living/simple_animal/hostile/stickman
					if("stickdog")
						path = /mob/living/simple_animal/hostile/stickman/dog
					if("lesserdragon")
						path = /mob/living/simple_animal/hostile/megafauna/dragon/lesser
			else
				var/animal = pick("parrot","corgi","crab","pug","cat","mouse","chicken","cow","lizard","chick","fox","butterfly","cak")
				switch(animal)
					if("parrot")
						path = /mob/living/simple_animal/parrot
					if("corgi")
						path = /mob/living/simple_animal/pet/dog/corgi
					if("crab")
						path = /mob/living/simple_animal/crab
					if("pug")
						path = /mob/living/simple_animal/pet/dog/pug
					if("cat")
						path = /mob/living/simple_animal/pet/cat
					if("mouse")
						path = /mob/living/simple_animal/mouse
					if("chicken")
						path = /mob/living/simple_animal/chicken
					if("cow")
						path = /mob/living/simple_animal/cow
					if("lizard")
						path = /mob/living/simple_animal/hostile/lizard
					if("fox")
						path = /mob/living/simple_animal/pet/fox
					if("butterfly")
						path = /mob/living/simple_animal/butterfly
					if("cak")
						path = /mob/living/simple_animal/pet/cat/cak
					if("chick")
						path = /mob/living/simple_animal/chick

			new_mob = new path(M.loc)

		if("humanoid")
			new_mob = new /mob/living/carbon/human(M.loc)

			var/datum/preferences/A = new()	//Randomize appearance for the human
			A.copy_to(new_mob, icon_updates=0)

			var/mob/living/carbon/human/H = new_mob
			if(prob(50))
				var/list/all_species = list()
				for(var/speciestype in subtypesof(/datum/species))
					var/datum/species/S = new speciestype()
					if(!S.dangerous_existence)
						all_species += speciestype
				H.set_species(pick(all_species), icon_update=0)
			H.update_body()
			H.update_hair()
			H.update_body_parts()
			H.dna.update_dna_identity()

	if(!new_mob)
		return

	new_mob.languages_spoken |= HUMAN
	new_mob.languages_understood |= HUMAN
	new_mob.attack_log = M.attack_log

	// Some forms can still wear some items
	for(var/obj/item/W in contents)
		new_mob.equip_to_appropriate_slot(W)

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")

	new_mob.a_intent = INTENT_HARM

	M.wabbajack_act(new_mob)

	new_mob << "<span class='warning'>Your form morphs into that of \
		a [randomize].</span>"

	qdel(M)
	return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage = 0
	damage_type = BURN
	nodamage = 1

/obj/item/projectile/magic/animate/on_hit(atom/target, blocked = 0)
	..()
	if((istype(target, /obj/item) || istype(target, /obj/structure)) && !is_type_in_list(target, protected_objects))
		if(istype(target, /obj/structure/statue/petrified))
			var/obj/structure/statue/petrified/P = target
			if(P.petrified_mob)
				var/mob/living/L = P.petrified_mob
				var/mob/living/simple_animal/hostile/statue/S = new (P.loc, firer)
				S.name = "statue of [L.name]"
				S.faction = list("\ref[firer]")
				S.icon = P.icon
				S.icon_state = P.icon_state
				S.overlays = P.overlays
				S.color = P.color
				S.atom_colours = P.atom_colours.Copy()
				if(L.mind)
					L.mind.transfer_to(S)
					S << "<span class='userdanger'>You are an animate statue. You cannot move when monitored, but are nearly invincible and deadly when unobserved! Do not harm [firer.name], your creator.</span>"
				P.loc = S
				qdel(src)
				return
		else
			var/obj/O = target
			if(istype(O, /obj/item/weapon/gun))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(O.loc, O, firer)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)

	else if(istype(target, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = target
		C.ChangeOwner(firer)

/obj/item/projectile/magic/spellblade
	name = "blade energy"
	icon_state = "lavastaff"
	damage = 15
	damage_type = BURN
	flag = "magic"
	dismemberment = 50
	nodamage = 0

/obj/item/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = 0
	armour_penetration = 0
	flag = "magic"
