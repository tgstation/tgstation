//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob
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
			usr << "<span class='revennotice'><b>You transmit to [M]:</b> [msg]</span>"
			M << "<span class='revennotice'><b>An alien voice resonates from all around...</b></span><i> [msg]</I>"


/obj/effect/proc_holder/spell/aoe_turf/revenant
	clothes_req = 0
	action_background_icon_state = "bg_revenant"
	panel = "Revenant Abilities (Locked)"
	name = "Report this to a coder"
	var/reveal = 80 //How long it reveals the revenant in deciseconds
	var/stun = 20 //How long it stuns the revenant in deciseconds
	var/locked = 1 //If it's locked and needs to be unlocked before use
	var/unlock_amount = 100 //How much essence it costs to unlock
	var/cast_amount = 50 //How much essence it costs to use

/obj/effect/proc_holder/spell/aoe_turf/revenant/New()
	..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]E)"
	else
		name = "[initial(name)] ([cast_amount]E)"

/obj/effect/proc_holder/spell/aoe_turf/revenant/can_cast(mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		return 0
	if(charge_counter < charge_max)
		return 0
	if(locked)
		if(user.essence <= unlock_amount)
			return 0
	if(user.essence <= cast_amount)
		return 0
	return 1

/obj/effect/proc_holder/spell/aoe_turf/revenant/proc/attempt_cast(mob/living/simple_animal/revenant/user = usr)
	if(locked)
		if(!user.castcheck(-unlock_amount))
			charge_counter = charge_max
			return 0
		name = "[initial(name)] ([cast_amount]E)"
		user << "<span class='revennotice'>You have unlocked [initial(name)]!</span>"
		panel = "Revenant Abilities"
		locked = 0
		charge_counter = charge_max
		return 0
	if(!user.castcheck(-cast_amount))
		charge_counter = charge_max
		return 0
	name = "[initial(name)] ([cast_amount]E)"
	user.reveal(reveal)
	user.stun(stun)
	user.update_action_buttons()
	return 1

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe_turf/revenant/overload
	name = "Overload Lights"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	charge_max = 200
	range = 5
	stun = 40
	cast_amount = 45
	var/shock_range = 2
	var/shock_damage = 18
	action_icon_state = "overload_lights"

/obj/effect/proc_holder/spell/aoe_turf/revenant/overload/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				for(var/obj/machinery/light/L in T.contents)
					spawn(0)
						if(!L.on)
							return
						L.visible_message("<span class='warning'><b>\The [L] suddenly flares brightly and begins to spark!</span>")
						var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
						s.set_up(4, 0, L)
						s.start()
						new/obj/effect/overlay/temp/revenant(L.loc)
						sleep(20)
						if(!L.on) //wait, wait, don't shock me
							return
						flick("[L.base_state]2", L)
						for(var/mob/living/carbon/human/M in range(shock_range, L))
							if(M == user)
								return
							M.Beam(L,icon_state="purple_lightning",icon='icons/effects/effects.dmi',time=5)
							M.electrocute_act(shock_damage, "[L.name]", safety=1)
							var/datum/effect_system/spark_spread/z = new /datum/effect_system/spark_spread
							z.set_up(4, 0, M)
							z.start()
							playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/obj/effect/proc_holder/spell/aoe_turf/revenant/defile
	name = "Defile"
	desc = "Twists and corrupts the nearby area as well as dispelling holy auras on floors."
	charge_max = 150
	range = 3
	stun = 30
	unlock_amount = 75
	cast_amount = 40
	action_icon_state = "defile"
	var/stamdamage= 25
	var/toxdamage = 3
	var/confusion = 50

/obj/effect/proc_holder/spell/aoe_turf/revenant/defile/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				if(T.flags & NOJAUNT)
					T.flags -= NOJAUNT
					new/obj/effect/overlay/temp/revenant(T)
				for(var/mob/living/carbon/human/human in T.contents)
					human << "<span class='warning'>You suddenly feel [pick("sick and tired", "tired and confused", "nauseated", "dizzy")].</span>"
					human.adjustStaminaLoss(stamdamage)
					human.adjustToxLoss(toxdamage)
					human.confused += confusion
					new/obj/effect/overlay/temp/revenant(human.loc)
				if(!istype(T, /turf/simulated/wall/shuttle) && !istype(T, /turf/simulated/wall/rust) && !istype(T, /turf/simulated/wall/r_wall) && istype(T, /turf/simulated/wall) && prob(15))
					new/obj/effect/overlay/temp/revenant(T)
					T.ChangeTurf(/turf/simulated/wall/rust)
				if(!istype(T, /turf/simulated/wall/r_wall/rust) && istype(T, /turf/simulated/wall/r_wall) && prob(15))
					new/obj/effect/overlay/temp/revenant(T)
					T.ChangeTurf(/turf/simulated/wall/r_wall/rust)
				for(var/obj/structure/window/window in T.contents)
					window.hit(rand(50,90))
					if(window && window.fulltile)
						new/obj/effect/overlay/temp/revenant/cracks(window.loc)
				for(var/obj/machinery/light/light in T.contents)
					light.flicker(30) //spooky

//Malfunction: Makes bad stuff happen to robots and machines.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	charge_max = 200
	range = 4
	unlock_amount = 150
	action_icon_state = "malfunction"

//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				for(var/obj/machinery/bot/bot in T.contents)
					if(!bot.emagged)
						new/obj/effect/overlay/temp/revenant(bot.loc)
						bot.locked = 0
						bot.open = 1
						bot.Emag(null)
				for(var/mob/living/carbon/human/human in T.contents)
					human << "<span class='warning'>You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")].</span>"
					new/obj/effect/overlay/temp/revenant(human.loc)
					human.emp_act(1)
				for(var/obj/thing in T.contents)
					if(istype(thing, /obj/machinery/dominator) || istype(thing, /obj/machinery/power/apc) || istype(thing, /obj/machinery/power/smes) || istype(thing, /obj/machinery/bot)) //Doesn't work on dominators, SMES and APCs, to prevent kekkery
						continue
					if(prob(20))
						if(prob(50))
							new/obj/effect/overlay/temp/revenant(thing.loc)
						thing.emag_act(null)
					else
						if(!istype(thing, /obj/machinery/clonepod)) //I hate everything but mostly the fact there's no better way to do this without just not affecting it at all
							thing.emp_act(1)
				for(var/mob/living/silicon/robot/S in T.contents) //Only works on cyborgs, not AI
					playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
					new/obj/effect/overlay/temp/revenant(S.loc)
					S.spark_system.start()
					S.emp_act(1)