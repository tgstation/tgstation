
/atom/movable/proc/apply_displacement_icon(obj/effect/distortion/large/type)
	var/obj/effect/distortion/distortion_effect = new type
	src.add_filter("large_displacement_[initial(type.name)]", 1, displacement_map_filter(size= distortion_effect.size , render_source = distortion_effect.render_target))
	distortion_effect.name = ""
	src.vis_contents += distortion_effect
	distortion_effect.icon_state = initial(type.icon_state)
