/**
 * PIC file type
 * Stores a picture to be used for programs.
 */
/datum/computer_file/picture
	filetype = "PIC"
	var/datum/picture/stored_picture

/datum/computer_file/picture/New(datum/picture/picture)
	..()
	stored_picture = picture.Copy()
	filename = picture.picture_name
