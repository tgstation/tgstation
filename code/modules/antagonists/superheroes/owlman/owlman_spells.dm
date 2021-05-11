/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long/owlman
	name = "Smoke Jaunt"
	desc = "Disappear using your smoke grenades and a bit of bluespace magic. Use the spell second time to reappear faster."
	invocation = "TWOOOO!!"
	invocation_type = INVOCATION_SHOUT
	charge_max = 15 SECONDS
	range = -1
	action_icon_state = "owl_jaunt"
	action_background_icon_state = "bg_default"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	phase_allowed = TRUE

	var/jaunt_timer

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long/owlman/do_jaunt(mob/living/target)
	playsound(target, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(1, target)
	smoke.start()
	qdel(smoke)

	if(istype(target.loc, /obj/effect/dummy/phased_mob/spell_jaunt))
		end_jaunt(target, target.loc)
		deltimer(jaunt_timer)
		return

	target.notransform = 1
	var/turf/mobloc = get_turf(target)
	var/obj/effect/dummy/phased_mob/spell_jaunt/holder = new /obj/effect/dummy/phased_mob/spell_jaunt(mobloc)
	new jaunt_out_type(mobloc, target.dir)
	target.extinguish_mob()
	target.forceMove(holder)
	target.reset_perspective(holder)
	target.notransform=0 //mob is safely inside holder now, no need for protection.
	jaunt_steam(mobloc)
	if(jaunt_out_time)
		ADD_TRAIT(target, TRAIT_IMMOBILIZED, type)
		sleep(jaunt_out_time)
		REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, type)

	jaunt_timer = addtimer(CALLBACK(src, .proc/end_jaunt, target, holder), jaunt_duration, TIMER_STOPPABLE)
	charge_counter = charge_max

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long/owlman/proc/end_jaunt(mob/living/target, obj/effect/dummy/phased_mob/spell_jaunt/holder)
	if(target.loc != holder) //mob warped out of the warp
		qdel(holder)
		return
	playsound(target, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(1, target)
	smoke.start()
	qdel(smoke)
	var/turf/mobloc = get_turf(target.loc)
	jaunt_steam(mobloc)
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, type)
	holder.reappearing = 1
	play_sound("exit",target)

	sleep(25 - jaunt_in_time)

	new jaunt_in_type(mobloc, holder.dir)
	target.setDir(holder.dir)

	sleep(jaunt_in_time)

	qdel(holder)
	if(!QDELETED(target))
		if(mobloc.density)
			for(var/direction in GLOB.alldirs)
				var/turf/T = get_step(mobloc, direction)
				if(T)
					if(target.Move(T))
						break
		REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, type)


/obj/effect/proc_holder/spell/targeted/owl_rush
	name = "Owl Rush"
	desc = "Focus all of your inner power on your cloak and use it to temporarely speed up. Cast the spell again to stop the rush."
	charge_max = 25 SECONDS
	range = -1
	include_user = TRUE
	clothes_req = FALSE
	invocation = "SHOOO!!"
	invocation_type = INVOCATION_SHOUT
	action_icon_state = "owl_sweep"
	action_background_icon_state = "bg_default"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	var/rush_active = FALSE
	var/mob/living/rush_target
	var/rush_timer

/obj/effect/proc_holder/spell/targeted/owl_rush/cast(list/targets,mob/user = usr)
	if(rush_active)
		deltimer(rush_timer)
		rush_target.remove_movespeed_modifier(/datum/movespeed_modifier/owl_rush)
		return

	for(var/mob/living/target in targets)
		target.add_movespeed_modifier(/datum/movespeed_modifier/owl_rush)
		rush_timer = addtimer(CALLBACK(target, /mob.proc/remove_movespeed_modifier, /datum/movespeed_modifier/owl_rush), 5 SECONDS, TIMER_STOPPABLE)
		rush_target = target
		rush_active = TRUE
		return

/datum/movespeed_modifier/owl_rush
	multiplicative_slowdown = -0.5
