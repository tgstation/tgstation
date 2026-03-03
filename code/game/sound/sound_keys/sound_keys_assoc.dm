/// subtype that accepts weighted lists
/datum/sound_effect/assoc

/datum/sound_effect/assoc/return_sfx()
	return pick_weight(file_paths)

/datum/sound_effect/assoc/plate_armor_rustle
	key = SFX_PLATE_ARMOR_RUSTLE
	file_paths = list(
		'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle1.ogg' = 8, //longest sound is rarer.
		'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle2.ogg' = 23,
		'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle3.ogg' = 23,
		'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle4.ogg' = 23,
		'sound/items/handling/armor_rustle/plate_armor/plate_armor_rustle5.ogg' = 23,
	)

/datum/sound_effect/assoc/snore_female
	key = SFX_SNORE_FEMALE
	file_paths = list(
		'sound/mobs/humanoids/human/snore/snore_female1.ogg' = 33,
		'sound/mobs/humanoids/human/snore/snore_female2.ogg' = 33,
		'sound/mobs/humanoids/human/snore/snore_female3.ogg' = 33,
		'sound/mobs/humanoids/human/snore/snore_mimimi1.ogg' = 1,
	)

/datum/sound_effect/assoc/snore_male
	key = SFX_SNORE_MALE
	file_paths = list(
		'sound/mobs/humanoids/human/snore/snore_male1.ogg' = 20,
		'sound/mobs/humanoids/human/snore/snore_male2.ogg' = 20,
		'sound/mobs/humanoids/human/snore/snore_male3.ogg' = 20,
		'sound/mobs/humanoids/human/snore/snore_male4.ogg' = 20,
		'sound/mobs/humanoids/human/snore/snore_male5.ogg' = 20,
		'sound/mobs/humanoids/human/snore/snore_mimimi2.ogg' = 1,
	)

/datum/sound_effect/assoc/cat_meow
	key = SFX_CAT_MEOW
	file_paths = list(
		'sound/mobs/non-humanoids/cat/cat_meow1.ogg' = 33,
		'sound/mobs/non-humanoids/cat/cat_meow2.ogg' = 33,
		'sound/mobs/non-humanoids/cat/cat_meow3.ogg' = 33,
		'sound/mobs/non-humanoids/cat/oranges_meow1.ogg' = 1,
	)
