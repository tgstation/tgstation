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

	var/focus

	harm_intent_damage = 15
	melee_damage_lower = 1
	melee_damage_upper = 1

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	var/devourChance = 5

	var/powerStored = 0
	var/totalPowerTaken = 0
	var/upgradeLevel = 0
	var/floorConvert = /turf/simulated/floor/nano
	var/wallConvert = /turf/simulated/wall/nano

/mob/living/simple_animal/hostile/nanoswarm/emp_act(var/severity)
	health = 0
	update_icon()

/mob/living/simple_animal/hostile/nanoswarm/fire_act()
	health = max(0,health - 25)
	powerStored = max(0,powerStored - 500)
	upgradeLevel = max(0,upgradeLevel - 1)
	updateDamage()
	update_icon()

/mob/living/simple_animal/hostile/nanoswarm/ex_act(var/severity, var/target)
	health = max(0,health - severity*10)
	..()

/mob/living/simple_animal/hostile/nanoswarm/proc/update_icon()
	..()
	if(health > 0)
		icon_state = "nanoswarm[round(upgradeLevel)]"
		icon_living = "nanoswarm[round(upgradeLevel)]"
	else
		icon_state = "nanoswarm[round(upgradeLevel)]_dead"

/mob/living/simple_animal/hostile/nanoswarm/proc/updateDamage()
	melee_damage_lower = min(50,(initial(melee_damage_lower) + (totalPowerTaken/1000)*upgradeLevel)/2)
	melee_damage_upper = min(100,initial(melee_damage_upper) + (totalPowerTaken/1000)*upgradeLevel)
	devourChance = min(100,initial(devourChance) + (powerStored/5000)+upgradeLevel*5)

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
			totalPowerTaken += drain
			updateDamage()

		if(SM)
			if(SM.charge)
				var/drain = SM.charge
				SM.charge -= drain
				powerStored += drain
				totalPowerTaken += drain
				updateDamage()

		if(A)
			if(A.cell && A.cell.charge)
				var/drain = A.cell.charge
				A.cell.charge -= drain
				powerStored += drain
				totalPowerTaken += drain
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
			NS.totalPowerTaken += shared

		if(H)
			var/injectResist = 0
			if(H.head && H.head.flags & THICKMATERIAL)
				injectResist++
			if(H.wear_suit && H.wear_suit.flags & THICKMATERIAL)
				injectResist++
			if(injectResist < 2)
				if(prob(devourChance))
					H << "<span class='danger'>You feel a thousand tiny little pricks sizzle across your skin</span>"
					new /mob/living/simple_animal/hostile/syndicate/ranged/nanobot(get_turf(H))
					H.gib()

		if(focus)
			Goto(get_turf(focus),0,0)
			if(get_dist(src,focus) <= 3)
				focus = null
		else
			if(istype(t,/turf/simulated/floor) || istype(t,/turf/space))
				if(istype(t,/turf/simulated/floor/nano))
					Goto(get_step_away(src,t,7),0,0)
				else
					t.ChangeTurf(floorConvert)
					Goto(t,0,0)
			if(istype(t,/turf/simulated/wall))
				t.ChangeTurf(wallConvert)


//nanoswarm zombies
/mob/living/simple_animal/hostile/syndicate/ranged/nanobot
	name = "Nano-cyborg"
	desc = "An unholy fusion of flesh and machine. You can see a pained, saddened look in the person's eyes"
	icon = 'icons/mob/robots.dmi'
	icon_living = "robot_old"
	icon_state = "robot_old"
	icon_dead = "remainsrobot"

/mob/living/simple_animal/hostile/syndicate/ranged/nanobot/New(loc)
	..()
	var/chosen = pick("captainborg","ceborg","hosborg","cmoborg","ceborg","rdborg")
	icon_state = chosen
	icon_living = chosen

//nanoswarm hives
/obj/structure/nanohive
	name = "nanohive"
	desc = "The surface crawls with a sickly, silver sheen."
	icon_state = "nanohive"
	var/mob/camera/nano/myCamera = null
	var/list/hiveBots = list()
	var/maxBots = 5
	var/curBots = 0
	var/interval = 30
	var/health = 100

/obj/structure/nanohive/nanohiveP
	name = "giga-nanohive"
	desc = "The surface crawls with a sickly, silver sheen. This hive buzzes with an almost palpable power."
	icon_state = "nanohive_p"
	maxBots = 15
	interval = 120
	health = 1000

/obj/structure/nanohive/proc/spawnNano()
	updateCount()
	if(health <= 0)
		return
	else
		doSpawnNano()
		spawn(interval)
			spawnNano()

/obj/structure/nanohive/proc/doSpawnNano()
	updateCount()
	if(health <= 0)
		return
	for(var/turf/T in oview(src,1))
		if(curBots < maxBots)
			curBots++
			hiveBots += new /mob/living/simple_animal/hostile/nanoswarm(T)
		return

/obj/structure/nanohive/proc/updateCount()
	for(var/mob/living/simple_animal/hostile/nanoswarm/NS in hiveBots)
		if(NS.health <= 0)
			hiveBots -= NS

/obj/structure/nanohive/New()
	spawn(interval)
		spawnNano()

/obj/structure/nanohive/fire_act()
	health = max(0,health - 25)

/obj/structure/nanohive/emp_act(var/severity)
	if(health > 0)
		health -= max(0,severity*10)
	if(health <= 0)
		icon_state = "[initial(icon_state)]_broken"

/obj/structure/nanohive/ex_act(var/severity, var/target)
	health = max(0,health - severity*10)
	..()

/obj/structure/nanohive/proc/create_hive(var/client/new_hive)
	if(myCamera)
		qdel(myCamera)

	var/client/C = null
	var/list/candidates = list()
	world << "Making new hive"
	if(!new_hive)
		world << "No given hive, locating.."
		candidates = get_candidates(BE_NANO)
		world << "[candidates.len] candidates"
		if(candidates.len)
			C = pick(candidates)
			world << "Picked [C]"
	else
		world << "[C] was given"
		C = new_hive

	if(C)
		world << "Creating eye.."
		var/mob/camera/nano/B = new(get_turf(src))
		world << "Made [B]"
		B.key = C.key
		B.myHive = src
		src.myCamera = B
		world << "[B] stats are key: [B.key], hive: [B.myHive], my camera [src.myCamera]"
		return 1
	return 0

/mob/camera/nano
	name = "Nanoswarm Overlord"
	real_name = "Nanoswarm Overlord"
	icon = 'icons/obj/structures.dmi'
	icon_state = "nanocursor"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	faction = list("nano")

	var/obj/structure/nanohive/myHive
	var/heldPower = 10000
	var/ghostimage = null

/mob/camera/nano/New()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	ghostimage = image(src.icon,src,src.icon_state)
	ghost_darkness_images |= ghostimage //so ghosts can see the blob cursor when they disable darkness
	updateallghostimages()
	..()

/mob/camera/nano/Life()
	updatePower()
	heldPower += 10
	if(!myHive)
		qdel(src)
	..()

/mob/camera/nano/Destroy()
	if (ghostimage)
		ghost_darkness_images -= ghostimage
		qdel(ghostimage)
		ghostimage = null;
		updateallghostimages()
	..()

/mob/camera/nano/Login()
	..()
	sync_mind()
	src << "<span class='notice'>You are an overlord!</span>"
	src << "You are an overlord of the Nanoswarm. You must ensure the absolute and utter annihilation of all living flesh-bags."
	src << "The Nanoswarm has granted you the following powers:"
	src << "<b>Spawn Nanoswarm (2500p)</b> will birth a Nanoswarm immediately from your hive. Nanoswarms naturally replenish over time."
	src << "<b>Bolster (10000p)</b> will imbue your children with stronger power, increasing their damage and survivability."
	src << "<b>Psychic Screech (1000p)</b> causes your hive to emit a psychic screech, extremely painful to all living beings nearby."
	src << "<b>Call to Arms (100p)</b> summons all nanoswarms to return to the hive, and protect the overlord."
	src << "<b>Call to Point (100p)</b> summons all nanoswarms to your cursor."

/mob/camera/nano/proc/checkAndConsume(var/amount)
	if(heldPower - amount > 0)
		heldPower -= amount
		return TRUE
	else
		src << "<span class='danger'>You do not have enough power to use this. (Need [amount].)</span>"
	return FALSE

/mob/camera/nano/verb/SpawnNanoswarm()
	set category = "Swarm"
	set name = "Spawn Nanoswarm (2500)"
	set desc = "Spawns a Swarm from your Hive."

	if(checkAndConsume(2500))
		myHive.doSpawnNano()

/mob/camera/nano/verb/Bolster()
	set category = "Swarm"
	set name = "Bolster Nanoswarm (10000)"
	set desc = "Empowers your Nanoswarm from your Hive."

	if(checkAndConsume(10000))
		var/divisor = myHive.hiveBots.len
		for(var/mob/living/simple_animal/hostile/nanoswarm/NS in myHive.hiveBots)
			NS.powerStored += 10000/divisor
			NS.upgradeLevel = min(5,NS.upgradeLevel + 1)
			NS.updateDamage()
			NS.update_icon()

/mob/camera/nano/verb/PsychicScreech()
	set category = "Swarm"
	set name = "Psychic Screech (1000)"
	set desc = "Emits a damaging, stunning Psychic Scream from your Hive."

	if(checkAndConsume(1000))
		playsound(myHive.loc, 'sound/hallucinations/wail.ogg', 50, 1, -1)
		for(var/mob/living/carbon/human/H in oview(myHive,5))
			if(!(H.head && H.head.flags & THICKMATERIAL)) // No head protection? eraser.gif
				H.Stun(2)
				H.Weaken(2)
				H.apply_effect(STUTTER, 2)

/mob/camera/nano/verb/CallHome()
	set category = "Swarm"
	set name = "Call to Arms (100)"
	set desc = "Calls your Swarm to your Hive."

	if(checkAndConsume(100))
		for(var/mob/living/simple_animal/hostile/nanoswarm/NS in myHive.hiveBots)
			NS.focus = get_turf(myHive)

/mob/camera/nano/verb/CallToMe()
	set category = "Swarm"
	set name = "Call to Point (100)"
	set desc = "Calls your Swarm to your Cursor."

	if(checkAndConsume(100))
		for(var/mob/living/simple_animal/hostile/nanoswarm/NS in myHive.hiveBots)
			NS.focus = get_turf(src)

/mob/camera/nano/say(var/message)
	return

/mob/camera/nano/emote(var/act,var/m_type=1,var/message = null)
	return

/mob/camera/nano/blob_act()
	return

/mob/camera/nano/proc/updatePower()
	for(var/mob/living/simple_animal/hostile/nanoswarm/NS in myHive.hiveBots)
		var/stored = NS.powerStored/2
		heldPower += stored
		NS.powerStored -= stored

/mob/camera/nano/Stat()
	..()
	if(statpanel("Status"))
		if(myHive)
			stat(null, "Hive Health: [myHive.health]")
		stat(null, "Consumed Power (p): [heldPower]")
		stat(null, "Minions: [myHive.curBots]/[myHive.maxBots]")

/mob/camera/nano/Move(var/NewLoc, var/Dir = 0)
	loc = NewLoc