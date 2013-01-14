//this is everything i'm going to be using in my outpost zeta map, and possibly future maps.

turf/unsimulated/desert
	name = "desert"
	icon = 'desert.dmi'
	icon_state = "desert"
	temperature = 393.15
	luminosity = 5
	lighting_lumcount = 8

turf/unsimulated/desert/New()
	icon_state = "desert[rand(0,4)]"

/area/awaymission/labs/researchdivision
	name = "Research"
	icon_state = "away3"

/area/awaymission/labs/militarydivision
	name = "Military"
	icon_state = "away2"

/area/awaymission/labs/gateway
	name = "Gateway"
	icon_state = "away1"

/area/awaymission/labs/command
	name = "Command"
	icon_state = "away"

/area/awaymission/labs/civilian
	name = "Civilian"
	icon_state = "away3"

/area/awaymission/labs/cargo
	name = "Cargo"
	icon_state = "away2"

/area/awaymission/labs/medical
	name = "Medical"
	icon_state = "away1"

/area/awaymission/labs/security
	name = "Security"
	icon_state = "away"

/area/awaymission/labs/solars
	name = "Solars"
	icon_state = "away3"

/area/awaymission/labs/cave
	name = "Caves"
	icon_state = "away2"

//corpses and possibly other decorative items

/obj/effect/landmark/corpse/alien
	mutantrace = "lizard"

/obj/effect/landmark/corpse/alien/cargo
	name = "Cargo Technician"
	corpseuniform = /obj/item/clothing/under/rank/cargo
	corpseradio = /obj/item/device/radio/headset/headset_cargo
	corpseid = 1
	corpseidjob = "Cargo Technician"
	corpseidaccess = "Quartermaster"

/obj/effect/landmark/corpse/alien/laborer
	name = "Laborer"
	corpseuniform = /obj/item/clothing/under/overalls
	corpseradio = /obj/item/device/radio/headset/headset_eng
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpsebelt = /obj/item/weapon/storage/belt/utility/full
	corpsehelmet = /obj/item/clothing/head/hardhat
	corpseid = 1
	corpseidjob = "Laborer"
	corpseidaccess = "Engineer"

/obj/effect/landmark/corpse/alien/testsubject
	name = "Unfortunate Test Subject"
	corpseuniform = /obj/item/clothing/under/color/white
	corpseid = 0

/obj/effect/landmark/corpse/overseer
	name = "Overseer"
	corpseuniform = /obj/item/clothing/under/rank/navyhead_of_security
	corpsesuit = /obj/item/clothing/suit/armor/hosnavycoat
	corpseradio = /obj/item/device/radio/headset/heads/captain
	corpsegloves = /obj/item/clothing/gloves/black/hos
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsehelmet = /obj/item/clothing/head/beret/navyhos
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpseid = 1
	corpseidjob = "Facility Overseer"
	corpseidaccess = "Captain"

/obj/effect/landmark/corpse/officer
	name = "Security Officer"
	corpseuniform = /obj/item/clothing/under/rank/navysecurity
	corpsesuit = /obj/item/clothing/suit/armor/navysecvest
	corpseradio = /obj/item/device/radio/headset/headset_sec
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsehelmet = /obj/item/clothing/head/beret/navysec
	corpseid = 1
	corpseidjob = "Security Officer"
	corpseidaccess = "Security Officer"

/*
 * Weeds
 */
#define NODERANGE 1

/obj/effect/alien/flesh/weeds
	name = "Fleshy Growth"
	desc = "A pulsating grouping of odd, alien tissues. It's almost like it has a heartbeat..."
	icon = 'biocraps.dmi'
	icon_state = "flesh"

	anchored = 1
	density = 0
	var/health = 15
	var/obj/effect/alien/weeds/node/linked_node = null

/obj/effect/alien/flesh/weeds/node
	icon_state = "fleshnode"
	icon = 'biocraps.dmi'
	name = "Throbbing Pustule"
	desc = "A grotquese, oozing, pimple-like growth. You swear you can see something moving around in the bulb..."
	luminosity = NODERANGE
	var/node_range = NODERANGE

/obj/effect/alien/flesh/weeds/node/New()
	..(src.loc, src)


/obj/effect/alien/flesh/weeds/New(pos, node)
	..()
	linked_node = node
	if(istype(loc, /turf/space))
		del(src)
		return
	if(icon_state == "flesh")icon_state = pick("flesh", "flesh1", "flesh2")
	spawn(rand(150, 200))
		if(src)
			Life()
	return

/obj/effect/alien/flesh/weeds/proc/Life()
	set background = 1
	var/turf/U = get_turf(src)
/*
	if (locate(/obj/movable, U))
		U = locate(/obj/movable, U)
		if(U.density == 1)
			del(src)
			return

Alien plants should do something if theres a lot of poison
	if(U.poison> 200000)
		health -= round(U.poison/200000)
		update()
		return
*/
	if (istype(U, /turf/space))
		del(src)
		return

	direction_loop:
		for(var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || locate(/obj/effect/alien/flesh/weeds) in T || istype(T.loc, /area/arrival) || istype(T, /turf/space))
				continue

			if(!linked_node || get_dist(linked_node, src) > linked_node.node_range)
				return

	//		if (locate(/obj/movable, T)) // don't propogate into movables
	//			continue

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

			new /obj/effect/alien/flesh/weeds(T, linked_node)


/obj/effect/alien/flesh/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				del(src)
		if(3.0)
			if (prob(5))
				del(src)
	return

/obj/effect/alien/flesh/weeds/attackby(var/obj/item/weapon/W, var/mob/user)
	if(W.attack_verb.len)
		visible_message("\red <B>\The [src] has been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()

/obj/effect/alien/flesh/weeds/proc/healthcheck()
	if(health <= 0)
		del(src)


/obj/effect/alien/flesh/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/*/obj/effect/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		spawn( 0 )
			del(src)
			return
		return 0
	return 1
*/

#undef NODERANGE

//clothing, weapons, and other items that can be worn or used in some way

/obj/item/clothing/under/rank/navywarden
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word \"Warden\" written on the shoulders."
	name = "warden's jumpsuit"
	icon_state = "wardendnavyclothes"
	item_state = "wardendnavyclothes"
	color = "wardendnavyclothes"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = FPRINT | TABLEPASS

/obj/item/clothing/under/rank/navysecurity
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "officerdnavyclothes"
	item_state = "officerdnavyclothes"
	color = "officerdnavyclothes"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = FPRINT | TABLEPASS

/obj/item/clothing/under/rank/navyhead_of_security
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's jumpsuit"
	icon_state = "hosdnavyclothes"
	item_state = "hosdnavyclothes"
	color = "hosdnavyclothes"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = FPRINT | TABLEPASS

/obj/item/clothing/suit/armor/hosnavycoat
	name = "armored coat"
	desc = "A coat enchanced with a special alloy for some protection and style."
	icon_state = "hosdnavyjacket"
	item_state = "armor"
	armor = list(melee = 65, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/head/beret/navysec
	name = "security beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "officerberet"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/beret/navywarden
	name = "warden's beret"
	desc = "A beret with a two-colored security insignia emblazoned on it. For wardens that are more inclined towards style than safety."
	icon_state = "wardenberet"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/beret/navyhos
	name = "security head's beret"
	desc = "A stylish beret bearing a golden insignia that proudly displays the security coat of arms. A commander's must-have."
	icon_state = "hosberet"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/suit/armor/navysecvest
	name = "armored coat"
	desc = "An armored coat that protects against some damage."
	icon_state = "officerdnavyjacket"
	item_state = "armor"
	flags = FPRINT | TABLEPASS
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/navywardenvest
	name = "Warden's jacket"
	desc = "An armoured jacket with silver rank pips and livery."
	icon_state = "wardendnavyjacket"
	item_state = "armor"
	flags = FPRINT | TABLEPASS
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

//hostile entities or npcs

/obj/item/projectile/slimeglob
	icon = 'projectiles.dmi'
	icon_state = "toxin"
	damage = 20
	damage_type = BRUTE

/obj/effect/critter/fleshmonster
	name = "Fleshy Horror"
	desc = "A grotesque, shambling fleshy horror... was this once a... a person?"
	icon = 'icons/mob/mob.dmi'
	icon_state = "horror"
/*
	health = 120
	max_health = 120
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = 1
	atkcarbon = 1
	atksilicon = 1
	atkcritter = 1
	atksame = 0
	atkmech = 1
	firevuln = 0.5
	brutevuln = 1
	seekrange = 25
	armor = 15
	melee_damage_lower = 12
	melee_damage_upper = 17
	angertext = "shambles"
	attacktext = "slashes"
	var/ranged = 0
	var/rapid = 0
	proc
		Shoot(var/target, var/start, var/user, var/bullet = 0)
		OpenFire(var/thing)//bluh ill rename this later or somethin


	Die()
		if (!src.alive) return
		src.alive = 0
		walk_to(src,0)
		src.visible_message("<b>[src]</b> disintegrates into mush!")
		playsound(loc, 'sound/voice/hiss6.ogg', 80, 1, 1)
		var/turf/Ts = get_turf(src)
		new /obj/effect/decal/cleanable/blood(Ts)
		del(src)

	seek_target()
		src.anchored = 0
		var/T = null
		for(var/mob/living/C in view(src.seekrange,src))//TODO: mess with this
			if (src.target)
				src.task = "chasing"
				break
			if((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if(istype(C, /mob/living/carbon/) && !src.atkcarbon) continue
			if(istype(C, /mob/living/silicon/) && !src.atksilicon) continue
			if(C.health < 0) continue
			if(istype(C, /mob/living/carbon/) && src.atkcarbon)
				if(C:mind)
					if(C:mind:special_role == "H.I.V.E")
						continue
				src.attack = 1
			if(istype(C, /mob/living/silicon/) && src.atksilicon)
				if(C:mind)
					if(C:mind:special_role == "H.I.V.E")
						continue
				src.attack = 1
			if(src.attack)
				T = C
				break

		if(!src.attack)
			for(var/obj/effect/critter/C in view(src.seekrange,src))
				if(istype(C, /obj/effect/critter) && !src.atkcritter) continue
				if(C.health <= 0) continue
				if(istype(C, /obj/effect/critter) && src.atkcritter)
					if((istype(C, /obj/effect/critter/hivebot) && !src.atksame) || (C == src))	continue
					T = C
					break

			for(var/obj/mecha/M in view(src.seekrange,src))
				if(istype(M, /obj/mecha) && !src.atkmech) continue
				if(M.health <= 0) continue
				if(istype(M, /obj/mecha) && src.atkmech) src.attack = 1
				if(src.attack)
					T = M
					break

		if(src.attack)
			src.target = T
			src.oldtarget_name = T:name
			if(src.ranged)
				OpenFire(T)
				return
			src.task = "chasing"
		return


	OpenFire(var/thing)
		src.target = thing
		src.oldtarget_name = thing:name
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <b>[src]</b> spits a glob at [src.target]!", 1)

		var/tturf = get_turf(target)
		if(rapid)
			spawn(1)
				Shoot(tturf, src.loc, src)
			spawn(4)
				Shoot(tturf, src.loc, src)
			spawn(6)
				Shoot(tturf, src.loc, src)
		else
			Shoot(tturf, src.loc, src)

		src.attack = 0
		sleep(12)
		seek_target()
		src.task = "thinking"
		return


	Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(target == start)
			return

		var/obj/item/projectile/slimeglob/A = new /obj/item/projectile/slimeglob(user:loc)
		playsound(user, 'sound/weapons/bite.ogg', 100, 1)

		if(!A)	return

		if (!istype(target, /turf))
			del(A)
			return
		A.current = target
		A.yo = target:y - start:y
		A.xo = target:x - start:x
		spawn( 0 )
			A.process()
		return
*/

obj/effect/critter/fleshmonster/fleshslime
	name = "Flesh Slime"
	icon = 'biocraps.dmi'
	icon_state = "livingflesh"
	desc = "A creature that appears to be made out of living tissue strewn together haphazardly. Some kind of liquid bubbles from its maw."
	//ranged = 1