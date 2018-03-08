/obj/item/clothing/head/helmet/space/hardsuit
	var/next_warn_rad = 0
	var/warn_rad_cooldown = 180

/obj/item/clothing/suit/space/hardsuit
	var/next_warn_acid = 0
	var/warn_acid_cooldown = 150

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(severity)
	..()

	if (prob(33))
		if (next_warn_rad > world.time)
			return
		next_warn_rad = world.time + warn_rad_cooldown
		display_visor_message("Radiation present, seek distance from source!")

/obj/item/clothing/suit/space/hardsuit/acid_act()
	..()

	if (prob(33))
		if(helmet)
			if(next_warn_acid > world.time)
				return
			next_warn_acid = world.time + warn_acid_cooldown
			helmet.display_visor_message("Corrosive Chemical Detected!")


//Crytek Nanosuit
/obj/item/clothing/mask/gas/nano_mask
	name = "nanosuit gas mask"
	desc = "A robust gas mask." //More accurate
	icon_state = "syndicate"
	strip_delay = 60


/obj/item/clothing/glasses/nano_goggles
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	alternate_worn_icon = 'hippiestation/icons/mob/eyes.dmi'
	icon = 'hippiestation/icons/obj/clothing/glasses.dmi'
	icon_state = "nvgmesonnano"
	item_state = "nvgmesonnano"
	glass_colour_type = /datum/client_colour/glass_colour/green
	darkness_view = 6
	vision_flags = SEE_BLACKNESS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE


/obj/item/clothing/head/helmet/space/hardsuit/nano
	name = "nanosuit helmet"
	desc = "Some sort of alien future suit helmet. It looks very robust."
	alternate_worn_icon = 'hippiestation/icons/mob/head.dmi'
	icon = 'hippiestation/icons/obj/clothing/hats.dmi'
	icon_state = "nanohelmet"
	item_state = "nanohelmet"
	item_color = "nano"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 45, "bomb" = 70, "bio" = 100, "rad" = 80, "fire" = 100, "acid" = 100)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	var/obj/item/clothing/mask/gas/nanomask
	var/obj/item/clothing/mask/gas/nanogoggles
	var/visagetoggled = FALSE
	actions_types = list()


/obj/item/clothing/suit/space/hardsuit/nano
	alternate_worn_icon = 'hippiestation/icons/mob/suit.dmi'
	icon = 'hippiestation/icons/obj/clothing/suits.dmi'
	icon_state = "nanosuit"
	item_state = "nanosuit"
	name = "nanosuit"
	desc = "Some sort of alien future suit. It looks very robust."
	w_class = WEIGHT_CLASS_NORMAL
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 45, "bomb" = 70, "bio" = 100, "rad" = 80, "fire" = 100, "acid" = 100)
	allowed = list(/obj/item/tank/internals)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/nano
	slowdown = 0.5
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	actions_types = list(/datum/action/item_action/nanosuit/armor, /datum/action/item_action/nanosuit/cloak, /datum/action/item_action/nanosuit/speed, /datum/action/item_action/nanosuit/strength)
	jetpack = /obj/item/tank/jetpack/suit
	var/obj/item/stock_parts/cell/cell //What type of power cell this uses
	var/cell_type = /obj/item/stock_parts/cell{charge = 100; maxcharge = 100}
	var/charge_tick = 0
	var/charge_delay = 4
	var/charge_rate = 10
	var/hit_use = 20
	var/idle_use = 5
	var/move_use = 10
	var/low_use = 2
	var/criticalpower = FALSE
	var/mode = ""


/obj/item/clothing/suit/space/hardsuit/nano/emp_act(severity)
	..()
	cell.use(round(cell.charge / severity))
	update_icon()

/obj/item/clothing/suit/space/hardsuit/nano/get_cell()
	return cell

/obj/item/clothing/suit/space/hardsuit/nano/Initialize()
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	cell.give(cell.maxcharge)
	START_PROCESSING(SSobj, src)
	update_icon()


/obj/item/clothing/suit/space/hardsuit/nano/Destroy()
	QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/space/hardsuit/nano/process()
	var/mob/living/carbon/human/H = src.loc
	if(mode == "")
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!cell)
			return
		cell.give(charge_rate)
	else
		if(cell.charge > 20)
			cell.use(idle_use)
			criticalpower = FALSE
		if(cell.charge <= 20)
			cell.use(low_use)
			if(!criticalpower)
				helmet.display_visor_message("Energy Critical!")
				criticalpower = !criticalpower
		if (cell.charge <= 1)
			helmet.display_visor_message(mode == "armor" ? "Armour Disabled!" : mode == "speed" ? "Speed Disabled!" : mode == "strength" ? "Strength Disabled!" : mode == "cloak" ? "Cloak Disalbed!" : "")
			slowdown = 0.5
			H.alpha = 255
			armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 45, "bomb" = 70, "bio" = 100, "rad" = 80, "fire" = 100, "acid" = 100)
			mode = ""
			return

	if(mode == "speed")
		if(cell.charge > 20)
			slowdown = -0.5
		else if(cell.charge <= 20)
			slowdown = 0.25



/obj/item/clothing/suit/space/hardsuit/nano/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	//recharge_cooldown = world.time + recharge_delay let the other stuff handle this
	if(mode == "armor" || "cloak")
		if(cell.charge > 0)
			cell.use(hit_use)
	if(mode == "armor")
		return 1
	return 0

/obj/item/clothing/suit/space/hardsuit/nano/ui_action_click(mob/user, datum/action/action)
	return

/obj/item/clothing/suit/space/hardsuit/nano/proc/can_toggle()
	return cell.charge > 0

/datum/action/item_action/nanosuit/armor/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't toggles modules while you're incapacitated.</span>")
		return
	var/obj/item/clothing/suit/space/hardsuit/nano/NS = target
	if(istype(NS))
		if(NS.mode == "armor")
			NS.slowdown = 0.5
			NS.helmet.display_visor_message("Armor Disabled!.")
			NS.mode = ""
			owner.alpha = 255
			armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 45, "bomb" = 70, "bio" = 100, "rad" = 80, "fire" = 100, "acid" = 100)
		else
			if(NS.can_toggle())
				NS.helmet.display_visor_message("Maximum Armor!")
				NS.slowdown = 1.0
				NS.mode = "armor"
				owner.alpha = 255
				armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 65, "bomb" = 100, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 100)
			else NS.helmet.display_visor_message("Insufficient Charge!")

/datum/action/item_action/nanosuit/speed/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't toggles modules while you're incapacitated.</span>")
		return
	var/obj/item/clothing/suit/space/hardsuit/nano/NS = target
	if(istype(NS))
		if(NS.mode == "speed")
			NS.slowdown = 0.5
			NS.helmet.display_visor_message("Speed Disabled!")
			NS.mode = ""
			owner.alpha = 255
		else
			if(NS.can_toggle())
				NS.helmet.display_visor_message("Maximum Speed!")
				NS.mode = "speed"
				if(NS.cell.charge > 20)
					NS.slowdown = -0.5
				else if(NS.cell.charge <= 20)
					NS.slowdown = 0.25
				owner.alpha = 255
			else NS.helmet.display_visor_message("Insufficient Charge!")

/datum/action/item_action/nanosuit/strength/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't toggles modules while you're incapacitated.</span>")
		return
	var/obj/item/clothing/suit/space/hardsuit/nano/NS = target
	if(istype(NS))
		if(NS.mode == "strength")
			NS.helmet.display_visor_message("Strength Disabled!")
			NS.mode = ""
			owner.alpha = 255
		else
			if(NS.can_toggle())
				NS.helmet.display_visor_message("Maximum Strength!")
				NS.mode = "strength"
				NS.slowdown = 0.5
				owner.alpha = 255
			else NS.helmet.display_visor_message("Insufficient Charge!")

/datum/action/item_action/nanosuit/cloak/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't toggles modules while you're incapacitated.</span>")
		return
	var/obj/item/clothing/suit/space/hardsuit/nano/NS = target
	if(istype(NS))
		if(NS.mode == "cloak")
			NS.slowdown = 0.5
			NS.helmet.display_visor_message("Cloak Disabled!")
			owner.alpha = 255
			NS.mode = ""
		else
			if(NS.can_toggle())
				NS.helmet.display_visor_message("Cloak Engaged!")
				NS.slowdown = 0.4
				owner.alpha = 25
				NS.mode = "cloak"
			else NS.helmet.display_visor_message("Insufficient Charge!")


/datum/action/item_action/nanosuit/armor
	name = "Armor Mode"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_defense_mode_on"


/datum/action/item_action/nanosuit/cloak
	name = "Cloak Mode"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_defense_mode_on"


/datum/action/item_action/nanosuit/speed
	name = "Speed Mode"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_defense_mode_on"


/datum/action/item_action/nanosuit/strength
	name = "Strength Mode"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_defense_mode_on"


/obj/item/clothing/glasses/nano_goggles/equipped(mob/user, slot)
	.=..()
	if(slot == slot_glasses)
		flags_1 |= NODROP_1

/obj/item/clothing/mask/gas/nano_mask/equipped(mob/user, slot)
	.=..()
	if(slot == slot_wear_mask)
		flags_1 |= NODROP_1


/obj/item/clothing/head/helmet/space/hardsuit/nano/Initialize()
	nanomask = make_mask()
	nanogoggles = make_goggles()
	.=..()

/obj/item/clothing/head/helmet/space/hardsuit/nano/proc/make_mask()
	return new /obj/item/clothing/mask/gas/nano_mask(src)

/obj/item/clothing/head/helmet/space/hardsuit/nano/proc/make_goggles()
	return new /obj/item/clothing/glasses/nano_goggles(src)

/obj/item/clothing/suit/space/hardsuit/nano/equipped(mob/user, slot)
	var/mob/living/carbon/human/H = src.loc
	if(slot == slot_wear_suit)
		flags_1 |= NODROP_1
		if(istype(H.wear_mask) || istype(H.head) || istype(H.glasses))
//		H.visible_message("<span class='warning'>[H] casts off their [suit_name_simple]!</span>", "<span class='warning'>We cast off our [suit_name_simple].</span>", "<span class='italics'>You hear the organic matter ripping and tearing!</span>")
			H.temporarilyRemoveItemFromInventory(H.head, FALSE) //The qdel on dropped() takes care of it
			H.temporarilyRemoveItemFromInventory(H.wear_mask, FALSE)
			H.temporarilyRemoveItemFromInventory(H.glasses, FALSE)
			H.update_inv_wear_mask()
			H.update_inv_head()
			H.update_hair()
			H.update_inv_glasses()
		ToggleHelmet()
	..()

/obj/item/clothing/head/helmet/space/hardsuit/nano/equipped(mob/user, slot)
	if(slot == slot_head)
		flags_1 |= NODROP_1
		ToggleVisage()
	..()

/obj/item/clothing/head/helmet/space/hardsuit/nano/proc/ToggleVisage()
	var/mob/living/carbon/human/H = src.loc
	if (!nanomask && !nanogoggles)
		return
	if(!visagetoggled)
		if(ishuman(src.loc))
			/*if(H.head != src)
				to_chat(H, "<span class='warning'>You must be wearing [src] to engage the helmet!</span>")
				return
			if(H.wear_mask)
				to_chat(H, "<span class='warning'>You're already wearing something on your face!</span>")
				return*/
			if(H.equip_to_slot_if_possible(nanomask,slot_wear_mask,0,0,1) && H.equip_to_slot_if_possible(nanogoggles,slot_glasses,0,0,1))
				//to_chat(H, "<span class='notice'>You engage the mask and visor on the hardsuit.</span>")
				H.update_inv_wear_mask()
				H.update_inv_glasses()
			visagetoggled = TRUE
	else
		RemoveVisage()


/obj/item/clothing/head/helmet/space/hardsuit/nano/proc/RemoveVisage()
	visagetoggled = FALSE
	if(!nanomask && !nanogoggles)
		return
	if(ishuman(nanomask.loc) || ishuman(nanogoggles.loc))
		var/mob/living/carbon/H = nanomask.loc
		nanomask.attack_self(H)
		H.transferItemToLoc(nanomask, src, TRUE)
		H.update_inv_wear_mask()
		nanogoggles.attack_self(H)
		H.transferItemToLoc(nanogoggles, src, TRUE)
		H.update_inv_glasses()
		to_chat(H, "<span class='notice'>The mask and visor on the hardsuit disengages.</span>")
	else
		nanomask.forceMove(src)
		nanogoggles.forceMove(src)

/obj/item/clothing/head/helmet/space/hardsuit/nano/Destroy()
	RemoveVisage()
	qdel(nanomask)
	nanomask = null
	qdel(nanogoggles)
	nanogoggles = null
	return ..()
