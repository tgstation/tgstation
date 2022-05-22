/obj/effect/proc_holder/spell/pointed/oil_jaunt
	name = "Oil Jaunt"
	desc = "This spell allows you to jump from oil to other oil pools."
	school = SCHOOL_TRANSMUTATION
	charge_max = 15 SECONDS
	clothes_req = FALSE
	invocation = "Gurlgle-gle blubf"
	invocation_type = INVOCATION_WHISPER
	range = 9
	ranged_mousepointer = 'icons/effects/mouse_pointers/oil_target.dmi'
	action_icon = 'icons/mob/actions/actions_ccult.dmi'
	action_icon_state = "oil_jaunt"
	action_background_icon_state = "bg_clock"
	active_msg = "You prepare to jump through oil..."
	self_castable = TRUE
	/// For how long we become immobilized when using this spell.
	var/jaunt_time = 2 SECONDS
	/// Visual for jaunting
	var/jaunt_in_type = /obj/effect/temp_visual/oil
	/// Visual for exiting the jaunt
	var/jaunt_out_type = /obj/effect/temp_visual/oil/out

/obj/effect/proc_holder/spell/pointed/oil_jaunt/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	var/area/noteleport_check_user = get_area(user)
	var/area/noteleport_check_target = get_area(user)
	if(noteleport_check_target && noteleport_check_target && noteleport_check_user.area_flags & NOTELEPORT && noteleport_check_user.area_flags & NOTELEPORT)
		to_chat(user, span_danger("Some dull, universal force is between you and your other existence, preventing you from blood crawling."))
		return FALSE
	var/list/can_jaunt_owner = get_oiljaunt_pools(get_turf(owner), 0)
	if(!can_jaunt_owner.len)
		to_chat(user, span_warning("You can only jaunt to tiles while standing on oil!"))
		return FALSE
	var/list/can_jaunt_target = get_oiljaunt_pools(get_turf(target), 0)
	if(!can_jaunt_target.len)
		to_chat(user, span_warning("You can only jaunt to tiles with oil!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/oil_jaunt/cast(list/targets, mob/user = usr)
	play_sound("enter", user)
	user.notransform = TRUE
	var/turf/target_loc
	for(var/target in targets)
		target_loc = get_turf(target)
	var/turf/mobloc = get_turf(user)
	new jaunt_in_type(mobloc, user.dir)
	var/obj/effect/dummy/phased_mob/oil_jaunt/holder = new /obj/effect/dummy/phased_mob/oil_jaunt(mobloc)
	user.forceMove(holder)
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, type)
	sleep(jaunt_time)
	play_sound("exit", user)
	new jaunt_out_type(target_loc, user.dir)
	holder.forceMove(target_loc)
	sleep(0.5 SECONDS)
	mobloc = get_turf(user.loc)
	holder.reappearing = TRUE
	qdel(holder)
	user.notransform = FALSE
	sleep(0.3 SECONDS)
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, type)

/obj/effect/proc_holder/spell/pointed/oil_jaunt/proc/play_sound(type, mob/living/target)
	switch(type)
		if("enter")
			playsound(get_turf(target), 'sound/magic/ethereal_enter.ogg', 50, TRUE, -1)
		if("exit")
			playsound(get_turf(target), 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)

/proc/get_oiljaunt_pools(turf/tile, range)
	. = list()
	for(var/obj/effect/decal/cleanable/nearby in view(tile, range))
		if(nearby.can_oiljaunt_in())
			. += nearby

/obj/effect/dummy/phased_mob/oil_jaunt
	var/reappearing = FALSE

/obj/effect/dummy/phased_mob/oil_jaunt/phased_check(mob/living/user, direction)
	if(reappearing)
		return
	. = ..()
	if(!.)
		return
	if (locate(/obj/effect/blessing, .))
		to_chat(user, span_warning("Holy energies block your path!"))
		return null
