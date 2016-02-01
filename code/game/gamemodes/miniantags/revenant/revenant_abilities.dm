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
			log_say("RevenantTransmit: [key_name(user)]->[key_name(M)] : [msg]")
			user << "<span class='revennotice'><b>You transmit to [M]:</b> [msg]</span>"
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
	if(!istype(user)) //Badmins, no. Badmins, don't do it.
		if(charge_counter < charge_max)
			return 0
		return 1
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
	if(!istype(user)) //If you're not a revenant, it works. Please, please, please don't give this to a non-revenant.
		name = "[initial(name)]"
		if(locked)
			panel = "Revenant Abilities"
			locked = 0
		return 1
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
	stun = 30
	cast_amount = 40
	var/shock_range = 2
	var/shock_damage = 20
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
						PoolOrNew(/obj/effect/overlay/temp/revenant, L.loc)
						sleep(20)
						if(!L.on) //wait, wait, don't shock me
							return
						flick("[L.base_state]2", L)
						for(var/mob/living/carbon/human/M in view(shock_range, L))
							if(M == user)
								continue
							L.Beam(M,icon_state="purple_lightning",icon='icons/effects/effects.dmi',time=5)
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
	stun = 10
	reveal = 40
	unlock_amount = 75
	cast_amount = 30
	action_icon_state = "defile"

/obj/effect/proc_holder/spell/aoe_turf/revenant/defile/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				if(T.flags & NOJAUNT)
					T.flags -= NOJAUNT
					PoolOrNew(/obj/effect/overlay/temp/revenant, T)
				if(!istype(T, /turf/simulated/floor/plating) && !istype(T, /turf/simulated/floor/engine/cult) && istype(T, /turf/simulated/floor) && prob(15))
					var/turf/simulated/floor/floor = T
					if(floor.intact)
						floor.builtin_tile.loc = floor
					floor.broken = 0
					floor.burnt = 0
					floor.make_plating(1)
				if(!istype(T, /turf/simulated/wall/shuttle) && !istype(T, /turf/simulated/wall/cult) && !istype(T, /turf/simulated/wall/rust) && !istype(T, /turf/simulated/wall/r_wall) && istype(T, /turf/simulated/wall) && prob(15))
					PoolOrNew(/obj/effect/overlay/temp/revenant, T)
					T.ChangeTurf(/turf/simulated/wall/rust)
				if(!istype(T, /turf/simulated/wall/r_wall/rust) && istype(T, /turf/simulated/wall/r_wall) && prob(15))
					PoolOrNew(/obj/effect/overlay/temp/revenant, T)
					T.ChangeTurf(/turf/simulated/wall/r_wall/rust)
				for(var/obj/structure/closet/closet in T.contents)
					closet.open()
				for(var/obj/structure/bodycontainer/corpseholder in T.contents)
					if(corpseholder.connected.loc == corpseholder)
						corpseholder.open()
				for(var/obj/machinery/dna_scannernew/dna in T.contents)
					dna.open_machine()
				for(var/obj/structure/window/window in T.contents)
					window.hit(rand(50,90))
					if(window && window.fulltile)
						PoolOrNew(/obj/effect/overlay/temp/revenant/cracks, window.loc)
				for(var/obj/machinery/light/light in T.contents)
					light.flicker(20) //spooky

//Malfunction: Makes bad stuff happen to robots and machines.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	charge_max = 200
	range = 4
	cast_amount = 45
	unlock_amount = 150
	action_icon_state = "malfunction"

//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				for(var/mob/living/simple_animal/bot/bot in T.contents)
					if(!bot.emagged)
						PoolOrNew(/obj/effect/overlay/temp/revenant, bot.loc)
						bot.locked = 0
						bot.open = 1
						bot.Emag(null)
				for(var/mob/living/carbon/human/human in T.contents)
					if(human == user)
						continue
					human << "<span class='revenwarning'>You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")].</span>"
					PoolOrNew(/obj/effect/overlay/temp/revenant, human.loc)
					human.emp_act(1)
				for(var/obj/thing in T.contents)
					if(istype(thing, /obj/machinery/dominator) || istype(thing, /obj/machinery/power/apc) || istype(thing, /obj/machinery/power/smes)) //Doesn't work on dominators, SMES and APCs, to prevent kekkery
						continue
					if(prob(20))
						if(prob(50))
							PoolOrNew(/obj/effect/overlay/temp/revenant, thing.loc)
						thing.emag_act(null)
					else
						if(!istype(thing, /obj/machinery/clonepod)) //I hate everything but mostly the fact there's no better way to do this without just not affecting it at all
							thing.emp_act(1)
				for(var/mob/living/silicon/robot/S in T.contents) //Only works on cyborgs, not AI
					playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
					PoolOrNew(/obj/effect/overlay/temp/revenant, S.loc)
					S.spark_system.start()
					S.emp_act(1)

//Blight: Infects nearby humans and in general messes living stuff up.
/obj/effect/proc_holder/spell/aoe_turf/revenant/blight
	name = "Blight"
	desc = "Causes nearby living things to waste away."
	charge_max = 200
	range = 3
	reveal = 50
	cast_amount = 50
	unlock_amount = 200
	action_icon_state = "blight"

/obj/effect/proc_holder/spell/aoe_turf/revenant/blight/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				for(var/mob/living/mob in T.contents)
					if(mob == user)
						continue
					PoolOrNew(/obj/effect/overlay/temp/revenant, mob.loc)
					if(iscarbon(mob))
						if(ishuman(mob))
							var/mob/living/carbon/human/H = mob
							if(H.dna && H.dna.species)
								H.dna.species.handle_mutant_bodyparts(H,"#1d2953")
								H.dna.species.handle_hair(H,"#1d2953")
								H.dna.species.update_color(H,"#1d2953")
								spawn(20)
									if(H && H.dna && H.dna.species)
										H.dna.species.handle_mutant_bodyparts(H)
										H.dna.species.handle_hair(H)
										H.dna.species.update_color(H)
							var/blightfound = 0
							for(var/datum/disease/revblight/blight in H.viruses)
								blightfound = 1
								if(blight.stage < 5)
									blight.stage++
							if(!blightfound)
								H.AddDisease(new /datum/disease/revblight)
								H << "<span class='revenminor'>You feel [pick("suddenly sick", "a surge of nausea", "like your skin is <span class='italics'>wrong</span>")].</span>"
						else
							if(mob.reagents)
								mob.reagents.add_reagent("plasma", 5)
					else
						mob.adjustToxLoss(5)
				for(var/obj/effect/spacevine/vine in T.contents) //Fucking with botanists, the ability.
					vine.color = "#823abb"
					PoolOrNew(/obj/effect/overlay/temp/revenant, vine.loc)
					spawn(20)
						if(vine)
							qdel(vine)
				for(var/obj/effect/glowshroom/shroom in T.contents)
					shroom.color = "#823abb"
					PoolOrNew(/obj/effect/overlay/temp/revenant, shroom.loc)
					spawn(20)
						if(shroom)
							qdel(shroom)
				for(var/obj/machinery/hydroponics/tray in T.contents)
					PoolOrNew(/obj/effect/overlay/temp/revenant, tray.loc)
					tray.pestlevel = rand(8, 10)
					tray.weedlevel = rand(8, 10)
					tray.toxic = rand(45, 55)