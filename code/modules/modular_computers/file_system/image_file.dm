/**
 * PNG file type
 * Stores an image which can be used by other programs.
 */
/datum/computer_file/image
	filetype = "PNG" // the superior filetype
	size = 1
	/// The instance of the stored image.
	var/icon/stored_icon
	/// The name of the asset cache item.
	/// This will be initialized after assign_path() is called.
	var/image_name
	/// The unmodified photo or painting this is a digital copy of.
	var/source_photo_or_painting
	/// The ckey of the user who last modified this image, applied to printed photos.
	var/author_ckey

/datum/computer_file/image/New(icon/stored_icon, image_name, display_name, source_photo_or_painting)
	..()
	if(isnull(stored_icon))
		return
	src.filename = "[display_name] ([uid])"
	src.stored_icon = stored_icon
	src.image_name = image_name
	set_source(source_photo_or_painting)

/datum/computer_file/image/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	assign_path()

/// Assigns an asset path to the stored image, for use in the UI.
/datum/computer_file/image/proc/assign_path()
	if(!isnull(image_name))
		return
	image_name = SSmodular_computers.get_next_picture_name()
	SSassets.transport.register_asset(image_name, stored_icon)

/datum/computer_file/image/clone(rename = FALSE)
	var/datum/computer_file/image/temp = ..()
	temp.stored_icon = stored_icon
	temp.image_name = image_name
	temp.source_photo_or_painting = source_photo_or_painting
	temp.author_ckey = author_ckey
	return temp

/// Assign this file's backing datum
/datum/computer_file/image/proc/set_source(new_source)
	source_photo_or_painting = new_source
	if(istype(new_source, /datum/picture))
		var/datum/picture/source_picture = new_source
		author_ckey = source_picture.author_ckey
	if(istype(new_source, /datum/painting))
		var/datum/painting/source_painting = new_source
		author_ckey = source_painting.creator_ckey

