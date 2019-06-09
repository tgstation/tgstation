/datum/alpha_mask
	var/atom/mask

/datum/alpha_mask/New(appearance)
	var/image/I = new
	I.appearance = appearance
	I.color = list(0,0,0,1, 0,0,0,0, 0,0,0,0, 0,0,0,0, 1,1,1,0)
	I.blend_mode = BLEND_MULTIPLY
	I.appearance_flags |= KEEP_TOGETHER
	src.mask = I

/datum/alpha_mask/proc/apply_to(atom/target)
	var/target_old_color = target.color
	var/target_old_blend_mode = target.blend_mode
	var/target_old_appearance_flags = target.appearance_flags

	target.color = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,1)
	target.blend_mode = BLEND_MULTIPLY
	target.appearance_flags |= KEEP_TOGETHER

	var/image/together = new
	together.appearance_flags |= KEEP_TOGETHER

	mask.overlays = list(target)
	target.color = target_old_color
	together.overlays = list(mask, target)

	target.blend_mode = target_old_blend_mode
	target.appearance_flags = target_old_appearance_flags

	return together
