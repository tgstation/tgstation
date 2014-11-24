///////////////////////////////////////////////////////////////
//Deity Link, giving a new meaning to the Adminbus since 2014//
///////////////////////////////////////////////////////////////

//RELEASE PASSENGERS

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/release_passengers(mob/bususer)

	unloading = 1
	flick("icon_free-push",bususer.gui_icons.adminbus_free)

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
			update_rearview()
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
	L << "<span class='notice'>Thank you for riding with \the [src], have a secure day.</span>"
	passengers -= L
	update_rearview()

//MOB SPAWNING
/obj/structure/stool/bed/chair/vehicle/adminbus/proc/spawn_mob(mob/bususer,var/mob_type,var/count)
	switch(mob_type)
		if(1)
			flick("icon_spclown-push",bususer.gui_icons.adminbus_spclowns)
		if(2)
			flick("icon_spcarp-push",bususer.gui_icons.adminbus_spcarps)
		if(3)
			flick("icon_spbear-push",bususer.gui_icons.adminbus_spbears)
		if(4)
			flick("icon_sptree-push",bususer.gui_icons.adminbus_sptrees)
		if(5)
			flick("icon_spspider-push",bususer.gui_icons.adminbus_spspiders)
		if(6)
			flick("icon_spalien-push",bususer.gui_icons.adminbus_spalien)

	var/turflist[] = list()
	for(var/turf/T in orange(src,1))
		if((T.density == 0) && (T!=src.loc))
			turflist += T

	var/invocnum = min(count, turflist.len)

	for(var/i=0;i<invocnum;i++)
		var/turf/T = pick(turflist)
		turflist -= T
		switch(mob_type)
			if(1)
				var/mob/living/simple_animal/hostile/retaliate/clown/admin/M = new /mob/living/simple_animal/hostile/retaliate/clown/admin(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#FFC0FF")
			if(2)
				var/mob/living/simple_animal/hostile/carp/admin/M = new /mob/living/simple_animal/hostile/carp/admin(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#C70AF5")
			if(3)
				if(prob(10))
					var/mob/living/simple_animal/hostile/russian/admin/M = new /mob/living/simple_animal/hostile/russian/admin(T)
					M.faction = "adminbus mob"
					spawned_mobs += M
				else
					var/mob/living/simple_animal/hostile/bear/admin/M = new /mob/living/simple_animal/hostile/bear/admin(T)
					M.faction = "adminbus mob"
					spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#454545")
			if(4)
				var/mob/living/simple_animal/hostile/tree/admin/M = new /mob/living/simple_animal/hostile/tree/admin(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#232B2C")
			if(5)
				var/mob/living/simple_animal/hostile/giant_spider/admin/M = new /mob/living/simple_animal/hostile/giant_spider/admin(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#3B2D1C")
			if(6)
				var/mob/living/simple_animal/hostile/alien/queen/large/admin/M = new /mob/living/simple_animal/hostile/alien/queen/large/admin(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-16,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',"#525288")
		sleep(5)

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/remove_mobs(mob/bususer)

	flick("icon_delmobs-push",bususer.gui_icons.adminbus_delmobs)

	for(var/mob/M in spawned_mobs)
		var/xoffset = -32
		if(istype(M,/mob/living/simple_animal/hostile/alien/queen/large))
			xoffset = -16
		var/turf/T = get_turf(M)
		if(T)
			T.turf_animation('icons/effects/96x96.dmi',"beamin",xoffset,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')
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

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/throw_hookshot(mob/bususer)

	if(!hook && !singulo)
		return

	if(singulo)
		bususer.gui_icons.adminbus_hook.icon_state = "icon_hook-push"
		var/obj/structure/singulo_chain/anchor/A = locate(/obj/structure/singulo_chain/anchor) in chain
		if(A)
			del(A)//so we don't drag the singulo back to us along with the rest of the chain.
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

		if(!singulo)
			bususer.gui_icons.adminbus_hook.icon_state = "icon_hook"
			hook = 1
	else if(hook)
		bususer.gui_icons.adminbus_hook.icon_state = "icon_hook-push"
		hook = 0

		var/obj/structure/hookshot/claw/C = new/obj/structure/hookshot/claw(get_step(src,src.dir))	//First we spawn the claw
		hookshot += C
		C.abus = src

		var/obj/machinery/singularity/S = C.hook_throw(src.dir)							//The claw moves forward, spawning hookshot-chains on its path
		if(S)
			bususer.gui_icons.adminbus_hook.icon_state = "icon_singulo"
			capture_singulo(S)															//If the claw hits a singulo, we remove the hookshot-chains and replace them with singulo-chains
		else
			for(var/obj/structure/hookshot/A in hookshot)								//If it doesn't hit anything, all the elements of the chain come back toward the bus,
				spawn()//so they all return at once										//deleting themselves when they reach it.
					A.hook_back()

/////////////////

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/mass_rejuvinate(mob/bususer)

	flick("icon_massrejuv-push",bususer.gui_icons.adminbus_massrejuv)

	for(var/mob/living/M in orange(src,3))
		M.revive()
		M << "<span class='notice'>THE ADMINBUS IS LOVE. THE ADMINBUS IS LIFE.</span>"
		sleep(2)
	update_rearview()

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/toggle_lights(mob/bususer,var/lightpower=0)

	if(lightpower == roadlights)
		return

	switch(lightpower)
		if(0)
			bususer.gui_icons.adminbus_roadlights_0.icon_state = "icon_lights_0-on"
			bususer.gui_icons.adminbus_roadlights_1.icon_state = "icon_lights_1-off"
			bususer.gui_icons.adminbus_roadlights_2.icon_state = "icon_lights_2-off"
			lightsource.SetLuminosity(0)
			if(roadlights == 1 || roadlights == 2)
				overlays -= image(icon,"roadlights",LIGHTING_LAYER+1)
			roadlights = 0
		if(1)
			bususer.gui_icons.adminbus_roadlights_0.icon_state = "icon_lights_0-off"
			bususer.gui_icons.adminbus_roadlights_1.icon_state = "icon_lights_1-on"
			bususer.gui_icons.adminbus_roadlights_2.icon_state = "icon_lights_2-off"
			lightsource.SetLuminosity(2)
			if(roadlights == 0)
				overlays += image(icon,"roadlights",LIGHTING_LAYER+1)
			roadlights = 1
		if(2)
			bususer.gui_icons.adminbus_roadlights_0.icon_state = "icon_lights_0-off"
			bususer.gui_icons.adminbus_roadlights_1.icon_state = "icon_lights_1-off"
			bususer.gui_icons.adminbus_roadlights_2.icon_state = "icon_lights_2-on"
			lightsource.SetLuminosity(3)
			if(roadlights == 0)
				overlays += image(icon,"roadlights",LIGHTING_LAYER+1)
			roadlights = 2

	update_lightsource()

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/toggle_bumpers(mob/bususer,var/bumperpower=1)

	if(bumperpower == bumpers)
		return

	switch(bumperpower)
		if(1)
			bususer.gui_icons.adminbus_bumpers_1.icon_state = "icon_bumpers_1-on"
			bususer.gui_icons.adminbus_bumpers_2.icon_state = "icon_bumpers_2-off"
			bususer.gui_icons.adminbus_bumpers_3.icon_state = "icon_bumpers_3-off"
			bumpers = 1
		if(2)
			bususer.gui_icons.adminbus_bumpers_1.icon_state = "icon_bumpers_1-off"
			bususer.gui_icons.adminbus_bumpers_2.icon_state = "icon_bumpers_2-on"
			bususer.gui_icons.adminbus_bumpers_3.icon_state = "icon_bumpers_3-off"
			bumpers = 2
		if(3)
			bususer.gui_icons.adminbus_bumpers_1.icon_state = "icon_bumpers_1-off"
			bususer.gui_icons.adminbus_bumpers_2.icon_state = "icon_bumpers_2-off"
			bususer.gui_icons.adminbus_bumpers_3.icon_state = "icon_bumpers_3-on"
			bumpers = 3


/obj/structure/stool/bed/chair/vehicle/adminbus/proc/toggle_door(mob/bususer,var/doorstate=0)

	if(doorstate == door_mode)
		return

	switch(doorstate)
		if(0)
			bususer.gui_icons.adminbus_door_0.icon_state = "icon_door_0-on"
			bususer.gui_icons.adminbus_door_1.icon_state = "icon_door_1-off"
			door_mode = 0
			overlays -= image(icon,"opendoor")
		if(1)
			bususer.gui_icons.adminbus_door_0.icon_state = "icon_door_0-off"
			bususer.gui_icons.adminbus_door_1.icon_state = "icon_door_1-on"
			door_mode = 1
			overlays += image(icon,"opendoor")

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/loadsa_goodies(mob/bususer,var/goodie_type)
	switch(goodie_type)
		if(1)
			flick("icon_loadsids-push",bususer.gui_icons.adminbus_loadsids)
			visible_message("<span class='notice'>All Access for Everyone!</span>")
		if(2)
			flick("icon_loadsmone-push",bususer.gui_icons.adminbus_loadsmoney)
			visible_message("<span class='notice'>Loads of Money!</span>")

	var/joy_sound = list('sound/voice/SC4Mayor1.ogg','sound/voice/SC4Mayor2.ogg','sound/voice/SC4Mayor3.ogg')
	playsound(src, pick(joy_sound), 50, 0, 0)
	var/throwzone = list()
	for(var/i=1;i<=5;i++)
		throwzone = list()
		for(var/turf/T in range(src,5))
			throwzone += T
		switch(goodie_type)
			if(1)
				var/obj/item/weapon/card/id/captains_spare/S = new/obj/item/weapon/card/id/captains_spare(src.loc)
				S.throw_at(pick(throwzone),rand(2,5),0)
			if(2)
				var/obj/item/fuckingmoney = null
				fuckingmoney = pick(
				50;/obj/item/weapon/coin/gold,
				50;/obj/item/weapon/coin/silver,
				50;/obj/item/weapon/coin/diamond,
				40;/obj/item/weapon/coin/iron,
				50;/obj/item/weapon/coin/plasma,
				40;/obj/item/weapon/coin/uranium,
				10;/obj/item/weapon/coin/clown,
				50;/obj/item/weapon/coin/phazon,
				30;/obj/item/weapon/coin/adamantine,
				30;/obj/item/weapon/coin/mythril,
				200;/obj/item/weapon/spacecash,
				200;/obj/item/weapon/spacecash/c10,
				200;/obj/item/weapon/spacecash/c100,
				300;/obj/item/weapon/spacecash/c1000
				)
				var/obj/item/C = new fuckingmoney(src.loc)
				C.throw_at(pick(throwzone),rand(2,5),0)

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/give_bombs(mob/bususer)

	flick("icon_givebombs-push",bususer.gui_icons.adminbus_givebombs)

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

	bususer << "[distributed] bombs distributed to passengers.</span>"

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/delete_bombs(mob/bususer)

	flick("icon_delgiven-push",bususer.gui_icons.adminbus_delbombs)

	if(spawnedbombs.len == 0)
		bususer << "No bombs to delete.</span>"
		return

	var/distributed = 0

	for(var/i=spawnedbombs.len;i>0;i--)
		var/obj/item/device/fuse_bomb/B = spawnedbombs[i]
		if(B)
			del(B)
			distributed++
		spawnedbombs -= spawnedbombs[i]

	bususer << "Deleted all [distributed] bombs.</span>"


/obj/structure/stool/bed/chair/vehicle/adminbus/proc/give_lasers(mob/bususer)

	flick("icon_givelasers-push",bususer.gui_icons.adminbus_givelasers)

	var/distributed = 0

	if(buckled_mob && iscarbon(buckled_mob))
		if(!(buckled_mob.r_hand))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(buckled_mob)
			spawnedlasers += L
			buckled_mob.equip_to_slot_or_del(L, slot_r_hand)
			buckled_mob << "<span class='warning'>Spray and /pray!</span>"
			buckled_mob.update_inv_r_hand()
		else if(!(buckled_mob.l_hand))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(buckled_mob)
			spawnedlasers += L
			buckled_mob.equip_to_slot_or_del(L, slot_l_hand)
			buckled_mob << "<span class='warning'>Spray and /pray!</span>"
			buckled_mob.update_inv_l_hand()

	for(var/mob/living/carbon/C in passengers)
		if(!(C.r_hand))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(C)
			spawnedlasers += L
			C.equip_to_slot_or_del(L, slot_r_hand)
			C << "<span class='warning'>Our benefactors have provided you with an infinite laser gun. Spray and /pray!</span>"
			distributed++
			C.update_inv_r_hand()
		else if(!(C.l_hand))
			var/obj/item/weapon/gun/energy/laser/admin/L = new /obj/item/weapon/gun/energy/laser/admin(C)
			spawnedlasers += L
			C.equip_to_slot_or_del(L, slot_l_hand)
			C << "<span class='warning'>Our benefactors have provided you with an infinite laser gun. Spray and /pray!</span>"
			distributed++
			C.update_inv_l_hand()

	update_rearview()
	bususer << "[distributed] infinite laser guns distributed to passengers.</span>"

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/delete_lasers(mob/bususer)

	flick("icon_delgiven-push",bususer.gui_icons.adminbus_dellasers)

	if(spawnedlasers.len == 0)
		bususer << "No laser guns to delete.</span>"
		return

	var/distributed = 0

	for(var/i=spawnedlasers.len;i>0;i--)
		var/obj/item/weapon/gun/energy/laser/admin/L = spawnedlasers[i]
		if(L)
			if(istype(L.loc,/mob/living/carbon))
				var/mob/living/carbon/C = L.loc
				del(L)
				C.regenerate_icons()
			else
				del(L)
			distributed++
		spawnedlasers -= spawnedlasers[i]

	update_rearview()
	bususer << "Deleted all [distributed] laser guns.</span>"

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Mass_Repair(mob/bususer)

	flick("icon_massrepair-push",bususer.gui_icons.adminbus_massrepair)

	visible_message("<span class='notice'>WE BUILD!</span>")

	for(var/obj/machinery/M in range(src,3))
		if(istype(M,/obj/machinery/door/window))//for some reason it makes the windoors' sprite disapear (until you bump into it)
			continue
		if(istype(M,/obj/machinery/light))
			var/obj/machinery/light/L = M
			L.fix()
			continue
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

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Teleportation(mob/bususer)

	if(warp.icon_state == "warp_activated")
		return

	bususer.gui_icons.adminbus_tele.icon_state = "icon_teleport-push"
	warp.icon_state = "warp_activated"

	var/A
	A = input(bususer, "Area to jump to", "Teleportation Warp", A) as null|anything in adminbusteleportlocs
	var/area/thearea = adminbusteleportlocs[A]
	if(!thearea)
		bususer.gui_icons.adminbus_tele.icon_state = "icon_teleport"
		warp.icon_state = ""
		return

	var/list/L = list()

	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !L.len)
		bususer << "No area available."
		bususer.gui_icons.adminbus_tele.icon_state = "icon_teleport"
		warp.icon_state = ""
		return

	var/turf/T1 = get_turf(src)
	var/turf/T2 = pick(L)
	bususer.gui_icons.adminbus_tele.icon_state = "icon_teleport"
	warp.icon_state = ""
	src.loc = T2
	src.Move()
	T1.turf_animation('icons/effects/160x160.dmi',"busteleport",-64,-32,MOB_LAYER+1,'sound/effects/busteleport.ogg')
	T2.turf_animation('icons/effects/160x160.dmi',"busteleport",-64,-32,MOB_LAYER+1,'sound/effects/busteleport.ogg')

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Sendto_Thunderdome_Obs(mob/bususer)

	if(passengers.len == 0)
		flick("icon_tdobs-flick",bususer.gui_icons.adminbus_tdobs)
		bususer << "<span class='warning'>There are no passengers to send.</span>"
		return

	bususer.gui_icons.adminbus_tdobs.icon_state = "icon_tdobs-push"
	if(alert(bususer, "Send all passengers to the thunderdome's spectating area?", "Adminbus", "Yes", "No") != "Yes")
		bususer.gui_icons.adminbus_tdobs.icon_state = "icon_tdobs"
		return
	bususer.gui_icons.adminbus_tdobs.icon_state = "icon_tdobs"

	var/turf/T = get_turf(src)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')

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
			TD.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')

		sleep(1)

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Sendto_Thunderdome_Arena(mob/bususer)//this one sends an equal number of fighter to each side.

	if(passengers.len == 0)
		flick("icon_tdarena-flick",bususer.gui_icons.adminbus_tdarena)
		bususer << "<span class='warning'>There are no passengers to send.</span>"
		return

	bususer.gui_icons.adminbus_tdarena.icon_state = "icon_tdarena-push"
	if(alert(bususer, "Split passengers between the two thunderdome teams?", "Adminbus", "Yes", "No") != "Yes")
		bususer.gui_icons.adminbus_tdarena.icon_state = "icon_tdarena"
		return
	bususer.gui_icons.adminbus_tdarena.icon_state = "icon_tdarena"

	var/turf/T = get_turf(src)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')

	var/alternate = 1

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(alternate)
			join_team(A,"Red")
			alternate = 0
		else
			join_team(A,"Green")
			alternate = 1

	bususer << "The passengers' belongings were stored inside the Thunderdome's admin lodge."

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Sendto_Thunderdome_Arena_Green(mob/bususer)

	if(passengers.len == 0)
		flick("icon_tdgreen-flick",bususer.gui_icons.adminbus_tdgreen)
		bususer << "<span class='warning'>There are no passengers to send.</span>"
		return

	bususer.gui_icons.adminbus_tdgreen.icon_state = "icon_tdgreen-push"
	if(alert(bususer, "Send all passengers to the thunderdome's Green Team?", "Adminbus", "Yes", "No") != "Yes")
		bususer.gui_icons.adminbus_tdgreen.icon_state = "icon_tdgreen"
		return
	bususer.gui_icons.adminbus_tdgreen.icon_state = "icon_tdgreen"

	var/turf/T = get_turf(src)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		join_team(A,"Green")

	bususer << "The passengers' belongings were stored inside the Thunderdome's admin lodge."

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Sendto_Thunderdome_Arena_Red(mob/bususer)

	if(passengers.len == 0)
		flick("icon_tdred-flick",bususer.gui_icons.adminbus_tdred)
		bususer << "<span class='warning'>There are no passengers to send.</span>"
		return

	bususer.gui_icons.adminbus_tdred.icon_state = "icon_tdred-push"
	if(alert(bususer, "Send all passengers to the thunderdome's Red Team?", "Adminbus", "Yes", "No") != "Yes")
		bususer.gui_icons.adminbus_tdred.icon_state = "icon_tdred"
		return
	bususer.gui_icons.adminbus_tdred.icon_state = "icon_tdred"

	var/turf/T = get_turf(src)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')

	for(var/i=passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		join_team(A,"Red")

	bususer << "The passengers' belongings were stored inside the Thunderdome's admin lodge."

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/join_team(var/atom/A, var/team)
	if(isliving(A))
		var/mob/living/M = A
		freed(M)

		var/obj/item/packobelongings/pack = null

		switch(team)
			if("Green")
				pack = new /obj/item/packobelongings/green(src.loc)
			if("Red")
				pack = new /obj/item/packobelongings/red(src.loc)

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

		var/obj/item/weapon/card/id/thunderdome/ident = null

		switch(team)
			if("Green")
				ident = new /obj/item/weapon/card/id/thunderdome/green(M)
				ident.name = "[M.real_name]'s Thunderdome Green ID"
			if("Red")
				ident = new /obj/item/weapon/card/id/thunderdome/red(M)
				ident.name = "[M.real_name]'s Thunderdome Red ID"

		if(!iscarbon(M))
			qdel(ident)

		switch(team)
			if("Green")
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

			if("Red")
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

		M << "<span class='danger'>You have been chosen to fight for the [team] Team. [pick(\
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

	switch(team)
		if("Green")
			A.loc = pick(tdome1)
		if("Red")
			A.loc = pick(tdome2)

	var/turf/T = get_turf(A)
	if(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg', "#00FF00")

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

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Send_Home(mob/bususer)

	if(passengers.len == 0)
		flick("icon_home-flick",bususer.gui_icons.adminbus_home)
		bususer << "<span class='warning'>There are no passengers to send.</span>"
		return

	bususer.gui_icons.adminbus_home.icon_state = "icon_home-push"
	if(alert(bususer, "Send all mobs among the passengers back where they first appeared? (Risky: This sends them back where their \"object\" was created. If they were cloned they will teleport back at genetics, If they had their species changed they'll spawn back where it happenned, etc...)", "Adminbus", "Yes", "No") != "Yes")
		bususer.gui_icons.adminbus_home.icon_state = "icon_home"
		return
	bususer.gui_icons.adminbus_home.icon_state = "icon_home"

	var/turf/T1 = get_turf(src)
	if(T1)
		T1.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')

	for(var/mob/M in passengers)
		freed(M)
		M.send_back()

		var/turf/T2 = get_turf(M)
		if(T2)
			T2.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Make_Antag(mob/bususer)

	if(passengers.len == 0)
		flick("icon_antag-flick",bususer.gui_icons.adminbus_antag)
		bususer << "<span class='warning'>There are no passengers to make antag.</span>"
		return

	bususer.gui_icons.adminbus_antag.icon_state = "icon_antag-push"
	var/list/delays = list("CANCEL", "No Delay", "10 seconds", "30 seconds", "1 minute", "5 minutes", "15 minutes")
	var/delay = input("How much delay before the transformation occurs?", "Antag Madness") in delays

	switch(delay)
		if("CANCEL")
			bususer.gui_icons.adminbus_antag.icon_state = "icon_antag"
			return
		if("No Delay")
			bususer.gui_icons.adminbus_antag.icon_state = "icon_antag"
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
	bususer.gui_icons.adminbus_antag.icon_state = "icon_antag"

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

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Mounted_Jukebox(mob/bususer)

	flick("icon_jukebox-push",bususer.gui_icons.adminbus_juke)

	busjuke.attack_hand(bususer)

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/Adminbus_Deletion(mob/bususer)//make sure to always use this proc when deleting an adminbus

	bususer.gui_icons.adminbus_delete.icon_state = "icon_delete-push"
	if(alert(bususer, "This will free all passengers, remove any spawned mobs/laserguns/bombs, [singulo ? "free the captured singularity" : ""], and remove all the entities associated with the bus(chains, roadlights, jukebox,...) Are you sure?", "Adminbus Deletion", "Yes", "No") != "Yes")
		bususer.gui_icons.adminbus_delete.icon_state = "icon_delete"
		return

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

	delete_bombs()
	delete_lasers()
	remove_mobs()

	if(singulo)
		singulo.on_release()

	for(var/obj/structure/singulo_chain/N in chain)
		del(N)

	for(var/obj/structure/hookshot/H in hookshot)
		del(H)

	busjuke.disconnect_media_source()
	del(busjuke)
	del(warp)
	del(lightsource)

	var/turf/T = get_turf(src)
	T.turf_animation('icons/effects/160x160.dmi',"busteleport",-64,-32,MOB_LAYER+1,'sound/effects/busteleport.ogg')

	if(buckled_mob)
		buckled_mob.hud_used.remove_adminbus_hud()

	del(src)//RIP ADMINBUS