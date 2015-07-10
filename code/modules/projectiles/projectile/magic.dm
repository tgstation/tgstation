/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"

/obj/item/projectile/magic/death/on_hit(var/target)
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
	flag = "magic"

/obj/item/projectile/magic/fireball/Range()
	var/mob/living/L = locate(/mob/living) in (range(src, 1) - firer)
	if(L && L.stat != DEAD)
		Bump(L) //Magic Bullet #teachthecontroversy
		return
	..()

/obj/item/projectile/magic/fireball/on_hit(var/target)
	. = ..()
	var/turf/T = get_turf(target)
	explosion(T, -1, 0, 2, 3, 0, flame_range = 2)
	if(ismob(target)) //multiple flavors of pain
		var/mob/living/M = target
		M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately

/obj/item/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/resurrection/on_hit(var/mob/living/carbon/target)
	. = ..()
	if(ismob(target))
		var/old_stat = target.stat
		target.revive()
		target.suiciding = 0
		if(!target.ckey)
			for(var/mob/dead/observer/ghost in player_list)
				if(target.real_name == ghost.real_name)
					ghost.reenter_corpse()
					break
		if(old_stat != DEAD)
			target << "<span class='notice'>You feel great!</span>"
		else
			target << "<span class='notice'>You rise with a start, you're alive!!!</span>"

/obj/item/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/item/projectile/magic/teleport/on_hit(var/mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc)
			teleammount++
			do_teleport(stuff, stuff, 10)
			var/datum/effect/effect/system/smoke_spread/smoke = new
			smoke.set_up(max(round(10 - teleammount),1), 0, stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
			smoke.start()

/obj/item/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/door/on_hit(var/atom/target)
	. = ..()
	var/atom/T = target.loc
	if(isturf(target) && target.density)
		CreateDoor(target)
	else if (isturf(T) && T.density)
		CreateDoor(T)

/obj/item/projectile/magic/door/proc/CreateDoor(var/turf/T)
	new /obj/structure/mineral_door/wood(T)
	T.ChangeTurf(/turf/simulated/floor/plating)


/obj/item/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/change/on_hit(var/atom/change)
	. = ..()
	wabbajack(change)

/proc/wabbajack(mob/living/M)
	if(istype(M))
		if(istype(M, /mob/living) && M.stat != DEAD)
			if(M.notransform)	return
			M.notransform = 1
			M.canmove = 0
			M.icon = null
			M.overlays.Cut()
			M.invisibility = 101

			if(istype(M, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/Robot = M
				if(Robot.mmi)	qdel(Robot.mmi)
				Robot.notify_ai(1)
			else
				for(var/obj/item/W in M)
					if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
						qdel(W)
						continue
					W.layer = initial(W.layer)
					W.loc = M.loc
					W.dropped(M)

			var/mob/living/new_mob

			var/randomize = pick("monkey","robot","slime","xeno","human","animal")
			switch(randomize)
				if("monkey")
					new_mob = new /mob/living/carbon/monkey(M.loc)
					new_mob.languages |= HUMAN
				if("robot")
					var/robot = pick("cyborg","syndiborg","drone")
					switch(robot)
						if("cyborg")		new_mob = new /mob/living/silicon/robot(M.loc)
						if("syndiborg")		new_mob = new /mob/living/silicon/robot/syndicate(M.loc)
						if("drone")			new_mob = new /mob/living/simple_animal/drone(M.loc)
					if(issilicon(new_mob))
						new_mob.gender = M.gender
						new_mob.invisibility = 0
						new_mob.job = "Cyborg"
						var/mob/living/silicon/robot/Robot = new_mob
						Robot.mmi = new /obj/item/device/mmi(new_mob)
						Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
					else
						new_mob.languages |= HUMAN
				if("slime")
					new_mob = new /mob/living/simple_animal/slime(M.loc)
					if(prob(50))
						var/mob/living/simple_animal/slime/Slime = new_mob
						Slime.is_adult = 1
					new_mob.languages |= HUMAN
				if("xeno")
					if(prob(50))
						new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
					else
						new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
					new_mob.languages |= HUMAN

					/*var/alien_caste = pick("Hunter","Sentinel","Drone","Larva")
					switch(alien_caste)
						if("Hunter")	new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
						if("Sentinel")	new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
						if("Drone")		new_mob = new /mob/living/carbon/alien/humanoid/drone(M.loc)
						else			new_mob = new /mob/living/carbon/alien/larva(M.loc)
					new_mob.languages |= HUMAN*/
				if("animal")
					if(prob(50))
						var/beast = pick("carp","bear","mushroom","statue", "bat", "goat","killertomato", "spiderbase", "spiderhunter", "blobbernaut", "magicarp", "chaosmagicarp")
						switch(beast)
							if("carp")		new_mob = new /mob/living/simple_animal/hostile/carp(M.loc)
							if("bear")		new_mob = new /mob/living/simple_animal/hostile/bear(M.loc)
							if("mushroom")	new_mob = new /mob/living/simple_animal/hostile/mushroom(M.loc)
							if("statue")	new_mob = new /mob/living/simple_animal/hostile/statue(M.loc)
							if("bat") 		new_mob = new /mob/living/simple_animal/hostile/retaliate/bat(M.loc)
							if("goat")		new_mob = new /mob/living/simple_animal/hostile/retaliate/goat(M.loc)
							if("killertomato")	new_mob = new /mob/living/simple_animal/hostile/killertomato(M.loc)
							if("spiderbase")	new_mob = new /mob/living/simple_animal/hostile/poison/giant_spider(M.loc)
							if("spiderhunter")	new_mob = new /mob/living/simple_animal/hostile/poison/giant_spider/hunter(M.loc)
							if("blobbernaut")	new_mob = new /mob/living/simple_animal/hostile/blob/blobbernaut(M.loc)
							if("magicarp")		new_mob = new /mob/living/simple_animal/hostile/carp/ranged(M.loc)
							if("chaosmagicarp")	new_mob = new /mob/living/simple_animal/hostile/carp/ranged/chaos(M.loc)
					else
						var/animal = pick("parrot","corgi","crab","pug","cat","mouse","chicken","cow","lizard","chick","fox","butterfly")
						switch(animal)
							if("parrot")	new_mob = new /mob/living/simple_animal/parrot(M.loc)
							if("corgi")		new_mob = new /mob/living/simple_animal/pet/corgi(M.loc)
							if("crab")		new_mob = new /mob/living/simple_animal/crab(M.loc)
							if("pug")		new_mob = new /mob/living/simple_animal/pet/pug(M.loc)
							if("cat")		new_mob = new /mob/living/simple_animal/pet/cat(M.loc)
							if("mouse")		new_mob = new /mob/living/simple_animal/mouse(M.loc)
							if("chicken")	new_mob = new /mob/living/simple_animal/chicken(M.loc)
							if("cow")		new_mob = new /mob/living/simple_animal/cow(M.loc)
							if("lizard")	new_mob = new /mob/living/simple_animal/lizard(M.loc)
							if("fox") new_mob = new /mob/living/simple_animal/pet/fox(M.loc)
							if("butterfly")	new_mob = new /mob/living/simple_animal/butterfly(M.loc)
							else			new_mob = new /mob/living/simple_animal/chick(M.loc)
					new_mob.languages |= HUMAN
				if("human")
					new_mob = new /mob/living/carbon/human(M.loc)

					var/datum/preferences/A = new()	//Randomize appearance for the human
					A.copy_to(new_mob)

					var/mob/living/carbon/human/H = new_mob
					ready_dna(H)
					if(H.dna && prob(50))
						var/list/all_species = list()
						for(var/speciestype in typesof(/datum/species) - /datum/species)
							var/datum/species/S = new speciestype()
							if(!S.dangerous_existence)
								all_species += speciestype
						hardset_dna(H, null, null, null, null, pick(all_species))
						H.real_name = H.dna.species.random_name(H.gender,1)
					H.update_icons()
				else
					return

			new_mob.attack_log = M.attack_log
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")

			new_mob.a_intent = "harm"
			if(M.mind)
				M.mind.transfer_to(new_mob)
			else
				new_mob.key = M.key

			new_mob << "<B>Your form morphs into that of a [randomize].</B>"

			del(M)
			return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/animate/Bump(var/atom/change)
	..()
	if(istype(change, /obj/item) || istype(change, /obj/structure) && !is_type_in_list(change, protected_objects))
		if(istype(change, /obj/structure/closet/statue))
			for(var/mob/living/carbon/human/H in change.contents)
				var/mob/living/simple_animal/hostile/statue/S = new /mob/living/simple_animal/hostile/statue(change.loc, firer)
				S.name = "statue of [H.name]"
				S.faction = list("\ref[firer]")
				S.icon = change.icon
				if(H.mind)
					H.mind.transfer_to(S)
					S << "<span class='userdanger'>You are an animate statue. You cannot move when monitored, but are nearly invincible and deadly when unobserved! Do not harm [firer.name], your creator.</span>"
				H = change
				H.loc = S
				qdel(src)
				return
		else
			var/obj/O = change
			if(istype(O, /obj/item/weapon/gun))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(O.loc, O, firer)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)

	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = change
		C.ChangeOwner(firer)