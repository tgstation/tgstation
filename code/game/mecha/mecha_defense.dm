/obj/mecha/proc/get_armour_facing(relative_dir)
	switch(relative_dir)
		if(0) // BACKSTAB!
			return facing_modifiers[BACK_ARMOUR]
		if(45, 90, 270, 315)
			return facing_modifiers[SIDE_ARMOUR]
		if(225, 180, 135)
			return facing_modifiers[FRONT_ARMOUR]
	return 1 //always return non-0

/obj/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		spark_system.start()
		switch(damage_flag)
			if("fire")
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL))
			if("melee")
				check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			else
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT))
		if(. >= 5 || prob(33))
			occupant_message("<span class='userdanger'>Taking damage!</span>")
		log_append_to_last("Took [damage_amount] points of damage. Damage type: \"[damage_type]\".",1)

/obj/mecha/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	. = ..()
	var/booster_deflection_modifier = 1
	var/booster_damage_modifier = 1
	if(damage_flag == "bullet" || damage_flag == "laser" || damage_flag == "energy")
		for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
			if(B.projectile_react())
				booster_deflection_modifier = B.deflect_coeff
				booster_damage_modifier = B.damage_coeff
				break
	else if(damage_flag == "melee")
		for(var/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/B in equipment)
			if(B.attack_react())
				booster_deflection_modifier *= B.deflect_coeff
				booster_damage_modifier *= B.damage_coeff
				break

	if(attack_dir)
		var/facing_modifier = get_armour_facing(dir2angle(attack_dir) - dir2angle(src))
		booster_damage_modifier /= facing_modifier
		booster_deflection_modifier *= facing_modifier
	if(prob(deflect_chance * booster_deflection_modifier))
		visible_message("<span class='danger'>[src]'s armour deflects the attack!</span>")
		log_append_to_last("Armor saved.")
		return 0
	if(.)
		. *= booster_damage_modifier


/obj/mecha/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE) // Ugh. Ideally we shouldn't be setting cooldowns outside of click code.
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, 1, -1)
	user.visible_message("<span class='danger'>[user] hits [name]. Nothing happens</span>", null, null, COMBAT_MESSAGE_RANGE)
	log_message("Attack by hand/paw. Attacker - [user].",1)
	log_append_to_last("Armor saved.")

/obj/mecha/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/mecha/attack_alien(mob/living/user)
	log_message("Attack by alien. Attacker - [user].",1)
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	attack_generic(user, 15, BRUTE, "melee", 0)

/obj/mecha/attack_animal(mob/living/simple_animal/user)
	log_message("Attack by simple animal. Attacker - [user].",1)
	if(!user.melee_damage_upper && !user.obj_damage)
		user.emote("custom", message = "[user.friendly] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(user.environment_smash)
			play_soundeffect = 0
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		var/animal_damage = rand(user.melee_damage_lower,user.melee_damage_upper)
		if(user.obj_damage)
			animal_damage = user.obj_damage
		animal_damage = min(animal_damage, 20*user.environment_smash)
		attack_generic(user, animal_damage, user.melee_damage_type, "melee", play_soundeffect)
		add_logs(user, src, "attacked")
		return 1


/obj/mecha/hulk_damage()
	return 15

/obj/mecha/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(.)
		log_message("Attack by hulk. Attacker - [user].",1)
		add_logs(user, src, "punched", "hulk powers")

/obj/mecha/blob_act(obj/structure/blob/B)
	take_damage(30, BRUTE, "melee", 0, get_dir(src, B))

/obj/mecha/attack_tk()
	return

/obj/mecha/hitby(atom/movable/A as mob|obj) //wrapper
	log_message("Hit by [A].",1)
	. = ..()


/obj/mecha/bullet_act(obj/item/projectile/Proj) //wrapper
	log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)
	. = ..()

/obj/mecha/ex_act(severity, target)
	log_message("Affected by explosion of severity: [severity].",1)
	if(prob(deflect_chance))
		severity++
		log_append_to_last("Armor saved, changing severity to [severity].")
	. = ..()

/obj/mecha/contents_explosion(severity, target)
	severity++
	for(var/X in equipment)
		var/obj/item/mecha_parts/mecha_equipment/ME = X
		ME.ex_act(severity,target)
	for(var/Y in trackers)
		var/obj/item/mecha_parts/mecha_tracking/MT = Y
		MT.ex_act(severity, target)
	if(occupant)
		occupant.ex_act(severity,target)

/obj/mecha/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		icon_state = initial(icon_state)+"-open"
		setDir(dir_in)

/obj/mecha/emp_act(severity)
	if(get_charge())
		use_power((cell.charge/3)/(severity*2))
		take_damage(30 / severity, BURN, "energy", 1)
	log_message("EMP detected",1)
	check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)

/obj/mecha/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature>max_temperature)
		log_message("Exposed to dangerous temperature.",1)
		take_damage(5, BURN, 0, 1)

/obj/mecha/attackby(obj/item/W as obj, mob/user as mob, params)

	if(istype(W, /obj/item/device/mmi))
		if(mmi_move_inside(W,user))
			to_chat(user, "[src]-[W] interface initialized successfully.")
		else
			to_chat(user, "[src]-[W] interface initialization failed.")
		return

	if(istype(W, /obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/E = W
		spawn()
			if(E.can_attach(src))
				if(!user.drop_item())
					return
				E.attach(src)
				user.visible_message("[user] attaches [W] to [src].", "<span class='notice'>You attach [W] to [src].</span>")
			else
				to_chat(user, "<span class='warning'>You were unable to attach [W] to [src]!</span>")
		return
	if(W.GetID())
		if(add_req_access || maint_access)
			if(internals_access_allowed(user))
				var/obj/item/weapon/card/id/id_card
				if(istype(W, /obj/item/weapon/card/id))
					id_card = W
				else
					var/obj/item/device/pda/pda = W
					id_card = pda.id
				output_maintenance_dialog(id_card, user)
				return
			else
				to_chat(user, "<span class='warning'>Invalid ID: Access denied.</span>")
		else
			to_chat(user, "<span class='warning'>Maintenance protocols disabled by operator.</span>")
	else if(istype(W, /obj/item/weapon/wrench))
		if(state==1)
			state = 2
			to_chat(user, "<span class='notice'>You undo the securing bolts.</span>")
		else if(state==2)
			state = 1
			to_chat(user, "<span class='notice'>You tighten the securing bolts.</span>")
		return
	else if(istype(W, /obj/item/weapon/crowbar))
		if(state==2)
			state = 3
			to_chat(user, "<span class='notice'>You open the hatch to the power unit.</span>")
		else if(state==3)
			state=2
			to_chat(user, "<span class='notice'>You close the hatch to the power unit.</span>")
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		if(state == 3 && (internal_damage & MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/stack/cable_coil/CC = W
			if(CC.use(2))
				clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
				to_chat(user, "<span class='notice'>You replace the fused wires.</span>")
			else
				to_chat(user, "<span class='warning'>You need two lengths of cable to fix this mech!</span>")
		return
	else if(istype(W, /obj/item/weapon/screwdriver) && user.a_intent != INTENT_HARM)
		if(internal_damage & MECHA_INT_TEMP_CONTROL)
			clearInternalDamage(MECHA_INT_TEMP_CONTROL)
			to_chat(user, "<span class='notice'>You repair the damaged temperature controller.</span>")
		else if(state==3 && cell)
			cell.forceMove(loc)
			cell = null
			state = 4
			to_chat(user, "<span class='notice'>You unscrew and pry out the powercell.</span>")
			log_message("Powercell removed")
		else if(state==4 && cell)
			state=3
			to_chat(user, "<span class='notice'>You screw the cell in place.</span>")
		return

	else if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(state==4)
			if(!cell)
				if(!user.drop_item())
					return
				var/obj/item/weapon/stock_parts/cell/C = W
				to_chat(user, "<span class='notice'>You install the powercell.</span>")
				C.forceMove(src)
				cell = C
				log_message("Powercell installed")
			else
				to_chat(user, "<span class='notice'>There's already a powercell installed.</span>")
		return

	else if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != INTENT_HARM)
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/weapon/weldingtool/WT = W
		if(obj_integrity<max_integrity)
			if (WT.remove_fuel(0,user))
				if (internal_damage & MECHA_INT_TANK_BREACH)
					clearInternalDamage(MECHA_INT_TANK_BREACH)
					to_chat(user, "<span class='notice'>You repair the damaged gas tank.</span>")
				else
					user.visible_message("<span class='notice'>[user] repairs some damage to [name].</span>")
					obj_integrity += min(10, max_integrity-obj_integrity)
			else
				to_chat(user, "<span class='warning'>The welder must be on for this task!</span>")
				return 1
		else
			to_chat(user, "<span class='warning'>The [name] is at full integrity!</span>")
		return 1

	else if(istype(W, /obj/item/mecha_parts/mecha_tracking))
		if(!user.transferItemToLoc(W, src))
			to_chat(user, "<span class='warning'>\the [W] is stuck to your hand, you cannot put it in \the [src]!</span>")
			return
		trackers += W
		user.visible_message("[user] attaches [W] to [src].", "<span class='notice'>You attach [W] to [src].</span>")
		diag_hud_set_mechtracking()
		return
	else
		return ..()

/obj/mecha/attacked_by(obj/item/I, mob/living/user)
	log_message("Attacked by [I]. Attacker - [user]")
	..()

/obj/mecha/proc/mech_toxin_damage(mob/living/target)
	playsound(src, 'sound/effects/spray2.ogg', 50, 1)
	if(target.reagents)
		if(target.reagents.get_reagent_amount("cryptobiolin") + force < force*2)
			target.reagents.add_reagent("cryptobiolin", force/2)
		if(target.reagents.get_reagent_amount("toxin") + force < force*2)
			target.reagents.add_reagent("toxin", force/2.5)


/obj/mecha/mech_melee_attack(obj/mecha/M)
	if(!has_charge(melee_energy_drain))
		return 0
	use_power(melee_energy_drain)
	if(M.damtype == BRUTE || M.damtype == BURN)
		add_logs(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
		. = ..()

/obj/mecha/proc/full_repair(charge_cell)
	obj_integrity = max_integrity
	if(cell && charge_cell)
		cell.charge = cell.maxcharge
	if(internal_damage & MECHA_INT_FIRE)
		clearInternalDamage(MECHA_INT_FIRE)
	if(internal_damage & MECHA_INT_TEMP_CONTROL)
		clearInternalDamage(MECHA_INT_TEMP_CONTROL)
	if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
		clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
	if(internal_damage & MECHA_INT_TANK_BREACH)
		clearInternalDamage(MECHA_INT_TANK_BREACH)
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		clearInternalDamage(MECHA_INT_CONTROL_LOST)

/obj/mecha/narsie_act()
	if(occupant)
		var/mob/living/L = occupant
		go_out(TRUE)
		if(L)
			L.narsie_act()

/obj/mecha/ratvar_act()
	if((GLOB.ratvar_awakens || GLOB.clockwork_gateway_activated) && occupant)
		if(is_servant_of_ratvar(occupant)) //reward the minion that got a mech by repairing it
			full_repair(TRUE)
		else
			var/mob/living/L = occupant
			go_out(TRUE)
			if(L)
				L.ratvar_act()

/obj/mecha/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(!no_effect)
		if(selected)
			used_item = selected
		else if(!visual_effect_icon)
			visual_effect_icon = ATTACK_EFFECT_SMASH
			if(damtype == BURN)
				visual_effect_icon = ATTACK_EFFECT_MECHFIRE
			else if(damtype == TOX)
				visual_effect_icon = ATTACK_EFFECT_MECHTOXIN
	..()

