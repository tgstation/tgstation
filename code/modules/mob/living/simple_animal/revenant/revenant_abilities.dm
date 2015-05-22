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
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	for(var/mob/living/carbon/human/target in targets)
		spawn(0)
			if(draining)
				user << "<span class='warning'>You are already siphoning the essence of a soul!</span>"
				return
			draining = 1
			essence_drained = 1
			user << "<span class='notice'>You begin searching for [target]'s soul...</span>"
			sleep(30)
			if(target.stat != DEAD)
				user << "<span class='warning'>[target] is not dead and their soul is powerful enough to defend against you.</span>"
				target << "<span class='boldannounce'>You feel an unpleasant draining sensation before it disappears.</span>"
				draining = 0
				return
			var/targetDeath = world.time - target.timeofdeath
			if(target in drained_mobs)
				user << "<span class='warning'>[target]'s soul has warded itself against your pries. Further attempts will be useless.</span>"
				draining = 0
				return
			if(target.ckey)
				user << "<span class='notice'>Their soul burns brightly with intelligence.</span>"
				essence_drained += 3
			if(targetDeath < 5000)
				user << "<span class='notice'>They have died recently. Their soul is confused and vulnerable.</span>"
				essence_drained += 2
			sleep(20)
			switch(essence_drained)
				if(1 to 2)
					user << "<span class='info'>[target]'s soul is dim and will yield only small amounts of essence.</span>"
				if(3 to 4)
					user << "<span class='info'>[target]'s soul is normal and will yield average essence as such.</span>"
				if(5 to INFINITY)
					user << "<span class='info'>Such a feast! [target]'s soul glows with inner fire and will yield much essence to you.</span>"
			sleep(30)
			if(!in_range(user, target))
				user << "<span class='warning'>You are not close enough to siphon [target]'s soul. The link has been broken.</span>"
				draining = 0
				return
			if(!target.stat)
				user << "<span class='warning'>Their corpse has been raised. They can no longer be harvested.</span>"
				target << "<span class='boldannounce'>You feel something tugging across your body before subsiding.</span>"
				draining = 0
				return
			user << "<span class='danger'>You begin siphoning essence from [target]'s soul. You can not move while this is happening.</span>"
			user.icon_state = "revenant_draining"
			user.notransform = 1
			user.revealed = 1
			user.invisibility = 0
			target.visible_message("<span class='warning'>[target] suddenly rises slightly into the air, their skin turning an ashy gray.</span>")
			target.Beam(user,icon_state="drain_life",icon='icons/effects/effects.dmi',time=80)
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
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	if(locked && essence_check(5, 1))
		usr << "<span class='info'>You have unlocked Transmit! This ability will allow you to communicate with people.</span>"
		name = "Transmit (5E)"
		locked = 0
		charge_counter = charge_max
		panel = "Revenant Abilities"
		range = 7
		include_user = 0
		return
	if(locked)
		charge_counter = charge_max
		return
	if(!essence_check(5))
		charge_counter = charge_max
		return
	for(var/mob/living/M in targets)
		spawn(0)
			var/msg = stripped_input(usr, "What do you wish to tell [M]?", null, "")
			usr << "<span class='info'><b>You transmit to [M]:</b> [msg]</span>"
			M << "<span class='deadsay'><b>You hear an odd, alien voice in your head...</b></span><i> [msg]</I>"
			user.RevenantReveal(3, user, 0)


//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe_turf/revenant_overloadLight
	name = "Overload Light (35E)"
	desc = "Directs a large amount of essence into an electrical light, causing an impressive light show."
	panel = "Revenant Abilities (Locked)"
	charge_max = 300
	clothes_req = 0
	range = 1
	var/locked = 1

/obj/effect/proc_holder/spell/aoe_turf/revenant_overloadLight/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	if(locked && essence_check(35, 1))
		user << "<span class='info'>You have unlocked Overload Light! This ability will imbue nearby lights with essence, causing them to spit bolts of lightning at nearby things.</span>"
		name = "Overload Light (35E)"
		panel = "Revenant Abilities"
		locked = 0
		range = 5
		charge_counter = charge_max
		return
	if(locked)
		charge_counter = charge_max
		return
	if(!essence_check(35))
		charge_counter = charge_max
		return
	for(var/turf/T in targets)
		user << "<span class='info'>You imbue nearby lights with essence.</span>"
		user.RevenantReveal(20, user, 0)
		spawn(0)
			for(var/obj/machinery/light/L in T.contents)
				spawn(0)
					if(!L.on)
						return
					L.color = "#CA58FF"
					L.visible_message("<span class='warning'>\The [L]'s light suddenly becomes a deep violet...</span>")
					sleep(20)
					for(var/mob/living/M in orange(4, L))
						if(M == user)
							return
						M.Stun(1)
						M.Beam(L,icon_state="lightning",icon='icons/effects/effects.dmi',time=2)
						M.electrocute_act(rand(5,30), "[L.name]")
						L.color = "white"
						playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)


//Shatter: Breaks a window.
/obj/effect/proc_holder/spell/aoe_turf/revenant_breakWindow
	name = "Shatter (10E)"
	desc = "Breaks nearby windows. That's literally it."
	panel = "Revenant Abilities (Locked)"
	charge_max = 75
	clothes_req = 0
	range = 1
	var/locked = 1

/obj/effect/proc_holder/spell/aoe_turf/revenant_breakWindow/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	if(locked && essence_check(10, 1))
		user << "<span class='info'>You have unlocked Shatter! This ability will break apart nearby windows.</span>"
		name = "Shatter (10E)"
		panel = "Revenant Abilities"
		locked = 0
		charge_counter = charge_max
		return
	if(locked)
		charge_counter = charge_max
		return
	if(!essence_check(10))
		charge_counter = charge_max
		return
	user << "<span class='info'>You damage nearby windows.</span>"
	user.RevenantReveal(20, user, 0)
	for(var/turf/T in targets)
		spawn(0)
			for(var/obj/structure/window/W in T.contents)
				W.hit(W.maxhealth) //Doesn't break r-windows
