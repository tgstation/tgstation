/*!
 * # Mecha defence explanation
 * Mechs focus is on a more heavy-but-slower damage approach
 * For this they have the following mechanics
 *
 * ## Backstab
 * Basically the tldr is that mechs are less flexible so we encourage good positioning, pretty simple
 * ## Armor modules
 * Pretty simple, adds armor, you can choose against what
 * ## Internal damage
 * When taking damage will force you to take some time to repair, encourages improvising in a fight
 * Targetting different def zones will damage them to encurage a more strategic approach to fights
 * where they target the "dangerous" modules
 */

/// tries to damage mech equipment depending on damage and where is being targetted
/obj/vehicle/sealed/mecha/proc/try_damage_component(damage, def_zone)
	if(damage < component_damage_threshold)
		return
	var/obj/item/mecha_parts/mecha_equipment/gear
	switch(def_zone)
		if(BODY_ZONE_L_ARM)
			gear = equip_by_category[MECHA_L_ARM]
		if(BODY_ZONE_R_ARM)
			gear = equip_by_category[MECHA_R_ARM]
	if(!gear)
		return
	var/component_health = gear.get_integrity()
	// always leave at least 1 health
	var/damage_to_deal = min(component_health - 1, damage)
	if(damage_to_deal <= 0)
		return

	gear.take_damage(damage_to_deal)
	if(gear.get_integrity() <= 1)
		to_chat(occupants, "[icon2html(src, occupants)][span_danger("[gear] is critically damaged!")]")
		playsound(src, gear.destroy_sound, 50)

/obj/vehicle/sealed/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	var/damage_taken = ..()
	if(damage_taken <= 0 || atom_integrity < 0)
		return damage_taken

	spark_system.start()
	try_deal_internal_damage(damage_taken)
	if(damage_taken >= 5 || prob(33))
		to_chat(occupants, "[icon2html(src, occupants)][span_userdanger("Taking damage!")]")
	log_message("Took [damage_taken] points of damage. Damage type: [damage_type]", LOG_MECHA)

	return damage_taken

/obj/vehicle/sealed/mecha/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration)
	. = ..()
	if(attack_dir)
		var/facing_modifier = get_armour_facing(abs(dir2angle(dir) - dir2angle(attack_dir)))
		if(.)
			. *= facing_modifier

/obj/vehicle/sealed/mecha/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE) // Ugh. Ideally we shouldn't be setting cooldowns outside of click code.
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, TRUE, -1)
	user.visible_message(span_danger("[user] hits [src]. Nothing happens."), null, null, COMBAT_MESSAGE_RANGE)
	log_message("Attack by hand/paw (no damage). Attacker - [user].", LOG_MECHA, color="red")

/obj/vehicle/sealed/mecha/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/vehicle/sealed/mecha/attack_alien(mob/living/user, list/modifiers)
	log_message("Attack by alien. Attacker - [user].", LOG_MECHA, color="red")
	playsound(loc, 'sound/weapons/slash.ogg', 100, TRUE)
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
	return ..()

/obj/vehicle/sealed/mecha/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit) //wrapper
	if(!enclosed && LAZYLEN(occupants) && !(mecha_flags  & SILICON_PILOT) && (hitting_projectile.def_zone == BODY_ZONE_HEAD || hitting_projectile.def_zone == BODY_ZONE_CHEST)) //allows bullets to hit the pilot of open-canopy mechs
		for(var/mob/living/hitmob as anything in occupants)
			hitmob.bullet_act(hitting_projectile, def_zone, piercing_hit) //If the sides are open, the occupant can be hit
		return BULLET_ACT_HIT
	log_message("Hit by projectile. Type: [hitting_projectile]([hitting_projectile.damage_type]).", LOG_MECHA, color="red")
	// yes we *have* to run the armor calc proc here I love tg projectile code too
	try_damage_component(run_atom_armor(
		damage_amount = hitting_projectile.damage,
		damage_type = hitting_projectile.damage_type,
		damage_flag = hitting_projectile.armor_flag,
		attack_dir = REVERSE_DIR(hitting_projectile.dir),
		armour_penetration = hitting_projectile.armour_penetration,
	), hitting_projectile.def_zone)
	return ..()

/obj/vehicle/sealed/mecha/ex_act(severity, target)
	log_message("Affected by explosion of severity: [severity].", LOG_MECHA, color="red")
	return ..()

/obj/vehicle/sealed/mecha/contents_explosion(severity, target)
	severity--

	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(flat_equipment)
				SSexplosions.high_mov_atom += flat_equipment
			if(trackers)
				SSexplosions.high_mov_atom += trackers
			if(occupants)
				SSexplosions.high_mov_atom += occupants
		if(EXPLODE_HEAVY)
			if(flat_equipment)
				SSexplosions.med_mov_atom += flat_equipment
			if(trackers)
				SSexplosions.med_mov_atom += trackers
			if(occupants)
				SSexplosions.med_mov_atom += occupants
		if(EXPLODE_LIGHT)
			if(flat_equipment)
				SSexplosions.low_mov_atom += flat_equipment
			if(trackers)
				SSexplosions.low_mov_atom += trackers
			if(occupants)
				SSexplosions.low_mov_atom += occupants

/obj/vehicle/sealed/mecha/handle_atom_del(atom/A)
	if(A in occupants) //todo does not work and in wrong file
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

	if(!equipment_disabled && LAZYLEN(occupants)) //prevent spamming this message with back-to-back EMPs
		to_chat(occupants, span_warning("Error -- Connection to equipment control unit has been lost."))
	addtimer(CALLBACK(src, /obj/vehicle/sealed/mecha.proc/restore_equipment), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	equipment_disabled = TRUE
	set_mouse_pointer()

/obj/vehicle/sealed/mecha/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > max_temperature

/obj/vehicle/sealed/mecha/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	log_message("Exposed to dangerous temperature.", LOG_MECHA, color="red")
	take_damage(5, BURN, 0, 1)

/obj/vehicle/sealed/mecha/fire_act() //Check if we should ignite the pilot of an open-canopy mech
	. = ..()
	if(enclosed || mecha_flags & SILICON_PILOT)
		return
	for(var/mob/living/cookedalive as anything in occupants)
		if(cookedalive.fire_stacks < 5)
			cookedalive.adjust_fire_stacks(1)
			cookedalive.ignite_mob()

/obj/vehicle/sealed/mecha/attackby_secondary(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/mecha_parts))
		var/obj/item/mecha_parts/parts = weapon
		parts.try_attach_part(user, src, TRUE)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

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
				ui_interact(user)
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

	if(istype(W, /obj/item/mecha_parts))
		var/obj/item/mecha_parts/P = W
		P.try_attach_part(user, src, FALSE)
		return

	return ..()

/obj/vehicle/sealed/mecha/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!attacking_item.force)
		return

	var/damage_taken = take_damage(attacking_item.force * attacking_item.demolition_mod, attacking_item.damtype, MELEE, 1)
	try_damage_component(damage_taken, user.zone_selected)

	var/hit_verb = length(attacking_item.attack_verb_simple) ? "[pick(attacking_item.attack_verb_simple)]" : "hit"
	user.visible_message(
		span_danger("[user] [hit_verb][plural_s(hit_verb)] [src] with [attacking_item][damage_taken ? "." : ", without leaving a mark!"]"),
		span_danger("You [hit_verb] [src] with [attacking_item][damage_taken ? "." : ", without leaving a mark!"]"),
		span_hear("You hear a [hit_verb]."),
		COMBAT_MESSAGE_RANGE,
	)

	log_combat(user, src, "attacked", attacking_item)
	log_message("Attacked by [user]. Item - [attacking_item], Damage - [damage_taken]", LOG_MECHA)

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

/obj/vehicle/sealed/mecha/welder_act(mob/living/user, obj/item/W)
	. = ..()
	if(user.combat_mode)
		return
	. = TRUE
	if(atom_integrity < max_integrity)
		if(!W.use_tool(src, user, 0, volume=50, amount=1))
			return
		user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to [src]."))
		atom_integrity += min(10, max_integrity-atom_integrity)
		if(atom_integrity == max_integrity)
			to_chat(user, span_notice("It looks to be fully repaired now."))
		return
	to_chat(user, span_warning("[src] is at full integrity!"))

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
	if(!no_effect && !visual_effect_icon)
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
		for(var/obj/item/mecha_parts/mecha_equipment/E in flat_equipment)
			if(E.detachable && prob(30))
				WR.crowbar_salvage += E
				E.detach(WR) //detaches from src into WR
				E.activated = TRUE
			else
				E.detach(loc)
				qdel(E)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.charge = rand(0, cell.charge)
			cell = null
	. = ..()

/obj/vehicle/sealed/mecha/proc/ammo_resupply(obj/item/mecha_ammo/A, mob/user,fail_chat_override = FALSE)
	if(!A.rounds)
		if(!fail_chat_override)
			to_chat(user, span_warning("This box of ammo is empty!"))
		return FALSE
	var/ammo_needed
	var/found_gun
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in flat_equipment)
		ammo_needed = 0

		if(!istype(gun, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic) && gun.ammo_type == A.ammo_type)
			continue
		found_gun = TRUE
		if(A.direct_load)
			ammo_needed = initial(gun.projectiles) - gun.projectiles
		else
			ammo_needed = gun.projectiles_cache_max - gun.projectiles_cache

		if(!ammo_needed)
			continue
		if(ammo_needed < A.rounds)
			if(A.direct_load)
				gun.projectiles = gun.projectiles + ammo_needed
			else
				gun.projectiles_cache = gun.projectiles_cache + ammo_needed
			playsound(get_turf(user),A.load_audio,50,TRUE)
			to_chat(user, span_notice("You add [ammo_needed] [A.ammo_type][ammo_needed > 1?"s":""] to the [gun.name]"))
			A.rounds = A.rounds - ammo_needed
			if(A.custom_materials)
				A.set_custom_materials(A.custom_materials, A.rounds / initial(A.rounds))
			A.update_name()
			return TRUE

		if(A.direct_load)
			gun.projectiles = gun.projectiles + A.rounds
		else
			gun.projectiles_cache = gun.projectiles_cache + A.rounds
		playsound(get_turf(user),A.load_audio,50,TRUE)
		to_chat(user, span_notice("You add [A.rounds] [A.ammo_type][A.rounds > 1?"s":""] to the [gun.name]"))
		A.rounds = 0
		A.set_custom_materials(list(/datum/material/iron=2000))
		A.update_name()
		return TRUE
	if(!fail_chat_override)
		if(found_gun)
			to_chat(user, span_notice("You can't fit any more ammo of this type!"))
		else
			to_chat(user, span_notice("None of the equipment on this exosuit can use this ammo!"))
	return FALSE
