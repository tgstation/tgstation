//Small sprites
/datum/action/small_sprite
	name = "Toggle Giant Sprite"
	desc = "Others will always see you as giant."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "smallqueen"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	var/small = FALSE
	var/small_icon
	var/small_icon_state

/datum/action/small_sprite/queen
	small_icon = 'icons/mob/nonhuman-player/alien.dmi'
	small_icon_state = "alienq"

/datum/action/small_sprite/megafauna
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	small_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'

/datum/action/small_sprite/megafauna/drake
	small_icon_state = "ash_whelp"

/datum/action/small_sprite/megafauna/colossus
	small_icon_state = "Basilisk"

/datum/action/small_sprite/megafauna/bubblegum
	small_icon_state = "goliath2"

/datum/action/small_sprite/megafauna/legion
	small_icon_state = "mega_legion"

/datum/action/small_sprite/mega_arachnid
	small_icon = 'icons/mob/simple/jungle/arachnid.dmi'
	small_icon_state = "arachnid_mini"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"


/datum/action/small_sprite/space_dragon
	small_icon = 'icons/mob/simple/carp.dmi'
	small_icon_state = "carp"
	button_icon = 'icons/mob/simple/carp.dmi'
	button_icon_state = "carp"

/datum/action/small_sprite/Trigger(trigger_flags)
	..()
	if(!small)
		var/image/I = image(icon = small_icon, icon_state = small_icon_state, loc = owner)
		I.override = TRUE
		I.pixel_x -= owner.pixel_x
		I.pixel_y -= owner.pixel_y
		owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smallsprite", I, AA_TARGET_SEE_APPEARANCE | AA_MATCH_TARGET_OVERLAYS)
		small = TRUE
	else
		owner.remove_alt_appearance("smallsprite")
		small = FALSE
