
/*
		WELCOME TO THE FULPSTATION CODE Z-LEVEL!


	Any time we want to outright overwrite a variable that is already given a value in a previously defined atom or datum, we
	can overwrite it here!

		WHY DO THIS?

	So we don't have to overwrite the variables defined in TG code.
*/





 	//antag disallowing//

/datum/game_mode/revolution
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Deputy")

/datum/game_mode/clockwork_cult
	restricted_jobs = list("Chaplain", "Captain", "Deputy")

/datum/game_mode/cult
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Deputy")

/datum/game_mode/traitor
	restricted_jobs = list("Cyborg", "Deputy")




/obj/item/clothing/accessory
	mob_overlay_icon = 'icons/mob/clothing/accessories.dmi'

/obj/item/clothing/suit/space/hardsuit
	var/toggle_helmet_sound = 'sound/mecha/mechmove03.ogg'

//*************************************************************************
//** FULPSTATION IMPROVED RECORD SECURITY PR -Surrealistik Oct 2019 BEGINS
//**-----------------------------------------------------------------------
//** -Adds security levels to the security record computer.
//** -Adds arrest logging for security bots.
//*************************************************************************

/mob/living/simple_animal/bot/secbot
	var/list/arrest_cooldown = list() //If you're in the list, we don't log the arrest

//*************************************************************************
//** FULPSTATION IMPROVED RECORD SECURITY PR -Surrealistik Oct 2019 ENDS
//**-----------------------------------------------------------------------
//** -Adds security levels to the security record computer.
//** -Adds arrest logging for security bots.
//*************************************************************************


//******************************************************
//SEC BODY CAMS by Surrealistik Oct 2019 BEGINS
//******************************************************
/obj/item/clothing/under/rank/security
	var/obj/machinery/camera/builtInCamera = null
	var/registrant
	var/camera_on = TRUE
	var/sound_time_stamp
	req_one_access = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)

/obj/machinery/computer/security
	req_one_access = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)

//******************************************************
//SEC BODY CAMS by Surrealistik Oct 2019 ENDS
//******************************************************


//*************************************************************
//** Mech Weapon Firing Pins PR by Surrealistik Oct 2019 BEGINS
//*************************************************************

/obj/item/mecha_parts/mecha_equipment/weapon
	var/obj/item/firing_pin/pin //standard firing pin for most guns
	var/initial_firing_pin //If it is unlocked by default, this is the firing pin type the weapon uses


/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma //Plasma cutter; more of a tool than a weapon
	initial_firing_pin = /obj/item/firing_pin //standard firing pin for most guns


/obj/item/mecha_parts/mecha_equipment/weapon/honker
	initial_firing_pin = /obj/item/firing_pin //standard firing pin for most guns


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar
	initial_firing_pin = /obj/item/firing_pin //standard firing pin for most guns


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar
	initial_firing_pin = /obj/item/firing_pin //standard firing pin for most guns


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove
	initial_firing_pin = /obj/item/firing_pin //standard firing pin for most guns

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana
	initial_firing_pin = null

/obj/item/firing_pin/mech
	name = "electronic mech firing pin"
	desc = "A small authentication device, to be inserted into a firearm receiver to allow operation. NT safety regulations require all new designs to incorporate one. This one is specifically designed to be installed into mech and exosuit weaponry only."

/obj/item/firing_pin/mech/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(istype(target, /obj/item/gun))
		to_chat(user, "<span class='warning'>This firing pin is incompatible with guns and only be installed into mech weaponry!</span>")

/obj/item/storage/box/syndicate/bundle_mech/PopulateContents()
	new /obj/item/firing_pin/mech(src)
	new /obj/item/mecha_parts/concealed_weapon_bay(src)

//*************************************************************
//** Mech Weapon Firing Pins PR by Surrealistik Oct 2019 ENDS
//*************************************************************


//***********************************************************************
//** FULP PROPER RADIO CHANNELS FOR BORGS by Surrealistik Nov 2019 BEGINS
//**---------------------------------------------------------------------
//** Borgs now have access to appropriate secure radio channels
//***********************************************************************


/obj/item/robot_module/medical/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_med, FREQ_MEDICAL)


/obj/item/robot_module/engineering/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_eng, FREQ_ENGINEERING)


/obj/item/robot_module/security/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_sec, FREQ_SECURITY)

/obj/item/robot_module/peacekeeper/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_sec, FREQ_SECURITY)


/obj/item/robot_module/miner/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_mining, FREQ_SUPPLY)


/obj/item/robot_module/clown/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_service, FREQ_SERVICE)

/obj/item/robot_module/standard/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_service, FREQ_SERVICE)

/obj/item/robot_module/janitor/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_service, FREQ_SERVICE)

/obj/item/robot_module/butler/do_transform_delay()
	..()
	borg_set_radio(/obj/item/encryptionkey/headset_service, FREQ_SERVICE)


//***********************************************************************
//** FULP PROPER RADIO CHANNELS FOR BORGS by Surrealistik Nov 2019 ENDS
//**---------------------------------------------------------------------
//** Borgs now have access to appropriate secure radio channels
//***********************************************************************

//***************************************************************************
//** FULPSTATION HOLOBEDS by Surrealistik Nov 2019 BEGINS
//---------------------------------------------------------------------------
//** Adds no-collision holobeds to the medborg. Support for handheld versions
//***************************************************************************

/obj/item/robot_module/medical
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/borghypo,
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/extinguisher/mini,
		/obj/item/holobed_projector/robot,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/organ_storage,
		/obj/item/borg/lollipop)

//***************************************************************************
//** FULPSTATION HOLOBEDS by Surrealistik Nov 2019 ENDS
//---------------------------------------------------------------------------
//** Adds no-collision holobeds to the medborg. Support for handheld versions
//***************************************************************************


