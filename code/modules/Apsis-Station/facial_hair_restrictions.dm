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

// Hair beyond shoulder length restricted for helmet purposes.
// Hair tied up is still restricted.

/datum/sprite_accessory/hair/bedheadfloorlength
	lore_banned = TRUE //the most egregious offender

/datum/sprite_accessory/hair/afro_huge
	lore_banned = TRUE

/datum/sprite_accessory/hair/allthefuzz
	lore_banned = TRUE

/datum/sprite_accessory/hair/antenna
	lore_banned = TRUE

/datum/sprite_accessory/hair/bedheadlong
	lore_banned = TRUE

/datum/sprite_accessory/hair/bedhead2
	lore_banned = TRUE

/datum/sprite_accessory/hair/badlycut
	lore_banned = TRUE

/datum/sprite_accessory/hair/beehive
	lore_banned = TRUE

/datum/sprite_accessory/hair/beehive2
	lore_banned = TRUE

/datum/sprite_accessory/hair/braid
	lore_banned = TRUE

/datum/sprite_accessory/hair/braided
	lore_banned = TRUE

/datum/sprite_accessory/hair/front_braid
	lore_banned = TRUE

/datum/sprite_accessory/hair/not_floorlength_braid
	lore_banned = TRUE

/datum/sprite_accessory/hair/lowbraid
	lore_banned = TRUE

/datum/sprite_accessory/hair/shortbraid
	lore_banned = TRUE

/datum/sprite_accessory/hair/braidtail
	lore_banned = TRUE

/datum/sprite_accessory/hair/cornrows2
	lore_banned = TRUE

/datum/sprite_accessory/hair/cornrowbraid
	lore_banned = TRUE

/datum/sprite_accessory/hair/cornrowdualtail
	lore_banned = TRUE

/datum/sprite_accessory/hair/doublebun
	lore_banned = TRUE

/datum/sprite_accessory/hair/dreadlocks
	lore_banned = TRUE

/datum/sprite_accessory/hair/drillhair
	lore_banned = TRUE

/datum/sprite_accessory/hair/drillhairextended
	lore_banned = TRUE

/datum/sprite_accessory/hair/flair
	lore_banned = TRUE

/datum/sprite_accessory/hair/gentle
	lore_banned = TRUE

/datum/sprite_accessory/hair/halfshaved
	lore_banned = TRUE

/datum/sprite_accessory/hair/himecut
	lore_banned = TRUE

/datum/sprite_accessory/hair/himecut2
	lore_banned = TRUE

/datum/sprite_accessory/hair/shorthime
	lore_banned = TRUE

/datum/sprite_accessory/hair/himeup
	lore_banned = TRUE

/datum/sprite_accessory/hair/jade
	lore_banned = TRUE

/datum/sprite_accessory/hair/kusangi
	lore_banned = TRUE

/datum/sprite_accessory/hair/long
	lore_banned = TRUE

/datum/sprite_accessory/hair/long2
	lore_banned = TRUE

/datum/sprite_accessory/hair/long3
	lore_banned = TRUE

/datum/sprite_accessory/hair/long_over_eye
	lore_banned = TRUE

/datum/sprite_accessory/hair/longbangs
	lore_banned = TRUE

/datum/sprite_accessory/hair/longemo
	lore_banned = TRUE

/datum/sprite_accessory/hair/longfringe
	lore_banned = TRUE

/datum/sprite_accessory/hair/sidepartlongalt
	lore_banned = TRUE

/datum/sprite_accessory/hair/messy
	lore_banned = TRUE

/datum/sprite_accessory/hair/modern
	lore_banned = TRUE

/datum/sprite_accessory/hair/nitori
	lore_banned = TRUE

/datum/sprite_accessory/hair/odango
	lore_banned = TRUE

/datum/sprite_accessory/hair/oneshoulder
	lore_banned = TRUE

/datum/sprite_accessory/hair/over_eye
	lore_banned = TRUE

/datum/sprite_accessory/hair/hair_overeyetwo
	lore_banned = TRUE

/datum/sprite_accessory/hair/kagami
	lore_banned = TRUE

/datum/sprite_accessory/hair/pigtail
	lore_banned = TRUE

/datum/sprite_accessory/hair/pigtail2
	lore_banned = TRUE

/datum/sprite_accessory/hair/ponytail2
	lore_banned = TRUE

/datum/sprite_accessory/hair/ponytail3
	lore_banned = TRUE

/datum/sprite_accessory/hair/ponytail4
	lore_banned = TRUE

/datum/sprite_accessory/hair/ponytail5
	lore_banned = TRUE

/datum/sprite_accessory/hair/ponytail6
	lore_banned = TRUE

/datum/sprite_accessory/hair/ponytail7
	lore_banned = TRUE

/datum/sprite_accessory/hair/highponytail
	lore_banned = TRUE

/datum/sprite_accessory/hair/stail
	lore_banned = TRUE

/datum/sprite_accessory/hair/longponytail
	lore_banned = TRUE

/datum/sprite_accessory/hair/countryponytail
	lore_banned = TRUE

/datum/sprite_accessory/hair/fringetail
	lore_banned = TRUE

/datum/sprite_accessory/hair/sidetail
	lore_banned = TRUE

/datum/sprite_accessory/hair/sidetail2
	lore_banned = TRUE

/datum/sprite_accessory/hair/sidetail3
	lore_banned = TRUE

/datum/sprite_accessory/hair/sidetail4
	lore_banned = TRUE

/datum/sprite_accessory/hair/spikyponytail
	lore_banned = TRUE

/datum/sprite_accessory/hair/poofy
	lore_banned = TRUE

/datum/sprite_accessory/hair/shortbangs2
	lore_banned = TRUE

/datum/sprite_accessory/hair/shorthaireighties
	lore_banned = TRUE

/datum/sprite_accessory/hair/sidecut
	lore_banned = TRUE

/datum/sprite_accessory/hair/tressshoulder
	lore_banned = TRUE

/datum/sprite_accessory/hair/twintails
	lore_banned = TRUE

/datum/sprite_accessory/hair/unkept
	lore_banned = TRUE

/datum/sprite_accessory/hair/updo
	lore_banned = TRUE

/datum/sprite_accessory/hair/longer
	lore_banned = TRUE

/datum/sprite_accessory/hair/longest
	lore_banned = TRUE

/datum/sprite_accessory/hair/longest2
	lore_banned = TRUE

/datum/sprite_accessory/hair/longestalt
	lore_banned = TRUE

/datum/sprite_accessory/hair/volaju
	lore_banned = TRUE

/datum/sprite_accessory/hair/wisp
	lore_banned = TRUE

/datum/sprite_accessory/hair/ziegler
	lore_banned = TRUE

// Facial hair that breaks mask seals are disallowed.

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

/datum/sprite_accessory/facial_hair/smallstache
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/walrus
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/fu
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/watson
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/vandyke
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/handlebar
	lore_banned = TRUE

/datum/sprite_accessory/facial_hair/handlebar2
	lore_banned = TRUE

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

