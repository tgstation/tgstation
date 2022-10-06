///Checks if spritesheet assets contain icon states with invalid names
/datum/unit_test/spritesheets

/datum/unit_test/spritesheets/Run()
	for(var/spritesheet_type in subtypesof(/datum/asset/spritesheet))
		var/datum/asset/spritesheet/sheet = get_asset_datum(spritesheet_type)
		for(var/sprite_name in sheet.sprites)
			if(!sprite_name)
				TEST_FAIL("Spritesheet [spritesheet_type] has a nameless icon state.")
			if(!sprite_name)
				TEST_FAIL("Spritesheet [spritesheet_type] has a nameless icon state.")
