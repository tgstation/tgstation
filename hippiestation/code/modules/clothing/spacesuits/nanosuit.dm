//Crytek Nanosuit
/obj/item/clothing/under/syndicate/combat/nano
	name = "nanosuit lining"
	desc = "Foreign body resistant lining built below the nanosuit. Provides internal protection. Property of CryNet Systems."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	armor = list("melee" = 20, "bullet" = 10, "laser" = 0,"energy" = 5, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 80, "acid" = 50)

/obj/item/clothing/under/syndicate/combat/nano/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION, TRUE, FALSE)

/obj/item/clothing/under/syndicate/combat/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_w_uniform)
		flags_1 |= NODROP_1

/obj/item/clothing/under/syndicate/combat/nano/dropped(mob/user)
	..()
	qdel(src)

/obj/item/clothing/mask/gas/nano_mask
	name = "nanosuit gas mask"
	desc = "Operator mask. Property of CryNet Systems." //More accurate
	icon_state = "syndicate"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/clothing/mask/gas/nano_gas/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION, TRUE, FALSE)

/obj/item/clothing/mask/gas/nano_mask/equipped(mob/user, slot)
	.=..()
	if(slot == slot_wear_mask)
		flags_1 |= NODROP_1

/obj/item/clothing/mask/gas/nano_mask/dropped(mob/user)
	..()
	qdel(src)

/datum/action/item_action/nanojump
	name = "Activate Strength Jump"
	desc = "Activates the Nanosuit's super jumping ability to allows the user to cross 2 wide gaps."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"

/obj/item/clothing/shoes/combat/coldres/nanojump
	name = "nanosuit boots"
	desc = "Boots part of a nanosuit. Slip resistant. Property of CryNet Systems."
	flags_1 = NOSLIP_1
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	var/jumpdistance = 2 //-1 from to see the actual distance, e.g 3 goes over 2 tiles
	var/jumpspeed = 1
	actions_types = list(/datum/action/item_action/nanojump)

/obj/item/clothing/shoes/combat/nano/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION, TRUE, FALSE)


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
					if(NS.cell.charge >= 30)
						NS.cell.use(30)
					else
						to_chat(user, "<span class='warning'>Not enough charge.</span>")
						return
				else
					to_chat(user, "<span class='warning'>You must be on a proper floor or stable structure.</span>")
					return
			else
				to_chat(user, "<span class='warning'>Only available in strength mode.</span>")
				return
		else
			to_chat(user, "<span class='warning'>You must be wearing a nanosuit.</span>")
			return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	if(user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 0.75, 1)
		user.visible_message("<span class='warning'>[usr] jumps forward into the air!</span>")
	else
		to_chat(user, "<span class='warning'>Something prevents you from dashing forward!</span>")


/obj/item/clothing/shoes/combat/coldres/nanojump/equipped(mob/user, slot)
	.=..()
	if(slot == slot_shoes)
		flags_1 |= NODROP_1

/obj/item/clothing/shoes/combat/coldres/nanojump/dropped(mob/user)
	..()
	qdel(src)

/obj/item/clothing/gloves/combat/nano
	name = "nano gloves"
	desc = "These tactical gloves are built into a nanosuit and are fireproof and shock resistant. Property of CryNet Systems."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01

/obj/item/clothing/gloves/combat/nano/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION, TRUE, FALSE)

/obj/item/device/radio/headset/syndicate/alt/nano

/obj/item/clothing/gloves/combat/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_gloves)
		flags_1 |= NODROP_1

/obj/item/clothing/gloves/combat/nano/dropped(mob/user)
	..()
	qdel(src)

/obj/item/device/radio/headset/syndicate/alt/nano
	name = "\proper the nanosuit's bowman headset"
	desc = "Operator communication headset. Property of CryNet Systems."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	subspace_transmission = FALSE
	keyslot = new /obj/item/device/encryptionkey/binary
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/device/radio/headset/syndicate/alt/nano/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION, TRUE, FALSE)

/obj/item/device/radio/headset/syndicate/alt/nano/equipped(mob/user, slot)
	.=..()
	if(slot == slot_ears)
		flags_1 |= NODROP_1

/obj/item/device/radio/headset/syndicate/alt/nano/dropped(mob/user)
	..()
	qdel(src)

/obj/item/device/radio/headset/syndicate/alt/nano/emp_act()
	return

/obj/item/clothing/glasses/nano_goggles
	name = "nanosuit goggles"
	desc = "Goggles built for a nanosuit. Property of CryNet Systems."
	alternate_worn_icon = 'hippiestation/icons/mob/nanosuit.dmi'
	icon = 'hippiestation/icons/obj/nanosuit.dmi'
	icon_state = "nvgmesonnano"
	item_state = "nvgmesonnano"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	glass_colour_type = /datum/client_colour/glass_colour/nightvision
	actions_types = list(/datum/action/item_action/nanogoggles/toggle)
	vision_correction = 1 //We must let our wearer have good eyesight
	var/on = 0

/obj/item/clothing/glasses/nano_goggles/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION, TRUE, FALSE)

/datum/client_colour/glass_colour/nightvision
	colour = "#45723f"

/obj/item/clothing/glasses/nano_goggles/equipped(mob/user, slot)
	.=..()
	if(slot == slot_glasses)
		flags_1 |= NODROP_1

/obj/item/clothing/glasses/nano_goggles/dropped(mob/user)
	..()
	qdel(src)

/obj/item/clothing/glasses/nano_goggles/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/nanogoggles/toggle))
		nvgmode(user)
		return TRUE
	return FALSE

/obj/item/clothing/glasses/nano_goggles/AltClick(mob/user)
	return

/obj/item/clothing/glasses/nano_goggles/proc/nvgmode(mob/user, var/forced = FALSE)
	on = !on
	to_chat(user, "<span class='[forced ? "warning":"notice"]'>[forced ? "The goggles turn":"You turn the goggles"] [on ? "on":"off"][forced ? "!":"."]</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			if(on)
				darkness_view = 8
				vision_flags = SEE_BLACKNESS
				lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
				H.add_client_colour(glass_colour_type)
			else
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
	desc = "Some sort of alien future suit. It looks very robust. Property of CryNet Systems."
	var/armor_mode = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 65, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 45, "bomb" = 70, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100)
	allowed = list(/obj/item/tank/internals)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/nano
	slowdown = 0.5
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	actions_types = list(/datum/action/item_action/nanosuit/armor, /datum/action/item_action/nanosuit/cloak, /datum/action/item_action/nanosuit/speed, /datum/action/item_action/nanosuit/strength)
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
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/medical_delay = 200 //How long after we've been shot before we can start recharging. 20 seconds here
	var/medical_cooldown = 0 //Time since we've last been shot
	var/temp_cooldown = 0
	var/restore_delay = 80
	var/defrosted = FALSE
	var/detecting = FALSE
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/nano/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION, TRUE, FALSE)

/obj/item/clothing/suit/space/hardsuit/nano/emp_act(severity)
	..()
	cell.use(round(cell.charge / severity))
	if(prob(10/severity*1.5) && !shutdown)
		emp_assault()
	update_icon()


/obj/item/clothing/suit/space/hardsuit/nano/proc/emp_assault()
	if(!U.mind)
		return //Not sure how this could happen.
	shutdown = TRUE
	toggle_mode("none", TRUE)
	U.Knockdown(300)
	U.AdjustStun(300)
	U.Jitter(120)
	helmet.display_visor_message("EMP Assault! Systems impaired.")
	addtimer(CALLBACK(src, .proc/emp_assaulttwo), 25)


/obj/item/clothing/suit/space/hardsuit/nano/proc/emp_assaulttwo()
	sleep(45)
	helmet.display_visor_message("Warning. EMP shutdown, all systems impaired.")
	sleep(25)
	helmet.display_visor_message("Switching to core function mode.")
	sleep(25)
	helmet.display_visor_message("Life support priority. Warning!")
	addtimer(CALLBACK(src, .proc/emp_assaultthree), 35)


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
	update_icon()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/hardsuit/nano/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(cell)
	if(U)
		U = null
	. = ..()

/obj/item/clothing/suit/space/hardsuit/nano/examine(mob/user)
	..()
	if(mode != "none")
		to_chat(user, "The suit appears to be in [mode] mode.")
	else
		to_chat(user, "The suit appears to be offline.")

/obj/item/clothing/suit/space/hardsuit/nano/process()
	if(cell.charge >= 20)
		criticalpower = FALSE
	else
		if(!criticalpower)
			helmet.display_visor_message("Energy Critical!")
			criticalpower = !criticalpower
	if(cell.charge < 1)
		cell.charge = 0
		if(mode != "armor" && mode != "strength")
			toggle_mode("armor", TRUE)
	if(mode == "cloak")
		cell.use(1)
	if(world.time > medical_cooldown && current_charges < max_charges)
		current_charges = CLAMP((current_charges + 1), 0, max_charges)
	if(U.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		if(!detecting)
			temp_cooldown = world.time + restore_delay
			detecting = TRUE
		if(world.time > temp_cooldown)
			if(!defrosted)
				helmet.display_visor_message("Activating suit defrosting protocols.")
				U.reagents.add_reagent("leporazine", 2)
				defrosted = TRUE
				temp_cooldown += 100
	else
		defrosted = FALSE
		detecting = FALSE


/obj/item/clothing/suit/space/hardsuit/nano/proc/ntick()
	spawn while(!shutdown)
		if(cell && cell.charge < cell.maxcharge && mode != "cloak" && !U.Move())
			if(cell.charge > 0)
				cell.give(charge_rate) //this will get called after the bottom
			else
				sleep(40) //if we lose energy wait 5 seconds then recharge us
				cell.give(charge_rate)

		sleep(recharge_delay)//recharges us at variable rate


/obj/item/clothing/suit/space/hardsuit/nano/hit_reaction(mob/living/carbon/human/user, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(mode == "armor")
		if(cell.charge > 0)
			cell.use(CLAMP(hit_use + damage,1,cell.charge))
			user.visible_message("<span class='danger'>[user]'s shields deflect [attack_text]!</span>")
			return TRUE
		else
			return FALSE
		if(cell <= 20) //we instantly go out of armor if we get hit at critical energy
			cell.charge = 0
			//DisableModes()
		if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(50))
			var/datum/effect_system/spark_spread/s = new
			s.set_up(1, 1, src)
			s.start()
	kill_cloak(user)
	if(prob(damage*2.5) && user.health < 50 && current_charges > 0)
		medical_cooldown = world.time + medical_delay
		current_charges--
		heal_nano(user)

	return FALSE

/obj/item/clothing/suit/space/hardsuit/nano/proc/heal_nano(mob/living/carbon/human/user)
	helmet.display_visor_message("Engaging emergency medical protocols")
	user.reagents.add_reagent("syndicate_nanites", 2)

/obj/item/clothing/suit/space/hardsuit/nano/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/nanosuit/armor))
		toggle_mode("armor")
		return TRUE
	if(istype(action, /datum/action/item_action/nanosuit/cloak))
		toggle_mode("cloak")
		return TRUE
	if(istype(action, /datum/action/item_action/nanosuit/speed))
		toggle_mode("speed")
		return TRUE
	if(istype(action, /datum/action/item_action/nanosuit/strength))
		toggle_mode("strength")
		return TRUE
	return FALSE

/obj/item/clothing/suit/space/hardsuit/nano/proc/toggle_mode(var/suitmode, var/forced = FALSE)
	if(forced || (cell.charge > 0 && mode != suitmode))
		mode = suitmode
		switch(suitmode)
			if("armor")
				helmet.display_visor_message("Maximum Armor!")
				slowdown = 1.0
				armor = armor_mode
				helmet.armor = armor_mode
				U.filters = null
				animate(U, alpha = 255, time = 5)
				U.remove_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
				U.remove_trait(TRAIT_IGNORESLOWDOWN, "Speed Mode")
				U.remove_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
				style.remove(U)
				jetpack.full_speed = FALSE

			if("cloak")
				helmet.display_visor_message("Cloak Engaged!")
				slowdown = 0.4 //cloaking makes us go sliightly faster
				armor = initial(armor)
				helmet.armor = initial(helmet.armor)
				U.filters = filter(type="blur",size=1)
				animate(U, alpha = 40, time = 2)
				U.remove_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
				U.remove_trait(TRAIT_IGNORESLOWDOWN, "Speed Mode")
				U.remove_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
				style.remove(U)
				jetpack.full_speed = FALSE

			if("speed")
				helmet.display_visor_message("Maximum Speed!")
				slowdown = initial(slowdown)
				armor = initial(armor)
				helmet.armor = initial(helmet.armor)
				U.add_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
				U.add_trait(TRAIT_IGNORESLOWDOWN, "Speed Mode")
				U.adjustOxyLoss(-5, 0)
				U.adjustStaminaLoss(-20)
				U.filters = filter(type="outline", size=0.1, color=rgb(255,255,224))
				animate(U, alpha = 255, time = 5)
				U.remove_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
				style.remove(U)
				jetpack.full_speed = TRUE

			if("strength")
				helmet.display_visor_message("Maximum Strength!")
				U.add_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
				style.teach(U,1)
				slowdown = initial(slowdown)
				armor = initial(armor)
				helmet.armor = initial(helmet.armor)
				U.filters = filter(type="outline", size=0.1, color=rgb(255,0,0))
				animate(U, alpha = 255, time = 5)
				U.remove_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
				U.remove_trait(TRAIT_IGNORESLOWDOWN, "Speed Mode")
				jetpack.full_speed = FALSE

			if("none")
				U.remove_trait(TRAIT_PUSHIMMUNE, "Strength Mode")
				style.remove(U)
				slowdown = initial(slowdown)
				armor = initial(armor)
				helmet.armor = initial(helmet.armor)
				U.filters = null
				animate(U, alpha = 255, time = 5)
				U.remove_trait(TRAIT_GOTTAGOFAST, "Speed Mode")
				U.remove_trait(TRAIT_IGNORESLOWDOWN, "Speed Mode")
				jetpack.full_speed = FALSE

	U.update_inv_wear_suit()
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

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
	desc = "The cherry on top. Property of CryNet Systems."
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
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_BASIC)
	var/zoom_range = 12
	var/zoom = FALSE
	actions_types = list(/datum/action/item_action/nanosuit/zoom)

/obj/item/clothing/head/helmet/space/hardsuit/nano/ui_action_click()
	return FALSE

/obj/item/clothing/head/helmet/space/hardsuit/nano/equipped(mob/living/carbon/human/wearer, slot)
	..()
	if(slot == slot_head)
		flags_1 |= NODROP_1
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = GLOB.huds[hudtype]
		H.add_hud_to(wearer)

/obj/item/clothing/head/helmet/space/hardsuit/nano/dropped(mob/living/carbon/human/wearer)
	..()
	if(wearer)
		for(var/hudtype in datahuds)
			var/datum/atom_hud/H = GLOB.huds[hudtype]
			H.remove_hud_from(wearer)
		if(zoom)
			toggle_zoom(wearer, TRUE)

/obj/item/clothing/head/helmet/space/hardsuit/nano/proc/toggle_zoom(mob/living/user, force_off = FALSE)
	if(zoom || force_off)
		user.client.change_view(CONFIG_GET(string/default_view))
		to_chat(user, "<span class='boldnotice'>Disabled helmet zoom...</span>")
		zoom = FALSE
		return FALSE
	else
		user.client.change_view(zoom_range)
		to_chat(user, "<span class='boldnotice'>Toggled helmet zoom!</span>")
		zoom = TRUE
		return TRUE


/datum/action/item_action/nanosuit/zoom
	name = "Helmet Zoom"
	icon_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"

/datum/action/item_action/nanosuit/zoom/Trigger()
	var/obj/item/clothing/head/helmet/space/hardsuit/nano/NS = target
	if(istype(NS))
		NS.toggle_zoom(owner)
	return ..()


/obj/item/clothing/head/helmet/space/hardsuit/nano/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION, TRUE, FALSE)

/obj/item/clothing/suit/space/hardsuit/nano/equipped(mob/user, slot)
	if(ishuman(user))
		U = user
	if(slot == slot_wear_suit)
		flags_1 |= NODROP_1
		U.unequip_everything()
		equip_nanosuit(user)
		var/area/A = get_area(src)
		priority_announce("[user] has engaged [src] at [A.map_name]!","Message from The Syndicate!", 'sound/misc/notice1.ogg')
		U.add_trait(TRAIT_NODISMEMBER, "Nanosuit")
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
	implants = list(/obj/item/implant/explosive/disintegrate)
	suit_store = /obj/item/tank/internals/emergency_oxygen/recharge
	internals_slot = slot_s_store


obj/item/clothing/suit/space/hardsuit/nano/dropped()
	toggle_mode("none", TRUE)
	if(U)
		U = null
	..()

/mob/living/carbon/human/Stat()
	..()
	//NANOSUITCODE
	if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit/nano)) //Only display if actually wearing the suit.
		var/obj/item/clothing/suit/space/hardsuit/nano/NS = wear_suit
		if(statpanel("Crynet Nanosuit"))
			stat("Crynet Protocols : Engaged")
			stat("Energy Charge:", "[NS.cell.charge]%")
			stat("Mode:", "[NS.mode]")
			stat("Overall Status:", "[health]% healthy")
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
					if(NS.mode != "armor")//no more infinite loops
						NS.toggle_mode("armor", TRUE)

/datum/martial_art/nano
	name = "Strength Mode"
	block_chance = 75
	deflection_chance = 25

/datum/martial_art/nano/grab_act(mob/living/carbon/human/A, mob/living/carbon/D)
	if(A.grab_state >= GRAB_AGGRESSIVE)
		D.grabbedby(A, 1)
	else
		A.start_pulling(D, 1)
		if(A.pulling)
			D.stop_pulling()
			add_logs(A, D, "grabbed", addition="aggressively")
			A.grab_state = GRAB_AGGRESSIVE //Instant aggressive grab

	return TRUE

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
		bonus_damage += 5
		D.Knockdown(60)
		add_logs(A, D, "nanosuit leg sweeped")
	if(D != A && !D.stat || !D.IsKnockdown()) //and we can't knock ourselves the fuck out/down!
		if(A.grab_state == GRAB_AGGRESSIVE)
			A.stop_pulling() //So we don't spam the combo
			bonus_damage += 5
			D.Knockdown(15)
			D.visible_message("<span class='warning'>[A] knocks [D] the fuck down!", \
							"<span class='userdanger'>[A] knocks you the fuck down!</span>")
		else if(A.grab_state > GRAB_AGGRESSIVE)
			var/atom/throw_target = get_edge_target_turf(D, A.dir)
			if(!D.anchored)
				D.throw_at(throw_target, rand(1,2), 7, A)
			bonus_damage += 10
			D.Knockdown(60)
			D.visible_message("<span class='warning'>[A] knocks [D] the fuck out!!", \
							"<span class='userdanger'>[A] knocks you the fuck out!!</span>")
	return TRUE

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
	return TRUE


/obj/proc/nano_damage() //the damage nanosuits do on punches to this object, is affected by melee armor
	return 22 //just enough to damage an airlock

/atom/proc/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)
	SendSignal(COMSIG_ATOM_HULK_ATTACK, user)
	if(does_attack_animation)
		user.changeNext_move(CLICK_CD_MELEE)
		add_logs(user, src, "punched", "nanosuit strength mode")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/obj/item/attack_nano(mob/living/carbon/human/user)
	return FALSE

/obj/effect/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)
	return FALSE

/obj/structure/window/attack_nano(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return TRUE
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
			playsound(src, 'sound/effects/bang.ogg', 100, 0.5)//less ear rape
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 0.5)//less ear rape
		take_damage(nano_damage(), BRUTE, "melee", 0, get_dir(src, user))
		return TRUE
	return FALSE


/mob/living/carbon/human/check_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(attacker.mind.martial_art, /datum/martial_art/nano) && weapon && weapon.damtype == BRUTE)
		return 1.25 //deal 25% more damage in strength
	. = ..()


/obj/attacked_by(obj/item/I, mob/living/user)
	if(I.force && I.damtype == BRUTE && user.mind && istype(user.mind.martial_art, /datum/martial_art/nano))
		visible_message("<span class='danger'>[user] has hit [src] with a strengthened blow from [I]!</span>", null, null, COMBAT_MESSAGE_RANGE)
		//only witnesses close by and the victim see a hit message.
		take_damage(I.force*1.75, I.damtype, "melee", 1)//take 75% more damage with strength on
	else
		return ..()

/obj/item/throw_at(atom/target, range, speed, mob/living/carbon/human/thrower, spin = 1, diagonals_first = 0, datum/callback/callback)
	if(thrower.mind && istype(thrower.mind.martial_art, /datum/martial_art/nano))
		.=..(target, range*1.5, speed*2, thrower, spin, diagonals_first, callback)
	else
		..()
	kill_cloak(thrower)

/obj/item/afterattack(atom/O, mob/living/carbon/human/user, proximity)
	..()
	kill_cloak(user)

/obj/item/gun/afterattack(atom/O, mob/living/carbon/human/user, proximity)
	..()
	kill_cloak(user)

/obj/item/weldingtool/afterattack(atom/O, mob/living/carbon/human/user, proximity)
	..()
	kill_cloak(user)

/obj/item/twohanded/fireaxe/afterattack(atom/A, mob/living/carbon/human/user, proximity)
	..()
	kill_cloak(user)

/datum/species/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	kill_cloak(M)

/proc/kill_cloak(mob/living/carbon/human/user)
	if(istype(user.wear_suit, /obj/item/clothing/suit/space/hardsuit/nano))
		var/obj/item/clothing/suit/space/hardsuit/nano/NS = user.wear_suit
		if(NS.mode == "cloak")
			NS.cell.charge = 0
			NS.toggle_mode("armor", TRUE)

/datum/martial_art/nano/proc/on_attack_hand(mob/living/carbon/human/owner, atom/target, proximity)
	if(proximity)
		return target.attack_nano(owner)


/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	var/datum/martial_art/nano/style = new
	if(istype(src.mind.martial_art, /datum/martial_art/nano))
		if(style.on_attack_hand(src, A, proximity))
			return
	..()

/obj/item/storage/box/syndie_kit/nanosuit
	name = "\improper Crynet Systems kit"
	desc = "Maximum Death."

/obj/item/storage/box/syndie_kit/nanosuit/PopulateContents()
	new /obj/item/clothing/suit/space/hardsuit/nano(src)

/obj/item/implant/explosive/disintegrate
	name = "disintegration implant"
	desc = "Ashes to ashes."
	icon_state = "explosive"

/obj/item/implant/explosive/disintegrate/activate(cause)
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button" && !popup)
		popup = TRUE
		var/response = alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to vapourize!", "[name] Confirmation", "Yes", "No")
		popup = FALSE
		if(response == "No")
			return FALSE
	to_chat(imp_in, "<span class='notice'>You activate your [name].</span>")
	active = TRUE
	var/turf/dustturf = get_turf(imp_in)
	var/area/A = get_area(dustturf)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [A.name] [ADMIN_JMP(dustturf)], with cause of [cause].")
	playsound(loc, 'sound/effects/fuse.ogg', 30, 0)
	sleep(25)
	imp_in.dust()
	qdel(src)

/obj/item/tank/internals/emergency_oxygen/recharge
	name = "self-filling miniature oxygen tank"
	desc = "A magical tank that uses bluespace technology to replenish it's oxygen supply."
	volume = 2

/obj/item/tank/internals/emergency_oxygen/recharge/New()
	..()
	air_contents.assert_gas(/datum/gas/oxygen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	START_PROCESSING(SSobj, src)
	return

/obj/item/tank/internals/emergency_oxygen/recharge/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		var/moles_val = (ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		var/In_Use = H.Move()
		if(!In_Use)
			sleep(10)
			if(air_contents.gases[/datum/gas/oxygen][MOLES] < (10*moles_val))
				air_contents.assert_gas(/datum/gas/oxygen)
				air_contents.gases[/datum/gas/oxygen][MOLES] = CLAMP(air_contents.total_moles()+moles_val,0,(10*moles_val))
		if(air_contents.return_pressure() >= 16 && distribute_pressure < 16)
			distribute_pressure = 16

/obj/item/tank/internals/emergency_oxygen/recharge/equipped(mob/living/carbon/human/wearer, slot)
	..()
	if(slot == slot_s_store)
		flags_1 |= NODROP_1
		START_PROCESSING(SSobj, src)

/obj/item/tank/internals/emergency_oxygen/recharge/dropped(mob/living/carbon/human/wearer)
	..()
	STOP_PROCESSING(SSobj, src)
	qdel(src)