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

/datum/hair_mask/hoodie
	icon_state = "hide_hoodie"
	strict_coverage_zones = HAIR_APPENDAGE_TOP | HAIR_APPENDAGE_LEFT | HAIR_APPENDAGE_RIGHT | HAIR_APPENDAGE_REAR | HAIR_APPENDAGE_HANGING_REAR

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
	icon_state = SPRITE_ACCESSORY_NONE

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
