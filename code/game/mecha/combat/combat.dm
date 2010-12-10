/obj/mecha/combat
	deflect_chance = 10
	health = 500

	var/list/weapons = new
	var/datum/mecha_weapon/selected_weapon
	operation_req_access = list(access_security)
	internals_req_access = list(access_engine)
	var/force = 25
	var/damtype = "brute"
	var/melee_cooldown = 10
	var/melee_can_hit = 1
	var/list/destroyable_obj = list(/obj/mecha, /obj/window, /obj/grille, /turf/simulated/wall)

/*
/obj/mecha/combat/verb/switch_weapon()
	set category = "Exosuit Interface"
	set name = "Switch weapon"
	set src in view(0)
	if(usr!=src.occupant)
		return
	if(state || !cell || cell.charge<=0) return

	if(selected_weapon == weapon_1)
		selected_weapon = weapon_2
	else if(selected_weapon == weapon_2)
		selected_weapon = weapon_1

	src.occupant << "You switch to [selected_weapon.name]"
	for (var/mob/M in oviewers(src))
		M.show_message("[src.name] raises [selected_weapon.name]")
	return
*/

/obj/mecha/combat/range_action(target)
	if(selected_weapon)
		selected_weapon.fire(target)
	return

/obj/mecha/combat/melee_action(target)
	if(!melee_can_hit || (!istype(target, /obj) && !istype(target, /mob) && !istype(target, /turf))) return
	if(istype(target, /mob))
		playsound(src, 'punch4.ogg', 50, 1)
		var/mob/M = target
		if(damtype == "brute")
			step_away(M,src,15)
		if(M.stat>1)
			M.gib()
			return
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
//			if (M.health <= 0) return

			var/dam_zone = pick("chest", "chest", "chest", "head", "groin")
			if (istype(H.organs[dam_zone], /datum/organ/external))
				var/datum/organ/external/temp = H.organs[dam_zone]
				switch(damtype)
					if("brute")
						H.paralysis += 1
						temp.take_damage(rand(force/2, force), 0)
					if("fire")
						temp.take_damage(0, rand(force/2, force))
					if("tox")
						H.toxloss += rand(force/2, force)
					else
						return
				H.UpdateDamageIcon()
			H.updatehealth()

		else
			switch(damtype)
				if("brute")
					M.paralysis += 1
					M.bruteloss += rand(force/2, force)
				if("fire")
					M.fireloss += rand(force/2, force)
				if("tox")
					M.toxloss += rand(force/2, force)
				else
					return
			M.updatehealth()

		src.occupant.show_message("[src.name] hits [target].", 1)
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("[src.name] hits [target].", 1)

		melee_can_hit = 0
		spawn(melee_cooldown)
			melee_can_hit = 1
		return

	else
		if(damtype == "brute")
			for(var/target_type in src.destroyable_obj)
				if(istype(target, target_type) && hascall(target, "attackby"))
					src.occupant.show_message("[src.name] hits [target].", 1)
					src.visible_message("<font color='red'><b>[src.name] hits [target]</b></font>")
					for (var/mob/V in viewers(src))
						if(V.client && !(V.blinded))
							V.show_message("[src.name] hits [target].", 1)
					if(!istype(target, /turf/simulated/wall))
						target:attackby(src,src.occupant)
					else if(prob(2))
						target:dismantle_wall(1)
						src.occupant << text("\blue You smash through the wall.")
						src.visible_message("<b>[src.name] smashes through the wall</b>")
						playsound(src, 'smash.ogg', 50, 1)
					melee_can_hit = 0
					spawn(melee_cooldown)
						melee_can_hit = 1
					break
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
/obj/mecha/combat/Topic(href, href_list)
	..()
	if (href_list["select_weapon"])
		var/weapon = locate(href_list["select_weapon"])
		if(weapon)
			src.selected_weapon = weapon
	return


/obj/mecha/combat/move_inside()
	set name = "Move Inside"
	set src in oview(1)

	if (usr.stat != 0 || !istype(usr, /mob/living/carbon/human))
		return
	if (src.occupant)
		usr << "\blue <B>The [src.name] is already occupied!</B>"
		return
/*
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
*/
	if(!src.operation_allowed(usr))
		usr << "\red Access denied"
		return
	usr << "You start climbing into [src.name]"
	spawn(20)
		if(usr in range(1))
			usr.pulling = null
	//		usr.client.eye = src
			src.occupant = usr
			usr.loc = src
			src.add_fingerprint(usr)
			if(usr.client)
				usr.client.mouse_pointer_icon = file("icons/misc/mecha_mouse.dmi")
	return

/obj/mecha/combat/go_out()
	if(src.occupant && src.occupant.client)
		src.occupant.client.mouse_pointer_icon = initial(src.occupant.client.mouse_pointer_icon)
	..()
	return


/obj/mecha/combat/Del()
	for(var/weapon in weapons)
		del weapon
	..()
	return
