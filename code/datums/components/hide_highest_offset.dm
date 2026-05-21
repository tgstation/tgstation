/// Component that takes a plane master, and will hide it if it's the highest offset of its kind
/// This allows us to not show PMs to clients if they're not actively doing anything
/datum/component/plane_hide_highest_offset

/datum/component/plane_hide_highest_offset/Initialize()
	if(!istype(parent, /atom/movable/screen/plane_master))
		return
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_offset_increase))
	offset_increase(-1, SSmapping.max_plane_offset)

/datum/component/plane_hide_highest_offset/proc/on_offset_increase(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_increase(old_offset, new_offset)

/datum/component/plane_hide_highest_offset/proc/offset_increase(old_offset, new_offset)
	var/atom/movable/screen/plane_master/plane_parent = parent
	var/mob/our_mob = plane_parent.home?.our_hud?.mymob
	var/our_offset = plane_parent.offset
	if(!our_mob)
		return
	if(our_offset == new_offset)
		plane_parent.hide_plane(our_mob)
	else if(our_offset == old_offset && plane_parent.force_hidden)
		plane_parent.unhide_plane(our_mob)
