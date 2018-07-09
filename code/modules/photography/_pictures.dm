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
	var/id							//this var is NOT protected because the worst you can do with this that you couldn't do otherwise is overwrite photos, and photos aren't going to be used as attack logs/investigations anytime soon.

/datum/picture/New(name = "picture", desc = "This is a picture. A bugged one. Report it to coderbus!", image, icon, size_x = 96, size_y = 96, bp = FALSE, caption_, autogenerate_icon = FALSE)
	picture_name = name
	picture_desc = desc
	picture_image = image
	picture_icon = icon
	psize_x = size_x
	psize_y = size_y
	has_blueprints = bp
	caption = caption_
	if(autogenerate_icon && !picture_icon && picture_image)
		regenerate_small_icon()

/datum/picture/proc/get_small_icon()
	if(!picture_icon)
		regenerate_small_icon()
	return picture_icon

/datum/picture/proc/regenerate_small_icon()
	if(!picture_image)
		return
	var/icon/small_img = icon(picture_image)
	var/icon/ic = icon('icons/obj/items_and_weapons.dmi', "photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	picture_icon = ic

/datum/picture/serialize_list(list/options)
	. = list()
	.["id"] = id
	.["desc"] = picture_desc
	.["name"] = picture_name
	.["caption"] = caption
	.["pixel_size_x"] = psize_x
	.["pixel_size_y"] = psize_y
	.["blueprints"] = has_blueprints
	.["logpath"] = logpath

/datum/picture/deserialize_list(list/input, list/options)
	if(!input["logpath"] || !fexists(input["logpath"]) || !input["id"] || !input["pixel_size_x"] || !input["pixel_size_y"])
		return
	picture_image = icon(file(input["logpath"]))
	logpath = input["logpath"]
	id = input["id"]
	psize_x = input["pixel_size_x"]
	psize_y = input["pixel_size_y"]
	if(input["blueprints"])
		has_blueprints = input["blueprints"]
	if(input["caption"])
		caption = input["caption"]
	if(input["desc"])
		picture_desc = input["desc"]
	if(input["name"])
		picture_name = input["name"]

/datum/picture/proc/generate_ID()
	return "[GLOB.picture_logging_prefix][GLOB.picture_logging_id++]"

/proc/load_photo_from_disk(id)
	var/datum/picture/P = load_picture_from_disk(id)
	if(istype(P))
		var/obj/item/photo/p = new(null, P)
		return p

/proc/load_picture_from_disk(id)
	var/path = log_path_from_picture_ID(id)
	if(!path)
		return
	if(!fexists(path))
		return
	var/dir_index = findlasttext(path, "/")
	var/dir = copytext(path, 1, dir_index + 1)
	var/json_path = "[dir]/metadata.json"
	if(!fexists(json_path))
		return
	var/list/json = json_decode(file2text(json_path))
	if(!json[id])
		return
	var/datum/picture/P = new
	P.deserialize_list(json[id])
	return P

/proc/log_path_from_picture_ID(id)
	. = "data/logs/"
	var/posL = findlasttext(id, "_")
	var/posF = findtext(id, "_")
	var/n = copytext(id, posL+1)
	var/mid = copytext(id, posF+1, posL)
	if(id[1] == "O")
		. += mid
	else if(id[1] == "L")
		var/LposD = findtext(mid, "_")
		var/D = copytext(mid, 1, LposD)
		var/m = copytext(mid, LposD+1)
		var/year = copytext(D, 1, 5)
		var/month = copytext(D, 5, 7)
		var/day = copytext(D, 7, 9)
		. += "[year]/[month]/[day]/"
		if(m[1] == "R")
			. += "round-[copytext(m, 2)]"
		else if(m[2] == "T")
			. += "[copytext(m, 2)]"
		else
			return null
	else
		return
	. += "/[n].png"

//BE VERY CAREFUL WITH THIS PROC, TO AVOID DUPLICATION.
/datum/picture/proc/log_to_file()
	if(!picture_image)
		return
	if(!CONFIG_GET(flag/log_pictures))
		return
	if(logpath)
		return			//we're already logged
	id = generate_ID()
	var/finalpath = "[GLOB.picture_log_directory]/[id].png"
	fcopy(icon(picture_image, dir = SOUTH, frame = 1), finalpath)
	logpath = finalpath
	SSpersistence.picture_logging_information["[id]"] = serialize_json()

/datum/picture/proc/Copy(greyscale = FALSE, cropx = 0, cropy = 0)
	var/datum/picture/P = new
	P.picture_name = picture_name
	P.picture_desc = picture_desc
	if(picture_image)
		P.picture_image = icon(picture_image)	//Copy, not reference.
	if(picture_icon)
		P.picture_icon = icon(picture_icon)
	P.psize_x = psize_x - cropx * 2
	P.psize_y = psize_y - cropy * 2
	P.has_blueprints = has_blueprints
	if(greyscale)
		if(picture_image)
			P.picture_image.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		if(picture_icon)
			P.picture_icon.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
	if(cropx || cropy)
		if(picture_image)
			P.picture_image.Crop(cropx, cropy, psize_x - cropx, psize_y - cropy)
		P.regenerate_small_icon()
	return P
