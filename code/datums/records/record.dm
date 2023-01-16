/**
 * Record datum. Used for crew records and admin locked records.
 */
/datum/record
	/// Age of the character
	var/age
	/// Their blood type
	var/blood_type
	/// Character appearance
	var/mutable_appearance/character_appearance
	/// DNA string
	var/dna_string
	/// Fingerprint string (md5)
	var/fingerprint
	/// The character's gender
	var/gender
	/// The character's ID number
	var/id_number
	/// The character's initial rank at roundstart
	var/initial_rank
	/// The character's name
	var/name = "Unknown"
	/// The character's rank
	var/rank
	/// The character's species
	var/species
	/// The character's ID trim
	var/trim

/datum/record/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	id_number = "000000",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	trim = "Unassigned",
	)
	src.age = age
	src.blood_type = blood_type
	src.character_appearance = character_appearance
	src.dna_string = dna_string
	src.fingerprint = fingerprint
	src.gender = gender
	src.id_number = id_number
	src.initial_rank = rank
	src.name = name
	src.rank = rank
	src.species = species
	src.trim = trim

/**
 * Crew record datum
 */
/datum/record/crew
	/// List of citations
	var/list/citations = list()
	/// List of crimes
	var/list/crimes = list()
	/// Names of major disabilities
	var/major_disabilities
	/// Fancy description of major disabilities
	var/major_disabilities_desc
	/// List of medical notes (roundstart populated with quirk strings)
	var/list/medical_notes
	/// Names of minor disabilities
	var/minor_disabilities
	/// Fancy description of minor disabilities
	var/minor_disabilities_desc
	/// List of security notes
	var/list/security_notes = list()
	/// Current arrest status
	var/wanted_status = "None"

/datum/record/crew/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	id_number = "000000",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	trim = "Unassigned",
	/// Crew specific
	major_disabilities = "None",
	major_disabilities_desc = "No disabilities have been diagnosed at the moment.",
	medical_notes = list(),
	minor_disabilities = "None",
	minor_disabilities_desc = "No disabilities have been diagnosed at the moment.",
	)
	. = ..()
	src.major_disabilities = major_disabilities
	src.major_disabilities_desc = major_disabilities_desc
	src.medical_notes += medical_notes
	src.minor_disabilities = minor_disabilities
	src.minor_disabilities_desc = minor_disabilities_desc

	GLOB.data_core.general += src

/datum/record/crew/Destroy()
	GLOB.data_core.general -= src
	return ..()

/**
 * Admin locked record
 */
/datum/record/locked
	/// Mob's dna
	var/datum/dna/dna_ref
	/// Mind datum
	var/datum/mind/mindref

/datum/record/locked/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	id_number = "000000",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	trim = "Unassigned",
	/// Locked specific
	dna_ref,
	mindref,
	)
	. = ..()
	src.dna_ref = dna_ref
	src.mindref = mindref

	GLOB.data_core.locked += src

/datum/record/locked/Destroy()
	GLOB.data_core.locked -= src
	return ..()

/// A helper proc to get the front photo of a character from the record.
/// Handles calling `get_photo()`, read its documentation for more information.
/datum/record/crew/proc/get_front_photo()
	return get_photo("photo_front", SOUTH)

/// A helper proc to get the side photo of a character from the record.
/// Handles calling `get_photo()`, read its documentation for more information.
/datum/record/crew/proc/get_side_photo()
	return get_photo("photo_side", WEST)

/**
 * You shouldn't be calling this directly, use `get_front_photo()` or `get_side_photo()`
 * instead.
 *
 * This is the proc that handles either fetching (if it was already generated before) or
 * generating (if it wasn't) the specified photo from the specified record. This is only
 * intended to be used by records that used to try to access `fields["photo_front"]` or
 * `fields["photo_side"]`, and will return an empty icon if there isn't any of the necessary
 * fields.
 *
 * Arguments:
 * * field_name - The name of the key in the `fields` list, of the record itself.
 * * orientation - The direction in which you want the character appearance to be rotated
 * in the outputed photo.
 *
 * Returns an empty `/icon` if there was no `character_appearance` entry in the `fields` list,
 * returns the generated/cached photo otherwise.
 */
/datum/record/crew/proc/get_photo(field_name, orientation)
	if(field_name)
		return field_name

	if(!character_appearance)
		return new /icon()

	var/mutable_appearance/appearance = character_appearance
	appearance.setDir(orientation)

	var/icon/picture_image = getFlatIcon(appearance)

	var/datum/picture/picture = new
	picture.picture_name = name
	picture.picture_desc = "This is [name]."
	picture.picture_image = picture_image

	var/obj/item/photo/photo = new(null, picture)
	field_name = photo
	return photo
