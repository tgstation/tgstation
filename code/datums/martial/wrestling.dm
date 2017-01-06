/datum/martial_art/wrestling
	name = "Wrestling"
	var/datum/action/slam/slam = new/datum/action/slam()
	var/datum/action/throw_wrassle/throw_wrassle = new/datum/action/throw_wrassle()
	var/datum/action/kick/kick = new/datum/action/kick()
	var/datum/action/strike/strike = new/datum/action/strike()
	var/datum/action/drop/drop = new/datum/action/drop()

/datum/martial_art/wrestling/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	switch(streak)
		if("drop")
			streak = ""
			drop(A,D)
			return 1
		if("strike")
			streak = ""
			strike(A,D)
			return 1
		if("kick")
			streak = ""
			kick(A,D)
			return 1
		if("throw")
			streak = ""
			throw_wrassle(A,D)
			return 1
		if("slam")
			streak = ""
			slam(A,D)
			return 1
	return 0

/datum/action/slam
	name = "Slam (Cinch) - Slam a grappled opponent into the floor."
	button_icon_state = "wrassle_slam"

/datum/action/slam/Trigger()
	if(owner.incapacitated())
		owner << "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>"
		return
	owner.visible_message("<span class='danger'>[owner] prepares to BODY SLAM!</span>", "<b><i>Your next attack will be a BODY SLAM.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.martial_art.streak = "slam"

/datum/action/throw_wrassle
	name = "Throw (Cinch) - Spin a cinched opponent around and throw them."
	button_icon_state = "wrassle_throw"

/datum/action/throw_wrassle/Trigger()
	if(owner.incapacitated())
		owner << "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>"
		return
	owner.visible_message("<span class='danger'>[owner] prepares to THROW!</span>", "<b><i>Your next attack will be a THROW.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.martial_art.streak = "throw"

/datum/action/kick
	name = "Kick - A powerful kick, sends people flying away from you. Also useful for escaping from bad situations."
	button_icon_state = "wrassle_kick"

/datum/action/kick/Trigger()
	if(owner.incapacitated())
		owner << "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>"
		return
	owner.visible_message("<span class='danger'>[owner] prepares to KICK!</span>", "<b><i>Your next attack will be a KICK.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.martial_art.streak = "kick"

/datum/action/strike
	name = "Strike - Hit a neaby opponent with a quick attack."
	button_icon_state = "wrassle_strike"

/datum/action/strike/Trigger()
	if(owner.incapacitated())
		owner << "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>"
		return
	owner.visible_message("<span class='danger'>[owner] prepares to STRIKE!</span>", "<b><i>Your next attack will be a STRIKE.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.martial_art.streak = "strike"

/datum/action/drop
	name = "Drop - Smash down onto an opponent."
	button_icon_state = "wrassle_drop"

/datum/action/drop/Trigger()
	if(owner.incapacitated())
		owner << "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>"
		return
	owner.visible_message("<span class='danger'>[owner] prepares to LEG DROP!</span>", "<b><i>Your next attack will be a LEG DROP.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.martial_art.streak = "drop"

/datum/martial_art/wrestling/teach(var/mob/living/carbon/human/H,var/make_temporary=0)
	..()
	H << "<span class = 'userdanger'>SNAP INTO A THIN TIM!</span>"
	H << "<span class = 'danger'>Place your cursor over a move at the top of the screen to see what it does.</span>"
	drop.Grant(H)
	kick.Grant(H)
	slam.Grant(H)
	throw_wrassle.Grant(H)
	strike.Grant(H)

/datum/martial_art/wrestling/remove(var/mob/living/carbon/human/H)
	..()
	H << "<span class = 'userdanger'>You no longer feel that the tower of power is too sweet to be sour...</span>"
	drop.Remove(H)
	kick.Remove(H)
	slam.Remove(H)
	throw_wrassle.Remove(H)
	strike.Remove(H)

/datum/martial_art/wrestling/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	add_logs(A, D, "punched with wrestling")
	..()

/datum/martial_art/wrestling/proc/throw_wrassle(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	if(!A.pulling || A.pulling != D)
		A << "You need to have [D] in a cinch!"
		return
	D.forceMove(A.loc)
	D.setDir(get_dir(D, A))

	D.Stun(4)
	A.visible_message("<span class = 'danger'><B>[A] starts spinning around with [D]!</B></span>")
	A.emote("scream")

	for (var/i = 0, i < 20, i++)
		var/delay = 5
		switch (i)
			if (17 to INFINITY)
				delay = 0.25
			if (14 to 16)
				delay = 0.5
			if (9 to 13)
				delay = 1
			if (5 to 8)
				delay = 2
			if (0 to 4)
				delay = 3

		if (A && D)

			if (get_dist(A, D) > 1)
				A << "[D] is too far away!"
				return 0

			if (!isturf(A.loc) || !isturf(D.loc))
				A << "You can't throw [D] from here!"
				return 0

			A.setDir(turn(A.dir, 90))
			var/turf/T = get_step(A, A.dir)
			var/turf/S = D.loc
			if ((S && isturf(S) && S.Exit(D)) && (T && isturf(T) && T.Enter(A)))
				D.forceMove(T)
				D.setDir(get_dir(D, A))
		else
			return 0

		sleep(delay)

	if (A && D)
		// These are necessary because of the sleep call.

		if (get_dist(A, D) > 1)
			A << "[D] is too far away!"
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			A << "You can't throw [D] from here!"
			return 0

		D.forceMove(A.loc) // Maybe this will help with the wallthrowing bug.

		A.visible_message("<span class = 'danger'><B>[A] throws [D]!</B></span>")
		playsound(A.loc, "swing_hit", 50, 1)
		var/turf/T = get_edge_target_turf(A, A.dir)
		if (T && isturf(T))
			if (!D.stat)
				D.emote("scream")
			D.throw_at(T, 10, 4, callback = CALLBACK(D, /mob/living/carbon/human/.Weaken, 2))
	add_logs(A, D, "has thrown with wrestling")
	return 0

/datum/martial_art/wrestling/proc/slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	if(!A.pulling || A.pulling != D)
		A << "You need to have [D] in a cinch!"
		return
	D.forceMove(A.loc)
	A.setDir(get_dir(A, D))
	D.setDir(get_dir(D, A))

	A.visible_message("<span class = 'danger'><B>[A] lifts [D] up!</B></span>")

	spawn (0)
		if (D)
			animate(D, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
		sleep (15)
		if (D)
			animate(D, transform = null, time = 1, loop = 0)

	for (var/i = 0, i < 3, i++)
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
				A << "[D] is too far away!"
				A.pixel_x = 0
				A.pixel_y = 0
				D.pixel_x = 0
				D.pixel_y = 0
				return 0

			if (!isturf(A.loc) || !isturf(D.loc))
				A << "You can't slam [D] here!"
				A.pixel_x = 0
				A.pixel_y = 0
				D.pixel_x = 0
				D.pixel_y = 0
				return 0
		else
			if (A)
				A.pixel_x = 0
				A.pixel_y = 0
			if (D)
				D.pixel_x = 0
				D.pixel_y = 0
			return 0

		sleep (1)

	if (A && D)
		A.pixel_x = 0
		A.pixel_y = 0
		D.pixel_x = 0
		D.pixel_y = 0

		if (get_dist(A, D) > 1)
			A << "[D] is too far away!"
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			A << "You can't slam [D] here!"
			return 0

		D.forceMove(A.loc)

		var/fluff = "body-slam"
		switch(pick(2,3))
			if (2)
				fluff = "turbo [fluff]"
			if (3)
				fluff = "atomic [fluff]"

		A.visible_message("<span class = 'danger'><B>[A] [fluff] [D]!</B></span>")
		playsound(A.loc, "swing_hit", 50, 1)
		if (!D.stat)
			D.emote("scream")
			D.weakened += 2
			D.stunned += 2

			switch(rand(1,3))
				if (2)
					D.adjustBruteLoss(rand(20,30))
				if (3)
					D.ex_act(3)
				else
					D.adjustBruteLoss(rand(10,20))
		else
			D.ex_act(3)

	else
		if (A)
			A.pixel_x = 0
			A.pixel_y = 0
		if (D)
			D.pixel_x = 0
			D.pixel_y = 0


	add_logs(A, D, "body-slammed")
	return 0

/datum/martial_art/wrestling/proc/strike(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	var/turf/T = get_turf(A)
	if (T && isturf(T) && D && isturf(D.loc))
		for (var/i = 0, i < 4, i++)
			A.setDir(turn(A.dir, 90))

		A.forceMove(D.loc)
		spawn (4)
			if (A && (T && isturf(T) && get_dist(A, T) <= 1))
				A.forceMove(T)

		A.visible_message("<span class = 'danger'><b>[A] headbutts [D]!</b></span>")
		D.adjustBruteLoss(rand(10,20))
		playsound(A.loc, "swing_hit", 50, 1)
		D.Paralyse(1)
	add_logs(A, D, "headbutted")

/datum/martial_art/wrestling/proc/kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	A.emote("scream")
	A.emote("flip")
	A.setDir(turn(A.dir, 90))

	A.visible_message("<span class = 'danger'><B>[A] roundhouse-kicks [D]!</B></span>")
	playsound(A.loc, "swing_hit", 50, 1)
	D.adjustBruteLoss(rand(10,20))

	var/turf/T = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
	if (T && isturf(T))
		D.Weaken(1)
		D.throw_at(T, 3, 2)
	add_logs(A, D, "roundhouse-kicked")

/datum/martial_art/wrestling/proc/drop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	var/obj/surface = null
	var/turf/ST = null
	var/falling = 0

	for (var/obj/O in oview(1, A))
		if (O.density == 1)
			if (O == A) continue
			if (O == D) continue
			if (O.opacity) continue
			else
				surface = O
				ST = get_turf(O)
				break

	if (surface && (ST && isturf(ST)))
		A.forceMove(ST)
		A.visible_message("<span class = 'danger'><B>[A] climbs onto [surface]!</b></span>")
		A.pixel_y = 10
		falling = 1
		sleep(10)

	if (A && D)
		// These are necessary because of the sleep call.

		if ((falling == 0 && get_dist(A, D) > 1) || (falling == 1 && get_dist(A, D) > 2)) // We climbed onto stuff.
			A.pixel_y = 0
			if (falling == 1)
				A.visible_message("<span class = 'danger'><B>...and dives head-first into the ground, ouch!</b></span>")
				A.adjustBruteLoss(rand(10,20))
				A.Weaken(3)
			A << "[D] is too far away!"
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			A.pixel_y = 0
			A << "You can't drop onto [D] from here!"
			return 0

		if(A)
			animate(A, transform = matrix(90, MATRIX_ROTATE), time = 1, loop = 0)
		sleep(10)
		if(A)
			animate(A, transform = null, time = 1, loop = 0)

		A.forceMove(D.loc)

		A.visible_message("<span class = 'danger'><B>[A] leg-drops [D]!</B></span>")
		playsound(A.loc, "swing_hit", 50, 1)
		A.emote("scream")

		if (falling == 1)
			if (prob(33) || D.stat)
				D.ex_act(3)
			else
				D.adjustBruteLoss(rand(20,30))
		else
			D.adjustBruteLoss(rand(20,30))

		D.Weaken(1)
		D.Stun(2)

		A.pixel_y = 0

	else
		if (A)
			A.pixel_y = 0
	add_logs(A, D, "leg-dropped")
	return

/datum/martial_art/wrestling/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	add_logs(A, D, "wrestling-disarmed")
	..()

/datum/martial_art/wrestling/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	if(A.pulling == D)
		return 1
	A.start_pulling(D)
	D.visible_message("<span class='danger'>[A] gets [D] in a cinch!</span>", \
								"<span class='userdanger'>[A] gets [D] in a cinch!</span>")
	D.Stun(rand(3,5))
	add_logs(A, D, "cinched")
	return 1
