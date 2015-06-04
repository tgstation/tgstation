/*
Ideas for the subtle effects of hallucination:

Light up oxygen/plasma indicators (done)
Cause health to look critical/dead, even when standing (done)
Characters silently watching you
Brief flashes of fire/space/bombs/c4/dangerous shit (done)
Items that are rare/traitorous/don't exist appearing in your inventory slots (done)
Strange audio (should be rare) (done)
Gunshots/explosions/opening doors/less rare audio (done)

*/

/mob/living/carbon/
	var/image/halimage
	var/image/halbody
	var/obj/halitem
	var/hal_screwyhud = 0 //1 - critical, 2 - dead, 3 - oxygen indicator, 4 - toxin indicator
	var/handling_hal = 0
	var/hal_crit = 0

/mob/living/carbon/proc/handle_hallucinations()
	if(handling_hal)
		return
	handling_hal = 1
	while(hallucination > 20)
		sleep(rand(200,500)/(hallucination/25))
		var/halpick = rand(1,100)
		switch(halpick)
			if(0 to 15)
				//Screwy HUD
				//src << "Screwy HUD"
				hal_screwyhud = pick(1,2,3,3,4,4)
				spawn(rand(100,250))
					hal_screwyhud = 0
			if(16 to 25)
				//Strange items
				//src << "Traitor Items"
				if(!halitem)
					halitem = new
					var/list/slots_free = list(ui_lhand,ui_rhand)
					if(l_hand) slots_free -= ui_lhand
					if(r_hand) slots_free -= ui_rhand
					if(istype(src,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = src
						if(!H.belt) slots_free += ui_belt
						if(!H.l_store) slots_free += ui_storage1
						if(!H.r_store) slots_free += ui_storage2
					if(slots_free.len)
						halitem.screen_loc = pick(slots_free)
						halitem.layer = 50
						switch(rand(1,6))
							if(1) //revolver
								halitem.icon = 'icons/obj/guns/projectile.dmi'
								halitem.icon_state = "revolver"
								halitem.name = "Revolver"
							if(2) //c4
								halitem.icon = 'icons/obj/assemblies.dmi'
								halitem.icon_state = "plastic-explosive0"
								halitem.name = "Mysterious Package"
								if(prob(25))
									halitem.icon_state = "c4small_1"
							if(3) //sword
								halitem.icon = 'icons/obj/weapons.dmi'
								halitem.icon_state = "sword1"
								halitem.name = "Sword"
							if(4) //stun baton
								halitem.icon = 'icons/obj/weapons.dmi'
								halitem.icon_state = "stunbaton"
								halitem.name = "Stun Baton"
							if(5) //emag
								halitem.icon = 'icons/obj/card.dmi'
								halitem.icon_state = "emag"
								halitem.name = "Cryptographic Sequencer"
							if(6) //flashbang
								halitem.icon = 'icons/obj/grenade.dmi'
								halitem.icon_state = "flashbang1"
								halitem.name = "Flashbang"
						if(client) client.screen += halitem
						spawn(rand(100,250))
							qdel(halitem)
			if(26 to 40)
				//Flashes of danger
				//src << "Danger Flash"
				if(!halimage)
					var/list/possible_points = list()
					for(var/turf/simulated/floor/F in view(src,world.view))
						possible_points += F
					if(possible_points.len)
						var/turf/simulated/floor/target = pick(possible_points)

						switch(rand(1,3))
							if(1)
								//src << "Space"
								halimage = image('icons/turf/space.dmi',target,"[rand(1,25)]",TURF_LAYER)
							if(2)
								//src << "Fire"
								halimage = image('icons/effects/fire.dmi',target,"1",TURF_LAYER)
							if(3)
								//src << "C4"
								halimage = image('icons/obj/assemblies.dmi',target,"plastic-explosive2",OBJ_LAYER+0.01)


						if(client) client.images += halimage
						spawn(rand(10,50)) //Only seen for a brief moment.
							if(client) client.images -= halimage
							halimage = null


			if(41 to 65)
				//Strange audio
				//src << "Strange Audio"
				switch(rand(1,14))
					if(1) src << 'sound/machines/airlock.ogg'
					if(2)
						if(prob(50))src << 'sound/effects/Explosion1.ogg'
						else src << 'sound/effects/Explosion2.ogg'
					if(3) src << 'sound/effects/explosionfar.ogg'
					if(4) src << 'sound/effects/Glassbr1.ogg'
					if(5) src << 'sound/effects/Glassbr2.ogg'
					if(6) src << 'sound/effects/Glassbr3.ogg'
					if(7) src << 'sound/machines/twobeep.ogg'
					if(8) src << 'sound/machines/windowdoor.ogg'
					if(9)
						//To make it more realistic, I added two gunshots (enough to kill)
						src << 'sound/weapons/Gunshot.ogg'
						spawn(rand(10,30))
							src << 'sound/weapons/Gunshot.ogg'
					if(10) src << 'sound/weapons/smash.ogg'
					if(11)
						//Same as above, but with tasers.
						src << 'sound/weapons/Taser.ogg'
						spawn(rand(10,30))
							src << 'sound/weapons/Taser.ogg'
				//Rare audio
					if(12)
//These sounds are (mostly) taken from Hidden: Source
						var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
							'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
							'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
							'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
							'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
						src << pick(creepyasssounds)
					if(13)
						src << "<span class='warning'>You feel a tiny prick!</span>"
					if(14)
						src << "<h1 class='alert'>Priority Announcement</h1>"
						src << "<br><br><span class='alert'>The Emergency Shuttle has docked with the station. You have 3 minutes to board the Emergency Shuttle.</span><br><br>"
						src << sound('sound/AI/shuttledock.ogg')
			if(66 to 70)
				//Flashes of danger
				if(!halbody)
					var/list/possible_points = list()
					for(var/turf/simulated/floor/F in view(src,world.view))
						possible_points += F
					if(possible_points.len)
						var/turf/simulated/floor/target = pick(possible_points)
						switch(rand(1,4))
							if(1)
								halbody = image('icons/mob/human.dmi',target,"husk_l",TURF_LAYER)
							if(2,3)
								halbody = image('icons/mob/human.dmi',target,"husk_s",TURF_LAYER)
							if(4)
								halbody = image('icons/mob/alien.dmi',target,"alienother",TURF_LAYER)

						if(client) client.images += halbody
						spawn(rand(50,80)) //Only seen for a brief moment.
							if(client) client.images -= halbody
							halbody = null
			if(71 to 72)
				//Fake death
				src.sleeping = 20
				hal_crit = 1
				hal_screwyhud = 1
				spawn(rand(50,100))
					src.sleeping = 0
					hal_crit = 0
					hal_screwyhud = 0
			if(73 to 75) //severe hallucinations
				hallucinate(pick("fake","flood","xeno","singulo","delusion","battle"))
	handling_hal = 0

/obj/effect/hallucination
	invisibility = INVISIBILITY_OBSERVER
	var/mob/living/carbon/target = null

/obj/effect/hallucination/simple
	var/image_icon = 'icons/mob/alien.dmi'
	var/image_state = "alienh_pounce"
	var/px = 0
	var/py = 0
	var/col_mod = null
	var/image/current_image = null
	var/image_layer = MOB_LAYER
	var/active = 1 //qdelery

/obj/effect/hallucination/simple/New(loc,var/mob/living/carbon/T)
	target = T
	current_image = GetImage()
	if(target.client) target.client.images |= current_image
	return

/obj/effect/hallucination/simple/proc/GetImage()
	var/image/I = image(image_icon,loc,image_state,image_layer,dir=src.dir)
	I.pixel_x = px
	I.pixel_y = py
	if(col_mod)
		I.color = col_mod
	return I

/obj/effect/hallucination/simple/proc/Show(var/update=1)
	if(active)
		if(target.client) target.client.images.Remove(current_image)
		if(update)
			current_image = GetImage()
		if(target.client) target.client.images |= current_image

/obj/effect/hallucination/simple/update_icon(var/new_state,var/new_icon,var/new_px=0,var/new_py=0)
	image_state = new_state
	if(new_icon)
		image_icon = new_icon
	else
		image_icon = initial(image_icon)
	px = new_px
	py = new_py
	Show()

/obj/effect/hallucination/simple/Moved(atom/OldLoc, Dir)
	Show()
	return

/obj/effect/hallucination/simple/Destroy()
	if(target.client) target.client.images.Remove(current_image)
	active = 0

#define FAKE_FLOOD_EXPAND_TIME 30
#define FAKE_FLOOD_MAX_RADIUS 7

/obj/effect/hallucination/fake_flood
	//Plasma/N2O starts flooding from the nearby vent
	var/list/flood_images = list()
	var/list/turf/flood_turfs = list()
	var/image_icon = 'icons/effects/tile_effects.dmi'
	var/image_state = "plasma"
	var/radius = 0
	var/next_expand = 0

/obj/effect/hallucination/fake_flood/New(loc,var/mob/living/carbon/T)
	..()
	target = T
	for(var/obj/machinery/atmospherics/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			src.loc = U.loc
			break
	image_state = pick("plasma","sleeping_agent")
	flood_images += image(image_icon,src,image_state,MOB_LAYER)
	flood_turfs += get_turf(loc)
	if(target.client) target.client.images |= flood_images
	next_expand = world.time + FAKE_FLOOD_EXPAND_TIME
	SSobj.processing |= src

/obj/effect/hallucination/fake_flood/process()
	if(next_expand <= world.time)
		radius += 1
		if(radius > FAKE_FLOOD_MAX_RADIUS)
			qdel(src)
		Expand()
		next_expand = world.time + FAKE_FLOOD_EXPAND_TIME
	return

/obj/effect/hallucination/fake_flood/proc/Expand()
	for(var/turf/T in circlerangeturfs(loc,radius)) //Todo : Make it do actual flood
		if((T in flood_turfs)|| T.blocks_air)
			continue
		flood_images += image(image_icon,T,image_state,MOB_LAYER)
		flood_turfs += T
	if(target.client) target.client.images |= flood_images
	return

/obj/effect/hallucination/fake_flood/Destroy()
	SSobj.processing.Remove(src)
	del(flood_turfs)
	if(target.client) target.client.images.Remove(flood_images)
	target = null
	del(flood_images)
	return

/obj/effect/hallucination/simple/xeno
	image_icon = 'icons/mob/alien.dmi'
	image_state = "alienh_pounce"

/obj/effect/hallucination/simple/xeno/New(loc,var/mob/living/carbon/T)
	..()
	name = "alien hunter ([rand(1, 1000)])"
	return

/obj/effect/hallucination/simple/xeno/throw_at(atom/target, range, speed) // TODO : Make diagonal trhow into proc/property
	if(!target || !src || (flags & NODROP))	return 0

	src.throwing = 1

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dist_travelled = 0
	var/dist_since_sleep = 0

	var/tdist_x = dist_x;
	var/tdist_y = dist_y;

	if(dist_x <= dist_y)
		tdist_x = dist_y;
		tdist_y = dist_x;

	var/error = tdist_x/2 - tdist_y
	while(target && (((((dist_x > dist_y) && ((src.x < target.x) || (src.x > target.x))) || ((dist_x <= dist_y) && ((src.y < target.y) || (src.y > target.y))) || (src.x > target.x)) && dist_travelled < range) || !has_gravity(src)))

		if(!src.throwing) break
		if(!istype(src.loc, /turf)) break

		var/atom/step = get_step(src, get_dir(src,target))
		if(!step)
			break
		src.Move(step, get_dir(src, step))
		hit_check()
		error += (error < 0) ? tdist_x : -tdist_y;
		dist_travelled++
		dist_since_sleep++
		if(dist_since_sleep >= speed)
			dist_since_sleep = 0
			sleep(1)


	src.throwing = 0
	src.throw_impact(get_turf(src))
	
	return 1

/obj/effect/hallucination/simple/xeno/throw_impact(A)
	update_icon("alienh_pounce")
	if(A == target)
		target.Weaken(5)
		target << "<span class ='userdanger'>[name] pounces on you!</span>" //Todo : make this flailing for observers ?

/obj/effect/hallucination/xeno_attack
	//Xeno crawls from nearby vent,jumps at you, and goes back in
	var/obj/machinery/atmospherics/unary/vent_pump/pump = null
	var/obj/effect/hallucination/simple/xeno/xeno = null

/obj/effect/hallucination/xeno_attack/New(loc,var/mob/living/carbon/T)
	target = T
	for(var/obj/machinery/atmospherics/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			pump = U
			break
	xeno = new(pump.loc,target)
	sleep(10)
	xeno.update_icon("alienh_leap",'icons/mob/alienleap.dmi',-32,-32)
	xeno.throw_at(target,7,1)
	sleep(10)
	xeno.update_icon("alienh_leap",'icons/mob/alienleap.dmi',-32,-32)
	xeno.throw_at(pump,7,1)
	sleep(10)
	var/xeno_name = xeno.name
	target << "<span class='notice'>[xeno_name] begins climbing into the ventilation system...</span>"
	sleep(10)
	qdel(xeno)
	target << "<span class='notice'>[xeno_name] scrambles into the ventilation ducts!</span>"
	qdel(src)

/obj/effect/hallucination/singularity_scare
	//Singularity moving towards you.
	//todo Hide where it moved with fake space images
	var/obj/effect/hallucination/simple/singularity/s = null

/obj/effect/hallucination/singularity_scare/New(loc,var/mob/living/carbon/T)
	target = T
	var/turf/start = T.loc
	var/screen_border = pick(SOUTH,EAST,WEST,NORTH)
	for(var/i = 0,i<11,i++)
		start = get_step(start,screen_border)
	s = new(start,target)
	for(var/i = 0,i<11,i++)
		sleep(5)
		s.loc = get_step(get_turf(s),get_dir(s,target))
		s.Show()
		s.Eat()
	qdel(s)

/obj/effect/hallucination/simple/singularity
	image_icon = 'icons/effects/224x224.dmi'
	image_state = "singularity_s7"
	image_layer = 6
	px = -96
	py = -96

/obj/effect/hallucination/simple/singularity/proc/Eat(atom/OldLoc, Dir)
	var/target_dist = get_dist(src,target)
	if(target_dist<=3) //"Eaten"
		target.sleeping = 20
		target.hal_crit = 1
		target.hal_screwyhud = 1
		spawn(rand(50,100))
			target.sleeping = 0
			target.hal_crit = 0
			target.hal_screwyhud = 0

/obj/effect/hallucination/battle

/obj/effect/hallucination/battle/New(loc,var/mob/living/carbon/T)
	target = T
	var/hits = rand(3,5)
	switch(rand(1,3))
		if(1) //Laser fight
			for(var/i=0,i<hits,i++)
				target << sound('sound/weapons/Laser.ogg',0,1,0,25)
				sleep(rand(1,5))
			target << sound(get_sfx("bodyfall"),0,1,0,25)
		if(2) //Esword fight
			target << sound('sound/weapons/saberon.ogg',,0,1,0,15)
			for(var/i=0,i<hits,i++)
				target << sound('sound/weapons/blade1.ogg',,0,1,0,25)
				sleep(rand(1,5))
			target << sound(get_sfx("bodyfall"),0,1,0,25)
		if(3) //Gun fight
			for(var/i=0,i<hits,i++)
				target << sound(get_sfx("gunshot"),0,1,0,25)
				sleep(rand(1,5))
			target << sound(get_sfx("bodyfall"),0,1,0,25)
	qdel(src)


/obj/effect/hallucination/delusion
	var/list/image/delusions = list()

/obj/effect/hallucination/delusion/New(loc,var/mob/living/carbon/T)
	target = T
	var/image/A = null
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H == target)
			continue
		if(H in view(target))
			continue
		A = image('icons/mob/animal.dmi',H,"clown") //Todo : pick from diffrent stuff. Aliens/Lings/Clowns/Carp
		A.override = 1
		if(target.client)
			delusions |= A
			target.client.images |= A
	sleep(300)
	for(var/image/I in delusions)
		if(target.client)
			target.client.images.Remove(I)
	qdel(src)

/obj/effect/hallucination/fakeattacker/New(loc,var/mob/living/carbon/T)
	target = T
	var/mob/living/carbon/human/clone = null
	var/clone_weapon = null

	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H.stat || H.lying)
			continue
		clone = H
		break

	if(!clone)
		return

	var/obj/effect/fake_attacker/F = new/obj/effect/fake_attacker(get_turf(target),target)
	if(clone.l_hand)
		if(!(locate(clone.l_hand) in non_fakeattack_weapons))
			clone_weapon = clone.l_hand.name
			F.weap = clone.l_hand
	else if (clone.r_hand)
		if(!(locate(clone.r_hand) in non_fakeattack_weapons))
			clone_weapon = clone.r_hand.name
			F.weap = clone.r_hand

	F.name = clone.name
	F.my_target = target
	F.weapon_name = clone_weapon

	F.left = image(clone,dir = WEST)
	F.right = image(clone,dir = EAST)
	F.up = image(clone,dir = NORTH)
	F.down = image(clone,dir = SOUTH)

	F.updateimage()
	qdel(src)

/obj/effect/fake_attacker
	icon = null
	icon_state = null
	name = ""
	desc = ""
	density = 0
	anchored = 1
	opacity = 0
	var/mob/living/carbon/human/my_target = null
	var/weapon_name = null
	var/obj/item/weap = null
	var/image/stand_icon = null
	var/image/currentimage = null
	var/icon/base = null
	var/skin_tone
	var/mob/living/clone = null
	var/image/left
	var/image/right
	var/image/up
	var/collapse
	var/image/down

	var/health = 100

/obj/effect/fake_attacker/attackby(var/obj/item/weapon/P as obj, mob/living/user as mob, params)
	step_away(src,my_target,2)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	my_target << sound(pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg'))
	my_target.visible_message("<span class='danger'>[my_target] flails around wildly.</span>", \
							"<span class='danger'>[my_target] has attacked [src]!</span>")

	src.health -= P.force
	return

/obj/effect/fake_attacker/Crossed(var/mob/M, somenumber)
	if(M == my_target)
		step_away(src,my_target,2)
		if(prob(30))
			for(var/mob/O in oviewers(world.view , my_target))
				O << "<span class='danger'>[my_target] stumbles around.</span>"

/obj/effect/fake_attacker/New(loc,var/mob/living/carbon/T)
	..()
	my_target = T
	spawn(300)
		qdel(src)
	step_away(src,my_target,2)
	spawn(0)
		attack_loop()


/obj/effect/fake_attacker/proc/updateimage()
//	del src.currentimage
	if(src.dir == NORTH)
		del src.currentimage
		src.currentimage = new /image(up,src)
	else if(src.dir == SOUTH)
		del src.currentimage
		src.currentimage = new /image(down,src)
	else if(src.dir == EAST)
		del src.currentimage
		src.currentimage = new /image(right,src)
	else if(src.dir == WEST)
		del src.currentimage
		src.currentimage = new /image(left,src)
	my_target << currentimage


/obj/effect/fake_attacker/proc/attack_loop()
	while(1)
		sleep(rand(5,10))
		if(src.health < 0)
			collapse()
			continue
		if(get_dist(src,my_target) > 1)
			src.dir = get_dir(src,my_target)
			step_towards(src,my_target)
			updateimage()
		else
			if(prob(15))
				src.do_attack_animation(my_target)
				if(weapon_name)
					my_target << sound(pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg'))
					my_target.show_message("<span class='danger'>[src.name] has attacked [my_target] with [weapon_name]!</span>", 1)
					my_target.staminaloss += 30
					if(prob(20))
						my_target.eye_blurry += 3
					if(prob(33))
						if(!locate(/obj/effect/overlay) in my_target.loc)
							fake_blood(my_target)
				else
					my_target << sound(pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg'))
					my_target.show_message("<span class='userdanger'>[src.name] has punched [my_target]!</span>", 1)
					my_target.staminaloss += 30
					if(prob(33))
						if(!locate(/obj/effect/overlay) in my_target.loc)
							fake_blood(my_target)

		if(prob(15))
			step_away(src,my_target,2)

/obj/effect/fake_attacker/proc/collapse()
	collapse = 1
	updateimage()

/obj/effect/fake_attacker/proc/fake_blood(var/mob/target)
	var/obj/effect/overlay/O = new/obj/effect/overlay(target.loc)
	O.name = "blood"
	var/image/I = image('icons/effects/blood.dmi',O,"floor[rand(1,7)]",O.dir,1)
	target << I
	spawn(300)
		qdel(O)
	return

var/list/non_fakeattack_weapons = list(/obj/item/weapon/gun/projectile, /obj/item/ammo_box/a357,\
	/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow, /obj/item/weapon/melee/energy/sword/saber,\
	/obj/item/weapon/storage/box/syndicate, /obj/item/weapon/storage/box/emps,\
	/obj/item/weapon/cartridge/syndicate, /obj/item/clothing/under/chameleon,\
	/obj/item/clothing/shoes/sneakers/syndigaloshes, /obj/item/weapon/card/id/syndicate,\
	/obj/item/clothing/mask/gas/voice, /obj/item/clothing/glasses/thermal,\
	/obj/item/device/chameleon, /obj/item/weapon/card/emag,\
	/obj/item/weapon/storage/toolbox/syndicate, /obj/item/weapon/aiModule,\
	/obj/item/device/radio/headset/syndicate,	/obj/item/weapon/c4,\
	/obj/item/device/powersink, /obj/item/weapon/storage/box/syndie_kit,\
	/obj/item/toy/syndicateballoon, /obj/item/weapon/gun/energy/laser/captain,\
	/obj/item/weapon/hand_tele, /obj/item/weapon/rcd, /obj/item/weapon/tank/jetpack,\
	/obj/item/clothing/under/rank/captain, /obj/item/device/aicard,\
	/obj/item/clothing/shoes/magboots, /obj/item/areaeditor/blueprints, /obj/item/weapon/disk/nuclear,\
	/obj/item/clothing/suit/space/nasavoid, /obj/item/weapon/tank)

/obj/effect/hallucination/bolts
	var/list/doors = list()

/obj/effect/hallucination/bolts/New(loc,var/mob/living/carbon/T,var/door_number=-1) //-1 for sever 1-2 for subtle
	target = T
	var/image/I = null
	var/count = 0
	for(var/obj/machinery/door/airlock/A in range(target,7))
		if(count>door_number && door_number>0)
			break
		count++
		I = image(A.icon,A,"door_locked",layer=A.layer+0.1)
		doors += I
		if(target.client)
			target.client.images |= I
		sleep(2)
	sleep(100)
	for(var/image/B in doors)
		if(target.client)
			target.client.images.Remove(B)
	qdel(src)


/mob/living/carbon/proc/hallucinate(var/hal_type) // Todo -> proc / defines
	switch(hal_type)
		if("xeno")
			new /obj/effect/hallucination/xeno_attack(src.loc,src)
		if("singulo")
			new /obj/effect/hallucination/singularity_scare(src.loc,src)
		if("battle")
			new /obj/effect/hallucination/battle(src.loc,src)
		if("flood")
			new /obj/effect/hallucination/fake_flood(src.loc,src)
		if("delusion")
			new /obj/effect/hallucination/delusion(src.loc,src)
		if("fake")
			new /obj/effect/hallucination/fakeattacker(src.loc,src)
		if("bolts")
			new /obj/effect/hallucination/bolts(src.loc,src)
