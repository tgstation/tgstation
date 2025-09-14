#define HUG_MODE_NICE 0
#define HUG_MODE_HUG 1
#define HUG_MODE_SHOCK 2
#define HUG_MODE_CRUSH 3

#define HUG_SHOCK_COOLDOWN (2 SECONDS)
#define HUG_CRUSH_COOLDOWN (1 SECONDS)

#define HARM_ALARM_NO_SAFETY_COOLDOWN (60 SECONDS)
#define HARM_ALARM_SAFETY_COOLDOWN (20 SECONDS)

/obj/item/borg
	icon = 'icons/mob/silicon/robot_items.dmi'
	abstract_type = /obj/item/borg

/// Cost to use the stun arm
#define CYBORG_STUN_CHARGE_COST (0.2 * STANDARD_CELL_CHARGE)

/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	var/stamina_damage = 60 //Same as normal batong
	var/cooldown_check = 0
	/// cooldown between attacks
	var/cooldown = 4 SECONDS // same as baton

/obj/item/borg/stun/attack(mob/living/attacked_mob, mob/living/user)
	if(cooldown_check > world.time)
		user.balloon_alert(user, "still recharging!")
		return
	if(ishuman(attacked_mob))
		var/mob/living/carbon/human/human = attacked_mob
		if(human.check_block(src, 0, "[attacked_mob]'s [name]", MELEE_ATTACK))
			playsound(attacked_mob, 'sound/items/weapons/genhit.ogg', 50, TRUE)
			return FALSE
	if(iscyborg(user))
		var/mob/living/silicon/robot/robot_user = user
		if(!robot_user.cell.use(CYBORG_STUN_CHARGE_COST))
			return

	user.do_attack_animation(attacked_mob)
	attacked_mob.adjustStaminaLoss(stamina_damage)
	attacked_mob.set_confusion_if_lower(5 SECONDS)
	attacked_mob.adjust_stutter(20 SECONDS)
	attacked_mob.set_jitter_if_lower(5 SECONDS)
	if(issilicon(attacked_mob))
		attacked_mob.emp_act(EMP_HEAVY)
		attacked_mob.visible_message(
			span_danger("[user] shocks [attacked_mob] with [src]!"),
			span_userdanger("[user] shocks you with [src]!"),
		)
	else
		attacked_mob.visible_message(
			span_danger("[user] prods [attacked_mob] with [src]!"),
			span_userdanger("[user] prods you with [src]!"),
		)

	playsound(loc, 'sound/items/weapons/egloves.ogg', 50, TRUE, -1)
	cooldown_check = world.time + cooldown
	log_combat(user, attacked_mob, "stunned", src, "(Combat mode: [user.combat_mode ? "On" : "Off"])")

#undef CYBORG_STUN_CHARGE_COST

/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	/// Hug mode
	var/mode = HUG_MODE_NICE
	/// Crush cooldown
	COOLDOWN_DECLARE(crush_cooldown)
	/// Shock cooldown
	COOLDOWN_DECLARE(shock_cooldown)
	/// Can it be a stunarm when emagged. Only PK borgs get this by default.
	var/shockallowed = FALSE
	var/boop = FALSE

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/robot_user = user
		if(robot_user.emagged && shockallowed == 1)
			if(mode < HUG_MODE_CRUSH)
				mode++
			else
				mode = HUG_MODE_NICE
		else if(mode < HUG_MODE_HUG)
			mode++
		else
			mode = HUG_MODE_NICE
	switch(mode)
		if(HUG_MODE_NICE)
			to_chat(user, span_infoplain("Power reset. Hugs!"))
		if(HUG_MODE_HUG)
			to_chat(user, span_infoplain("Power increased!"))
		if(HUG_MODE_SHOCK)
			to_chat(user, "<span class='warningplain'>BZZT. Electrifying arms...</span>")
		if(HUG_MODE_CRUSH)
			to_chat(user, "<span class='warningplain'>ERROR: ARM ACTUATORS OVERLOADED.</span>")

/obj/item/borg/cyborghug/attack(mob/living/attacked_mob, mob/living/silicon/robot/user, list/modifiers, list/attack_modifiers)
	if(attacked_mob == user)
		return
	if(attacked_mob.health < 0)
		return
	switch(mode)
		if(HUG_MODE_NICE)
			if(isanimal_or_basicmob(attacked_mob))
				if (!user.combat_mode && !LAZYACCESS(modifiers, RIGHT_CLICK))
					attacked_mob.attack_hand(user, modifiers) //This enables borgs to get the floating heart icon and mob emote from simple_animal's that have petbonus == true.
				return
			if(user.zone_selected == BODY_ZONE_HEAD)
				user.visible_message(
					span_notice("[user] playfully boops [attacked_mob] on the head!"),
					span_notice("You playfully boop [attacked_mob] on the head!"),
				)
				user.do_attack_animation(attacked_mob, ATTACK_EFFECT_BOOP)
				playsound(loc, 'sound/items/weapons/tap.ogg', 50, TRUE, -1)
			else if(ishuman(attacked_mob))
				if(user.body_position == LYING_DOWN)
					user.visible_message(
						span_notice("[user] shakes [attacked_mob] trying to get [attacked_mob.p_them()] up!"),
						span_notice("You shake [attacked_mob] trying to get [attacked_mob.p_them()] up!"),
					)
				else
					user.visible_message(
						span_notice("[user] hugs [attacked_mob] to make [attacked_mob.p_them()] feel better!"),
						span_notice("You hug [attacked_mob] to make [attacked_mob.p_them()] feel better!"),
					)
				if(attacked_mob.resting)
					attacked_mob.set_resting(FALSE, TRUE)
			else
				user.visible_message(
					span_notice("[user] pets [attacked_mob]!"),
					span_notice("You pet [attacked_mob]!"),
				)
			playsound(loc, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
		if(HUG_MODE_HUG)
			if(ishuman(attacked_mob))
				attacked_mob.adjust_status_effects_on_shake_up()
				if(attacked_mob.body_position == LYING_DOWN)
					user.visible_message(
						span_notice("[user] shakes [attacked_mob] trying to get [attacked_mob.p_them()] up!"),
						span_notice("You shake [attacked_mob] trying to get [attacked_mob.p_them()] up!"),
					)
				else if(user.zone_selected == BODY_ZONE_HEAD)
					user.visible_message(span_warning("[user] bops [attacked_mob] on the head!"),
						span_warning("You bop [attacked_mob] on the head!"),
					)
					user.do_attack_animation(attacked_mob, ATTACK_EFFECT_PUNCH)
				else
					if(!(SEND_SIGNAL(attacked_mob, COMSIG_BORG_HUG_MOB, user) & COMSIG_BORG_HUG_HANDLED))
						user.visible_message(
							span_warning("[user] hugs [attacked_mob] in a firm bear-hug! [attacked_mob] looks uncomfortable..."),
							span_warning("You hug [attacked_mob] firmly to make [attacked_mob.p_them()] feel better! [attacked_mob] looks uncomfortable..."),
						)
				if(attacked_mob.resting)
					attacked_mob.set_resting(FALSE, TRUE)
			else
				user.visible_message(
					span_warning("[user] bops [attacked_mob] on the head!"),
					span_warning("You bop [attacked_mob] on the head!"),
				)
			playsound(loc, 'sound/items/weapons/tap.ogg', 50, TRUE, -1)
		if(HUG_MODE_SHOCK)
			if (!COOLDOWN_FINISHED(src, shock_cooldown))
				return
			if(ishuman(attacked_mob))
				attacked_mob.electrocute_act(5, "[user]", flags = SHOCK_NOGLOVES | SHOCK_NOSTUN)
				attacked_mob.dropItemToGround(attacked_mob.get_active_held_item())
				attacked_mob.dropItemToGround(attacked_mob.get_inactive_held_item())
				user.visible_message(
					span_userdanger("[user] electrocutes [attacked_mob] with [user.p_their()] touch!"),
					span_danger("You electrocute [attacked_mob] with your touch!"),
				)
			else
				if(!iscyborg(attacked_mob))
					attacked_mob.adjustFireLoss(10)
					user.visible_message(
						span_userdanger("[user] shocks [attacked_mob]!"),
						span_danger("You shock [attacked_mob]!"),
					)
				else
					user.visible_message(
						span_userdanger("[user] shocks [attacked_mob]. It does not seem to have an effect"),
						span_danger("You shock [attacked_mob] to no effect."),
					)
			playsound(loc, 'sound/effects/sparks/sparks2.ogg', 50, TRUE, -1)
			user.cell.use(0.5 * STANDARD_CELL_CHARGE, force = TRUE)
			COOLDOWN_START(src, shock_cooldown, HUG_SHOCK_COOLDOWN)
		if(HUG_MODE_CRUSH)
			if (!COOLDOWN_FINISHED(src, crush_cooldown))
				return
			if(ishuman(attacked_mob))
				user.visible_message(
					span_userdanger("[user] crushes [attacked_mob] in [user.p_their()] grip!"),
					span_danger("You crush [attacked_mob] in your grip!"),
				)
			else
				user.visible_message(
					span_userdanger("[user] crushes [attacked_mob]!"),
						span_danger("You crush [attacked_mob]!"),
				)
			playsound(loc, 'sound/items/weapons/smash.ogg', 50, TRUE, -1)
			attacked_mob.adjustBruteLoss(15)
			user.cell.use(0.3 * STANDARD_CELL_CHARGE, force = TRUE)
			COOLDOWN_START(src, crush_cooldown, HUG_CRUSH_COOLDOWN)

/obj/item/borg/cyborghug/peacekeeper
	shockallowed = TRUE

/obj/item/borg/cyborghug/medical
	boop = TRUE

/obj/item/borg/charger
	name = "power connector"
	icon_state = "charger_draw"
	item_flags = NOBLUDGEON
	/// Charging mode
	var/mode = "draw"
	/// Whitelist of charging machines
	var/static/list/charge_machines = typecacheof(list(/obj/machinery/cell_charger, /obj/machinery/recharger, /obj/machinery/recharge_station, /obj/machinery/mech_bay_recharge_port))
	/// Whitelist of chargable items
	var/static/list/charge_items = typecacheof(list(/obj/item/stock_parts/power_store, /obj/item/gun/energy))

/obj/item/borg/charger/update_icon_state()
	icon_state = "charger_[mode]"
	return ..()

/obj/item/borg/charger/attack_self(mob/user)
	if(mode == "draw")
		mode = "charge"
	else
		mode = "draw"
	to_chat(user, span_notice("You toggle [src] to \"[mode]\" mode."))
	update_appearance()

/obj/item/borg/charger/interact_with_atom(atom/target, mob/living/silicon/robot/user, list/modifiers)
	if(!iscyborg(user))
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(mode == "draw")
		if(is_type_in_list(target, charge_machines))
			var/obj/machinery/target_machine = target
			if((target_machine.machine_stat & (NOPOWER|BROKEN)) || !target_machine.anchored)
				to_chat(user, span_warning("[target_machine] is unpowered!"))
				return

			to_chat(user, span_notice("You connect to [target_machine]'s power line..."))
			while(do_after(user, 1.5 SECONDS, target = target_machine, progress = FALSE))
				if(!user || !user.cell || mode != "draw")
					return

				if((target_machine.machine_stat & (NOPOWER|BROKEN)) || !target_machine.anchored)
					break

				target_machine.charge_cell(0.15 * STANDARD_CELL_CHARGE, user.cell)

			to_chat(user, span_notice("You stop charging yourself."))

		else if(is_type_in_list(target, charge_items))
			var/obj/item/stock_parts/power_store/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/stock_parts/power_store) in target
			if(!cell)
				to_chat(user, span_warning("[target] has no power cell!"))
				return

			if(istype(target, /obj/item/gun/energy))
				var/obj/item/gun/energy/energy_gun = target
				if(!energy_gun.can_charge)
					to_chat(user, span_warning("[target] has no power port!"))
					return

			if(!cell.charge)
				to_chat(user, span_warning("[target] has no power!"))


			to_chat(user, span_notice("You connect to [target]'s power port..."))

			while(do_after(user, 1.5 SECONDS, target = target, progress = FALSE))
				if(!user || !user.cell || mode != "draw")
					return

				if(!cell || !target)
					return

				if(cell != target && cell.loc != target)
					return

				var/draw = min(cell.charge, cell.chargerate*0.5, user.cell.maxcharge - user.cell.charge)
				if(!cell.use(draw))
					break
				if(!user.cell.give(draw))
					break
				target.update_appearance()

			to_chat(user, span_notice("You stop charging yourself."))

	else if(is_type_in_list(target, charge_items))
		var/obj/item/stock_parts/power_store/cell = target
		if(!istype(cell))
			cell = locate(/obj/item/stock_parts/power_store) in target
		if(!cell)
			to_chat(user, span_warning("[target] has no power cell!"))
			return

		if(istype(target, /obj/item/gun/energy))
			var/obj/item/gun/energy/energy_gun = target
			if(!energy_gun.can_charge)
				to_chat(user, span_warning("[target] has no power port!"))
				return

		if(cell.charge >= cell.maxcharge)
			to_chat(user, span_warning("[target] is already charged!"))

		to_chat(user, span_notice("You connect to [target]'s power port..."))

		while(do_after(user, 1.5 SECONDS, target = target, progress = FALSE))
			if(!user || !user.cell || mode != "charge")
				return

			if(!cell || !target)
				return

			if(cell != target && cell.loc != target)
				return

			var/draw = min(user.cell.charge, cell.chargerate * 0.5, cell.maxcharge - cell.charge)
			if(!user.cell.use(draw))
				break
			if(!cell.give(draw))
				break
			target.update_appearance()

		to_chat(user, span_notice("You stop charging [target]."))

/obj/item/harmalarm
	name = "\improper Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "megaphone"
	/// Harm alarm cooldown
	COOLDOWN_DECLARE(alarm_cooldown)

/obj/item/harmalarm/emag_act(mob/user, obj/item/card/emag/emag_card)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		balloon_alert(user, "safeties shorted")
	else
		balloon_alert(user, "safeties reset")
	return TRUE

/obj/item/harmalarm/attack_self(mob/user)
	var/safety = !(obj_flags & EMAGGED)
	if (!COOLDOWN_FINISHED(src, alarm_cooldown))
		to_chat(user, "<font color='red'>The device is still recharging!</font>")
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/robot_user = user
		if(!robot_user.cell || robot_user.cell.charge < 1200)
			to_chat(user, span_warning("You don't have enough charge to do this!"))
			return
		robot_user.cell.charge -= 1000
		if(robot_user.emagged)
			safety = FALSE

	if(safety == TRUE)
		user.visible_message(
			"<font color='red' size='2'>[user] blares out a near-deafening siren from its speakers!</font>",
			span_userdanger("Your siren blares around [iscyborg(user) ? "you" : "and confuses you"]!"),
			span_danger("The siren pierces your hearing!"),
		)
		for(var/mob/living/carbon/carbon in get_hearers_in_view(9, user))
			if(carbon.get_ear_protection())
				continue
			carbon.adjust_confusion(6 SECONDS)

		audible_message("<font color='red' size='7'>HUMAN HARM</font>")
		playsound(get_turf(src), 'sound/mobs/non-humanoids/cyborg/harmalarm.ogg', 70, 3)
		COOLDOWN_START(src, alarm_cooldown, HARM_ALARM_SAFETY_COOLDOWN)
		user.log_message("used a Cyborg Harm Alarm", LOG_ATTACK)
		if(iscyborg(user))
			var/mob/living/silicon/robot/robot_user = user
			to_chat(robot_user.connected_ai, "<br>[span_notice("NOTICE - Peacekeeping 'HARM ALARM' used by: [user]")]<br>")
	else
		user.audible_message("<font color='red' size='7'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</font>")
		for(var/mob/living/carbon/carbon in get_hearers_in_view(9, user))
			var/bang_effect = carbon.soundbang_act(2, 0, 0, 5)
			switch(bang_effect)
				if(1)
					carbon.adjust_confusion(5 SECONDS)
					carbon.adjust_stutter(20 SECONDS)
					carbon.adjust_jitter(20 SECONDS)
				if(2)
					carbon.Paralyze(40)
					carbon.adjust_confusion(10 SECONDS)
					carbon.adjust_stutter(30 SECONDS)
					carbon.adjust_jitter(50 SECONDS)
		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 130, 3)
		COOLDOWN_START(src, alarm_cooldown, HARM_ALARM_NO_SAFETY_COOLDOWN)
		user.log_message("used an emagged Cyborg Harm Alarm", LOG_ATTACK)

/obj/item/shield_module
	name = "Shield Activator"
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "module_miner"
	var/active = FALSE
	var/mutable_appearance/shield_overlay

/obj/item/shield_module/Initialize(mapload)
	. = ..()
	shield_overlay = mutable_appearance('icons/mob/effects/durand_shield.dmi', "borg_shield")

/obj/item/shield_module/attack_self(mob/living/silicon/borg)
	active = !active
	if(active)
		playsound(src, 'sound/vehicles/mecha/mech_shield_raise.ogg', 50, FALSE)
		RegisterSignal(borg, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_shield_overlay_update), override = TRUE)
	else
		playsound(src, 'sound/vehicles/mecha/mech_shield_drop.ogg', 50, FALSE)
		UnregisterSignal(borg, COMSIG_ATOM_UPDATE_OVERLAYS)
	borg.update_appearance()

/obj/item/shield_module/cyborg_unequip(mob/living/silicon/robot/borg)
	active = FALSE
	playsound(src, 'sound/vehicles/mecha/mech_shield_drop.ogg', 50, FALSE)
	borg.cut_overlay(shield_overlay)

/obj/item/shield_module/proc/on_shield_overlay_update(atom/source, list/overlays)
	SIGNAL_HANDLER
	if(active)
		overlays += shield_overlay

#undef HUG_MODE_NICE
#undef HUG_MODE_HUG
#undef HUG_MODE_SHOCK
#undef HUG_MODE_CRUSH

#undef HUG_SHOCK_COOLDOWN
#undef HUG_CRUSH_COOLDOWN

#undef HARM_ALARM_NO_SAFETY_COOLDOWN
#undef HARM_ALARM_SAFETY_COOLDOWN
