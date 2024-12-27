/datum/asset/spritesheet/simple/achievements
	name = "achievements"

/datum/asset/spritesheet/simple/achievements/create_spritesheets()
	InsertAll("achievement", ACHIEVEMENTS_SET)
	// catch achievements which are pulling icons from another file
	for(var/datum/award/other_award as anything in subtypesof(/datum/award))
		var/icon = initial(other_award.icon)
		if (icon != ACHIEVEMENTS_SET)
			var/icon_state = initial(other_award.icon_state)
			Insert("achievement-[icon_state]", icon, icon_state=icon_state)
