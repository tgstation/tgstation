/datum/action/item_action/flightsuit
	icon_icon = 'icons/mob/actions/actions_flightsuit.dmi'

/datum/action/item_action/flightsuit/toggle_boots
	name = "Toggle Boots"
	button_icon_state = "flightsuit_shoes"
	background_icon_state = "bg_tech"

/datum/action/item_action/flightsuit/toggle_boots/Trigger()
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/FS = target
	if(istype(FS))
		FS.deployedshoes? FS.retract_flightshoes() : FS.extend_flightshoes()
	return ..()

/datum/action/item_action/flightsuit/toggle_helmet
	name = "Toggle Helmet"
	button_icon_state = "flightsuit_helmet"
	background_icon_state = "bg_tech"

/datum/action/item_action/flightsuit/toggle_helmet/Trigger()
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/FS = target
	if(istype(FS))
		FS.ToggleHelmet()
	return ..()

/datum/action/item_action/flightsuit/toggle_flightpack
	name = "Toggle Flightpack"
	button_icon_state = "flightsuit_pack"
	background_icon_state = "bg_tech"

/datum/action/item_action/flightsuit/toggle_flightpack/Trigger()
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/FS = target
	if(istype(FS))
		FS.deployedpack? FS.retract_flightpack() : FS.extend_flightpack()
	return ..()

/datum/action/item_action/flightsuit/lock_suit
	name = "Lock Suit"
	button_icon_state = "flightsuit_lock"
	background_icon_state = "bg_tech"

/datum/action/item_action/flightsuit/lock_suit/Trigger()
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/FS = target
	if(istype(FS))
		FS.locked? FS.unlock_suit(owner) : FS.lock_suit(owner)
	return ..()

/datum/action/item_action/flightpack
	icon_icon = 'icons/mob/actions/actions_flightsuit.dmi'

/datum/action/item_action/flightpack/toggle_flight
	name = "Toggle Flight"
	button_icon_state = "flightpack_fly"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/toggle_flight/Trigger()
	var/obj/item/flightpack/F = target
	if(istype(F))
		F.flight? F.disable_flight() : F.enable_flight()
	return ..()

/datum/action/item_action/flightpack/engage_boosters
	name = "Toggle Boosters"
	button_icon_state = "flightpack_boost"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/engage_boosters/Trigger()
	var/obj/item/flightpack/F = target
	if(istype(F))
		F.boost? F.deactivate_booster() : F.activate_booster()
	return ..()

/datum/action/item_action/flightpack/toggle_stabilizers
	name = "Toggle Stabilizers"
	button_icon_state = "flightpack_stabilizer"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/toggle_stabilizers/Trigger()
	var/obj/item/flightpack/F = target
	if(istype(F))
		F.stabilizer? F.disable_stabilizers() : F.enable_stabilizers()
	return ..()

/datum/action/item_action/flightpack/change_power
	name = "Flight Power Setting"
	button_icon_state = "flightpack_power"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/change_power/Trigger()
	var/obj/item/flightpack/F = target
	if(istype(F))
		F.cycle_power()
	return ..()

/datum/action/item_action/flightpack/toggle_airbrake
	name = "Toggle Airbrake"
	button_icon_state = "flightpack_airbrake"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/toggle_airbrake/Trigger()
	var/obj/item/flightpack/F = target
	if(istype(F))
		F.brake? F.disable_airbrake() : F.enable_airbrake()
	return ..()

/datum/action/item_action/flightpack/zoom
	name = "Helmet Smart Zoom"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"

/datum/action/item_action/flightpack/zoom/Trigger()
	var/obj/item/clothing/head/helmet/space/hardsuit/flightsuit/FH = target
	if(istype(FH))
		FH.toggle_zoom(owner)
	return ..()
