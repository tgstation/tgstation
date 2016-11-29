#define MEDAL_PREFIX "Hierophant"
/*

The Hierophant

The Hierophant spawns in its arena, an area designed to make it harder to fight than it would otherwise be.

The text this boss speaks is ROT4, use ROT22 to decode

The Hierophant's attacks are as follows, and INTENSIFY at a random chance based on Hierophant's health;
- Creates a cardinal or diagonal blast(Cross Blast) under its target, exploding after a short time.
	INTENSITY EFFECT: Creates one of the cross blast types under itself instead of under the target.
	INTENSITY EFFECT: The created Cross Blast fires in all directions if below half health.
- If no chasers exist, creates a chaser that will seek its target, leaving a trail of blasts.
	INTENSITY EFFECT: Creates a second, slower chaser.
- Creates an expanding AoE burst.
- INTENSE ATTACKS:
	If target is at least 2 tiles away; Blinks to the target after a very brief delay, damaging everything near the start and end points.
		As above, but does so multiple times if below half health.
	Rapidly creates Cross Blasts under a target.
	If chasers are off cooldown, creates four high-speed chasers.
- IF TARGET WAS STRUCK IN MELEE: Creates a 3x3 square of blasts under the target.

Cross Blasts and the AoE burst gain additional range as the Hierophant loses health, while Chasers gain additional speed.

When The Hierophant dies, it leaves behind its staff, which, while much weaker than when wielded by The Hierophant itself, is still quite effective.
- The staff can place a teleport rune, allowing the user to teleport themself and their allies to the rune.

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/hierophant
	name = "Hierophant"
	desc = "Stolen from Hyper Light Drifter."
	health = 2500
	maxHealth = 2500
	attacktext = "clubs"
	//attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_sound = "swing_hit"
	icon_state = "hierophant"
	icon_living = "hierophant"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/hierophant.dmi'
	faction = list("boss") //asteroid mobs? get that shit out of my beautiful square house
	speak_emote = list("preaches")
	armour_penetration = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	speed = 1
	move_to_delay = 10
	ranged = 1
	pixel_x = -16
	ranged_cooldown_time = 40
	aggro_vision_range = 23
	loot = list(/obj/item/weapon/hierophant_staff)
	wander = FALSE
	var/burst_range = 3 //range on burst aoe
	var/beam_range = 5 //range on cross blast beams
	var/chaser_speed = 3 //how fast chasers are currently
	var/chaser_cooldown = 101 //base cooldown/cooldown var between spawning chasers
	var/major_attack_cooldown = 60 //base cooldown for major attacks
	var/blinking = FALSE //if we're doing something that requires us to stand still and not attack
	var/obj/effect/hierophant/spawned_rune //the rune we teleport back to
	var/timeout_time = 15 //after this many Life() ticks with no target, we return to our rune
	var/did_reset = TRUE //if we timed out, returned to our rune, and healed some
	//var/list/kill_phrases = list("Wsyvgi sj irivkc xettih. Vitemvmrk...", "Irivkc wsyvgi jsyrh. Vitemvmrk...", "Jyip jsyrh. Egxmzexmrk vitemv gcgpiw...")
	//var/list/target_phrases = list("Xevkix psgexih.", "Iriqc jsyrh.", "Eguymvih xevkix.")
	medal_type = MEDAL_PREFIX
	score_type = BIRD_SCORE
	del_on_death = TRUE
	death_sound = 'sound/magic/Repulse.ogg'

/mob/living/simple_animal/hostile/megafauna/hierophant/New()
	..()
	internal = new/obj/item/device/gps/internal/hierophant(src)
	spawned_rune = new(loc)

/mob/living/simple_animal/hostile/megafauna/hierophant/Life()
	. = ..()
	if(. && spawned_rune && !client)
		if(target || loc == spawned_rune.loc)
			timeout_time = initial(timeout_time)
		else
			timeout_time--
		if(timeout_time <= 0 && !did_reset)
			did_reset = TRUE
			//visible_message("<span class='hierophant'>\"Vixyvrmrk xs fewi...\"</span>")
			blink(spawned_rune)
			adjustHealth(min((health - maxHealth) * 0.5, -50)) //heal for 50% of our missing health
			wander = FALSE
			/*if(health > maxHealth * 0.9)
				visible_message("<span class='hierophant'>\"Vitemvw gsqtpixi. Stivexmrk ex qebmqyq ijjmgmirgc.\"</span>")
			else
				visible_message("<span class='hierophant'>\"Vitemvw gsqtpixi. Stivexmsrep ijjmgmirgc gsqtvsqmwih.\"</span>")*/

/mob/living/simple_animal/hostile/megafauna/hierophant/death()
	if(health > 0 || stat == DEAD)
		return
	else
		stat = DEAD
		blinking = TRUE //we do a fancy animation, release a huge burst(), and leave our staff.
		animate(src, alpha = 0, color = "660099", time = 20, easing = EASE_OUT)
		addtimer(src, "update_atom_colour", 20)
		burst_range = 10
		//visible_message("<span class='hierophant'>\"Mrmxmexmrk wipj-hiwxvygx wiuyirgi...\"</span>")
		visible_message("<span class='hierophant_warning'>[src] disappears in a massive burst of magic, leaving only its staff.</span>")
		burst(get_turf(src))
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Destroy()
	qdel(spawned_rune)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/devour(mob/living/L)
	for(var/obj/item/W in L)
		if(!L.unEquip(W))
			qdel(W)
	/*visible_message(
		"<span class='hierophant'>\"[pick(kill_phrases)]\"</span>\n<span class='hierophant_warning'>[src] annihilates [L]!</span>",
		"<span class='userdanger'>You annihilate [L], restoring your health!</span>")*/
	visible_message(
		"<span class='hierophant'>\"Caw.\"</span>\n<span class='hierophant_warning'>[src] annihilates [L]!</span>",
		"<span class='userdanger'>You annihilate [L], restoring your health!</span>")
	adjustHealth(-L.maxHealth*0.5)
	L.dust()

/*/mob/living/simple_animal/hostile/megafauna/hierophant/GiveTarget(new_target)
	var/targets_the_same = (new_target == target)
	. = ..()
	if(. && target && !targets_the_same)
		visible_message("<span class='hierophant'>\"[pick(target_phrases)]\"</span>")*/

/mob/living/simple_animal/hostile/megafauna/hierophant/adjustHealth(amount)
	. = ..()
	if(src && amount > 0 && !blinking)
		wander = TRUE
		did_reset = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/AttackingTarget()
	if(!blinking)
		if(target && isliving(target))
			addtimer(src, "melee_blast", 0, TIMER_NORMAL, get_turf(target)) //melee attacks on living mobs produce a 3x3 blast
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/DestroySurroundings()
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Move()
	if(!blinking)
		/*if(!stat)
			playsound(loc, 'sound/mecha/mechmove04.ogg', 150, 1, -4)*/
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Goto(target, delay, minimum_distance)
	wander = TRUE
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/calculate_rage() //how angry we are overall
	did_reset = FALSE //oh hey we're doing SOMETHING, clearly we might need to heal if we recall
	anger_modifier = Clamp(((maxHealth - health) / 42),0,50)
	burst_range = initial(burst_range) + round(anger_modifier * 0.08)
	beam_range = initial(beam_range) + round(anger_modifier * 0.12)

/mob/living/simple_animal/hostile/megafauna/hierophant/OpenFire()
	calculate_rage()
	var/target_is_slow = FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(!blinking && L.stat == DEAD && get_dist(src, L) > 2)
			blink(L)
			return
		if(L.movement_delay() > 1.5)
			target_is_slow = TRUE
	chaser_speed = max(1, (3 - anger_modifier * 0.04) + target_is_slow * 0.5)
	if(blinking)
		return
	ranged_cooldown = world.time + max(5, ranged_cooldown_time - anger_modifier * 0.75) //scale cooldown lower with high anger.

	if(prob(anger_modifier * 0.75)) //major ranged attack
		var/list/possibilities = list()
		var/cross_counter = 1 + round(anger_modifier * 0.12)
		if(cross_counter > 1)
			possibilities += "cross_blast_spam"
		if(get_dist(src, target) > 2)
			possibilities += "blink_spam"
		if(chaser_cooldown < world.time)
			if(prob(anger_modifier * 2))
				possibilities = list("chaser_swarm")
			else
				possibilities += "chaser_swarm"
		if(possibilities.len)
			ranged_cooldown = world.time + max(5, major_attack_cooldown - anger_modifier * 0.75) //we didn't cancel out of an attack, use the higher cooldown
			var/blink_counter = 1 + round(anger_modifier * 0.08)
			switch(pick(possibilities))
				if("blink_spam") //blink either once or multiple times.
					if(health < maxHealth * 0.5 && !target_is_slow && blink_counter > 1)
						//visible_message("<span class='hierophant'>\"Mx ampp rsx iwgeti.\"</span>")
						var/oldcolor = color
						animate(src, color = "#660099", time = 6)
						while(health && target && blink_counter)
							if(loc == target.loc || loc == target) //we're on the same tile as them after about a second we can stop now
								break
							blink_counter--
							blinking = FALSE
							blink(target)
							blinking = TRUE
							sleep(5)
						animate(src, color = oldcolor, time = 8)
						addtimer(src, "update_atom_colour", 8)
						sleep(8)
						blinking = FALSE
					else
						blink(target)
				if("cross_blast_spam") //fire a lot of cross blasts at a target.
					//visible_message("<span class='hierophant'>\"Piezi mx rsalivi xs vyr.\"</span>")
					blinking = TRUE
					var/oldcolor = color
					animate(src, color = "#660099", time = 6)
					while(health && target && cross_counter)
						cross_counter--
						var/delay = 6
						if(prob(60))
							addtimer(src, "cardinal_blasts", 0, TIMER_NORMAL, target)
						else
							addtimer(src, "diagonal_blasts", 0, TIMER_NORMAL, target)
							delay = 5 //this one isn't so mean, so do the next one faster(if there is one)
						sleep(delay)
					animate(src, color = oldcolor, time = 8)
					addtimer(src, "update_atom_colour", 8)
					sleep(8)
					blinking = FALSE
				if("chaser_swarm") //fire four fucking chasers at a target and their friends.
					//visible_message("<span class='hierophant'>\"Mx gerrsx lmhi.\"</span>")
					blinking = TRUE
					var/oldcolor = color
					animate(src, color = "#660099", time = 10)
					var/list/targets = ListTargets()
					var/list/cardinal_copy = cardinal.Copy()
					while(health && targets.len && cardinal_copy.len)
						var/mob/living/pickedtarget = pick(targets)
						if(targets.len > 4)
							pickedtarget = pick_n_take(targets)
						if(pickedtarget.stat == DEAD)
							pickedtarget = target
						var/obj/effect/overlay/temp/hierophant/chaser/C = PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(loc, src, pickedtarget, chaser_speed, FALSE))
						C.moving = 3
						C.moving_dir = pick_n_take(cardinal_copy)
						sleep(10)
					chaser_cooldown = world.time + initial(chaser_cooldown)
					animate(src, color = oldcolor, time = 8)
					addtimer(src, "update_atom_colour", 8)
					sleep(8)
					blinking = FALSE
			return

	if(prob(10 + (anger_modifier * 0.5)) && get_dist(src, target) > 2)
		blink(target)

	else if(prob(70 - anger_modifier)) //a cross blast of some type
		if(prob(anger_modifier)) //at us?
			if(prob(anger_modifier * 2) && health < maxHealth * 0.5) //we're super angry do it at all dirs
				addtimer(src, "alldir_blasts", 0, TIMER_NORMAL, src)
			else if(prob(60))
				addtimer(src, "cardinal_blasts", 0, TIMER_NORMAL, src)
			else
				addtimer(src, "diagonal_blasts", 0, TIMER_NORMAL, src)
		else //at them?
			if(prob(anger_modifier * 2) && health < maxHealth * 0.5 && !target_is_slow) //we're super angry do it at all dirs
				addtimer(src, "alldir_blasts", 0, TIMER_NORMAL, target)
			else if(prob(60))
				addtimer(src, "cardinal_blasts", 0, TIMER_NORMAL, target)
			else
				addtimer(src, "diagonal_blasts", 0, TIMER_NORMAL, target)
	else if(chaser_cooldown < world.time) //if chasers are off cooldown, fire some!
		var/obj/effect/overlay/temp/hierophant/chaser/C = PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(loc, src, target, chaser_speed, FALSE))
		chaser_cooldown = world.time + initial(chaser_cooldown)
		if((prob(anger_modifier) || target.Adjacent(src)) && target != src)
			var/obj/effect/overlay/temp/hierophant/chaser/OC = PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(loc, src, target, max(1.5, 5 - anger_modifier * 0.07), FALSE))
			OC.moving = 4
			OC.moving_dir = pick(cardinal - C.moving_dir)
	else //just release a burst of power
		addtimer(src, "burst", 0, TIMER_NORMAL, get_turf(src))

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/diagonal_blasts(mob/victim) //fire diagonal cross blasts with a delay
	var/turf/T = get_turf(victim)
	if(!T)
		return
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/diagonal, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src, FALSE))
	for(var/d in diagonals)
		addtimer(src, "blast_wall", 0, TIMER_NORMAL, T, d)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/cardinal_blasts(mob/victim) //fire cardinal cross blasts with a delay
	var/turf/T = get_turf(victim)
	if(!T)
		return
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/cardinal, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src, FALSE))
	for(var/d in cardinal)
		addtimer(src, "blast_wall", 0, TIMER_NORMAL, T, d)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/alldir_blasts(mob/victim) //fire alldir cross blasts with a delay
	var/turf/T = get_turf(victim)
	if(!T)
		return
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src, FALSE))
	for(var/d in alldirs)
		addtimer(src, "blast_wall", 0, TIMER_NORMAL, T, d)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blast_wall(turf/T, dir) //make a wall of blasts beam_range tiles long
	var/range = beam_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(J, src, FALSE))
		previousturf = J
		J = get_step(previousturf, dir)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blink(mob/victim) //blink to a target
	if(blinking || !victim)
		return
	var/turf/T = get_turf(victim)
	var/turf/source = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, src))
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(source, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/magic/Wand_Teleport.ogg', 200, 1)
	playsound(source,'sound/magic/blink.ogg', 200, 1)
	//playsound(source,'sound/machines/AirlockOpen.ogg', 200, 1)
	blinking = TRUE
	sleep(2) //short delay before we start...
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(T, src))
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(source, src))
	for(var/t in RANGE_TURFS(1, T))
		var/obj/effect/overlay/temp/hierophant/blast/B = PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src, FALSE))
		B.damage = 30
	for(var/t in RANGE_TURFS(1, source))
		var/obj/effect/overlay/temp/hierophant/blast/B = PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src, FALSE))
		B.damage = 30
	animate(src, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(1)
	visible_message("<span class='hierophant_warning'>[src] fades out!</span>")
	density = FALSE
	sleep(2)
	forceMove(T)
	sleep(1)
	animate(src, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(1)
	density = TRUE
	visible_message("<span class='hierophant_warning'>[src] fades in!</span>")
	sleep(1) //at this point the blasts we made detonate
	blinking = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/melee_blast(mob/victim) //make a 3x3 blast around a target
	if(!victim)
		return
	var/turf/T = get_turf(victim)
	if(!T)
		return
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	//playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	for(var/t in RANGE_TURFS(1, T))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src, FALSE))

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/burst(turf/original) //release a wave of blasts
	playsound(original,'sound/magic/blink.ogg', 200, 1)
	//playsound(original,'sound/machines/AirlockOpen.ogg', 200, 1)
	var/last_dist = 0
	for(var/t in spiral_range_turfs(burst_range, original))
		var/turf/T = t
		if(!T)
			continue
		var/dist = get_dist(original, T)
		if(dist > last_dist)
			last_dist = dist
			sleep(1 + (burst_range - last_dist) * 0.5) //gets faster as it gets further out
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src, FALSE))

/mob/living/simple_animal/hostile/megafauna/hierophant/AltClickOn(atom/A) //player control handler(don't give this to a player holy fuck)
	if(!istype(A) || get_dist(A, src) <= 2)
		return
	blink(A)

//Hierophant overlays
/obj/effect/overlay/temp/hierophant
	layer = BELOW_MOB_LAYER
	var/mob/living/caster //who made this, anyway

/obj/effect/overlay/temp/hierophant/New(loc, new_caster)
	..()
	if(new_caster)
		caster = new_caster

/obj/effect/overlay/temp/hierophant/chaser //a hierophant's chaser. follows target around, moving and producing a blast every speed deciseconds.
	duration = 98
	var/mob/living/target //what it's following
	var/turf/targetturf //what turf the target is actually on
	var/moving_dir //what dir it's moving in
	var/previous_moving_dir //what dir it was moving in before that
	var/more_previouser_moving_dir //what dir it was moving in before THAT
	var/moving = 0 //how many steps to move before recalculating
	var/standard_moving_before_recalc = 4 //how many times we step before recalculating normally
	var/tiles_per_step = 1 //how many tiles we move each step
	var/speed = 3 //how many deciseconds between each step
	var/currently_seeking = FALSE
	var/friendly_fire_check = FALSE //if blasts produced apply friendly fire

/obj/effect/overlay/temp/hierophant/chaser/New(loc, new_caster, new_target, new_speed, is_friendly_fire)
	..()
	target = new_target
	friendly_fire_check = is_friendly_fire
	if(new_speed)
		speed = new_speed
	addtimer(src, "seek_target", 1)

/obj/effect/overlay/temp/hierophant/chaser/proc/get_target_dir()
	. = get_cardinal_dir(src, targetturf)
	if((. != previous_moving_dir && . == more_previouser_moving_dir) || . == 0) //we're alternating, recalculate
		var/list/cardinal_copy = cardinal.Copy()
		cardinal_copy -= more_previouser_moving_dir
		. = pick(cardinal_copy)

/obj/effect/overlay/temp/hierophant/chaser/proc/seek_target()
	if(!currently_seeking)
		currently_seeking = TRUE
		targetturf = get_turf(target)
		while(target && src && !qdeleted(src) && currently_seeking && x && y && targetturf) //can this target actually be sook out
			if(!moving) //we're out of tiles to move, find more and where the target is!
				more_previouser_moving_dir = previous_moving_dir
				previous_moving_dir = moving_dir
				moving_dir = get_target_dir()
				var/standard_target_dir = get_cardinal_dir(src, targetturf)
				if((standard_target_dir != previous_moving_dir && standard_target_dir == more_previouser_moving_dir) || standard_target_dir == 0)
					moving = 1 //we would be repeating, only move a tile before checking
				else
					moving = standard_moving_before_recalc
			if(moving) //move in the dir we're moving in right now
				var/turf/T = get_turf(src)
				for(var/i in 1 to tiles_per_step)
					var/maybe_new_turf = get_step(T, moving_dir)
					if(maybe_new_turf)
						T = maybe_new_turf
					else
						break
				forceMove(T)
				make_blast() //make a blast, too
				moving--
				sleep(speed)
			targetturf = get_turf(target)

/obj/effect/overlay/temp/hierophant/chaser/proc/make_blast()
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(loc, caster, friendly_fire_check))

/obj/effect/overlay/temp/hierophant/telegraph
	icon = 'icons/effects/96x96.dmi'
	icon_state = "hierophant_telegraph"
	pixel_x = -32
	pixel_y = -32
	duration = 3

/obj/effect/overlay/temp/hierophant/telegraph/diagonal
	icon_state = "hierophant_telegraph_diagonal"

/obj/effect/overlay/temp/hierophant/telegraph/cardinal
	icon_state = "hierophant_telegraph_cardinal"

/obj/effect/overlay/temp/hierophant/telegraph/teleport
	icon_state = "hierophant_telegraph_teleport"
	duration = 9

/obj/effect/overlay/temp/hierophant/blast
	icon_state = "hierophant_blast"
	name = "vortex blast"
	luminosity = 1
	desc = "Get out of the way!"
	duration = 9
	var/damage = 10 //how much damage do we do?
	var/list/hit_things = list() //we hit these already, ignore them
	var/friendly_fire_check = FALSE
	var/bursting = FALSE //if we're bursting and need to hit anyone crossing us

/obj/effect/overlay/temp/hierophant/blast/New(loc, new_caster, friendly_fire)
	..()
	friendly_fire_check = friendly_fire
	if(new_caster)
		hit_things += new_caster
	if(ismineralturf(loc)) //drill mineral turfs
		var/turf/closed/mineral/M = loc
		M.gets_drilled(caster)
	addtimer(src, "blast", 0)

/obj/effect/overlay/temp/hierophant/blast/proc/blast()
	var/turf/T = get_turf(src)
	if(!T)
		return
	playsound(T,'sound/magic/Blind.ogg', 125, 1, -5) //make a sound
	sleep(6) //wait a little
	bursting = TRUE
	do_damage(T) //do damage and mark us as bursting
	sleep(1.3) //slightly forgiving; the burst animation is 1.5 deciseconds
	bursting = FALSE //we no longer damage crossers

/obj/effect/overlay/temp/hierophant/blast/Crossed(atom/movable/AM)
	..()
	if(bursting)
		do_damage(get_turf(src))

/obj/effect/overlay/temp/hierophant/blast/proc/do_damage(turf/T)
	for(var/mob/living/L in T.contents - hit_things) //find and damage mobs...
		hit_things += L
		if((friendly_fire_check && caster && caster.faction_check(L)) || L.stat == DEAD)
			continue
		if(L.client)
			flash_color(L.client, "#660099", 1)
		playsound(L,'sound/weapons/sear.ogg', 50, 1, -4)
		L << "<span class='userdanger'>You're struck by a [name]!</span>"
		var/limb_to_hit = L.get_bodypart(pick("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg"))
		var/armor = L.run_armor_check(limb_to_hit, "melee", "Your armor absorbs [src]!", "Your armor blocks part of [src]!", 50, "Your armor was penetrated by [src]!")
		L.apply_damage(damage, BURN, limb_to_hit, armor)
		if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
			L.adjustBruteLoss(damage)
		add_logs(caster, L, "struck with a [name]")
	for(var/obj/mecha/M in T.contents - hit_things) //and mechs.
		hit_things += M
		if(M.occupant)
			if(friendly_fire_check && caster && caster.faction_check(M.occupant))
				continue
			M.occupant << "<span class='userdanger'>Your [M.name] is struck by a [name]!</span>"
		playsound(M,'sound/weapons/sear.ogg', 50, 1, -4)
		M.take_damage(damage, BURN, 0, 0)

/obj/effect/hierophant
	name = "hierophant rune"
	desc = "A powerful magic mark allowing whomever attunes themself to it to return to it at will."
	icon = 'icons/obj/rune.dmi'
	icon_state = "hierophant"
	layer = LOW_OBJ_LAYER
	anchored = TRUE
	color = "#CC00FF"

/obj/effect/hierophant/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/hierophant_staff))
		var/obj/item/weapon/hierophant_staff/H = I
		if(H.rune == src)
			user << "<span class='notice'>You start removing your hierophant rune...</span>"
			H.timer = world.time + 51
			if(do_after(user, 50, target = src))
				playsound(src,'sound/magic/Blind.ogg', 200, 1, -4)
				PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(get_turf(src), user))
				user << "<span class='hierophant_warning'>You touch the rune with the staff, dispelling it!</span>"
				H.rune = null
				user.update_action_buttons_icon()
				qdel(src)
			else
				H.timer = world.time
		else
			user << "<span class='hierophant_warning'>You touch the rune with the staff, but nothing happens.</span>"

	else
		..()

/obj/item/device/gps/internal/hierophant
	icon_state = null
	gpstag = "Zealous Signal"
	desc = "Heed its words."
	invisibility = 100

/turf/open/indestructible/hierophant
	icon_state = "hierophant1"
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	desc = "A floor with a square pattern. It's faintly cool to the touch."

/turf/open/indestructible/hierophant/New()
	..()
	if(prob(50))
		icon_state = "hierophant2"

/turf/closed/indestructible/riveted/hierophant
	name = "wall"
	desc = "A wall made out of smooth, cold stone."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	icon_state = "hierophant"
	smooth = SMOOTH_TRUE

#undef MEDAL_PREFIX