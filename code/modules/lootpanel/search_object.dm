/datum/search_object
	/// A string representation of the object's icon
	var/image
	/// The name of the object
	var/name
	/// The reference of the object
	var/ref


/datum/search_object/New(name, ref, image)
	. = ..()

	src.name = name
	src.ref = ref
	src.image = image


/datum/search_object/Destroy(force)
	. = ..()

	name = null
	ref = null
	image = null
