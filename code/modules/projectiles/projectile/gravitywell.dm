/obj/item/projectile/gravitywell
	name = "gravity impulse"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "gravitywell"
	damage = 0
	nodamage = 1
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration = -1

/obj/item/projectile/gravitywell/bresenham_step(var/distA, var/distB, var/dA, var/dB)
	if(..())
		return 2
	else
		return 0

/obj/item/projectile/gravitywell/Bump(atom/A as mob|obj|turf|area)
	if(loc == target)
		spawnGravityWell()

	if(isliving(A))
		var/mob/living/M = A
		M.Weaken(5)

	forceMove(get_step(loc,dir))

	if(loc == target)
		spawnGravityWell()


/obj/item/projectile/gravitywell/proc/spawnGravityWell()
	kill_count = 0
	log_admin("\[[time_stamp()]\] <b>[key_name(firer)]</b> has created a gravity well at ([loc.x],[loc.y],[loc.z])")
	message_admins("\[[time_stamp()]\] <b>[key_name(firer)]</b> has created a gravity well at (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>([loc.x],[loc.y],[loc.z])</a>)", 1)

	new/obj/effect/overlay/gravitywell(loc)
	bullet_die()


/obj/item/projectile/gravitywell/bump_original_check()//so players can aim at floors
	if(!bumped)
		if(loc == get_turf(original))
			if(!(original in permutated))
				Bump(original)

/obj/item/projectile/gravitywell/cultify()
	return

/obj/item/projectile/gravitywell/singularity_act(var/current_size,var/obj/machinery/singularity/S)
	src.loc = S.loc
	spawnGravityWell()
	return

/obj/effect/overlay/gravitywell
	name = "gravity well"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "gravitywell_shadow"
	pixel_x = -64
	pixel_y = -64
	unacidable = 1
	density = 0
	layer = 2.1
	anchored = 1
	alpha = 255
	mouse_opacity = 0
	var/size = 2
	var/xp = 6
	var/xlevel = 4
	var/obj/effect/overlay/gravitygrid/GG = null

/obj/effect/overlay/gravitywell/New()
	..()
	GG = new(loc)
	playsound(loc, 'sound/weapons/emp.ogg', 75, 1)
	animate(GG, alpha = 255, time = 10, easing = SINE_EASING)
	spawn()
		Pulse()
	overlays += image(icon,"gravitywell_shadow",2.1)

/obj/effect/overlay/gravitywell/Destroy()
	if(GG)
		qdel(GG)
	..()

/obj/effect/overlay/gravitywell/proc/Pulse()
	xp--
	if(xp <= 0)
		xp = 6
		xlevel--
		if(xlevel <= -4)
			empulse(loc,size,size+2)
			if(locate(/obj/machinery/the_singularitygen/) in loc)
				new/obj/machinery/singularity(loc)//How evil can one man be?
			qdel(src)
			return
		else if(xlevel > 0)
			size++
			if(GG)
				GG.LevelUp()
				src.transform *= (size*2+1)/((size-1)*2+1)

	var/outter_size = round(size+1)
	for(var/atom/A in range(src,outter_size))
		var/dist = get_dist_euclidian(src,A)
		var/pull_force = size/max(1,round(dist))
		if(istype(A,/atom/movable) && (size >= 4) && (get_dist(src,A) == 1))
			A.singularity_pull(src, (pull_force * 3), 1)
			var/atom/movable/AM = A
			AM.forceMove(loc)//KATAMARI DAMACYYyyYYyyYY
		else if(get_dist(src,A) >= 1)
			if(dist <= size)
				A.singularity_pull(src, (pull_force * 3), 1)
				if(istype(A,/mob/living))
					var/mob/living/M = A
					M.take_overall_damage(5,0)
					to_chat(M, "<span class='warning'>The [src]'s tidal force rips your skin!</span>")

	for(var/mob/living/L in loc)//standing right in the center of the gravity well means double damage
		if((L.stat == DEAD) && prob(5))
			L.gib()
		L.take_overall_damage(3,0)//less brute damage in the center, but the radiations caused by singularity_pull make up for it.
		to_chat(L, "<span class='danger'>The [src]'s tidal force is crushing you!</span>")

	sleep(10)
	Pulse()

/obj/effect/overlay/gravitygrid
	name = "gravity well"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "gravitywell_white"
	pixel_x = -64
	pixel_y = -64
	unacidable = 1
	density = 0
	layer = 30
	anchored = 1
	color = "green"
	alpha = 0
	mouse_opacity = 0
	var/obj/effect/overlay/gravitygrid/GG = null
	var/size = 5

/obj/effect/overlay/gravitygrid/Destroy()
	if(GG)
		qdel(GG)//NO RE
	..()

/obj/effect/overlay/gravitygrid/proc/LevelUp()
	if(!GG)
		GG = new(loc)
		GG.layer = layer-1
		GG.size = size+2
		GG.alpha = 255
		GG.transform *= size/5

		var/matrix/M = matrix()
		M.Scale((size/5)*(GG.size/size),(size/5)*(GG.size/size))
		animate(GG, transform = M, time = 10)
	else
		GG.LevelUp()

	var/newcolor = null
	switch(color)
		if("#00c000")
			newcolor = "#ffa500"
		if("#ffa500")
			newcolor = "#ff0000"
		else
			newcolor = "#800080"

	animate(src, color = newcolor, time = 10)
