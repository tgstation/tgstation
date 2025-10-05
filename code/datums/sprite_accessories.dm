/*
 *	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
 *	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
 *	intended to be friendly for people with little to no actual coding experience.
 *	The process of adding in new hairstyles has been made pain-free and easy to do.
 *	Enjoy! - Doohl
 *
 *
 *	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
 *	have to define any UI values for sprite accessories manually for hair and facial
 *	hair. Just add in new hair types and the game will naturally adapt.
 *
 *	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
 *	to the point where you may completely corrupt a server's savefiles. Please refrain
 *	from doing this unless you absolutely know what you are doing, and have defined a
 *	conversion in savefile.dm
 */

/datum/sprite_accessory
	/// The icon file the accessory is located in.
	var/icon
	/// The icon_state of the accessory.
	var/icon_state
	/// The preview name of the accessory.
	var/name
	/// Determines if the accessory will be skipped or included in random hair generations.
	var/gender = NEUTER
	/// Something that can be worn by either gender, but looks different on each.
	var/gender_specific = FALSE
	/// Determines if the accessory will be skipped by color preferences.
	var/use_static
	/**
	 * Currently only used by mutantparts so don't worry about hair and stuff.
	 * This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	 */
	var/color_src = MUTANT_COLOR
	/// Is this part locked from roundstart selection? Used for parts that apply effects.
	var/locked = FALSE
	/// Should we center the sprite?
	var/center = FALSE
	/// The width of the sprite in pixels. Used to center it if necessary.
	var/dimension_x = 32
	/// The height of the sprite in pixels. Used to center it if necessary.
	var/dimension_y = 32
	/// Should this sprite block emissives?
	var/em_block = FALSE
	/// Determines if this is considered "sane" for the purpose of [/proc/randomize_human_normie]
	/// Basically this is to blacklist the extremely wacky stuff from being picked in random human generation.
	var/natural_spawn = TRUE

/datum/sprite_accessory/blank
	name = SPRITE_ACCESSORY_NONE
	icon_state = "None"

////////////////
// Hair Masks //
////////////////

/datum/hair_mask
	var/icon/icon = 'icons/mob/human/hair_masks.dmi'
	var/icon_state = ""
	/// Strict coverage zones will always have the hair mask applied to them, even if a piece of hair at that location would normally resist being masked.
	/// If a piece of headware only covers the top of the head, it should only strictly cover the top zone. But a mostly-enclosed helmet might strictly cover almost all zones.
	var/strict_coverage_zones = NONE

/datum/hair_mask/standard_hat_middle
	icon_state = "hide_above_45deg"
	strict_coverage_zones = HAIR_APPENDAGE_TOP

/datum/hair_mask/standard_hat_low
	icon_state = "hide_above_45deg_low"
	strict_coverage_zones = HAIR_APPENDAGE_TOP | HAIR_APPENDAGE_LEFT | HAIR_APPENDAGE_RIGHT | HAIR_APPENDAGE_REAR

/datum/hair_mask/winterhood
	icon_state = "hide_winterhood"
	strict_coverage_zones = HAIR_APPENDAGE_TOP | HAIR_APPENDAGE_LEFT | HAIR_APPENDAGE_RIGHT | HAIR_APPENDAGE_REAR | HAIR_APPENDAGE_HANGING_REAR

//////////////////////
// Hair Definitions //
//////////////////////
// Cache of each hairstyle's icon after being blended with the given masks
// "joined mask types" is each mask's type as a string joined by commas (for no masks, it is the empty string)
// /datum/sprite_accessory/hair path -> list(joined mask types -> icon)
GLOBAL_LIST_EMPTY(blended_hair_icons_cache)

/datum/sprite_accessory/hair
	icon = 'icons/mob/human/human_face.dmi'   // default icon for all hairs
	var/y_offset = 0 // Y offset to apply so we can have hair that reaches above the player sprite's visual bounding box

	// Some hair will have "appendages", such as pony tails, that stick out from certain parts of the head. These can be layered above or below headwear and resist being masked away by hair masks.
	// Lists should be icon_state strings associated with the HAIR_APPENDAGE defines specifying the part of the head they stick out from.
	// hair_appendages_inner contains icon_states that go in the normal hair layer, hair_appendages_outer contains icon_states that go above the layer for headwear.
	// hair_appendages_inner will be masked normally if their HAIR_APPENDAGE zone is strictly masked by a piece of clothing (a fully enclosed helmet with a transparent visor will strictly mask all zones, a small hat will only strictly mask the top, etc.).
	// hair_appendages_outer will never be masked at all and will just not be shown if their zone has strict masking. These should generally not have visible sprites for every dir.
	var/list/hair_appendages_inner = null
	var/list/hair_appendages_outer = null

/// Retrieve the base hair icon with all hair appendeges blended in, with hair masks applied, from the cache, or generate it if it doesn't exist
/datum/sprite_accessory/hair/proc/getCachedIcon(list/hair_masks)
	var/icon/cachedIcon
	var/joinedMasks = LAZYLEN(hair_masks) ? jointext(hair_masks, ",") : ""
	var/list/masks_to_icons = GLOB.blended_hair_icons_cache[type]
	if(!masks_to_icons)
		GLOB.blended_hair_icons_cache[type] = list()
	else
		cachedIcon = masks_to_icons[joinedMasks]

	if(!cachedIcon)
		if(LAZYLEN(hair_masks))
			if(LAZYLEN(hair_appendages_inner))
				// Check if there are any hair appendages in a zone that is not strictly masked
				var/found_mask_dodger = FALSE
				for(var/datum/hair_mask/mask as anything in hair_masks)
					for(var/appendage in hair_appendages_inner)
						var/zone = hair_appendages_inner[appendage]
						if(!(zone & mask.strict_coverage_zones))
							found_mask_dodger = TRUE

				if(found_mask_dodger)
					// We have to process each icon individually
					cachedIcon = icon(icon, icon_state)
					// mask the base icon
					for(var/datum/hair_mask/mask as anything in hair_masks)
						var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
						mask_icon.Shift(SOUTH, y_offset)
						cachedIcon.Blend(mask_icon, ICON_ADD)

					// mask the appendages if required and add them to the base icon
					for(var/appendage_icon_state in hair_appendages_inner)
						var/icon/appendage_icon = icon(icon, appendage_icon_state)
						var/zone = hair_appendages_inner[appendage_icon_state]
						for(var/datum/hair_mask/mask as anything in hair_masks)
							if(zone & mask.strict_coverage_zones)
								var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
								mask_icon.Shift(SOUTH, y_offset)
								appendage_icon.Blend(mask_icon, ICON_ADD)
						cachedIcon.Blend(appendage_icon, ICON_OVERLAY)
				else
					// No mask dodgers, so we can just mask the full (hopefully cached) icon
					cachedIcon = icon(getCachedIcon())
					for(var/datum/hair_mask/mask as anything in hair_masks)
						var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
						mask_icon.Shift(SOUTH, y_offset)
						cachedIcon.Blend(mask_icon, ICON_ADD)
			else
				// No hair appendages, so just apply all hair masks to the base icon
				cachedIcon = icon(icon, icon_state)
				for(var/datum/hair_mask/mask as anything in hair_masks)
					var/icon/mask_icon = icon('icons/mob/human/hair_masks.dmi', mask.icon_state)
					mask_icon.Shift(SOUTH, y_offset)
					cachedIcon.Blend(mask_icon, ICON_ADD)
		else
			// no hair masks
			cachedIcon = icon(icon, icon_state)
			if(LAZYLEN(hair_appendages_inner))
				for(var/appendage_icon_state in hair_appendages_inner)
					var/icon/appendage_icon = icon(icon, appendage_icon_state)
					cachedIcon.Blend(appendage_icon, ICON_OVERLAY)
		// set cache
		GLOB.blended_hair_icons_cache[type][joinedMasks] = cachedIcon
	return cachedIcon


// please make sure they're sorted alphabetically and, where needed, categorized
// try to capitalize the names please~
// try to spell
// you do not need to define _s or _l sub-states, game automatically does this for you

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Afro (Large)"
	icon_state = "hair_bigafro"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/afro_huge
	name = "Afro (Huge)"
	icon_state = "hair_hugeafro"
	y_offset = 6
	natural_spawn = FALSE

/datum/sprite_accessory/hair/allthefuzz
	name = "All The Fuzz"
	icon_state = "hair_allthefuzz"

/datum/sprite_accessory/hair/antenna
	name = "Ahoge"
	icon_state = "hair_antenna"
	hair_appendages_inner = list("hair_antenna_a1" = HAIR_APPENDAGE_TOP)

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = null

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/bedheadv4
	name = "Bedhead 4x"
	icon_state = "hair_bedheadv4"

/datum/sprite_accessory/hair/bedheadlong
	name = "Long Bedhead"
	icon_state = "hair_long_bedhead"

/datum/sprite_accessory/hair/bedheadfloorlength
	name = "Floorlength Bedhead"
	icon_state = "hair_floorlength_bedhead"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/badlycut
	name = "Shorter Long Bedhead"
	icon_state = "hair_verybadlycut"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "hair_beehivev2"

/datum/sprite_accessory/hair/bob
	name = "Bob Hair"
	icon_state = "hair_bob"

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_bob2"

/datum/sprite_accessory/hair/bob3
	name = "Bob Hair 3"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bob4
	name = "Bob Hair 4"
	icon_state = "hair_bob4"

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/boddicker
	name = "Boddicker"
	icon_state = "hair_boddicker"

/datum/sprite_accessory/hair/bowlcut
	name = "Bowlcut"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/bowlcut2
	name = "Bowlcut 2"
	icon_state = "hair_bowlcut2"

/datum/sprite_accessory/hair/braid
	name = "Braid (Floorlength)"
	icon_state = "hair_braid"
	hair_appendages_inner = list("hair_braid_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_braid_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/braided
	name = "Braided"
	icon_state = "hair_braided"

/datum/sprite_accessory/hair/front_braid
	name = "Braided Front"
	icon_state = "hair_braidfront"
	hair_appendages_inner = list("hair_braidfront_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_braidfront_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/not_floorlength_braid
	name = "Braid (High)"
	icon_state = "hair_braid2"
	hair_appendages_inner = list("hair_braid2_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_braid2_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/lowbraid
	name = "Braid (Low)"
	icon_state = "hair_hbraid"

/datum/sprite_accessory/hair/shortbraid
	name = "Braid (Short)"
	icon_state = "hair_shortbraid"
	hair_appendages_inner = list("hair_shortbraid_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_shortbraid_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/braidtail
	name = "Braided Tail"
	icon_state = "hair_braidtail"
	hair_appendages_inner = list("hair_braidtail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_braidtail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/bun
	name = "Bun Head"
	icon_state = "hair_bun"

/datum/sprite_accessory/hair/bun2
	name = "Bun Head 2"
	icon_state = "hair_bunhead2"
	hair_appendages_inner = list("hair_bunhead2_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_bunhead2_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/bun3
	name = "Bun Head 3"
	icon_state = "hair_bun3"

/datum/sprite_accessory/hair/largebun
	name = "Bun (Large)"
	icon_state = "hair_largebun"

/datum/sprite_accessory/hair/manbun
	name = "Bun (Manbun)"
	icon_state = "hair_manbun"
	hair_appendages_inner = list("hair_manbun_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_manbun_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/tightbun
	name = "Bun (Tight)"
	icon_state = "hair_tightbun"

/datum/sprite_accessory/hair/business
	name = "Business Hair"
	icon_state = "hair_business"

/datum/sprite_accessory/hair/business2
	name = "Business Hair 2"
	icon_state = "hair_business2"

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "hair_business3"

/datum/sprite_accessory/hair/business4
	name = "Business Hair 4"
	icon_state = "hair_business4"

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/chinbob
	name = "Chin-Length Bob Cut"
	icon_state = "hair_chinbob"

/datum/sprite_accessory/hair/comet
	name = "Comet"
	icon_state = "hair_comet"

/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "hair_cia"

/datum/sprite_accessory/hair/coffeehouse
	name = "Coffee House"
	icon_state = "hair_coffeehouse"

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/cornrows1
	name = "Cornrows"
	icon_state = "hair_cornrows"

/datum/sprite_accessory/hair/cornrows2
	name = "Cornrows 2"
	icon_state = "hair_cornrows2"

/datum/sprite_accessory/hair/cornrowbun
	name = "Cornrow Bun"
	icon_state = "hair_cornrowbun"

/datum/sprite_accessory/hair/cornrowbraid
	name = "Cornrow Braid"
	icon_state = "hair_cornrowbraid"

/datum/sprite_accessory/hair/cornrowdualtail
	name = "Cornrow Tail"
	icon_state = "hair_cornrowtail"
	hair_appendages_inner = list("hair_cornrowtail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_cornrowtail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/dandpompadour
	name = "Dandy Pompadour"
	icon_state = "hair_dandypompadour"

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/doublebun
	name = "Double Bun"
	icon_state = "hair_doublebun"
	hair_appendages_inner = list("hair_doublebun_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_doublebun_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/drillhair
	name = "Drillruru"
	icon_state = "hair_drillruru"
	hair_appendages_inner = list("hair_drillruru_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_drillruru_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/drillhairextended
	name = "Drill Hair (Extended)"
	icon_state = "hair_drillhairextended"
	hair_appendages_inner = list("hair_drillhairextended_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_drillhairextended_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/emofrine
	name = "Emo Fringe"
	icon_state = "hair_emofringe"

/datum/sprite_accessory/hair/nofade
	name = "Fade (None)"
	icon_state = "hair_nofade"

/datum/sprite_accessory/hair/highfade
	name = "Fade (High)"
	icon_state = "hair_highfade"

/datum/sprite_accessory/hair/medfade
	name = "Fade (Medium)"
	icon_state = "hair_medfade"

/datum/sprite_accessory/hair/lowfade
	name = "Fade (Low)"
	icon_state = "hair_lowfade"

/datum/sprite_accessory/hair/baldfade
	name = "Fade (Bald)"
	icon_state = "hair_baldfade"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "hair_father"

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/flair
	name = "Flair"
	icon_state = "hair_flair"

/datum/sprite_accessory/hair/bigflattop
	name = "Flat Top (Big)"
	icon_state = "hair_bigflattop"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/flow_hair
	name = "Flow Hair"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbang2
	name = "Half-banged Hair 2"
	icon_state = "hair_halfbang2"

/datum/sprite_accessory/hair/halfshaved
	name = "Half-shaved"
	icon_state = "hair_halfshaved"

/datum/sprite_accessory/hair/hedgehog
	name = "Hedgehog Hair"
	icon_state = "hair_hedgehog"

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"

/datum/sprite_accessory/hair/himecut2
	name = "Hime Cut 2"
	icon_state = "hair_himecut2"

/datum/sprite_accessory/hair/shorthime
	name = "Hime Cut (Short)"
	icon_state = "hair_shorthime"

/datum/sprite_accessory/hair/himeup
	name = "Hime Updo"
	icon_state = "hair_himeup"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/jade
	name = "Jade"
	icon_state = "hair_jade"

/datum/sprite_accessory/hair/jensen
	name = "Jensen Hair"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/joestar
	name = "Joestar"
	icon_state = "hair_joestar"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_keanu"

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/long
	name = "Long Hair 1"
	icon_state = "hair_long"
	hair_appendages_inner = list("hair_long_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long2
	name = "Long Hair 2"
	icon_state = "hair_long2"
	hair_appendages_inner = list("hair_long2_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long3
	name = "Long Hair 3"
	icon_state = "hair_long3"
	hair_appendages_inner = list("hair_long3_a1" = HAIR_APPENDAGE_HANGING_REAR)

/datum/sprite_accessory/hair/long_over_eye
	name = "Long Over Eye"
	icon_state = "hair_longovereye"

/datum/sprite_accessory/hair/longbangs
	name = "Long Bangs"
	icon_state = "hair_lbangs"

/datum/sprite_accessory/hair/longemo
	name = "Long Emo"
	icon_state = "hair_longemo"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/sidepartlongalt
	name = "Long Side Part"
	icon_state = "hair_longsidepart"
	hair_appendages_inner = list("hair_longsidepart_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_longsidepart_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/megaeyebrows
	name = "Mega Eyebrows"
	icon_state = "hair_megaeyebrows"

/datum/sprite_accessory/hair/messy
	name = "Messy"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "hair_modern"

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"
	natural_spawn = FALSE // sorry little one

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "hair_nitori"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/reversemohawk
	name = "Mohawk (Reverse)"
	icon_state = "hair_reversemohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/shavedmohawk
	name = "Mohawk (Shaved)"
	icon_state = "hair_shavedmohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/unshavenmohawk
	name = "Mohawk (Unshaven)"
	icon_state = "hair_unshaven_mohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "hair_mulder"

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/over_eye
	name = "Over Eye"
	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/hair_overeyetwo
	name = "Over Eye 2"
	icon_state = "hair_overeyetwo"

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/partedside
	name = "Parted (Side)"
	icon_state = "hair_part"

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pigtail
	name = "Pigtails 2"
	icon_state = "hair_pigtails"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pigtail2
	name = "Pigtails 3"
	icon_state = "hair_pigtails2"
	natural_spawn = FALSE
	hair_appendages_inner = list("hair_pigtails2_a1" = HAIR_APPENDAGE_LEFT, "hair_pigtails2_a2" = HAIR_APPENDAGE_RIGHT)

/datum/sprite_accessory/hair/pixie
	name = "Pixie Cut"
	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/bigpompadour
	name = "Pompadour (Big)"
	icon_state = "hair_bigpompadour"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"
	hair_appendages_inner = list("hair_ponytail4_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail4_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"
	hair_appendages_inner = list("hair_ponytail5_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_ponytail5_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail 6"
	icon_state = "hair_ponytail6"
	hair_appendages_inner = list("hair_ponytail6_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail6_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ponytail7
	name = "Ponytail 7"
	icon_state = "hair_ponytail7"
	hair_appendages_inner = list("hair_ponytail7_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ponytail7_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/highponytail
	name = "Ponytail (High)"
	icon_state = "hair_highponytail"
	hair_appendages_inner = list("hair_highponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_highponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/stail
	name = "Ponytail (Short)"
	icon_state = "hair_stail"
	hair_appendages_inner = list("hair_stail_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_stail_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/longponytail
	name = "Ponytail (Long)"
	icon_state = "hair_longstraightponytail"
	hair_appendages_inner = list("hair_longstraightponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_longstraightponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/countryponytail
	name = "Ponytail (Country)"
	icon_state = "hair_country"
	hair_appendages_inner = list("hair_country_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_country_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/fringetail
	name = "Ponytail (Fringe)"
	icon_state = "hair_fringetail"

/datum/sprite_accessory/hair/sidetail
	name = "Ponytail (Side)"
	icon_state = "hair_sidetail"

/datum/sprite_accessory/hair/sidetail2
	name = "Ponytail (Side) 2"
	icon_state = "hair_sidetail2"

/datum/sprite_accessory/hair/sidetail3
	name = "Ponytail (Side) 3"
	icon_state = "hair_sidetail3"
	hair_appendages_inner = list("hair_sidetail3_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_sidetail3_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/sidetail4
	name = "Ponytail (Side) 4"
	icon_state = "hair_sidetail4"
	hair_appendages_inner = list("hair_sidetail4_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_sidetail4_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/spikyponytail
	name = "Ponytail (Spiky)"
	icon_state = "hair_spikyponytail"
	hair_appendages_inner = list("hair_spikyponytail_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_spikyponytail_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/poofy
	name = "Poofy"
	icon_state = "hair_poofy"

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "hair_ronin"

/datum/sprite_accessory/hair/shaved
	name = "Shaved"
	icon_state = "hair_shaved"

/datum/sprite_accessory/hair/shavedpart
	name = "Shaved Part"
	icon_state = "hair_shavedpart"

/datum/sprite_accessory/hair/shortbangs
	name = "Short Bangs"
	icon_state = "hair_shortbangs"

/datum/sprite_accessory/hair/shortbangs2
	name = "Short Bangs 2"
	icon_state = "hair_shortbangs2"

/datum/sprite_accessory/hair/short
	name = "Short Hair"
	icon_state = "hair_a"

/datum/sprite_accessory/hair/shorthair2
	name = "Short Hair 2"
	icon_state = "hair_shorthair2"

/datum/sprite_accessory/hair/shorthair3
	name = "Short Hair 3"
	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/shorthair4
	name = "Short Hair 4"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/shorthair5
	name = "Short Hair 5"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/shorthair6
	name = "Short Hair 6"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/shorthair7
	name = "Short Hair 7"
	icon_state = "hair_shorthairg"

/datum/sprite_accessory/hair/shorthaireighties
	name = "Short Hair 80s"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/rosa
	name = "Short Hair Rosa"
	icon_state = "hair_rosa"

/datum/sprite_accessory/hair/shoulderlength
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/sidecut
	name = "Sidecut"
	icon_state = "hair_sidecut"

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/protagonist
	name = "Slightly Long Hair"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/spiky2
	name = "Spiky 2"
	icon_state = "hair_spiky"

/datum/sprite_accessory/hair/spiky3
	name = "Spiky 3"
	icon_state = "hair_spiky2"

/datum/sprite_accessory/hair/swept
	name = "Swept Back Hair"
	icon_state = "hair_swept"

/datum/sprite_accessory/hair/swept2
	name = "Swept Back Hair 2"
	icon_state = "hair_swept2"

/datum/sprite_accessory/hair/thinning
	name = "Thinning"
	icon_state = "hair_thinning"

/datum/sprite_accessory/hair/thinningfront
	name = "Thinning (Front)"
	icon_state = "hair_thinningfront"

/datum/sprite_accessory/hair/thinningrear
	name = "Thinning (Rear)"
	icon_state = "hair_thinningrear"

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "hair_topknot"

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"
	hair_appendages_inner = list("hair_tressshoulder_a1" = HAIR_APPENDAGE_HANGING_FRONT)
	hair_appendages_outer = list("hair_tressshoulder_a1o" = HAIR_APPENDAGE_HANGING_FRONT)

/datum/sprite_accessory/hair/trimmed
	name = "Trimmed"
	icon_state = "hair_trimmed"

/datum/sprite_accessory/hair/trimflat
	name = "Trim Flat"
	icon_state = "hair_trimflat"

/datum/sprite_accessory/hair/twintails
	name = "Twintails"
	icon_state = "hair_twintail"

/datum/sprite_accessory/hair/undercut
	name = "Undercut"
	icon_state = "hair_undercut"

/datum/sprite_accessory/hair/undercutleft
	name = "Undercut Left"
	icon_state = "hair_undercutleft"

/datum/sprite_accessory/hair/undercutright
	name = "Undercut Right"
	icon_state = "hair_undercutright"

/datum/sprite_accessory/hair/unkept
	name = "Unkept"
	icon_state = "hair_unkept"

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"
	hair_appendages_inner = list("hair_updo_a1" = HAIR_APPENDAGE_TOP)

/datum/sprite_accessory/hair/longer
	name = "Very Long Hair"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair 2"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longest2
	name = "Very Long Over Eye"
	icon_state = "hair_longest2"

/datum/sprite_accessory/hair/veryshortovereye
	name = "Very Short Over Eye"
	icon_state = "hair_veryshortovereyealternate"

/datum/sprite_accessory/hair/longestalt
	name = "Very Long with Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/volaju
	name = "Volaju"
	icon_state = "hair_volaju"

/datum/sprite_accessory/hair/wisp
	name = "Wisp"
	icon_state = "hair_wisp"
	hair_appendages_inner = list("hair_wisp_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_wisp_a1o" = HAIR_APPENDAGE_REAR)

/datum/sprite_accessory/hair/ziegler
	name = "Ziegler"
	icon_state = "hair_ziegler"
	hair_appendages_inner = list("hair_ziegler_a1" = HAIR_APPENDAGE_REAR)
	hair_appendages_outer = list("hair_ziegler_a1o" = HAIR_APPENDAGE_REAR)

/*
/////////////////////////////////////
/  =---------------------------=    /
/  == Gradient Hair Definitions ==  /
/  =---------------------------=    /
/////////////////////////////////////
*/

/datum/sprite_accessory/gradient
	icon = 'icons/mob/human/species/hair_gradients.dmi'
	///whether this gradient applies to hair and/or beards. Some gradients do not work well on beards.
	var/gradient_category = GRADIENT_APPLIES_TO_HAIR|GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/gradient/full
	name = "Full"
	icon_state = "full"

/datum/sprite_accessory/gradient/fadeup
	name = "Fade Up"
	icon_state = "fadeup"

/datum/sprite_accessory/gradient/fadedown
	name = "Fade Down"
	icon_state = "fadedown"

/datum/sprite_accessory/gradient/vertical_split
	name = "Vertical Split"
	icon_state = "vsplit"

/datum/sprite_accessory/gradient/horizontal_split
	name = "Horizontal Split"
	icon_state = "bottomflat"

/datum/sprite_accessory/gradient/reflected
	name = "Reflected"
	icon_state = "reflected_high"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/reflected/beard
	icon_state = "reflected_high_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/reflected_inverse
	name = "Reflected Inverse"
	icon_state = "reflected_inverse_high"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/reflected_inverse/beard
	icon_state = "reflected_inverse_high_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/wavy
	name = "Wavy"
	icon_state = "wavy"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/long_fade_up
	name = "Long Fade Up"
	icon_state = "long_fade_up"

/datum/sprite_accessory/gradient/long_fade_down
	name = "Long Fade Down"
	icon_state = "long_fade_down"

/datum/sprite_accessory/gradient/short_fade_up
	name = "Short Fade Up"
	icon_state = "short_fade_up"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/short_fade_up/beard
	icon_state = "short_fade_down"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/short_fade_down
	name = "Short Fade Down"
	icon_state = "short_fade_down_beard"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/short_fade_down/beard
	icon_state = "short_fade_down_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/wavy_spike
	name = "Spiked Wavy"
	icon_state = "wavy_spiked"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/striped
	name = "striped"
	icon_state = "striped"

/datum/sprite_accessory/gradient/striped_vertical
	name = "Striped Vertical"
	icon_state = "striped_vertical"

/////////////////////////////
// Facial Hair Definitions //
/////////////////////////////

/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/human/human_face.dmi'
	gender = MALE // barf (unless you're a dorf, dorfs dig chix w/ beards :P)
	em_block = TRUE

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/facial_hair/abe
	name = "Beard (Abraham Lincoln)"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/brokenman
	name = "Beard (Broken Man)"
	icon_state = "facial_brokenman"
	natural_spawn = FALSE

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Beard (Chinstrap)"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Beard (Dwarf)"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Beard (Full)"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/croppedfullbeard
	name = "Beard (Cropped Fullbeard)"
	icon_state = "facial_croppedfullbeard"

/datum/sprite_accessory/facial_hair/gt
	name = "Beard (Goatee)"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/hip
	name = "Beard (Hipster)"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/jensen
	name = "Beard (Jensen)"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Beard (Neckbeard)"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Beard (Very Long)"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/muttonmus
	name = "Beard (Muttonmus)"
	icon_state = "facial_muttonmus"

/datum/sprite_accessory/facial_hair/martialartist
	name = "Beard (Martial Artist)"
	icon_state = "facial_martialartist"
	natural_spawn = FALSE

/datum/sprite_accessory/facial_hair/chinlessbeard
	name = "Beard (Chinless Beard)"
	icon_state = "facial_chinlessbeard"

/datum/sprite_accessory/facial_hair/moonshiner
	name = "Beard (Moonshiner)"
	icon_state = "facial_moonshiner"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Beard (Long)"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/volaju
	name = "Beard (Volaju)"
	icon_state = "facial_volaju"

/datum/sprite_accessory/facial_hair/threeoclock
	name = "Beard (Three o Clock Shadow)"
	icon_state = "facial_3oclock"

/datum/sprite_accessory/facial_hair/fiveoclock
	name = "Beard (Five o Clock Shadow)"
	icon_state = "facial_fiveoclock"

/datum/sprite_accessory/facial_hair/fiveoclockm
	name = "Beard (Five o Clock Moustache)"
	icon_state = "facial_5oclockmoustache"

/datum/sprite_accessory/facial_hair/sevenoclock
	name = "Beard (Seven o Clock Shadow)"
	icon_state = "facial_7oclock"

/datum/sprite_accessory/facial_hair/sevenoclockm
	name = "Beard (Seven o Clock Moustache)"
	icon_state = "facial_7oclockmoustache"

/datum/sprite_accessory/facial_hair/moustache
	name = "Moustache"
	icon_state = "facial_moustache"

/datum/sprite_accessory/facial_hair/pencilstache
	name = "Moustache (Pencilstache)"
	icon_state = "facial_pencilstache"

/datum/sprite_accessory/facial_hair/smallstache
	name = "Moustache (Smallstache)"
	icon_state = "facial_smallstache"

/datum/sprite_accessory/facial_hair/walrus
	name = "Moustache (Walrus)"
	icon_state = "facial_walrus"

/datum/sprite_accessory/facial_hair/fu
	name = "Moustache (Fu Manchu)"
	icon_state = "facial_fumanchu"

/datum/sprite_accessory/facial_hair/hogan
	name = "Moustache (Hulk Hogan)"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/selleck
	name = "Moustache (Selleck)"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Moustache (Square)"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/vandyke
	name = "Moustache (Van Dyke)"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/watson
	name = "Moustache (Watson)"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/handlebar
	name = "Moustache (Handlebar)"
	icon_state = "facial_handlebar"

/datum/sprite_accessory/facial_hair/handlebar2
	name = "Moustache (Handlebar 2)"
	icon_state = "facial_handlebar2"

/datum/sprite_accessory/facial_hair/elvis
	name = "Sideburns (Elvis)"
	icon_state = "facial_elvis"

/datum/sprite_accessory/facial_hair/mutton
	name = "Sideburns (Mutton Chops)"
	icon_state = "facial_mutton"

/datum/sprite_accessory/facial_hair/sideburn
	name = "Sideburns"
	icon_state = "facial_sideburn"

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = null
	gender = NEUTER

///////////////////////////
// Underwear Definitions //
///////////////////////////

/datum/sprite_accessory/underwear
	icon = 'icons/mob/clothing/underwear.dmi'
	use_static = FALSE
	em_block = TRUE


//MALE UNDERWEAR
/datum/sprite_accessory/underwear/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

/datum/sprite_accessory/underwear/male_briefs
	name = "Briefs"
	icon_state = "male_briefs"
	gender = MALE

/datum/sprite_accessory/underwear/male_boxers
	name = "Boxers"
	icon_state = "male_boxers"
	gender = MALE

/datum/sprite_accessory/underwear/male_stripe
	name = "Striped Boxers"
	icon_state = "male_stripe"
	gender = MALE

/datum/sprite_accessory/underwear/male_midway
	name = "Midway Boxers"
	icon_state = "male_midway"
	gender = MALE

/datum/sprite_accessory/underwear/male_longjohns
	name = "Long Johns"
	icon_state = "male_longjohns"
	gender = MALE

/datum/sprite_accessory/underwear/male_kinky
	name = "Jockstrap"
	icon_state = "male_kinky"
	gender = MALE

/datum/sprite_accessory/underwear/male_mankini
	name = "Mankini"
	icon_state = "male_mankini"
	gender = MALE

/datum/sprite_accessory/underwear/male_hearts
	name = "Hearts Boxers"
	icon_state = "male_hearts"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_commie
	name = "Commie Boxers"
	icon_state = "male_commie"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_usastripe
	name = "Freedom Boxers"
	icon_state = "male_assblastusa"
	gender = MALE
	use_static = TRUE

/datum/sprite_accessory/underwear/male_uk
	name = "UK Boxers"
	icon_state = "male_uk"
	gender = MALE
	use_static = TRUE


//FEMALE UNDERWEAR
/datum/sprite_accessory/underwear/female_bikini
	name = "Bikini"
	icon_state = "female_bikini"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_lace
	name = "Lace Bikini"
	icon_state = "female_lace"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_bralette
	name = "Bralette w/ Boyshorts"
	icon_state = "female_bralette"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_sport
	name = "Sports Bra w/ Boyshorts"
	icon_state = "female_sport"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_thong
	name = "Thong"
	icon_state = "female_thong"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_strapless
	name = "Strapless Bikini"
	icon_state = "female_strapless"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_babydoll
	name = "Babydoll"
	icon_state = "female_babydoll"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_onepiece
	name = "One-Piece Swimsuit"
	icon_state = "swim_onepiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_strapless_onepiece
	name = "Strapless One-Piece Swimsuit"
	icon_state = "swim_strapless_onepiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_twopiece
	name = "Two-Piece Swimsuit"
	icon_state = "swim_twopiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_strapless_twopiece
	name = "Strapless Two-Piece Swimsuit"
	icon_state = "swim_strapless_twopiece"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_stripe
	name = "Strapless Striped Swimsuit"
	icon_state = "swim_stripe"
	gender = FEMALE

/datum/sprite_accessory/underwear/swimsuit_halter
	name = "Halter Swimsuit"
	icon_state = "swim_halter"
	gender = FEMALE

/datum/sprite_accessory/underwear/female_white_neko
	name = "Neko Bikini (White)"
	icon_state = "female_neko_white"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_black_neko
	name = "Neko Bikini (Black)"
	icon_state = "female_neko_black"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_commie
	name = "Commie Bikini"
	icon_state = "female_commie"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_usastripe
	name = "Freedom Bikini"
	icon_state = "female_assblastusa"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_uk
	name = "UK Bikini"
	icon_state = "female_uk"
	gender = FEMALE
	use_static = TRUE

/datum/sprite_accessory/underwear/female_kinky
	name = "Lingerie"
	icon_state = "female_kinky"
	gender = FEMALE
	use_static = TRUE

////////////////////////////
// Undershirt Definitions //
////////////////////////////

/datum/sprite_accessory/undershirt
	icon = 'icons/mob/clothing/underwear.dmi'
	em_block = TRUE

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null
	gender = NEUTER

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/undershirt/bluejersey
	name = "Jersey (Blue)"
	icon_state = "shirt_bluejersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redjersey
	name = "Jersey (Red)"
	icon_state = "shirt_redjersey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/bluepolo
	name = "Polo Shirt (Blue)"
	icon_state = "bluepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/grayyellowpolo
	name = "Polo Shirt (Gray-Yellow)"
	icon_state = "grayyellowpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redpolo
	name = "Polo Shirt (Red)"
	icon_state = "redpolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whitepolo
	name = "Polo Shirt (White)"
	icon_state = "whitepolo"
	gender = NEUTER

/datum/sprite_accessory/undershirt/alienshirt
	name = "Shirt (Alien)"
	icon_state = "shirt_alien"
	gender = NEUTER

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Shirt (Band)"
	icon_state = "band"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_black
	name = "Shirt (Black)"
	icon_state = "shirt_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirt
	name = "Shirt (Blue)"
	icon_state = "shirt_blue"
	gender = NEUTER

/datum/sprite_accessory/undershirt/clownshirt
	name = "Shirt (Clown)"
	icon_state = "shirt_clown"
	gender = NEUTER

/datum/sprite_accessory/undershirt/commie
	name = "Shirt (Commie)"
	icon_state = "shirt_commie"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirt
	name = "Shirt (Green)"
	icon_state = "shirt_green"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Shirt (Grey)"
	icon_state = "shirt_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ian
	name = "Shirt (Ian)"
	icon_state = "ian"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ilovent
	name = "Shirt (I Love NT)"
	icon_state = "ilovent"
	gender = NEUTER

/datum/sprite_accessory/undershirt/lover
	name = "Shirt (Lover)"
	icon_state = "lover"
	gender = NEUTER

/datum/sprite_accessory/undershirt/matroska
	name = "Shirt (Matroska)"
	icon_state = "matroska"
	gender = NEUTER

/datum/sprite_accessory/undershirt/meat
	name = "Shirt (Meat)"
	icon_state = "shirt_meat"
	gender = NEUTER

/datum/sprite_accessory/undershirt/nano
	name = "Shirt (Nanotrasen)"
	icon_state = "shirt_nano"
	gender = NEUTER

/datum/sprite_accessory/undershirt/peace
	name = "Shirt (Peace)"
	icon_state = "peace"
	gender = NEUTER

/datum/sprite_accessory/undershirt/pacman
	name = "Shirt (Pogoman)"
	icon_state = "pogoman"
	gender = NEUTER

/datum/sprite_accessory/undershirt/question
	name = "Shirt (Question)"
	icon_state = "shirt_question"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirt
	name = "Shirt (Red)"
	icon_state = "shirt_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/skull
	name = "Shirt (Skull)"
	icon_state = "shirt_skull"
	gender = NEUTER

/datum/sprite_accessory/undershirt/ss13
	name = "Shirt (SS13)"
	icon_state = "shirt_ss13"
	gender = NEUTER

/datum/sprite_accessory/undershirt/stripe
	name = "Shirt (Striped)"
	icon_state = "shirt_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tiedye
	name = "Shirt (Tie-dye)"
	icon_state = "shirt_tiedye"
	gender = NEUTER

/datum/sprite_accessory/undershirt/uk
	name = "Shirt (UK)"
	icon_state = "uk"
	gender = NEUTER

/datum/sprite_accessory/undershirt/usa
	name = "Shirt (USA)"
	icon_state = "shirt_assblastusa"
	gender = NEUTER

/datum/sprite_accessory/undershirt/shirt_white
	name = "Shirt (White)"
	icon_state = "shirt_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blackshortsleeve
	name = "Short-sleeved Shirt (Black)"
	icon_state = "blackshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshortsleeve
	name = "Short-sleeved Shirt (Blue)"
	icon_state = "blueshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshortsleeve
	name = "Short-sleeved Shirt (Green)"
	icon_state = "greenshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/purpleshortsleeve
	name = "Short-sleeved Shirt (Purple)"
	icon_state = "purpleshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/whiteshortsleeve
	name = "Short-sleeved Shirt (White)"
	icon_state = "whiteshortsleeve"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra
	name = "Sports Bra"
	icon_state = "sports_bra"
	gender = NEUTER

/datum/sprite_accessory/undershirt/sports_bra2
	name = "Sports Bra (Alt)"
	icon_state = "sports_bra_alt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/blueshirtsport
	name = "Sports Shirt (Blue)"
	icon_state = "blueshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/greenshirtsport
	name = "Sports Shirt (Green)"
	icon_state = "greenshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redshirtsport
	name = "Sports Shirt (Red)"
	icon_state = "redshirtsport"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_black
	name = "Tank Top (Black)"
	icon_state = "tank_black"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankfire
	name = "Tank Top (Fire)"
	icon_state = "tank_fire"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_grey
	name = "Tank Top (Grey)"
	icon_state = "tank_grey"
	gender = NEUTER

/datum/sprite_accessory/undershirt/female_midriff
	name = "Tank Top (Midriff)"
	icon_state = "tank_midriff"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tank_red
	name = "Tank Top (Red)"
	icon_state = "tank_red"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tankstripe
	name = "Tank Top (Striped)"
	icon_state = "tank_stripes"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tank_white
	name = "Tank Top (White)"
	icon_state = "tank_white"
	gender = NEUTER

/datum/sprite_accessory/undershirt/redtop
	name = "Top (Red)"
	icon_state = "redtop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/whitetop
	name = "Top (White)"
	icon_state = "whitetop"
	gender = FEMALE

/datum/sprite_accessory/undershirt/tshirt_blue
	name = "T-Shirt (Blue)"
	icon_state = "blueshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_green
	name = "T-Shirt (Green)"
	icon_state = "greenshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/tshirt_red
	name = "T-Shirt (Red)"
	icon_state = "redshirt"
	gender = NEUTER

/datum/sprite_accessory/undershirt/yellowshirt
	name = "T-Shirt (Yellow)"
	icon_state = "yellowshirt"
	gender = NEUTER

///////////////////////
// Socks Definitions //
///////////////////////

/datum/sprite_accessory/socks
	icon = 'icons/mob/clothing/underwear.dmi'
	em_block = TRUE

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/socks/ace_knee
	name = "Knee-high (Ace)"
	icon_state = "ace_knee"

/datum/sprite_accessory/socks/bee_knee
	name = "Knee-high (Bee)"
	icon_state = "bee_knee"

/datum/sprite_accessory/socks/black_knee
	name = "Knee-high (Black)"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/commie_knee
	name = "Knee-High (Commie)"
	icon_state = "commie_knee"

/datum/sprite_accessory/socks/usa_knee
	name = "Knee-High (Freedom)"
	icon_state = "assblastusa_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high (Rainbow)"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high (Striped)"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high (Thin)"
	icon_state = "thin_knee"

/datum/sprite_accessory/socks/trans_knee
	name = "Knee-high (Trans)"
	icon_state = "trans_knee"

/datum/sprite_accessory/socks/uk_knee
	name = "Knee-High (UK)"
	icon_state = "uk_knee"

/datum/sprite_accessory/socks/white_knee
	name = "Knee-high (White)"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/fishnet_knee
	name = "Knee-high (Fishnet)"
	icon_state = "fishnet_knee"

/datum/sprite_accessory/socks/black_norm
	name = "Normal (Black)"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_norm
	name = "Normal (White)"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"

/datum/sprite_accessory/socks/black_short
	name = "Short (Black)"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_short
	name = "Short (White)"
	icon_state = "white_short"

/datum/sprite_accessory/socks/stockings_blue
	name = "Stockings (Blue)"
	icon_state = "stockings_blue"

/datum/sprite_accessory/socks/stockings_cyan
	name = "Stockings (Cyan)"
	icon_state = "stockings_cyan"

/datum/sprite_accessory/socks/stockings_dpink
	name = "Stockings (Dark Pink)"
	icon_state = "stockings_dpink"

/datum/sprite_accessory/socks/stockings_green
	name = "Stockings (Green)"
	icon_state = "stockings_green"

/datum/sprite_accessory/socks/stockings_orange
	name = "Stockings (Orange)"
	icon_state = "stockings_orange"

/datum/sprite_accessory/socks/stockings_programmer
	name = "Stockings (Programmer)"
	icon_state = "stockings_lpink"

/datum/sprite_accessory/socks/stockings_purple
	name = "Stockings (Purple)"
	icon_state = "stockings_purple"

/datum/sprite_accessory/socks/stockings_yellow
	name = "Stockings (Yellow)"
	icon_state = "stockings_yellow"

/datum/sprite_accessory/socks/stockings_fishnet
	name = "Stockings (Fishnet)"
	icon_state = "fishnet_full"

/datum/sprite_accessory/socks/ace_thigh
	name = "Thigh-high (Ace)"
	icon_state = "ace_thigh"

/datum/sprite_accessory/socks/bee_thigh
	name = "Thigh-high (Bee)"
	icon_state = "bee_thigh"

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high (Black)"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/commie_thigh
	name = "Thigh-high (Commie)"
	icon_state = "commie_thigh"

/datum/sprite_accessory/socks/usa_thigh
	name = "Thigh-high (Freedom)"
	icon_state = "assblastusa_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high (Rainbow)"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high (Striped)"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high (Thin)"
	icon_state = "thin_thigh"

/datum/sprite_accessory/socks/trans_thigh
	name = "Thigh-high (Trans)"
	icon_state = "trans_thigh"

/datum/sprite_accessory/socks/uk_thigh
	name = "Thigh-high (UK)"
	icon_state = "uk_thigh"

/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high (White)"
	icon_state = "white_thigh"

/datum/sprite_accessory/socks/fishnet_thigh
	name = "Thigh-high (Fishnet)"
	icon_state = "fishnet_thigh"

/datum/sprite_accessory/socks/thocks
	name = "Thocks"
	icon_state = "thocks"

//////////.//////////////////
// MutantParts Definitions //
/////////////////////////////

/datum/sprite_accessory/lizard_markings
	icon = 'icons/mob/human/species/lizard/lizard_markings.dmi'

/datum/sprite_accessory/lizard_markings/dtiger
	name = "Dark Tiger Body"
	icon_state = "dtiger"
	gender_specific = TRUE

/datum/sprite_accessory/lizard_markings/ltiger
	name = "Light Tiger Body"
	icon_state = "ltiger"
	gender_specific = TRUE

/datum/sprite_accessory/lizard_markings/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	gender_specific = TRUE

/datum/sprite_accessory/tails
	em_block = TRUE
	/// Describes which tail spine sprites to use, if any.
	var/spine_key = NONE

///Used for fish-infused tails, which come in different flavors.
/datum/sprite_accessory/tails/fish
	icon = 'icons/mob/human/fish_features.dmi'
	color_src = TRUE

/datum/sprite_accessory/tails/fish/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/tails/fish/crescent
	name = "Crescent"
	icon_state = "crescent"

/datum/sprite_accessory/tails/fish/long
	name = "Long"
	icon_state = "long"
	center = TRUE
	dimension_x = 38

/datum/sprite_accessory/tails/fish/shark
	name = "Shark"
	icon_state = "shark"

/datum/sprite_accessory/tails/fish/chonky
	name = "Chonky"
	icon_state = "chonky"
	center = TRUE
	dimension_x = 36

/datum/sprite_accessory/tails/lizard
	icon = 'icons/mob/human/species/lizard/lizard_tails.dmi'
	spine_key = SPINE_KEY_LIZARD

/datum/sprite_accessory/tails/lizard/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	natural_spawn = FALSE

/datum/sprite_accessory/tails/lizard/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails/lizard/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/lizard/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/lizard/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails/lizard/short
	name = "Short"
	icon_state = "short"
	spine_key = NONE

/datum/sprite_accessory/tails/felinid/cat
	name = "Cat"
	icon = 'icons/mob/human/cat_features.dmi'
	icon_state = "default"
	color_src = HAIR_COLOR

/datum/sprite_accessory/tails/monkey

/datum/sprite_accessory/tails/monkey/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	natural_spawn = FALSE

/datum/sprite_accessory/tails/monkey/default
	name = "Monkey"
	icon = 'icons/mob/human/species/monkey/monkey_tail.dmi'
	icon_state = "default"
	color_src = FALSE

/datum/sprite_accessory/tails/xeno
	icon_state = "default"
	color_src = FALSE
	center = TRUE

/datum/sprite_accessory/tails/xeno/default
	name = "Xeno"
	icon = 'icons/mob/human/species/alien/tail_xenomorph.dmi'
	dimension_x = 40

/datum/sprite_accessory/tails/xeno/queen
	name = "Xeno Queen"
	icon = 'icons/mob/human/species/alien/tail_xenomorph_queen.dmi'
	dimension_x = 64

/datum/sprite_accessory/pod_hair
	icon = 'icons/mob/human/species/podperson_hair.dmi'
	em_block = TRUE

/datum/sprite_accessory/pod_hair/ivy
	name = "Ivy"
	icon_state = "ivy"

/datum/sprite_accessory/pod_hair/cabbage
	name = "Cabbage"
	icon_state = "cabbage"

/datum/sprite_accessory/pod_hair/spinach
	name = "Spinach"
	icon_state = "spinach"

/datum/sprite_accessory/pod_hair/prayer
	name = "Prayer"
	icon_state = "prayer"

/datum/sprite_accessory/pod_hair/vine
	name = "Vine"
	icon_state = "vine"

/datum/sprite_accessory/pod_hair/shrub
	name = "Shrub"
	icon_state = "shrub"

/datum/sprite_accessory/pod_hair/rose
	name = "Rose"
	icon_state = "rose"

/datum/sprite_accessory/pod_hair/orchid
	name = "Orchid"
	icon_state = "orchid"

/datum/sprite_accessory/pod_hair/fig
	name = "Fig"
	icon_state = "fig"

/datum/sprite_accessory/pod_hair/hibiscus
	name = "Hibiscus"
	icon_state = "hibiscus"

/datum/sprite_accessory/snouts
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'
	em_block = TRUE

/datum/sprite_accessory/snouts/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/snouts/sharplight
	name = "Sharp + Light"
	icon_state = "sharplight"

/datum/sprite_accessory/snouts/roundlight
	name = "Round + Light"
	icon_state = "roundlight"

/datum/sprite_accessory/horns
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'
	em_block = TRUE

/datum/sprite_accessory/horns/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/horns/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/horns/curled
	name = "Curled"
	icon_state = "curled"

/datum/sprite_accessory/horns/ram
	name = "Ram"
	icon_state = "ram"

/datum/sprite_accessory/horns/angler
	name = "Angeler"
	icon_state = "angler"

/datum/sprite_accessory/ears
	icon = 'icons/mob/human/cat_features.dmi'
	em_block = TRUE

/datum/sprite_accessory/ears/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR_COLOR

/datum/sprite_accessory/ears/cat/big
	name = "Big"
	icon_state = "big"

/datum/sprite_accessory/ears/cat/miqo
	name = "Coeurl"
	icon_state = "miqo"

/datum/sprite_accessory/ears/cat/fold
	name = "Fold"
	icon_state = "fold"

/datum/sprite_accessory/ears/cat/lynx
	name = "Lynx"
	icon_state = "lynx"

/datum/sprite_accessory/ears/cat/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/ears/fox
	icon = 'icons/mob/human/fox_features.dmi'
	name = "Fox"
	icon_state = "fox"
	color_src = HAIR_COLOR
	locked = TRUE

/datum/sprite_accessory/wings
	icon = 'icons/mob/human/species/wings.dmi'
	em_block = TRUE

/datum/sprite_accessory/wings_open
	icon = 'icons/mob/human/species/wings.dmi'
	em_block = TRUE

/datum/sprite_accessory/wings/angel
	name = "Angel"
	icon_state = "angel"
	color_src = FALSE
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	locked = TRUE

/datum/sprite_accessory/wings_open/angel
	name = "Angel"
	icon_state = "angel"
	color_src = FALSE
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings/dragon
	name = "Dragon"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/dragon
	name = "Dragon"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/megamoth
	name = "Megamoth"
	icon_state = "megamoth"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/megamoth
	name = "Megamoth"
	icon_state = "megamoth"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/mothra
	name = "Mothra"
	icon_state = "mothra"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/mothra
	name = "Mothra"
	icon_state = "mothra"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/skeleton
	name = "Skeleton"
	icon_state = "skele"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/skeleton
	name = "Skeleton"
	icon_state = "skele"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/robotic
	name = "Robotic"
	icon_state = "robotic"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/robotic
	name = "Robotic"
	icon_state = "robotic"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/fly
	name = "Fly"
	icon_state = "fly"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/fly
	name = "Fly"
	icon_state = "fly"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/slime
	name = "Slime"
	icon_state = "slime"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/slime
	name = "Slime"
	icon_state = "slime"
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/frills
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'

/datum/sprite_accessory/frills/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/frills/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/frills/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/spines
	icon = 'icons/mob/human/species/lizard/lizard_spines.dmi'
	em_block = TRUE

/datum/sprite_accessory/tail_spines
	icon = 'icons/mob/human/species/lizard/lizard_spines.dmi'
	em_block = TRUE

/datum/sprite_accessory/spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/tail_spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/tail_spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/tail_spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/tail_spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/tail_spines/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/caps
	icon = 'icons/mob/human/species/mush_cap.dmi'
	color_src = HAIR_COLOR
	em_block = TRUE

/datum/sprite_accessory/caps/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/moth_wings
	icon = 'icons/mob/human/species/moth/moth_wings.dmi'
	color_src = null
	em_block = TRUE

/datum/sprite_accessory/moth_wings/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/moth_wings/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/moth_wings/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/moth_wings/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/moth_wings/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/moth_wings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_wings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_wings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_wings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_wings/burnt_off
	name = "Burnt Off"
	icon_state = "burnt_off"
	locked = TRUE

/datum/sprite_accessory/moth_wings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_wings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_wings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_wings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_wings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_wings/snow
	name = "Snow"
	icon_state = "snow"

/datum/sprite_accessory/moth_wings/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_wings/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/moth_wings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_wings/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/moth_wings/feathery
	name = "Feathery"
	icon_state = "feathery"

/datum/sprite_accessory/moth_wings/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/moth_wings/plasmafire
	name = "Plasmafire"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_wings/moffra
	name = "Moffra"
	icon_state = "moffra"

/datum/sprite_accessory/moth_wings/lightbearer
	name = "Lightbearer"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_wings/dipped
	name = "Dipped"
	icon_state = "dipped"

/datum/sprite_accessory/moth_antennae //Finally splitting the sprite
	icon = 'icons/mob/human/species/moth/moth_antennae.dmi'
	color_src = null

/datum/sprite_accessory/moth_antennae/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/moth_antennae/reddish
	name = "Reddish"
	icon_state = "reddish"

/datum/sprite_accessory/moth_antennae/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_antennae/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_antennae/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_antennae/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_antennae/burnt_off
	name = "Burnt Off"
	icon_state = "burnt_off"

/datum/sprite_accessory/moth_antennae/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_antennae/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_antennae/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_antennae/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_antennae/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_antennae/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_antennae/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/moth_antennae/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_antennae/regal
	name = "Regal"
	icon_state = "regal"
/datum/sprite_accessory/moth_antennae/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/moth_antennae/feathery
	name = "Feathery"
	icon_state = "feathery"

/datum/sprite_accessory/moth_antennae/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/moth_antennae/plasmafire
	name = "Plasmafire"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_antennae/moffra
	name = "Moffra"
	icon_state = "moffra"

/datum/sprite_accessory/moth_antennae/lightbearer
	name = "Lightbearer"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_antennae/dipped
	name = "Dipped"
	icon_state = "dipped"

/datum/sprite_accessory/moth_markings // the markings that moths can have. finally something other than the boring tan
	icon = 'icons/mob/human/species/moth/moth_markings.dmi'
	color_src = null

/datum/sprite_accessory/moth_markings/reddish
	name = "Reddish"
	icon_state = "reddish"

/datum/sprite_accessory/moth_markings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_markings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_markings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_markings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_markings/burnt_off
	name = "Burnt Off"
	icon_state = "burnt_off"

/datum/sprite_accessory/moth_markings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_markings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_markings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_markings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_markings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_markings/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/moth_markings/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/moth_markings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_markings/lightbearer
	name = "Lightbearer"
	icon_state = "lightbearer"

/datum/sprite_accessory/moth_markings/dipped
	name = "Dipped"
	icon_state = "dipped"
