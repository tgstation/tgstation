/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */


/datum/game_mode
	var
		name = "invalid"
		config_tag = null
		intercept_hacked = 0
		votable = 1
		probability = 1
		station_was_nuked = 0 //see nuclearbomb.dm and malfunction.dm
		explosion_in_progress = 0 //sit back and relax
		list/datum/mind/modePlayer = new
		list/restricted_jobs = list()
		required_players = 0
		required_enemies = 0
		uplink_welcome
		uplink_uses
		uplink_items = {"Highly Visible and Dangerous Weapons;
/obj/item/weapon/gun/projectile:6:Revolver;
/obj/item/ammo_magazine/a357:2:Ammo-357;
/obj/item/weapon/gun/energy/crossbow:5:Energy Crossbow;
/obj/item/weapon/melee/energy/sword:4:Energy Sword;
/obj/item/weapon/storage/box/syndicate:10:Syndicate Bundle;
/obj/item/weapon/storage/emp_kit:4:5 EMP Grenades;
Whitespace:Seperator;
Stealthy and Inconspicuous Weapons;
/obj/item/weapon/pen/sleepypen:3:Sleepy Pen;
/obj/item/weapon/soap/syndie:1:Syndicate Soap;
/obj/item/weapon/cartridge/syndicate:3:Detomatix PDA Cartridge;
Whitespace:Seperator;
Stealth and Camouflage Items;
/obj/item/clothing/under/chameleon:4:Chameleon Jumpsuit, with armor.;
/obj/item/clothing/shoes/syndigaloshes:2:No-Slip Syndicate Shoes;
/obj/item/weapon/card/id/syndicate:3:Agent ID card;
/obj/item/clothing/mask/gas/voice:4:Voice Changer;
/obj/item/clothing/glasses/thermal:4:Thermal Imaging Glasses;
/obj/item/device/chameleon:4:Chameleon-Projector;
/obj/item/weapon/stamperaser:1:Stamp Remover;
Whitespace:Seperator;
Devices and Tools;
/obj/item/weapon/card/emag:4:Cryptographic Sequencer (Limited uses, almost full access);
/obj/item/device/hacktool:3:Hacktool (Slow, but stealthy.  Unlimited uses);
/obj/item/weapon/storage/toolbox/syndicate:1:Fully Loaded Toolbox;
/obj/item/device/encryptionkey/traitor:3:Traitor Radio Key;
/obj/item/device/encryptionkey/binary:3:Binary Translator Key;
/obj/item/weapon/storage/syndie_kit/space:3:Space Suit;
/obj/item/weapon/aiModule/syndicate:7:Hacked AI Upload Module;
/obj/item/weapon/plastique:2:C-4 (Destroys walls);
/obj/item/weapon/syndie/c4explosive:4:Low Power Explosive Charge, with Detonator;
/obj/item/device/powersink:5:Powersink (DANGER!);
/obj/machinery/singularity_beacon/syndicate:7:Singularity Beacon (DANGER!);
/obj/item/weapon/circuitboard/teleporter:20:Teleporter Circuit Board;
Whitespace:Seperator;
Implants;
/obj/item/weapon/storage/syndie_kit/imp_freedom:3:Freedom Implant;
/obj/item/weapon/storage/syndie_kit/imp_compress:5:Compressed Matter Implant;
/obj/item/weapon/storage/syndie_kit/imp_explosive:6:Explosive Implant;
/obj/item/weapon/storage/syndie_kit/imp_uplink:10:Uplink Implant (Contains 5 Telecrystals);
Whitespace:Seperator;
Badassery;
/obj/item/toy/syndicateballoon:10:For showing that You Are The BOSS (Useless Balloon);
Whitespace:Seperator;"}

//obj/item/weapon/syndie/c4explosive/heavy:7:High (!) Power Explosive Charge, with Detonator;

/datum/game_mode/proc/announce() //to be calles when round starts
	world << "<B>Notice</B>: [src] did not define announce()"


///can_start()
///Checks to see if the game can be setup and ran with the current number of players or whatnot.
/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/new_player/player in world)
		if((player.client)&&(player.ready))
			playerC++
	if(playerC >= required_players)
		return 1
	return 0


///pre_setup()
///Attempts to select players for special roles the mode might have.
/datum/game_mode/proc/pre_setup()
	return 1


///post_setup()
///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup()
	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(ticker && ticker.mode)
		feedback_set_details("game_mode","[ticker.mode]")
	if(revdata)
		feedback_set_details("revision","[revdata.revision]")
	feedback_set_details("server_ip","[world.internet_address]")
	return 1


///process()
///Called by the gameticker
/datum/game_mode/proc/process()
	return 0


/datum/game_mode/proc/check_finished() //to be called by ticker
	if(emergency_shuttle.location==2 || station_was_nuked)
		return 1
	return 0


/datum/game_mode/proc/declare_completion()
	return 0


/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	return 0

/datum/game_mode/proc/latespawn(var/mob)

/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))

	if(!intercept_hacked)
		possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	shuffle(possible_modes)

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		if(modePlayer.len == 0)
			intercepttext += i_text.build(A)
		else
			intercepttext += i_text.build(A, pick(modePlayer))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper - 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('intercept.ogg')
	if(security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)


/datum/game_mode/proc/get_players_for_role(var/role, override_jobbans=1)
	var/list/candidates = list()
	for(var/mob/new_player/player in world)
		if(player.client && player.ready)
			if(player.preferences.be_special & role)
				if(!jobban_isbanned(player, "Syndicate"))
					candidates += player.mind

	if(candidates.len < required_enemies)
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				if(!jobban_isbanned(player, "Syndicate"))
					candidates += player.mind

	if(candidates.len < required_enemies && override_jobbans) //just to be safe. Ignored jobbans are better than broken round. Shouldn't happen usually. --rastaf0
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				candidates += player.mind
	return candidates


/datum/game_mode/proc/check_player_role_pref(var/role, var/mob/new_player/player)
	if(player.preferences.be_special & role)
		return 1
	return 0


/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			. ++


///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/game_mode/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in world)
		if(player.stat!=2 && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/player in world)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads
