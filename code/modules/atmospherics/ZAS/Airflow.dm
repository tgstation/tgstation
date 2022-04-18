/*
Contains helper procs for airflow, handled in /connection_group.
*/

/mob/var/tmp/last_airflow_stun = 0
/mob/proc/airflow_stun()
	return
/mob/living/airflow_stun()
	if(stat == 2)
		return 0
	if(last_airflow_stun > world.time - SSzas.settings.airflow_stun_cooldown)	return 0

	if(!(status_flags & CANSTUN) && !(status_flags & CANKNOCKDOWN))
		to_chat(src, "<span class='notice'>You stay upright as the air rushes past you.</span>")
		return 0
	if(buckled)
		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
		return 0
	if(!body_position == LYING_DOWN)
		to_chat(src, "<span class='warning'>The sudden rush of air knocks you over!</span>")

	slip(5, null, GALOSHES_DONT_HELP|SLIDE, 0, TRUE)
	last_airflow_stun = world.time

/mob/living/silicon/airflow_stun()
	return

/mob/living/carbon/slime/airflow_stun()
	return

/mob/living/carbon/human/airflow_stun()
	if(!slip_chance())
		to_chat(src, "<span class='notice'>Air suddenly rushes past you!</span>")
		return 0
	..()

/atom/movable/proc/experience_pressure_difference()
	return

/mob/proc/slip_chance()
	return

/mob/living/carbon/human/slip_chance(prob_slip = 10)
	if(stat)
		return FALSE
	if(buckled)
		return FALSE
	if(shoes)
		var/obj/item/clothing/myshoes = shoes
		if(myshoes.clothing_flags & NOSLIP|NOSLIP_ICE)
			return FALSE

	if(m_intent == MOVE_INTENT_RUN) //No running in the halls!
		prob_slip *= 2

	if(HAS_TRAIT(src, TRAIT_NOSLIPALL))
		return
	return prob_slip

/atom/movable/proc/check_airflow_movable(n)

	if(anchored && !ismob(src)) return 0

	if(!isobj(src) && n < SSzas.settings.airflow_dense_pressure) return 0

	return 1

/mob/check_airflow_movable(n)
	if(n < SSzas.settings.airflow_heavy_pressure)
		return 0
	return 1

/mob/living/silicon/check_airflow_movable()
	return 0

/obj/check_airflow_movable(n)
	if(n < SSzas.settings.airflow_dense_pressure) return 0

	return ..()

/obj/item/check_airflow_movable(n)
	switch(w_class)
		if(1,2)
			if(n < SSzas.settings.airflow_lightest_pressure) return 0
		if(3)
			if(n < SSzas.settings.airflow_light_pressure) return 0
		if(4,5)
			if(n < SSzas.settings.airflow_medium_pressure) return 0
		if(6)
			if(n < SSzas.settings.airflow_heavy_pressure) return 0
		if(7 to INFINITY)
			if(n < SSzas.settings.airflow_dense_pressure) return 0
	return ..()


/atom/movable/var/tmp/turf/airflow_dest
/atom/movable/var/tmp/airflow_speed = 0
/atom/movable/var/tmp/airflow_time = 0
/atom/movable/var/tmp/last_airflow = 0
/atom/movable/var/tmp/airborne_acceleration = 0

/atom/movable/proc/AirflowCanMove(n)
	return 1

/mob/AirflowCanMove(n)
	if(status_flags & GODMODE)
		return 0
	if(buckled)
		return 0
	var/obj/item/clothing/shoes = get_item_by_slot(ITEM_SLOT_FEET)
	if(istype(shoes) && (shoes.clothing_flags & NOSLIP))
		return 0
	return 1

/atom/movable/Bump(atom/A)
	if(airflow_speed > 0 && airflow_dest)
		if(airborne_acceleration > 1)
			airflow_hit(A)
		else if(istype(src, /mob/living/carbon/human))
			to_chat(src, "<span class='notice'>You are pinned against [A] by airflow!</span>")
			airborne_acceleration = 0
	else
		airflow_speed = 0
		airflow_time = 0
		airborne_acceleration = 0
		. = ..()

/atom/movable/proc/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null
	airborne_acceleration = 0

/mob/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("<span class='danger'>\The [src] slams into \a [A]!</span>",1,"<span class='danger'>You hear a loud slam!</span>",2)
	playsound(src.loc, "smash.ogg", 25, 1, -1)
	. = ..()

/mob/living/airflow_hit(atom/A)
	var/weak_amt = istype(A,/obj/item) ? A:w_class : rand(1,5) //Heheheh
	Knockdown(weak_amt)
	return ..()

/obj/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("<span class='danger'>\The [src] slams into \a [A]!</span>",1,"<span class='danger'>You hear a loud slam!</span>",2)
	playsound(src.loc, "smash.ogg", 25, 1, -1)
	. = ..()

/obj/item/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

/mob/living/carbon/human/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("<span class='danger'>[src] slams into [A]!</span>",1,"<span class='danger'>You hear a loud slam!</span>",2)
	playsound(src.loc, "punch", 25, 1, -1)
	if (prob(33))
		loc.add_blood_DNA(return_blood_DNA())

	var/b_loss = min(airflow_speed, (airborne_acceleration*2)) * SSzas.settings.airflow_damage

	apply_damage(b_loss/3, BRUTE, BODY_ZONE_HEAD)

	apply_damage(b_loss/3, BRUTE, BODY_ZONE_CHEST)


	if(airflow_speed > 10)
		Paralyze(round(airflow_speed * SSzas.settings.airflow_stun))
		Stun(round(airflow_speed * SSzas.settings.airflow_stun) + 3)
	else
		Stun(round(airflow_speed * SSzas.settings.airflow_stun/2))
	return ..()

/zone/proc/movables()
	. = list()
	for(var/turf/T in contents)
		for(var/atom/movable/A in T)
			if(!A.simulated || A.anchored || istype(A, /obj/effect) || isobserver(A))
				continue
			. += A
