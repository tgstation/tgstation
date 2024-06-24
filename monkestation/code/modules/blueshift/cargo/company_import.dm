/datum/supply_order/company_import
	/// The armament entry used to fill the supply order
	var/datum/armament_entry/company_import/selected_entry
	/// The component used to create the order
	var/datum/component/armament/company_imports/used_component

/datum/supply_order/company_import/Destroy(force)
	selected_entry = null
	used_component = null
	. = ..()

/datum/supply_order/company_import/proc/reimburse_armament()
	if(!selected_entry || !used_component)
		return
	used_component.purchased_items[selected_entry]--

/// A proc to be overriden if you want custom code to happen when SSshuttle spawns the order
/datum/supply_order/proc/on_spawn()
	return

/datum/supply_order/generate(atom/A)
	. = ..()

	if(!.)
		return

	on_spawn()

#define CARGO_CUT 0.05

/datum/supply_pack/armament
	goody = TRUE
	crate_type = /obj/structure/closet/crate/large/import

/datum/supply_pack/armament/generate(atom/A, datum/bank_account/paying_account)
	. = ..()
	var/datum/bank_account/cargo_dep = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo_dep.account_balance += round(cost * CARGO_CUT)
	var/obj/structure/container = .
	for(var/obj/item/gun/gun_actually in container.contents)
		QDEL_NULL(gun_actually.pin)
		var/obj/item/firing_pin/permit_pin/new_pin = new(gun_actually)
		gun_actually.pin = new_pin

#undef CARGO_CUT


/obj/machinery/computer/cargo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armament/company_imports, subtypesof(/datum/armament_entry/company_import), 0)

/// Proc for speaking over radio without needing to reuse a bunch of code
/obj/machinery/computer/cargo/proc/radio_wrapper(atom/movable/speaker, message, channel)
	radio.talk_into(speaker, message, channel)

/obj/item/storage/lockbox/order
	/// Bool if this was departmentally ordered or not
	var/department_purchase
	/// Department of the person buying the crate if buying via the NIRN app.
	var/datum/bank_account/department/department_account

/obj/structure/closet/crate/large/import
	name = "heavy-duty wooden crate"
	icon = 'monkestation/code/modules/blueshift/icons/import_crate.dmi'

GLOBAL_VAR_INIT(permit_pin_unrestricted, FALSE)
// Firing pin that can be used off station freely, and requires a permit to use on-station
/obj/item/firing_pin/permit_pin
	name = "permit-locked firing pin"
	desc = "A firing pin for a station who can't trust their crew. Only allows you to fire the weapon off-station or with a firearms permit.."
	icon_state = "firing_pin_explorer"
	fail_message = "firearms permit check failed!</span>"

// This checks that the user isn't on the station Z-level.
/obj/item/firing_pin/permit_pin/pin_auth(mob/living/user)
	var/turf/station_check = get_turf(user)

	if(obj_flags & EMAGGED)
		return TRUE

	if(GLOB.permit_pin_unrestricted)
		return TRUE

	var/obj/item/card/id/the_id = user.get_idcard()

	if(!the_id && is_station_level(station_check.z))
		return FALSE

	if(!is_station_level(station_check.z) || (ACCESS_WEAPONS in the_id.GetAccess()))
		return TRUE


/obj/item/firing_pin
	var/can_remove = TRUE

/obj/item/firing_pin/emag_act(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "firing pin unlocked!")
	obj_flags |= EMAGGED
	can_remove = TRUE
	return TRUE

/obj/item/clothing/glasses/hud/gun_permit
	name = "permit HUD"
	desc = "A heads-up display that scans humanoids in view, and displays if their current ID possesses a firearms permit or not."
	icon = 'monkestation/code/modules/blueshift/icons/hud_goggles.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/hud_goggles_worn.dmi'
	icon_state = "permithud"
	hud_type = DATA_HUD_PERMIT

/obj/item/clothing/glasses/hud/gun_permit/sunglasses
	name = "permit HUD sunglasses"
	desc = "A pair of sunglasses with a heads-up display that scans humanoids in view, and displays if their current ID possesses a firearms permit or not."
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/datum/design/permit_hud
	name = "Gun Permit HUD glasses"
	desc = "A heads-up display that scans humanoids in view, and displays if their current ID possesses a firearms permit or not."
	id = "permit_glasses"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/clothing/glasses/hud/gun_permit
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MISC,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/proc/toggle_permit_pins()
	GLOB.permit_pin_unrestricted = !GLOB.permit_pin_unrestricted
	minor_announce("Permit-locked firing pins have now had their locks [GLOB.permit_pin_unrestricted ? "removed" : "reinstated"].", "Weapons Systems Update:")
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("permit-locked pins", GLOB.permit_pin_unrestricted ? "unlocked" : "locked"))

/obj/machinery/computer/cargo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("company_import_window")
			var/datum/component/armament/company_imports/company_import_component = GetComponent(/datum/component/armament/company_imports)
			company_import_component.ui_interact(usr)
			. = TRUE
	if(.)
		post_signal(cargo_shuttle)
