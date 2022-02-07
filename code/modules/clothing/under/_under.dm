/obj/item/clothing/under
	name = "under"
	icon = 'icons/obj/clothing/under/default.dmi'
	worn_icon = 'icons/mob/clothing/under/default.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.9
	slot_flags = ITEM_SLOT_ICLOTHING
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, WOUND = 5)
	equip_sound = 'sound/items/equip/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	limb_integrity = 30
	var/fitted = FEMALE_UNIFORM_FULL // For use in alternate clothing styles for women
	var/has_sensor = HAS_SENSORS // For the crew computer
	var/random_sensor = TRUE
	var/sensor_mode = NO_SENSORS
	var/can_adjust = TRUE
	var/adjusted = NORMAL_STYLE
	var/alt_covers_chest = FALSE // for adjusted/rolled-down jumpsuits, FALSE = exposes chest and arms, TRUE = exposes arms only
	var/obj/item/clothing/accessory/attached_accessory
	var/mutable_appearance/accessory_overlay
	var/mutantrace_variation = NO_MUTANTRACE_VARIATION //Are there special sprites for specific situations? Don't use this unless you need to.
	var/freshly_laundered = FALSE

/obj/item/clothing/under/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform")
	if(HAS_BLOOD_DNA(src))
		. += mutable_appearance('icons/effects/blood.dmi', "uniformblood")
	if(accessory_overlay)
		. += accessory_overlay

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if((has_sensor == BROKEN_SENSORS) && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		C.use(1)
		has_sensor = HAS_SENSORS
		to_chat(user,span_notice("You repair the suit sensors on [src] with [C]."))
		return 1
	if(!attach_accessory(I, user))
		return ..()

/obj/item/clothing/under/attack_hand_secondary(mob/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	toggle()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/under/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_w_uniform()
	if(damaged_state == CLOTHING_SHREDDED && has_sensor > NO_SENSORS)
		has_sensor = BROKEN_SENSORS
	else if(damaged_state == CLOTHING_PRISTINE && has_sensor == BROKEN_SENSORS)
		has_sensor = HAS_SENSORS

/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		sensor_mode = pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS, SENSOR_COORDS)

/obj/item/clothing/under/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(has_sensor > NO_SENSORS)
		if(severity <= EMP_HEAVY)
			has_sensor = BROKEN_SENSORS
			if(ismob(loc))
				var/mob/M = loc
				to_chat(M,span_warning("[src]'s sensors short out!"))
		else
			sensor_mode = pick(SENSOR_OFF, SENSOR_OFF, SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS)
			if(ismob(loc))
				var/mob/M = loc
				to_chat(M,span_warning("The sensors on the [src] change rapidly!"))
		if(ishuman(loc))
			var/mob/living/carbon/human/ooman = loc
			if(ooman.w_uniform == src)
				ooman.update_suit_sensors()


/obj/item/clothing/under/visual_equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = NORMAL_STYLE
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST

	if(mutantrace_variation && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(DIGITIGRADE in H.dna.species.species_traits)
			adjusted = DIGITIGRADE_STYLE
		H.update_inv_w_uniform()

	if(attached_accessory && slot != ITEM_SLOT_HANDS && ishuman(user))
		var/mob/living/carbon/human/H = user
		attached_accessory.on_uniform_equip(src, user)
		H.fan_hud_set_fandom()
		if(attached_accessory.above_suit)
			H.update_inv_wear_suit()

/obj/item/clothing/under/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_ICLOTHING && freshly_laundered)
		freshly_laundered = FALSE
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fresh_laundry", /datum/mood_event/fresh_laundry)

/obj/item/clothing/under/dropped(mob/user)
	if(attached_accessory)
		attached_accessory.on_uniform_dropped(src, user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.fan_hud_set_fandom()
			if(attached_accessory.above_suit)
				H.update_inv_wear_suit()
	..()

/mob/living/carbon/human/update_suit_sensors()
	. = ..()
	update_sensor_list()

/mob/living/carbon/human/proc/update_sensor_list()
	var/obj/item/clothing/under/U = w_uniform
	if(istype(U) && U.has_sensor > 0 && U.sensor_mode)
		GLOB.suit_sensors_list |= src
	else
		GLOB.suit_sensors_list -= src

/mob/living/carbon/human/dummy/update_sensor_list()
	return

/obj/item/clothing/under/proc/attach_accessory(obj/item/tool, mob/user, notifyAttach = 1)
	. = FALSE
	if(!istype(tool, /obj/item/clothing/accessory))
		return
	var/obj/item/clothing/accessory/accessory = tool
	if(attached_accessory)
		if(user)
			to_chat(user, span_warning("[src] already has an accessory."))
		return

	if(!accessory.can_attach_accessory(src, user)) //Make sure the suit has a place to put the accessory.
		return
	if(user && !user.temporarilyRemoveItemFromInventory(accessory))
		return
	if(!accessory.attach(src, user))
		return

	. = TRUE
	if(user && notifyAttach)
		to_chat(user, span_notice("You attach [accessory] to [src]."))

	var/accessory_color = attached_accessory.icon_state
	accessory_overlay = mutable_appearance(attached_accessory.worn_icon, "[accessory_color]")
	accessory_overlay.alpha = attached_accessory.alpha
	accessory_overlay.color = attached_accessory.color

	update_appearance()
	if(!ishuman(loc))
		return

	var/mob/living/carbon/human/holder = loc
	holder.update_inv_w_uniform()
	holder.update_inv_wear_suit()
	holder.fan_hud_set_fandom()

/obj/item/clothing/under/proc/remove_accessory(mob/user)
	. = FALSE
	if(!isliving(user))
		return
	if(!can_use(user))
		return

	if(!attached_accessory)
		return

	. = TRUE
	var/obj/item/clothing/accessory/accessory = attached_accessory
	attached_accessory.detach(src, user)
	if(user.put_in_hands(accessory))
		to_chat(user, span_notice("You detach [accessory] from [src]."))
	else
		to_chat(user, span_notice("You detach [accessory] from [src] and it falls on the floor."))

	update_appearance()
	if(!ishuman(loc))
		return

	var/mob/living/carbon/human/holder = loc
	holder.update_inv_w_uniform()
	holder.update_inv_wear_suit()
	holder.fan_hud_set_fandom()


/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(freshly_laundered)
		. += "It looks fresh and clean."
	if(can_adjust)
		if(adjusted == ALT_STYLE)
			. += "Alt-click on [src] to wear it normally."
		else
			. += "Alt-click on [src] to wear it casually."
	if (has_sensor == BROKEN_SENSORS)
		. += "Its sensors appear to be shorted out."
	else if(has_sensor > NO_SENSORS)
		switch(sensor_mode)
			if(SENSOR_OFF)
				. += "Its sensors appear to be disabled."
			if(SENSOR_LIVING)
				. += "Its binary life sensors appear to be enabled."
			if(SENSOR_VITALS)
				. += "Its vital tracker appears to be enabled."
			if(SENSOR_COORDS)
				. += "Its vital tracker and tracking beacon appear to be enabled."
	if(attached_accessory)
		. += "\A [attached_accessory] is attached to it."

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	if(has_sensor == LOCKED_SENSORS)
		to_chat(usr, "The controls are locked.")
		return
	if(has_sensor == BROKEN_SENSORS)
		to_chat(usr, "The sensors have shorted out!")
		return
	if(has_sensor <= NO_SENSORS)
		to_chat(usr, "This suit does not have any sensors.")
		return

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = tgui_input_list(M, "Select a sensor mode", "Suit Sensors", modes, modes[sensor_mode + 1])
	if(isnull(switchMode))
		return
	if(get_dist(usr, src) > 1)
		to_chat(usr, span_warning("You have moved too far away!"))
		return
	sensor_mode = modes.Find(switchMode) - 1
	if (loc == usr)
		switch(sensor_mode)
			if(0)
				to_chat(usr, span_notice("You disable your suit's remote sensing equipment."))
			if(1)
				to_chat(usr, span_notice("Your suit will now only report whether you are alive or dead."))
			if(2)
				to_chat(usr, span_notice("Your suit will now only report your exact vital lifesigns."))
			if(3)
				to_chat(usr, span_notice("Your suit will now report your exact vital lifesigns as well as your coordinate position."))

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.w_uniform == src)
			H.update_suit_sensors()

/obj/item/clothing/under/AltClick(mob/user)
	. = ..()
	if(.)
		return

	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	if(attached_accessory)
		remove_accessory(user)
	else
		rolldown()

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(!can_use(usr))
		return
	if(!can_adjust)
		to_chat(usr, span_warning("You cannot wear this suit any differently!"))
		return
	if(toggle_jumpsuit_adjust())
		to_chat(usr, span_notice("You adjust the suit to wear it more casually."))
	else
		to_chat(usr, span_notice("You adjust the suit back to normal."))
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_inv_w_uniform()
		H.update_body()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	if(adjusted == DIGITIGRADE_STYLE)
		return
	adjusted = !adjusted
	if(adjusted)
		if(fitted != FEMALE_UNIFORM_TOP)
			fitted = NO_FEMALE_UNIFORM
		if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted (and also the arms, realistically)
			body_parts_covered &= ~CHEST
			body_parts_covered &= ~ARMS
	else
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST
			body_parts_covered |= ARMS
			if(!LAZYLEN(damage_by_parts))
				return adjusted
			for(var/zone in list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)) // ugly check to make sure we don't reenable protection on a disabled part
				if(damage_by_parts[zone] > limb_integrity)
					for(var/part in zone2body_parts_covered(zone))
						body_parts_covered &= part
	return adjusted

/obj/item/clothing/under/rank
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/proc/dump_attachment()
	if(!attached_accessory)
		return
	var/atom/drop_location = drop_location()
	attached_accessory.transform *= 2
	attached_accessory.pixel_x -= 8
	attached_accessory.pixel_y += 8
	if(drop_location)
		attached_accessory.forceMove(drop_location)
	cut_overlays()
	attached_accessory = null
	accessory_overlay = null
	update_appearance()

/obj/item/clothing/under/rank/atom_destruction(damage_flag)
	dump_attachment()
	return ..()
