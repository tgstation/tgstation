///////////////////////////////////////////////////////////////
//Deity Link, giving a new meaning to the Adminbus since 2014//
///////////////////////////////////////////////////////////////

//RELEASE PASSENGERS

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/release_passengers()
	set name = "Release Passengers"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	unloading = 1

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/L = A
			freed(L)
		else if(isbot(A))
			var/obj/machinery/bot/B = A
			switch(dir)
				if(SOUTH)
					B.x = x-1
				if(WEST)
					B.y = y+1
				if(NORTH)
					B.x = x+1
				if(EAST)
					B.y = y-1
			B.turn_on()
			B.isolated = 0
			B.anchored = 0
			passengers -= B
		sleep(3)

	unloading = 0

	return

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/freed(var/mob/living/L)
	switch(dir)
		if(SOUTH)
			L.x = x-1
		if(WEST)
			L.y = y+1
		if(NORTH)
			L.x = x+1
		if(EAST)
			L.y = y-1
	L.buckled = null
	L.anchored = 0
	L.isolated = 0
	L.captured = 0
	L.pixel_x = 0
	L.pixel_y = 0
	L.update_canmove()
	L << "<span class='notice'>Thank you for riding with the Adminbus, have a secure day.</span>"
	passengers -= L

//MOB SPAWNING

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

//SINGULARITY/NARSIE HOOK&CHAIN

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/capture_singulo(var/obj/machinery/singularity/S)
	for(var/atom/A in hookshot)																//first we remove the hookshot and its chain
		qdel(A)
	hookshot.len = 0

	singulo = S
	S.on_capture()
	var/obj/structure/singulo_chain/parentchain = null
	var/obj/structure/singulo_chain/anchor/A = new /obj/structure/singulo_chain/anchor(loc)	//then we spawn the invisible anchor on top of the bus,
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
	chain += A																				//once the anchor has reached the singulo, it parents itself to the last element in the chain
	A.target = singulo																		//and stays on top of the singulo.

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

	var/obj/structure/hookshot/claw/C = new/obj/structure/hookshot/claw(get_step(src,src.dir))	//First we spawn the claw
	hookshot += C
	C.abus = src

	var/obj/machinery/singularity/S = C.launchin(src.dir)							//The claw moves forward, spawning hookshot-chains on its path
	if(S)
		capture_singulo(S)															//If the claw hits a singulo, we remove the hookshot-chains and replace them with singulo-chains
	else
		for(var/obj/structure/hookshot/A in hookshot)								//If it doesn't hit anything, all the elements of the chain come back toward the bus,
			spawn()//so they all return at once										//deleting themselves when they reach it.
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

	if(chain_base)
		var/obj/structure/singulo_chain/anchor/A = locate(/obj/structure/singulo_chain/anchor) in chain
		if(A)
			del(A)//so we don't drag the singulo back to us along with the rest of the chain.
		if(singulo)
			singulo.on_release()
			singulo = null
		while(chain_base)
			var/obj/structure/singulo_chain/C = chain_base
			C.move_child(get_turf(src))
			chain_base = C.child
			del(C)
			sleep(2)

		for(var/obj/structure/singulo_chain/N in chain)//Just in case some bits of the chain were detached from the bus for whatever reason
			del(N)
		chain.len = 0

		hook = 1

/////////////////

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/mass_rejuvinate()
	set name = "Mass Rejuvinate"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	for(var/mob/living/M in orange(src,3))
		M.revive()
		M << "<span class='notice'>THE ADMINBUS IS LOVE. THE ADMINBUS IS LIFE.</span>"
		sleep(2)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/toggle_lights()
	set name = "Toggle Roadlights"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(roadlights)
		roadlights = 0
		overlays -= overlays_bus[2]
		lightsource.SetLuminosity(0)
	else
		roadlights = 1
		overlays += overlays_bus[2]
		lightsource.SetLuminosity(2)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/toggle_door()
	set name = "Toggle Door"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(door_mode)
		door_mode = 0
		overlays -= overlays_bus[4]
	else
		door_mode = 1
		overlays += overlays_bus[4]

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Loadsa_Captains_Spares()
	set name = "Loadsa Captains Spares"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	visible_message("<span class='notice'>All Access for Everyone!</span>")
	var/joy_sound = list('sound/voice/SC4Mayor1.ogg','sound/voice/SC4Mayor2.ogg','sound/voice/SC4Mayor3.ogg')
	playsound(src, pick(joy_sound), 50, 0, 0)
	var/throwzone[] = list()
	for(var/i=1;i<=5;i++)
		throwzone = list()
		for(var/turf/T in range(src,5))
			throwzone += T
		var/obj/item/weapon/card/id/captains_spare/S = new/obj/item/weapon/card/id/captains_spare(src.loc)
		S.throw_at(pick(throwzone),rand(2,5),0)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Loadsa_Money()
	set name = "Loadsa Money"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	visible_message("<span class='notice'>Loads of Money!</span>")
	var/joy_sound = list('sound/voice/SC4Mayor1.ogg','sound/voice/SC4Mayor2.ogg','sound/voice/SC4Mayor3.ogg')
	playsound(src, pick(joy_sound), 50, 0, 0)
	var/obj/item/fuckingmoney = null
	var/throwzone[] = list()
	for(var/i=1;i<=10;i++)
		throwzone = list()
		for(var/turf/T in range(src,5))
			throwzone += T
		fuckingmoney = pick(\
		50;/obj/item/weapon/coin/gold,\
		50;/obj/item/weapon/coin/silver,\
		50;/obj/item/weapon/coin/diamond,\
		40;/obj/item/weapon/coin/iron,\
		50;/obj/item/weapon/coin/plasma,\
		40;/obj/item/weapon/coin/uranium,\
		10;/obj/item/weapon/coin/clown,\
		50;/obj/item/weapon/coin/phazon,\
		30;/obj/item/weapon/coin/adamantine,\
		30;/obj/item/weapon/coin/mythril,\
		200;/obj/item/weapon/spacecash,\
		200;/obj/item/weapon/spacecash/c10,\
		200;/obj/item/weapon/spacecash/c100,\
		300;/obj/item/weapon/spacecash/c1000)
		var/obj/item/C = new fuckingmoney(src.loc)
		C.throw_at(pick(throwzone),rand(2,5),0)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/give_bombs()
	set name = "Give Bombs"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	var/distributed = 0

	if(buckled_mob && iscarbon(buckled_mob))
		if(!(buckled_mob.r_hand))
			var/obj/item/device/fuse_bomb/admin/B = new /obj/item/device/fuse_bomb/admin(buckled_mob)
			spawnedbombs += B
			buckled_mob.equip_to_slot_or_del(B, slot_r_hand)
			buckled_mob << "<span class='warning'>Lit and throw!</span>"
			buckled_mob.update_inv_r_hand()
		else if(!(buckled_mob.l_hand))
			var/obj/item/device/fuse_bomb/admin/B = new /obj/item/device/fuse_bomb/admin(buckled_mob)
			spawnedbombs += B
			buckled_mob.equip_to_slot_or_del(B, slot_l_hand)
			buckled_mob << "<span class='warning'>Lit and throw!</span>"
			buckled_mob.update_inv_l_hand()
	for(var/mob/living/carbon/C in passengers)
		if(!(C.r_hand))
			var/obj/item/device/fuse_bomb/admin/B = new /obj/item/device/fuse_bomb/admin(C)
			spawnedbombs += B
			C.equip_to_slot_or_del(B, slot_r_hand)
			C << "<span class='warning'>Our benefactors have provided you with a bomb. Lit and throw!</span>"
			distributed++
			C.update_inv_r_hand()
		else if(!(C.l_hand))
			var/obj/item/device/fuse_bomb/admin/B = new /obj/item/device/fuse_bomb/admin(C)
			spawnedbombs += B
			C.equip_to_slot_or_del(B, slot_l_hand)
			C << "<span class='warning'>Our benefactors have provided you with a bomb. Lit and throw!</span>"
			distributed++
			C.update_inv_l_hand()

	usr << "[distributed] bombs distributed to passengers.</span>"

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/delete_bombs()
	set name = "Delete Bombs"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(spawnedbombs.len == 0)
		usr << "No bombs to delete.</span>"
		return

	var/distributed = 0

	for(var/i=spawnedbombs.len;i>0;i--)
		var/obj/item/device/fuse_bomb/B = spawnedbombs[i]
		if(B)
			del(B)
			distributed++
		spawnedbombs -= spawnedbombs[i]

	usr << "Deleted all [distributed] bombs.</span>"


/obj/structure/stool/bed/chair/vehicle/adminbus/verb/give_lasers()
	set name = "Give Laser Guns"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	var/distributed = 0

	if(buckled_mob && iscarbon(buckled_mob))
		if(!(buckled_mob.r_hand))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(buckled_mob)
			spawnedlasers += L
			buckled_mob.equip_to_slot_or_del(L, slot_r_hand)
			buckled_mob << "<span class='notice'>Spray and /pray!</span>"
			buckled_mob.update_inv_r_hand()
		else if(!(buckled_mob.l_hand))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(buckled_mob)
			spawnedlasers += L
			buckled_mob.equip_to_slot_or_del(L, slot_l_hand)
			buckled_mob << "<span class='notice'>Spray and /pray!</span>"
			buckled_mob.update_inv_l_hand()

	for(var/mob/living/carbon/C in passengers)
		if(!(C.r_hand))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(C)
			spawnedlasers += L
			C.equip_to_slot_or_del(L, slot_r_hand)
			C << "<span class='notice'>Our benefactors have provided you with an infinite laser gun. Spray and /pray!</span>"
			distributed++
			C.update_inv_r_hand()
		else if(!(C.l_hand))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(C)
			spawnedlasers += L
			C.equip_to_slot_or_del(L, slot_l_hand)
			C << "<span class='notice'>Our benefactors have provided you with an infinite laser gun. Spray and /pray!</span>"
			distributed++
			C.update_inv_l_hand()

	usr << "[distributed] infinite laser guns distributed to passengers.</span>"

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/delete_lasers()
	set name = "Delete Laser Guns"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(spawnedlasers.len == 0)
		usr << "No laser guns to delete.</span>"
		return

	var/distributed = 0

	for(var/i=spawnedlasers.len;i>0;i--)
		var/obj/item/weapon/gun/energy/laser/admin/L = spawnedlasers[i]
		if(L)
			del(L)
			distributed++
		spawnedlasers -= spawnedlasers[i]

	usr << "Deleted all [distributed] laser guns.</span>"

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Mass_Repair()
	set name = "Mass Repair"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	visible_message("<span class='notice'>WE BUILD!</span>")

	for(var/obj/machinery/M in range(src,3))
		M.stat = 0
		M.update_icon()

	for(var/turf/T in range(src,3))
		if(istype(T, /turf/space/))
			if(T.loc.name == "Space")
				continue
			var/obj/item/stack/tile/plasteel/P = new /obj/item/stack/tile/plasteel
			P.build(T)
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/floor/F = T
			if(F.broken || F.burnt)
				if(F.is_plating())
					F.icon_state = "plating"
					F.burnt = 0
					F.broken = 0
				else
					F.make_plating()

	for(var/obj/structure/cultgirder/G in range(src,3))
		var/turf/T = get_turf(G)
		T.ChangeTurf(/turf/simulated/wall/cult)
		del(G)

	for(var/obj/structure/girder/G in range(src,3))
		var/turf/T = get_turf(G)
		if(istype(G,/obj/structure/girder/reinforced))
			T.ChangeTurf(/turf/simulated/wall/r_wall)
		else
			T.ChangeTurf(/turf/simulated/wall)
		del(G)

	for(var/obj/item/weapon/shard/S in range(src,3))
		if(istype(S,/obj/item/weapon/shard/plasma))
			new/obj/item/stack/sheet/glass/plasmaglass(S.loc)
		else
			new/obj/item/stack/sheet/glass(S.loc)
		del(S)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Teleportation()
	set name = "Teleportation"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	warp.icon_state = "warp_activated"

	var/A
	A = input(usr, "Area to jump to", "Teleportation Warp", A) as null|anything in adminbusteleportlocs
	var/area/thearea = adminbusteleportlocs[A]
	if(!thearea)
		warp.icon_state = ""
		return

	var/list/L = list()

	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !L.len)
		usr << "No area available."
		warp.icon_state = ""
		return

	var/turf/T1 = get_turf(src)
	var/turf/T2 = pick(L)
	warp.icon_state = ""
	src.loc = T2
	src.Move()
	T1.busteleport()
	T2.busteleport()

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Sendto_Thunderdome_Obs()
	set name = "Send Passengers to Thunderdome as Observers"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(passengers.len == 0)
		usr << "<span class='warning'>There are no passengers to send.</span>"
		return

	if(alert(usr, "Send all passengers to the thunderdome's spectating area?", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(src)
	if(T)
		T.beamin("")

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/M = A
			freed(M)

/*									//We let the observers keep their belongings
			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.loc = M.loc
					I.layer = initial(I.layer)
					I.dropped(M)
					I.z = 2
					I.y = 68
					I.x = (thunderdomefightercount % 15) + 121

*/

			M.loc = pick(tdomeobserve)
			M << "<span class='notice'>You have been sent to the Thunderdome. Thank you for riding with us and enjoy your games.</span>"

		else if(isbot(A))
			var/obj/machinery/bot/B = A
			switch(dir)
				if(SOUTH)
					B.x = x-1
				if(WEST)
					B.y = y+1
				if(NORTH)
					B.x = x+1
				if(EAST)
					B.y = y-1
			B.turn_on()
			B.isolated = 0
			B.anchored = 0
			passengers -= B
			B.loc = pick(tdomeobserve)

		var/turf/TD = get_turf(A)
		if(TD)
			TD.beamin("")

		sleep(1)

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Sendto_Thunderdome_Arena()//this one sends an equal number of fighter to each side.
	set name = "Send Passengers to Thunderdome Arena"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(passengers.len == 0)
		usr << "<span class='warning'>There are no passengers to send.</span>"
		return

	if(alert(usr, "Split passengers between the two thunderdome teams?", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(src)
	if(T)
		T.beamin("")

	var/alternate = 1

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(alternate)
			red_team(A)
			alternate = 0
		else
			green_team(A)
			alternate = 1

	usr << "The passengers' belongings were stored inside the Thunderdome's admin lodge."

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Sendto_Thunderdome_Arena_Green()
	set name = "Send Passengers to Thunderdome Arena Green"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(passengers.len == 0)
		usr << "<span class='warning'>There are no passengers to send.</span>"
		return

	if(alert(usr, "Send all passengers to the thunderdome's Green Team?", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(src)
	if(T)
		T.beamin("")

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		green_team(A)

	usr << "The passengers' belongings were stored inside the Thunderdome's admin lodge."

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Sendto_Thunderdome_Arena_Red()
	set name = "Send Passengers to Thunderdome Arena Red"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(passengers.len == 0)
		usr << "<span class='warning'>There are no passengers to send.</span>"
		return

	if(alert(usr, "Send all passengers to the thunderdome's Red Team?", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T = get_turf(src)
	if(T)
		T.beamin("")

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		red_team(A)

	usr << "The passengers' belongings were stored inside the Thunderdome's admin lodge."

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/green_team(var/atom/A)
	if(isliving(A))
		var/mob/living/M = A
		freed(M)

		var/obj/item/packobelongings/green/pack = new /obj/item/packobelongings/green(src.loc)
		pack.z = 2
		pack.y = 69
		pack.x = 130
		pack.name = "[M.real_name]'s belongings"

		for(var/obj/item/I in M)
			if(istype(I,/obj/item/clothing/glasses))
				var/obj/item/clothing/glasses/G = I
				if(G.prescription)
					continue
			M.u_equip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)
				I.loc = pack

		var/obj/item/weapon/card/id/thunderdome/green/ident = new /obj/item/weapon/card/id/thunderdome/green(M)
		ident.name = "[M.real_name]'s Thunderdome Green ID"
		if(!iscarbon(M))
			qdel(ident)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
			H.equip_to_slot_or_del(ident, slot_wear_id)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/green(H), slot_belt)
			H.regenerate_icons()
		else if(ismonkey(M))
			var/mob/living/carbon/monkey/K = M
			var/obj/item/clothing/monkeyclothes/jumpsuit_green/JS = new /obj/item/clothing/monkeyclothes/jumpsuit_green(K)
			var/obj/item/clothing/monkeyclothes/olduniform = null
			var/obj/item/clothing/monkeyclothes/oldhat = null
			if(K.uniform)
				olduniform = K.uniform
				K.uniform = null
				olduniform.loc = pack
			K.uniform = JS
			K.uniform.loc = K
			if(K.hat)
				oldhat = K.hat
				K.hat = null
				oldhat.loc = pack
			K.equip_to_slot_or_del(ident, slot_r_hand)
			K.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/green(K), slot_l_hand)
			K.regenerate_icons()

		if(pack.contents.len == 0)
			qdel(pack)

		M.loc = pick(tdome1)
		M << "<span class='danger'>You have been chosen to fight for the Green Team. [pick(\
		"The wheel of fate is turning!",\
		"Heaven or Hell!",\
		"Set Spell Card!",\
		"Hologram Summer Again!",\
		"Get ready for the next battle!",\
		"Fight for your life!",\
		)]</span>"

	else if(isbot(A))
		var/obj/machinery/bot/B = A
		switch(dir)
			if(SOUTH)
				B.x = x-1
			if(WEST)
				B.y = y+1
			if(NORTH)
				B.x = x+1
			if(EAST)
				B.y = y-1
		B.turn_on()
		B.isolated = 0
		B.anchored = 0
		passengers -= B
		B.loc = pick(tdome1)

	var/turf/T = get_turf(A)
	if(T)
		T.beamin("green")

	sleep(1)

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/red_team(var/atom/A)
	if(isliving(A))
		var/mob/living/M = A
		freed(M)

		var/obj/item/packobelongings/red/pack = new /obj/item/packobelongings/red(src.loc)
		pack.z = 2
		pack.y = 69
		pack.x = 126
		pack.name = "[M.real_name]'s belongings"

		for(var/obj/item/I in M)
			if(istype(I,/obj/item/clothing/glasses))
				var/obj/item/clothing/glasses/G = I
				if(G.prescription)
					continue
			M.u_equip(I)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				I.dropped(M)
				I.loc = pack

		var/obj/item/weapon/card/id/thunderdome/red/ident = new /obj/item/weapon/card/id/thunderdome/red(M)
		ident.name = "[M.real_name]'s Thunderdome Red ID"
		if(!iscarbon(M))
			qdel(ident)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
			H.equip_to_slot_or_del(ident, slot_wear_id)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/red(H), slot_belt)
			H.regenerate_icons()
		else if(ismonkey(M))
			var/mob/living/carbon/monkey/K = M
			var/obj/item/clothing/monkeyclothes/jumpsuit_red/JS = new /obj/item/clothing/monkeyclothes/jumpsuit_red(K)
			var/obj/item/clothing/monkeyclothes/olduniform = null
			var/obj/item/clothing/monkeyclothes/oldhat = null
			if(K.uniform)
				olduniform = K.uniform
				K.uniform = null
				olduniform.loc = pack
			K.uniform = JS
			K.uniform.loc = K
			if(K.hat)
				oldhat = K.hat
				K.hat = null
				oldhat.loc = pack
			K.equip_to_slot_or_del(ident, slot_r_hand)
			K.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/red(K), slot_l_hand)
			K.regenerate_icons()

		if(pack.contents.len == 0)
			qdel(pack)

		M.loc = pick(tdome2)
		M << "<span class='danger'>You have been chosen to fight for the Red Team. [pick(\
		"The wheel of fate is turning!",\
		"Heaven or Hell!",\
		"Set Spell Card!",\
		"Hologram Summer Again!",\
		"Get ready for the next battle!",\
		"Fight for your life!",\
		)]</span>"

	else if(isbot(A))
		var/obj/machinery/bot/B = A
		switch(dir)
			if(SOUTH)
				B.x = x-1
			if(WEST)
				B.y = y+1
			if(NORTH)
				B.x = x+1
			if(EAST)
				B.y = y-1
		B.turn_on()
		B.isolated = 0
		B.anchored = 0
		passengers -= B
		B.loc = pick(tdome2)

	var/turf/T = get_turf(A)
	if(T)
		T.beamin("red")

	sleep(1)

/obj/item/packobelongings
	name = "Unknown's belongings"
	desc = "Full of stuff."
	icon = 'icons/obj/storage.dmi'
	icon_state = "belongings"
	w_class = 3.0

/obj/item/packobelongings/New()
	..()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

/obj/item/packobelongings/attack_self(mob/user as mob)
	var/turf/T = get_turf(user)
	for(var/obj/O in src)
		O.loc = T
	qdel(src)

/obj/item/packobelongings/green
	icon_state = "belongings-green"
	desc = "Items belonging to one of the Thunderdome contestants."

/obj/item/packobelongings/red
	icon_state = "belongings-red"
	desc = "Items belonging to one of the Thunderdome contestants."

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Send_Home()
	set name = "Send Back Home"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(alert(usr, "Send all mobs among the passengers back where they first appeared? (Risky: This sends them back where their \"object\" was created. If they were cloned they will teleport back at genetics, If they had their species changed they'll spawn back where it happenned, etc...)", "Adminbus", "Yes", "No") != "Yes")
		return

	if(passengers.len == 0)
		usr << "<span class='warning'>There are no passengers to send.</span>"
		return

	var/turf/T1 = get_turf(src)
	if(T1)
		T1.beamin("")

	for(var/mob/M in passengers)
		freed(M)
		M.send_back()

		var/turf/T2 = get_turf(M)
		if(T2)
			T2.beamin("")

/obj/structure/stool/bed/chair/vehicle/adminbus/verb/Make_Antag()
	set name = "Make all passengers antags after a delay"
	set category = "Adminbus"
	set src = view(0)
	set popup_menu = 0
	set hidden = 0

	if(!(istype(usr,/mob/living/carbon/human/dummy) || istype(usr,/mob/living/simple_animal/corgi/Ian)))
		usr << "Nice try."
		return

	if(passengers.len == 0)
		usr << "<span class='warning'>There are no make antag.</span>"
		return


	var/list/delays = list("CANCEL", "No Delay", "10 seconds", "30 seconds", "1 minute", "5 minutes", "15 minutes")
	var/delay = input("How much delay before the transformation occurs?", "Antag Madness") in delays

	switch(delay)
		if("CANCEL")
			return
		if("No Delay")
			for(var/mob/M in passengers)
				spawn()
					M << "<span class='danger'>YOU JUST REMEMBERED SOMETHING IMPORTANT!</span>"
					sleep(20)
					antag_madness_adminbus(M)
		if("10 seconds")
			for(var/mob/M in passengers)
				spawn()
					Delay_Antag(M,100)
		if("30 seconds")
			for(var/mob/M in passengers)
				spawn()
					Delay_Antag(M,300)
		if("1 minute")
			for(var/mob/M in passengers)
				spawn()
					Delay_Antag(M,600)
		if("5 minutes")
			for(var/mob/M in passengers)
				spawn()
					Delay_Antag(M,3000)
		if("15 minutes")
			for(var/mob/M in passengers)
				spawn()
					Delay_Antag(M,9000)

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Delay_Antag(var/mob/M,var/delay=100)
	if(!M.mind)	return
	if(!ishuman(M) && !ismonkey(M))	return

	M << "<span class='rose'>You feel like you forgot something important!</span>"

	sleep(delay/2)

	M << "<span class='rose'>You're starting to remember...</span>"

	sleep(delay/2)

	M << "<span class='danger'>OH THAT'S RIGHT!</span>"

	sleep(20)

	antag_madness_adminbus(M)