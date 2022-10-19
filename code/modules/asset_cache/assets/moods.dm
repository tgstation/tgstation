/datum/asset/spritesheet/moods
	name = "moods"
	var/iconinserted = 1

/datum/asset/spritesheet/moods/create_spritesheets()
	for(var/i in 1 to 9)
		var/target_to_insert = "mood"+"[iconinserted]"
		Insert(target_to_insert, 'icons/hud/screen_gen.dmi', target_to_insert)
		iconinserted++

/datum/asset/spritesheet/moods/ModifyInserted(icon/pre_asset)
	var/blended_color
	switch(iconinserted)
		if(1)
			blended_color = "#f15d36"
		if(2 to 3)
			blended_color = "#f38943"
		if(4)
			blended_color = "#dfa65b"
		if(5)
			blended_color = "#4b96c4"
		if(6)
			blended_color = "#86d656"
		else
			blended_color = "#2eeb9a"
	pre_asset.Blend(blended_color, ICON_MULTIPLY)
	return pre_asset
