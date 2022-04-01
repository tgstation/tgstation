/obj/item/borg
	icon = 'icons/mob/robot_items.dmi'

/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	var/charge_cost = 1000

/obj/item/borg/stun/attack(mob/living/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.check_shields(src, 0, "[M]'s [name]", MELEE_ATTACK))
			playsound(M, 'sound/weapons/genhit.ogg', 50, TRUE)
			return FALSE
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(charge_cost))
			return

	user.do_attack_animation(M)
	M.Paralyze(100)
	M.apply_effect(EFFECT_STUTTER, 5)

	M.visible_message(span_danger("[user] prods [M] with [src]!"), \
					span_userdanger("[user] prods you with [src]!"))

	playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)

	log_combat(user, M, "stunned", src, "(Combat mode: [user.combat_mode ? "On" : "Off"])")

/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	var/mode = 0 //0 = Hugs 1 = "Hug" 2 = Shock 3 = CRUSH
	var/ccooldown = 0
	var/scooldown = 0
	var/shockallowed = FALSE//Can it be a stunarm when emagged. Only PK borgs get this by default.
	var/boop = FALSE

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/P = user
		if(P.emagged&&shockallowed == 1)
			if(mode < 3)
				mode++
			else
				mode = 0
		else if(mode < 1)
			mode++
		else
			mode = 0
	switch(mode)
		if(0)
			to_chat(user, "<span class='infoplain'>Power reset. Hugs!</span>")
		if(1)
			to_chat(user, "<span class='infoplain'>Power increased!</span>")
		if(2)
			to_chat(user, "<span class='warningplain'>BZZT. Electrifying arms...</span>")
		if(3)
			to_chat(user, "<span class='warningplain'>ERROR: ARM ACTUATORS OVERLOADED.</span>")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user, params)
	if(M == user)
		return
	switch(mode)
		if(0)
			if(M.health >= 0)
				if(isanimal(M))
					var/list/modifiers = params2list(params)
					if (!user.combat_mode && !LAZYACCESS(modifiers, RIGHT_CLICK))
						M.attack_hand(user, modifiers) //This enables borgs to get the floating heart icon and mob emote from simple_animal's that have petbonus == true.
					return
				if(user.zone_selected == BODY_ZONE_HEAD)
					user.visible_message(span_notice("[user] playfully boops [M] on the head!"), \
									span_notice("You playfully boop [M] on the head!"))
					user.do_attack_animation(M, ATTACK_EFFECT_BOOP)
					playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
				else if(ishuman(M))
					if(user.body_position == LYING_DOWN)
						user.visible_message(span_notice("[user] shakes [M] trying to get [M.p_them()] up!"), \
										span_notice("You shake [M] trying to get [M.p_them()] up!"))
					else
						user.visible_message(span_notice("[user] hugs [M] to make [M.p_them()] feel better!"), \
								span_notice("You hug [M] to make [M.p_them()] feel better!"))
					if(M.resting)
						M.set_resting(FALSE, TRUE)
				else
					user.visible_message(span_notice("[user] pets [M]!"), \
							span_notice("You pet [M]!"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		if(1)
			if(M.health >= 0)
				if(ishuman(M))
					M.adjust_status_effects_on_shake_up()
					if(M.body_position == LYING_DOWN)
						user.visible_message(span_notice("[user] shakes [M] trying to get [M.p_them()] up!"), \
										span_notice("You shake [M] trying to get [M.p_them()] up!"))
					else if(user.zone_selected == BODY_ZONE_HEAD)
						user.visible_message(span_warning("[user] bops [M] on the head!"), \
										span_warning("You bop [M] on the head!"))
						user.do_attack_animation(M, ATTACK_EFFECT_PUNCH)
					else
						user.visible_message(span_warning("[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable..."), \
								span_warning("You hug [M] firmly to make [M.p_them()] feel better! [M] looks uncomfortable..."))
					if(M.resting)
						M.set_resting(FALSE, TRUE)
				else
					user.visible_message(span_warning("[user] bops [M] on the head!"), \
							span_warning("You bop [M] on the head!"))
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
		if(2)
			if(scooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						M.electrocute_act(5, "[user]", flags = SHOCK_NOGLOVES)
						user.visible_message(span_userdanger("[user] electrocutes [M] with [user.p_their()] touch!"), \
							span_danger("You electrocute [M] with your touch!"))
					else
						if(!iscyborg(M))
							M.adjustFireLoss(10)
							user.visible_message(span_userdanger("[user] shocks [M]!"), \
								span_danger("You shock [M]!"))
						else
							user.visible_message(span_userdanger("[user] shocks [M]. It does not seem to have an effect"), \
								span_danger("You shock [M] to no effect."))
					playsound(loc, 'sound/effects/sparks2.ogg', 50, TRUE, -1)
					user.cell.charge -= 500
					scooldown = world.time + 20
		if(3)
			if(ccooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						user.visible_message(span_userdanger("[user] crushes [M] in [user.p_their()] grip!"), \
							span_danger("You crush [M] in your grip!"))
					else
						user.visible_message(span_userdanger("[user] crushes [M]!"), \
								span_danger("You crush [M]!"))
					playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE, -1)
					M.adjustBruteLoss(15)
					user.cell.charge -= 300
					ccooldown = world.time + 10

/obj/item/borg/cyborghug/peacekeeper
	shockallowed = TRUE

/obj/item/borg/cyborghug/medical
	boop = TRUE

/obj/item/borg/charger
	name = "power connector"
	icon_state = "charger_draw"
	item_flags = NOBLUDGEON
	var/mode = "draw"
	var/static/list/charge_machines = typecacheof(list(/obj/machinery/cell_charger, /obj/machinery/recharger, /obj/machinery/recharge_station, /obj/machinery/mech_bay_recharge_port))
	var/static/list/charge_items = typecacheof(list(/obj/item/stock_parts/cell, /obj/item/gun/energy))

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

/obj/item/borg/charger/afterattack(obj/item/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !iscyborg(user))
		return
	if(mode == "draw")
		if(is_type_in_list(target, charge_machines))
			var/obj/machinery/M = target
			if((M.machine_stat & (NOPOWER|BROKEN)) || !M.anchored)
				to_chat(user, span_warning("[M] is unpowered!"))
				return

			to_chat(user, span_notice("You connect to [M]'s power line..."))
			while(do_after(user, 15, target = M, progress = 0))
				if(!user || !user.cell || mode != "draw")
					return

				if((M.machine_stat & (NOPOWER|BROKEN)) || !M.anchored)
					break

				if(!user.cell.give(150))
					break

				M.use_power(200)

			to_chat(user, span_notice("You stop charging yourself."))

		else if(is_type_in_list(target, charge_items))
			var/obj/item/stock_parts/cell/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/stock_parts/cell) in target
			if(!cell)
				to_chat(user, span_warning("[target] has no power cell!"))
				return

			if(istype(target, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = target
				if(!E.can_charge)
					to_chat(user, span_warning("[target] has no power port!"))
					return

			if(!cell.charge)
				to_chat(user, span_warning("[target] has no power!"))


			to_chat(user, span_notice("You connect to [target]'s power port..."))

			while(do_after(user, 15, target = target, progress = 0))
				if(!user || !user.cell || mode != "draw")
					return

				if(!cell || !target)
					return

				if(cell != target && cell.loc != target)
					return

				var/draw = min(cell.charge, cell.chargerate*0.5, user.cell.maxcharge-user.cell.charge)
				if(!cell.use(draw))
					break
				if(!user.cell.give(draw))
					break
				target.update_appearance()

			to_chat(user, span_notice("You stop charging yourself."))

	else if(is_type_in_list(target, charge_items))
		var/obj/item/stock_parts/cell/cell = target
		if(!istype(cell))
			cell = locate(/obj/item/stock_parts/cell) in target
		if(!cell)
			to_chat(user, span_warning("[target] has no power cell!"))
			return

		if(istype(target, /obj/item/gun/energy))
			var/obj/item/gun/energy/E = target
			if(!E.can_charge)
				to_chat(user, span_warning("[target] has no power port!"))
				return

		if(cell.charge >= cell.maxcharge)
			to_chat(user, span_warning("[target] is already charged!"))

		to_chat(user, span_notice("You connect to [target]'s power port..."))

		while(do_after(user, 15, target = target, progress = 0))
			if(!user || !user.cell || mode != "charge")
				return

			if(!cell || !target)
				return

			if(cell != target && cell.loc != target)
				return

			var/draw = min(user.cell.charge, cell.chargerate*0.5, cell.maxcharge-cell.charge)
			if(!user.cell.use(draw))
				break
			if(!cell.give(draw))
				break
			target.update_appearance()

		to_chat(user, span_notice("You stop charging [target]."))

/obj/item/harmalarm
	name = "\improper Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	var/cooldown = 0

/obj/item/harmalarm/emag_act(mob/user)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		to_chat(user, "<font color='red'>You short out the safeties on [src]!</font>")
	else
		to_chat(user, "<font color='red'>You reset the safeties on [src]!</font>")

/obj/item/harmalarm/attack_self(mob/user)
	var/safety = !(obj_flags & EMAGGED)
	if(cooldown > world.time)
		to_chat(user, "<font color='red'>The device is still recharging!</font>")
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 1200)
			to_chat(user, span_warning("You don't have enough charge to do this!"))
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = FALSE

	if(safety == TRUE)
		user.visible_message("<font color='red' size='2'>[user] blares out a near-deafening siren from its speakers!</font>", \
			span_userdanger("The siren pierces your hearing and confuses you!"), \
			span_danger("The siren pierces your hearing!"))
		for(var/mob/living/carbon/M in get_hearers_in_view(9, user))
			if(M.get_ear_protection() == FALSE)
				M.add_confusion(6)
		audible_message("<font color='red' size='7'>HUMAN HARM</font>")
		playsound(get_turf(src), 'sound/ai/harmalarm.ogg', 70, 3)
		cooldown = world.time + 200
		user.log_message("used a Cyborg Harm Alarm in [AREACOORD(user)]", LOG_ATTACK)
		if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			to_chat(R.connected_ai, "<br>[span_notice("NOTICE - Peacekeeping 'HARM ALARM' used by: [user]")]<br>")

		return

	if(safety == FALSE)
		user.audible_message("<font color='red' size='7'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</font>")
		for(var/mob/living/carbon/C in get_hearers_in_view(9, user))
			var/bang_effect = C.soundbang_act(2, 0, 0, 5)
			switch(bang_effect)
				if(1)
					C.add_confusion(5)
					C.stuttering += 10
					C.Jitter(10)
				if(2)
					C.Paralyze(40)
					C.add_confusion(10)
					C.stuttering += 15
					C.Jitter(25)
		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 130, 3)
		cooldown = world.time + 600
		user.log_message("used an emagged Cyborg Harm Alarm in [AREACOORD(user)]", LOG_ATTACK)
