
/*
	run_armor_check(a,b)
	args
	a:def_zone - What part is getting hit, if null will check entire body
	b:attack_flag - What type of attack, bullet, laser, energy, melee

	Returns
	0 - no block
	1 - halfblock
	2 - fullblock
*/
/mob/living/proc/run_armor_check(var/def_zone = null, var/attack_flag = "melee", var/absorb_text = null, var/soften_text = null)
	var/armor = getarmor(def_zone, attack_flag)
	var/absorb = 0
	if(prob(armor))
		absorb += 1
	if(prob(armor))
		absorb += 1
	if(absorb >= 2)
		if(absorb_text)
			show_message("[absorb_text]")
		else
			show_message("\red Your armor absorbs the blow!")
		return 2
	if(absorb == 1)
		if(absorb_text)
			show_message("[soften_text]",4)
		else
			show_message("\red Your armor softens the blow!")
		return 1
	return 0


/mob/living/proc/getarmor(var/def_zone, var/type)
	return 0


/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	var/obj/item/weapon/cloaking_device/C = locate((/obj/item/weapon/cloaking_device) in src)
	if(C && C.active)
		C.attack_self(src)//Should shut it off
		update_icons()
		src << "\blue Your [C.name] was disrupted!"
		Stun(2)

	flash_weak_pain()

	if(istype(equipped(),/obj/item/device/assembly/signaler))
		var/obj/item/device/assembly/signaler/signaler = equipped()
		if(signaler.deadman && prob(80))
			src.visible_message("\red [src] triggers their deadman's switch!")
			signaler.signal()

	var/absorb = run_armor_check(def_zone, P.flag)
	if(absorb >= 2)
		P.on_hit(src,2)
		return 2
	if(!P.nodamage)
		apply_damage((P.damage/(absorb+1)), P.damage_type, def_zone, absorb, 0, used_weapon = P)
	P.on_hit(src, absorb)
	if(istype(P, /obj/item/projectile/beam/lightning))
		if(P.damage >= 200)
			src.dust()
	return absorb

/mob/living/hitby(atom/movable/AM as mob|obj,var/speed = 5)//Standardization and logging -Sieve
	if(flags & INVULNERABLE)
		return
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/zone = ran_zone("chest",75)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		src.visible_message("\red [src] has been hit by [O].")
		var/armor = run_armor_check(zone, "melee", "Your armor has protected your [zone].", "Your armor has softened hit to your [zone].")
		if(armor < 2)
			apply_damage(O.throwforce*(speed/5), dtype, zone, armor, O.sharp, O)

		if(!O.fingerprintslast)
			return

		var/client/assailant = directory[ckey(O.fingerprintslast)]
		if(assailant && assailant.mob && istype(assailant.mob,/mob))
			var/mob/M = assailant.mob

			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a thrown [O], last touched by [M.name] ([assailant.ckey])</font>")
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
			msg_admin_attack("[src.name] ([src.ckey]) was hit by a thrown [O], last touched by [M.name] ([assailant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")
			if(!iscarbon(M))
				src.LAssailant = null
			else
				src.LAssailant = M

			// Begin BS12 momentum-transfer code.

			if(speed >= 20)
				var/obj/item/weapon/W = O
				var/momentum = speed/2
				var/dir = get_dir(M,src)

				visible_message("\red [src] staggers under the impact!","\red You stagger under the impact!")
				src.throw_at(get_edge_target_turf(src,dir),1,momentum)

				if(istype(W.loc,/mob/living) && W.sharp) //Projectile is embedded and suitable for pinning.

					if(!istype(src,/mob/living/carbon/human)) //Handles embedding for non-humans and simple_animals.
						O.loc = src
						src.embedded += O

					var/turf/T = near_wall(dir,2)

					if(T)
						src.loc = T
						visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
						src.anchored = 1
						src.pinned += O


/mob/living/proc/near_wall(var/direction,var/distance=1)
	var/turf/T = get_step(get_turf(src),direction)
	var/turf/last_turf = src.loc
	var/i = 1

	while(i>0 && i<=distance)
		if(T.density) //Turf is a wall!
			return last_turf
		i++
		last_turf = T
		T = get_step(T,direction)

	return 0

// End BS12 momentum-transfer code.
//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		src.SetLuminosity(src.luminosity + 3)
		update_fire()

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		src.SetLuminosity(src.luminosity - 3)
		update_fire()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
    fire_stacks = Clamp(fire_stacks + add_fire_stacks, min = -20, max = 20)

/mob/living/proc/handle_fire()
	if((flags & INVULNERABLE) && on_fire)
		extinguish()
	if(fire_stacks < 0)
		fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1

	var/oxy=0
	var/turf/T=loc
	if(istype(T))
		var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
		if(G)
			oxy=G.oxygen
	if(oxy < 1 || fire_stacks <= 0)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return 1
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1,surfaces=1)

/mob/living/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	adjust_fire_stacks(0.5)
	IgniteMob()

//Mobs on Fire end