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
	actions_types = list(/datum/action/item_action/nanogoggles/toggle)
	var/on = FALSE

/obj/item/clothing/glasses/nano_goggles/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/nanogoggles/toggle))
		nvgmode(user)
		return TRUE
	return FALSE

/obj/item/clothing/glasses/nano_goggles/proc/nvgmode(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't toggles the goggles while you're incapacitated.</span>")
		return
	if(!on)
		darkness_view = 8
		vision_flags = SEE_BLACKNESS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		on=!on
	else
		vision_flags = NONE
		darkness_view = 2
		lighting_alpha = null
		on=!on

	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.glasses == src)
			U.update_sight()


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
	var/mob/living/carbon/human/U = null
	var/obj/item/stock_parts/cell/cell //What type of power cell this uses
	var/cell_type = /obj/item/stock_parts/cell{charge = 100; maxcharge = 100}
//	var/charge_tick = 0
//	var/charge_delay = 2
	var/charge_rate = 20
	var/hit_use = 20
	var/move_use = 1
	var/criticalpower = FALSE
	var/mode = "none"
	var/recharge_cooldown = 0
	var/recharge_delay = 30
	var/consumeonmove = FALSE
	var/moving = FALSE
	var/curLoc
	var/lastLoc


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
	curLoc = src.loc
	if(cell.charge > 0 && consumeonmove == TRUE)
		if(curLoc == lastLoc)
			moving = FALSE
		lastLoc = curLoc

	if(moving == FALSE && mode != "cloak")
		if(world.time > recharge_cooldown)
			if(!cell)
				return
			cell.give(charge_rate)
			recharge_cooldown = world.time + recharge_delay

	if(cell.charge > 20)
			//cell.use(idle_use)
		criticalpower = FALSE
	else if(cell.charge <= 20)
			//cell.use(low_use)
		if(!criticalpower)
			helmet.display_visor_message("Energy Critical!")
			criticalpower = !criticalpower

	if(cell.charge <= 0)
		armor_cancel()
		cloak_cancel()
		speed_cancel()
		strength_cancel()
		cell.charge = 0
	if(mode == "cloak")
		cell.use(1)


/obj/item/clothing/suit/space/hardsuit/nano/hit_reaction(mob/living/carbon/human/user, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	//recharge_cooldown = world.time + recharge_delay let the other stuff handle this
	if(mode == "armor" || "cloak")
		if(cell.charge > 0)
			cell.use(hit_use)
		else if(cell <= 20)
			cell.charge = 0
			armor_cancel()
			cloak_cancel()
	if(mode == "armor")
		return 1
	return 0

/obj/item/clothing/suit/space/hardsuit/nano/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/nanosuit/armor))
		armormode()
		return TRUE
	if(istype(action, /datum/action/item_action/nanosuit/cloak))
		cloakmode()
		return TRUE
	if(istype(action, /datum/action/item_action/nanosuit/speed))
		speedmode()
		return TRUE
	if(istype(action, /datum/action/item_action/nanosuit/strength))
		strengthmode()
		return TRUE
	return FALSE


/obj/item/clothing/suit/space/hardsuit/nano/proc/can_toggle()
	if(cell.charge <= 0)
		helmet.display_visor_message("Insufficient Charge!")
		return FALSE
	return TRUE

/obj/item/clothing/suit/space/hardsuit/nano/proc/armormode()
	if(!U.incapacitated())
		armor_toggle()
	else
		to_chat(U, "<span class='warning'>You can't toggles modules while you're incapacitated.</span>")

/obj/item/clothing/suit/space/hardsuit/nano/proc/armor_toggle()
	if(!U)
		return
	if(mode == "armor")
		armor_cancel()
	else
		if(can_toggle())
			cloak_cancel()
			speed_cancel()
			strength_cancel()
			helmet.display_visor_message("Maximum Armor!")
			slowdown = 1.0
			mode = "armor"
			armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 65,
							"bomb" = 100, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 100)


/obj/item/clothing/suit/space/hardsuit/nano/proc/armor_cancel()
	if(!U)
		return 0

	if(mode == "armor")
		recharge_cooldown = world.time + recharge_delay
		slowdown = 0.5
		helmet.display_visor_message("Armor Disabled!")
		mode = "none"
		armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 45,
						"bomb" = 70, "bio" = 100, "rad" = 80, "fire" = 100, "acid" = 100)
		return 1
	return 0


/obj/item/clothing/suit/space/hardsuit/nano/proc/cloakmode()
	if(!U.incapacitated())
		cloak_toggle()
	else
		to_chat(U, "<span class='warning'>You can't toggles modules while you're incapacitated.</span>")

/obj/item/clothing/suit/space/hardsuit/nano/proc/cloak_toggle()
	if(!U)
		return
	if(mode == "cloak")
		cloak_cancel()
	else
		if(can_toggle())
			armor_cancel()
			speed_cancel()
			strength_cancel()
			consumeonmove = TRUE
			helmet.display_visor_message("Cloak Engaged!")
			slowdown = 0.4
			mode = "cloak"
			animate(U, alpha = 25, time = 2)

/obj/item/clothing/suit/space/hardsuit/nano/proc/cloak_cancel()
	if(!U)
		return 0

	if(mode == "cloak")
		recharge_cooldown = world.time + recharge_delay
		slowdown = 0.5
		consumeonmove = FALSE
		moving = FALSE
		helmet.display_visor_message("Cloak Disabled!")
		mode = "none"
		animate(U, alpha = 255, time = 5)
		return 1
	return 0


/obj/item/clothing/suit/space/hardsuit/nano/proc/speedmode()
	if(!U.incapacitated())
		speed_toggle()
	else
		to_chat(U, "<span class='warning'>You can't toggles modules while you're incapacitated.</span>")

/obj/item/clothing/suit/space/hardsuit/nano/proc/speed_toggle()
	if(!U)
		return
	if(mode == "speed")
		speed_cancel()
	else
		if(can_toggle())
			armor_cancel()
			cloak_cancel()
			strength_cancel()
			consumeonmove = TRUE
			helmet.display_visor_message("Maximum Speed!")
			U.add_trait(TRAIT_GOTTAGOFAST, "speed mode")
			U.adjustOxyLoss(-5, 0)
			U.adjustStaminaLoss(-10)
			mode = "speed"


/obj/item/clothing/suit/space/hardsuit/nano/proc/speed_cancel()
	if(!U)
		return 0

	if(mode == "speed")
		recharge_cooldown = world.time + recharge_delay
		U.remove_trait(TRAIT_GOTTAGOFAST, "speed mode")
		consumeonmove = FALSE
		moving = FALSE
		helmet.display_visor_message("Speed Disabled!")
		mode = "none"
		return 1
	return 0


/obj/item/clothing/suit/space/hardsuit/nano/proc/strengthmode()
	if(!U.incapacitated())
		strength_toggle()
	else
		to_chat(U, "<span class='warning'>You can't toggles modules while you're incapacitated.</span>")

/obj/item/clothing/suit/space/hardsuit/nano/proc/strength_toggle()
	if(!U)
		return
	if(mode == "strength")
		strength_cancel()
	else
		if(can_toggle())
			armor_cancel()
			cloak_cancel()
			speed_cancel()
			helmet.display_visor_message("Maximum Strength!")
			mode = "strength"

/obj/item/clothing/suit/space/hardsuit/nano/proc/strength_cancel()
	if(!U)
		return 0

	if(mode == "strength")
		recharge_cooldown = world.time + recharge_delay
		//animate(U, alpha = 255, time = 5)
		helmet.display_visor_message("Strength Disabled!")
		mode = "none"
		return 1
	return 0


/datum/action/item_action/nanogoggles/toggle
	name = "Night Vision"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_defense_mode_on"


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
	if(ishuman(user))
		U = user
	if(slot == slot_wear_suit)
		flags_1 |= NODROP_1
		if(istype(U.wear_mask) || istype(U.head) || istype(U.glasses))
//		H.visible_message("<span class='warning'>[H] casts off their [suit_name_simple]!</span>", "<span class='warning'>We cast off our [suit_name_simple].</span>", "<span class='italics'>You hear the organic matter ripping and tearing!</span>")
			U.temporarilyRemoveItemFromInventory(U.head, FALSE) //The qdel on dropped() takes care of it
			U.temporarilyRemoveItemFromInventory(U.wear_mask, FALSE)
			U.temporarilyRemoveItemFromInventory(U.glasses, FALSE)
			U.update_inv_wear_mask()
			U.update_inv_head()
			U.update_hair()
			U.update_inv_glasses()
		ToggleHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/nano/dropped()
	if(U)
		U = null
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
			if(H.equip_to_slot_if_possible(nanomask,slot_wear_mask,0,0,1) && H.equip_to_slot_if_possible(nanogoggles,slot_glasses,0,0,1))
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


/mob/living/carbon/human/Stat()
	..()

	//NANOSUITCODE
	if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit/nano)) //Only display if actually a ninja.
		var/obj/item/clothing/suit/space/hardsuit/nano/NS = wear_suit
		if(statpanel("Crynet Nanosuit"))
			stat("Crynet Protocols : Engaged")
			stat("Current Time:", "[worldtime2text()]")
			stat("Energy Charge:", "[NS.cell.charge]%")
			stat("Mode:", "[NS.mode]")
			stat("Moving:", "[NS.moving]")
			stat("Fingerprints:", "[md5(dna.uni_identity)]")
			stat("Unique Identity:", "[dna.unique_enzymes]")
			stat("Overall Status:", "[stat > 1 ? "dead" : "[health]% healthy"]")
			stat("Nutrition Status:", "[nutrition]")
			stat("Oxygen Loss:", "[getOxyLoss()]")
			stat("Toxin Levels:", "[getToxLoss()]")
			stat("Burn Severity:", "[getFireLoss()]")
			stat("Brute Trauma:", "[getBruteLoss()]")
			stat("Radiation Levels:","[radiation] rad")
			stat("Body Temperature:","[bodytemperature-T0C] degrees C ([bodytemperature*1.8-459.67] degrees F)")


/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(. && mob_has_gravity()) //floating is easy
		if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit/nano))
			var/obj/item/clothing/suit/space/hardsuit/nano/NS = wear_suit
			if(stat != DEAD && m_intent == MOVE_INTENT_RUN)
				if(NS.cell.charge > 0 && NS.consumeonmove == TRUE)
					NS.cell.use(NS.move_use)
					NS.moving = TRUE