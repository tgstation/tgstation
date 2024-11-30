/datum/export/epic_loot_super_med_tools
	cost = PAYCHECK_COMMAND * 5
	unit_name = "ancient medical tools"
	export_types = list(
		/obj/item/epic_loot/vein_finder,
		/obj/item/epic_loot/eye_scope,
	)

// Vein finder, uses strong LED lights to reveal veins in someone's body. Perhaps the name "LEDX" rings a bell
/obj/item/epic_loot/vein_finder
	name = "medical vein locator"
	desc = "A small device with a number of high intensity lights on one side. Used by medical professionals to locate veins in someone's body."
	icon_state = "vein_finder"
	inhand_icon_state = "headset"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT*8, \
						/datum/material/silver = SMALL_MATERIAL_AMOUNT*2, \
						/datum/material/gold = SMALL_MATERIAL_AMOUNT*2,)

/obj/item/epic_loot/vein_finder/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(!ishuman(target))
		return
	user.visible_message(
		"[user] determines that [target] does, in fact, have veins.",
		"You determine that [target] does, in fact, have veins."
	)
	new /obj/effect/temp_visual/medical_holosign(get_turf(target), user)

/obj/item/epic_loot/vein_finder/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Medical Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> satchel medical kit.")
	. += span_notice("- <b>1</b> of these + <b>1</b> medical eye-scope can be traded for <b>1</b> advanced satchel medical kit.")

	return .

// Eyescope, a now rare device that was used to check the eyes of patients before the universal health scanner became common
/obj/item/epic_loot/eye_scope
	name = "medical eye-scope"
	desc = "An outdated device used to examine a patient's eyes. Rare now due to the outbreak of the universal health scanner."
	icon_state = "eyescope"
	inhand_icon_state = "zippo"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT*8, \
						/datum/material/glass = SMALL_MATERIAL_AMOUNT*2,)

/obj/item/epic_loot/eye_scope/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Medical Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> first responder surgical kit.")
	. += span_notice("- <b>1</b> of these + <b>1</b> medican vein locator can be traded for <b>1</b> advanced satchel medical kit.")

	return .
