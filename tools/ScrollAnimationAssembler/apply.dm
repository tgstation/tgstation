
/proc/Apply(var/icon/source, var/icon/mask, var/icon/target, frame)

	//Temporary copies of source, mask and target
	var/icon/S = new(source)
	var/icon/M = new(mask)
	var/icon/T = new(target)

	//Automatically invert the mask
	M.SwapColor(rgb(255, 0, 220, 255), rgb(10, 20, 30, 40))
	M.SwapColor(rgb(0, 0, 0, 0), rgb(255, 0, 220, 255))
	M.SwapColor(rgb(10, 20, 30, 40), rgb(0, 0, 0, 0))

	//Overlay the mask onto the image then erase the covered area
	S.Crop(frame, 1, frame+31, 32)
	S.Blend(M, ICON_OVERLAY, 1, 1)
	S.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))

	//Overlay the masked source onto the target
	T.Blend(S, ICON_OVERLAY, 1, 1)

	return T