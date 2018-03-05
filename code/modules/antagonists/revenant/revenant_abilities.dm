
//Harvest; activated ly clicking the target, will try to drain their essence.
/mob/living/simple_animal/revenant/ClickOn(atom/A, params) //revenants can't interact with the world directly.
	A.examine(src)
	if(ishuman(A))
		if(A in drained_mobs)
			to_chat(src, "<span class='revenwarning'>[A]'s soul is dead and empty.</span>" )
		else if(in_range(src, A))
			Harvest(A)

/mob/living/simple_animal/revenant/proc/Harvest(mob/living/carbon/human/target)
	if(!castcheck(0))
		return
	if(draining)
		to_chat(src, "<span class='revenwarning'>You are already siphoning the essence of a soul!</span>")
		return
	if(!target.stat)
		to_chat(src, "<span class='revennotice'>[target.p_their(TRUE)] soul is too strong to harvest.</span>")
		if(prob(10))
			to_chat(target, "You feel as if you are being watched.")
		return
	draining = TRUE
	essence_drained += rand(15, 20)
	to_chat(src, "<span class='revennotice'>You search for the soul of [target].</span>")
	if(do_after(src, rand(10, 20), 0, target)) //did they get deleted in that second?
		if(target.ckey)
			to_chat(src, "<span class='revennotice'>[target.p_their(TRUE)] soul burns with intelligence.</span>")
			essence_drained += rand(20, 30)
		if(target.stat != DEAD)
			to_chat(src, "<span class='revennotice'>[target.p_their(TRUE)] soul blazes with life!</span>")
			essence_drained += rand(40, 50)
		else
			to_chat(src, "<span class='revennotice'>[target.p_their(TRUE)] soul is weak and faltering.</span>")
		if(do_after(src, rand(15, 20), 0, target)) //did they get deleted NOW?
			switch(essence_drained)
				if(1 to 30)
					to_chat(src, "<span class='revennotice'>[target] will not yield much essence. Still, every bit counts.</span>")
				if(30 to 70)
					to_chat(src, "<span class='revennotice'>[target] will yield an average amount of essence.</span>")
				if(70 to 90)
					to_chat(src, "<span class='revenboldnotice'>Such a feast! [target] will yield much essence to you.</span>")
				if(90 to INFINITY)
					to_chat(src, "<span class='revenbignotice'>Ah, the perfect soul. [target] will yield massive amounts of essence to you.</span>")
			if(do_after(src, rand(15, 25), 0, target)) //how about now
				if(!target.stat)
					to_chat(src, "<span class='revenwarning'>[target.p_they(TRUE)] [target.p_are()] now powerful enough to fight off your draining.</span>")
					to_chat(target, "<span class='boldannounce'>You feel something tugging across your body before subsiding.</span>")
					draining = 0
					essence_drained = 0
					return //hey, wait a minute...
				to_chat(src, "<span class='revenminor'>You begin siphoning essence from [target]'s soul.</span>")
				if(target.stat != DEAD)
					to_chat(target, "<span class='warning'>You feel a horribly unpleasant draining sensation as your grip on life weakens...</span>")
				reveal(46)
				stun(46)
				target.visible_message("<span class='warning'>[target] suddenly rises slightly into the air, [target.p_their()] skin turning an ashy gray.</span>")
				if(target.anti_magic_check(FALSE, TRUE))
					to_chat(src, "<span class='revenminor'>Something's wrong! [target] seems to be resisting the siphoning, leaving you vulnerable!</span>")
					target.visible_message("<span class='warning'>[target] slumps onto the ground.</span>", \
											   "<span class='revenwarning'>Violets lights, dancing in your vision, receding--</span>")
					return
				var/datum/beam/B = Beam(target,icon_state="drain_life",time=INFINITY)
				if(do_after(src, 46, 0, target)) //As one cannot prove the existance of ghosts, ghosts cannot prove the existance of the target they were draining.
					change_essence_amount(essence_drained, FALSE, target)
					if(essence_drained <= 90 && target.stat != DEAD)
						essence_regen_cap += 5
						to_chat(src, "<span class='revenboldnotice'>The absorption of [target]'s living soul has increased your maximum essence level. Your new maximum essence is [essence_regen_cap].</span>")
					if(essence_drained > 90)
						essence_regen_cap += 15
						perfectsouls++
						to_chat(src, "<span class='revenboldnotice'>The perfection of [target]'s soul has increased your maximum essence level. Your new maximum essence is [essence_regen_cap].</span>")
					to_chat(src, "<span class='revennotice'>[target]'s soul has been considerably weakened and will yield no more essence for the time being.</span>")
					target.visible_message("<span class='warning'>[target] slumps onto the ground.</span>", \
										   "<span class='revenwarning'>Violets lights, dancing in your vision, getting clo--</span>")
					drained_mobs.Add(target)
					target.death(0)
				else
					to_chat(src, "<span class='revenwarning'>[target ? "[target] has":"They have"] been drawn out of your grasp. The link has been broken.</span>")
					if(target) //Wait, target is WHERE NOW?
						target.visible_message("<span class='warning'>[target] slumps onto the ground.</span>", \
											   "<span class='revenwarning'>Violets lights, dancing in your vision, receding--</span>")
				qdel(B)
			else
				to_chat(src, "<span class='revenwarning'>You are not close enough to siphon [target ? "[target]'s":"their"] soul. The link has been broken.</span>")
	draining = FALSE
	essence_drained = 0

/////GLOBAL REVENANT SPELLS/////

//Toggle night vision: lets the revenant toggle its night vision
/obj/effect/proc_holder/spell/targeted/night_vision/revenant
	charge_max = 0
	panel = "Revenant Abilities"
	message = "<span class='revennotice'>You toggle your night vision.</span>"
	action_icon = 'icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_nightvision"
	action_background_icon_state = "bg_revenant"

//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob
/obj/effect/proc_holder/spell/targeted/revenant_transmit
	name = "Transmit"
	desc = "Telepathically transmits a message to the target."
	panel = "Revenant Abilities"
	charge_max = 0
	clothes_req = 0
	range = 7
	include_user = 0
	action_icon = 'icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_revenant"

/obj/effect/proc_holder/spell/targeted/revenant_transmit/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	for(var/mob/living/M in targets)
		var/msg = stripped_input(usr, "What do you wish to tell [M]?", null, "")
		if(!msg)
			charge_counter = charge_max
			return
		log_talk(user,"RevenantTransmit: [key_name(user)]->[key_name(M)] : [msg]",LOGSAY)
		to_chat(user, "<span class='revenboldnotice'>You transmit to [M]:</span> <span class='revennotice'>[msg]</span>")
		if(!M.anti_magic_check(FALSE, TRUE)) //hear no evil
			to_chat(M, "<span class='revenboldnotice'>You hear something behind you talking...</span> <span class='revennotice'>[msg]</span>")
		for(var/ded in GLOB.dead_mob_list)
			if(!isobserver(ded))
				continue
			var/follow_rev = FOLLOW_LINK(ded, user)
			var/follow_whispee = FOLLOW_LINK(ded, M)
			to_chat(ded, "[follow_rev] <span class='revenboldnotice'>[user] Revenant Transmit:</span> <span class='revennotice'>\"[msg]\" to</span> [follow_whispee] <span class='name'>[M]</span>")

/obj/effect/proc_holder/spell/targeted/revenant
	clothes_req = 0
	action_icon = 'icons/mob/actions/actions_revenant.dmi'
	action_background_icon_state = "bg_revenant"
	panel = "Revenant Abilities (Locked)"
	name = "Report this to a coder"
	var/reveal = 80 //How long it reveals the revenant in deciseconds
	var/stun = 20 //How long it stuns the revenant in deciseconds
	var/locked = TRUE //If it's locked and needs to be unlocked before use
	var/unlock_amount = 100 //How much essence it costs to unlock
	var/cast_amount = 50 //How much essence it costs to use

/obj/effect/proc_holder/spell/targeted/revenant/New()
	..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]E)"
	else
		name = "[initial(name)] ([cast_amount]E)"

/obj/effect/proc_holder/spell/targeted/revenant/can_cast(mob/living/simple_animal/revenant/user = usr)
	if(charge_counter < charge_max)
		return FALSE
	if(!istype(user)) //Badmins, no. Badmins, don't do it.
		return TRUE
	if(user.inhibited)
		return FALSE
	if(locked)
		if(user.essence <= unlock_amount)
			return FALSE
	if(user.essence <= cast_amount)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/targeted/revenant/proc/attempt_cast(mob/living/simple_animal/revenant/user = usr)
	if(!istype(user)) //If you're not a revenant, it works. Please, please, please don't give this to a non-revenant.
		name = "[initial(name)]"
		if(locked)
			panel = "Revenant Abilities"
			locked = FALSE
		return TRUE
	if(locked)
		if(!user.castcheck(-unlock_amount))
			charge_counter = charge_max
			return FALSE
		name = "[initial(name)] ([cast_amount]E)"
		to_chat(user, "<span class='revennotice'>You have unlocked [initial(name)]!</span>")
		panel = "Revenant Abilities"
		locked = FALSE
		charge_counter = charge_max
		return FALSE
	if(!user.castcheck(-cast_amount))
		charge_counter = charge_max
		return FALSE
	name = "[initial(name)] ([cast_amount]E)"
	user.reveal(reveal)
	user.stun(stun)
	if(action)
		action.UpdateButtonIcon()
	return TRUE

/obj/effect/proc_holder/spell/aoe_turf/revenant
	clothes_req = 0
	action_icon = 'icons/mob/actions/actions_revenant.dmi'
	action_background_icon_state = "bg_revenant"
	panel = "Revenant Abilities (Locked)"
	name = "Report this to a coder"
	var/reveal = 80 //How long it reveals the revenant in deciseconds
	var/stun = 20 //How long it stuns the revenant in deciseconds
	var/locked = TRUE //If it's locked and needs to be unlocked before use
	var/unlock_amount = 100 //How much essence it costs to unlock
	var/cast_amount = 50 //How much essence it costs to use

/obj/effect/proc_holder/spell/aoe_turf/revenant/New()
	..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]E)"
	else
		name = "[initial(name)] ([cast_amount]E)"

/obj/effect/proc_holder/spell/aoe_turf/revenant/can_cast(mob/living/simple_animal/revenant/user = usr)
	if(charge_counter < charge_max)
		return FALSE
	if(!istype(user)) //Badmins, no. Badmins, don't do it.
		return TRUE
	if(user.inhibited)
		return FALSE
	if(locked)
		if(user.essence <= unlock_amount)
			return FALSE
	if(user.essence <= cast_amount)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/aoe_turf/revenant/proc/attempt_cast(mob/living/simple_animal/revenant/user = usr)
	if(!istype(user)) //If you're not a revenant, it works. Please, please, please don't give this to a non-revenant.
		name = "[initial(name)]"
		if(locked)
			panel = "Revenant Abilities"
			locked = FALSE
		return TRUE
	if(locked)
		if(!user.castcheck(-unlock_amount))
			charge_counter = charge_max
			return FALSE
		name = "[initial(name)] ([cast_amount]E)"
		to_chat(user, "<span class='revennotice'>You have unlocked [initial(name)]!</span>")
		panel = "Revenant Abilities"
		locked = FALSE
		charge_counter = charge_max
		return FALSE
	if(!user.castcheck(-cast_amount))
		charge_counter = charge_max
		return FALSE
	name = "[initial(name)] ([cast_amount]E)"
	user.reveal(reveal)
	user.stun(stun)
	if(action)
		action.UpdateButtonIcon()
	return TRUE

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/obj/effect/proc_holder/spell/aoe_turf/revenant/defile
	name = "Defile"
	desc = "Twists and corrupts the nearby area as well as dispelling holy auras on floors."
	charge_max = 150
	range = 4
	stun = 20
	reveal = 40
	unlock_amount = 75
	cast_amount = 30
	action_icon_state = "defile"

/obj/effect/proc_holder/spell/aoe_turf/revenant/defile/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			INVOKE_ASYNC(src, .proc/defile, T)

/obj/effect/proc_holder/spell/aoe_turf/revenant/defile/proc/defile(turf/T)
	for(var/obj/effect/blessing/B in T)
		qdel(B)
		new /obj/effect/temp_visual/revenant(T)

	if(!isplatingturf(T) && !istype(T, /turf/open/floor/engine/cult) && isfloorturf(T) && prob(15))
		var/turf/open/floor/floor = T
		if(floor.intact && floor.floor_tile)
			new floor.floor_tile(floor)
		floor.broken = 0
		floor.burnt = 0
		floor.make_plating(1)
	if(T.type == /turf/closed/wall && prob(15))
		new /obj/effect/temp_visual/revenant(T)
		T.ChangeTurf(/turf/closed/wall/rust)
	if(T.type == /turf/closed/wall/r_wall && prob(10))
		new /obj/effect/temp_visual/revenant(T)
		T.ChangeTurf(/turf/closed/wall/r_wall/rust)
	for(var/obj/effect/decal/cleanable/salt/salt in T)
		new /obj/effect/temp_visual/revenant(T)
		qdel(salt)
	for(var/obj/structure/closet/closet in T.contents)
		closet.open()
	for(var/obj/structure/bodycontainer/corpseholder in T)
		if(corpseholder.connected.loc == corpseholder)
			corpseholder.open()
	for(var/obj/machinery/dna_scannernew/dna in T)
		dna.open_machine()
	for(var/obj/structure/window/window in T)
		window.take_damage(rand(30,80))
		if(window && window.fulltile)
			new /obj/effect/temp_visual/revenant/cracks(window.loc)
	for(var/obj/machinery/light/light in T)
		light.flicker(20) //spooky

//Malfunction: Makes bad stuff happen to robots and machines.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	charge_max = 200
	range = 4
	cast_amount = 60
	unlock_amount = 200
	action_icon_state = "malfunction"

//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			INVOKE_ASYNC(src, .proc/malfunction, T, user)

/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/proc/malfunction(turf/T, mob/user)
	for(var/mob/living/simple_animal/bot/bot in T)
		if(!bot.emagged)
			new /obj/effect/temp_visual/revenant(bot.loc)
			bot.locked = FALSE
			bot.open = TRUE
			bot.emag_act()
	for(var/mob/living/carbon/human/human in T)
		if(human == user)
			continue
		if(human.anti_magic_check(FALSE, TRUE))
			continue
		to_chat(human, "<span class='revenwarning'>You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")].</span>")
		new /obj/effect/temp_visual/revenant(human.loc)
		human.emp_act(EMP_HEAVY)
	for(var/obj/thing in T)
		if(istype(thing, /obj/machinery/dominator) || istype(thing, /obj/machinery/power/apc) || istype(thing, /obj/machinery/power/smes)) //Doesn't work on dominators, SMES and APCs, to prevent kekkery
			continue
		if(prob(20))
			if(prob(50))
				new /obj/effect/temp_visual/revenant(thing.loc)
			thing.emag_act(null)
		else
			if(!istype(thing, /obj/machinery/clonepod)) //I hate everything but mostly the fact there's no better way to do this without just not affecting it at all
				thing.emp_act(EMP_HEAVY)
	for(var/mob/living/silicon/robot/S in T) //Only works on cyborgs, not AI
		playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
		new /obj/effect/temp_visual/revenant(S.loc)
		S.spark_system.start()
		S.emp_act(EMP_HEAVY)

/////POLTERGEIST (BRUTE GHOST)/////

/obj/effect/proc_holder/spell/targeted/revenant/punch
	name = "Violent Urges"
	desc = "Causes someone to attack someone else. You will be only quickly flashed."
	charge_max = 100
	range = 7
	cast_amount = 40
	unlock_amount = 80
	reveal = 10
	stun = 0
	locked = FALSE
	action_icon_state = "blight"

/obj/effect/proc_holder/spell/targeted/revenant/punch/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/mob/living/target in targets)
			target.a_intent = INTENT_HARM
			target.click_random_mob()

/obj/effect/proc_holder/spell/aoe_turf/revenant/push
	name = "Ethereal Cyclone"
	desc = "Causes nearby objects to fly away from you."
	charge_max = 200
	range = 3
	cast_amount = 75
	unlock_amount = 100
	action_icon_state = "blight"
	sound = 'sound/magic/repulse.ogg'
	reveal = 60
	stun = 20
	var/maxthrow = 5
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	var/anti_magic_check = TRUE
	action_icon_state = "repulse"

/obj/effect/proc_holder/spell/aoe_turf/revenant/push/cast(list/targets,mob/user = usr, var/stun_amt = 40) //repulse does the exact same thing so who am i to not use it's code
	if(attempt_cast(user))
		var/list/thrownatoms = list()
		var/atom/throwtarget
		var/distfromcaster
		playMagSound()
		for(var/turf/T in targets) //Done this way so things don't get thrown all around hilariously.
			for(var/atom/movable/AM in T)
				thrownatoms += AM

		for(var/am in thrownatoms)
			var/atom/movable/AM = am
			if(AM == user || AM.anchored)
				continue

			if(ismob(AM))
				var/mob/M = AM
				if(M.anti_magic_check(anti_magic_check, FALSE))
					continue

			throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
			distfromcaster = get_dist(user, AM)
			if(distfromcaster == 0)
				if(isliving(AM))
					var/mob/living/M = AM
					M.Knockdown(100)
					M.adjustBruteLoss(5)
					to_chat(M, "<span class='userdanger'>You're slammed into the floor by [user]!</span>")
			else
				new sparkle_path(get_turf(AM), get_dir(user, AM)) //created sparkles will disappear on their own
				if(isliving(AM))
					var/mob/living/M = AM
					M.Knockdown(stun_amt)
					to_chat(M, "<span class='userdanger'>You're thrown back by [user]!</span>")
				AM.throw_at(throwtarget, ((CLAMP((maxthrow - (CLAMP(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1,user)

/////SPECTER (BURN GHOST)/////

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe_turf/revenant/overload
	name = "Overload Lights"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	charge_max = 200
	range = 5
	stun = 30
	cast_amount = 40
	var/shock_range = 2
	var/shock_damage = 15
	action_icon_state = "overload_lights"

/obj/effect/proc_holder/spell/aoe_turf/revenant/overload/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			INVOKE_ASYNC(src, .proc/overload, T, user)

/obj/effect/proc_holder/spell/aoe_turf/revenant/overload/proc/overload(turf/T, mob/user)
	for(var/obj/machinery/light/L in T)
		if(!L.on)
			return
		L.visible_message("<span class='warning'><b>\The [L] suddenly flares brightly and begins to spark!</span>")
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(4, 0, L)
		s.start()
		new /obj/effect/temp_visual/revenant(get_turf(L))
		addtimer(CALLBACK(src, .proc/overload_shock, L, user), 20)

/obj/effect/proc_holder/spell/aoe_turf/revenant/overload/proc/overload_shock(obj/machinery/light/L, mob/user)
	if(!L.on) //wait, wait, don't shock me
		return
	flick("[L.base_state]2", L)
	for(var/mob/living/carbon/human/M in view(shock_range, L))
		if(M == user)
			continue
		L.Beam(M,icon_state="purple_lightning",time=5)
		if(!M.anti_magic_check(FALSE, TRUE))
			M.electrocute_act(shock_damage, L, safety=TRUE)
		do_sparks(4, FALSE, M)
		playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)


/////WIGHT (TOXIN GHOST)/////

//Blight: Infects nearby humans and in general messes living stuff up.
/obj/effect/proc_holder/spell/aoe_turf/revenant/blight
	name = "Blight"
	desc = "Causes nearby living things to waste away."
	charge_max = 200
	range = 3
	cast_amount = 50
	unlock_amount = 200
	action_icon_state = "blight"

/obj/effect/proc_holder/spell/aoe_turf/revenant/blight/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			INVOKE_ASYNC(src, .proc/blight, T, user)

/obj/effect/proc_holder/spell/aoe_turf/revenant/blight/proc/blight(turf/T, mob/user)
	for(var/mob/living/mob in T)
		if(mob == user)
			continue
		if(mob.anti_magic_check(FALSE, TRUE))
			continue
		new /obj/effect/temp_visual/revenant(mob.loc)
		if(iscarbon(mob))
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				if(H.dna && H.dna.species)
					H.dna.species.handle_hair(H,"#1d2953") //will be reset when blight is cured
				var/blightfound = FALSE
				for(var/datum/disease/revblight/blight in H.viruses)
					blightfound = TRUE
					if(blight.stage < 5)
						blight.stage++
				if(!blightfound)
					H.AddDisease(new /datum/disease/revblight)
					to_chat(H, "<span class='revenminor'>You feel [pick("suddenly sick", "a surge of nausea", "like your skin is <i>wrong</i>")].</span>")
			else
				if(mob.reagents)
					mob.reagents.add_reagent("plasma", 5)
		else
			mob.adjustToxLoss(5)
	for(var/obj/structure/spacevine/vine in T) //Fucking with botanists, the ability.
		vine.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(vine.loc)
		QDEL_IN(vine, 10)
	for(var/obj/structure/glowshroom/shroom in T)
		shroom.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(shroom.loc)
		QDEL_IN(shroom, 10)
	for(var/obj/machinery/hydroponics/tray in T)
		new /obj/effect/temp_visual/revenant(tray.loc)
		tray.pestlevel = rand(8, 10)
		tray.weedlevel = rand(8, 10)
		tray.toxic = rand(45, 55)

/////PHANTOM (OXYGEN GHOST)/////

/////WENDIGO (BRAIN GHOST)/////

/////PRETA (CLONELOSS GHOST)/////

/obj/effect/proc_holder/spell/targeted/revenant/enthrall
	name = "Enthrall"
	desc = "After a channel, you will seed their mind with a festering madness that will cause them to join your side to build meat effigies. BE VERY CAREFUL NOT TO KILL YOURSELF WITH THIS."
	charge_max = 6000 //10 minutes. don't mess this up!
	range = 7 //right next to em
	cast_amount = 60 //it'll put you at 15 health so beware
	unlock_amount = 80
	reveal = 10
	stun = 0
	action_icon_state = "blight"
	locked = FALSE

/obj/effect/proc_holder/spell/targeted/revenant/enthrall/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		if(!isrevenant(user))
			return FALSE
		var/mob/living/simple_animal/revenant/r = user
		if(r.thrall)
			to_chat(r, "<span class='revenwarning'>You already have a thrall!</span>")
			return FALSE
		to_chat(r, "<span class='revenboldnotice'>Yes, a fine thrall! We need to brainwash them first...</span>")
		for(var/mob/living/carbon/human/H in targets)
			if(!do_after(user, 30, 0, H))
				return FALSE
			r.reveal(100)
			r.stun(100)
			var/datum/beam/B = r.Beam(H,icon_state="animate",time=INFINITY)
			if(!do_after(r, 100, 0, H))
				to_chat(r, "<span class='revenwarning'>The animation has been broken!</span>")
				qdel(B)
				return FALSE
			qdel(B)
			to_chat(H, "<span class='warning'>A horrible feeling decends upon you as your mind goes fuzzy...")

/obj/effect/proc_holder/spell/aoe_turf/revenant/effigy
	name = "Conjure Effigy"
	desc = "Summons a small effigy for you to devour and possess. Must be improved by your thrall before you can use it."
	charge_max = 200
	range = 1
	cast_amount = 75
	unlock_amount = 200
	action_icon_state = "blight"
	locked = FALSE

/obj/effect/proc_holder/spell/aoe_turf/revenant/effigy/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		if(!isrevenant(user))
			return FALSE
		var/mob/living/simple_animal/revenant/r = user
		if(!r.thrall)
			to_chat(r, "<span class='revenwarning'>Get a thrall first!</span>")
			return FALSE
		to_chat(r, "<span class='revenboldnotice'>Fine place as any to prepare a feast!</span>")
		var/obj/structure/effigy/e = new(loc)
		e.linkedpreta = r
		e.linkedthrall = r.thrall
		to_chat(r.thrall, "<span class='revenboldnotice'>Our master has placed the effigy in [get_area_name(e)]!</span>")


/obj/structure/effigy
	name = "meat effigy"
	icon = 'icons/mob/revenant.dmi'
	icon_state = "effigy0"
	anchored = TRUE
	density = TRUE
	opacity = 0
	max_integrity = 200
	obj_integrity = 25
	var/meatlevel = 0
	var/linkedpreta = list()
	var/linkedthrall = list()
	var/requireditem = list()
	var/rareitem = list()

/obj/structure/effigy/examine(mob/user)
	if(ishuman(user) && linkedthrall == user)
		if(level > 0)
			to_chat(user, "<span class='revenboldnotice'>Ah, it's wonderful... But it can be perfected. It just needs...</span>")
		else
			to_chat(user, "<span class='revenboldnotice'>Here's our effigy, granted by our master. We need to start building a wonderful feast for it!</span>")
		to_chat(user, "<span class='revenwarning'>Of course! Nothing but a [requireditem] would do it justice!</span>")
		to_chat(user, "<span class='revenwarning'>But... a [rareitem] would be exceptional if I could ever get my hands on it!</span>")
	else
		if(level > 0)
			to_chat(user, "A hideous amalgamation of flesh and sinew that resembles a horrible creature... Who would build this?!")
		else
			to_chat(user, "It's a broken down borg shell, vibrantly shaking with evil energies. It would be wise to destroy this.")

/obj/structure/effigy/attackby(obj/item/I, mob/user, params)
	if(ishuman(user) && linkedthrall == user)
		if(requireditem == I)
			return TRUE
		to_chat(user, "<span class='revenwarning'>This isn't what it needs! I can examine the effigy to recall what it needs.</span>")
	to_chat(user, "<span class='notice'>You don't know what to do with this... thing.</span>")

/obj/structure/effigy/Destroy()
	if(linkedthrall)
		var/datum/antagonist/thrall/thrall = linkedthrall
		thrall.pretahunt()

/datum/antagonist/thrall
	name = "Thrall"
	roundend_category = "thralls"
	antagpanel_category = "Other"
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/thrall/on_gain()
	give_objective()
	. = ..()

/datum/antagonist/thrall/proc/give_objective()
	var/datum/objective/thrall/effigy/effigy = new
	effigy.owner = owner
	objectives += effigy
	var/datum/objective/thrall/protecteffigy/protecteffigy = new
	protecteffigy.owner = owner
	objectives += protecteffigy
	owner.objectives |= objectives

/datum/antagonist/thrall/proc/pretahunt()
	owner.objectives -= objectives
	var/datum/objective/escape/thrall/escape = new
	escape.owner = owner
	objectives += escape
	owner.objectives |= objectives

/datum/antagonist/thrall/greet()
	playsound(owner, 'sound/spookoween/ghost_whisper.ogg', 50, 1, -1)
	to_chat(owner, "<span class='revenboldnotice'> A painful chatter rushes through your skull as a dark presence focuses its attention on you. It <italics>wants</italics> one small task from you...</span>")
	owner.announce_objectives()

/datum/antagonist/thrall/farewell()
	to_chat(owner, "<span class='warning'>Your mind suddenly clears...</span>")
	to_chat(owner, "<big><span class='warning'><b>You have finally broken free of the Preta's influence! You are no longer controlled by it and can do as you please!</b></span></big>")

/datum/antagonist/thrall/on_removal()
	owner.objectives -= objectives
	. = ..()

/datum/antagonist/thrall/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(owner.objectives.len)
		report += printobjectives(owner)
		for(var/datum/objective/objective in owner.objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(owner.objectives.len == 0 || objectives_complete)
		if(/datum/objective/escape in owner.objectives)
			report += "<span class='greentext big'>The [name] has escaped the Preta!</span>"
		else
			report += "<span class='greentext big'>The [name] constructed the perfect effigy!</span>"
	else
		if(/datum/objective/escape in owner.objectives)
			report += "<span class='greentext big'>The [name] did not escape the Preta!</span>"
		else
			report += "<span class='redtext big'>The [name] has failed to finish the effigy!</span>"


	return report.Join("<br>")

/datum/objective/thrall
	completed = 1

/datum/objective/thrall/effigy
	completed = 0
	explanation_text = "Construct the perfect effigy to satisfy it's hunger."

/datum/objective/thrall/protecteffigy
	explanation_text = "Do not let the effigy be broken under any circumstances, or you will pay the ultimate price."

/datum/objective/escape/thrall
	explanation_text = "The effigy is broken, and the Preta is coming to eat you instead. Escape on the shuttle or an escape pod alive before it finds you."

/datum/objective/escape/thrall/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!considered_pretaescape(M))
			return FALSE
	return TRUE

/datum/objective/proc/considered_pretaescape(datum/mind/M)
	if(!considered_alive(M))
		return FALSE
	if(SSticker.force_ending || SSticker.mode.station_was_nuked)
		return TRUE
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/turf/location = get_turf(M.current)
	return location.onCentCom() || location.onSyndieBase()
