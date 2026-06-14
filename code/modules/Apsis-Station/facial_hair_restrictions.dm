// Apsis-Station DOWNSTREAM - hair lore restrictions
// Styles marked lore_banned = TRUE will be hidden in TGUI and reset to None on spawn
// Reason: NT safety regs prohibit facial hair that obstructs o2 mask seals and helmets

/datum/sprite_accessory
	/// Apsis-Station: If TRUE, banned server-wide for o2 seal / helmet lore reasons
	var/lore_banned = FALSE

// ============================================================
// FLAG BANNED STYLES HERE
// Check exact subtype names in:
// code/datums/sprite_accessories.dm
// ============================================================

/datum/sprite_accessory/hair/bedheadfloorlength
	lore_banned = TRUE

/datum/sprite_accessory/hair/afro_huge
	lore_banned = TRUE

/datum/sprite_accessory/hair/antenna
	lore_banned = TRUE

/datum/sprite_accessory/hair/bedheadlong
	lore_banned = TRUE

/datum/sprite_accessory/hair/braid
	lore_banned = TRUE

/datum/sprite_accessory/hair/braided
	lore_banned = TRUE

/datum/sprite_accessory/hair/shortbraid
	lore_banned = TRUE

/datum/sprite_accessory/hair/long
	lore_banned = TRUE

/datum/sprite_accessory/hair/long2
	lore_banned = TRUE

/datum/sprite_accessory/hair/long3
	lore_banned = TRUE

/datum/sprite_accessory/hair/long_over_eye
	lore_banned = TRUE

/datum/sprite_accessory/hair/modern
	lore_banned = TRUE

/datum/sprite_accessory/hair/longest
	lore_banned = TRUE

/datum/sprite_accessory/hair/longest2
	lore_banned = TRUE

/datum/sprite_accessory/hair/ponytail5
	lore_banned = TRUE

/datum/sprite_accessory/hair/longponytail
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/abe
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/brokenman
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/chinstrap
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/dwarf
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/fullbeard
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/croppedfullbeard
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/gt
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/hip
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/jensen
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/neckbeard
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/vlongbeard
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/muttonmus
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/martialartist
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/chinlessbeard
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/moonshiner
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/longbeard
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/volaju
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/fiveoclock
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/moustache
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/pencilstache
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/smallstache
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/vandyke
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/watson
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/handlebar
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/handlebar2
	lore_banned = TRUE

// Add or remove styles to taste. Stubble/moustache/goatee left allowed
// as they don't break mask seal.

// Removes lore_banned styles after SSaccessories populates its lists
/datum/controller/subsystem/accessories/PreInit()
	. = ..()
	remove_lore_banned_styles()

/datum/controller/subsystem/accessories/proc/remove_lore_banned_styles()
	for(var/style_name in hairstyles_list)
		var/datum/sprite_accessory/style = hairstyles_list[style_name]
		if(style?.lore_banned)
			hairstyles_list.Remove(style_name)
			hairstyles_male_list?.Remove(style_name)
			hairstyles_female_list?.Remove(style_name)

	for(var/style_name in facial_hairstyles_list)
		var/datum/sprite_accessory/style = facial_hairstyles_list[style_name]
		if(style?.lore_banned)
			facial_hairstyles_list.Remove(style_name)
			facial_hairstyles_male_list?.Remove(style_name)
			facial_hairstyles_female_list?.Remove(style_name)

