//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob for 5E.
/obj/effect/proc_holder/spell/targeted/revenant_transmit
	name = "Transmit"
	desc = "Telepathically transmits a message to the target."
	panel = "Revenant Abilities"
	charge_max = 0
	clothes_req = 0
	range = 7
	include_user = 0
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_revenant"

/obj/effect/proc_holder/spell/targeted/revenant_transmit/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	for(var/mob/living/M in targets)
		spawn(0)
			var/msg = stripped_input(usr, "What do you wish to tell [M]?", null, "")
			if(!msg)
				charge_counter = charge_max
				return
			usr << "<span class='info'><b>You transmit to [M]:</b> [msg]</span>"
			M << "<span class='deadsay'><b>An alien voice resonates from all around...</b></span><i> [msg]</I>"


//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe_turf/revenant_light
	name = "Overload Lights (30E)"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	panel = "Revenant Abilities (Locked)"
	charge_max = 200
	clothes_req = 0
	range = 1
	var/reveal = 80
	var/stun = 20
	var/locked = 1
	action_icon_state = "overload_lights"
	action_background_icon_state = "bg_revenant"

/obj/effect/proc_holder/spell/aoe_turf/revenant_light/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(locked)
		if(!user.castcheck(-30))
			charge_counter = charge_max
			return
		user << "<span class='info'>You have unlocked Overload Lights!</span>"
		name = "Overload Lights (20E)"
		panel = "Revenant Abilities"
		locked = 0
		range = 2
		charge_counter = charge_max
		return
	if(!user.castcheck(-20))
		charge_counter = charge_max
		return
	for(var/turf/T in targets)
		spawn(0)
			for(var/obj/machinery/light/L in T.contents)
				spawn(0)
					if(!L.on)
						return
					L.visible_message("<span class='warning'><b>\The [L] suddenly flares brightly and begins to spark!</span>")
					sleep(10)
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(4, 1, L)
					s.start()
					sleep(10)
					for(var/mob/living/M in range(4, L))
						if(M == user)
							return
						M.Beam(L,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
						M.electrocute_act(25, "[L.name]")
						var/datum/effect_system/spark_spread/z = new /datum/effect_system/spark_spread
						z.set_up(4, 1, M)
						z.start()
						playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)
	user.reveal(reveal)
	user.stun(stun)


//Defile: Corrupts nearby stuff, unblesses floor tiles.
/obj/effect/proc_holder/spell/aoe_turf/revenant_defile
	name = "Defile (20E)"
	desc = "Twists and corrupts the nearby area. Also dispels holy auras on floors."
	panel = "Revenant Abilities (Locked)"
	charge_max = 200
	clothes_req = 0
	range = 1
	var/reveal = 100
	var/stun = 20
	var/locked = 1
	action_icon_state = "defile"
	action_background_icon_state = "bg_revenant"

/obj/effect/proc_holder/spell/aoe_turf/revenant_defile/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(locked)
		if(!user.castcheck(-35))
			charge_counter = charge_max
			return
		user << "<span class='info'>You have unlocked Defile!</span>"
		name = "Defile (10E)"
		panel = "Revenant Abilities"
		locked = 0
		range = 3
		charge_counter = charge_max
		return
	if(!user.castcheck(-20))
		charge_counter = charge_max
		return
	for(var/turf/T in targets)
		spawn(0)
			if(T.flags & NOJAUNT)
				T.flags -= NOJAUNT
			for(var/mob/living/carbon/human/human in T.contents)
				human << "<span class='warning'>You suddenly feel tired.</span>"
				human.adjustStaminaLoss(35)
			for(var/obj/structure/window/window in T.contents)
				window.hit(rand(50,125))
			for(var/obj/machinery/light/light in T.contents)
				light.flicker() //spooky
	user.reveal(reveal)
	user.stun(stun)


//Malfunction: Makes bad stuff happen to robots and machines.
/obj/effect/proc_holder/spell/aoe_turf/revenant_malf
	name = "Malfunction (50E)"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	panel = "Revenant Abilities (Locked)"
	charge_max = 150
	clothes_req = 0
	range = 1
	var/reveal = 60
	var/stun = 30
	var/locked = 1
	action_icon_state = "malfunction"
	action_background_icon_state = "bg_revenant"

/obj/effect/proc_holder/spell/aoe_turf/revenant_malf/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(locked)
		if(!user.castcheck(-50))
			charge_counter = charge_max
			return
		user << "<span class='info'>You have unlocked Malfunction!</span>"
		name = "Malfunction (15E)"
		panel = "Revenant Abilities"
		locked = 0
		range = 4
		charge_counter = charge_max
		return
	if(!user.castcheck(-15))
		charge_counter = charge_max
		return
	for(var/turf/T in targets)
		spawn(0)
			for(var/obj/machinery/bot/bot in T.contents)
				if(!bot.emagged)
					bot.locked = 0
					bot.open = 1
					bot.Emag(null)
			for(var/obj/machinery/mach in T.contents)
				if(istype(mach, /obj/machinery/dominator) || istype(mach, /obj/machinery/power/apc) || istype(mach, /obj/machinery/power/smes)) //Doesn't work on dominators, SMES and APCs, to prevent kekkery
					continue
				if(prob(10))
					mach.emag_act(null)
				else
					mach.emp_act(1)
			for(var/mob/living/silicon/robot/S in T.contents) //Only works on cyborgs, not AI
				S << "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>"
				S << 'sound/misc/interference.ogg'
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
				sp.set_up(5, 1, S)
				sp.start()
				S.Weaken(6)
	user.reveal(reveal)
	user.stun(stun)