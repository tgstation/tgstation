/obj/effect/proc_holder/spell/aoe_turf/conjure/eruption
	name = "Eruption"
	desc = "Gradually set fire to everything you can see, yourself included. The closer the fire is to the centre, the longer it lasts."
	school = "evocation"
	charge_max = 600
	clothes_req = 1
	invocation = "DIE, INSECT!"
	invocation_type = "shout"
	cooldown_min = 200
	summon_type = list(/obj/effect/hotspot)
	summon_amt = 225 //quite literally everything
	summon_ignore_prev_spawn_points = 1
	range = 1
	action_icon_state = "eruption"
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	sound = 'sound/magic/Fireball.ogg'

/obj/effect/proc_holder/spell/aoe_turf/conjure/eruption/cast(list/targets,mob/living/user = usr)
	user.SetStun(40, TRUE)
	var/list/viewarea = view(range, usr)
	LAZYINITLIST(targets)
	LAZYCLEARLIST(targets)
	for(var/turf/T in viewarea)
		LAZYADD(targets, T)
	..()
	visciouscycle()

/obj/effect/proc_holder/spell/aoe_turf/conjure/eruption/proc/visciouscycle()
	if(range <= 6)
		sound = null
		invocation = null
		spawn(5)
			range += 1
			cast()
	else
		invocation = "DIE, INSECT!"
		sound = 'sound/magic/Fireball.ogg'
		range = 1
		return
