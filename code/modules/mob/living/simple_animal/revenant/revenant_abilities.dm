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
			if(target in drained_mobs)
				user << "<span class='warning'>[target]'s soul is dead and empty.</span>"
				return
			if(!target.stat)
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
			if(target.stat == UNCONSCIOUS)
				user << "<span class='notice'>They still cling to life, but are not powerful enough to resist. A large amount of essence lies unguarded.</span>"
				essence_drained += 5
			else if(target.stat == DEAD)
				user << "<span class='notice'>They have passed on.</span>"
				essence_drained += 1
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
	name = "Unlock: Transmit (5E)"
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
		usr << "<span class='info'>You have unlocked Transmit!</span>"
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
			M << "<span class='deadsay'><b>Suddenly a strange voice resonates in your head...</b></span><i> [msg]</I>"


//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe_turf/revenant_light
	name = "Unlock: Overload Light (25E)"
	desc = "Directs a large amount of essence into an electrical light, causing an impressive light show."
	panel = "Revenant Abilities (Locked)"
	charge_max = 300
	clothes_req = 0
	range = -1
	var/locked = 1

/obj/effect/proc_holder/spell/aoe_turf/revenant_light/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	if(locked && essence_check(25, 1))
		user << "<span class='info'>You have unlocked Overload Light!</span>"
		name = "Overload Light (25E)"
		panel = "Revenant Abilities"
		locked = 0
		range = 5
		charge_counter = charge_max
		return
	if(locked)
		charge_counter = charge_max
		return
	if(!essence_check(25))
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
	user.revealed = 1
	user.invisibility = 0
	spawn(30)
		user.revealed = 0
		user.invisibility = INVISIBILITY_OBSERVER


//Life Tap: Drains one 'strike' to gain 50E
/obj/effect/proc_holder/spell/targeted/revenant_life_tap
	name = "Unlock: Life Tap (25E)"
	desc = "Draws from your own life pool to gain more essence. Can only be cast three times."
	panel = "Revenant Abilities (Locked)"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1
	var/locked = 1

/obj/effect/proc_holder/spell/targeted/revenant_life_tap/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	if(locked && essence_check(25, 1))
		user << "<span class='info'>You have unlocked Life Tap!</span>"
		name = "Life Tap (0E)"
		panel = "Revenant Abilities"
		locked = 0
		charge_counter = charge_max
		return
	if(locked)
		charge_counter = charge_max
		return
	for(var/mob/living/simple_animal/revenant/target in targets)
		if(!target.strikes)
			target << "<span class='warning'>Your life force has grown too weak to life tap again.</span>"
		target.strikes--
		target << "<span class='info'>You convert your own life into energy.[target.strikes ? "" : " This is the last time you can do this."]</span>"
		target.change_essence_amount(50, 0, "your life pool")


//Seed of Draining: Plants a 'seed' in the target that will slowly siphon essence silently from them.
/obj/effect/proc_holder/spell/targeted/revenant_seed_drain
	name = "Unlock: Seed of Draining (20E)"
	desc = "Corrupts a target with dark energies. Their essence will slowly drain for some time."
	panel = "Revenant Abilities (Locked)"
	charge_max = 1200
	clothes_req = 0
	range = -1
	include_user = 1
	var/locked = 1
	var/planted = 0

/obj/effect/proc_holder/spell/targeted/revenant_seed_drain/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	if(locked && essence_check(20, 1))
		user << "<span class='info'>You have unlocked Seed of Draining!</span>"
		charge_counter = charge_max
		name = "Seed of Draining (20E)"
		locked = 0
		panel = "Revenant Abilities"
		range = 1
		include_user = 0
		return
	if(locked)
		charge_counter = charge_max
		return
	if(!essence_check(20))
		charge_counter = charge_max
		return
	if(planted)
		user << "<span class='warning'>You are already passively draining essence.</span>"
		charge_counter = charge_max
		return
	for(var/mob/living/carbon/human/target in targets)
		if(target.stat == DEAD)
			user << "<span class='warning'>[target] is dead and will not yield essence.</span>"
			charge_counter = charge_max
		user << "<span class='info'>You plant a draining seed on [target].</span>"
		planted = 1
		for(var/i = 0, i < 120, i++)
			sleep(10)
			var/mob/living/carbon/human/M = target
			user.essence += rand(0.3, 0.5) //Not a huge amount of essence; at the least it's 36 and at the most it's 60
			M.adjustStaminaLoss(1)
			if(prob(3))
				target << "<span class='warning'>You feel sapped.</span>" //Letting the target know that they're not bugged and losing stamina 4nr
		planted = 0
		user << "<span class='info'>The energies siphoning [target] have fallen dormant. You will need to plant a new seed.</span>"


//Mind Spike: The typical straight damage ability. Does a decent amount of brute damage and small brain damage.
/obj/effect/proc_holder/spell/targeted/revenant_mindspike
	name = "Unlock: Mind Spike (5E)"
	desc = "Drives a spike of dark energy into the target's mind. Cheap but effective and doesn't take long to cool down."
	panel = "Revenant Abilities (Locked)"
	charge_max = 40
	clothes_req = 0
	range = -1
	include_user = 1
	var/locked = 1

/obj/effect/proc_holder/spell/targeted/revenant_mindspike/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	if(locked && essence_check(5, 1))
		user << "<span class='info'>You have unlocked Mind Spike!</span>"
		charge_counter = charge_max
		name = "Mind Spike (5E)"
		locked = 0
		panel = "Revenant Abilities"
		range = 3
		include_user = 0
		return
	if(locked)
		charge_counter = charge_max
		return
	if(!essence_check(5))
		charge_counter = charge_max
		return
	for(var/mob/living/carbon/human/M in targets)
		user << "<span class='info'>You drive a spike of energy into [M]'s mind!</span>"
		M << "<span class='boldannounce'>You feel a spike of pain in your head!</span>"
		M.apply_damage(12, BRUTE, "head")
		M.adjustBrainLoss(3)
		//M << 'sound/effects/mind_blast.ogg'
		if(prob(20) && !M.stat)
			M.Weaken(2)
			M.visible_message("<span class='warning'>[M] clutches at their head!</span>")
		user.revealed = 1
		user.invisibility = 0
		spawn(10)
			user.revealed = 0
			user.invisibility = INVISIBILITY_OBSERVER

//Hypnotize: Makes the target fall asleep, make them vulnerable to draining.
/obj/effect/proc_holder/spell/targeted/revenant_hypnotize
	name = "Unlock: Hypnotize (15E)"
	desc = "Causes a target to fall asleep."
	panel = "Revenant Abilities (Locked)"
	charge_max = 900
	clothes_req = 0
	range = -1
	include_user = 1
	var/locked = 1

/obj/effect/proc_holder/spell/targeted/revenant_hypnotize/cast(list/targets, var/mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		user << "<span class='warning'>Something is blocking the use of [src]!</span>"
		charge_counter = charge_max
		return
	if(locked && essence_check(15, 1))
		user << "<span class='info'>You have unlocked Hypnotize!</span>"
		charge_counter = charge_max
		name = "Hypnotize (15E)"
		locked = 0
		range = 3
		panel = "Revenant Abilities"
		include_user = 0
		return
	if(locked)
		charge_counter = charge_max
		return
	if(!essence_check(15))
		charge_counter = charge_max
		return
	for(var/mob/living/carbon/human/M in targets)
		user << "<span class='info'>You gently influence [M]'s mind toward deep sleep.</span>"
		M << "<span class='boldannounce'>Tired... <font size=1.5> so tired...</font></span>"
		M.drowsyness += 7
		spawn(70)
			M.sleeping += 30
