/// Previously, body types could only be used on non-binary characters.
/// PR #62733 changed this to allow all characters to use body type.
/// This migration moves binary-gendered characters over to the "use gender" body type
/// so that old characters are preserved.
/datum/preferences/proc/migrate_body_types(savefile/savefile)
	var/current_gender

	READ_FILE(savefile["gender"], current_gender)
	if (current_gender == MALE || current_gender == FEMALE)
		WRITE_FILE(savefile["body_type"], "Use gender")
