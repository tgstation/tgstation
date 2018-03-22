/obj/item/clothing/head/helmet/space/hardsuit
	var/next_warn_rad = 0
	var/warn_rad_cooldown = 180

/obj/item/clothing/suit/space/hardsuit
	var/next_warn_acid = 0
	var/warn_acid_cooldown = 150

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(severity)
	.=..()
	if (prob(33) && rad_count > 250)
		if (next_warn_rad > world.time)
			return
		next_warn_rad = world.time + warn_rad_cooldown
		display_visor_message("Radiation present, seek distance from source!")

/obj/item/clothing/suit/space/hardsuit/acid_act(acidpwr, acid_volume)
	.=..()
	if (prob(33) && acidpwr >= 10)
		if(helmet)
			if(next_warn_acid > world.time)
				return
			next_warn_acid = world.time + warn_acid_cooldown
			helmet.display_visor_message("Corrosive Chemical Detected!")


//Crytek Nanosuit
/obj/item/clothing/under/syndicate/combat/nano
	name = "nanosuit under suit"
	desc = "A robust suit to line the inside of your nanosuit. Provides internal protection."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/clothing/under/syndicate/combat/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_w_uniform)
		flags_1 |= NODROP_1

/obj/item/clothing/mask/gas/nano_mask
	name = "nanosuit gas mask"
	desc = "A robust gas mask. Property of CryNet Systems." //More accurate
	icon_state = "syndicate"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/clothing/mask/gas/nano_mask/equipped(mob/user, slot)
	.=..()
	if(slot == slot_wear_mask)
		flags_1 |= NODROP_1

/obj/item/clothing/shoes/combat/coldres/nano
	name = "insulated combat boots"
	desc = "High speed, low drag combat boots, now with an added layer of insulation. Property of CryNet Systems."
	flags_1 = NOSLIP_1

/obj/item/clothing/shoes/combat/coldres/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_shoes)
		flags_1 |= NODROP_1


/obj/item/clothing/gloves/combat/nano
	name = "nano gloves"
	desc = "These tactical gloves are fireproof and shock resistant. Property of CryNet Systems."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/clothing/gloves/combat/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_gloves)
		flags_1 |= NODROP_1

/obj/item/device/radio/headset/syndicate/alt/nano
	name = "\proper the nanosuit's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs.\nChannels are as follows: :c - command, :s - security, :e - engineering, :u - supply, :v - service, :m - medical, :n - science."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	subspace_switchable = TRUE
	keyslot = new /obj/item/device/encryptionkey/binary
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/device/radio/headset/syndicate/alt/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_ears)
		flags_1 |= NODROP_1


/obj/item/clothing/glasses/nano_goggles
	name = "night vision goggles"
	desc = "Goggles built into your nanosuit helmet. Property of CryNet."
	alternate_worn_icon = 'hippiestation/icons/mob/eyes.dmi'
	icon = 'hippiestation/icons/obj/clothing/glasses.dmi'
	icon_state = "nvgmesonnano"
	item_state = "nvgmesonnano"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	glass_colour_type = /datum/client_colour/glass_colour/nightvision
	actions_types = list(/datum/action/item_action/nanogoggles/toggle)
	vision_correction = 1
	var/on = FALSE

/datum/client_colour/glass_colour/nightvision
	colour = "#12bc00"

/obj/item/clothing/glasses/nano_goggles/equipped(mob/user, slot)
	.=..()
	if(slot == slot_glasses)
		flags_1 |= NODROP_1

/obj/item/clothing/glasses/nano_goggles/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/nanogoggles/toggle))
		nvgmode(user)
		return TRUE
	return FALSE

/obj/item/clothing/glasses/nano_goggles/AltClick(mob/user)
	return

/obj/item/clothing/glasses/nano_goggles/proc/nvgmode(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't toggles the goggles while you're incapacitated.</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(!on)
			on = !on
			darkness_view = 8
			vision_flags = SEE_BLACKNESS
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			//animate(U.client, color = glass_colour_type, time = 5)
			U.add_client_colour(glass_colour_type)
			U.update_client_colour()
			U.update_sight()
		else
			on = !on
			vision_flags = NONE
			darkness_view = 2
			lighting_alpha = null
			//animate(U.client, color = "", time = 5)
			U.remove_client_colour(glass_colour_type)
			U.update_client_colour()
			U.update_sight()


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
	var/charge_rate = 20
	var/move_use = 1
	var/hit_use = 20
	var/criticalpower = FALSE
	var/mode = "none"
	var/recharge_cooldown = 0
	var/recharge_delay = 30
	var/consumeonmove = FALSE
	var/moving = FALSE
	var/curLoc
	var/lastLoc
	var/datum/martial_art/nano/style = new


/obj/item/clothing/suit/space/hardsuit/nano/emp_act(severity)
	..()
	cell.use(round(cell.charge / severity))
	update_icon()

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
	armor_cancel()
	cloak_cancel()
	speed_cancel()
	strength_cancel()
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
	var/obj/item/projectile/P = hitby
	if(mode == "armor" || mode == "cloak")
		if(cell.charge > 0)
			cell.use(CLAMP(hit_use,1,cell.charge))
		else if(cell <= 20)
			cell.charge = 0
			armor_cancel()
			cloak_cancel()
		if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(35))
			var/datum/effect_system/spark_spread/s = new
			s.set_up(1, 1, src)
			s.start()
	if(mode == "armor")
		user.visible_message("<span class='danger'>[user]'s shields deflect [attack_text]!</span>")
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
			U.filters += filter(type="blur", x=0, y=0,size=1)

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
		U.filters -= filter(type="blur", x=0, y=0,size=1)
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
			U.add_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
			U.adjustOxyLoss(-5, 0)
			U.adjustStaminaLoss(-10)
			//jetpack.full_speed = TRUE
			mode = "speed"


/obj/item/clothing/suit/space/hardsuit/nano/proc/speed_cancel()
	if(!U)
		return 0

	if(mode == "speed")
		recharge_cooldown = world.time + recharge_delay
		U.remove_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
		consumeonmove = FALSE
		moving = FALSE
		helmet.display_visor_message("Speed Disabled!")
		mode = "none"
		//jetpack.full_speed = FALSE
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
			U.add_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
			style.teach(U,1)

/obj/item/clothing/suit/space/hardsuit/nano/proc/strength_cancel()
	if(!U)
		return 0

	if(mode == "strength")
		recharge_cooldown = world.time + recharge_delay
		//animate(U, alpha = 255, time = 5)
		helmet.display_visor_message("Strength Disabled!")
		mode = "none"
		if(!U.has_trait(TRAIT_HULK))//don't want to cuck our hulk push immunity
			U.remove_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
		style.remove(U)
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
	var/obj/item/clothing/mask/gas/nano_mask/nanomask
	var/obj/item/clothing/glasses/nano_goggles/nanogoggles
	var/visagetoggled = FALSE
	actions_types = list()


/obj/item/clothing/suit/space/hardsuit/nano/equipped(mob/user, slot)
	if(ishuman(user))
		U = user
	if(slot == slot_wear_suit)
		flags_1 |= NODROP_1
		U.unequip_everything()
		equip_nanosuit(user)
		//ToggleHelmet()
	..()


/obj/item/clothing/suit/space/hardsuit/nano/proc/equip_nanosuit(mob/living/carbon/human/user)
	return user.equipOutfit(/datum/outfit/nanosuit)

/datum/outfit/nanosuit
	name = "Nanosuit"
	uniform = /obj/item/clothing/under/syndicate/combat/nano
	//head = /obj/item/clothing/head/helmet/space/hardsuit/nano
	glasses = /obj/item/clothing/glasses/nano_goggles
	mask = /obj/item/clothing/mask/gas/nano_mask
	ears = /obj/item/device/radio/headset/syndicate/alt/nano
	shoes = /obj/item/clothing/shoes/combat/coldres/nano
	gloves = /obj/item/clothing/gloves/combat/nano
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	internals_slot = slot_r_store
	implants = list(/obj/item/implant/explosive)


obj/item/clothing/suit/space/hardsuit/nano/dropped()
	armor_cancel()
	cloak_cancel()
	speed_cancel()
	strength_cancel()
	if(U)
		U = null
	..()

/obj/item/clothing/head/helmet/space/hardsuit/nano/equipped(mob/user, slot)
	if(slot == slot_head)
		flags_1 |= NODROP_1
	..()


/mob/living/carbon/human/Stat()
	..()
	//NANOSUITCODE
	if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit/nano)) //Only display if actually a ninja.
		var/obj/item/clothing/suit/space/hardsuit/nano/NS = wear_suit
		if(statpanel("Crynet Nanosuit"))
			stat("Crynet Protocols : Engaged")
			stat("Energy Charge:", "[NS.cell.charge]%")
			stat("Mode:", "[NS.mode]")
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


/datum/martial_art/nano
	name = "Strength Mode"
	block_chance = 60

/datum/martial_art/nano/grab_act(mob/living/carbon/human/A, mob/living/carbon/D)
	if(A.grab_state >= GRAB_AGGRESSIVE)
		D.grabbedby(A, 1)
	else
		A.start_pulling(D, 1)
		if(A.pulling)
			D.stop_pulling()
			add_logs(A, D, "grabbed", addition="aggressively")
			A.grab_state = GRAB_AGGRESSIVE //Instant aggressive grab

	return 1

/datum/martial_art/nano/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/D)
	add_logs(A, D, "punched")
	var/picked_hit_type = pick("punches", "kicks")
	var/bonus_damage = 10
	if(D.IsKnockdown() || D.resting || D.lying)
		bonus_damage += 5
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kicks" || picked_hit_type == "stomps on")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_logs(A, D, "[picked_hit_type] with [name]")
	if(A.resting && !D.stat && !D.IsKnockdown())
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE)
		D.Knockdown(60)
		add_logs(A, D, "nanosuit sweeped")
	if(!D.stat || !D.IsKnockdown())
		if(A.grab_state == GRAB_AGGRESSIVE)
			A.stop_pulling() //So we don't spam the combo
			D.apply_damage(10, BRUTE)
			D.Knockdown(20)
			D.visible_message("<span class='warning'>[A] knocks [D] the fuck down!", \
							"<span class='userdanger'>[A] knocks you the fuck down!</span>")
		else if(A.grab_state > GRAB_AGGRESSIVE)
			var/atom/throw_target = get_edge_target_turf(D, A.dir)
			if(!D.anchored)
				D.throw_at(throw_target, rand(1,2), 7, A)
			D.apply_damage(15, BRUTE)
			D.Knockdown(60)
			D.visible_message("<span class='warning'>[A] knocks [D] the fuck out!!", \
							"<span class='userdanger'>[A] knocks you the fuck out!!</span>")
	return 1

/datum/martial_art/nano/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/D)
	var/obj/item/I = null
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	if(prob(60))
		I = D.get_active_held_item()
		if(I)
			if(D.temporarilyRemoveItemFromInventory(I))
				A.put_in_hands(I)
		D.visible_message("<span class='danger'>[A] has disarmed [D]!</span>", \
							"<span class='userdanger'>[A] has disarmed [D]!</span>")
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		D.Knockdown(40)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", \
							"<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	add_logs(A, D, "disarmed with krav maga", "[I ? " removing \the [I]" : ""]")
	return 1

/*/datum/martial_art/nano/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>You feel your muscles tighten and pump up!</span>")

/datum/martial_art/nano/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You feel your muscles relax...</span>")
*/