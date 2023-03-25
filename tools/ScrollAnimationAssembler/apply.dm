/// Cut out a piece of the background at a specified frame, and paste it on top of the foreground
/proc/Apply(var/icon/source, var/icon/mask, var/icon/target, frame)

	//Temporary copies of source, mask and target
	var/icon/source_copy = new(source)
	var/icon/mask_copy = new(mask)
	var/icon/target_copy = new(target)

	//Automatically invert the mask
	mask_copy.SwapColor(rgb(255, 0, 220, 255), rgb(10, 20, 30, 40))
	mask_copy.SwapColor(rgb(0, 0, 0, 0), rgb(255, 0, 220, 255))
	mask_copy.SwapColor(rgb(10, 20, 30, 40), rgb(0, 0, 0, 0))

	//Overlay the mask onto the image then erase the covered area
	source_copy.Crop(frame, 1, frame+31, 32)
	source_copy.Blend(mask_copy, ICON_OVERLAY, 1, 1)
	source_copy.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))

	//Overlay the masked source onto the target
	target_copy.Blend(source_copy, ICON_OVERLAY, 1, 1)

	return target_copy
