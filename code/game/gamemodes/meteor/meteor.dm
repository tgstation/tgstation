/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/const/meteordelay = 2000
	var/nometeors = 1
	required_players = 0

	uplink_welcome = "EVIL METEOR Uplink Console:"
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
/obj/item/clothing/under/chameleon:3:Chameleon Jumpsuit;
/obj/item/clothing/shoes/syndigaloshes:2:No-Slip Syndicate Shoes;
/obj/item/weapon/card/id/syndicate:3:Agent ID card;
/obj/item/clothing/mask/gas/voice:4:Voice Changer;
/obj/item/clothing/glasses/thermal:4:Thermal Imaging Glasses;
/obj/item/device/chameleon:4:Chameleon-Projector;
/obj/item/weapon/stamperaser:1:Stamp Remover;
Whitespace:Seperator;
Devices and Tools;
/obj/item/weapon/card/emag:3:Cryptographic Sequencer;
/obj/item/device/hacktool:4:Hacktool;
/obj/item/weapon/storage/toolbox/syndicate:1:Fully Loaded Toolbox;
/obj/item/weapon/aiModule/syndicate:7:Hacked AI Upload Module;
/obj/item/device/radio/headset/traitor:3:Headset with Binary Translator;
/obj/item/weapon/plastique:2:C-4;
/obj/item/device/powersink:5:Powersink (DANGER!);
/obj/machinery/singularity_beacon/syndicate:7:Singularity Beacon (DANGER!);
Whitespace:Seperator;
Implants;
/obj/item/weapon/storage/syndie_kit/imp_freedom:3:Freedom Implant;
/obj/item/weapon/storage/syndie_kit/imp_compress:5:Compressed Matter Implant;
/obj/item/weapon/storage/syndie_kit/imp_explosive:6:Explosive Implant;
/obj/item/weapon/storage/syndie_kit/imp_uplink:10:Uplink Implant (Contains 5 Telecrystals);
Whitespace:Seperator;
Badassery;
/obj/item/toy/syndicateballoon:10:For showing that You Are The BOSS (Useless Balloon);"}
	uplink_uses = 10

/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"


/datum/game_mode/meteor/post_setup()
	defer_powernet_rebuild = 2//Might help with the lag
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	spawn(meteordelay)
		nometeors = 0
	..()


/datum/game_mode/meteor/process()
	if(nometeors) return
	/*if(prob(80))
		spawn()
			dust_swarm("norm")
	else
		spawn()
			dust_swarm("strong")*/
	spawn() spawn_meteors(6)


/datum/game_mode/meteor/declare_completion()
	var/list/survivors = list()
	var/area/escape_zone = locate(/area/shuttle/escape/centcom)

	for(var/mob/living/player in world)
		if (player.client)
			if (player.stat != 2)
				var/turf/location = get_turf(player.loc)
				if (location in escape_zone)
					survivors[player.real_name] = "shuttle"
				else
					survivors[player.real_name] = "alive"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors.len)

	if (survivors.len)
		world << "\blue <B>The following survived the meteor attack!</B>"
		for(var/survivor in survivors)
			var/condition = survivors[survivor]
			switch(condition)
				if("shuttle")
					world << "\t <B><FONT size = 2>[survivor] escaped on the shuttle!</FONT></B>"
				if("pod")
					world << "\t <FONT size = 2>[survivor] escaped on an escape pod!</FONT>"
				if("alive")
					world << "\t <FONT size = 1>[survivor] stayed alive. Whereabouts unknown.</FONT>"
	else
		world << "\blue <B>No one survived the meteor attack!</B>"

	..()
	return 1
