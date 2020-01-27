#define THERMAL_REGULATOR_COST 16 // the cost per tick for the thermal regulator

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
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	equip_delay_other = 80
	resistance_flags = NONE
	actions_types = list(/datum/action/item_action/toggle_spacesuit, /datum/action/item_action/toggle_spacesuit_cell)
	var/temperature_setting = BODYTEMP_NORMAL /// The default temperature setting
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high /// If this is a path, this gets created as an object in Initialize.
	var/cell_cover_open = FALSE /// Status of the cell cover on the suit
	var/thermal_on = TRUE /// Status of the thermal regulator

/obj/item/clothing/suit/space/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)

// Turn on the suit when it is worn
/obj/item/clothing/suit/space/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING) // Check that the slot is valid
		START_PROCESSING(SSobj, src)

// On removal turn off
/obj/item/clothing/suit/space/dropped(mob/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)

// Space Suit temperature regulation and power usage
/obj/item/clothing/suit/space/process()
	if(thermal_on && cell.charge >= THERMAL_REGULATOR_COST)
		var/mob/living/carbon/human/user = src.loc
		if(user && ishuman(user) && user.wear_suit == src)
			var/temp_diff = temperature_setting - user.bodytemperature
			user.adjust_bodytemperature(temp_diff) // TODO: use_steps=True when #48920 merged
			cell.charge -= THERMAL_REGULATOR_COST

// Clean up the cell on destroy
/obj/item/clothing/suit/space/Destroy()
	cell = null
	return ..()

/obj/item/clothing/suit/space/get_cell()
	return cell

/obj/item/clothing/suit/space/examine(mob/user)
	. = ..()
	. += "Thermal regulator is [thermal_on ? "on" : "off"], the temperature is set to \
		[round(temperature_setting-T0C,0.1)] &deg;C ([round(temperature_setting*1.8-459.67,0.1)] &deg;F)"
	. += "Charge remaining: [cell ? "[cell.charge / cell.maxcharge * 100]%" : "invalid"]"
	if(cell_cover_open)
		. += "The cell cover is open!"
		if(!cell)
			. += "The slot for a cell is empty."
		else
			. += "\The [cell] is in place."

/obj/item/clothing/suit/space/attackby(obj/item/I, mob/user, params)
	if(cell_cover_open && I.tool_behaviour == TOOL_SCREWDRIVER)
		var/deg_c = input(user, "What temperature would you like to set the thermal regulator to? \
			(20-45 degrees celcius)") as null|num
		if(deg_c && deg_c >= 20 && deg_c <= 45)
			temperature_setting = round(T0C + deg_c, 0.1)
			to_chat(user, "<span class='notice'>You see the readout change to [deg_c] c.</span>")
	else if(istype(I, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell installed.</span>")
			return
		if(user.transferItemToLoc(I, src))
			cell = I
			to_chat(user, "<span class='notice'>You successfully install \the [cell] into [src].</span>")
			return
	return ..()

/obj/item/clothing/suit/space/attack_self(mob/user)
	if(cell_cover_open && cell)
		user.visible_message("<span class='notice'>[user] removes \the [cell] from [src]!</span>", \
			"<span class='notice'>You remove [cell].</span>")
		cell.add_fingerprint(user)
		user.put_in_hands(cell)
		cell = null

/obj/item/clothing/suit/space/proc/toggle_spacesuit_cell(mob/user)
	cell_cover_open = !cell_cover_open
	to_chat(user, "<span class='notice'>You [cell_cover_open ? "open" : "close"] the cell cover on \the [src].</span>")

/obj/item/clothing/suit/space/proc/toggle_spacesuit(mob/user)
	thermal_on = !thermal_on
	to_chat(user, "<span class='notice'>You turn [thermal_on ? "on" : "off"] the thermal regulator on \the [src].</span>")

#undef THERMAL_REGULATOR_COST
