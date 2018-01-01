
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
		to_chat(M, "<span class='revenboldnotice'>You hear something behind you talking...</span> <span class='revennotice'>[msg]</span>")
		for(var/ded in GLOB.dead_mob_list)
			if(!isobserver(ded))
				continue
			var/follow_rev = FOLLOW_LINK(ded, user)
			var/follow_whispee = FOLLOW_LINK(ded, M)
			to_chat(ded, "[follow_rev] <span class='revenboldnotice'>[user] Revenant Transmit:</span> <span class='revennotice'>\"[msg]\" to</span> [follow_whispee] <span class='name'>[M]</span>")



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

//Spook: Free spell that gives people phobias with a jump!
/obj/effect/proc_holder/spell/aoe_turf/revenant/spook
	name = "Spook"
	desc = "Materialize with a jump to give spacemen phobias. Phobias you can exploit."
	locked = FALSE
	range = 7
	stun = 20
	reveal = 50
	cast_amount = 20
	unlock_amount = 50 //for some reason if this is locked
	action_icon_state = "spook"

/obj/effect/proc_holder/spell/aoe_turf/revenant/spook/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		playsound(user, 'sound/magic/divulge_end.ogg', 15, 1, -1) //it's a sound, i don't need to take in account people seeing it
		for(var/mob/living/M in viewers(7, user))
			if(M == user)
				continue //don't spook yaself :(
			flash_color(M, flash_color = list("#db0000", "#db0000", "#db0000", rgb(0,0,0)), flash_time = 50)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.gain_trauma(/datum/brain_trauma/mild/phobia, FALSE, "skeletons")

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
		M.electrocute_act(shock_damage, L, safety=1)
		do_sparks(4, FALSE, M)
		playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)

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
	if(T.flags_1 & NOJAUNT_1)
		T.flags_1 &= ~NOJAUNT_1
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

//Induce Madness: Drive someone boooooonkers!
/obj/effect/proc_holder/spell/targeted/revenant/madness
	name = "Induce Madness"
	desc = "Slowly descends someone into madness, causing them to do unpredictable things and, as a side effect, melts their brain."
	charge_max = 150
	range = 7
	include_user = 0
	stun = 20
	reveal = 80
	unlock_amount = 150
	cast_amount = 60
	action_icon_state = "induce_madness"

/datum/antagonist/abductee/mindsnapped //pillzredux
		name = "Broken"
		roundend_category = "insane people"

/datum/antagonist/abductee/mindsnapped/greet()
	playsound(owner, 'sound/spookoween/ghost_whisper.ogg', 50, 1, -1)
	to_chat(owner, "<span class='revenboldnotice'>You finally snap, and the voices in your head speak to you directly. They have a job for you...")
	owner.announce_objectives()

/obj/effect/proc_holder/spell/targeted/revenant/madness/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/mob/living/carbon/human/target in targets)
			if(target.stat)
				to_chat(user, "<span class='revennotice'>Not enough brain activity for our powers!</span>")
				continue
			to_chat(user, "<span class='revenwarning'>We have seeded madness in [target]'s mind! It will continue to fester...</span>")
			to_chat(target, "<span class='warning'>A horrible feeling decends upon you as your mind goes fuzzy...")
			var/turf/soundturf = get_turf(target)
			target.playsound_local(soundturf, 'sound/spookoween/ghosty_wind.ogg', 50, 1)
			addtimer(CALLBACK(src, .proc/mind_warn, target), 300)
			addtimer(CALLBACK(src, .proc/mind_snap, target), 600)

/obj/effect/proc_holder/spell/targeted/revenant/madness/proc/mind_warn(mob/living/carbon/human/target)
	to_chat(target, "<span class='revenwarning'>voices in your head whisper, acclimating their arrival in disgust.")

/obj/effect/proc_holder/spell/targeted/revenant/madness/proc/mind_snap(mob/living/carbon/human/target)
	target.mind.add_antag_datum(/datum/antagonist/abductee/mindsnapped) // this handles adding the random objective in it's on_gain proc
	target.gain_trauma_type(BRAIN_TRAUMA_SEVERE)
	target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL)

/obj/effect/proc_holder/spell/targeted/revenant/animate_bone
	name = "Animate Bone"
	desc = "Exhumes the skeleton from it's host, as long as the body has been drained. It will hunt down the living."
	charge_max = 300
	range = 1
	include_user = 0
	reveal = 0 //How long it reveals the revenant in deciseconds
	stun = 0 //How long it stuns the revenant in deciseconds
	unlock_amount = 150
	cast_amount = 30
	action_icon_state = "animate_bone"

/obj/effect/proc_holder/spell/targeted/revenant/animate_bone/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/mob/living/M in targets)
			if(!(M in user.drained_mobs))
				to_chat(user, "<span class='revenwarning'>Harvest the soul first!</span>")
				return FALSE
			to_chat(user, "<span class='revenboldnotice'>Ah yes, this will do nicely! You charge up your necrotic powers...</span>")
			if(!do_after(user, 30, 0, M))
				return FALSE
			user.reveal(66)
			user.stun(66)
			M.visible_message("<span class='warning'>[M] starts shaking violently!</span>", \
				  "<span class='userdanger'>You lock up, but your bones do not! THEY'RE TRYING TO GET OUT!</span>")
			M.Knockdown(66)
			M.Jitter(66)
			M.adjustBruteLoss(30) //i'm pretty sure your skeleton trying to get out hurts, but i'm no doctor.
			var/datum/beam/B = user.Beam(M,icon_state="animate",time=INFINITY)
			if(!do_after(user, 66, 0, M))
				to_chat(user, "<span class='revenwarning'>The animation has been broken!</span>")
				qdel(B)
				return FALSE
			qdel(B)
			M.visible_message("<span class='userdanger'>[M]'s skeleton explodes out of them in a shower of gore!</span>")
			var/mob/living/simple_animal/hostile/skeleton/revenant/S
			S = new(M.loc)
			S.name = "[M]'s haunted remains"
				S.speak += "Join us..."
			M.gib()

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
