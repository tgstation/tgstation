/mob/living/simple_animal/hostile/megafauna/dragon
	name = "ash drake"
	desc = "Guardians of the necropolis."
	health = 2500
	maxHealth = 2500
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/dragon.dmi'
	faction = list("mining")
	speak_emote = list("roars")
	luminosity = 3
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -16
	aggro_vision_range = 18
	idle_vision_range = 5
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/weapon/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)
	var/anger_modifier = 0
	var/obj/item/device/gps/internal
	var/swooping = 0
	var/swoop_cooldown = 0
	deathmessage = "collapes into a pile of bones, it's flesh sloughing away."
	death_sound = 'sound/magic/demon_dies.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)

/mob/living/simple_animal/hostile/megafauna/dragon/New()
	..()
	internal = new/obj/item/device/gps/internal/dragon(src)

/mob/living/simple_animal/hostile/megafauna/dragon/AttackingTarget()
	if(swooping)
		return
	else
		..()
		if(isliving(target))
			var/mob/living/L = target
			if(L.stat == DEAD)
				L.gib()
				visible_message("<span class='danger'>[src] devours [L]!</span>")
				src << "<span class='userdanger'>You feast on [L], restoring your health!</span>"
				adjustBruteLoss(-L.maxHealth)

/mob/living/simple_animal/hostile/megafauna/dragon/Process_Spacemove(movement_dir = 0)
	return 1

/obj/effect/overlay/temp/fireball
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "fireball"
	name = "fireball"
	desc = "Get out of the way!"
	layer = 6
	randomdir = 0
	duration = 10
	pixel_z = 500

/obj/effect/overlay/temp/target
	icon = 'icons/mob/actions.dmi'
	icon_state = "sniper_zoom"
	layer = MOB_LAYER - 0.1
	luminosity = 2
	duration = 10

/obj/effect/overlay/temp/dragon_swoop
	name = "certain death"
	desc = "Don't just stand there, move!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "rune_large"
	layer = MOB_LAYER - 0.1
	pixel_x = -32
	pixel_y = -32
	color = "#FF0000"
	duration = 10

/obj/effect/overlay/temp/target/ex_act()
	return

/obj/effect/overlay/temp/target/New()
	..()
	spawn()
		var/turf/T = get_turf(src)
		playsound(get_turf(src),'sound/magic/Fireball.ogg', 200, 1)
		var/obj/effect/overlay/temp/fireball/F = new(src.loc)
		animate(F, pixel_z = 0, time = 12)
		sleep(12)
		explosion(T, 0, 0, 1, 0, 0, 0, 1)
		qdel(F)
		qdel(src)

/mob/living/simple_animal/hostile/megafauna/dragon/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + ranged_cooldown_time

	if(prob(15 + anger_modifier) && !client)
		if(health < maxHealth/2)
			swoop_attack(1)
		else
			fire_rain()

	else if(prob(10+anger_modifier) && !client && !swooping)
		if(health > maxHealth/2)
			swoop_attack()
		else
			swoop_attack()
			swoop_attack()
			swoop_attack()
	else
		fire_walls()

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_rain()
	visible_message("<span class='danger'>Fire rains from the sky!</span>")
	for(var/turf/turf in range(12,get_turf(src)))
		if(prob(10))
			new /obj/effect/overlay/temp/target(turf)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_walls()
	var/list/attack_dirs = list(NORTH,EAST,SOUTH,WEST)
	if(prob(50))
		attack_dirs = list(NORTH,WEST,SOUTH,EAST)
	playsound(get_turf(src),'sound/magic/Fireball.ogg', 200, 1)

	for(var/d in attack_dirs)
		spawn(0)
			var/turf/E = get_edge_target_turf(src, d)
			var/range = 10
			for(var/turf/open/J in getline(src,E))
				if(!range)
					break
				range--
				PoolOrNew(/obj/effect/hotspot,J)
				J.hotspot_expose(700,50,1)
				for(var/mob/living/L in J)
					if(L != src)
						L.adjustFireLoss(20)
						L << "<span class='danger'>You're hit by the drake's fire breath!</span>"
				sleep(1)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/swoop_attack(fire_rain = 0, atom/movable/manual_target)
	if(stat)
		return
	swoop_cooldown = world.time + 200
	var/swoop_target
	if(manual_target)
		swoop_target = manual_target
	else
		swoop_target = target
	stop_automated_movement = TRUE
	swooping = 1
	icon_state = "swoop"
	visible_message("<span class='danger'>[src] swoops up high!</span>")
	if(prob(50))
		animate(src, pixel_x = 500, pixel_z = 500, time = 10)
	else
		animate(src, pixel_x = -500, pixel_z = 500, time = 10)
	sleep(30)

	var/turf/tturf
	if(fire_rain)
		fire_rain()

	icon_state = "dragon"
	if(swoop_target)
		tturf = get_turf(swoop_target)
	else
		tturf = get_turf(src)
	src.loc = tturf
	new/obj/effect/overlay/temp/dragon_swoop(tturf)
	animate(src, pixel_x = 0, pixel_z = 0, time = 10)
	sleep(10)
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 200, 1)
	for(var/mob/living/L in range(1,tturf))
		if(L == src)
			continue
		if(L.stat)
			visible_message("<span class='danger'>[src] slams down on [L], crushing them!</span>")
			L.gib()
		else
			var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
			L.adjustBruteLoss(75)
			L.throw_at_fast(throwtarget)
			visible_message("<span class='danger'>[L] is thrown clear of [src]!</span>")
	for(var/mob/M in range(7,src))
		shake_camera(M, 15, 1)

	stop_automated_movement = FALSE
	swooping = 0
	density = 1

/mob/living/simple_animal/hostile/megafauna/dragon/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(swoop_cooldown >= world.time)
		src << "You need to wait 20 seconds between swoop attacks!"
		return
	swoop_attack(1, A)


/obj/item/device/gps/internal/dragon
	icon_state = null
	gpstag = "Fiery Signal"
	desc = "Here there be dragons."
	invisibility = 100


//The part you've all been waiting for: Loot

/obj/item/weapon/melee/ghost_sword
	name = "spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon_state = "cultblade"
	item_state = "cultblade"
	flags = CONDUCT
	sharpness = IS_SHARP
	w_class = 4
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
	var/summon_cooldown = 0

/obj/item/weapon/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		user << "You just recently called out for aid. You don't want to annoy the spirits."
		return
	user << "You call out for aid, attempting to summon spirits to your side."
	notify_ghosts("[user] is raising their [src], calling for your help!", source = user)
	summon_cooldown = world.time + 600

/obj/item/weapon/melee/ghost_sword/proc/ghost_check(mob/user)
	var/ghost_counter = 0
	for(var/mob/dead/observer/G in dead_mob_list)
		if(G.orbiting == user)
			ghost_counter++
			G.invisibility = 0
			spawn(30)
				G.invisibility = initial(G.invisibility)
	return ghost_counter

/obj/item/weapon/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check(user)

	force = Clamp((ghost_counter * 4), 0, 75)
	user.visible_message("<span class='danger'>[user] strikes with the force of [ghost_counter] vengeful spirits!</span>")
	..()

/obj/item/weapon/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	var/ghost_counter = ghost_check(owner)
	final_block_chance += Clamp((ghost_counter * 5), 0, 75)
	owner.visible_message("<span class='danger'>[owner] is protected by a ring of [ghost_counter] ghosts!</span>")
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/lesser
	name = "lesser ash drake"
	maxHealth = 750
	health = 750
	melee_damage_upper = 30
	melee_damage_lower = 30
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	loot = list()

//Blood

/obj/item/weapon/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/weapon/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	var/random = rand(1,3)

	switch(random)
		if(1)
			user << "<span class='danger'>Other than tasting terrible, nothing really happens.</span>"
		if(2)
			user << "<span class='danger'>Your flesh begins to melt! Miraculously, you seem fine otherwise.</span>"
			H.set_species(/datum/species/skeleton)
		if(3)
			user << "<span class='danger'>You don't feel so good...</span>"
			H.ForceContractDisease(new /datum/disease/transformation/dragon(0))
	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)

/datum/disease/transformation/dragon
	name = "dragon transformation"
	cure_text = "nothing"
	cures = list("adminordrazine")
	agent = "dragon's blood"
	desc = "What do dragons have to do with Space Station 13?"
	stage_prob = 20
	severity = BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your bones ache.")
	stage2	= list("Your skin feels scaley.")
	stage3	= list("<span class='danger'>You have an overwhelming urge to terrorize some peasants.</span>", "<span class='danger'>Your teeth feel sharper.</span>")
	stage4	= list("<span class='danger'>Your blood burns.</span>")
	stage5	= list("<span class='danger'>You're a fucking dragon.</span>")
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser


//Lava Staff

/obj/item/weapon/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	item_state = "staffofstorms"
	w_class = 4
	force = 25
	damtype = BURN
	burn_state = LAVA_PROOF
	hitsound = 'sound/weapons/sear.ogg'
	var/lava_cooldown = 0

/obj/item/weapon/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(lava_cooldown > world.time)
		return
	if(target && istype(target, /turf/open))
		var/turf/open/O = target
		user.visible_message("<span class='danger'>[user] turns \the [O] into lava!</span>")
		O.ChangeTurf(/turf/open/floor/plating/lava/smooth)
		playsound(get_turf(src),'sound/magic/Fireball.ogg', 200, 1)
		lava_cooldown = world.time + 200

/obj/structure/closet/crate/necropolis/dragon
	name = "dragon chest"

/obj/structure/closet/crate/necropolis/dragon/New()
	..()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/weapon/melee/ghost_sword(src)
		if(2)
			new /obj/item/weapon/dragons_blood(src)
		if(3)
			new /obj/item/weapon/lava_staff(src)
