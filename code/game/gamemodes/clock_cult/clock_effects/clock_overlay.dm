//an "overlay" used by clockwork walls and floors to appear normal to mesons.
/obj/effect/clockwork/overlay
	mouse_opacity = 0
	var/atom/linked

/obj/effect/clockwork/overlay/examine(mob/user)
	if(linked)
		linked.examine(user)

/obj/effect/clockwork/overlay/ex_act()
	return FALSE

/obj/effect/clockwork/overlay/singularity_pull(S, current_size)
	return

/obj/effect/clockwork/overlay/Destroy()
	if(linked)
		linked = null
	. = ..()

/obj/effect/clockwork/overlay/floor/bloodcult //this is used by BLOOD CULT, it shouldn't use such a path...
	icon_state = "cult"