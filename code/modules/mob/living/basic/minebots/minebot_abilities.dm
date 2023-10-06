
/datum/action/cooldown/mob_cooldown/minedrone
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/minedrone/toggle_light
	name = "Toggle Light"
	button_icon_state = "mech_lights_off"

/datum/action/cooldown/mob_cooldown/minedrone/Activate()
	owner.set_light_on(!owner.light_on)
	owner.balloon_alert(owner, "lights [owner.light_on ? "on" : "off"]!")

/datum/action/cooldown/mob_cooldown/minedrone/dump_ore
	name = "Dump Ore"
	button_icon_state = "mech_eject"

/datum/action/cooldown/mob_cooldown/minedrone/dump_ore/IsAvailable(feedback = TRUE)
	if(locate(/obj/item/stack/ore) in owner.contents)
		return TRUE

	if(feedback)
		owner.balloon_alert(owner, "no ore!")
	return FALSE

/datum/action/cooldown/mob_cooldown/minedrone/dump_ore/Activate()
	var/mob/living/basic/mining_drone/user = owner
	user.drop_ore()

/datum/action/cooldown/mob_cooldown/minedrone/toggle_meson_vision
	name = "Toggle Meson Vision"
	button_icon_state = "meson"

/datum/action/cooldown/mob_cooldown/minedrone/toggle_meson_vision/Activate()
	if(owner.sight & SEE_TURFS)
		owner.clear_sight(SEE_TURFS)
		owner.lighting_cutoff_red += 5
		owner.lighting_cutoff_green += 15
		owner.lighting_cutoff_blue += 5
	else
		owner.add_sight(SEE_TURFS)
		owner.lighting_cutoff_red -= 5
		owner.lighting_cutoff_green -= 15
		owner.lighting_cutoff_blue -= 5

	owner.sync_lighting_plane_cutoff()

	to_chat(owner, span_notice("You toggle your meson vision [(owner.sight & SEE_TURFS) ? "on" : "off"]."))

