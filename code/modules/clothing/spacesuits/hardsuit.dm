	//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	max_integrity = 300
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75, fire = 50, acid = 75)
	var/basestate = "hardsuit"
	var/brightness_on = 4 //luminosity when on
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit
	item_color = "engineering" //Determines used sprites: hardsuit[on]-[color] and hardsuit[on]-[color]2 (lying down sprite)
	actions_types = list(/datum/action/item_action/toggle_helmet_light)


/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	on = !on
	icon_state = "[basestate][on]-[item_color]"
	user.update_inv_head()	//so our mob-overlays update

	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveHelmet()

/obj/item/clothing/head/helmet/space/hardsuit/item_action_slot_check(slot)
	if(slot == slot_head)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/equipped(mob/user, slot)
	..()
	if(slot != slot_head)
		if(suit)
			suit.RemoveHelmet()
		else
			qdel(src)

/obj/item/clothing/head/helmet/space/hardsuit/proc/display_visor_message(var/msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message("[bicon(src)]<b><span class='robot'>[msg]</span></b>", 1)

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(severity)
	..()
	display_visor_message("Radiation pulse detected! Magnitude: <span class='green'>[severity]</span> RADs.")

/obj/item/clothing/head/helmet/space/hardsuit/emp_act(severity)
	..()
	display_visor_message("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!")


/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	max_integrity = 300
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75, fire = 50, acid = 75)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals,/obj/item/device/t_scanner, /obj/item/weapon/construction/rcd, /obj/item/weapon/pipe_dispenser)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(/datum/action/item_action/toggle_helmet)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/weapon/tank/jetpack/suit/jetpack = null


/obj/item/clothing/suit/space/hardsuit/New()
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)
	..()

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, "<span class='warning'>[src] already has a jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(slot_wear_suit)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return

		if(user.transferItemToLoc(I, src))
			jetpack = I
			to_chat(user, "<span class='notice'>You successfully install the jetpack into [src].</span>")

	else if(istype(I, /obj/item/weapon/screwdriver))
		if(!jetpack)
			to_chat(user, "<span class='warning'>[src] has no jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(slot_wear_suit))
			to_chat(user, "<span class='warning'>You cannot remove the jetpack from [src] while wearing it.</span>")
			return

		jetpack.turn_off()
		jetpack.loc = get_turf(src)
		jetpack = null
		to_chat(user, "<span class='notice'>You successfully remove the jetpack from [src].</span>")


/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(jetpack)
		if(slot == slot_wear_suit)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == slot_wear_suit) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return 1

	//Engineering
/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75, fire = 100, acid = 75)
	item_color = "engineering"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75, fire = 100, acid = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	resistance_flags = FIRE_PROOF

	//Atmospherics
/obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	icon_state = "hardsuit0-atmospherics"
	item_state = "atmo_helm"
	item_color = "atmospherics"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0, fire = 100, acid = 75)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding."
	icon_state = "hardsuit-atmospherics"
	item_state = "atmo_hardsuit"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0, fire = 100, acid = 75)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/atmos


	//Chief Engineer's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	item_state = "ce_helm"
	item_color = "white"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90, fire = 100, acid = 90)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/elite
	icon_state = "hardsuit-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90, fire = 100, acid = 90)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	jetpack = /obj/item/weapon/tank/jetpack/suit

	//Mining hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating for wildlife encounters and dual floodlights."
	icon_state = "hardsuit0-mining"
	item_state = "mining_helm"
	item_color = "mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	heat_protection = CHEST|GROIN|LEGS|ARMS
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50, fire = 50, acid = 75)
	brightness_on = 7
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/resonator, /obj/item/device/mining_scanner, /obj/item/device/t_scanner/adv_mining_scanner, /obj/item/weapon/gun/energy/kinetic_accelerator)


/obj/item/clothing/suit/space/hardsuit/mining
	icon_state = "hardsuit-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating for wildlife encounters."
	item_state = "mining_hardsuit"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50, fire = 50, acid = 75)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals,/obj/item/weapon/storage/bag/ore,/obj/item/weapon/pickaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining

	//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50, fire = 50, acid = 90)
	on = TRUE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	visor_flags = STOPSPRESSUREDMAGE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon()
	icon_state = "hardsuit[on]-[item_color]"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/New()
	..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/syndi))
		linkedsuit = loc

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot toggle your helmet while in this [user.loc]!</span>" )
		return
	on = !on
	if(on || force)
		to_chat(user, "<span class='notice'>You switch your hardsuit to EVA mode, sacrificing speed for space protection.</span>")
		name = initial(name)
		desc = initial(desc)
		set_light(brightness_on)
		flags |= visor_flags
		flags_cover |= HEADCOVERSEYES | HEADCOVERSMOUTH
		flags_inv |= visor_flags_inv
		cold_protection |= HEAD
	else
		to_chat(user, "<span class='notice'>You switch your hardsuit to combat mode and can now run at full speed.</span>")
		name += " (combat)"
		desc = alt_desc
		set_light(0)
		flags &= ~visor_flags
		flags_cover &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
		flags_inv &= ~visor_flags_inv
		cold_protection &= ~HEAD
	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	toggle_hardsuit_mode(user)
	user.update_inv_head()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/toggle_hardsuit_mode(mob/user) //Helmet Toggles Suit Mode
	if(linkedsuit)
		if(on)
			linkedsuit.name = initial(linkedsuit.name)
			linkedsuit.desc = initial(linkedsuit.desc)
			linkedsuit.slowdown = 1
			linkedsuit.flags |= STOPSPRESSUREDMAGE
			linkedsuit.cold_protection |= CHEST | GROIN | LEGS | FEET | ARMS | HANDS
		else
			linkedsuit.name += " (combat)"
			linkedsuit.desc = linkedsuit.alt_desc
			linkedsuit.slowdown = 0
			linkedsuit.flags &= ~(STOPSPRESSUREDMAGE)
			linkedsuit.cold_protection &= ~(CHEST | GROIN | LEGS | FEET | ARMS | HANDS)

		linkedsuit.icon_state = "hardsuit[on]-[item_color]"
		linkedsuit.update_icon()
		user.update_inv_wear_suit()
		user.update_inv_w_uniform()


/obj/item/clothing/suit/space/hardsuit/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50, fire = 50, acid = 90)
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword/saber,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/weapon/tank/jetpack/suit

//Elite Syndie suit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fireproofing. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "An elite version of the syndicate helmet, with improved armour and fireproofing. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndielite"
	item_color = "syndielite"
	armor = list(melee = 60, bullet = 60, laser = 50, energy = 25, bomb = 55, bio = 100, rad = 70, fire = 100, acid = 100)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF


/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in travel mode."
	alt_desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in combat mode."
	icon_state = "hardsuit0-syndielite"
	item_color = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor = list(melee = 60, bullet = 60, laser = 50, energy = 25, bomb = 55, bio = 100, rad = 70, fire = 100, acid = 100)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

//The Owl Hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/owl
	name = "owl hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	item_state = "s_helmet"
	item_color = "owl"
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE

/obj/item/clothing/suit/space/hardsuit/syndi/owl
	name = "owl hardsuit"
	desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	item_state = "s_suit"
	item_color = "owl"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/owl


	//Wizard hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "hardsuit0-wiz"
	item_state = "wiz_helm"
	item_color = "wiz"
	resistance_flags = FIRE_PROOF | ACID_PROOF //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 20, bomb = 35, bio = 100, rad = 50, fire = 100, acid = 100)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/wizard
	icon_state = "hardsuit-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 20, bomb = 35, bio = 100, rad = 50, fire = 100, acid = 100)
	allowed = list(/obj/item/weapon/teleportation_scroll,/obj/item/weapon/tank/internals)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/wizard


	//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	item_state = "medical_helm"
	item_color = "medical"
	flash_protect = 0
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50, fire = 75, acid = 75)
	scan_reagents = 1

/obj/item/clothing/suit/space/hardsuit/medical
	icon_state = "hardsuit-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Built with lightweight materials for easier movement."
	item_state = "medical_hardsuit"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50, fire = 75, acid = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical

	//Research Director hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/rd
	name = "prototype hardsuit helmet"
	desc = "A prototype helmet designed for research in a hazardous, low pressure environment. Scientific data flashes across the visor."
	icon_state = "hardsuit0-rd"
	item_color = "rd"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	var/onboard_hud_enabled = 0 //stops conflicts with another diag HUD
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 100, bio = 100, rad = 60, fire = 60, acid = 80)
	var/obj/machinery/doppler_array/integrated/bomb_radar
	scan_reagents = 1
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/head/helmet/space/hardsuit/rd/New()
	..()
	bomb_radar = new /obj/machinery/doppler_array/integrated(src)

/obj/item/clothing/head/helmet/space/hardsuit/rd/equipped(mob/living/carbon/human/user, slot)
	..()
	if(user.glasses && istype(user.glasses, /obj/item/clothing/glasses/hud/diagnostic))
		to_chat(user, ("<span class='warning'>Your [user.glasses] prevents you using [src]'s diagnostic visor HUD.</span>"))
	else
		onboard_hud_enabled = 1
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC]
		DHUD.add_hud_to(user)

/obj/item/clothing/head/helmet/space/hardsuit/rd/dropped(mob/living/carbon/human/user)
	..()
	if(onboard_hud_enabled && !(user.glasses && istype(user.glasses, /obj/item/clothing/glasses/hud/diagnostic)))
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC]
		DHUD.remove_hud_from(user)

/obj/item/clothing/suit/space/hardsuit/rd
	icon_state = "hardsuit-rd"
	name = "prototype hardsuit"
	desc = "A prototype suit that protects against hazardous, low pressure environments. Fitted with extensive plating for handling explosives and dangerous research materials."
	item_state = "hardsuit-rd"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/gun/energy/wormhole_projector,
	/obj/item/weapon/hand_tele, /obj/item/device/aicard)
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 100, bio = 100, rad = 60, fire = 60, acid = 80)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/rd



	//Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	item_color = "sec"
	armor = list(melee = 30, bullet = 15, laser = 30,energy = 10, bomb = 10, bio = 100, rad = 50, fire = 75, acid = 75)


/obj/item/clothing/suit/space/hardsuit/security
	icon_state = "hardsuit-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/ballistic,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50, fire = 75, acid = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security

	//Head of Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "head of security's hardsuit helmet"
	desc = "a special bulky helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-hos"
	item_color = "hos"
	armor = list(melee = 45, bullet = 25, laser = 30,energy = 10, bomb = 25, bio = 100, rad = 50, fire = 95, acid = 95)


/obj/item/clothing/suit/space/hardsuit/security/hos
	icon_state = "hardsuit-hos"
	name = "head of security's hardsuit"
	desc = "A special bulky suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	armor = list(melee = 45, bullet = 25, laser = 30, energy = 10, bomb = 25, bio = 100, rad = 50, fire = 95, acid = 95)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/weapon/tank/jetpack/suit

	//Captain
/obj/item/clothing/head/helmet/space/hardsuit/captain
	name = "captain's hardsuit helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A tactical SWAT helmet MK.II boasting better protection and a horrible fashion sense."
	armor = list(melee = 40, bullet = 50, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 50, fire = 100, acid = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR //we want to see the mask
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/captain/attack_self()
	return //Sprites required for flashlight

/obj/item/clothing/suit/space/hardsuit/captain
	name = "captain's SWAT suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available Usually reserved for heavy hitter corporate security, this one has a regal finish in Nanotrasen company colors. Better not let the assistants get a hold of it."
	icon_state = "caparmor"
	item_state = "capspacesuit"
	allowed = list(/obj/item/weapon/tank/internals, /obj/item/device/flashlight,/obj/item/weapon/gun/energy, /obj/item/weapon/gun/ballistic, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	armor = list(melee = 40, bullet = 50, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 50, fire = 100, acid = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT //this needed to be added a long fucking time ago
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/captain

	//Clown
/obj/item/clothing/head/helmet/space/hardsuit/clown
	name = "cosmohonk hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-humor environment. Has radiation shielding."
	icon_state = "hardsuit0-clown"
	item_state = "hardsuit0-clown"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75, fire = 60, acid = 30)
	item_color = "clown"

/obj/item/clothing/suit/space/hardsuit/clown
	name = "cosmohonk hardsuit"
	desc = "A special suit that protects against hazardous, low humor environments. Has radiation shielding. Only a true clown can wear it."
	icon_state = "hardsuit-clown"
	item_state = "clown_hardsuit"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75, fire = 60, acid = 30)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/clown

/obj/item/clothing/suit/space/hardsuit/clown/mob_can_equip(mob/M, slot)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(H.mind.assigned_role == "Clown")
		return TRUE
	else
		return FALSE

	//Old Prototype
/obj/item/clothing/head/helmet/space/hardsuit/ancient
	name = "prototype RIG hardsuit helmet"
	desc = "Early prototype RIG hardsuit helmet, designed to quickly shift over a user's head. Design constraints of the helmet mean it has no inbuilt cameras, thus it restricts the users visability."
	icon_state = "hardsuit0-ancient"
	item_state = "anc_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75)
	item_color = "ancient"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ancient
	name = "prototype RIG hardsuit"
	desc = "Prototype powered RIG hardsuit. Provides excellent protection from the elements of space while being comfortable to move around in, thanks to the powered locomotives. Remains very bulky however."
	icon_state = "hardsuit-ancient"
	item_state = "anc_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75)
	slowdown = 3
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	resistance_flags = FIRE_PROOF
	var/footstep = 1

/obj/item/clothing/suit/space/hardsuit/ancient/on_mob_move()
	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(footstep > 1)
		playsound(src, "servostep", 100, 1)
		footstep = 0
	else
		footstep++

/////////////SHIELDED//////////////////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded
	name = "shielded hardsuit"
	desc = "A hardsuit with built in energy shielding. Will rapidly recharge when not under fire."
	icon_state = "hardsuit-hos"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/gun,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50, fire = 100, acid = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 200 //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging
	var/shield_state = "shield-old"
	var/shield_on = "shield-old"

/obj/item/clothing/suit/space/hardsuit/shielded/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	recharge_cooldown = world.time + recharge_delay
	if(current_charges > 0)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(2, 1, src)
		s.start()
		owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
		current_charges--
		if(recharge_rate)
			START_PROCESSING(SSobj, src)
		if(current_charges <= 0)
			owner.visible_message("[owner]'s shield overloads!")
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return 1
	return 0


/obj/item/clothing/suit/space/hardsuit/shielded/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/space/hardsuit/shielded/process()
	if(world.time > recharge_cooldown && current_charges < max_charges)
		current_charges = Clamp((current_charges + recharge_rate), 0, max_charges)
		playsound(loc, 'sound/magic/charge.ogg', 50, 1)
		if(current_charges == max_charges)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			STOP_PROCESSING(SSobj, src)
		shield_state = "[shield_on]"
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			C.update_inv_wear_suit()

/obj/item/clothing/suit/space/hardsuit/shielded/worn_overlays(isinhands)
	. = list()
	if(!isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', shield_state, MOB_LAYER + 0.01)

/obj/item/clothing/head/helmet/space/hardsuit/shielded
	resistance_flags = FIRE_PROOF | ACID_PROOF

///////////////Capture the Flag////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded/ctf
	name = "white shielded hardsuit"
	desc = "Standard issue hardsuit for playing capture the flag."
	icon_state = "ert_medical"
	item_state = "ert_medical"
	item_color = "ert_medical"
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL | NODROP //Dont want people changing into the other teams gear
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	armor = list(melee = 0, bullet = 30, laser = 30, energy = 30, bomb = 50, bio = 100, rad = 100, fire = 95, acid = 95)
	slowdown = 0
	max_charges = 5

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	name = "red shielded hardsuit"
	icon_state = "ert_security"
	item_state = "ert_security"
	item_color = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	shield_state = "shield-red"
	shield_on = "shield-red"

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	name = "blue shielded hardsuit"
	desc = "Standard issue hardsuit for playing capture the flag."
	icon_state = "ert_command"
	item_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue



/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	name = "shielded hardsuit helmet"
	desc = "Standard issue hardsuit helmet for playing capture the flag."
	icon_state = "hardsuit0-ert_medical"
	item_state = "hardsuit0-ert_medical"
	item_color = "ert_medical"
	armor = list(melee = 0, bullet = 30, laser = 30, energy = 30, bomb = 50, bio = 100, rad = 100, fire = 95, acid = 95)


/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	icon_state = "hardsuit0-ert_security"
	item_state = "hardsuit0-ert_security"
	item_color = "ert_security"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue
	name = "shielded hardsuit helmet"
	desc = "Standard issue hardsuit helmet for playing capture the flag."
	icon_state = "hardsuit0-ert_commander"
	item_state = "hardsuit0-ert_commander"
	item_color = "ert_commander"





//////Syndicate Version

/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit"
	desc = "An advanced hardsuit with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50, fire = 100, acid = 100)
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword/saber,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	slowdown = 0


/obj/item/clothing/suit/space/hardsuit/shielded/syndi/New()
	jetpack = new /obj/item/weapon/tank/jetpack/suit(src)
	..()

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced hardsuit helmet with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50, fire = 100, acid = 100)

///SWAT version
/obj/item/clothing/suit/space/hardsuit/shielded/swat
	name = "death commando spacesuit"
	desc = "an advanced hardsuit favored by commandos for use in special operations."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	item_color = "syndi"
	max_charges = 4
	current_charges = 4
	recharge_delay = 15
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	dog_fashion = /datum/dog_fashion/back/deathsquad

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	name = "death commando helmet"
	desc = "A tactical helmet with built in energy shielding."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	item_color = "syndi"
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	actions_types = list()
