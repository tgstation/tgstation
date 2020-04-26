#define THERMAL_REGULATOR_COST 18 // the cost per tick for the thermal regulator

//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "spaceold"
	desc = "A special helmet with solar UV shielding to protect your eyes from harmful rays."
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT
	item_state = "spaceold"
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	dynamic_hair_suffix = ""
	dynamic_fhair_suffix = ""
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

/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "spaceold"
	item_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	slowdown = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70)
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

/obj/item/clothing/suit/space/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)

/// Start Processing on the space suit when it is worn to heat the wearer
/obj/item/clothing/suit/space/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING) // Check that the slot is valid
		START_PROCESSING(SSobj, src)

// On removal stop processing, save battery
/obj/item/clothing/suit/space/dropped(mob/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	var/mob/living/carbon/human/human = user
	if(istype(human))
		human.update_spacesuit_hud_icon("0")

// Space Suit temperature regulation and power usage
/obj/item/clothing/suit/space/process()
	var/mob/living/carbon/human/user = src.loc
	if(!user || !ishuman(user) || !(user.wear_suit == src))
		return
	if(!cell && thermal_on)
		toggle_spacesuit()
	if(!cell)
		user.update_spacesuit_hud_icon("missing")
	else
		var/cell_percent = cell.percent()
		if(cell_percent > 0.6)
			user.update_spacesuit_hud_icon("high")
		else if(cell_percent > 0.20)
			user.update_spacesuit_hud_icon("mid")
		else if(cell_percent > 0.01 && cell.charge > THERMAL_REGULATOR_COST)
			user.update_spacesuit_hud_icon("low")
		else
			user.update_spacesuit_hud_icon("empty")

		if(thermal_on && cell.charge >= THERMAL_REGULATOR_COST)
			user.adjust_bodytemperature((temperature_setting - user.bodytemperature), use_steps=TRUE, capped=FALSE)
			cell.use(THERMAL_REGULATOR_COST)

// Clean up the cell on destroy
/obj/item/clothing/suit/space/Destroy()
	if(cell)
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

// object handling for accessing features of the suit
/obj/item/clothing/suit/space/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		toggle_spacesuit_cell(user)
		return
	else if(cell_cover_open && I.tool_behaviour == TOOL_SCREWDRIVER)
		var/range_low = 20 // Default min temp c
		var/range_high = 45 // default max temp c
		if(obj_flags & EMAGGED)
			range_low = -20 // emagged min temp c
			range_high = 120 // emagged max temp c

		var/deg_c = input(user, "What temperature would you like to set the thermal regulator to? \
			([range_low]-[range_high] degrees celcius)") as null|num
		if(deg_c && deg_c >= range_low && deg_c <= range_high)
			temperature_setting = round(T0C + deg_c, 0.1)
			to_chat(user, "<span class='notice'>You see the readout change to [deg_c] c.</span>")
		return
	else if(cell_cover_open && istype(I, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell installed.</span>")
			return
		if(user.transferItemToLoc(I, src))
			cell = I
			to_chat(user, "<span class='notice'>You successfully install \the [cell] into [src].</span>")
			return
	return ..()

/// Open the cell cover when ALT+Click on the suit
/obj/item/clothing/suit/space/AltClick(mob/living/user)
	if(!user || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return ..()
	toggle_spacesuit_cell(user)

/// Remove the cell whent he cover is open on CTRL+Click
/obj/item/clothing/suit/space/CtrlClick(mob/living/user)
	if(user && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
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
		user.visible_message("<span class='notice'>[user] removes \the [cell] from [src]!</span>", \
			"<span class='notice'>You remove [cell].</span>")
		cell.add_fingerprint(user)
		user.put_in_hands(cell)
		cell = null

/// Toggle the space suit's cell cover
/obj/item/clothing/suit/space/proc/toggle_spacesuit_cell(mob/user)
	cell_cover_open = !cell_cover_open
	to_chat(user, "<span class='notice'>You [cell_cover_open ? "open" : "close"] the cell cover on \the [src].</span>")

/// Toggle the space suit's thermal regulator status
/obj/item/clothing/suit/space/proc/toggle_spacesuit()
	thermal_on = !thermal_on
	min_cold_protection_temperature = thermal_on ? SPACE_SUIT_MIN_TEMP_PROTECT : SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	SEND_SIGNAL(src, COMSIG_SUIT_SPACE_TOGGLE)

// let emags override the temperature settings
/obj/item/clothing/suit/space/emag_act(mob/user)
	if(!(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		user.visible_message("<span class='warning'>You emag [src], overwriting thermal regulator restrictions.</span>")
		log_game("[key_name(user)] emagged [src] at [AREACOORD(src)], overwriting thermal regulator restrictions.")
	playsound(src, "sparks", 50, TRUE)

// zap the cell if we get hit with an emp
/obj/item/clothing/suit/space/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	if(cell)
		cell.emp_act(severity)

#undef THERMAL_REGULATOR_COST
