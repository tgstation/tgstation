/// Previously, body types could only be used on non-binary characters.
/// PR #62733 changed this to allow all characters to use body type.
/// This migration moves binary-gendered characters over to the "use gender" body type
/// so that old characters are preserved.
/datum/preferences/proc/migrate_body_types(list/save_data)
	var/current_gender = save_data["gender"]
	if (current_gender == MALE || current_gender == FEMALE)
		save_data["body_type"] = "Use gender"
