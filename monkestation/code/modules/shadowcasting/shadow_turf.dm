/turf/proc/check_shadowcasting_update()
	if(!shadowcasting_image)
		return
	SSshadowcasting.turf_queue += src

/turf/proc/update_shadowcasting()
	update_shadowcasting_image()
	var/datum/component/shadowcasting/shadowcasting
	for(var/mob/mob in src)
		if(!mob.client)
			continue
		shadowcasting = mob.GetComponent(/datum/component/shadowcasting)
		if(shadowcasting)
			shadowcasting.update_shadow()

/turf/proc/update_shadowcasting_image()
	if(!shadowcasting_image)
		shadowcasting_image = new()
	shadowcasting_image.overlays = create_shadowcasting_overlays()

/turf/proc/create_shadowcasting_overlays(view_range = world.view + 2)
	var/static/icon_size = world.icon_size
	var/static/half_icon_size = icon_size/2

	var/list/shadows = list()

	var/list/blocker_turfs_in_view = list()
	for(var/turf/in_view in (range(view_range, src)-src))
		if(!CHECK_LIGHT_OCCLUSION(in_view))
			continue
		blocker_turfs_in_view += in_view

	var/diff_x
	var/diff_y
	var/fac
	var/dx
	var/dy
	var/sign_x
	var/sign_y
	var/width
	var/height
	var/top
	var/bottom
	var/left
	var/right
	var/v_dir
	var/h_dir
	var/turf/temp_turf
	for(var/turf/blocker_turf as anything in blocker_turfs_in_view)
		diff_x = blocker_turf.x - src.x
		diff_y = blocker_turf.y - src.y
		fac = icon_size/(abs(diff_x) + abs(diff_y))
		dx = diff_x * icon_size
		dy = diff_y * icon_size
		sign_x = SIGN(diff_x)
		sign_y = SIGN(diff_y)

		width = 1
		height = 1
		if(!diff_x)
			temp_turf = get_step(blocker_turf, EAST)
			while(temp_turf && CHECK_LIGHT_OCCLUSION(temp_turf) && abs(temp_turf.x - blocker_turf.x) < view_range)
				width++
				temp_turf = get_step(temp_turf, EAST)
			temp_turf = get_step(blocker_turf, WEST)
			while(temp_turf && CHECK_LIGHT_OCCLUSION(temp_turf) && abs(temp_turf.x - blocker_turf.x) < view_range)
				width++
				dx -= icon_size
				temp_turf = get_step(temp_turf, WEST)
		else if(!diff_y)
			temp_turf = get_step(blocker_turf, NORTH)
			while(temp_turf && CHECK_LIGHT_OCCLUSION(temp_turf) && abs(temp_turf.y - blocker_turf.y) < view_range)
				height++
				temp_turf = get_step(temp_turf, NORTH)
			temp_turf = get_step(blocker_turf, SOUTH)
			while(temp_turf && CHECK_LIGHT_OCCLUSION(temp_turf) && abs(temp_turf.y - blocker_turf.y) < view_range)
				height++
				dy -= icon_size
				temp_turf = get_step(temp_turf, SOUTH)
		else
			v_dir = (dy >= 0 ? NORTH : SOUTH)
			h_dir = (dx >= 0 ? EAST : WEST)

			temp_turf = get_step(blocker_turf, h_dir)
			while(temp_turf && CHECK_LIGHT_OCCLUSION(temp_turf) && abs(temp_turf.x - blocker_turf.x) < view_range)
				width++
				temp_turf = get_step(temp_turf, h_dir)
			temp_turf = get_step(blocker_turf, v_dir)
			while(temp_turf && CHECK_LIGHT_OCCLUSION(temp_turf) && abs(temp_turf.y - blocker_turf.y) < view_range)
				height++
				temp_turf = get_step(temp_turf, v_dir)

		top = dy-(sign_y*half_icon_size)+(sign_y*height*icon_size)
		bottom = dy-(sign_y*half_icon_size)
		left = dx-(sign_x*half_icon_size)
		right = dx-(sign_x*half_icon_size)+(sign_x*width*icon_size)
		if(!diff_y)
			shadows += get_triangle_appearance(left,top, left,bottom, left*fac,bottom*fac)
			shadows += get_triangle_appearance(left*fac, top*fac,left,top, left*fac,bottom*fac)
		else if(!diff_x)
			shadows += get_triangle_appearance(right,bottom, left,bottom, left*fac,bottom*fac)
			shadows += get_triangle_appearance(left*fac,bottom*fac, right,bottom, right*fac,bottom*fac)
		else
			shadows += get_triangle_appearance(right,top, left,top, left*fac,top*fac)
			shadows += get_triangle_appearance(right,top, right,bottom, right*fac,bottom*fac)
			shadows += get_triangle_appearance(left*fac,top*fac, right,top, right*fac,bottom*fac)

	return shadows
