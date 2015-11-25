
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
			show_message("<span class='warning'>Your armor absorbs the blow!</span>")
		return 2
	if(absorb == 1)
		if(absorb_text)
			show_message("[soften_text]",4)
		else
			show_message("<span class='warning'>Your armor softens the blow!</span>")
		return 1
	return 0


/mob/living/proc/getarmor(var/def_zone, var/type)
	return 0


/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	var/obj/item/weapon/cloaking_device/C = locate((/obj/item/weapon/cloaking_device) in src)
	if(C && C.active)
		C.attack_self(src)//Should shut it off
		update_icons()
		to_chat(src, "<span class='notice'>Your [C.name] was disrupted!</span>")
		Stun(2)

	flash_weak_pain()

	if(istype(get_active_hand(),/obj/item/device/assembly/signaler))
		var/obj/item/device/assembly/signaler/signaler = get_active_hand()
		if(signaler.deadman && prob(80))
			src.visible_message("<span class='warning'>[src] triggers their deadman's switch!</span>")
			signaler.signal()

	var/absorb = run_armor_check(def_zone, P.flag)
	if(absorb >= 2)
		P.on_hit(src,2)
		return 2
	if(!P.nodamage)
		apply_damage((P.damage/(absorb+1)), P.damage_type, def_zone, absorb, 0, used_weapon = P)
		regenerate_icons()
	P.on_hit(src, absorb)
	if(istype(P, /obj/item/projectile/beam/lightning))
		if(P.damage >= 200)
			src.dust()
	return absorb

/mob/living/hitby(atom/movable/AM as mob|obj,var/speed = 5,var/dir)//Standardization and logging -Sieve
	if(flags & INVULNERABLE)
		return
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/zone = ran_zone("chest",75)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		src.visible_message("<span class='warning'>[src] has been hit by [O].</span>")
		var/zone_normal_name
		switch(zone)
			if("l_arm")
				zone_normal_name = "left arm"
			if("r_arm")
				zone_normal_name = "right arm"
			if("l_leg")
				zone_normal_name = "left leg"
			if("r_leg")
				zone_normal_name = "right leg"
			else
				zone_normal_name = zone
		var/armor = run_armor_check(zone, "melee", "Your armor has protected your [zone_normal_name].", "Your armor has softened hit to your [zone_normal_name].")
		if(armor < 2)
			apply_damage(O.throwforce*(speed/5), dtype, zone, armor, O.is_sharp(), O)

		// Begin BS12 momentum-transfer code.

		var/client/assailant = directory[ckey(O.fingerprintslast)]
		var/mob/M

		if(assailant && assailant.mob && istype(assailant.mob,/mob))
			M = assailant.mob

		if(speed >= 20)
			var/obj/item/weapon/W = O
			var/momentum = speed/2

			visible_message("<span class='warning'>[src] staggers under the impact!</span>","<span class='warning'>You stagger under the impact!</span>")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(istype(W.loc,/mob/living) && W.is_sharp()) //Projectile is embedded and suitable for pinning.

				if(!istype(src,/mob/living/carbon/human)) //Handles embedding for non-humans and simple_animals.
					O.loc = src
					src.embedded += O

				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
					src.anchored = 1
					src.pinned += O

		//Log stuf!

		if(!O.fingerprintslast)
			return

		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a thrown [O], last touched by [M.name] ([assailant.ckey]) (speed: [speed])</font>")
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O] (speed: [speed])</font>")
		msg_admin_attack("[src.name] ([src.ckey]) was hit by a thrown [O], last touched by [M.name] ([assailant.ckey]) (speed: [speed]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")
		if(!iscarbon(M))
			src.LAssailant = null
		else
			src.LAssailant = M



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
		set_light(src.light_range + 3)
		update_fire()

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		set_light(src.light_range - 3)
		update_fire()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
    fire_stacks = Clamp(fire_stacks + add_fire_stacks, -20, 20)

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

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.mind && H.mind.vampire && H.stat == DEAD)
			dust()

/mob/living/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	adjust_fire_stacks(0.5)
	IgniteMob()

//Mobs on Fire end
