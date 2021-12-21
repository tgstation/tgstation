/obj/vehicle/sealed/mecha/proc/get_armour_facing(relative_dir)
	switch(relative_dir)
		if(180) // BACKSTAB!
			return facing_modifiers[MECHA_BACK_ARMOUR]
		if(0, 45) // direct or 45 degrees off
			return facing_modifiers[MECHA_FRONT_ARMOUR]
	return facing_modifiers[MECHA_SIDE_ARMOUR] //if its not a front hit or back hit then assume its from the side

/obj/vehicle/sealed/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && atom_integrity > 0)
		spark_system.start()
		switch(damage_flag)
			if(FIRE)
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL))
			if(MELEE)
				check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			else
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT))
		if(. >= 5 || prob(33))
			to_chat(occupants, "[icon2html(src, occupants)][span_userdanger("Taking damage!")]")
		log_message("Took [damage_amount] points of damage. Damage type: [damage_type]", LOG_MECHA)

/obj/vehicle/sealed/mecha/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	. = ..()
	if(!damage_amount)
		return 0
	var/booster_deflection_modifier = 1
	var/booster_damage_modifier = 1
	if(damage_flag == BULLET || damage_flag == LASER || damage_flag == ENERGY)
		for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
			if(B.projectile_react())
				booster_deflection_modifier = B.deflect_coeff
				booster_damage_modifier = B.damage_coeff
				break
	else if(damage_flag == MELEE)
		for(var/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/B in equipment)
			if(B.attack_react())
				booster_deflection_modifier *= B.deflect_coeff
				booster_damage_modifier *= B.damage_coeff
				break

	if(attack_dir)
		var/facing_modifier = get_armour_facing(abs(dir2angle(dir) - dir2angle(attack_dir)))
		booster_damage_modifier /= facing_modifier
		booster_deflection_modifier *= facing_modifier
	if(prob(deflect_chance * booster_deflection_modifier))
		visible_message(span_danger("[src]'s armour deflects the attack!"))
		log_message("Armor saved.", LOG_MECHA)
		return 0
	if(.)
		. *= booster_damage_modifier

/obj/vehicle/sealed/mecha/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE) // Ugh. Ideally we shouldn't be setting cooldowns outside of click code.
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, TRUE, -1)
	user.visible_message(span_danger("[user] hits [name]. Nothing happens."), null, null, COMBAT_MESSAGE_RANGE)
	log_message("Attack by hand/paw. Attacker - [user].", LOG_MECHA, color="red")

/obj/vehicle/sealed/mecha/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/vehicle/sealed/mecha/attack_alien(mob/living/user, list/modifiers)
	log_message("Attack by alien. Attacker - [user].", LOG_MECHA, color="red")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, TRUE)
	attack_generic(user, rand(user.melee_damage_lower, user.melee_damage_upper), BRUTE, MELEE, 0)

/obj/vehicle/sealed/mecha/attack_animal(mob/living/simple_animal/user, list/modifiers)
	log_message("Attack by simple animal. Attacker - [user].", LOG_MECHA, color="red")
	if(!user.melee_damage_upper && !user.obj_damage)
		user.emote("custom", message = "[user.friendly_verb_continuous] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(user.environment_smash)
			play_soundeffect = 0
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		var/animal_damage = rand(user.melee_damage_lower,user.melee_damage_upper)
		if(user.obj_damage)
			animal_damage = user.obj_damage
		animal_damage = min(animal_damage, 20*user.environment_smash)
		log_combat(user, src, "attacked")
		attack_generic(user, animal_damage, user.melee_damage_type, MELEE, play_soundeffect)
		return 1


/obj/vehicle/sealed/mecha/hulk_damage()
	return 15

/obj/vehicle/sealed/mecha/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(.)
		log_message("Attack by hulk. Attacker - [user].", LOG_MECHA, color="red")
		log_combat(user, src, "punched", "hulk powers")

/obj/vehicle/sealed/mecha/blob_act(obj/structure/blob/B)
	log_message("Attack by blob. Attacker - [B].", LOG_MECHA, color="red")
	take_damage(30, BRUTE, MELEE, 0, get_dir(src, B))

/obj/vehicle/sealed/mecha/attack_tk()
	return

/obj/vehicle/sealed/mecha/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum) //wrapper
	log_message("Hit by [AM].", LOG_MECHA, color="red")
	. = ..()

/obj/vehicle/sealed/mecha/bullet_act(obj/projectile/Proj) //wrapper
	if(!enclosed && LAZYLEN(occupants) && !(mecha_flags  & SILICON_PILOT) && !Proj.force_hit && (Proj.def_zone == BODY_ZONE_HEAD || Proj.def_zone == BODY_ZONE_CHEST)) //allows bullets to hit the pilot of open-canopy mechs
		for(var/m in occupants)
			var/mob/living/hitmob = m
			hitmob.bullet_act(Proj) //If the sides are open, the occupant can be hit
		return BULLET_ACT_HIT
	log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).", LOG_MECHA, color="red")
	. = ..()

/obj/vehicle/sealed/mecha/ex_act(severity, target)
	log_message("Affected by explosion of severity: [severity].", LOG_MECHA, color="red")
	if(prob(deflect_chance))
		severity--
		log_message("Armor saved, changing severity to [severity]", LOG_MECHA)
	return ..()

/obj/vehicle/sealed/mecha/contents_explosion(severity, target)
	severity--

	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(equipment)
				SSexplosions.high_mov_atom += equipment
			if(trackers)
				SSexplosions.high_mov_atom += trackers
			if(occupants)
				SSexplosions.high_mov_atom += occupants
		if(EXPLODE_HEAVY)
			if(equipment)
				SSexplosions.med_mov_atom += equipment
			if(trackers)
				SSexplosions.med_mov_atom += trackers
			if(occupants)
				SSexplosions.med_mov_atom += occupants
		if(EXPLODE_LIGHT)
			if(equipment)
				SSexplosions.low_mov_atom += equipment
			if(trackers)
				SSexplosions.low_mov_atom += trackers
			if(occupants)
				SSexplosions.low_mov_atom += occupants

/obj/vehicle/sealed/mecha/handle_atom_del(atom/A)
	if(A in occupants)
		LAZYREMOVE(occupants, A)
		icon_state = initial(icon_state)+"-open"
		setDir(dir_in)

/obj/vehicle/sealed/mecha/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(get_charge())
		use_power((cell.charge/3)/(severity*2))
		take_damage(30 / severity, BURN, ENERGY, 1)
	log_message("EMP detected", LOG_MECHA, color="red")

	if(istype(src, /obj/vehicle/sealed/mecha/combat))
		mouse_pointer = 'icons/effects/mouse_pointers/mecha_mouse-disable.dmi'
		for(var/occus in occupants)
			var/mob/living/occupant = occus
			occupant.update_mouse_pointer()
	if(!equipment_disabled && LAZYLEN(occupants)) //prevent spamming this message with back-to-back EMPs
		to_chat(occupants, span_warning("Error -- Connection to equipment control unit has been lost."))
	addtimer(CALLBACK(src, /obj/vehicle/sealed/mecha/proc/restore_equipment), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	equipment_disabled = 1

/obj/vehicle/sealed/mecha/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > max_temperature

/obj/vehicle/sealed/mecha/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	log_message("Exposed to dangerous temperature.", LOG_MECHA, color="red")
	take_damage(5, BURN, 0, 1)

/obj/vehicle/sealed/mecha/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/mmi))
		if(mmi_move_inside(W,user))
			to_chat(user, span_notice("[src]-[W] interface initialized successfully."))
		else
			to_chat(user, span_warning("[src]-[W] interface initialization failed."))
		return

	if(istype(W, /obj/item/mecha_ammo))
		ammo_resupply(W, user)
		return

	if(W.GetID())
		if((mecha_flags & ADDING_ACCESS_POSSIBLE) || (mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE))
			if(internals_access_allowed(user))
				var/obj/item/card/id/id_card
				if(istype(W, /obj/item/card/id))
					id_card = W
				else
					var/obj/item/pda/pda = W
					id_card = pda.id
				output_maintenance_dialog(id_card, user)
				return
			to_chat(user, span_warning("Invalid ID: Access denied."))
			return
		to_chat(user, span_warning("Maintenance protocols disabled by operator."))
		return

	if(istype(W, /obj/item/stock_parts/cell))
		if(construction_state == MECHA_OPEN_HATCH)
			if(!cell)
				if(!user.transferItemToLoc(W, src, silent = FALSE))
					return
				var/obj/item/stock_parts/cell/C = W
				to_chat(user, span_notice("You install the power cell."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				cell = C
				log_message("Power cell installed", LOG_MECHA)
			else
				to_chat(user, span_warning("There's already a power cell installed!"))
		return

	if(istype(W, /obj/item/stock_parts/scanning_module))
		if(construction_state == MECHA_OPEN_HATCH)
			if(!scanmod)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, span_notice("You install the scanning module."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				scanmod = W
				log_message("[W] installed", LOG_MECHA)
				update_part_values()
			else
				to_chat(user, span_warning("There's already a scanning module installed!"))
		return

	if(istype(W, /obj/item/stock_parts/capacitor))
		if(construction_state == MECHA_OPEN_HATCH)
			if(!capacitor)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, span_notice("You install the capacitor."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				capacitor = W
				log_message("[W] installed", LOG_MECHA)
				update_part_values()
			else
				to_chat(user, span_warning("There's already a capacitor installed!"))
		return

	if(istype(W, /obj/item/stack/cable_coil))
		if(construction_state == MECHA_OPEN_HATCH && (internal_damage & MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/stack/cable_coil/CC = W
			if(CC.use(2))
				clear_internal_damage(MECHA_INT_SHORT_CIRCUIT)
				to_chat(user, span_notice("You replace the fused wires."))
			else
				to_chat(user, span_warning("You need two lengths of cable to fix this mech!"))
		return

	if(istype(W, /obj/item/mecha_parts))
		var/obj/item/mecha_parts/P = W
		P.try_attach_part(user, src)
		return
	log_message("Attacked by [W]. Attacker - [user]", LOG_MECHA)
	return ..()

/obj/vehicle/sealed/mecha/wrench_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(construction_state == MECHA_SECURE_BOLTS)
		construction_state = MECHA_LOOSE_BOLTS
		to_chat(user, span_notice("You undo the securing bolts."))
		return
	if(construction_state == MECHA_LOOSE_BOLTS)
		construction_state = MECHA_SECURE_BOLTS
		to_chat(user, span_notice("You tighten the securing bolts."))

/obj/vehicle/sealed/mecha/crowbar_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(construction_state == MECHA_LOOSE_BOLTS)
		construction_state = MECHA_OPEN_HATCH
		to_chat(user, span_notice("You open the hatch to the power unit."))
		return
	if(construction_state == MECHA_OPEN_HATCH)
		construction_state = MECHA_LOOSE_BOLTS
		to_chat(user, span_notice("You close the hatch to the power unit."))

/obj/vehicle/sealed/mecha/screwdriver_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(internal_damage & MECHA_INT_TEMP_CONTROL)
		clear_internal_damage(MECHA_INT_TEMP_CONTROL)
		to_chat(user, span_notice("You repair the damaged temperature controller."))
		return

/obj/vehicle/sealed/mecha/welder_act(mob/living/user, obj/item/W)
	. = ..()
	if(user.combat_mode)
		return
	. = TRUE
	if(internal_damage & MECHA_INT_TANK_BREACH)
		if(!W.use_tool(src, user, 0, volume=50, amount=1))
			return
		clear_internal_damage(MECHA_INT_TANK_BREACH)
		to_chat(user, span_notice("You repair the damaged gas tank."))
		return
	if(atom_integrity < max_integrity)
		if(!W.use_tool(src, user, 0, volume=50, amount=1))
			return
		user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to [src]."))
		atom_integrity += min(10, max_integrity-atom_integrity)
		if(atom_integrity == max_integrity)
			to_chat(user, span_notice("It looks to be fully repaired now."))
		return
	to_chat(user, span_warning("The [name] is at full integrity!"))

/obj/vehicle/sealed/mecha/proc/mech_toxin_damage(mob/living/target)
	playsound(src, 'sound/effects/spray2.ogg', 50, TRUE)
	if(target.reagents)
		if(target.reagents.get_reagent_amount(/datum/reagent/cryptobiolin) + force < force*2)
			target.reagents.add_reagent(/datum/reagent/cryptobiolin, force/2)
		if(target.reagents.get_reagent_amount(/datum/reagent/toxin) + force < force*2)
			target.reagents.add_reagent(/datum/reagent/toxin, force/2.5)


/obj/vehicle/sealed/mecha/mech_melee_attack(obj/vehicle/sealed/mecha/M, mob/living/user)
	if(!has_charge(melee_energy_drain))
		return NONE
	use_power(melee_energy_drain)
	if(M.damtype == BRUTE || M.damtype == BURN)
		log_combat(user, src, "attacked", M, "(COMBAT MODE: [uppertext(user.combat_mode)] (DAMTYPE: [uppertext(M.damtype)])")
		. = ..()

/obj/vehicle/sealed/mecha/proc/full_repair(charge_cell)
	atom_integrity = max_integrity
	if(cell && charge_cell)
		cell.charge = cell.maxcharge
	if(internal_damage & MECHA_INT_FIRE)
		clear_internal_damage(MECHA_INT_FIRE)
	if(internal_damage & MECHA_INT_TEMP_CONTROL)
		clear_internal_damage(MECHA_INT_TEMP_CONTROL)
	if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
		clear_internal_damage(MECHA_INT_SHORT_CIRCUIT)
	if(internal_damage & MECHA_INT_TANK_BREACH)
		clear_internal_damage(MECHA_INT_TANK_BREACH)
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		clear_internal_damage(MECHA_INT_CONTROL_LOST)

/obj/vehicle/sealed/mecha/narsie_act()
	emp_act(EMP_HEAVY)

/obj/vehicle/sealed/mecha/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
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

/obj/vehicle/sealed/mecha/atom_destruction()
	if(wreckage)
		var/mob/living/silicon/ai/AI
		for(var/crew in occupants)
			if(isAI(crew))
				if(AI)
					var/mob/living/silicon/ai/unlucky_ais = crew
					unlucky_ais.gib()
					continue
				AI = crew
		var/obj/structure/mecha_wreckage/WR = new wreckage(loc, AI)
		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
			if(E.salvageable && prob(30))
				WR.crowbar_salvage += E
				E.detach(WR) //detaches from src into WR
				E.equip_ready = 1
			else
				E.detach(loc)
				qdel(E)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.charge = rand(0, cell.charge)
			cell = null
		if(internal_tank)
			WR.crowbar_salvage += internal_tank
			internal_tank.forceMove(WR)
			cell = null
	. = ..()
