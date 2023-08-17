/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Toggle [item_target.name]"

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_computer_light
	name = "Toggle Flashlight"

/datum/action/item_action/toggle_hood
	name = "Toggle Hood"

/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"

/datum/action/item_action/toggle_gunlight
	name = "Toggle Gunlight"

/datum/action/item_action/toggle_mode
	name = "Toggle Mode"

/datum/action/item_action/toggle_barrier_spread
	name = "Toggle Barrier Spread"

/datum/action/item_action/toggle_paddles
	name = "Toggle Paddles"

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/toggle_helmet_light
	name = "Toggle Helmet Light"

/datum/action/item_action/toggle_welding_screen
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_spacesuit
	name = "Toggle Suit Thermal Regulator"
	button_icon = 'icons/mob/actions/actions_spacesuit.dmi'
	button_icon_state = "thermal_off"

/datum/action/item_action/toggle_spacesuit/apply_button_icon(atom/movable/screen/movable/action_button/button, force)
	var/obj/item/clothing/suit/space/suit = target
	if(istype(suit))
		button_icon_state = "thermal_[suit.thermal_on ? "on" : "off"]"

	return ..()

/datum/action/item_action/toggle_helmet_flashlight
	name = "Toggle Helmet Flashlight"

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/toggle_voice_box
	name = "Toggle Voice Box"

/datum/action/item_action/toggle_human_head
	name = "Toggle Human Head"

/datum/action/item_action/toggle_helmet
	name = "Toggle Helmet"

/datum/action/item_action/toggle_seclight
	name = "Toggle Seclight"

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable(feedback = FALSE)
	var/obj/item/tank/jetpack/linked_jetpack = target
	if(!istype(linked_jetpack) || !linked_jetpack.on)
		return FALSE
	return ..()

/datum/action/item_action/wheelys
	name = "Toggle Wheels"
	desc = "Pops out or in your shoes' wheels."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "wheelys"

/datum/action/item_action/kindle_kicks
	name = "Activate Kindle Kicks"
	desc = "Kick you feet together, activating the lights in your Kindle Kicks."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "kindleKicks"

/datum/action/item_action/storage_gather_mode
	name = "Switch gathering mode"
	desc = "Switches the gathering mode of a storage object."
	background_icon = 'icons/mob/actions/actions_items.dmi'
	background_icon_state = "storage_gather_switch"
	overlay_icon_state = "bg_tech_border"

/datum/action/item_action/flip
	name = "Flip"

/datum/action/item_action/call_link
	name = "Call MODlink"

