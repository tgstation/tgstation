/datum/asset/spritesheet/emoji
	name = "emoji"
	cross_round_cachable = TRUE // The Emoji DMI is static and doesn't change without a commit mis-match.

/datum/asset/spritesheet/emoji/create_spritesheets()
	InsertAll("", EMOJI_SET)

