/turf/simulated/floor/nano
	name = "Nano-infested plating"
	desc = "The surface almost crawls with a visible layer of nanomites"
	icon_state = "rcircuit"

/turf/simulated/floor/nano/New()
	..()
	icon_state = pick("rcircuit","rcircuitanim")
	SetLuminosity(rand(1,5))

/turf/simulated/wall/nano
	name = "Nano-infested wall"
	desc = "The surface almost crawls with a visible layer of nanomites"
	icon_state = "alienvault"

/mob/living/simple_animal/hostile/nanoswarm
	name = "nanoswarm"
	icon_state = "nanoswarm0"
	icon_living = "nanoswarm0"
	icon_dead = "nanoswarm_dead"
	faction = list("nano")
	stop_automated_movement = 1
	environment_smash = 3
	attacktext = "absorbs"
	robust_searching = 1
	maxHealth = 75
	health = 75

	ranged = 1
	projectiletype = /obj/item/projectile/beam/disabler

	harm_intent_damage = 15
	melee_damage_lower = 1
	melee_damage_upper = 1

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	var/powerStored = 0
	var/upgradeLevel = 0
	var/floorConvert = /turf/simulated/floor/nano
	var/wallConvert = /turf/simulated/wall/nano

/mob/living/simple_animal/hostile/nanoswarm/emp_act(var/severity)
	health = 0
	update_icon()

/mob/living/simple_animal/hostile/nanoswarm/proc/update_icon()
	..()
	if(health > 0)
		icon_state = "nanoswarm[round(upgradeLevel)]"
		icon_living = "nanoswarm[round(upgradeLevel)]"
	else
		icon_state = "nanoswarm[round(upgradeLevel)]_dead"

/mob/living/simple_animal/hostile/nanoswarm/proc/updateDamage()
	melee_damage_lower = min(50,(initial(melee_damage_lower) + (powerStored/1000)*upgradeLevel)/2)
	melee_damage_upper = min(100,initial(melee_damage_upper) + (powerStored/1000)*upgradeLevel)

/mob/living/simple_animal/hostile/nanoswarm/Life()
	..()
	if(health <= 0)
		return
	//process movement
	var/dirchoice = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
	var/turf/myTurf = get_turf(src)
	var/turf/t = get_step(src,dirchoice)
	var/obj/machinery/M = locate(/obj/machinery) in t
	var/obj/item/weapon/reagent_containers/food/F = locate(/obj/item/weapon/reagent_containers/food) in t
	var/obj/item/stack/sheet/S = locate(/obj/item/stack/sheet) in t

	var/obj/structure/cable/C = locate(/obj/structure/cable) in myTurf
	var/obj/machinery/power/smes/SM = locate(/obj/machinery/power/smes) in t
	var/obj/machinery/power/apc/A = locate(/obj/machinery/power/apc) in t

	var/mob/living/carbon/human/H = locate(/mob/living/carbon/human) in t

	if(t)
		if(C)
			var/drain = C.powernet.avail
			C.powernet.load += drain
			powerStored += drain
			updateDamage()

		if(SM)
			if(SM.charge)
				var/drain = SM.charge
				SM.charge -= drain
				powerStored += drain
				updateDamage()

		if(A)
			if(A.cell && A.cell.charge)
				var/drain = A.cell.charge
				A.cell.charge -= drain
				powerStored += drain
				updateDamage()

		if(M)
			M.emagged = 1

		if(S)
			upgradeLevel = min(5,upgradeLevel + 0.1)
			qdel(S)
			update_icon()

		if(F)
			qdel(F)
			var/mob/living/simple_animal/hostile/nanoswarm/NS = new /mob/living/simple_animal/hostile/nanoswarm(t)
			var/shared = powerStored/(max(0.1,2-upgradeLevel))
			powerStored -= shared
			NS.powerStored += shared

		if(H)
			var/injectResist = 0
			if(H.head && H.head.flags & THICKMATERIAL)
				injectResist++
			if(H.wear_suit && H.wear_suit.flags & THICKMATERIAL)
				injectResist++
			if(injectResist < 2)
				H << "<span class='danger'>You feel a thousand tiny little pricks sizzle across your skin</span>"
				H.AddDisease(new /datum/disease/transformation/robot/evil)

		if(istype(t,/turf/simulated/floor) || istype(t,/turf/space))
			if(istype(t,/turf/simulated/floor/nano))
				Goto(get_step_away(src,t,7),0,0)
			else
				t.ChangeTurf(floorConvert)
				Goto(t,0,0)

		if(istype(t,/turf/simulated/wall))
			t.ChangeTurf(wallConvert)



//nanoswarm hives
/obj/structure/nanohive
	name = "nanohive"
	desc = "The surface crawls with a sickly, silver sheen"
	icon_state = "nanohive"
	var/maxBots = 5
	var/curBots = 0
	var/interval = 30
	var/health = 100

/obj/structure/nanohive/proc/spawnNano()
	if(health <= 0)
		return
	else
		for(var/turf/T in oview(1))
			if(curBots < maxBots)
				curBots++
				new /mob/living/simple_animal/hostile/nanoswarm(T)
		spawn(interval)
			spawnNano()

/obj/structure/nanohive/New()
	spawn(interval)
		spawnNano()

/obj/structure/nanohive/emp_act(var/severity)
	if(health > 0)
		health -= severity*10
	if(health <= 0)
		icon_state = "nanohive_broken"