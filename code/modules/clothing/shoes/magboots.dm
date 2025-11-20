/datum/armor/shoes_magboots
	bio = 90

/obj/item/clothing/shoes/magboots
	name = "magboots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	icon_state = "magboots0"
	base_icon_state = "magboots"
	inhand_icon_state = "magboots"
	armor_type = /datum/armor/shoes_magboots
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 7 SECONDS
	equip_delay_other = 7 SECONDS
	resistance_flags = FIRE_PROOF
	clothing_flags = parent_type::clothing_flags | STOPSPRESSUREDAMAGE
	slowdown = SHOES_SLOWDOWN
	/// Whether the magpulse system is active
	var/magpulse = FALSE
	/// Slowdown applied wwhen magpulse is active. This is added onto existing slowdown
	var/slowdown_active = 2
	/// A list of traits we apply when we get activated
	var/list/active_traits = list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NEGATES_GRAVITY)
	/// How much do these boots affect fishing when active
	var/magpulse_fishing_modifier = 8
	/// How much do these boots affect fishing when not active
	var/fishing_modifier = 4

/obj/item/clothing/shoes/magboots/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, PROC_REF(on_speed_potioned))
	if(fishing_modifier)
		AddComponent(/datum/component/adjust_fishing_difficulty, fishing_modifier)

/// Signal handler for [COMSIG_SPEED_POTION_APPLIED]. Speed potion removes the active slowdown
/obj/item/clothing/shoes/magboots/proc/on_speed_potioned(datum/source)
	SIGNAL_HANDLER

	// Don't need to touch the actual slowdown here, since the speed potion does it for us
	slowdown_active = 0

	if(magpulse && magpulse_fishing_modifier)
		qdel(GetComponent(/datum/component/adjust_fishing_difficulty))
		if(fishing_modifier)
			AddComponent(/datum/component/adjust_fishing_difficulty, fishing_modifier)
	magpulse_fishing_modifier = fishing_modifier

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr

	if(!can_use(usr))
		return
	attack_self(usr)

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	magpulse = !magpulse
	if(magpulse)
		attach_clothing_traits(active_traits)
		slowdown += slowdown_active
		if(magpulse_fishing_modifier)
			AddComponent(/datum/component/adjust_fishing_difficulty, magpulse_fishing_modifier)
		else if(magpulse_fishing_modifier != fishing_modifier)
			qdel(GetComponent(/datum/component/adjust_fishing_difficulty))
	else
		if(fishing_modifier)
			AddComponent(/datum/component/adjust_fishing_difficulty, fishing_modifier)
		else if(magpulse_fishing_modifier != fishing_modifier)
			qdel(GetComponent(/datum/component/adjust_fishing_difficulty))
		detach_clothing_traits(active_traits)
		slowdown -= slowdown_active

	update_appearance()
	balloon_alert(user, "mag-pulse [magpulse ? "enabled" : "disabled"]")
	//we want to update our speed so we arent running at max speed in regular magboots
	user.update_equipment_speed_mods()

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"]."

/obj/item/clothing/shoes/magboots/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][magpulse]"

/obj/item/clothing/shoes/magboots/advance
	name = "advanced magboots"
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	icon_state = "advmag0"
	base_icon_state = "advmag"
	slowdown_active = 0 // ZERO active slowdown
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	magpulse_fishing_modifier = 3
	fishing_modifier = 0

/obj/item/clothing/shoes/magboots/syndie
	name = "blood-red magboots"
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	icon_state = "syndiemag0"
	base_icon_state = "syndiemag"
	magpulse_fishing_modifier = 6
	fishing_modifier = 3
