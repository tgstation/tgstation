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
			playsound(M, 'sound/weapons/genhit.ogg', 50, 1)
			return FALSE
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

	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)

	add_logs(user, M, "stunned", src, "(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/cyborghug
	name = "Hugging Module"
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
			to_chat(user, "Power reset. Hugs!")
		if(1)
			to_chat(user, "Power increased!")
		if(2)
			to_chat(user, "BZZT. Electrifying arms...")
		if(3)
			to_chat(user, "ERROR: ARM ACTUATORS OVERLOADED.")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user)
	if(M == user)
		return
	switch(mode)
		if(0)
			if(M.health >= 0)
				if(user.zone_selected == "head")
					user.visible_message("<span class='notice'>[user] playfully boops [M] on the head!</span>", \
									"<span class='notice'>You playfully boop [M] on the head!</span>")
					user.do_attack_animation(M, ATTACK_EFFECT_BOOP)
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
				else if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get [M.p_them()] up!</span>", \
										"<span class='notice'>You shake [M] trying to get [M.p_them()] up!</span>")
					else
						user.visible_message("<span class='notice'>[user] hugs [M] to make [M.p_them()] feel better!</span>", \
								"<span class='notice'>You hug [M] to make [M.p_them()] feel better!</span>")
					if(M.resting)
						M.resting = FALSE
						M.update_canmove()
				else
					user.visible_message("<span class='notice'>[user] pets [M]!</span>", \
							"<span class='notice'>You pet [M]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(1)
			if(M.health >= 0)
				if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get [M.p_them()] up!</span>", \
										"<span class='notice'>You shake [M] trying to get [M.p_them()] up!</span>")
					else if(user.zone_selected == "head")
						user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
										"<span class='warning'>You bop [M] on the head!</span>")
						user.do_attack_animation(M, ATTACK_EFFECT_PUNCH)
					else
						user.visible_message("<span class='warning'>[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable...</span>", \
								"<span class='warning'>You hug [M] firmly to make [M.p_them()] feel better! [M] looks uncomfortable...</span>")
					if(M.resting)
						M.resting = FALSE
						M.update_canmove()
				else
					user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
							"<span class='warning'>You bop [M] on the head!</span>")
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
		if(2)
			if(scooldown < world.time)
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
					scooldown = world.time + 20
		if(3)
			if(ccooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						user.visible_message("<span class='userdanger'>[user] crushes [M] in their grip!</span>", \
							"<span class='danger'>You crush [M] in your grip!</span>")
					else
						user.visible_message("<span class='userdanger'>[user] crushes [M]!</span>", \
								"<span class='danger'>You crush [M]!</span>")
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1, -1)
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
	flags = NOBLUDGEON
	var/mode = "draw"
	var/static/list/charge_machines = typecacheof(list(/obj/machinery/cell_charger, /obj/machinery/recharger, /obj/machinery/recharge_station, /obj/machinery/mech_bay_recharge_port))
	var/static/list/charge_items = typecacheof(list(/obj/item/weapon/stock_parts/cell, /obj/item/weapon/gun/energy))

/obj/item/borg/charger/Initialize()
	. = ..()

/obj/item/borg/charger/update_icon()
	..()
	icon_state = "charger_[mode]"

/obj/item/borg/charger/attack_self(mob/user)
	if(mode == "draw")
		mode = "charge"
	else
		mode = "draw"
	to_chat(user, "<span class='notice'>You toggle [src] to \"[mode]\" mode.</span>")
	update_icon()

/obj/item/borg/charger/afterattack(obj/item/target, mob/living/silicon/robot/user, proximity_flag)
	if(!proximity_flag || !iscyborg(user))
		return
	if(mode == "draw")
		if(is_type_in_list(target, charge_machines))
			var/obj/machinery/M = target
			if((M.stat & (NOPOWER|BROKEN)) || !M.anchored)
				to_chat(user, "<span class='warning'>[M] is unpowered!</span>")
				return

			to_chat(user, "<span class='notice'>You connect to [M]'s power line...</span>")
			while(do_after(user, 15, target = M, progress = 0))
				if(!user || !user.cell || mode != "draw")
					return

				if((M.stat & (NOPOWER|BROKEN)) || !M.anchored)
					break

				if(!user.cell.give(150))
					break

				M.use_power(200)

			to_chat(user, "<span class='notice'>You stop charging youself.</span>")

		else if(is_type_in_list(target, charge_items))
			var/obj/item/weapon/stock_parts/cell/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/weapon/stock_parts/cell) in target
			if(!cell)
				to_chat(user, "<span class='warning'>[target] has no power cell!</span>")
				return

			if(istype(target, /obj/item/weapon/gun/energy))
				var/obj/item/weapon/gun/energy/E = target
				if(!E.can_charge)
					to_chat(user, "<span class='warning'>[target] has no power port!</span>")
					return

			if(!cell.charge)
				to_chat(user, "<span class='warning'>[target] has no power!</span>")


			to_chat(user, "<span class='notice'>You connect to [target]'s power port...</span>")

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

			to_chat(user, "<span class='notice'>You stop charging youself.</span>")

	else if(is_type_in_list(target, charge_items))
		var/obj/item/weapon/stock_parts/cell/cell = target
		if(!istype(cell))
			cell = locate(/obj/item/weapon/stock_parts/cell) in target
		if(!cell)
			to_chat(user, "<span class='warning'>[target] has no power cell!</span>")
			return

		if(istype(target, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = target
			if(!E.can_charge)
				to_chat(user, "<span class='warning'>[target] has no power port!</span>")
				return

		if(cell.charge >= cell.maxcharge)
			to_chat(user, "<span class='warning'>[target] is already charged!</span>")

		to_chat(user, "<span class='notice'>You connect to [target]'s power port...</span>")

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

		to_chat(user, "<span class='notice'>You stop charging [target].</span>")

/obj/item/device/harmalarm
	name = "Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH"
	icon_state = "megaphone"
	var/cooldown = 0
	var/emagged = FALSE

/obj/item/device/harmalarm/emag_act(mob/user)
	emagged = !emagged
	if(emagged)
		to_chat(user, "<font color='red'>You short out the safeties on the [src]!</font>")
	else
		to_chat(user, "<font color='red'>You reset the safeties on the [src]!</font>")

/obj/item/device/harmalarm/attack_self(mob/user)
	var/safety = !emagged
	if(cooldown > world.time)
		to_chat(user, "<font color='red'>The device is still recharging!</font>")
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell.charge < 1200)
			to_chat(user, "<font color='red'>You don't have enough charge to do this!</font>")
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = FALSE

	if(safety == TRUE)
		user.visible_message("<font color='red' size='2'>[user] blares out a near-deafening siren from its speakers!</font>", \
			"<span class='userdanger'>The siren pierces your hearing and confuses you!</span>", \
			"<span class='danger'>The siren pierces your hearing!</span>")
		for(var/mob/living/carbon/M in get_hearers_in_view(9, user))
			if(M.get_ear_protection() == FALSE)
				M.confused += 6
		audible_message("<font color='red' size='7'>HUMAN HARM</font>")
		playsound(get_turf(src), 'sound/ai/harmalarm.ogg', 70, 3)
		cooldown = world.time + 200
		log_game("[user.ckey]([user]) used a Cyborg Harm Alarm in ([user.x],[user.y],[user.z])")
		if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			to_chat(R.connected_ai, "<br><span class='notice'>NOTICE - Peacekeeping 'HARM ALARM' used by: [user]</span><br>")

		return

	if(safety == FALSE)
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

/obj/item/borg/lollipop
	name = "lollipop fabricator"
	desc = "Reward good humans with this. Toggle in-module to switch between dispensing and high velocity ejection modes."
	icon_state = "lollipop"
	var/candy = 30
	var/candymax = 30
	var/charge_delay = 10
	var/charging = 0
	var/mode = 1
	var/firedelay = 0
	var/hitspeed = 2
	var/hitdamage = 0
	var/emaggedhitdamage = 3

/obj/item/borg/lollipop/equipped()
	check_amount()

/obj/item/borg/lollipop/dropped()
	check_amount()

/obj/item/borg/lollipop/proc/check_amount()	//Doesn't even use processing ticks.
	if(charging)
		return
	if(candy < candymax)
		addtimer(CALLBACK(src, .proc/charge_lollipops), charge_delay)
		charging = TRUE

/obj/item/borg/lollipop/proc/charge_lollipops()
	candy++
	charging = FALSE
	check_amount()

/obj/item/borg/lollipop/proc/dispense(atom/A, mob/user)
	if(candy <= 0)
		to_chat(user, "<span class='warning'>No lollipops left in storage!</span>")
		return FALSE
	var/turf/T = get_turf(A)
	if(!T || !istype(T) || !isopenturf(T))
		return FALSE
	if(isobj(A))
		var/obj/O = A
		if(O.density)
			return FALSE
	new /obj/item/weapon/reagent_containers/food/snacks/lollipop(T)
	candy--
	check_amount()
	to_chat(user, "<span class='notice'>Dispensing lollipop...</span>")
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	return TRUE

/obj/item/borg/lollipop/proc/shootL(atom/target, mob/living/user, params)
	if(candy <= 0)
		to_chat(user, "<span class='warning'>Not enough lollipops left!</span>")
		return FALSE
	candy--
	var/obj/item/ammo_casing/caseless/lollipop/A = new /obj/item/ammo_casing/caseless/lollipop(src)
	A.BB.damage = hitdamage
	if(hitdamage)
		A.BB.nodamage = FALSE
	A.BB.speed = 0.5
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	A.fire_casing(target, user, params, 0, 0, null, 0)
	user.visible_message("<span class='warning'>[user] blasts a flying lollipop at [target]!</span>")
	check_amount()

/obj/item/borg/lollipop/proc/shootG(atom/target, mob/living/user, params)	//Most certainly a good idea.
	if(candy <= 0)
		to_chat(user, "<span class='warning'>Not enough gumballs left!</span>")
		return FALSE
	candy--
	var/obj/item/ammo_casing/caseless/gumball/A = new /obj/item/ammo_casing/caseless/gumball(src)
	A.BB.damage = hitdamage
	if(hitdamage)
		A.BB.nodamage = FALSE
	A.BB.speed = 0.5
	A.BB.color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	playsound(src.loc, 'sound/weapons/bulletflyby3.ogg', 50, 1)
	A.fire_casing(target, user, params, 0, 0, null, 0)
	user.visible_message("<span class='warning'>[user] shoots a high-velocity gumball at [target]!</span>")
	check_amount()

/obj/item/borg/lollipop/afterattack(atom/target, mob/living/user, proximity, click_params)
	check_amount()
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(12))
			to_chat(user, "<span class='warning'>Not enough power.</span>")
			return FALSE
		if(R.emagged)
			hitdamage = emaggedhitdamage
	switch(mode)
		if(1)
			if(!proximity)
				return FALSE
			dispense(target, user)
		if(2)
			shootL(target, user, click_params)
		if(3)
			shootG(target, user, click_params)
	hitdamage = initial(hitdamage)

/obj/item/borg/lollipop/attack_self(mob/living/user)
	switch(mode)
		if(1)
			mode++
			to_chat(user, "<span class='notice'>Module is now throwing lollipops.</span>")
		if(2)
			mode++
			to_chat(user, "<span class='notice'>Module is now blasting gumballs.</span>")
		if(3)
			mode = 1
			to_chat(user, "<span class='notice'>Module is now dispensing lollipops.</span>")
	..()

/obj/item/ammo_casing/caseless/gumball
	name = "Gumball"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/item/projectile/bullet/reusable/gumball
	click_cooldown_override = 2


/obj/item/projectile/bullet/reusable/gumball
	name = "gumball"
	desc = "Oh noes! A fast-moving gumball!"
	icon_state = "gumball"
	ammo_type = /obj/item/weapon/reagent_containers/food/snacks/gumball/cyborg
	nodamage = TRUE

/obj/item/projectile/bullet/reusable/gumball/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/weapon/reagent_containers/food/snacks/gumball/S = new ammo_type(T)
		S.color = color
		dropped = TRUE

/obj/item/ammo_casing/caseless/lollipop	//NEEDS RANDOMIZED COLOR LOGIC.
	name = "Lollipop"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/item/projectile/bullet/reusable/lollipop
	click_cooldown_override = 2

/obj/item/projectile/bullet/reusable/lollipop
	name = "lollipop"
	desc = "Oh noes! A fast-moving lollipop!"
	icon_state = "lollipop_1"
	ammo_type = /obj/item/weapon/reagent_containers/food/snacks/lollipop/cyborg
	var/color2 = rgb(0, 0, 0)
	nodamage = TRUE

/obj/item/projectile/bullet/reusable/lollipop/New()
	var/obj/item/weapon/reagent_containers/food/snacks/lollipop/S = new ammo_type(src)
	color2 = S.headcolor
	var/mutable_appearance/head = mutable_appearance('icons/obj/projectiles.dmi', "lollipop_2")
	head.color = color2
	add_overlay(head)

/obj/item/projectile/bullet/reusable/lollipop/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/weapon/reagent_containers/food/snacks/lollipop/S = new ammo_type(T)
		S.change_head_color(color2)
		dropped = TRUE

#define PKBORG_DAMPEN_CYCLE_DELAY 20

//Peacekeeper Cyborg Projectile Dampenening Field
/obj/item/borg/projectile_dampen
	name = "Hyperkinetic Dampening projector"
	desc = "A device that projects a dampening field that weakens kinetic energy above a certain threshold. <span class='boldnotice'>Projects a field that drains power per second \
		while active, that will weaken and slow damaging projectiles inside its field.</span> Still being a prototype, it tends to induce a charge on ungrounded metallic surfaces."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield"
	var/maxenergy = 1500
	var/energy = 1500
	var/energy_recharge = 7.5
	var/energy_recharge_cyborg_drain_coefficient = 0.4
	var/cyborg_cell_critical_percentage = 0.05
	var/mob/living/silicon/robot/host = null
	var/datum/proximity_monitor/advanced/dampening_field
	var/projectile_damage_coefficient = 0.5
	var/projectile_damage_tick_ecost_coefficient = 2	//Lasers get half their damage chopped off, drains 50 power/tick. Note that fields are processed 5 times per second.
	var/projectile_speed_coefficient = 1.5		//Higher the coefficient slower the projectile.
	var/projectile_tick_speed_ecost = 15
	var/list/obj/item/projectile/tracked
	var/image/projectile_effect
	var/field_radius = 3
	var/active = FALSE
	var/cycle_delay = 0

/obj/item/borg/projectile_dampen/debug
	maxenergy = 50000
	energy = 50000
	energy_recharge = 5000

/obj/item/borg/projectile_dampen/Initialize()
	. = ..()
	projectile_effect = image('icons/effects/fields.dmi', "projectile_dampen_effect")
	tracked = list()
	icon_state = "shield0"
	START_PROCESSING(SSfastprocess, src)
	host = loc

/obj/item/borg/projectile_dampen/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/borg/projectile_dampen/attack_self(mob/user)
	if(cycle_delay > world.time)
		to_chat(user, "<span class='boldwarning'>\the [src] is still recycling its projectors!</span>")
		return
	cycle_delay = world.time + PKBORG_DAMPEN_CYCLE_DELAY
	active = !active
	if(active)
		activate_field(user)
	else
		deactivate_field()
	update_icon()
	to_chat(user, "<span class='boldnotice'>You [active? "activate":"deactivate"] the [src].</span>")

/obj/item/borg/projectile_dampen/update_icon()
	icon_state = "[initial(icon_state)][active]"

/obj/item/borg/projectile_dampen/proc/activate_field()
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	dampening_field = make_field(/datum/proximity_monitor/advanced/peaceborg_dampener, list("current_range" = field_radius, "host" = src, "projector" = src))

/obj/item/borg/projectile_dampen/proc/deactivate_field()
	QDEL_NULL(dampening_field)
	visible_message("<span class='warning'>\The [src] shuts off!</span>")
	for(var/P in tracked)
		restore_projectile(P)

/obj/item/borg/projectile_dampen/dropped()
	. = ..()
	host = loc

/obj/item/borg/projectile_dampen/equipped()
	. = ..()
	host = loc

/obj/item/borg/projectile_dampen/on_mob_death()
	deactivate_field()
	. = ..()

/obj/item/borg/projectile_dampen/process()
	process_recharge()
	process_usage()
	update_location()

/obj/item/borg/projectile_dampen/proc/update_location()
	if(dampening_field)
		dampening_field.HandleMove()

/obj/item/borg/projectile_dampen/proc/process_usage()
	var/usage = 0
	for(var/I in tracked)
		var/obj/item/projectile/P = I
		if(!P.stun && P.nodamage)	//No damage
			continue
		usage += projectile_tick_speed_ecost
		usage += (tracked[I] * projectile_damage_tick_ecost_coefficient)
	energy = Clamp(energy - usage, 0, maxenergy)
	if(energy <= 0)
		deactivate_field()
		visible_message("<span class='warning'>The [src] blinks \"ENERGY DEPLETED\"</span>")

/obj/item/borg/projectile_dampen/proc/process_recharge()
	if(!istype(host))
		if(iscyborg(host.loc))
			host = host.loc
		else
			energy = Clamp(energy + energy_recharge, 0, maxenergy)
			return
	if((host.cell.charge >= (host.cell.maxcharge * cyborg_cell_critical_percentage)) && (energy < maxenergy))
		host.cell.use(energy_recharge*energy_recharge_cyborg_drain_coefficient)
		energy += energy_recharge

/obj/item/borg/projectile_dampen/proc/dampen_projectile(obj/item/projectile/P, track_projectile = TRUE)
	if(tracked[P])
		return
	if(track_projectile)
		tracked[P] = P.damage
	P.damage *= projectile_damage_coefficient
	P.speed *= projectile_speed_coefficient
	P.add_overlay(projectile_effect)

/obj/item/borg/projectile_dampen/proc/restore_projectile(obj/item/projectile/P)
	tracked -= P
	P.damage *= (1/projectile_damage_coefficient)
	P.speed *= (1/projectile_speed_coefficient)
	P.cut_overlay(projectile_effect)

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

/obj/item/borg/sight/xray/truesight_lens
	name = "truesight lens"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "truesight_lens"

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
