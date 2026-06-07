/// This test ensures that multiple languages aren't mapped to the same prefix key.
/datum/unit_test/language_key_conflicts

/datum/unit_test/language_key_conflicts/Run()
	var/list/used_keys = list()
	for(var/datum/language/language as anything in subtypesof(/datum/language))
		var/name = language::name
		var/key = language::key
		if(!key)
			continue
		if(used_keys[key])
			var/datum/language/conflicting_language = used_keys[key]
			TEST_FAIL("[name] ([language]) uses the '[key]' prefix, which is also used by [conflicting_language::name] ([conflicting_language])!")
		else
			used_keys[key] = language
