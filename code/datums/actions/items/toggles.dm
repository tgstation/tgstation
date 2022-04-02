/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Toggle [item_target.name]"

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_light/Trigger(trigger_flags)
	if(istype(target, /obj/item/pda))
		var/obj/item/pda/P = target
		P.toggle_light(owner)
		return
	..()

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

/datum/action/item_action/toggle_welding_screen/Trigger(trigger_flags)
	var/obj/item/clothing/head/hardhat/weldhat/H = target
	if(istype(H))
		H.toggle_welding_screen(owner)

/datum/action/item_action/toggle_welding_screen/plasmaman
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_welding_screen/plasmaman/Trigger(trigger_flags)
	var/obj/item/clothing/head/helmet/space/plasmaman/H = target
	if(istype(H))
		H.toggle_welding_screen(owner)

/datum/action/item_action/toggle_spacesuit
	name = "Toggle Suit Thermal Regulator"
	icon_icon = 'icons/mob/actions/actions_spacesuit.dmi'
	button_icon_state = "thermal_off"

/datum/action/item_action/toggle_spacesuit/New(Target)
	. = ..()
	RegisterSignal(target, COMSIG_SUIT_SPACE_TOGGLE, .proc/toggle)

/datum/action/item_action/toggle_spacesuit/Destroy()
	UnregisterSignal(target, COMSIG_SUIT_SPACE_TOGGLE)
	return ..()

/datum/action/item_action/toggle_spacesuit/Trigger(trigger_flags)
	var/obj/item/clothing/suit/space/suit = target
	if(!istype(suit))
		return
	suit.toggle_spacesuit()

/// Toggle the action icon for the space suit thermal regulator
/datum/action/item_action/toggle_spacesuit/proc/toggle(obj/item/clothing/suit/space/suit)
	SIGNAL_HANDLER

	button_icon_state = "thermal_[suit.thermal_on ? "on" : "off"]"
	UpdateButtons()

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

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return FALSE
	return ..()

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "scan_mode"
	var/active = FALSE

/datum/action/item_action/toggle_research_scanner/Trigger(trigger_flags)
	if(IsAvailable())
		active = !active
		if(active)
			owner.research_scanner++
		else
			owner.research_scanner--
		to_chat(owner, span_notice("[target] research scanner has been [active ? "activated" : "deactivated"]."))
		return 1

/datum/action/item_action/toggle_research_scanner/Remove(mob/M)
	if(owner && active)
		owner.research_scanner--
		active = FALSE
	..()

/datum/action/item_action/wheelys
	name = "Toggle Wheels"
	desc = "Pops out or in your shoes' wheels."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "wheelys"

/datum/action/item_action/kindle_kicks
	name = "Activate Kindle Kicks"
	desc = "Kick you feet together, activating the lights in your Kindle Kicks."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "kindleKicks"

/datum/action/item_action/storage_gather_mode
	name = "Switch gathering mode"
	desc = "Switches the gathering mode of a storage object."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "storage_gather_switch"

/datum/action/item_action/storage_gather_mode/ApplyIcon(atom/movable/screen/movable/action_button/current_button)
	. = ..()
	var/obj/item/item_target = target
	var/old_layer = item_target.layer
	var/old_plane = item_target.plane
	item_target.layer = FLOAT_LAYER //AAAH
	item_target.plane = FLOAT_PLANE //^ what that guy said
	current_button.cut_overlays()
	current_button.add_overlay(target)
	item_target.layer = old_layer
	item_target.plane = old_plane
	current_button.appearance_cache = item_target.appearance
