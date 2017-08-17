/obj/effect/clockwork/servant_blocker
	icon_state = "servant_blocker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = TRUE

/obj/effect/clockwork/servant_blocker/CanPass(atom/movable/mover, turf/target)
	var/list/target_contents = mover.GetAllContents()
	target_contents += mover
	for(var/mob/living/L in target_contents)
		if(is_servant_of_ratvar(L) && get_dir(get_turf(mover), src) != dir)
			return FALSE
	return TRUE