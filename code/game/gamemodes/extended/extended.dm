/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0

	uplink_welcome = "Syndicate Uplink Console:"
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

/datum/game_mode/announce()
	world << "<B>The current game mode is - Extended Role-Playing!</B>"
	world << "<B>Just have fun and role-play!</B>"

/datum/game_mode/extended/pre_setup()
	setup_sectors()
	spawn_exporation_packs()
	return 1
