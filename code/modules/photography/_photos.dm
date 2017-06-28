
/datum/picture
	var/picture_name = "picture"
	var/picture_desc = "This is a picture."
	var/image/picture_image
	var/icon/picture_icon
	var/psize_x = 0
	var/psize_y = 0
	var/has_blueprints = FALSE

/datum/picture/New(name = "picture", desc = "This is a picture. A bugged one. Report it to coderbus!", image, icon, size_x = 96, size_y = 96, bp = FALSE)
	picture_name = name
	picture_desc = desc
	picture_image = image
	picture_icon = icon
	psize_x = size_x
	psize_y = size_y
	has_blueprints = bp
