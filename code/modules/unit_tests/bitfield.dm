/// Detects duplicate bitfield definitions
/datum/unit_test/bitfield_dupes

/datum/unit_test/bitfield_dupes/Run()
	for (var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		var/list/sources = bitfield.return_sources()
		if(length(sources) == 1)
			continue
		var/list/error = list()
		for(var/list/source as anything in sources)
			error += "Instance found in [source[1]] around line [source[2]]"
		var/error_text = "Duplicate definitions of the [bitfield.variable] bitfield macro detected:\n[error.Join("\n")]"
		TEST_FAIL(error_text)
