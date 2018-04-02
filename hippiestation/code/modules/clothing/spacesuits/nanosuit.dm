//Crytek Nanosuit
/obj/item/clothing/under/syndicate/combat/nano
	name = "nanosuit lining"
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

/datum/action/item_action/nanojump
	name = "Activate Strength Jump"
	desc = "Activates the Nanosuit's super jumping ability to allows the user to cross 2 wide gaps."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"

/obj/item/clothing/shoes/combat/coldres/nanojump
	name = "nanosuit boots"
	desc = "High speed, no drag combat boots, now with an added layer of insulation. Property of CryNet Systems."
	flags_1 = NOSLIP_1
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	var/jumpdistance = 2 //-1 from to see the actual distance, e.g 3 goes over 2 tiles
	var/jumpspeed = 2
	actions_types = list(/datum/action/item_action/nanojump)

/obj/item/clothing/shoes/combat/coldres/nanojump/ui_action_click(mob/user, action)
	if(!isliving(user))
		return

	var/turf/open/floor/T = get_turf(src)
	var/obj/structure/S = locate() in get_turf(user.loc)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit/nano))
			var/obj/item/clothing/suit/space/hardsuit/nano/NS = H.wear_suit
			if(NS.mode == "strength")
				if(istype(T) || istype(S))
					if(NS.cell.charge > 30)
						NS.cell.use(30)
					else
						to_chat(user, "<span class='warning'>Not enough charge!</span>")
						return
				else
					to_chat(user, "<span class='warning'>Must be on a stable surface!</span>")
					return
			else
				to_chat(user, "<span class='warning'>Only available in strength mode!</span>")
				return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	if(user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		user.visible_message("<span class='warning'>[usr] jumps forward into the air!</span>")
	else
		to_chat(user, "<span class='warning'>Something prevents you from dashing forward!</span>")


/obj/item/clothing/shoes/combat/coldres/nanojump/equipped(mob/user, slot)
	.=..()
	if(slot == slot_shoes)
		flags_1 |= NODROP_1

/obj/item/clothing/gloves/combat/nano
	name = "nano gloves"
	desc = "These tactical gloves are fireproof and shock resistant. Property of CryNet Systems."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01

/obj/item/clothing/gloves/combat/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_gloves)
		flags_1 |= NODROP_1

/obj/item/device/radio/headset/syndicate/alt/nano
	name = "\proper the nanosuit's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs.\nChannels are as follows: :c - command, :s - security, :e - engineering, :u - supply, :v - service, :m - medical, :n - science."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	subspace_transmission = FALSE
	keyslot = new /obj/item/device/encryptionkey/binary
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/device/radio/headset/syndicate/alt/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_ears)
		flags_1 |= NODROP_1

/obj/item/device/radio/headset/syndicate/alt/nano/emp_act()
	return

/obj/item/clothing/glasses/nano_goggles
	name = "nanosuit goggles"
	desc = "Goggles built into your nanosuit helmet. Property of CryNet."
	alternate_worn_icon = 'hippiestation/icons/mob/nanosuit.dmi'
	icon = 'hippiestation/icons/obj/nanosuit.dmi'
	icon_state = "nvgmesonnano"
	item_state = "nvgmesonnano"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	glass_colour_type = /datum/client_colour/glass_colour/nightvision
	actions_types = list(/datum/action/item_action/nanogoggles/toggle)
	vision_correction = 1 //We must let our wearer have good eyesight
	var/on = 0

/datum/client_colour/glass_colour/nightvision
	colour = "#45723f"

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

/obj/item/clothing/glasses/nano_goggles/proc/nvgmode(mob/user, var/forced = FALSE)
	to_chat(user, "<span class='[forced ? "warning":"notice"]'>[forced ? "The goggles turn":"You turn the goggles"] [on ? "on":"off"][forced ? "!":"."]</span>")
	on = !on
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			switch(on)
				if(1)
					darkness_view = 8
					vision_flags = SEE_BLACKNESS
					lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
					H.add_client_colour(glass_colour_type)
				if(0)
					vision_flags = NONE
					darkness_view = 2
					lighting_alpha = null
					H.remove_client_colour(glass_colour_type)
			H.update_client_colour()
			H.update_sight()

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/glasses/nano_goggles/emp_act(severity)
	..()
	if(prob(33/severity))
		nvgmode(loc,TRUE)

/obj/item/clothing/suit/space/hardsuit/nano
	alternate_worn_icon = 'hippiestation/icons/mob/nanosuit.dmi'
	icon = 'hippiestation/icons/obj/nanosuit.dmi'
	icon_state = "nanosuit"
	item_state = "nanosuit"
	name = "nanosuit"
	desc = "Some sort of alien future suit. It looks very robust."
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 45, "bomb" = 70, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100)
	allowed = list(/obj/item/tank/internals)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/nano
	slowdown = 0.5
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	actions_types = list(/datum/action/item_action/nanosuit/armor, /datum/action/item_action/nanosuit/cloak, /datum/action/item_action/nanosuit/speed, /datum/action/item_action/nanosuit/strength)
	jetpack = /obj/item/tank/jetpack/suit
	permeability_coefficient = 0.01
	var/mob/living/carbon/human/U = null
	var/obj/item/stock_parts/cell/cell //What type of power cell this uses
	var/cell_type = /obj/item/stock_parts/cell{charge = 100; maxcharge = 100}
	var/charge_rate = 15
	var/move_use = 1
	var/hit_use = 5
	var/criticalpower = FALSE
	var/mode = "none"
	var/recharge_delay = 30
	var/datum/martial_art/nano/style = new
	var/shutdown = FALSE
	var/empdmg = 0


/obj/item/clothing/suit/space/hardsuit/nano/emp_act(severity)
	..()
	empdmg = 10/severity
	cell.use(round(cell.charge / severity))
	if(prob(empdmg*1.5) && !shutdown)
		emp_assault()
	update_icon()


/obj/item/clothing/suit/space/hardsuit/nano/proc/emp_assault()
	if(!U.mind)
		return //Not sure how this could happen.
	shutdown = TRUE
	DisableModes()
	U.Knockdown(empdmg*30)
	U.AdjustStun(empdmg*30)
	U.Jitter(empdmg*30)
	helmet.display_visor_message("EMP Assault! Systems impaired.")
	addtimer(CALLBACK(src, .proc/emp_assaulttwo), empdmg)


/obj/item/clothing/suit/space/hardsuit/nano/proc/emp_assaulttwo()
	sleep(45)
	helmet.display_visor_message("Warning. EMP shutdown, all systems impaired.")
	sleep(25)
	helmet.display_visor_message("Switching to core function mode.")
	sleep(25)
	helmet.display_visor_message("Life support priority. Warning!")
	addtimer(CALLBACK(src, .proc/emp_assaultthree), empdmg)


/obj/item/clothing/suit/space/hardsuit/nano/proc/emp_assaultthree()
	helmet.display_visor_message("4672482//-82544111.0//WRXT _YWD")
	sleep(5)
	helmet.display_visor_message("KPO- -86801780.768//1228.")
	sleep(5)
	helmet.display_visor_message("LMU/894411.-//0113122")
	sleep(5)
	helmet.display_visor_message("QRE 8667152...")
	sleep(5)
	helmet.display_visor_message("XAS -123455")
	sleep(5)
	helmet.display_visor_message("WF // .897")
	sleep(20)
	helmet.display_visor_message("DIAG//123")
	sleep(10)
	helmet.display_visor_message("MED//8189")
	sleep(10)
	helmet.display_visor_message("LOADING//...")
	sleep(70)
	U.AdjustStun(-100)
	U.AdjustKnockdown(-100)
	U.adjustStaminaLoss(-55)
	U.adjustOxyLoss(-55)
	helmet.display_visor_message("Cleared to proceed.")
	shutdown = FALSE
	ntick()


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
	DisableModes()
	QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	if(U)
		U = null
	return ..()

obj/item/clothing/suit/space/hardsuit/nano/proc/DisableModes()
	if(U)
		armor_cancel()
		cloak_cancel()
		speed_cancel()
		strength_cancel()

/obj/item/clothing/suit/space/hardsuit/nano/examine(mob/user)
	..()
	if(user == U)
		if(mode != "none")
			to_chat(user, "The suit appears to be in: [mode] mode.")
		else
			to_chat(user, "The suit appears to not be in any mode.")


/obj/item/clothing/suit/space/hardsuit/nano/process()
	if(cell.charge >= 20)
		criticalpower = FALSE
	else
		if(!criticalpower)
			helmet.display_visor_message("Energy Critical!")
			criticalpower = !criticalpower
	if(cell.charge < 1)
		DisableModes()
		cell.charge = 0
	if(mode == "cloak")
		cell.use(1)

/obj/item/clothing/suit/space/hardsuit/nano/proc/ntick()
	spawn while(!shutdown)
		if(cell && cell.charge < cell.maxcharge && mode != "cloak" && !U.Move())
			sleep(10)//bit of a delay
			cell.give(charge_rate)

		sleep(recharge_delay)//recharges us every 3 seconds


/obj/item/clothing/suit/space/hardsuit/nano/hit_reaction(mob/living/carbon/human/user, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(mode == "armor" || mode == "cloak")
		if(cell.charge > 0)
			cell.use(CLAMP(hit_use + damage,1,cell.charge))
		else if(cell <= 20) //we instantly go out of armor/cloak if we get hit at charge of 20 or less
			cell.charge = 0
			DisableModes()
		if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(50))
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
	if(cell.charge <= 0 && !shutdown)
		helmet.display_visor_message("Insufficient Charge!")
		return FALSE
	if(shutdown)
		helmet.display_visor_message("ERROR")
		return FALSE
	return TRUE

/obj/item/clothing/suit/space/hardsuit/nano/proc/armormode()
	armor_toggle()

/obj/item/clothing/suit/space/hardsuit/nano/proc/armor_toggle()
	if(!U)
		return
	if(mode == "armor")
		armor_cancel()
	else
		if(can_toggle())
			update_icon()
			cloak_cancel()
			speed_cancel()
			strength_cancel()
			helmet.display_visor_message("Maximum Armor!")
			slowdown = 1.0
			mode = "armor"
			armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 65,
							"bomb" = 100, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 100)
			helmet.armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 65,
							"bomb" = 100, "bio" = 100, "rad" = 90, "fire" = 100, "acid" = 100)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()


/obj/item/clothing/suit/space/hardsuit/nano/proc/armor_cancel()
	if(!U)
		return 0

	if(mode == "armor")
		update_icon()
		slowdown = initial(slowdown)
		helmet.display_visor_message("Armor Disabled!")
		mode = "none"
		armor = initial(armor)
		return 1
	return 0


/obj/item/clothing/suit/space/hardsuit/nano/proc/cloakmode()
	cloak_toggle()

/obj/item/clothing/suit/space/hardsuit/nano/proc/cloak_toggle()
	if(!U)
		return
	if(mode == "cloak")
		cloak_cancel()
	else
		if(can_toggle())
			update_icon()
			armor_cancel()
			speed_cancel()
			strength_cancel()
			helmet.display_visor_message("Cloak Engaged!")
			slowdown = 0.4
			mode = "cloak"
			U.filters += filter(type="blur",size=1)
			animate(U, alpha = 40, time = 2)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/space/hardsuit/nano/proc/cloak_cancel()
	if(!U)
		return 0

	if(mode == "cloak")
		update_icon()
		slowdown = initial(slowdown)
		helmet.display_visor_message("Cloak Disabled!")
		mode = "none"
		U.filters -= filter(type="blur",size=1)
		animate(U, alpha = 255, time = 5)
		return 1
	return 0


/obj/item/clothing/suit/space/hardsuit/nano/proc/speedmode()
	speed_toggle()

/obj/item/clothing/suit/space/hardsuit/nano/proc/speed_toggle()
	if(!U)
		return
	if(mode == "speed")
		speed_cancel()
	else
		if(can_toggle())
			update_icon()
			armor_cancel()
			cloak_cancel()
			strength_cancel()
			helmet.display_visor_message("Maximum Speed!")
			U.add_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
			U.add_trait(TRAIT_IGNORESLOWDOWN, "Speed Mode")
			U.adjustOxyLoss(-2, 0)
			U.adjustStaminaLoss(-20)
			mode = "speed"

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/space/hardsuit/nano/proc/speed_cancel()
	if(!U)
		return 0

	if(mode == "speed")
		update_icon()
		U.remove_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
		U.remove_trait(TRAIT_IGNORESLOWDOWN, "Speed Mode")
		helmet.display_visor_message("Speed Disabled!")
		mode = "none"
		return 1
	return 0


/obj/item/clothing/suit/space/hardsuit/nano/proc/strengthmode()
	strength_toggle()


/obj/item/clothing/suit/space/hardsuit/nano/proc/strength_toggle()
	if(!U)
		return
	if(mode == "strength")
		strength_cancel()
	else
		if(can_toggle())
			update_icon()
			armor_cancel()
			cloak_cancel()
			speed_cancel()
			helmet.display_visor_message("Maximum Strength!")
			mode = "strength"
			U.add_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
			style.teach(U,1)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/space/hardsuit/nano/proc/strength_cancel()
	if(!U)
		return 0

	if(mode == "strength")
		update_icon()
		helmet.display_visor_message("Strength Disabled!")
		mode = "none"
		if(!U.has_trait(TRAIT_HULK))//don't want to cuck our hulk push immunity
			U.remove_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
		style.remove(U)
		return 1
	return 0


/datum/action/item_action/nanogoggles/toggle
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	name = "Night Vision"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'hippiestation/icons/mob/actions/actions_nanosuit.dmi'
	button_icon_state = "toggle_goggle"

/datum/action/item_action/nanosuit/armor
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	name = "Armor Mode"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'hippiestation/icons/mob/actions/actions_nanosuit.dmi'
	button_icon_state = "armor_mode"

/datum/action/item_action/nanosuit/cloak
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	name = "Cloak Mode"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'hippiestation/icons/mob/actions/actions_nanosuit.dmi'
	button_icon_state = "cloak_mode"

/datum/action/item_action/nanosuit/speed
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	name = "Speed Mode"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'hippiestation/icons/mob/actions/actions_nanosuit.dmi'
	button_icon_state = "speed_mode"

/datum/action/item_action/nanosuit/strength
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	name = "Strength Mode"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'hippiestation/icons/mob/actions/actions_nanosuit.dmi'
	button_icon_state = "strength_mode"


/obj/item/clothing/head/helmet/space/hardsuit/nano
	name = "nanosuit helmet"
	desc = "Some sort of alien future suit helmet. It looks very robust."
	alternate_worn_icon = 'hippiestation/icons/mob/nanosuit.dmi'
	icon = 'hippiestation/icons/obj/nanosuit.dmi'
	icon_state = "nanohelmet"
	item_state = "nanohelmet"
	item_color = "nano"
	siemens_coefficient = 0
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 45, "bomb" = 70, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	var/obj/item/clothing/mask/gas/nano_mask/nanomask
	var/obj/item/clothing/glasses/nano_goggles/nanogoggles
	actions_types = list()

/obj/item/clothing/suit/space/hardsuit/nano/equipped(mob/user, slot)
	if(ishuman(user))
		U = user
	if(slot == slot_wear_suit)
		flags_1 |= NODROP_1
		U.unequip_everything()
		equip_nanosuit(user)
		ntick()
	..()

/obj/item/clothing/suit/space/hardsuit/nano/proc/equip_nanosuit(mob/living/carbon/human/user)
	return user.equipOutfit(/datum/outfit/nanosuit)

/datum/outfit/nanosuit
	name = "Nanosuit"
	uniform = /obj/item/clothing/under/syndicate/combat/nano
	glasses = /obj/item/clothing/glasses/nano_goggles
	mask = /obj/item/clothing/mask/gas/nano_mask
	ears = /obj/item/device/radio/headset/syndicate/alt/nano
	shoes = /obj/item/clothing/shoes/combat/coldres/nanojump
	gloves = /obj/item/clothing/gloves/combat/nano
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	internals_slot = slot_r_store
	implants = list(/obj/item/implant/explosive)


obj/item/clothing/suit/space/hardsuit/nano/dropped()
	DisableModes()
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
				if(NS.cell.charge > 0)
					if(NS.mode == "speed" || NS.mode == "cloak")
						NS.cell.use(NS.move_use)
				else
					NS.DisableModes()
					NS.cell.charge = 0

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

	if(D.IsKnockdown() || D.resting || D.lying)//we can hit ourselves
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
	if(A.resting && !D.stat && !D.IsKnockdown() && D != A) //but we can't legsweep ourselves!
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE)
		D.Knockdown(60)
		add_logs(A, D, "nanosuit leg sweeped")
	if(D != A && !D.stat || !D.IsKnockdown()) //and we can't knock ourselves the fuck out/down!
		if(A.grab_state == GRAB_AGGRESSIVE)
			A.stop_pulling() //So we don't spam the combo
			D.apply_damage(5, BRUTE)
			D.Knockdown(15)
			D.visible_message("<span class='warning'>[A] knocks [D] the fuck down!", \
							"<span class='userdanger'>[A] knocks you the fuck down!</span>")
		else if(A.grab_state > GRAB_AGGRESSIVE)
			var/atom/throw_target = get_edge_target_turf(D, A.dir)
			if(!D.anchored)
				D.throw_at(throw_target, rand(1,2), 7, A)
			D.apply_damage(10, BRUTE)
			D.Knockdown(60)
			D.visible_message("<span class='warning'>[A] knocks [D] the fuck out!!", \
							"<span class='userdanger'>[A] knocks you the fuck out!!</span>")
	return 1

/datum/martial_art/nano/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/D)
	var/obj/item/I = null
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	if(prob(60) && D != A)
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


/obj/proc/nano_damage() //the damage nanosuits do on punches to this object, is affected by melee armor
	return 22 //just enough to damage an airlock

/atom/proc/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)
	SendSignal(COMSIG_ATOM_HULK_ATTACK, user)
	if(does_attack_animation)
		user.changeNext_move(CLICK_CD_MELEE)
		add_logs(user, src, "punched", "nanosuit strength mode")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/obj/item/attack_nano(mob/living/carbon/human/user)
	return 0

/obj/effect/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)
	return 0

/obj/structure/window/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return 1
	. = ..()

/obj/structure/grille/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		if(!shock(user, 70))
			..(user, 1)
		return TRUE

/obj/structure/destructible/clockwork/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)
	if(is_servant_of_ratvar(user) && immune_to_servant_attacks)
		return FALSE
	return ..()

/obj/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)//attacking objects barehand
	if(user.a_intent == INTENT_HARM)
		..(user, 1)
		visible_message("<span class='danger'>[user] smashes [src]!</span>", null, null, COMBAT_MESSAGE_RANGE)
		if(density)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 0.5)//less ear rape
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 0.5)//less ear rape
		take_damage(nano_damage(), BRUTE, "melee", 0, get_dir(src, user))
		return 1
	return 0


/mob/living/carbon/human/check_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(attacker.mind.martial_art, /datum/martial_art/nano))
		return 1.25 //deal 25% more damage in strength
	. = ..()


/obj/attacked_by(obj/item/I, mob/living/user)
	if(I.force && I.damtype == BRUTE && istype(user.mind.martial_art, /datum/martial_art/nano))
		visible_message("<span class='danger'>[user] has hit [src] with a strengthened blow from [I]!</span>", null, null, COMBAT_MESSAGE_RANGE)
		//only witnesses close by and the victim see a hit message.
		take_damage(I.force*1.75, I.damtype, "melee", 1)//take 75% more damage with strength on
	else
		return ..()


/datum/martial_art/nano/proc/on_attack_hand(mob/living/carbon/human/owner, atom/target, proximity)
	if(proximity)
		return target.attack_nano(owner)


/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	if(!has_active_hand()) //can't attack without a hand.
		to_chat(src, "<span class='notice'>You look at your arm and sigh.</span>")
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A,1))
		return

	var/override = 0

	for(var/datum/mutation/human/HM in dna.mutations)
		override += HM.on_attack_hand(src, A, proximity)

	var/datum/martial_art/nano/style = new
	if(istype(src.mind.martial_art, /datum/martial_art/nano))
		override += style.on_attack_hand(src, A, proximity)

	if(override)
		return

	SendSignal(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A)
	A.attack_hand(src)
	SendSignal(COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY, src)


/obj/item/storage/box/syndie_kit/nanosuit
	name = "\improper Crynet Systems kit"
	desc = "Maximum Death."

/obj/item/storage/box/syndie_kit/nanosuit/PopulateContents()
	new /obj/item/clothing/suit/space/hardsuit/nano(src)