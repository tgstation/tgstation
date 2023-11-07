/mob
	///Should the mob use the shadowcasting component when a client is logged to it?
	var/shadow_caster = FALSE


/mob/proc/update_shadowcasting()
	if(!shadow_caster || !client)
		return
	for(var/atom/movable/screen/plane_master/plane_master as anything in hud_used.get_true_plane_masters(SHADOWCASTING_PLANE))
		plane_master.alpha = 96
	for(var/atom/movable/screen/plane_master/plane_master as anything in hud_used.get_true_plane_masters(SHADOWCASTING_PLANE))
		plane_master.add_filter("blur", 2, gauss_blur_filter(size = 3))
	var/datum/component/shadowcasting = GetComponent(/datum/component/shadowcasting)
	if(!shadowcasting)
		AddComponent(/datum/component/shadowcasting)
