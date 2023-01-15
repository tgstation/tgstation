/**
 * Record datum. Used for crew records and admin locked records.
 */
/datum/record
	/// Account number
	var/id
	/// Name of the crew member
	var/name
	/// Rank of the crew member
	var/rank
	/// Job of the crew member
	var/trim
	/// Initial rank of the crew member
	var/initial_rank
	/// Age
	var/age
	/// Crew species
	var/species
	/// Male/Female/Other gender
	var/gender
	/// Crew member's face
	var/mutable_appearance/character_appearance
	/// Crew member's blood type
	var/blood_type
	/// DNA string
	var/dna
	/// Fingerprint is md5 of DNA
	var/fingerprint

/datum/record/New(
	id = "000000",
	name = "Unknown",
	rank = "Unassigned",
	trim = "Unassigned",
	initial_rank = "Unassigned",
	age = 18,
	species = "Human",
	gender = "Other",
	character_appearance,
	blood_type = "?",
	dna = "Unknown",
	fingerprint = "?????"
	)
	src.id = id
	src.name = name
	src.rank = rank
	src.trim = trim
	src.initial_rank = rank
	src.age = age
	src.species = species
	src.gender = gender
	src.character_appearance = character_appearance
	src.blood_type = blood_type
	src.dna = dna
	src.fingerprint = fingerprint

/**
 * Crew record datum
 */
/datum/record/crew
	// Medical
	/// Minor disabilities
	var/mi_dis
	/// Minor disabilities description
	var/mi_dis_d
	/// Major disabilities
	var/ma_dis
	/// Major disabilities description
	var/ma_dis_d
	/// Diseases
	var/cdi
	/// Diseases description
	var/cdi_d
	/// Allergies
	var/alg
	/// Allergies description
	var/alg_d
	/// Other notes written by doctors
	var/medical_notes
	/// Notes description
	var/medical_notes_d
	/// Health status in medical records
	var/p_stat
	/// Mental status in medical records
	var/m_stat

	// Security
	/// Security status
	var/criminal
	/// Citations list
	var/citation = list()
	/// Crimes list
	var/crim = list()
	/// Security notes
	var/security_notes

/datum/record/crew/New(
	id = "000000",
	name = "Unknown",
	rank = "Unassigned",
	trim = "Unassigned",
	initial_rank = "Unassigned",
	age = 18,
	species = "Human",
	gender = "Other",
	character_appearance,
	blood_type = "?",
	dna = "Unknown",
	fingerprint = "?????"
	mi_dis = "None",
	mi_dis_d = "No disabilities have been diagnosed at the moment.",
	ma_dis = "None",
	ma_dis_d = "No disabilities have been diagnosed at the moment.",
	cdi = "None",
	cdi_d = "No diseases",
	alg = "None",
	alg_d = "No allergies",
	medical_notes = "No notes.",
	medical_notes_d = "No notes.",
	p_stat = "Active",
	m_stat = "Stable",
	criminal = "None",
	citation = list(),
	crim = list(),
	security_notes = "No notes."
	)
	. = ..()
	src.mi_dis = mi_dis
	src.mi_dis_d = mi_dis_d
	src.ma_dis = ma_dis
	src.ma_dis_d = ma_dis_d
	src.cdi = cdi
	src.cdi_d = cdi_d
	src.alg = alg
	src.alg_d = alg_d
	src.medical_notes = medical_notes
	src.medical_notes_d = medical_notes_d
	src.p_stat = p_stat
	src.m_stat = m_stat
	src.criminal = criminal
	src.citation = citation
	src.crim = crim
	src.security_notes = security_notes

	GLOB.data_core.general += src

/datum/record/crew/Destroy()
	GLOB.data_core.general -= src
	return ..()

/**
 * Admin locked record
 */
/datum/record/locked
	/// Mind datum
	var/datum/mind/mindref
	/// List of features
	var/features = list()
	/// Mobs unique identity from dna
	var/identity

/datum/record/locked/New(
	id = "000000",
	name = "Unknown",
	rank = "Unassigned",
	trim = "Unassigned",
	initial_rank = "Unassigned",
	age = 18,
	species = "Human",
	gender = "Other",
	character_appearance,
	blood_type = "?",
	dna = "Unknown",
	fingerprint = "?????",
	mindref,
	features = list(),
	identity = "Unknown"
	)
	. = ..()
	src.mindref = mindref
	src.features = features
	src.identity = identity

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
