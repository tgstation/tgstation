
GLOBAL_VAR_INIT(picture_datum_id, 1)
//GLOBAL_PROTECT(picture_datum_id)			//please don't.
GLOBAL_LIST_INIT(picture_logging_information, list())
//GLOBAL_PROTECT(picture_logging_information)			//pls no.

/datum/picture
	var/picture_name = "picture"
	var/picture_desc = "This is a picture."
	var/caption
	var/icon/picture_image
	var/icon/picture_icon
	var/psize_x = 0
	var/psize_y = 0
	var/has_blueprints = FALSE
	var/logpath						//If the picture has been logged this is the path.
	var/id

/datum/picture/New(name = "picture", desc = "This is a picture. A bugged one. Report it to coderbus!", image, icon, size_x = 96, size_y = 96, bp = FALSE, caption_)
	id = GLOB.picture_datum_id++
	picture_name = name
	picture_desc = desc
	picture_image = image
	picture_icon = icon
	psize_x = size_x
	psize_y = size_y
	has_blueprints = bp
	caption = caption_

/datum/picture/proc/log_to_file()
	var/finalpath = GLOB.picture_log_folder
	finalpath += "[id].png"
	var/list/picinfo = list()
	picinfo["desc"] = picture_desc
	picinfo["name"] = picture_name
	picinfo["caption"] = caption
	picinfo["pixel_size_x"] = psize_x
	picinfo["pixel_size_y"] = psize_y
	picinfo["blueprints"] = has_blueprints
	picinfo["logpath"] = finalpath
	GLOB.picture_logging_information["[id]"] = picinfo
	fcopy(icon(picture_image, dir = NORTH), finalpath)

/datum/picture/proc/Copy(greyscale = FALSE, cropx = 0, cropy = 0)
	var/datum/picture/P = new
	P.picture_name = picture_name
	P.picture_desc = picture_desc
	P.picture_image = picture_image
	P.picture_icon = picture_icon
	P.psize_x = psize_x - cropx * 2
	P.psize_y = psize_y - cropy * 2
	P.has_blueprints = has_blueprints
	if(greyscale)
		P.picture_image.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		P.picture_icon.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
	if(cropx || cropy)
		P.picture_image.Crop(cropx, cropy, psize_x - cropx, psize_y - cropy)
	return P
