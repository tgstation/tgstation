//Harvest Essence: The bread and butter of the revenant. The basic way of harvesting additional essence.
/obj/effect/proc_holder/spell/targeted/revenant_harvest
	name = "Harvest (0E)"
	desc = "Siphons the lingering spectral essence from a human, empowering yourself."
	panel = "Revenant Abilities"
	charge_max = 100 //Short cooldown
	clothes_req = 0
	range = 5
	var/essence_drained = 0
	var/draining
	var/list/drained_mobs = list() //Cannot harvest the same mob twice

/obj/effect/proc_holder/spell/targeted/revenant_harvest/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(!user.castcheck(0))
		charge_counter = charge_max
		return
	for(var/mob/living/carbon/human/target in targets)
		spawn(0)
			if(draining)
				user << "<span class='warning'>You are already siphoning the essence of a soul!</span>"
				return
			if(target in drained_mobs)
				user << "<span class='warning'>[target]'s soul is dead and empty.</span>"
				return
			if(target.stat != DEAD)
				user << "<span class='notice'>This being's soul is too strong to harvest.</span>"
				if(prob(10))
					target << "You feel as if you are being watched."
				return
			draining = 1
			essence_drained = 1
			user << "<span class='notice'>You search for the still-living soul of [target].</span>"
			sleep(10)
			if(target.ckey)
				user << "<span class='notice'>Their soul burns with intelligence.</span>"
				essence_drained += 3
			sleep(20)
			switch(essence_drained)
				if(1 to 2)
					user << "<span class='info'>[target] will not yield much essence. Still, every bit counts.</span>"
				if(3 to 4)
					user << "<span class='info'>[target] will yield an average amount of essence.</span>"
				if(5 to INFINITY)
					user << "<span class='info'>Such a feast! [target] will yield much essence to you.</span>"
			sleep(30)
			if(!in_range(user, target))
				user << "<span class='warning'>You are not close enough to siphon [target]'s soul. The link has been broken.</span>"
				draining = 0
				return
			if(!target.stat)
				user << "<span class='warning'>They are now powerful enough to fight off your draining.</span>"
				target << "<span class='boldannounce'>You feel something tugging across your body before subsiding.</span>"
			user << "<span class='danger'>You begin siphoning essence from [target]'s soul. You can not move while this is happening.</span>"
			if(target.stat != DEAD)
				target << "<span class='warning'>You feel a horribly unpleasant draining sensation as your grip on life weakens...</span>"
			user.icon_state = "revenant_draining"
			user.notransform = 1
			user.revealed = 1
			user.invisibility = 0
			target.visible_message("<span class='warning'>[target] suddenly rises slightly into the air, their skin turning an ashy gray.</span>")
			target.Beam(user,icon_state="drain_life",icon='icons/effects/effects.dmi',time=80)
			target.death(0)
			target.visible_message("<span class='warning'>[target] gently slumps back onto the ground.</span>")
			user.icon_state = "revenant_idle"
			user.change_essence_amount(essence_drained * 5, 0, target)
			user << "<span class='info'>[target]'s soul has been considerably weakened and will yield no more essence for the time being.</span>"
			user.revealed = 0
			user.notransform = 0
			user.invisibility = INVISIBILITY_OBSERVER
			drained_mobs.Add(target)
			draining = 0


//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob for 5E.
/obj/effect/proc_holder/spell/targeted/revenant_transmit
	name = "Transmit (5E)"
	desc = "Telepathically transmits a message to the target."
	panel = "Revenant Abilities (Locked)"
	charge_max = 50
	clothes_req = 0
	range = -1
	include_user = 1
	var/locked = 1

/obj/effect/proc_holder/spell/targeted/revenant_transmit/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(!user.castcheck(-5))
		charge_counter = charge_max
		return
	if(locked)
		usr << "<span class='info'>You have unlocked Transmit!</span>"
		locked = 0
		charge_counter = charge_max
		panel = "Revenant Abilities"
		range = 7
		include_user = 0
		return
	for(var/mob/living/M in targets)
		spawn(0)
			var/msg = stripped_input(usr, "What do you wish to tell [M]?", null, "")
			if(!msg)
				charge_counter = charge_max
				return
			usr << "<span class='info'><b>You transmit to [M]:</b> [msg]</span>"
			M << "<span class='deadsay'><b>A strange voice resonates in your head...</b></span><i> [msg]</I>"


//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe_turf/revenant_light
	name = "Overload Light (25E)"
	desc = "Directs a large amount of essence into an electrical light, causing an impressive light show."
	panel = "Revenant Abilities (Locked)"
	charge_max = 300
	clothes_req = 0
	range = 1
	var/locked = 1

/obj/effect/proc_holder/spell/aoe_turf/revenant_light/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(!user.castcheck(-25))
		charge_counter = charge_max
		return
	if(locked)
		user << "<span class='info'>You have unlocked Overload Light!</span>"
		panel = "Revenant Abilities"
		locked = 0
		range = 5
		charge_counter = charge_max
		return
	for(var/turf/T in targets)
		spawn(0)
			for(var/obj/machinery/light/L in T.contents)
				spawn(0)
					if(!L.on)
						return
					L.visible_message("<span class='warning'><b>\The [L] suddenly flares brightly and begins to spark!</span>")
					sleep(20)
					for(var/mob/living/M in orange(4, L))
						if(M == user)
							return
						M.Beam(L,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
						M.electrocute_act(25, "[L.name]")
						playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)
	user.reveal(50, 1)


//Defile: Corrupts nearby stuff, unblesses floor tiles.
/obj/effect/proc_holder/spell/aoe_turf/revenantDefile
	name = "Defile (30E)"
	desc = "Twists and corrupts certain nearby objects."
	panel = "Revenant Abilities (Locked)"
	charge_max = 300
	clothes_req = 0
	range = 1
	var/locked = 1

/obj/effect/proc_holder/spell/aoe_turf/revenantDefile/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(!user.castcheck(-30))
		charge_counter = charge_max
		return
	if(locked)
		user << "<span class='info'>You have unlocked Defile!</span>"
		panel = "Revenant Abilities"
		locked = 0
		range = 4
		charge_counter = charge_max
		return
	for(var/turf/T in targets)
		spawn(0)
			if(T.flags & NOJAUNT)
				T.flags -= NOJAUNT
			for(var/obj/machinery/bot/bot in T.contents)
				bot.emag_act()
				bot.visible_message("<span class='warning'>[bot] [pick("shudders", "buzzes", "clunks")] [pick("oddly", "strangely", "loudly")]!</span>")
			for(var/mob/living/carbon/human/human in T.contents)
				human << "<span class='warning'>You suddenly feel tired.</span>"
				human.adjustStaminaLoss(25)
			for(var/mob/living/silicon/robot/robot in T.contents)
				robot.visible_message("<span class='warning'>[robot] lets out an alarm!</span>", \
									  "<span class='boldannounce'>01001111 01010110 01000101 01010010 01001100 01001111 01000001 01000100</span>")
				robot << 'sound/misc/interference.ogg'
				playsound(robot, 'sound/machines/warning-buzzer.ogg', 50, 1)
			for(var/obj/structure/window/window in T.contents)
				window.hit(rand(10,50))
	user.reveal(30, 1)
