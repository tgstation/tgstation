/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	phase_type = PROJREACT_WINDOWS
	penetration = 5 //bullets can now by default move through up to 5 windows, or 2 reinforced windows, or 1 plasma window. (reinforced plasma windows still have enough dampening to completely block them)
	flag = "bullet"
	var/embed = 1

/obj/item/projectile/bullet/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		shake_camera(L, 3, 2)
		return 1
	return 0

/obj/item/projectile/bullet/dart
	name = "shotgun dart"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/bullet/weakbullet
	icon_state = "bbshell"
	damage = 10
	stun = 5
	weaken = 5
	embed = 0
/obj/item/projectile/bullet/weakbullet/booze
	on_hit(var/atom/target, var/blocked = 0)
		if(..(target, blocked))
			var/mob/living/M = target
			M.dizziness += 20
			M:slurring += 20
			M.confused += 20
			M.eye_blurry += 20
			M.drowsyness += 20
			if(M.dizziness <= 150)
				M.Dizzy(150)
				M.dizziness = 150
			for(var/datum/reagent/ethanol/A in M.reagents.reagent_list)
				M.paralysis += 2
				M.dizziness += 10
				M:slurring += 10
				M.confused += 10
				M.eye_blurry += 10
				M.drowsyness += 10
				A.volume += 5 //Because we can
				M.dizziness += 10
			return 1
		return 0

/obj/item/projectile/bullet/midbullet
	damage = 20
	stun = 5
	weaken = 5

/obj/item/projectile/bullet/midbullet/lawgiver
	damage = 10
	stun = 0
	weaken = 0

/obj/item/projectile/bullet/midbullet2
	damage = 25

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 20
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX


/obj/item/projectile/bullet/burstbullet//I think this one needs something for the on hit
	name = "exploding bullet"
	damage = 20


/obj/item/projectile/bullet/stunshot
	name = "stunshot"
	icon_state = "sshell"
	damage = 5
	stun = 10
	weaken = 10
	stutter = 10

/obj/item/projectile/bullet/a762
	damage = 25

#define SPUR_FULL_POWER 4
#define SPUR_HIGH_POWER 3
#define SPUR_MEDIUM_POWER 2
#define SPUR_LOW_POWER 1
#define SPUR_NO_POWER 0

/obj/item/projectile/spur
	name = "spur bullet"
	damage_type = BRUTE
	flag = "bullet"
	kill_count = 100
	layer = 13
	damage = 40
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "spur_high"
	animate_movement = 2
	custom_impact = 1
	linear_movement = 0

/obj/item/projectile/spur/OnFired()
	..()
	var/obj/item/weapon/gun/energy/polarstar/spur/quote = shot_from
	if(!quote || !istype(quote))
		return
	switch(quote.firelevel)
		if(SPUR_FULL_POWER,SPUR_HIGH_POWER)
			icon_state = "spur_high"
			damage = 40
			kill_count = 20
		if(SPUR_MEDIUM_POWER)
			icon_state = "spur_medium"
			damage = 30
			kill_count = 13
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			icon_state = "spur_low"
			damage = 20
			kill_count = 7

/obj/item/projectile/spur/polarstar
	name = "polar star bullet"
	damage = 20

/obj/item/projectile/spur/polarstar/OnFired()
	..()
	var/obj/item/weapon/gun/energy/polarstar/quote = shot_from
	if(!quote || !istype(quote))
		return
	switch(quote.firelevel)
		if(SPUR_FULL_POWER,SPUR_HIGH_POWER)
			icon_state = "spur_high"
			damage = 20
			kill_count = 20
		if(SPUR_MEDIUM_POWER)
			icon_state = "spur_medium"
			damage = 15
			kill_count = 13
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			icon_state = "spur_low"
			damage = 10
			kill_count = 7

/obj/item/projectile/spur/Bump(atom/A as mob|obj|turf|area)

	if(loc)
		var/turf/T = loc
		var/impact_icon = null
		var/impact_sound = null
		var/PixelX = 0
		var/PixelY = 0

		switch(get_dir(src,A))
			if(NORTH)
				PixelY = 16
			if(SOUTH)
				PixelY = -16
			if(EAST)
				PixelX = 16
			if(WEST)
				PixelX = -16
		if(ismob(A))
			impact_icon = "spur_3"
			impact_sound = 'sound/weapons/spur_hitmob.ogg'
		else
			impact_icon = "spur_1"
			impact_sound = 'sound/weapons/spur_hitwall.ogg'

		var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,impact_icon)
		impact.pixel_x = PixelX
		impact.pixel_y = PixelY
		impact.layer = 13
		T.overlays += impact
		spawn(3)
			T.overlays -= impact
		playsound(loc, impact_sound, 30, 1)


	if(istype(A, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = A
		M.GetDrilled()
	if(istype(A, /obj/structure/boulder))
		returnToPool(A)

	return ..()

/obj/item/projectile/spur/process_step()
	if(kill_count <= 0)
		if(loc)
			var/turf/T = loc
			var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,"spur_2")
			impact.layer = 13
			T.overlays += impact
			spawn(3)
				T.overlays -= impact
	..()

#undef SPUR_FULL_POWER
#undef SPUR_HIGH_POWER
#undef SPUR_MEDIUM_POWER
#undef SPUR_LOW_POWER
#undef SPUR_NO_POWER


/obj/item/projectile/bullet/gatling
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "minigun"
	damage = 30

/obj/item/projectile/bullet/osipr
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "osipr"
	damage = 50
	stun = 2
	weaken = 2
	destroy = 1
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = 1

/obj/item/projectile/bullet/hecate
	name = "high penetration bullet"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "hecate"
	damage = 101//you're going to crit, lad
	kill_count = 255//oh boy, we're crossing through the entire Z level!
	stun = 5
	weaken = 5
	stutter = 5
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration = 20//can hit 3 mobs at once, or go through a wall and hit 2 more mobs, or go through an rwall/blast door and hit 1 mob
	var/superspeed = 1

/obj/item/projectile/bullet/hecate/OnFired()
	..()
	for (var/mob/M in player_list)
		if(M && M.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && (M_turf.z == starting.z))
				M.playsound_local(starting, 'sound/weapons/hecate_fire_far.ogg', 25, 1)
	for (var/mob/living/carbon/human/H in range(src,1))
		if(!H.earprot())
			H.Weaken(2)
			H.Stun(2)
			H.ear_damage += rand(3, 5)
			H.ear_deaf = max(H.ear_deaf,15)
			to_chat(H, "<span class='warning'>Your ears ring!</span>")

/obj/item/projectile/bullet/hecate/bresenham_step(var/distA, var/distB, var/dA, var/dB)
	if(..())
		if(superspeed)
			superspeed = 0
			return 1
		else
			superspeed = 1
			return 0
	else
		return 0

/obj/item/projectile/bullet/a762x55
	damage = 65
	stun = 5
	weaken = 5
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS
	penetration = 10

/obj/item/projectile/bullet/beegun
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "beegun"
	damage = 5
	damage_type = TOX
	flag = "bio"

/obj/item/projectile/bullet/beegun/OnFired()
	..()
	playsound(starting, 'sound/effects/bees.ogg', 75, 1)

/obj/item/projectile/bullet/beegun/Bump(atom/A as mob|obj|turf|area)
	if (!A)
		return 0
	if((A == firer) && !reflected)
		loc = A.loc
		return 0
	if(bumped)
		return 0
	bumped = 1

	var/turf/T = get_turf(src)
	var/mob/living/simple_animal/bee/BEE = new(T)
	BEE.strength = 1
	BEE.toxic = 5
	BEE.mut = 2
	BEE.feral = 25
	BEE.icon_state = "bees1-feral"

	if(istype(A,/mob/living))
		var/mob/living/M = A
		visible_message("<span class='warning'>\the [M.name] is hit by \the [src.name] in the [parse_zone(def_zone)]!</span>")
		M.bullet_act(src, def_zone)
		admin_warn(M)
		BEE.loc = M.loc
		BEE.target = M
	else
		BEE.newTarget()
	bullet_die()

/obj/item/projectile/bullet/APS //Armor-piercing sabot round. Metal rods become this when fired from a railgun.
	name = "armor-piercing sabot round"
	icon_state = "APS"
	damage = 10 //Default damage, actual damage is determined per-shot in railgun.dm
	kill_count = 20 //This will be increased when the round is fired, based on the strength of the shot
	stun = 0
	weaken = 0
	stutter = 0
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration = 0 //By default. Higher-power shots will have penetration.
	var/superspeed = 0

/obj/item/projectile/bullet/APS/on_hit(var/atom/atarget, var/blocked = 0)
	if(istype(atarget, /mob/living) && damage == 200)
		var/mob/living/M = atarget
		M.gib()
	else ..()

/obj/item/projectile/bullet/APS/OnFired()
	..()
	if(damage >= 100)
		superspeed = 1
		for (var/mob/M in player_list)
			if(M && M.client)
				var/turf/M_turf = get_turf(M)
				if(M_turf && (M_turf.z == starting.z))
					M.playsound_local(starting, 'sound/weapons/hecate_fire_far.ogg', 25, 1)

/obj/item/projectile/bullet/APS/OnDeath()
	var/turf/T = get_turf(src)
	new /obj/item/stack/rods(T)

/obj/item/projectile/bullet/APS/bresenham_step(var/distA, var/distB, var/dA, var/dB)
	if(..())
		if(superspeed)
			superspeed = 0
			return 1
		else
			superspeed = 1
			return 0
	else
		return 0

/obj/item/projectile/bullet/stinger
	name = "alien stinger"
	damage = 5
	damage_type = TOX
	flag = "bio"

/obj/item/projectile/bullet/stinger/OnFired()
	var/choice = rand(1,4)
	switch(choice)
		if(1)
			stutter = 2
		if(2)
			eyeblur = 2
		if(3)
			agony = 2
		if(4)
			jittery = 2
	..()

/obj/item/projectile/bullet/vial
	name = "vial"
	icon_state = "vial"
	damage = 0
	penetration = 0
	embed = 0
	var/vial = null
	var/user = null
	var/hit_mob = 0

/obj/item/projectile/bullet/vial/Destroy()
	if(vial)
		qdel(vial)
		vial = null
	if(user)
		user = null

/obj/item/projectile/bullet/vial/on_hit(var/atom/atarget, var/blocked = 0)
	..()
	if(!user)
		return
	if(vial)
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/V = vial
		if(!V.is_open_container())
			V.flags |= OPENCONTAINER
		if(!V.is_empty())
			hit_mob = 1
			atarget.visible_message("<span class='warning'>\The [V] shatters, dousing [atarget] in its contents!</span>",
								"<span class='warning'>\The [V] shatters, dousing you in its contents!</span>")

		V.transfer(atarget, user, TRUE, FALSE, V.reagents.total_volume)

		qdel(V)
		vial = null
		user = null

/obj/item/projectile/bullet/vial/OnDeath()
	if(!hit_mob)
		src.visible_message("<span class='warning'>The vial shatters!</span>")
	playsound(get_turf(src), "shatter", 20, 1)

/obj/item/projectile/bullet/blastwave
	name = "blast wave"
	icon_state = null
	damage = 0
	penetration = -1
	embed = 0
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	var/heavy_damage_range = 0
	var/medium_damage_range = 0
	var/light_damage_range = 0

/obj/item/projectile/bullet/blastwave/OnFired()
	..()
	if(!heavy_damage_range || !medium_damage_range || !light_damage_range)
		bullet_die()
		return

/obj/item/projectile/bullet/blastwave/process_step()
	..()
	var/turf/T = get_turf(src)
	if(light_damage_range)
		if(medium_damage_range)
			if(heavy_damage_range)
				for(var/atom/movable/A in T.contents)
					if(!istype(A, /obj/item/weapon/organ/head))
						A.ex_act(1)
				T.ex_act(1)
				heavy_damage_range -= 1
			else
				for(var/atom/movable/A in T.contents)
					A.ex_act(2)
				T.ex_act(2)
				medium_damage_range -= 1
		else
			for(var/atom/movable/A in T.contents)
				A.ex_act(3)
			T.ex_act(3)
			light_damage_range -= 1
	else
		bullet_die()

/obj/item/projectile/bullet/blastwave/ex_act()
	return
