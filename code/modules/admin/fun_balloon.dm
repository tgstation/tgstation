/obj/effect/fun_balloon
	name = "fun balloon"
	desc = "This is going to be a laugh riot."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	anchored = TRUE
	var/popped = FALSE

/obj/effect/fun_balloon/New()
	. = ..()
	SSobj.processing |= src

/obj/effect/fun_balloon/Destroy()
	SSobj.processing -= src
	. = ..()

/obj/effect/fun_balloon/process()
	if(!popped && check() && !qdeleted(src))
		popped = TRUE
		effect()
		pop()

/obj/effect/fun_balloon/proc/check()
	return FALSE

/obj/effect/fun_balloon/proc/effect()
	return

/obj/effect/fun_balloon/proc/pop()
	visible_message("[src] pops!")
	playsound(get_turf(src), 'sound/items/party_horn.ogg', 50, 1, -1)
	qdel(src)

/obj/effect/fun_balloon/attack_ghost(mob/user)
	if(!user.client || !user.client.holder || popped)
		return
	switch(alert("Pop [src]?","Fun Balloon","Yes","No"))
		if("Yes")
			effect()
			pop()

/obj/effect/fun_balloon/sentience
	name = "sentience fun balloon"
	desc = "When this pops, things are gonna get more aware around here."
	var/effect_range = 3
	var/group_name = "a bunch of giant spiders"

/obj/effect/fun_balloon/sentience/effect()
	var/list/bodies = list()
	for(var/mob/living/M in range(effect_range, get_turf(src)))
		bodies += M

	var/question = "Would you like to be [group_name]?"
	var/list/candidates = pollCandidatesForMobs(question, "pAI", null, FALSE, 100, bodies)
	while(candidates.len && bodies.len)
		var/mob/dead/observer/ghost = pick_n_take(candidates)
		var/mob/living/body = pick_n_take(bodies)

		body << "Your mob has been taken over by a ghost!"
		message_admins("[key_name_admin(ghost)] has taken control of ([key_name_admin(body)])")
		body.ghostize(0)
		body.key = ghost.key
		PoolOrNew(/obj/effect/overlay/temp/gravpush, get_turf(body))

/obj/effect/fun_balloon/sentience/emergency_shuttle
	name = "shuttle sentience fun balloon"
	var/trigger_time = 60

/obj/effect/fun_balloon/sentience/emergency_shuttle/check()
	. = FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.timeLeft() <= trigger_time) && (SSshuttle.emergency.mode == SHUTTLE_CALL))
		. = TRUE

/obj/effect/fun_balloon/scatter
	name = "scatter fun balloon"
	desc = "When this pops, you're not going to be around here anymore."
	var/effect_range = 5

/obj/effect/fun_balloon/scatter/effect()
	for(var/mob/living/M in range(effect_range, get_turf(src)))
		var/turf/T = find_safe_turf()
		PoolOrNew(/obj/effect/overlay/temp/gravpush, get_turf(M))
		M.forceMove(T)
		M << "<span class='notice'>Pop!</span>"

/obj/effect/station_crash
	name = "station crash"
	desc = "With no survivors!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	anchored = TRUE

/obj/effect/station_crash/New()
	for(var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/SM = S
		if(SM.id == "emergency_home")
			var/new_dir = turn(SM.dir, 180)
			SM.loc = get_ranged_target_turf(SM, new_dir, rand(3,15))
			break
	qdel(src)


//Luxury Shuttle Blockers

/obj/effect/forcefield/luxury_shuttle
	var/threshhold = 500
	var/list/approved_passengers = list()

/obj/effect/forcefield/luxury_shuttle/CanPass(atom/movable/mover, turf/target, height=0)
	if(mover in approved_passengers)
		return 1

	if(!isliving(mover)) //No stowaways
		return 0

	var/total_cash = 0
	var/list/counted_money = list()

	for(var/obj/item/weapon/coin/C in mover)
		total_cash += C.value
		counted_money += C
		if(total_cash >= threshhold)
			break
	for(var/obj/item/stack/spacecash/S in mover)
		total_cash += S.value * S.amount
		counted_money += S
		if(total_cash >= threshhold)
			break

	if(total_cash >= threshhold)
		for(var/obj/I in counted_money)
			qdel(I)

		mover << "Thank you for your payment! Please enjoy your flight."
		approved_passengers += mover
		return 1
	else
		mover << "You don't have enough money to enter the main shuttle. You'll have to fly coach."
		return 0

//Shuttle Build

/obj/effect/shuttle_build
	name = "shuttle_build"
	desc = "Some assembly required"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	anchored = TRUE

/obj/effect/shuttle_build/New()
	SSshuttle.emergency.dock(SSshuttle.getDock("emergency_home"))
	qdel(src)