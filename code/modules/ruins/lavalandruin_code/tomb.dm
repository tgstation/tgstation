//ENEMIES//

/mob/living/simple_animal/hostile/cryptguard
	name = "statue"
	desc = "An incredibly lifelike stone carving depicting a brave warrior."
	icon = 'icons/obj/statue.dmi'
	icon_state = "crypt-0"
	icon_living = "crypt-0"
	icon_dead = "crypt-0"
	speak_emote = list("says")
	health = 100
	maxHealth = 100
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes"
	deathmessage = "crumbles to dust."
	AIStatus = AI_OFF
	status_flags = 0
	anchored = TRUE
	a_intent = INTENT_HARM
	wander = FALSE
	del_on_death = 1
	loot = list(/obj/mecha/combat/stone/loaded)
	var/woke = FALSE //cannot take damage if true
	var/swiping = FALSE
	var/powerful = FALSE //the boss can move while setting up attacks, the small ones cannot

/mob/living/simple_animal/hostile/cryptguard/AttackingTarget()
	if(swiping == TRUE)
		if(client)
			to_chat(src, "<span class='warning'>You're already attacking!</span>")
		return
	swiping = TRUE
	//putting vars up here since all attacks are done for each direction, saves me from a mindflood//
	var/turf/T = get_turf(target)
	var/turf/Tstep = get_step(T, dir)
	var/turf/Tstepstep = get_step(Tstep, dir)
	var/turf/src_turf = get_turf(src)
	var/dir_to_target = get_dir(src_turf, get_turf(target))
	var/angle1 = 0
	var/angle2 = -45
	var/angle3 = 45
	var/turf/Tcleave1 = get_step(src_turf, turn(dir_to_target, angle1))
	var/turf/Tcleave2 = get_step(src_turf, turn(dir_to_target, angle2))
	var/turf/Tcleave3 = get_step(src_turf, turn(dir_to_target, angle3))
	var/atktype = pick("cleave", "lunge", "energy blast", "curb stomp")
	if(target.stat == UNCONSCIOUS)
		atktype = "curb stomp"
	if(atktype == "energy blast")
		visible_message("<span class='warning'>[src] begins to shudder...</span>", "<span class='notice'>You ready a blast of necropolis magic...</span>")
	else
		visible_message("<span class='warning'>[src] readies a [atktype]...</span>", "<span class='notice'>You begin to ready a [atktype]...</span>")
	if(atktype == "cleave" || atktype == "lunge")
		var/atkexecuted = "[atktype][dir]"
	else
		atkexecuted = "[atktype]"
	switch(atkexecuted)
		if("lunge1")
			new /obj/effect/temp_visual/attackwarn(T, src, 0, 1)
			new /obj/effect/temp_visual/attackwarn(Tstep, src, 0, 2)
			new /obj/effect/temp_visual/attackwarn(Tstepstep, src, 0, 3)
		if("lunge2")
			new /obj/effect/temp_visual/attackwarn(T, src, 0, -1)
			new /obj/effect/temp_visual/attackwarn(Tstep, src, 0, -2)
			new /obj/effect/temp_visual/attackwarn(Tstepstep, src, 0, -3)
		if("lunge4")
			new /obj/effect/temp_visual/attackwarn(T, src, -1, 0)
			new /obj/effect/temp_visual/attackwarn(Tstep, src, -2, 0)
			new /obj/effect/temp_visual/attackwarn(Tstepstep, src, -3, 0)
		if("lunge8")
			new /obj/effect/temp_visual/attackwarn(T, src, 1, 0)
			new /obj/effect/temp_visual/attackwarn(Tstep, src, 2, 0)
			new /obj/effect/temp_visual/attackwarn(Tstepstep, src, 3, 0)
		if("cleave1")
			new /obj/effect/temp_visual/attackwarn(Tcleave, src, 0, 1)
			new /obj/effect/temp_visual/attackwarn(Tcleave2, src, 1, 1)
			new /obj/effect/temp_visual/attackwarn(Tcleave3, src, -1, 1)
		if("cleave2")
			new /obj/effect/temp_visual/attackwarn(Tcleave, src, 0, -1)
			new /obj/effect/temp_visual/attackwarn(Tcleave2, src, 1, -1)
			new /obj/effect/temp_visual/attackwarn(Tcleave3, src, -1, -1)
		if("cleave4")
			new /obj/effect/temp_visual/attackwarn(Tcleave, src, -1, 0)
			new /obj/effect/temp_visual/attackwarn(Tcleave2, src, -1, 1)
			new /obj/effect/temp_visual/attackwarn(Tcleave3, src, -1, -1)
		if("cleave8")
			new /obj/effect/temp_visual/attackwarn(Tcleave, src, 1, 0)
			new /obj/effect/temp_visual/attackwarn(Tcleave2, src, 1, 1)
			new /obj/effect/temp_visual/attackwarn(Tcleave3, src, 1, -1)
		if("energy blast")
			new /obj/effect/temp_visual/attackwarn(Tcleave, src, 1, 0)
			new /obj/effect/temp_visual/attackwarn(Tcleave, src, 1, 0)
			new /obj/effect/temp_visual/attackwarn(Tcleave, src, 1, 0)
			new /obj/effect/temp_visual/attackwarn(Tcleave, src, 1, 0)
		if("curb stomp")
			forceMove(target)
			/obj/effect/temp_visual/attackwarn/execute(T, src, 0, 0)

/obj/effect/temp_visual/attackwarn
	name = "incoming attack"
	desc = "a deer in headlights..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "attackarea"
	layer = BELOW_MOB_LAYER
	duration = 7
	var/hit_damage = 30
	var/mob/living/simple_animal/hostile/cryptguard/createdby
	var/offset_x = 0
	var/offset_y = 0
	var/datum/component/mobhook

/obj/effect/temp_visual/attackwarn/fast
	duration = 4

/obj/effect/temp_visual/attackwarn/slow
	duration = 12
	hit_damage = 50

/obj/effect/temp_visual/attackwarn/execute
	duration = 25
	hit_damage = 100

/obj/effect/temp_visual/attackwarn/execute/Destroy()
	QDEL_NULL(mobhook)
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(istype(L, /mob/living/simple_animal/hostile/cryptguard))
			continue //don't kys!
		to_chat(L, "<span class='danger'>You are curb stomped by [createdby]!</span>")
		L.adjustBruteLoss(hit_damage)
		QDEL_NULL(L) //remind me to not do this
	createdby.swiping = FALSE

/obj/effect/temp_visual/attackwarn/Initialize(mapload, createdby, offset_x, offset_y)
	..(mapload)
	src.createdby = createdby
	src.offset_x = offset_x
	src.offset_y = offset_y
	mobhook = src.createdby.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED), CALLBACK(src, .proc/on_mob_move))

/obj/effect/temp_visual/attackwarn/proc/on_mob_move()
	var/target_turf = get_turf(locate(created_by.x + offset_x, created_by.y + offset_y))
	if(istype(target_turf, /turf))
		forceMove(target_turf)

/obj/effect/temp_visual/attackwarn/Destroy()
	QDEL_NULL(mobhook)
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		to_chat(L, "<span class='danger'>You are hit by [createdby]'s greatsword!</span>")
		L.adjustBruteLoss(hit_damage)
	createdby.swiping = FALSE
	..()
//hit

/mob/living/simple_animal/hostile/cryptguard/Move()
	if(swiping == TRUE)
		if(client)
			to_chat(src, "<span class='warning'>You can't move while swinging a sword like this!</span>")
		return
	..()

/mob/living/simple_animal/hostile/cryptguard/proc/awaken()
	woke = TRUE
	if(istype(src, /mob/living/simple_animal/hostile/cryptguard/leader))
		name = "\improper Antikythera"
	else
		name = "crypt guardian"
		icon_state = "crypt-1"
	toggle_ai(AI_ON)

/mob/living/simple_animal/hostile/cryptguard/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(woke == FALSE)
		return
	..()

/mob/living/simple_animal/hostile/cryptguard/sentience_act()
	awaken() //no infinite health sentient anything oh my god

/obj/effect/temp_visual/cryptguard_death
	name = "ghostly creature"
	desc = "there he goes!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost_yellow"
	duration = 30

/mob/living/simple_animal/hostile/cryptguard/leader
	name = "giant statue"
	desc = "An incredibly lifelike stone carving depicting a valiant hero."
	powerful = TRUE
	sentience_type = SENTIENCE_BOSS
	loot = list(/obj/mecha/combat/stone/loaded)
	var/list/guards = list()

/mob/living/simple_animal/hostile/cryptguard/leader/Initialize()
	. = ..()
	for(var/mob/living/simple_animal/hostile/cryptguard/statues in orange(10, get_turf(src)))
		guards += statues

/mob/living/simple_animal/hostile/cryptguard/leader/AttackingTarget()
	swiping = TRUE
	var/turf/T = get_turf(target)
	var/turf/src_turf = get_turf(src)
	var/dir_to_target = get_dir(src_turf, get_turf(target))
	var/static/list/front_angles = list(0, -45, 45)
	var/static/list/side_angles = list(90, -90)
	var/static/list/back_angles = list(180, 135, -135)
	visible_message("<span class='warning'>[src] unleashes a flurry of blades!</span>", "<span class='notice'>You begin to unleash a flurry of blades!</span>")
	var/atktype = pick("cleave", "lunge", "whirlwind", "bdance", "surge")//well good luck
	switch(atktype)
		if("lunge")//attacks 3 tiles forward
			var/turf/Tstep = get_step(T, dir)
			var/turf/Tstepstep = get_step(Tstep, dir)
			new /obj/effect/temp_visual/attackwarn(T, src)
			new /obj/effect/temp_visual/attackwarn(Tstep, src)
			new /obj/effect/temp_visual/attackwarn(Tstepstep, src)
		if("cleave") //attacks 3 in front
			for(var/i in front_angles)
				var/turf/Tcleave = get_step(src_turf, turn(dir_to_target, i))
				new /obj/effect/temp_visual/attackwarn(Tcleave, src)
		if("whirlwind") //attacks angles except diagonals
			var/static/list/whirlwind_angles = list(0, -90, 90, 180)
			for(var/i in whirlwind_angles)
				var/turf/Twhirl = get_step(src_turf, turn(dir_to_target, i))
				new /obj/effect/temp_visual/attackwarn(Twhirl, src)
		if("bdance") //attacks diagonals
			var/static/list/bdance_angles = list(45, -45, 135, -135)
		if("surge") //fast attacks in the front, medium on sides and slow in the back.
			for(var/i in front_angles)
				var/turf/Tsurge1 = get_step(src_turf, turn(dir_to_target, i))
				new /obj/effect/temp_visual/attackwarn/fast(Tsurge1, src)
			for(var/i in side_angles)
				var/turf/Tsurge2 = get_step(src_turf, turn(dir_to_target, i))
				new /obj/effect/temp_visual/attackwarn(Tsurge2, src)
			for(var/i in back_angles)
				var/turf/Tsurge3 = get_step(src_turf, turn(dir_to_target, i))
				new /obj/effect/temp_visual/attackwarn/slow(Tsurge3, src)

/mob/living/simple_animal/hostile/cryptguard/leader/attack_hand(mob/user)
	if(woke)
		return
	if(user.a_intent == INTENT_HARM)
		return
	var/isleep = TRUE
	var/finalboss = TRUE
	for(var/mob/living/simple_animal/hostile/cryptguard/goon in guards)
		if(goon.woke == TRUE && goon.stat != DEAD)//if any of them are woke but not dead, then they don't need to be awakened. just return.
			isleep = FALSE
		if(goon.stat != DEAD)//if any of them are alive, then awaken them instead.
			finalboss = FALSE
	if(isleep == FALSE)
		return
	if(finalboss == FALSE)
		say("Welcome... To your tomb.")
		sleep(5)
		var/turf/T = get_turf(target)
		var/turf/Tstep = get_step(T, dir)
		forceMove(Tstep)
		for(var/mob/living/simple_animal/hostile/cryptguard/goonstve in guards)
			goonstve.say("Defend... the treasure...")
			goonstve.awaken()
	else
		say("ENOUGH OF YOUR VANDALISM!!")
		sleep(10)
		say("YOU SHALL PAY... FOR YOUR INSOLENCE!!")
		awaken()

//LOOT (THE MECH)//

/obj/mecha/combat/stone
	desc = "The guardians of the necropolis, before the dragons arrived."
	name = "\improper Antikythera"
	icon_state = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list("melee" = 70, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100) //durand stats, but much higher melee and lower bullet and laser
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand

/obj/mecha/combat/stone/loaded/Initialize()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	ME.attach(src)

///replace with sword, and add it to the mech

//OTHER GARBAGE//

/obj/structure/sign/mural1
	name = "dusty mural"
	desc = "Guardians of the necropolis, on an old mural."
	max_integrity = 500

/obj/structure/sign/mural1/top
	icon_state = "mural1-top"

/obj/structure/sign/mural1/bot
	icon_state = "mural1-bot"

/obj/structure/sign/mural2
	name = "dusty mural"
	desc = "Guardians of the necropolis?"
	max_integrity = 500

/obj/structure/sign/mural2/top
	icon_state = "mural2-top"

/obj/structure/sign/mural2/bot
	icon_state = "mural2-bot"

