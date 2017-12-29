/datum/component/explosive_trap
	// Touch or bump into an item with this component, and it'll explode
	var/list/mob/immune = list()

	var/color = "#000000"

	var/disable_time = 60 SECONDS

/datum/component/explosive_trap/Initialize(_immune, _color, _disable_time)
	if(!ismovableatom(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("[type] added to a [parent.type]")

	if(_immune)
		immune = _immune
	if(_color)
		color = _color
	if(_disable_time)
		disable_time = _disable_time

	RegisterSignal(list(COMSIG_MOVABLE_COLLIDE, COMSIG_UNARMED_ATTACK), .proc/Detonate)
	RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/Attackby)
	RegisterSignal(COMSIG_PARENT_EXAMINE, .proc/Examine)

	if(disable_time)
		addtimer(CALLBACK(src, .proc/Disable), disable_time)

/datum/component/explosive_trap/proc/Disable()
	for(var/i in immune)
		to_chat(i, "<span class='danger'>The explosive trap on [parent] has expired without detonating.</span>")
	qdel(src)

/datum/component/explosive_trap/proc/Detonate(mob/living/victim)
	if(!isliving(victim))
		return FALSE

	if(victim in immune)
		to_chat(victim, "<span class='userdanger'>[parent] pulses softly with <font color=\"[color]\">light</font>")
		return FALSE

	to_chat(victim, "<span class='userdanger'>[parent] explodes with <font color=\"[color]\">light</font>!</span>")

	new /obj/effect/temp_visual/explosion(get_turf(parent))
	victim.ex_act(EXPLODE_HEAVY)

	for(var/i in immune)
		to_chat(i, "<span class='notice'>The explosive trap on [parent] has caught [victim]!</span>")

	qdel(src)
	return TRUE

/datum/component/explosive_trap/proc/Attackby(obj/item/I, mob/living/user, params)
	if(Detonate(user))
		. = COMPONENT_NO_AFTERATTACK

/datum/component/explosive_trap/proc/Examine(mob/living/user)
	if(isobserver(user) || get_dist(user, parent) <= 2)
		to_chat(user, "<span class='holoparasite'>It glows with a strange <font color=\"[color]\">light</font>!</span>")
