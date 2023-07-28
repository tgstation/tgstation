/// Used for finding a valid name to assign a picture to.
/// Please don't touch this.
var/static/next_ntos_picture_id = 0

/// Returns a name which a /datum/picture can be assigned to.
/// Use this function to get asset names and to avoid cache duplicates/overwriting.
/proc/get_next_ntos_picture_name()
	var/next_uid = next_ntos_picture_id
	next_ntos_picture_id++
	return "ntos_picture_[next_uid].png"

/**
 * PNG file type
 * Stores a picture which can be used by other programs.
 */
/datum/computer_file/picture
	filetype = "PNG" // the superior filetype
	size = 2
	/// The instance of the stored picture.
	var/datum/picture/stored_picture
	/// The name of the asset cache item.
	/// This is initialized after assign_path() is called.
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

/// Assigns an asset path to the stored image, for use in the UI.
/datum/computer_file/picture/proc/assign_path()
	if(!isnull(picture_name))
		return
	picture_name = get_next_ntos_picture_name()
	SSassets.transport.register_asset(picture_name, stored_picture.picture_image)

/datum/computer_file/picture/clone(rename = FALSE)
	var/datum/computer_file/picture/temp = ..()
	temp.stored_picture = stored_picture
	temp.picture_name = picture_name
	return temp
