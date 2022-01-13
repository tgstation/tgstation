/*
The contents of this file were originally licensed under CC-BY-NC-SA 3.0 as part of Goonstation(https://ss13.co).
However, /tg/station and derivative codebases have been granted the right to use this code under the terms of the AGPL.
The original authors are: cogwerks, pistoleer, spyguy, angriestibm, marquesas, and stuntwaffle.
If you make a derivative work from this code, you must include this notification header alongside it.
*/

/mob/living/proc/wrestling_help()
	set name = "Recall Teachings"
	set desc = "Remember how to wrestle."
	set category = "Wrestling"

	to_chat(usr, "<b><i>You flex your muscles and have a revelation...</i></b>")
	to_chat(usr, "[span_notice("Clinch")]: Grab. Passively gives you a chance to immediately aggressively grab someone. Not always successful.")
	to_chat(usr, "[span_notice("Suplex")]: Shove someone you are grabbing. Suplexes your target to the floor. Greatly injures them and leaves both you and your target on the floor.")
	to_chat(usr, "[span_notice("Advanced grab")]: Grab. Passively causes stamina damage when grabbing someone.")

/datum/martial_art/wrestling
	name = "Wrestling"
	id = MARTIALART_WRESTLING
	var/datum/action/slam/slam = new/datum/action/slam()
	var/datum/action/throw_wrassle/throw_wrassle = new/datum/action/throw_wrassle()
	var/datum/action/kick/kick = new/datum/action/kick()
	var/datum/action/strike/strike = new/datum/action/strike()
	var/datum/action/drop/drop = new/datum/action/drop()

/datum/martial_art/wrestling/proc/check_streak(mob/living/A, mob/living/D)
	switch(streak)
		if("drop")
			streak = ""
			drop(A,D)
			return TRUE
		if("strike")
			streak = ""
			strike(A,D)
			return TRUE
		if("kick")
			streak = ""
			kick(A,D)
			return TRUE
		if("throw")
			streak = ""
			throw_wrassle(A,D)
			return TRUE
		if("slam")
			streak = ""
			slam(A,D)
			return TRUE
	return FALSE

/datum/action/slam
	name = "Slam (Cinch) - Slam a grappled opponent into the floor."
	button_icon_state = "wrassle_slam"

/datum/action/slam/Trigger()
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't WRESTLE while you're OUT FOR THE COUNT."))
		return
	owner.visible_message(span_danger("[owner] prepares to BODY SLAM!"), "<b><i>Your next attack will be a BODY SLAM.</i></b>")
	owner.mind.martial_art.streak = "slam"

/datum/action/throw_wrassle
	name = "Throw (Cinch) - Spin a cinched opponent around and throw them."
	button_icon_state = "wrassle_throw"

/datum/action/throw_wrassle/Trigger()
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't WRESTLE while you're OUT FOR THE COUNT."))
		return
	owner.visible_message(span_danger("[owner] prepares to THROW!"), "<b><i>Your next attack will be a THROW.</i></b>")
	owner.mind.martial_art.streak = "throw"

/datum/action/kick
	name = "Kick - A powerful kick, sends people flying away from you. Also useful for escaping from bad situations."
	button_icon_state = "wrassle_kick"

/datum/action/kick/Trigger()
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't WRESTLE while you're OUT FOR THE COUNT."))
		return
	owner.visible_message(span_danger("[owner] prepares to KICK!"), "<b><i>Your next attack will be a KICK.</i></b>")
	owner.mind.martial_art.streak = "kick"

/datum/action/strike
	name = "Strike - Hit a neaby opponent with a quick attack."
	button_icon_state = "wrassle_strike"

/datum/action/strike/Trigger()
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't WRESTLE while you're OUT FOR THE COUNT."))
		return
	owner.visible_message(span_danger("[owner] prepares to STRIKE!"), "<b><i>Your next attack will be a STRIKE.</i></b>")
	owner.mind.martial_art.streak = "strike"

/datum/action/drop
	name = "Drop - Smash down onto an opponent."
	button_icon_state = "wrassle_drop"

/datum/action/drop/Trigger()
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't WRESTLE while you're OUT FOR THE COUNT."))
		return
	owner.visible_message(span_danger("[owner] prepares to LEG DROP!"), "<b><i>Your next attack will be a LEG DROP.</i></b>")
	owner.mind.martial_art.streak = "drop"

/datum/martial_art/wrestling/teach(mob/living/owner, make_temporary=FALSE)
	if(..())
		to_chat(owner, span_userdanger("SNAP INTO A THIN TIM!"))
		to_chat(owner, span_danger("Place your cursor over a move at the top of the screen to see what it does."))
		drop.Grant(owner)
		kick.Grant(owner)
		slam.Grant(owner)
		throw_wrassle.Grant(owner)
		strike.Grant(owner)

/datum/martial_art/wrestling/on_remove(mob/living/owner)
	to_chat(owner, span_userdanger("You no longer feel that the tower of power is too sweet to be sour..."))
	drop.Remove(owner)
	kick.Remove(owner)
	slam.Remove(owner)
	throw_wrassle.Remove(owner)
	strike.Remove(owner)

/datum/martial_art/wrestling/harm_act(mob/living/A, mob/living/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "punched with wrestling")
	..()

/datum/martial_art/wrestling/proc/throw_wrassle(mob/living/A, mob/living/D)
	if(!D)
		return
	if(!A.pulling || A.pulling != D)
		to_chat(A, span_warning("You need to have [D] in a cinch!"))
		return
	D.forceMove(A.loc)
	D.setDir(get_dir(D, A))

	D.Stun(80)
	D.visible_message(span_danger("[A] starts spinning around with [D]!"), \
					span_userdanger("You're spun around by [A]!"), span_hear("You hear aggressive shuffling!"), null, A)
	to_chat(A, span_danger("You start spinning around with [D]!"))
	A.emote("scream")

	for (var/i in 1 to 20)
		var/delay = 5
		switch (i)
			if (18 to INFINITY)
				delay = 0.25
			if (15 to 17)
				delay = 0.5
			if (10 to 14)
				delay = 1
			if (6 to 9)
				delay = 2
			if (1 to 5)
				delay = 3

		if (A && D)

			if (get_dist(A, D) > 1)
				to_chat(A, span_warning("[D] is too far away!"))
				return

			if (!isturf(A.loc) || !isturf(D.loc))
				to_chat(A, span_warning("You can't throw [D] from here!"))
				return

			A.setDir(turn(A.dir, 90))
			var/turf/T = get_step(A, A.dir)
			var/turf/S = D.loc
			var/direction = get_dir(D, A)
			if ((S && isturf(S) && S.Exit(D, direction)) && (T && isturf(T) && T.Enter(A)))
				D.forceMove(T)
				D.setDir(direction)
		else
			return

		sleep(delay)

	if (A && D)
		// These are necessary because of the sleep call.

		if (get_dist(A, D) > 1)
			to_chat(A, span_warning("[D] is too far away!"))
			return

		if (!isturf(A.loc) || !isturf(D.loc))
			to_chat(A, span_warning("You can't throw [D] from here!"))
			return

		D.forceMove(A.loc) // Maybe this will help with the wallthrowing bug.

		D.visible_message(span_danger("[A] throws [D]!"), \
						span_userdanger("You're thrown by [A]!"), span_hear("You hear aggressive shuffling and a loud thud!"), null, A)
		to_chat(A, span_danger("You throw [D]!"))
		playsound(A.loc, "swing_hit", 50, TRUE)
		var/turf/T = get_edge_target_turf(A, A.dir)
		if (T && isturf(T))
			if (!D.stat)
				D.emote("scream")
			D.throw_at(T, 10, 4, A, TRUE, TRUE, callback = CALLBACK(D, /mob/living.proc/Paralyze, 20))
	log_combat(A, D, "has thrown with wrestling")
	return

/datum/martial_art/wrestling/proc/FlipAnimation(mob/living/D)
	set waitfor = FALSE
	if (D)
		animate(D, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
	sleep(15)
	if (D)
		animate(D, transform = null, time = 1, loop = 0)

/datum/martial_art/wrestling/proc/slam(mob/living/A, mob/living/D)
	if(!D)
		return
	if(!A.pulling || A.pulling != D)
		to_chat(A, span_warning("You need to have [D] in a cinch!"))
		return
	D.forceMove(A.loc)
	A.setDir(get_dir(A, D))
	D.setDir(get_dir(D, A))

	D.visible_message(span_danger("[A] lifts [D] up!"), \
					span_userdanger("You're lifted up by [A]!"), span_hear("You hear aggressive shuffling!"), null, A)
	to_chat(A, span_danger("You lift [D] up!"))

	FlipAnimation()

	for (var/i in 1 to 3)
		if (A && D)
			A.pixel_y += 3
			D.pixel_y += 3
			A.setDir(turn(A.dir, 90))
			D.setDir(turn(D.dir, 90))

			switch (A.dir)
				if (NORTH)
					D.pixel_x = A.pixel_x
				if (SOUTH)
					D.pixel_x = A.pixel_x
				if (EAST)
					D.pixel_x = A.pixel_x - 8
				if (WEST)
					D.pixel_x = A.pixel_x + 8

			if (get_dist(A, D) > 1)
				to_chat(A, span_warning("[D] is too far away!"))
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
				return

			if (!isturf(A.loc) || !isturf(D.loc))
				to_chat(A, span_warning("You can't slam [D] here!"))
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
				return
		else
			if (A)
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
			if (D)
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
			return

		sleep(1)

	if (A && D)
		A.pixel_x = A.base_pixel_x
		A.pixel_y = A.base_pixel_y
		D.pixel_x = D.base_pixel_x
		D.pixel_y = D.base_pixel_y

		if (get_dist(A, D) > 1)
			to_chat(A, span_warning("[D] is too far away!"))
			return

		if (!isturf(A.loc) || !isturf(D.loc))
			to_chat(A, span_warning("You can't slam [D] here!"))
			return

		D.forceMove(A.loc)

		var/fluff = "body-slam"
		switch(pick(2,3))
			if (2)
				fluff = "turbo [fluff]"
			if (3)
				fluff = "atomic [fluff]"

		D.visible_message(span_danger("[A] [fluff] [D]!"), \
						span_userdanger("You're [fluff]ed by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
		to_chat(A, span_danger("You [fluff] [D]!"))
		playsound(A.loc, "swing_hit", 50, TRUE)
		if (!D.stat)
			D.emote("scream")
			D.Paralyze(40)

			switch(rand(1,3))
				if (2)
					D.adjustBruteLoss(rand(20,30))
				if (3)
					EX_ACT(D, EXPLODE_LIGHT)
				else
					D.adjustBruteLoss(rand(10,20))
		else
			EX_ACT(D, EXPLODE_LIGHT)

	else
		if (A)
			A.pixel_x = A.base_pixel_x
			A.pixel_y = A.base_pixel_y
		if (D)
			D.pixel_x = D.base_pixel_x
			D.pixel_y = D.base_pixel_y


	log_combat(A, D, "body-slammed")
	return

/datum/martial_art/wrestling/proc/CheckStrikeTurf(mob/living/A, turf/T)
	if (A && (T && isturf(T) && get_dist(A, T) <= 1))
		A.forceMove(T)

/datum/martial_art/wrestling/proc/strike(mob/living/A, mob/living/D)
	if(!D)
		return
	var/turf/T = get_turf(A)
	if (T && isturf(T) && D && isturf(D.loc))
		for (var/i in 1 to 4)
			A.setDir(turn(A.dir, 90))

		A.forceMove(D.loc)
		addtimer(CALLBACK(src, .proc/CheckStrikeTurf, A, T), 4)

		D.visible_message(span_danger("[A] headbutts [D]!"), \
						span_userdanger("You're headbutted by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
		to_chat(A, span_danger("You headbutt [D]!"))
		D.adjustBruteLoss(rand(10,20))
		playsound(A.loc, "swing_hit", 50, TRUE)
		D.Unconscious(20)
	log_combat(A, D, "headbutted")

/datum/martial_art/wrestling/proc/kick(mob/living/A, mob/living/D)
	if(!D)
		return
	A.emote("scream")
	A.emote("flip")
	A.setDir(turn(A.dir, 90))

	D.visible_message(span_danger("[A] roundhouse-kicks [D]!"), \
					span_userdanger("You're roundhouse-kicked by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
	to_chat(A, span_danger("You roundhouse-kick [D]!"))
	playsound(A.loc, "swing_hit", 50, TRUE)
	D.adjustBruteLoss(rand(10,20))

	var/turf/T = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
	if (T && isturf(T))
		D.Paralyze(20)
		D.throw_at(T, 3, 2)
	log_combat(A, D, "roundhouse-kicked")

/datum/martial_art/wrestling/proc/drop(mob/living/A, mob/living/D)
	if(!D)
		return
	var/obj/surface = null
	var/turf/ST = null
	var/falling = 0

	for (var/obj/O in oview(1, A))
		if (O.density == 1)
			if (O == A)
				continue
			if (O == D)
				continue
			if (O.opacity)
				continue
			else
				surface = O
				ST = get_turf(O)
				break

	if (surface && (ST && isturf(ST)))
		A.forceMove(ST)
		A.visible_message(span_danger("[A] climbs onto [surface]!"), \
						span_danger("You climb onto [surface]!"))
		A.pixel_y = A.base_pixel_y + 10
		falling = 1
		sleep(10)

	if (A && D)
		// These are necessary because of the sleep call.

		if ((falling == 0 && get_dist(A, D) > 1) || (falling == 1 && get_dist(A, D) > 2)) // We climbed onto stuff.
			A.pixel_y = A.base_pixel_y
			if (falling == 1)
				A.visible_message(span_danger("...and dives head-first into the ground, ouch!"), \
								span_userdanger("...and dive head-first into the ground, ouch!"))
				A.adjustBruteLoss(rand(10,20))
				A.Paralyze(60)
			to_chat(A, span_warning("[D] is too far away!"))
			return

		if (!isturf(A.loc) || !isturf(D.loc))
			A.pixel_y = A.base_pixel_y
			to_chat(A, span_warning("You can't drop onto [D] from here!"))
			return

		if(A)
			animate(A, transform = matrix(90, MATRIX_ROTATE), time = 1, loop = 0)
		sleep(10)
		if(A)
			animate(A, transform = null, time = 1, loop = 0)

		A.forceMove(D.loc)

		D.visible_message(span_danger("[A] leg-drops [D]!"), \
						span_userdanger("You're leg-dropped by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
		to_chat(A, span_danger("You leg-drop [D]!"))
		playsound(A.loc, "swing_hit", 50, TRUE)
		A.emote("scream")

		if (falling == 1)
			if (prob(33) || D.stat)
				EX_ACT(D, EXPLODE_LIGHT)
			else
				D.adjustBruteLoss(rand(20,30))
		else
			D.adjustBruteLoss(rand(20,30))

		D.Paralyze(40)

		A.pixel_y = A.base_pixel_y

	else
		if (A)
			A.pixel_y = A.base_pixel_y
	log_combat(A, D, "leg-dropped")
	return

/datum/martial_art/wrestling/disarm_act(mob/living/A, mob/living/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "wrestling-disarmed")
	..()

/datum/martial_art/wrestling/grab_act(mob/living/A, mob/living/D)
	if(check_streak(A,D))
		return 1
	if(A.pulling == D)
		return 1
	A.start_pulling(D)
	D.visible_message(span_danger("[A] gets [D] in a cinch!"), \
					span_userdanger("You're put into a cinch by [A]!"), span_hear("You hear aggressive shuffling!"), COMBAT_MESSAGE_RANGE, A)
	to_chat(A, span_danger("You get [D] in a cinch!"))
	D.Stun(rand(60,100))
	log_combat(A, D, "cinched")
	return 1

/obj/item/storage/belt/champion/wrestling
	name = "Wrestling Belt"
	var/datum/martial_art/wrestling/style = new

/obj/item/storage/belt/champion/wrestling/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_BELT)
		style.teach(user, TRUE)
	return

/obj/item/storage/belt/champion/wrestling/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.remove(user)
	return
