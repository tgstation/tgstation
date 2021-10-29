/////////////////////////////
//SKYRAT MODULAR UPLINK ITEMS
/////////////////////////////

//Place any new uplink items in this file, and explain what they do

//BUNDLES
/* /datum/uplink_item/bundles_tc/spaceassassin
	name = "Space Assassin Bundle"
	desc = "A unique kit commonly used by military infiltrators and the like to get the drop on unsuspecting crew, perfect for the aspiring covert assassin and stealthy manipulator."
	item = /obj/item/storage/box/syndie_kit/spaceassassin
	cost = 30 //40 tc would have been better
*/ //To be balanced
//DANGEROUS
/datum/uplink_item/dangerous/aps_traitor
	name = "Stechkin APS Machine Pistol"
	desc = "An ancient Soviet machine pistol, refurbished for the modern age. Uses 9mm auto rounds in 15-round magazines and is compatible \
			with suppressors. The gun fires in three round bursts."
	item = /obj/item/gun/ballistic/automatic/pistol/aps
	cost = 10

/datum/uplink_item/dangerous/foamsmg_traitor
	name = "Toy Submachine Gun"
	desc = "A fully-loaded Donksoft bullpup submachine gun that fires riot grade darts with a 20-round magazine."
	item = /obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot
	cost = 5

/datum/uplink_item/dangerous/revolver_alt
	name = "Unica Six Revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."
	item = /obj/item/gun/ballistic/revolver/mateba
	cost = 11
	surplus = 50

/datum/uplink_item/dangerous/holocarp
	name = "Holocarp"
	desc = "Fishsticks prepared through ritualistic means in honor of the god Carp-sie, capable of binding a holocarp \
			to act as a servant and guardian to their host."
	item = /obj/item/guardiancreator/carp/choose
	cost = 10
	surplus = 0
	player_minimum = 25
	restricted = TRUE

/datum/uplink_item/dangerous/smgc20r_traitor
	name = "C-20r Submachine Gun"
	desc = "A fully-loaded Scarborough Arms bullpup submachine gun. The C-20r fires .45 rounds with a \
			24-round magazine and is compatible with suppressors."
	item = /obj/item/gun/ballistic/automatic/c20r/unrestricted
	cost = 14

/datum/uplink_item/dangerous/shotgun_traitor
	name = "Bulldog Shotgun"
	desc = "A fully-loaded semi-automatic drum-fed shotgun. Compatible with all 12g rounds. Designed for close \
			quarter anti-personnel engagements."
	item = /obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	cost = 13

/datum/uplink_item/dangerous/shield_traitor
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles and defending \
			against other attacks. Pair with an Energy Sword for a killer combination."
	item = /obj/item/shield/energy
	cost = 5

/datum/uplink_item/dangerous/katana_traitor
	name = "Katana"
	desc = "An incredibly sharp sword used by Samurais. Woefully underpowered in D20."
	item = /obj/item/katana
	cost = 7

/datum/uplink_item/dangerous/oddjob
	name = "Deadly Bowler Hat"
	desc = "An incredibly sharp edged bowler hat used by an infamously short operative."
	item = /obj/item/clothing/head/sus_bowler
	cost = 20

//STEALTHY WEAPONS
/datum/uplink_item/stealthy_weapons/cqc_traitor
	name = "CQC Manual"
	desc = "A manual that teaches a single user tactical Close-Quarters Combat before self-destructing."
	item = /obj/item/book/granter/martial/cqc
	cost = 23
	surplus = 17

// Removed from the uplink for the time being.
/*datum/uplink_item/stealthy_weapons/cqcplus
	name = "CQC+ Manual"
	desc = "A manual that teaches a single user tactical Close-Quarters Combat and how to deflect projectiles before self-destructing."
	item = /obj/item/book/granter/martial/cqc/plus
	cost = 30
	surplus = 20
*/

/datum/uplink_item/stealthy_weapons/telescopicbaton
	name = "Telescopic Baton"
	desc = "A telescopic baton, exactly like the ones heads are issued. Good for knocking people down briefly."
	item = /obj/item/melee/baton/telescopic
	cost = 2
	surplus = 0

//STEALTHY TOOOLS
/datum/uplink_item/stealthy_tools/infiltratormask
	name = "Voice-Muffling Balaclava"
	desc = "A balaclava that muffles your voice, masking your identity. Also provides flash immunity!"
	item = /obj/item/clothing/mask/infiltrator
	cost = 2

/datum/uplink_item/stealthy_tools/deluxe_agent_card
	name = "Deluxe Agent Identification Card"
	desc = "Created by Cybersun Industries to be the ultimate for field operations, this upgraded Agent ID \
	comes with all the fluff of the original, but with an upgraded microchip - allowing for the storage of all \
	standard Nanotrasen access codes in one conveinent package. Now in glossy olive by default!"
	item = /obj/item/card/id/advanced/chameleon/black
	cost = 5 //Since this gives the possibility for All Access, this is a BIGBOY tool. Compared to oldbases' skeleton key, though, you still have to steal it somehow.

/datum/uplink_item/stealthy_tools/advanced_cham_headset
	name = "Advanced Chameleon Headset" //Consider this a standin for the oldbase headset upgrader.
	desc = "A premium model Chameleon Headset. All the features you love of the original, but now with flashbang \
	protection, voice amplification, memory-foam, HD Sound Quality, and extra-wide spectrum dial. Usually reserved \
	for high-ranking Cybersun officers, a few spares have been reserved for field agents."
	item = /obj/item/radio/headset/chameleon/advanced
	cost = 4 //Also a BIGBOY tool. Though inconvienent to wield, this allows the wearer to spy and interact with any one frequency they desire, even without the proper encryption key, along with flashbang protection and loudmode. Cannot breach syndiecomms by itself.

/datum/uplink_item/stealthy_tools/syndieshotglasses
	name = "Extra Large Syndicate Shotglasses"
	desc = "These modified shot glasses can hold up to 50 units of booze while looking like a regular 15 unit model \
	guaranteed to knock someone on their ass with a hearty dose of bacchus blessing. Look for the Snake underneath \
	to tell these are the real deal. Box of 7."
	item = /obj/item/storage/box/syndieshotglasses
	cost = 2 //These are taken nearly exactly from Goon, very fun tool.
	restricted_roles = list("Bartender")

//EXPLOSIVES
/datum/uplink_item/explosives/buzzkill_traitor
	name = "Buzzkill Grenade Box"
	desc = "A box with three grenades that release a swarm of angry bees upon activation. These bees indiscriminately attack friend or foe \
			with random toxins. Courtesy of the BLF and Tiger Cooperative."
	item = /obj/item/storage/box/syndie_kit/bee_grenades
	cost = 10

/datum/uplink_item/explosives/viscerators_traitor
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred \
			any non-operatives in the area."
	item = /obj/item/grenade/spawnergrenade/manhacks
	cost = 7
	surplus = 35

/datum/uplink_item/explosives/nukeop_traitor
	name = "Nuclear Delivery Grenade"
	desc = "A very confusing grenade containing 2 dehydrated nuclear operatives. Stand back when primed."
	item = /obj/item/grenade/spawnergrenade/therealnuke
	cost = 7
	surplus = 35

/datum/uplink_item/explosives/bonebang
	name = "Bonebang"
	desc = "A horrifying grenade filled with what looks to be bone and gore, which upon detonation will fill the room you're in with bone fragments."
	item = /obj/item/grenade/stingbang/bonebang
	cost = 5

//DEVICE TOOLS
/datum/uplink_item/device_tools/syndie_jaws_of_life_traitor
	name = "Syndicate Jaws of Life"
	desc = "Based on a Nanotrasen model, this powerful tool can be used as both a crowbar and a pair of wirecutters. \
	In its crowbar configuration, it can be used to force open airlocks. Very useful for entering the station or its departments."
	item = /obj/item/crowbar/power/syndicate
	cost = 3

/datum/uplink_item/device_tools/medkit_traitor
	name = "Syndicate Combat Medic Kit"
	desc = "This first aid kit is a suspicious brown and red. Included is a combat stimulant injector \
			for rapid healing, a medical night vision HUD for quick identification of injured personnel, \
			and other supplies helpful for a field medic."
	item = /obj/item/storage/firstaid/tactical
	cost = 4

/datum/uplink_item/device_tools/guerillagloves_traitor
	name = "Guerilla Gloves"
	desc = "A pair of highly robust combat gripper gloves that excels at performing takedowns at close range, with an added lining of insulation. Careful not to hit a wall!"
	item = /obj/item/clothing/gloves/tackler/combat/insulated
	cost = 2
	illegal_tech = FALSE

/datum/uplink_item/device_tools/ammo_pouch
	name = "Ammo Pouch"
	desc = "A small yet large enough pouch that can fit in your pocket, and has room for three magazines."
	item = /obj/item/storage/bag/ammo
	cost = 1

/datum/uplink_item/device_tools/syndie_glue
	name = "Glue"
	desc = "A cheap bottle of one use syndicate brand super glue. \
			Use on any item to make it undroppable. \
			Be careful not to glue an item you're already holding!"
	item = /obj/item/syndie_glue
	cost = 3

/datum/uplink_item/device_tools/syndikush
	name = "Syndikush Green Crack cart"
	desc = "A cheap Chinese vape cart that contains a potent combination of THC and \
			stimulants. Not made with real crack."
	item = /obj/item/reagent_containers/vapecart/syndicate
	cost = 5
	surplus = 90

//AMMO
/datum/uplink_item/ammo/pistolaps_traitor
	name = "9mm Stechkin APS Magazine"
	desc = "An additional 15-round 9mm magazine, compatible with the Stechkin APS machine pistol."
	item = /obj/item/ammo_box/magazine/m9mm_aps
	cost = 1

/datum/uplink_item/ammo/smg_traitor
	name = ".45 SMG Magazine"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun."
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 2

/datum/uplink_item/ammo/smgap_traitor
	name = ".45 Armor Piercing SMG Magazine"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun.\
			These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/smgm45/ap
	cost = 3

/datum/uplink_item/ammo/smgfire_traitor
	name = ".45 Incendiary SMG Magazine"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun.\
			Loaded with incendiary rounds which inflict little damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/smgm45/incen
	cost = 2

/datum/uplink_item/ammo/shotgun/buck_traitor
	name = "12g Buckshot Drum"
	desc = "An additional 8-round buckshot magazine for use with the Bulldog shotgun. Front towards enemy."
	item = /obj/item/ammo_box/magazine/m12g

/datum/uplink_item/ammo/shotgun/dragon_traitor
	name = "12g Dragon's Breath Drum"
	desc = "An alternative 8-round dragon's breath magazine for use in the Bulldog shotgun. \
			'I'm a fire starter, twisted fire starter!'"
	item = /obj/item/ammo_box/magazine/m12g/dragon

/datum/uplink_item/ammo/shotgun/meteor_traitor
	name = "12g Meteorslug Shells"
	desc = "An alternative 8-round meteorslug magazine for use in the Bulldog shotgun. \
		Great for blasting airlocks off their frames and knocking down enemies."
	item = /obj/item/ammo_box/magazine/m12g/meteor

/datum/uplink_item/ammo/shotgun/slug_traitor
	name = "12g Slug Drum"
	desc = "An additional 8-round slug magazine for use with the Bulldog shotgun. \
			Now 8 times less likely to shoot your pals."
	cost = 3
	item = /obj/item/ammo_box/magazine/m12g/slug

//SUITS

/datum/uplink_item/suits/standard_armor
	name = "Standard Armor Vest"
	desc = "A slim Type I armored vest that provides decent protection against most types of damage."
	item = /obj/item/clothing/suit/armor/vest
	cost = 1

/datum/uplink_item/suits/standard_armor_traitor
	name = "Bulletproof Armor Vest"
	desc = "A Type III heavy bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	item = /obj/item/clothing/suit/armor/bulletproof
	cost = 1

//HELMETS
/datum/uplink_item/suits/hardsuit/swathelmet_traitor
	name = "Syndicate Helmet"
	desc = "An extremely robust, space-worthy helmet in a nefarious red and black stripe pattern."
	item = /obj/item/clothing/head/helmet/swat
	cost = 2


//IMPLANTS
/datum/uplink_item/implants/antistun_traitor
	name = "CNS Rebooter Implant"
	desc = "This implant will help you get back up on your feet faster after being stunned. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/organ/syndicate/anti_stun
	cost = 6
	surplus = 0

//JOBS ONLY
/datum/uplink_item/role_restricted/cultkitsr //Ported from beestation
	name = "Cult Construct Kit"
	desc = "Recovered from an abandoned Nar'sie cult lair, two construct shells and a stash of empty soulstones was found. These were purified to prevent occult contamination and have been put in a belt so they may be used as an accessible source of disposable minions. The construct shells have been packaged into two beacons for rapid and portable deployment."
	item = /obj/item/storage/box/syndie_kit/cultkitsr
	cost = 15 //If used correctly, You actually get several servants or just get fucked over because no ghosts want to be a shade.
	restricted_roles = list("Chaplain")

//LOADOUTS

/datum/uplink_item/loadout_skyrat
	category = "Loadout"
	surplus = 0
	cant_discount = TRUE //I honestly don't think discount is worth it for those things, sorry.

/datum/uplink_item/loadout_skyrat/recon
	name = "Reconnaisance bundle"
	desc = "Get in and get out as quickly as you came with this unique kit of gear specialized in infiltration and observation."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/recon
	cost = 20

/datum/uplink_item/loadout_skyrat/spy
	name = "Spy bundle"
	desc = "Blend into the environment or any of crowd with this state-of-the-art stealth kit, perfect for infiltration experts."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/spy
	cost = 20

/datum/uplink_item/loadout_skyrat/stealthop
	name = "Burglar Bundle"
	desc = "Not a thing aboard the station is safe from your grubby hands with this specialized set of gear, perfect for the enterprising thief."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/stealthop
	cost = 20

/datum/uplink_item/loadout_skyrat/hacker
	name = "Hacker bundle"
	desc = "Subvert everything in sight using some of the most advanced tools available to operatives. If it’s powered, it’s already under your thumb."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/hacker
	cost = 15

/datum/uplink_item/loadout_skyrat/metaops
	name = "Bulldog Operative bundle"
	desc = "Fight the power with this frontline combatant kit, featuring armor and armaments commonly utilized by assault operative teams."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/metaops
	cost = 23

/datum/uplink_item/loadout_skyrat/bond
	name = "Classic Spy bundle"
	desc = "Play the hero or the villain in a cheesy spy movie with this throwback kit to far less modern syndicate operatives."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/bond
	cost = 20

/datum/uplink_item/loadout_skyrat/ninja
	name = "Cyborg Ninja bundle"
	desc = "Become a force of nature with this customized kit featuring next-generation syndicate technology in an efficient package."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/ninja
	cost = 20

/datum/uplink_item/loadout_skyrat/darklord
	name = "Dark Lord bundle"
	desc = "Wield unlimited power with this extremely effective combative kit, guaranteed to give the user efficient staying potential in any confrontation."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/darklord
	cost = 20

/datum/uplink_item/loadout_skyrat/hunter
	name = "Whaler bundle"
	desc = "There’s no whales in space, but there sure are carp. Blend in with your prey and wield an impossibly effective high-power harpoon gun in this tribute to a tale told long ago."
	item = /obj/item/storage/box/syndie_kit/loadout/hunter
	cost = 20

/datum/uplink_item/loadout_skyrat/bee
	name = "Buzzy bundle"
	desc = "Look bee-utiful in this extra specialized rapid attack kit, featuring unique armaments seen nowhere else and a bumble-y sense of style."
	item = /obj/item/storage/box/syndie_kit/loadout/bee
	cost = 20

/datum/uplink_item/loadout_skyrat/cryomancer
	name = "Mister Freeze bundle"
	desc = "Make everybody chill out at the sight of your power with this absolutely snowy weapons kit. Also happens to be great for ice-related puns."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/cryomancer
	cost = 20

/datum/uplink_item/loadout_skyrat/doctordeath
	name = "Doctor Death bundle"
	desc = "Be your very own mad scientist with this toxic bundle! Warning, license void if poisons used on self. Read bottom of bag for more information."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/doctordeath
	cost = 25

/datum/uplink_item/loadout_skyrat/donkcoshill
	name = "Donk Co. Shill bundle"
	desc = "Love Donk Pockets? Want to shill Donk Co. Toys? This bundle is for you! Contains some DonkSoft guns, a vending machine, restocking units, and a box of Donk Pockets."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/donkshillkit
	cost = 10

/datum/uplink_item/loadout_skyrat/downtownspecial
	name = "Downtown Special bundle"
	desc = "Ayyy fuggedaboudit! This bundle contains everything to be your own one man mafioso. Including an icon of the Virgin Mary for your own authentic mafia nickname. Gang members not included."
	item = /obj/item/storage/backpack/duffelbag/syndie/loadout/downtownspecial
	cost = 25

/datum/uplink_item/loadout_skyrat/ocelotfoxtrot
	name = "Snake Eater bundle"
	desc = "A kit themed around one certain gun spinning cat. Includes his famous colt special, and personalised ammo."
	item = /obj/item/storage/box/syndie_kit/loadout/ocelotfoxtrot
	cost = 15

/datum/uplink_item/loadout_skyrat/nt_impostor
	name = "Corporate Deceit bundle"
	desc = "Don the identities of the most powerful men and women in Nanotrasen, and pull strings from the shadows as you please with this specialized kit."
	item = /obj/item/storage/box/syndie_kit/loadout/nt_impostor
	cost = 20

/datum/uplink_item/loadout_skyrat/lasermanbundle
	name = "Laserman bundle"
	desc = "Themed after an infamous syndicate operative with a particular fighting style, this kit is both a fashionable throwback and a uniquely useful combative loadout."
	item = /obj/item/storage/box/syndie_kit/loadout/lasermanbundle
	cost = 20
