/datum/asset/spritesheet/emojipedia
	name = "emojipedia"
	cross_round_cachable = TRUE // The Emoji DMI is static and doesn't change without a commit mis-match.

/datum/asset/spritesheet/emojipedia/create_spritesheets()
	InsertAll("", EMOJI_SET)

