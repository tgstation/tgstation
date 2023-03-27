/obj/effect/sprint_dust
	icon = 'goon/icons/obj/effects.dmi'
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/obj/effect/sprint_dust/proc/appear(state, dir, turf/T, duration)
	if(!T)
		return
	if(state == "sprint_cloud")
		src.dir = SOUTH
	src.dir ||= dir
	abstract_move(T)
	flick(state, src)
	addtimer(CALLBACK(src, /atom/movable/proc/moveToNullspace), duration)
