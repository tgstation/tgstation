/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
/obj/item/borg
	icon = 'icons/mob/robot_items.dmi'


/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	var/charge_cost = 30

/obj/item/borg/stun/attack(mob/living/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.check_shields(0, "[M]'s [name]", src, MELEE_ATTACK))
			playsound(M, 'sound/weapons/Genhit.ogg', 50, 1)
			return 0
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(charge_cost))
			return

	user.do_attack_animation(M)
	M.Weaken(5)
	M.apply_effect(STUTTER, 5)
	M.Stun(5)

	M.visible_message("<span class='danger'>[user] has prodded [M] with [src]!</span>", \
					"<span class='userdanger'>[user] has prodded you with [src]!</span>")

	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	add_logs(user, M, "stunned", src, "(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/cyborghug
	name = "Hugging Module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	var/mode = 0 //0 = Hugs 1 = "Hug" 2 = Shock 3 = CRUSH
	var/ccooldown = 0
	var/scooldown = 0
	var/shockallowed = 0//Can it be a stunarm when emagged. Only PK borgs get this by default.

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
			user << "Power reset. Hugs!"
		if(1)
			user << "Power increased!"
		if(2)
			user << "BZZT. Electrifying arms..."
		if(3)
			user << "ERROR: ARM ACTUATORS OVERLOADED."

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user)
	switch(mode)
		if(0)
			if(M.health >= 0)
				if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get \him up!</span>", \
										"<span class='notice'>You shake [M] trying to get \him up!</span>")
					else
						user.visible_message("<span class='notice'>[user] hugs [M] to make \him feel better!</span>", \
								"<span class='notice'>You hug [M] to make \him feel better!</span>")
					if(M.resting)
						M.resting = 0
						M.update_canmove()
				else
					user.visible_message("<span class='notice'>[user] pets [M]!</span>", \
							"<span class='notice'>You pet [M]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(1)
			if(M.health >= 0)
				if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get \him up!</span>", \
										"<span class='notice'>You shake [M] trying to get \him up!</span>")
					else
						user.visible_message("<span class='warning'>[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable...</span>", \
								"<span class='warning'>You hug [M] firmly to make \him feel better! [M] looks uncomfortable...</span>")
					if(M.resting)
						M.resting = 0
						M.update_canmove()
				else
					user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
							"<span class='warning'>You bop [M] on the head!</span>")
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
		if(2)
			if(!scooldown)
				if(M.health >= 0)
					if(ishuman(M)||ismonkey(M))
						M.electrocute_act(5, "[user]", safety = 1)
						user.visible_message("<span class='userdanger'>[user] electrocutes [M] with their touch!</span>", \
							"<span class='danger'>You electrocute [M] with your touch!</span>")
						M.update_canmove()
					else
						if(!iscyborg(M))
							M.adjustFireLoss(10)
							user.visible_message("<span class='userdanger'>[user] shocks [M]!</span>", \
								"<span class='danger'>You shock [M]!</span>")
						else
							user.visible_message("<span class='userdanger'>[user] shocks [M]. It does not seem to have an effect</span>", \
								"<span class='danger'>You shock [M] to no effect.</span>")
					playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, -1)
					user.cell.charge -= 500
					scooldown = 1
					spawn(20)
					scooldown = 0
		if(3)
			if(!ccooldown)
				if(M.health >= 0)
					if(ishuman(M))
						user.visible_message("<span class='userdanger'>[user] crushes [M] in their grip!</span>", \
							"<span class='danger'>You crush [M] in your grip!</span>")
					else
						user.visible_message("<span class='userdanger'>[user] crushes [M]!</span>", \
								"<span class='danger'>You crush [M]!</span>")
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1, -1)
					M.adjustBruteLoss(10)
					user.cell.charge -= 300
					ccooldown = 1
					spawn(10)
					ccooldown = 0

/obj/item/borg/cyborghug/peacekeeper
	shockallowed = 1

/obj/item/borg/charger
	name = "power connector"
	icon_state = "charger_draw"
	flags = NOBLUDGEON
	var/mode = "draw"
	var/list/charge_machines = list(/obj/machinery/cell_charger, /obj/machinery/recharger,
		/obj/machinery/recharge_station, /obj/machinery/mech_bay_recharge_port)
	var/list/charge_items = list(/obj/item/weapon/stock_parts/cell, /obj/item/weapon/gun/energy,
		)

/obj/item/borg/charger/update_icon()
	..()
	icon_state = "charger_[mode]"

/obj/item/borg/charger/attack_self(mob/user)
	if(mode == "draw")
		mode = "charge"
	else
		mode = "draw"
	user << "<span class='notice'>You toggle [src] to \"[mode]\" mode.</span>"
	update_icon()

/obj/item/borg/charger/afterattack(obj/item/target, mob/living/silicon/robot/user, proximity_flag)
	if(!proximity_flag || !iscyborg(user))
		return
	if(mode == "draw")
		if(is_type_in_list(target, charge_machines))
			var/obj/machinery/M = target
			if((M.stat & (NOPOWER|BROKEN)) || !M.anchored)
				user << "<span class='warning'>[M] is unpowered!</span>"
				return

			user << "<span class='notice'>You connect to [M]'s power line...</span>"
			while(do_after(user, 15, target = M, progress = 0))
				if(!user || !user.cell || mode != "draw")
					return

				if((M.stat & (NOPOWER|BROKEN)) || !M.anchored)
					break

				if(!user.cell.give(150))
					break

				M.use_power(200)

			user << "<span class='notice'>You stop charging youself.</span>"

		else if(is_type_in_list(target, charge_items))
			var/obj/item/weapon/stock_parts/cell/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/weapon/stock_parts/cell) in target
			if(!cell)
				user << "<span class='warning'>[target] has no power cell!</span>"
				return

			if(istype(target, /obj/item/weapon/gun/energy))
				var/obj/item/weapon/gun/energy/E = target
				if(!E.can_charge)
					user << "<span class='warning'>[target] has no power port!</span>"
					return

			if(!cell.charge)
				user << "<span class='warning'>[target] has no power!</span>"


			user << "<span class='notice'>You connect to [target]'s power port...</span>"

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
				target.update_icon()

			user << "<span class='notice'>You stop charging youself.</span>"

	else if(is_type_in_list(target, charge_items))
		var/obj/item/weapon/stock_parts/cell/cell = target
		if(!istype(cell))
			cell = locate(/obj/item/weapon/stock_parts/cell) in target
		if(!cell)
			user << "<span class='warning'>[target] has no power cell!</span>"
			return

		if(istype(target, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = target
			if(!E.can_charge)
				user << "<span class='warning'>[target] has no power port!</span>"
				return

		if(cell.charge >= cell.maxcharge)
			user << "<span class='warning'>[target] is already charged!</span>"

		user << "<span class='notice'>You connect to [target]'s power port...</span>"

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
			target.update_icon()

		user << "<span class='notice'>You stop charging [target].</span>"

/obj/item/device/harmalarm
	name = "Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH"
	icon_state = "megaphone"
	var/cooldown = 0
	var/emagged = 0

/obj/item/device/harmalarm/emag_act(mob/user)
	emagged = !emagged
	if(emagged)
		user << "<font color='red'>You short out the safeties on the [src]!</font>"
	else
		user << "<font color='red'>You reset the safeties on the [src]!</font>"

/obj/item/device/harmalarm/attack_self(mob/user)
	var/safety = !emagged
	if(cooldown > world.time)
		user << "<font color='red'>The device is still recharging!</font>"
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell.charge < 1200)
			user << "<font color='red'>You don't have enough charge to do this!</font>"
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = 0

	if(safety == 1)
		user.visible_message("<font color='red' size='2'>[user] blares out a near-deafening siren from its speakers!</font>", \
			"<span class='userdanger'>The siren pierces your hearing and confuses you!</span>", \
			"<span class='danger'>The siren pierces your hearing!</span>")
		for(var/mob/living/carbon/M in get_hearers_in_view(9, user))
			if(M.get_ear_protection() == 0)
				M.confused += 6
		audible_message("<font color='red' size='7'>HUMAN HARM</font>")
		playsound(get_turf(src), 'sound/AI/harmalarm.ogg', 70, 3)
		cooldown = world.time + 200
		log_game("[user.ckey]([user]) used a Cyborg Harm Alarm in ([user.x],[user.y],[user.z])")
		if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			R.connected_ai << "<br><span class='notice'>NOTICE - Peacekeeping 'HARM ALARM' used by: [user]</span><br>"

		return

	if(safety == 0)
		user.audible_message("<font color='red' size='7'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</font>")
		for(var/mob/living/carbon/C in get_hearers_in_view(9, user))
			var/bang_effect = C.soundbang_act(2, 0, 0, 5)
			switch(bang_effect)
				if(1)
					C.confused += 5
					C.stuttering += 10
					C.Jitter(10)
				if(2)
					C.Weaken(2)
					C.confused += 10
					C.stuttering += 15
					C.Jitter(25)
		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 130, 3)
		cooldown = world.time + 600
		log_game("[user.ckey]([user]) used an emagged Cyborg Harm Alarm in ([user.x],[user.y],[user.z])")

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	var/sight_mode = null


/obj/item/borg/sight/xray
	name = "\proper x-ray Vision"
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	sight_mode = BORGXRAY


/obj/item/borg/sight/thermal
	name = "\proper thermal vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"


/obj/item/borg/sight/meson
	name = "\proper meson vision"
	sight_mode = BORGMESON
	icon_state = "meson"

/obj/item/borg/sight/material
	name = "\proper material vision"
	sight_mode = BORGMATERIAL
	icon_state = "material"

/obj/item/borg/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null


/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon_state = "healthhud"

/obj/item/borg/sight/hud/med/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/health(src)
	return


/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon_state = "securityhud"

/obj/item/borg/sight/hud/sec/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/security(src)
	return
