
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

/mob/living/simple_animal/bot/secbot
	var/obj/machinery/camera/builtInCamera = null

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
	borg_set_radio(RADIO_CHANNEL_MEDICAL)


/obj/item/robot_module/engineering/do_transform_delay()
	..()
	borg_set_radio(RADIO_CHANNEL_ENGINEERING)


/obj/item/robot_module/security/do_transform_delay()
	..()
	borg_set_radio(RADIO_CHANNEL_SECURITY)

/obj/item/robot_module/peacekeeper/do_transform_delay()
	..()
	borg_set_radio(RADIO_CHANNEL_SECURITY)


/obj/item/robot_module/miner/do_transform_delay()
	..()
	borg_set_radio(RADIO_CHANNEL_SUPPLY)

/obj/item/robot_module/clown/do_transform_delay()
	..()
	borg_set_radio(RADIO_CHANNEL_SERVICE)

/obj/item/robot_module/standard/do_transform_delay()
	..()
	borg_set_radio(RADIO_CHANNEL_SERVICE)

/obj/item/robot_module/janitor/do_transform_delay()
	..()
	borg_set_radio(RADIO_CHANNEL_SERVICE)

/obj/item/robot_module/butler/do_transform_delay()
	..()
	borg_set_radio(RADIO_CHANNEL_SERVICE)


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


//***************************************************************************
//** FULPSTATION SECBORG MODULE UPDATE by Surrealistik Jan 2020 BEGINS
//---------------------------------------------------------------------------
//** Expands the Secborg's module items and upgrades.
//***************************************************************************

//************************************************************************
//** Airlock Electroadaptive Psuedo Circuit BEGINS - Surrealistik Oct 2019
//************************************************************************

/obj/item/electroadaptive_pseudocircuit
	var/list/accesses = list()
	var/one_access = 0
	var/unres_sides = 0 //unrestricted sides, or sides of the airlock that will open regardless of access
	var/recharge_mod = 3 //allows for faster use of electroadaptive psuedocircuit; higher is slower; no idea why they made this cooldown so slow.

//************************************************************************
//** Airlock Electroadaptive Psuedo Circuit ENDS - Surrealistik Oct 2019
//************************************************************************

//***************************************************************************
//** FULPSTATION SECBORG MODULE UPDATE by Surrealistik Jan 2020 BEGINS
//---------------------------------------------------------------------------
//** Expands the Secborg's module items and upgrades.
//***************************************************************************

/obj/item/robot_module/security //Now has a crowbar to allow it to navigate depowered areas, and a default pepperspray.
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/e_gun/cyborg,
		/obj/item/reagent_containers/spray/pepper/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/handheld_sec_record_uplink/cyborg
		)
	emag_modules = list() //Instead we unlock lethals for the integrated e_gun


/obj/item/borg/upgrade/pinpointer //Sec borg can now install the crew monitor/pinpointer module.
	module_type = list(/obj/item/robot_module/medical, /obj/item/robot_module/syndicate_medical, /obj/item/robot_module/security)

/datum/techweb_node/cyborg_upg_combat
	design_ids = list("borg_upgrade_e_gun_cooler", "borg_upgrade_e_gun_kill")

//***************************************************************************
//** FULPSTATION SECBORG MODULE UPDATE by Surrealistik Jan 2020 BEGINS
//---------------------------------------------------------------------------
//** Expands the Secborg's module items and upgrades.
//***************************************************************************
//*****************************************************************************
//** Engineer Borg Manipulator Improvement by Surrealistik Oct 2019 BEGINS
//** -------------------------------------------------------------------------
//** Engiborgs now start with a manipulator for wall mounted frames and basic
//** electronics which can be upgraded to hold stock parts and circuitboards
//*****************************************************************************

/obj/item/robot_module/engineering
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter/cyborg,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/borg/apparatus/circuit,
		/obj/item/stack/cable_coil/cyborg)

/obj/item/borg/apparatus/circuit
	name = "basic component manipulation apparatus"
	desc = "A special apparatus for carrying and manipulating engineering components like electronics and wall mounted frames. Alt-Z or right-click to drop the stored object."
	var/upgraded = FALSE
	storable = list(/obj/item/wallframe,
				/obj/item/tank,
				/obj/item/electronics)

/obj/item/borg/upgrade/circuit_app
	name = "advanced component manipulation apparatus"
	desc = "An engineering cyborg upgrade that improves the engineering cyborg manipulator, allowing it to manipulate circuitboards and stock parts."

/datum/design/borg_upgrade_circuit_app
	name = "Cyborg Upgrade (Component Manipulator Upgrade)"

//*****************************************************************************
//** Engineer Borg Manipulator Improvement by Surrealistik Oct 2019 ENDS
//*****************************************************************************