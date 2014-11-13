
/obj/structure/stool/bed/chair/vehicle/adminbus/verb/release_passengers()
	set name = "Release Passengers"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	switch(dir)
		if(SOUTH)
			for(var/i=1;i<=passengers.len;i++)
				var/atom/A = passengers[i]
				if(isliving(A))
					var/mob/living/L = A
					freed(L)
					L.x = x-1
				sleep(3)
		if(WEST)
			for(var/i=1;i<=passengers.len;i++)
				var/atom/A = passengers[i]
				if(isliving(A))
					var/mob/living/L = A
					freed(L)
					L.y = y+1
				sleep(3)
		if(NORTH)
			for(var/i=1;i<=passengers.len;i++)
				var/atom/A = passengers[i]
				if(isliving(A))
					var/mob/living/L = A
					freed(L)
					L.x = x+1
				sleep(3)
		if(EAST)
			for(var/i=1;i<=passengers.len;i++)
				var/atom/A = passengers[i]
				if(isliving(A))
					var/mob/living/L = A
					freed(L)
					L.y = y-1
				sleep(3)
	for(var/i=1;i<=passengers.len;i++)
		passengers[i] = null
	occupied_seats = 0
	return

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/freed(var/mob/living/L)
	L.buckled = null
	L.anchored = 0
	L.update_canmove()
	L.isolated = 0
	L.captured = 0
	L.pixel_x = 0
	L.pixel_y = 0

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/spawn_clowns()
	set name = "Spawn Clowns"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	var/turflist[] = list()
	for(var/turf/T in orange(src,1))
		if((T.density == 0) && (T!=src.loc))
			turflist += T

	var/invocnum = min(5, turflist.len)

	for(var/i=0;i<invocnum;i++)
		var/turf/T = pick(turflist)
		turflist -= T
		var/mob/living/simple_animal/hostile/retaliate/clown/admin/M = new /mob/living/simple_animal/hostile/retaliate/clown/admin(T)
		spawned_mobs += M
		T.beamin("clown")
		sleep(5)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/spawn_carps()
	set name = "Spawn Carps"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	var/turflist[] = list()
	for(var/turf/T in orange(src,1))
		if((T.density == 0) && (T!=src.loc))
			turflist += T

	var/invocnum = min(5, turflist.len)

	for(var/i=0;i<invocnum;i++)
		var/turf/T = pick(turflist)
		turflist -= T
		var/mob/living/simple_animal/hostile/carp/admin/M = new /mob/living/simple_animal/hostile/carp/admin(T)
		spawned_mobs += M
		T.beamin("carp")
		sleep(5)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/spawn_bears()
	set name = "Spawn Bears"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	var/turflist[] = list()
	for(var/turf/T in orange(src,1))
		if((T.density == 0) && (T!=src.loc))
			turflist += T

	var/invocnum = min(5, turflist.len)

	for(var/i=0;i<invocnum;i++)
		var/turf/T = pick(turflist)
		turflist -= T
		if(prob(10))
			var/mob/living/simple_animal/hostile/russian/admin/M = new /mob/living/simple_animal/hostile/russian/admin(T)
			spawned_mobs += M
		else
			var/mob/living/simple_animal/hostile/bear/admin/M = new /mob/living/simple_animal/hostile/bear/admin(T)
			spawned_mobs += M
		T.beamin("bear")
		sleep(5)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/spawn_trees()
	set name = "Spawn Trees"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	var/turflist[] = list()
	for(var/turf/T in range(src,1))
		if(((T.density == 0) && (T!=src.loc)) && (T!=src.loc))
			turflist += T

	var/invocnum = min(5, turflist.len)

	for(var/i=0;i<invocnum;i++)
		var/turf/T = pick(turflist)
		turflist -= T
		var/mob/living/simple_animal/hostile/tree/admin/M = new /mob/living/simple_animal/hostile/tree/admin(T)
		spawned_mobs += M
		T.beamin("tree")
		sleep(5)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/spawn_spiders()
	set name = "Spawn Spiders"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	var/turflist[] = list()
	for(var/turf/T in orange(src,1))
		if((T.density == 0) && (T!=src.loc))
			turflist += T

	var/invocnum = min(5, turflist.len)

	for(var/i=0;i<invocnum;i++)
		var/turf/T = pick(turflist)
		turflist -= T
		var/mob/living/simple_animal/hostile/giant_spider/admin/M = new /mob/living/simple_animal/hostile/giant_spider/admin(T)
		spawned_mobs += M
		T.beamin("spider")
		sleep(5)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/spawn_alien()
	set name = "Spawn Alien"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	var/turflist[] = list()
	for(var/turf/T in orange(src,1))
		if((T.density == 0) && (T!=src.loc))
			turflist += T

	var/turf/T = pick(turflist)
	if(T)
		turflist -= T
		var/mob/living/simple_animal/hostile/alien/queen/large/admin/M = new /mob/living/simple_animal/hostile/alien/queen/large/admin(T)
		spawned_mobs += M
		T.beamin("alien")

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/remove_mobs()
	set name = "Remove Mobs"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	for(var/mob/M in spawned_mobs)
		var/turf/T = get_turf(M)
		if(T)
			T.beamin("")
		del(M)
	spawned_mobs.len = 0

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/capture_singulo(var/obj/machinery/singularity/S)
	singulo = S
	S.on_capture()
	var/obj/structure/singulo_chain/parentchain = null
	var/obj/structure/singulo_chain/anchor/A = new /obj/structure/singulo_chain/anchor(loc)	//the anchor spawns first, on top of the bus,
	while(get_dist(A,S) > 0)																//it then travels toward the singulo while creating chains on its path,
		A.forceMove(get_step_towards(A,S))													//and parenting them together
		var/obj/structure/singulo_chain/C = new /obj/structure/singulo_chain(A.loc)
		chain += C
		C.dir = get_dir(src,S)
		if(!parentchain)
			chain_base = C
		else
			parentchain.child = C
		parentchain = C
	if(!parentchain)
		chain_base = A
	else
		parentchain.child = A
	chain += A
	A.target = singulo

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/throw_hookshot()
	set name = "Throw Hookshot"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(!hook)
		return

	hook = 0

	var/obj/structure/hookshot/claw/C = new/obj/structure/hookshot/claw(get_step(src,src.dir))
	hookshot += C
	C.abus = src

	var/obj/machinery/singularity/S = C.launchin(src.dir)
	if(S)
		for(var/atom/A in hookshot)
			qdel(A)
		hookshot.len = 0
		capture_singulo(S)
	else
		for(var/obj/structure/hookshot/A in hookshot)
			spawn()//so they all return at once
				A.returnin()

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/release_singulo()
	set name = "Release Singulo"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(singulo)
		var/obj/structure/hookshot/claw/A = new /obj/structure/hookshot/claw(loc)
		hookshot += A
		A.abus = src
		A.dropped = 1 //so it doesn't try to grab the singulo again as soon as it drops it.
		while(get_dist(A,singulo) > 0)
			A.forceMove(get_step_towards(A,singulo))
			var/obj/structure/hookshot/H = new /obj/structure/hookshot(A.loc)
			hookshot += H
			H.abus = src
			var/obj/structure/singulo_chain/C = locate(/obj/structure/singulo_chain) in H.loc
			if(C)
				H.dir = C.dir
		for(var/obj/structure/singulo_chain/N in chain)
			del(N)
		chain.len = 0
		for(var/obj/structure/hookshot/T in hookshot)
			spawn()//so they all return at once
				T.returnin()
		singulo.on_release()
		singulo = null

/obj/item/key/teleportback

/obj/item/key/teleportback/attack_self(mob/user as mob)
	user.send_back()



