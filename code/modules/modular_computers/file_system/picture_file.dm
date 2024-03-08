/**
 * PNG file type
 * Stores a picture which can be used by other programs.
 */
/datum/computer_file/picture
	filetype = "PNG" // the superior filetype
	size = 1
	/// The instance of the stored picture.
	var/datum/picture/stored_picture
	/// The name of the asset cache item.
	/// This will be initialized after assign_path() is called.
	var/picture_name

/datum/computer_file/picture/New(datum/picture/stored_picture, picture_name)
	..()
	if(isnull(stored_picture))
		return
	src.filename = "[stored_picture.picture_name] ([uid])"
	src.stored_picture = stored_picture
	src.picture_name = picture_name

/datum/computer_file/picture/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	assign_path()

/// Assigns an asset path to the stored image, for use in the UI.
/datum/computer_file/picture/proc/assign_path()
	if(!isnull(picture_name))
		return
	picture_name = SSmodular_computers.get_next_picture_name()
	SSassets.transport.register_asset(picture_name, stored_picture.picture_image)

/datum/computer_file/picture/clone(rename = FALSE)
	var/datum/computer_file/picture/temp = ..()
	temp.stored_picture = stored_picture
	temp.picture_name = picture_name
	return temp
