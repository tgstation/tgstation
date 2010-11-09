/obj/mecha/combat
	deflect_chance = 20
	health = 500

	var/weapon_1 = null
	var/weapon_1_cooldown = 0
	var/weapon_1_ready = 1
	var/weapon_1_name = "some weapon"
	var/weapon_1_energy_drain = 0
	var/weapon_2 = null
	var/weapon_2_cooldown = 0
	var/weapon_2_ready = 1
	var/weapon_2_name = "another weapon"
	var/weapon_2_energy_drain = 0
	var/selected_weapon = 1
	var/overload = 0
	var/melee_damage = 20
	req_access = access_heads

/obj/mecha/combat/verb/switch_weapon()
	set category = "Exosuit Interface"
	set name = "Switch weapon"
	set src in view(0)
	if(state || !cell || cell.charge<=0) return
	if(usr!=src.occupant)
		return
	if(selected_weapon == 1)
		selected_weapon = 2
		src.occupant << "You switch to [weapon_2_name]"
		for (var/mob/M in oviewers(src))
			M.show_message("[src.name] raises [weapon_2_name]")
	else if(selected_weapon == 2)
		selected_weapon = 1
		src.occupant << "You switch to [weapon_1_name]"
		for (var/mob/M in oviewers(src))
			M.show_message("[src.name] raises [weapon_1_name]")
	return

/obj/mecha/combat/verb/overload()
	set category = "Exosuit Interface"
	set name = "Toggle leg actuators overload"
	set src in view(0)
	if(overload)
		overload = 0
		step_in = initial(step_in)
		src.occupant << "\blue You disable leg actuators overload."
	else
		overload = 1
		step_in = min(1, round(step_in/2))
		src.occupant << "\red You enable leg actuators overload."


/obj/mecha/combat/click_action(target)
	if(state || !cell || cell.charge<=0) return
	if(get_dist(src,target)<=1)
		src.mega_punch(target)

/*
		if(src.occupant.a_intent == "hurt")
			src.mega_punch(target)
		else if(src.occupant.a_intent == "help")
			src.mega_shake(target)
*/
	else
		src.fire(src.selected_weapon,target)
	return


/obj/mecha/combat/proc/fire(weapon_num,target)
	var/turf/curloc = src.loc
	var/atom/targloc = get_turf(target)
	if (!targloc || !istype(targloc, /turf) || !curloc)
		return
	var/weapon_type
	switch(weapon_num)
		if(1)
			if(weapon_1_ready)
				weapon_type = weapon_1
				weapon_1_ready = 0
				spawn(weapon_1_cooldown)
					cell.use(weapon_1_energy_drain)
					weapon_1_ready = 1
		if(2)
			if(weapon_2_ready)
				weapon_type = weapon_2
				weapon_2_ready = 0
				spawn(weapon_2_cooldown)
					cell.use(weapon_2_energy_drain)
					weapon_2_ready = 1


	if(!weapon_type) return


	playsound(src, 'Laser.ogg', 50, 1)
	if (targloc == curloc)
		src.bullet_act(PROJECTILE_PULSE)
		return

	var/obj/beam/a_laser/A = new weapon_type(src.loc)
	A.current = curloc
	A.yo = targloc.y - curloc.y
	A.xo = targloc.x - curloc.x
	spawn()
		A.process()

	return

/obj/mecha/combat/proc/mega_punch(target)
	if(!istype(target, /obj) && !istype(target, /mob)) return
	if(istype(target, /mob))
		var/mob/M = target
		M.bruteloss += rand(melee_damage/2, melee_damage)
		M.paralysis += 1
		M.updatehealth()
		step_away(M,src,15)
		for (var/mob/V in viewers(src))
			V.show_message("[src.name] sends [M] flying.")
	return

/*
/obj/mecha/combat/proc/mega_shake(target)
	if(!istype(target, /obj) && !istype(target, /mob)) return
	if(istype(target, /mob))
		var/mob/M = target
		M.make_dizzy(3)
		M.bruteloss += 1
		M.updatehealth()
		for (var/mob/V in viewers(src))
			V.show_message("[src.name] shakes [M] like a rag doll.")
	return
*/

/obj/mecha/combat/relaymove(mob/user,direction)
	if(!..()) return
	if(overload)
		cell.use(step_energy_drain)
		health--
		if(health < initial(health) - initial(health)/3)
			overload = 0
			src.occupant << "\red Leg actuators damage treshold exceded. Disabling overload."


/*
	if(energy>0 && can_move)
		if(step(src,direction))
			can_move = 0
			spawn(step_in) can_move = 1
			if(overload)
				energy = energy-2
				health--
			else
				energy--
			return 1

	return 0
*/