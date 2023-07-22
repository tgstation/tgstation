/**
 * PNG file type
 * Stores a picture to be used for programs.
 */

GLOBAL_VAR_INIT(next_ntos_picture_uid, 0)

/proc/get_next_ntos_picture_path()
	return "ntos_picture_[GLOB.next_ntos_picture_uid++].png"

/datum/computer_file/picture
	filetype = "PNG" // the superior filetype
	size = 2
	var/datum/picture/stored_picture
	var/picture_name

/datum/computer_file/picture/New(datum/picture/stored_picture, picture_name)
	..()
	if(isnull(stored_picture))
		return
	src.filename = stored_picture.picture_name
	src.stored_picture = stored_picture
	src.picture_name = picture_name

/datum/computer_file/picture/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	assign_path()

/datum/computer_file/picture/proc/assign_path()
	if(!isnull(picture_name))
		return
	picture_name = get_next_ntos_picture_path()
	SSassets.transport.register_asset(picture_name, stored_picture.picture_image)

/datum/computer_file/picture/clone(rename = FALSE)
	var/datum/computer_file/picture/temp = ..()
	temp.stored_picture = stored_picture
	temp.picture_name = picture_name
	return temp
