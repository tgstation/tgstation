/datum/action/cooldown/mob_cooldown/blood_worm
	abstract_type = /datum/action/cooldown/mob_cooldown/blood_worm

	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_demon"

	button_icon = 'icons/mob/actions/actions_blood_worm.dmi'

	overlay_icon = 'icons/mob/actions/backgrounds.dmi'
	overlay_icon_state = "bg_demon_border"
	active_overlay_icon_state = "bg_spell_border_active_red"

	ranged_mousepointer = 'icons/effects/mouse_pointers/weapon_pointer.dmi'

/datum/action/cooldown/mob_cooldown/blood_worm/set_click_ability(mob/on_who)
	. = ..()
	build_all_button_icons(UPDATE_BUTTON_OVERLAY)

/datum/action/cooldown/mob_cooldown/blood_worm/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	build_all_button_icons(UPDATE_BUTTON_OVERLAY)
