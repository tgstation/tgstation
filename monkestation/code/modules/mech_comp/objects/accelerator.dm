/obj/item/mcobject/graviton_accelerator
	name = "graviton accelerator"
	base_icon_state = "comp_accel"
	icon_state = "comp_accel"

	var/on = FALSE
	COOLDOWN_DECLARE(cd)

/obj/item/mcobject/graviton_accelerator/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, connections)

	MC_ADD_INPUT("activate", turn_on)

/obj/item/mcobject/graviton_accelerator/Destroy(force)
	on = FALSE
	return ..()

/obj/item/mcobject/graviton_accelerator/set_anchored(anchorvalue)
	. = ..()
	if(!anchored)
		on = FALSE

/obj/item/mcobject/graviton_accelerator/update_icon_state()
	. = ..()
	icon_state = anchored ? "u[base_icon_state]" : base_icon_state
	icon_state = on ? "[icon_state]1" : icon_state

/obj/item/mcobject/graviton_accelerator/proc/turn_on()
	set waitfor = FALSE
	if(on || !COOLDOWN_FINISHED(src, cd))
		return

	on = TRUE
	update_icon_state()
	spawn(-1)
		while(on)
			if(length(loc.contents) > 1)
				for(var/atom/movable/AM as anything in loc.contents - src)
					if(!on)
						return
					if(ismob(AM) && !isliving(AM))
						continue
					if(iseffect(AM))
						continue
					yeet(AM)
					CHECK_TICK
				stoplag(1 SECONDS)
			else
				stoplag()

	sleep(2 SECONDS)
	on = FALSE
	update_icon_state()
	COOLDOWN_START(src, cd, 1 SECONDS)

/obj/item/mcobject/graviton_accelerator/proc/on_entered(source, atom/movable/thing)
	set waitfor = FALSE

	if(!on)
		return

	sleep(0.2 SECONDS)
	yeet(thing)

/obj/item/mcobject/graviton_accelerator/proc/yeet(atom/movable/thing)
	if(thing.anchored)
		return
	if(!thing.has_gravity())
		return
	thing.safe_throw_at(get_edge_target_turf(src, dir), 8, 3)
