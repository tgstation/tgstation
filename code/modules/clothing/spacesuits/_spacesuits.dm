#define THERMAL_REGULATOR_COST 18 // the cost per tick for the thermal regulator

//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	worn_icon = 'icons/mob/clothing/head/spacehelm.dmi'
	icon_state = "spaceold"
	inhand_icon_state = "space_helmet"
	desc = "A special helmet with solar UV shielding to protect your eyes from harmful rays."
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | STACKABLE_HELMET_EXEMPT | HEADINTERNALS
	armor_type = /datum/armor/helmet_space
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	strip_delay = 50
	equip_delay_other = 50
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE
	dog_fashion = null

/datum/armor/helmet_space
	bio = 100
	fire = 80
	acid = 70

/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "spaceold"
	icon = 'icons/obj/clothing/suits/spacesuit.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	worn_icon = 'icons/mob/clothing/suits/spacesuit.dmi'
	inhand_icon_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack/oxygen/captain,
		)
	slowdown = 1
	armor_type = /datum/armor/suit_space
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	equip_delay_other = 80
	resistance_flags = NONE
	actions_types = list(/datum/action/item_action/toggle_spacesuit)
	var/temperature_setting = BODYTEMP_NORMAL /// The default temperature setting
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high /// If this is a path, this gets created as an object in Initialize.
	var/cell_cover_open = FALSE /// Status of the cell cover on the suit
	var/thermal_on = FALSE /// Status of the thermal regulator
	var/show_hud = TRUE /// If this is FALSE the batery status UI will be disabled. This is used for suits that don't use bateries like the changeling's flesh suit mutation.

/datum/armor/suit_space
	bio = 100
	fire = 80
	acid = 70

/obj/item/clothing/suit/space/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)

/// Start Processing on the space suit when it is worn to heat the wearer
/obj/item/clothing/suit/space/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING) // Check that the slot is valid
		START_PROCESSING(SSobj, src)
		update_hud_icon(user) // update the hud
		RegisterSignal(user, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))

// On removal stop processing, save battery
/obj/item/clothing/suit/space/dropped(mob/living/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(user, COMSIG_MOB_GET_STATUS_TAB_ITEMS)
	var/mob/living/carbon/carbon_user = user
	if(istype(carbon_user))
		carbon_user.update_spacesuit_hud_icon("0")

/obj/item/clothing/suit/space/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	items += "Thermal Regulator: [thermal_on ? "On" : "Off"]"
	items += "Cell Charge: [cell ? "[round(cell.percent(), 0.1)]%" : "No Cell!"]"

// Space Suit temperature regulation and power usage
/obj/item/clothing/suit/space/process(seconds_per_tick)
	var/mob/living/carbon/human/user = loc
	if(!user || !ishuman(user) || user.wear_suit != src)
		return

	// Do nothing if thermal regulators are off
	if(!thermal_on)
		return

	// If we got here, thermal regulators are on. If there's no cell, turn them off
	if(!cell)
		toggle_spacesuit(user, FALSE)
		update_hud_icon(user)
		return

	// cell.use will return FALSE if charge is lower than THERMAL_REGULATOR_COST
	if(!cell.use(THERMAL_REGULATOR_COST))
		toggle_spacesuit(user, FALSE)
		update_hud_icon(user)
		to_chat(user, span_warning("The thermal regulator cuts off as [cell] runs out of charge."))
		return

	// If we got here, it means thermals are on, the cell is in and the cell has
	// just had enough charge subtracted from it to power the thermal regulator
	user.adjust_bodytemperature(get_temp_change_amount((temperature_setting - user.bodytemperature), 0.08 * seconds_per_tick))
	update_hud_icon(user)

// Clean up the cell on destroy
/obj/item/clothing/suit/space/Destroy()
	if(isatom(cell))
		QDEL_NULL(cell)
	var/mob/living/carbon/human/human = src.loc
	if(istype(human))
		human.update_spacesuit_hud_icon("0")
	STOP_PROCESSING(SSobj, src)
	return ..()

// Clean up the cell on destroy
/obj/item/clothing/suit/space/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		thermal_on = FALSE
	return ..()

// support for items that interact with the cell
/obj/item/clothing/suit/space/get_cell()
	return cell

// Show the status of the suit and the cell
/obj/item/clothing/suit/space/examine(mob/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		. += "The thermal regulator is [thermal_on ? "on" : "off"] and the temperature is set to \
			[round(temperature_setting-T0C,0.1)] &deg;C ([round(temperature_setting*1.8-459.67,0.1)] &deg;F)"
		. += "The power meter shows [cell ? "[round(cell.percent(), 0.1)]%" : "!invalid!"] charge remaining."
		if(cell_cover_open)
			. += "The cell cover is open exposing the cell and setting knobs."
			if(!cell)
				. += "The slot for a cell is empty."
			else
				. += "\The [cell] is firmly in place."

/obj/item/clothing/suit/space/crowbar_act(mob/living/user, obj/item/tool)
	toggle_spacesuit_cell(user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/clothing/suit/space/screwdriver_act(mob/living/user, obj/item/tool)
	var/range_low = 20 // Default min temp c
	var/range_high = 45 // default max temp c
	if(obj_flags & EMAGGED)
		range_low = -20 // emagged min temp c
		range_high = 120 // emagged max temp c

	var/deg_c = input(user, "What temperature would you like to set the thermal regulator to? \
		([range_low]-[range_high] degrees celcius)") as null|num
	if(deg_c && deg_c >= range_low && deg_c <= range_high)
		temperature_setting = round(T0C + deg_c, 0.1)
		to_chat(user, span_notice("You see the readout change to [deg_c] c."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

// object handling for accessing features of the suit
/obj/item/clothing/suit/space/attackby(obj/item/I, mob/user, params)
	if(!cell_cover_open || !istype(I, /obj/item/stock_parts/cell))
		return ..()
	if(cell)
		to_chat(user, span_warning("[src] already has a cell installed."))
		return
	if(user.transferItemToLoc(I, src))
		cell = I
		to_chat(user, span_notice("You successfully install \the [cell] into [src]."))
		return

/// Open the cell cover when ALT+Click on the suit
/obj/item/clothing/suit/space/AltClick(mob/living/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return ..()
	toggle_spacesuit_cell(user)

/// Remove the cell whent he cover is open on CTRL+Click
/obj/item/clothing/suit/space/CtrlClick(mob/living/user)
	if(user.can_perform_action(src, NEED_DEXTERITY))
		if(cell_cover_open && cell)
			remove_cell(user)
			return
	return ..()

// Remove the cell when using the suit on its self
/obj/item/clothing/suit/space/attack_self(mob/user)
	remove_cell(user)

/// Remove the cell from the suit if the cell cover is open
/obj/item/clothing/suit/space/proc/remove_cell(mob/user)
	if(cell_cover_open && cell)
		user.visible_message(span_notice("[user] removes \the [cell] from [src]!"), \
			span_notice("You remove [cell]."))
		cell.add_fingerprint(user)
		user.put_in_hands(cell)
		cell = null

/// Toggle the space suit's cell cover
/obj/item/clothing/suit/space/proc/toggle_spacesuit_cell(mob/user)
	cell_cover_open = !cell_cover_open
	to_chat(user, span_notice("You [cell_cover_open ? "open" : "close"] the cell cover on \the [src]."))

/**
 * Toggle the space suit's thermal regulator status
 *
 * Toggle the space suit's thermal regulator status...
 * Can't do it if it has no charge.
 * Arguments:
 * * toggler - User mob who recieves the to_chat messages.
 * * manual_toggle - If false get a differently-flavored message about it being disabled by itself
 */
/obj/item/clothing/suit/space/proc/toggle_spacesuit(mob/toggler, manual_toggle = TRUE)
	// If we're turning thermal protection on, check for valid cell and for enough
	// charge that cell. If it's too low, we shouldn't bother with setting the
	// thermal protection value and should just return out early.
	if(!thermal_on && (!cell || cell.charge < THERMAL_REGULATOR_COST))
		if(toggler)
			to_chat(toggler, span_warning("The thermal regulator on [src] has no charge."))
		return

	thermal_on = !thermal_on
	min_cold_protection_temperature = thermal_on ? SPACE_SUIT_MIN_TEMP_PROTECT : SPACE_SUIT_MIN_TEMP_PROTECT_OFF

	update_item_action_buttons()

	if(!toggler)
		return
	if(manual_toggle)
		to_chat(toggler, span_notice("You turn [thermal_on ? "on" : "off"] [src]'s thermal regulator."))
	else
		to_chat(toggler, span_danger("You feel [src]'s thermal regulator switch [thermal_on ? "on" : "off"] by itself!"))

/obj/item/clothing/suit/space/ui_action_click(mob/user, actiontype)
	toggle_spacesuit(user)

// let emags override the temperature settings
/obj/item/clothing/suit/space/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	if (user)
		balloon_alert(user, "thermal regulator restrictions overridden")
		user.log_message("emagged [src], overwriting thermal regulator restrictions.", LOG_GAME)
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

// update the HUD icon
/obj/item/clothing/suit/space/proc/update_hud_icon(mob/user)
	var/mob/living/carbon/human/human = user

	if(!show_hud)
		return

	if(!cell)
		human.update_spacesuit_hud_icon("missing")
		return

	var/cell_percent = cell.percent()

	// Check if there's enough charge to trigger a thermal regulator tick and
	// if there is, whethere the cell's capacity indicates high, medium or low
	// charge based on it.
	if(cell.charge >= THERMAL_REGULATOR_COST)
		if(cell_percent > 60)
			human.update_spacesuit_hud_icon("high")
			return
		if(cell_percent > 20)
			human.update_spacesuit_hud_icon("mid")
			return
		human.update_spacesuit_hud_icon("low")
		return

	human.update_spacesuit_hud_icon("empty")
	return

// zap the cell if we get hit with an emp
/obj/item/clothing/suit/space/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	if(cell)
		cell.emp_act(severity)

/obj/item/clothing/head/helmet/space/suicide_act(mob/living/carbon/user)
	var/datum/gas_mixture/environment = user.loc.return_air()
	if(HAS_TRAIT(user, TRAIT_RESISTCOLD) || !environment || environment.return_temperature() >= user.get_body_temp_cold_damage_limit())
		user.visible_message(span_suicide("[user] is beating [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS
	user.say("You want proof? I'll give you proof! Here's proof of what'll happen to you if you stay here with your stuff!", forced = "space helmet suicide")
	user.visible_message(span_suicide("[user] is removing [user.p_their()] helmet to make a point! Yo, holy shit, [user.p_they()] dead!")) //the use of p_they() instead of p_their() here is intentional
	user.adjust_bodytemperature(-300)
	user.apply_status_effect(/datum/status_effect/freon)
	if(!ishuman(user))
		return FIRELOSS
	var/mob/living/carbon/human/humanafterall = user
	var/datum/disease/advance/cold/pun = new //in the show, arnold survives his stunt, but catches a cold because of it
	humanafterall.ForceContractDisease(pun, FALSE, TRUE) //this'll show up on health analyzers and the like
	return FIRELOSS

#undef THERMAL_REGULATOR_COST
