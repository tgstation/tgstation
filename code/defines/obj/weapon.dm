/obj/item/weapon
	name = "weapon"
	icon = 'weapons.dmi'

/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'weapons.dmi'
	icon_state = "riot"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	g_amt = 7500
	m_amt = 1000
	origin_tech = "materials=2"

/obj/item/weapon/match
	name = "Match"
	desc = "A simple match stick, used for lighting tobacco"
	icon = 'cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = 0
	var/smoketime = 5
	w_class = 1.0
	origin_tech = "materials=1"

/obj/item/weapon/matchbox
	name = "Matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = 1
	flags = ONBELT | TABLEPASS
	var/matchcount = 10
	w_class = 1.0

/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/working = 0
	var/mode = 1
	var/disabled = 0
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 50000
	origin_tech = "materials=4"
	var/datum/effects/system/spark_spread/spark_system

/obj/item/weapon/rsf
	name = "Rapid-Service-Fabricator (RSF)"
	desc = "A device used to rapidly deploy service items."
	icon = 'items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	flags = TABLEPASS
	w_class = 3.0

/obj/item/weapon/rcd_ammo
	name = "Compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	m_amt = 30000
	g_amt = 15000

/obj/item/weapon/spacecash
	name = "Space Cash"
	desc = "You're rich, bitch!"
	icon = 'items.dmi'
	icon_state = "spacecash"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = 1.0

/obj/item/weapon/spacecash/c10
	icon_state = "spacecash10"
/obj/item/weapon/spacecash/c20
	icon_state = "spacecash20"
/obj/item/weapon/spacecash/c50
	icon_state = "spacecash50"
/obj/item/weapon/spacecash/c100
	icon_state = "spacecash100"
/obj/item/weapon/spacecash/c200
	icon_state = "spacecash200"
/obj/item/weapon/spacecash/c500
	icon_state = "spacecash500"
/obj/item/weapon/spacecash/c1000
	icon_state = "spacecash1000"

/obj/item/weapon/ammo
	name = "ammo"
	icon = 'ammo.dmi'
	var/amount_left = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "syringe_kit"
	m_amt = 50000
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/ammo/a357
	desc = "There are 7 rounds left!"
	name = "ammo-357"
	icon_state = "357-7"
	amount_left = 7.0

/obj/item/weapon/ammo/a45
	desc = "There are 10 rounds left!"
	name = "ammo-45"
	icon_state = "45-10"
	amount_left = 10.0

/obj/item/weapon/ammo/a763m
	desc = "There are 9 rounds left!"
	name = "ammo-7.63x25"
	icon_state = "7.63x25m-9"
	amount_left = 9.0

/obj/item/weapon/ammo/a9x19p
	desc = "There are 8 rounds left!"
	name = "ammo-9x19"
	icon_state = "9x19p-8"
	amount_left = 8.0

/obj/item/weapon/ammo/assaultmag
	desc = "There are 30 rounds left!"
	name = "5.56x45mm NATO"
	icon_state = "5.56"
	amount_left = 30.0

/obj/item/weapon/ammo/shell //easier to add new shell types. Like badmin laser/taser/pulse shells.
	desc = "Generic shell description."
	name = "Generic shell."
	icon_state = "blshell"
	m_amt = 9000
	New()
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/ammo/shell/beanbag
	desc = "A weak beanbag shell."
	name = "beanbag shell"
	icon_state = "bshell"
	m_amt = 10000

/obj/item/weapon/ammo/shell/gauge
	desc = "A 12gauge shell."
	name = "12 gauge shell"
	icon_state = "gshell"
	m_amt = 25000

/obj/item/weapon/ammo/shell/blank
	desc = "A blank shell."
	name = "blank shell"
	icon_state = "blshell"
	m_amt = 500

/obj/item/weapon/ammo/shell/dart
	desc = "A dart for use in shotguns.."
	name = "shotgun dart"
	icon_state = "blshell" //someone, draw the icon, please.
	m_amt = 50000 //because it's like, instakill.


/obj/item/weapon/ammo/a38
	desc = "A speedloader that contains 7 .38 Special rounds."
	name = "38-Special ammo"
	icon_state = "38-7"
	amount_left = 7.0
	m_amt = 10000

/obj/item/device/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1"

/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT | OPENCONTAINER
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=2;biotech=2"
	var
		details = 0
		recent_fail = 0

/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"

/obj/item/weapon/axe
	name = "Axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	var/active = 0.0
	force = 40.0
	throwforce = 25.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | CONDUCT | NOSHIELD | TABLEPASS
	origin_tech = "combat=3"

/obj/item/weapon/bananapeel
	name = "Banana Peel"
	desc = "A peel from a banana."
	icon = 'items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/baton
	name = "Stun Baton"
	desc = "A stun baton for hitting people with."
	icon_state = "stunbaton"
	item_state = "baton"
	flags = FPRINT | ONBELT | TABLEPASS
	force = 10
	throwforce = 7
	w_class = 3
	var/charges = 10.0
	var/maximum_charges = 10.0
	var/status = 1
	origin_tech = "combat=2"

/obj/item/weapon/bedsheet
	name = "bedsheet"
	icon = 'items.dmi'
	icon_state = "sheet"
	layer = 4.0
	item_state = "w_suit"
	throwforce = 1
	w_class = 1.0
	throw_speed = 2
	throw_range = 10

/obj/item/weapon/bikehorn
	name = "Bike Horn"
	desc = "A horn off of a bicycle."
	icon = 'items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	var/spam_flag = 0

/obj/item/weapon/medical
	name = "medical pack"
	icon = 'items.dmi'
	var/amount = 5
	w_class = 1
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/weapon/medical/bruise_pack
	name = "bruise pack"
	desc = "A pack designed to treat blunt-force trauma."
	icon_state = "brutepack"
	heal_brute = 60
	origin_tech = "biotech=1"

/obj/item/weapon/medical/ointment
	name = "ointment"
	icon_state = "ointment"
	heal_burn = 40
	origin_tech = "biotech=1"

/obj/item/weapon/c_tube
	name = "cardboard tube"
	icon = 'items.dmi'
	icon_state = "c_tube"
	throwforce = 1
	w_class = 1.0
	throw_speed = 4
	throw_range = 5

/obj/item/weapon/camera
	name = "camera"
	icon_state = "camera"
	var/last_pic = 1.0
	item_state = "wrench"
	w_class = 2.0
	origin_tech = "magnets=1"

/obj/item/weapon/card
	name = "card"
	icon = 'card.dmi'
	w_class = 1.0

	var/list/files = list(  )

/obj/item/weapon/card/data
	name = "data disk"
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/weapon/card/data/clown
	name = "Coordinates to Clown Planet"
	icon_state = "data"
	item_state = "card-id"
	layer = 3
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."

/obj/item/weapon/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"

/obj/item/weapon/card/id
	name = "identification card"
	icon_state = "id"
	item_state = "card-id"
	var/access = list()
	var/registered = null
	var/assignment = null
	var/obj/item/weapon/photo/PHOTO = null

/obj/item/weapon/card/id/gold
	name = "identification card"
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/weapon/card/id/syndicate
	name = "agent card"
	access = list(access_maint_tunnels)
	origin_tech = "syndicate=2"

/obj/item/weapon/card/id/captains_spare
	name = "Captain's spare ID"
	icon_state = "gold"
	item_state = "gold_id"
	registered = "Captain"
	assignment = "Captain"
	New()
		access = get_access("Captain")
		..()

/obj/item/weapon/cleaner
	desc = "Space Cleaner!"
	icon = 'janitor.dmi'
	name = "space cleaner"
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10

/obj/item/weapon/clipboard
	name = "clipboard"
	icon = 'items.dmi'
	icon_state = "clipboard00"
	var/obj/item/weapon/pen/pen = null
	item_state = "clipboard"
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 10

/obj/item/weapon/cloaking_device
	name = "cloaking device"
	icon = 'device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	origin_tech = "magnets=3;syndicate=3"

#define MAXCOIL 30
/obj/item/weapon/cable_coil
	name = "cable coil"
	var/amount = MAXCOIL
	icon = 'power.dmi'
	icon_state = "coil"
	desc = "A coil of power cable."
	throwforce = 10
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	flags = TABLEPASS|USEDELAY|FPRINT|CONDUCT
	item_state = "coil"

/obj/item/weapon/cable_coil/cut
	icon = 'power.dmi'
	icon_state = "coil2"
	origin_tech = "materials=1"

/obj/item/weapon/crowbar
	name = "crowbar"
	icon = 'items.dmi'
	icon_state = "crowbar"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	throwforce = 7.0
	item_state = "wrench"
	w_class = 2.0
	m_amt = 50

/obj/item/weapon/crowbar/red
	icon = 'items.dmi'
	icon_state = "red_crowbar"

/obj/item/weapon/disk
	name = "disk"
	icon = 'items.dmi'

/obj/item/weapon/disk/nuclear
	name = "Nuclear Authentication Disk"
	icon_state = "nucleardisk"
	item_state = "card-id"
	w_class = 1.0

/obj/item/weapon/dummy
	name = "dummy"
	invisibility = 101.0
	anchored = 1.0
	flags = 2.0

/obj/item/weapon/extinguisher
	name = "fire extinguisher"
	icon = 'items.dmi'
	icon_state = "fire_extinguisher0"
	var/last_use = 1.0
	var/safety = 1
	hitsound = 'smash.ogg'
	flags = FPRINT | USEDELAY | TABLEPASS | CONDUCT
	throwforce = 10
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 10.0
	item_state = "fire_extinguisher"
	m_amt = 90

/obj/item/weapon/f_card
	name = "Finger Print Card"
	icon = 'card.dmi'
	icon_state = "fingerprint0"
	var/amount = 10.0
	item_state = "paper"
	throwforce = 1
	w_class = 1.0
	throw_speed = 3
	throw_range = 5


/obj/item/weapon/fcardholder
	name = "Finger Print Case"
	icon = 'items.dmi'
	icon_state = "fcardholder0"
	item_state = "clipboard"


/obj/item/weapon/flashbang
	desc = "It is set to detonate in 3 seconds."
	name = "flashbang"
	icon = 'grenade.dmi'
	icon_state = "flashbang"
	var/state = null
	var/det_time = 30.0
	w_class = 2.0
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	origin_tech = "materials=2;combat=1"

/obj/item/weapon/empgrenade
	desc = "It is set to detonate in 5 seconds."
	name = "emp grenade"
	var/state = null
	var/det_time = 50.0
	w_class = 2.0
	icon = 'device.dmi'
	icon_state = "emp"
	item_state = "emp"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	origin_tech = "materials=2;magnets=3"

/obj/item/weapon/flasks
	name = "flask"
	icon = 'Cryogenic2.dmi'
	var/oxygen = 0.0
	var/plasma = 0.0
	var/coolant = 0.0

/obj/item/weapon/flasks/coolant
	name = "light blue flask"
	icon_state = "coolant-c"
	coolant = 1000.0

/obj/item/weapon/flasks/oxygen
	name = "blue flask"
	icon_state = "oxygen-c"
	oxygen = 500.0

/obj/item/weapon/flasks/plasma
	name = "orange flask"
	icon_state = "plasma-c"
	plasma = 500.0

/*
/obj/item/weapon/game_kit
	name = "Gaming Kit"
	icon = 'items.dmi'
	icon_state = "game_kit"
	var/selected = null
	var/board_stat = null
	var/data = ""
	var/base_url = "http://svn.slurm.us/public/spacestation13/misc/game_kit"
	item_state = "sheet-metal"
	w_class = 5.0
*/

/obj/item/weapon/gift
	name = "gift"
	icon = 'items.dmi'
	icon_state = "gift3"
	var/size = 3.0
	var/obj/item/gift = null
	item_state = "gift"
	w_class = 4.0

/obj/item/weapon/grab
	name = "grab"
	icon = 'screen1.dmi'
	icon_state = "grabbed"
	var/obj/screen/grab/hud1 = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = 1.0
	var/killing = 0.0
	var/allow_upgrade = 1.0
	var/last_suffocate = 1.0
	layer = 21
	abstract = 1.0
	item_state = "nothing"
	w_class = 5.0

/obj/item/weapon/gun
	name = "gun"
	icon = 'gun.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY
	item_state = "gun"
	m_amt = 2000
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	throw_range = 10
	origin_tech = "combat=1"

/obj/item/weapon/gun/shotgun
	name = "shotgun"
	icon_state = "shotgun"
	var/shellsmax
	var/shellsunlimited = 0
	var/index
	var/list/shells = list() //this is a list. All craftsmanship is of good quality. At least, it's better than two/eight vars, Uhangi! -- Barhandar //it is, thanks bro --uhangi
	w_class = 4.0 //dammit urist no
	force = 7.0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	var/pumped = 0
	shellsmax = 2
	origin_tech = "combat=2"

/obj/item/weapon/gun/shotgun/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	w_class = 4.0
	force = 12.0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	shellsmax = 8
	origin_tech = "combat=3"

/obj/item/weapon/gun/energy
	name = "energy"
	var/charges = 10.0
	var/maximum_charges = 10.0
	origin_tech = "combat=2;magnets=2"

/obj/item/weapon/gun/energy/taser_gun
	name = "taser gun"
	icon_state = "taser"
	w_class = 3.0
	item_state = "gun"
	force = 10.0
	throw_speed = 2
	throw_range = 10
	charges = 4
	maximum_charges = 4
	m_amt = 2000
	origin_tech = "combat=2;magnets=2"

/obj/item/weapon/gun/energy/teleport_gun
	name = "teleport gun"
	desc = "A hacked together combination of a taser and a handheld teleportation unit."
	icon_state = "taser"
	w_class = 3.0
	item_state = "gun"
	force = 10.0
	throw_speed = 2
	throw_range = 10
	charges = 4
	maximum_charges = 4
	m_amt = 2000
	var/failchance = 5
	var/obj/item/target = null
	origin_tech = "combat=2;magnets=2;bluespace=3"

/obj/item/weapon/gun/energy/crossbow // Laaazy
	name = "mini energy-crossbow"
	desc = "A weapon favored by many of the syndicates stealth specialists."
	icon_state = "crossbow"
	w_class = 2.0
	item_state = "crossbow"
	force = 4.0
	throw_speed = 2
	throw_range = 10
	charges = 3
	maximum_charges = 3
	m_amt = 2000
	origin_tech = "combat=2;magnets=2;syndicate=2"

/obj/item/weapon/gun/energy/laser_gun
	name = "laser gun"
	icon_state = "laser"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 7.0
	m_amt = 2000
	origin_tech = "combat=3;magnets=2"

/obj/item/weapon/gun/energy/laser_gun/captain
	icon_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	origin_tech = null

/obj/item/weapon/gun/revolver
	desc = "There are 0 bullets left. Uses 357"
	name = "revolver"
	icon_state = "revolver"
	var/bullets = 0.0
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 24.0
	m_amt = 2000
	origin_tech = "combat=3;materials=2"

/obj/item/weapon/gun/revolver/mateba
	desc = "There are 0 bullets left. Uses 357"
	name = "revolver"
	icon_state = "mateba"
	origin_tech = "combat=3;materials=2"

/obj/item/weapon/gun/c96
	desc = "There are 0 rounds left. Uses 7.63x25 Mauser"
	name = "c96"
	icon_state = "c96"
	var/obj/item/weapon/ammo/a763m/magazine
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 12.0
	m_amt = 2000
//	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/p08
	desc = "There are 0 rounds left. Uses 9x19 Parabellum"
	name = "p08"
	icon_state = "p08empty"
	var/obj/item/weapon/ammo/a9x19p/magazine
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 16.0
	m_amt = 2000
//	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/glock
	desc = "There are 0 rounds left. Uses .45 ACP"
	name = "glock"
	icon_state = "glock"
	var/obj/item/weapon/ammo/a45/magazine
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 6.0
	m_amt = 2000
//	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/m1911
	desc = "There are 0 rounds left. Uses .45 ACP"
	name = "m1911"
	icon_state = "m1911"
	var/obj/item/weapon/ammo/a45/magazine
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 14.0
	m_amt = 2000
//	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/carbine
	desc = "There are 0 rounds left. Uses 5.56x45mm NATO"
	name = "carbine"
	icon_state = "carbinenomag"
	var/obj/item/weapon/ammo/assaultmag/magazine
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 6.0
	m_amt = 2000
//	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/ak331
	desc = "There are 0 rounds left. Uses 5.56x45mm NATO"
	name = "ak331"
	icon_state = "ak331nomag"
	var/obj/item/weapon/ammo/assaultmag/magazine
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 18.0
	m_amt = 2000
//	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/detectiverevolver
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = ".38 revolver"
	icon_state = "detective"
	var/bullets = 5.0
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 14.0
	m_amt = 1000
	origin_tech = "combat=2;materials=2"

/obj/item/weapon/hand_tele
	name = "hand tele"
	icon = 'device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 5
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	origin_tech = "magnets=1;bluespace=3"

/obj/item/weapon/handcuffs
	name = "handcuffs"
	icon = 'items.dmi'
	icon_state = "handcuff"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	throwforce = 5
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	m_amt = 500
	origin_tech = "materials=1"


/obj/item/weapon/implant
	name = "implant"
	var/implanted = null
	var/mob/imp_in = null
	var/color = "b"

/obj/item/weapon/implant/freedom
	name = "freedom"
	var/uses = 1.0
	color = "r"
	var/activation_emote = "chuckle"

/obj/item/weapon/implant/tracking
	name = "tracking"
	var/frequency = 1451
	var/id = 1.0

/obj/item/weapon/implant/explosive
	name = "explosive"

/obj/item/weapon/implant/chem
	name = "chem"

/obj/item/weapon/implantcase
	name = "Glass Case"
	icon_state = "implantcase-0"
	var/obj/item/weapon/implant/imp = null
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0

/obj/item/weapon/implantcase/tracking
	name = "Glass Case- 'Tracking'"
	icon = 'items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	icon = 'items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/chem
	name = "Glass Case- 'Chem'"
	icon = 'items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implanter
	name = "implanter"
	icon = 'items.dmi'
	icon_state = "implanter0"
	var/obj/item/weapon/implant/imp = null
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

/obj/item/weapon/implantpad
	name = "implantpad"
	icon = 'items.dmi'
	icon_state = "implantpad-0"
	var/obj/item/weapon/implantcase/case = null
	var/broadcasting = null
	var/listening = 1.0
	item_state = "electronic"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0


/obj/item/weapon/locator
	name = "locator"
	icon = 'device.dmi'
	icon_state = "locator"
	var/temp = null
	var/frequency = 1451
	var/broadcasting = null
	var/listening = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 400
	origin_tech = "magnets=1"



/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'janitor.dmi'
	icon_state = "mop"
	var/mopping = 0
	var/mopcount = 0
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	flags = FPRINT | TABLEPASS

/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS


/obj/item/weapon/paint
	name = "Paint Can"
	icon = 'items.dmi'
	icon_state = "paint_neutral"
	var/color = "neutral"
	item_state = "paintcan"
	w_class = 3.0

/obj/item/weapon/paper
	name = "Paper"
	icon = 'items.dmi'
	icon_state = "paper"
	var/info = null
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	layer = 4
	var/list/stamped
	var/see_face = 1
	var/body_parts_covered = HEAD
	var/protective_temperature = T0C + 10
	var/heat_transfer_coefficient = 0.99
	var/gas_transfer_coefficient = 1
	var/permeability_coefficient = 0.99
	var/siemens_coefficient = 0.80

/obj/item/weapon/directions
	name = "Crumpled Paper"
	icon = 'weapons.dmi'
	icon_state = "crumpled"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	//layer = 4


/obj/item/weapon/paper/Internal
	name = "paper- 'Internal Atmosphere Operating Instructions'"
	info = "Equipment:<BR>\n\t1+ Tank(s) with appropriate atmosphere<BR>\n\t1 Gas Mask w regulator (standard issue)<BR>\n<BR>\nProcedure:<BR>\n\t1. Wear mask<BR>\n\t2. Attach oxygen tank pipe to regulater (automatic))<BR>\n\t3. Set internal!<BR>\n<BR>\nNotes:<BR>\n\tDon't forget to stop internal when tank is low by<BR>\n\tremoving internal!<BR>\n<BR>\n\tDo not use a tank that has a high concentration of toxins.<BR>\n\tThe filters shut down on internal mode!<BR>\n<BR>\n\tWhen exiting a high danger environment it is advised<BR>\n\tthat you exit through a decontamination zone!<BR>\n<BR>\n\tRefill a tank at a oxygen canister by equiping the tank (Double Click)<BR>\n\tthen 'attacking' the canister (Double Click the canister)."

/obj/item/weapon/paper/Court
	name = "paper- 'Judgement'"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/weapon/paper/Map
	name = "paper- 'Station Blueprint'"
	var/map_graphic = 'map.png'
	info = {"<IMG SRC="ss13mapd.png">
<BR>
CQ: Crew Quarters<BR>
L: Lounge<BR>
CH: Chapel<BR>
ENG: Engine Area<BR>
EC: Engine Control<BR>
ES: Engine Storage<BR>
GR: Generator Room<BR>
MB: Medical Bay<BR>
MR: Medical Research<BR>
TR: Toxin Research<BR>
TS: Toxin Storage<BR>
AC: Atmospheric Control<BR>
SEC: Security<BR>
SB: Shuttle Bay
SA: Shuttle Airlock<BR>
S: Storage<BR>
CR: Control Room<BR>
EV: EVA Storage<BR>
AE: Aux. Engine<BR>
P: Podbay<BR>
NA: North Airlock<BR>
SC: Solar Control<BR>
ASC: Aux. Solar Control<BR>
"}

/obj/item/weapon/paper/Toxin
	name = "paper- 'Chemical Information'"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep toxins.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSleep Toxin T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effects are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/weapon/paper/courtroom
	name = "paper- 'A Crash Course in Legal SOP on SS13'"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/weapon/paper/hydroponics
	name = "paper- 'Greetings from Billy Bob'"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effects<BR>\nIn Liberty caps, potency = drug power + effects<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/weapon/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = 1.0

/obj/item/weapon/paper/jobs
	name = "paper- 'Job Information'"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/weapon/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0.0
	item_state = "paper"

/obj/item/weapon/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alrms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/weapon/paper/engine
	name = "paper- 'Generator Startup Procedure'"
	info = {"<B>Thermo-Electric Generator Startup Procedure for Mark I Plasma-Fired Engines</B>
<HR>
<i>Warning!</i> Improper engine and generator operation may cause exposure to hazardous gasses, extremes of heat and cold, and dangerous electrical voltages.<BR>
Only trained personnel should operate station systems. Follow all procedures carefully. Wear correct personal protective equipment at all times.<BR>
Refer to your supervisor or Head of Personnel for procedure updates and additional information.
<HR>
Standard checklist for engine and generator cold-start.<BR>
<ol>
<li>Perform visual inspection of external (cooling) and internal (heating) heat-exchange pipe loops.
Refer any breaks or cracks in the pipe to Station Maintenance for repair before continuing.
<li>Connect a CO<sub>2</sub> canister to the external (cooling) loop connector, and release the contents. Check loop pressurization is stable.<BR>
<i>Note:</i> Observe standard canister safety procedures.<BR>
<i>Note:</i> Other gasses may be substituted as a medium in the external (cooling) loop in the event that CO<sub>2</sub> is not available.
<li>Connect a CO<sub>2</sub> canister to the internal (heating) loop connector, and release the contents. Check loop pressurization is stable.<BR>
<i>Note:</i> Observe standard canister safety procedures.<BR>
<i>Note:</i> Nitrogen may be substituted as a medium in the internal (heating) loop in the event that CO<sub>2</sub> is not available.
<i>Do not use plasma in the internal (heating) pipe loop as an unsafe condition may result.</i>
<li>Using the thermo-electric generator (TEG) master control panel, engage the internal and external loop circulator pumps at 1% maximum rate.<BR>
<li>Ignite the engine. Refer to document NTRSN-113-H9-12939 for proper engine preparation, ignition, and plasma-oxygen loading procedures.<BR>
<i>Note:</i> Exceeding recommended plasma-oxygen concentrations can cause engine damage and potential hazards.
<li>Monitor engine temperatures until stable operation is achieved.
<li>Increase internal and external circulator pumps to 10% of maximum rate. Monitor the generated power output on the TEG control panel.<BR>
<i>Note:</i> Consult appendix A for expected electrical generation rates.
<li>Adjust circulator rates until required electrical demand is met.<BR>
<i>Note:</i> Generation rate varies with internal and external loop temperatures, exchange media pressure, and engine geometry. Refer to Appendix B or your supervisor for locally determined optimal settings.<BR>
<i>Note:</i> Do not exceed safety ratings for station power cabling and electrical equipment.
<li>With the power generation rate stable, engage charging of the superconducting magnetic energy storage (SMES) devices.
Total SMES charging rate should not exceed total power generation rate, or an overload condition may occur.
"}

/obj/item/weapon/paper_bin
	name = "Paper Bin"
	icon = 'items.dmi'
	icon_state = "paper_bin1"
	var/amount = 30.0
	item_state = "sheet-metal"
	throwforce = 1
	w_class = 3.0
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'items.dmi'
	icon_state = "pen"
	flags = FPRINT | ONBELT | TABLEPASS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 10
	var/text_size = 2
	var/text_color = "#000000"
	var/text_bold = 0
	var/text_italic = 0
	var/text_underline = 0
	var/text_break = 0

/obj/item/weapon/banhammer
	desc = "A banhammer"
	name = "Banhammer"
	icon = 'items.dmi'
	icon_state = "toyhammer"
	flags = FPRINT | ONBELT | TABLEPASS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15

/obj/item/weapon/pen/sleepypen
	desc = "It's a normal black ink pen with a sharp point."
	flags = FPRINT | ONBELT | TABLEPASS | OPENCONTAINER
	origin_tech = "materials=2;biotech=1;syndicate=2"

/obj/item/weapon/rack_parts
	name = "rack parts"
	icon = 'items.dmi'
	icon_state = "rack_parts"
	flags = FPRINT | TABLEPASS| CONDUCT
	m_amt = 3750

/obj/item/weapon/rubber_chicken
	name = "Rubber Chicken"
	desc = "A rubber chicken, isn't that hilarious?"
	icon = 'items.dmi'
	icon_state = "rubber_chicken"
	item_state = "rubber_chicken"
	w_class = 2.0

/obj/item/weapon/screwdriver
	name = "screwdriver"
	icon = 'items.dmi'
	icon_state = "screwdriver"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5

/obj/item/weapon/shard
	name = "shard"
	icon = 'shards.dmi'
	icon_state = "large"
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = 3.0
	force = 5.0
	throwforce = 15.0
	item_state = "shard-glass"
	g_amt = 3750

/obj/item/weapon/syndicate_uplink
	name = "station bounced radio"
	icon = 'radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 10.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/origradio = null
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = 2.0
	item_state = "radio"
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	origin_tech = "magnets=2;syndicate=3"

/obj/item/weapon/SWF_uplink
	name = "station bounced radio"
	icon = 'radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 4.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/origradio = null
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	item_state = "radio"
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	origin_tech = "magnets=1"

/obj/item/weapon/spellbook
	name = "Spell Book"
	icon = 'library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	var/uses = 4.0
	var/temp = null

/obj/item/weapon/staff
	name = "wizards staff"
	icon = 'wizard.dmi'
	icon_state = "staff"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD

/obj/item/weapon/sword
	var/color
	name = "energy sword"
	icon_state = "sword0"
	var/active = 0.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD
	origin_tech = "magnets=3;syndicate=3"

/obj/item/weapon/sword/pirate
	name = "energy cutlass"
	icon_state = "cutlass0"

/obj/item/weapon/table_parts
	name = "table parts"
	icon = 'items.dmi'
	icon_state = "table_parts"
	m_amt = 3750
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/weapon/table_parts/reinforced
	name = "table parts"
	icon = 'items.dmi'
	icon_state = "reinf_tableparts"
	m_amt = 7500
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/weapon/tank
	name = "tank"
	icon = 'tank.dmi'

	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	flags = FPRINT | TABLEPASS | CONDUCT | ONBACK

	pressure_resistance = ONE_ATMOSPHERE*5

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	var/volume = 70

/obj/item/weapon/tank/anesthetic
	name = "Gas Tank (Sleeping Agent)"
	icon_state = "anesthetic"

/obj/item/weapon/tank/jetpack
	name = "Jetpack (Oxygen)"
	icon_state = "jetpack0"
	var/on = 0.0
	w_class = 4.0
	item_state = "jetpack"
	var/datum/effects/system/ion_trail_follow/ion_trail
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	//volume = 140 //jetpack sould be larger, but then it will never deplete -rastaf0

/obj/item/weapon/tank/jetpack/voidjetpack
	name = "Void Jetpack (oxygen)"
	icon_state = "voidjetpack0"
//	item_state =  //I want my item state very soon Agouri.

/obj/item/weapon/tank/oxygen
	name = "Gas Tank (Oxygen)"
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD

/obj/item/weapon/tank/air
	name = "Gas Tank (Air Mix)"
	icon_state = "oxygen"

/obj/item/weapon/tank/plasma
	name = "Gas Tank (BIOHAZARD)"
	icon_state = "plasma"

/obj/item/weapon/tank/emergency_oxygen
	name = "emergency oxygentank"
	icon_state = "emergency"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT
	w_class = 2.5
	force = 4.0
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 10 //yeah, SO tiny

/obj/item/weapon/teleportation_scroll
	name = "Teleportation Scroll"
	icon = 'wizard.dmi'
	icon_state = "scroll"
	var/uses = 4.0
	flags = FPRINT | TABLEPASS
	w_class = 2.0
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	origin_tech = "bluespace=4"

/obj/item/weapon/wire
	desc = "This is just a simple piece of regular insulated wire."
	name = "wire"
	icon = 'power.dmi'
	icon_state = "item_wire"
	var/amount = 1.0
	var/laying = 0.0
	var/old_lay = null
	m_amt = 40

/obj/item/weapon/wirecutters
	name = "wirecutters"
	icon = 'items.dmi'
	icon_state = "cutters"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	m_amt = 80
	origin_tech = "materials=1"

/obj/item/weapon/wrapping_paper
	name = "wrapping paper"
	icon = 'items.dmi'
	icon_state = "wrap_paper"
	var/amount = 20.0

/obj/item/weapon/wrench
	name = "wrench"
	icon = 'items.dmi'
	icon_state = "wrench"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 150
	origin_tech = "materials=1"

/obj/item/weapon/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = "powerstorage=1"
	flags = FPRINT|TABLEPASS
	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = 3.0
	pressure_resistance = 80
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	m_amt = 700
	g_amt = 50
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.

/obj/item/weapon/cell/high
	name = "high-capacity power cell"
	origin_tech = "powerstorage=2"
	maxcharge = 10000
	g_amt = 60

/obj/item/weapon/cell/super
	name = "super-capcity power cell"
	origin_tech = "powerstorage=3"
	maxcharge = 20000
	g_amt = 70

/*/obj/item/weapon/cell/potato
	name = "Potato Battery"
	desc = "A rechargable starch based power cell."
	icon = 'harvest.dmi'
	icon_state = "potato_battery"
	maxcharge = 100
	m_amt = 0
	g_amt = 0*/

/obj/item/weapon/camera_bug/attack_self(mob/usr as mob)
	var/list/cameras = new/list()
	for (var/obj/machinery/camera/C in world)
		if (C.bugged && C.status)
			cameras.Add(C)
	if (length(cameras) == 0)
		usr << "\red No bugged functioning cameras found."
		return

	var/list/friendly_cameras = new/list()

	for (var/obj/machinery/camera/C in cameras)
		friendly_cameras.Add(C.c_tag)

	var/target = input("Select the camera to observe", null) as null|anything in friendly_cameras
	if (!target)
		return
	for (var/obj/machinery/camera/C in cameras)
		if (C.c_tag == target)
			target = C
			break
	if (usr.stat == 2) return

	usr.client.eye = target


/obj/item/weapon/module
	icon = 'module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS|CONDUCT
	var/mtype = 1						// 1=electronic 2=hardware

/obj/item/weapon/module/card_reader
	name = "card reader module"
	icon_state = "card_mod"
	desc = "An electronic module for reading data and ID cards."

/obj/item/weapon/module/power_control
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."

/obj/item/weapon/module/id_auth
	name = "ID authentication module"
	icon_state = "id_mod"
	desc = "A module allowing secure authorization of ID cards."

/obj/item/weapon/module/cell_power
	name = "power cell regulator module"
	icon_state = "power_mod"
	desc = "A converter and regulator allowing the use of power cells."

/obj/item/weapon/module/cell_power
	name = "power cell charger module"
	icon_state = "power_mod"
	desc = "Charging circuits for power cells."


/obj/item/weapon/a_gift
	name = "gift"
	icon = 'items.dmi'
	icon_state = "gift"
	item_state = "gift"
	pressure_resistance = 70


/obj/item/weapon/camera_bug
	name = "camera bug"
	icon = 'device.dmi'
	icon_state = "flash"
	w_class = 1.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20


/obj/item/weapon/kitchen
	icon = 'kitchen.dmi'

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = 3.0

/obj/item/weapon/kitchenknife
	name = "Kitchen knife"
	icon = 'kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 10.0
	w_class = 3.0
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"

/obj/item/weapon/tray
	name = "Tray"
	icon = 'food.dmi'
	icon_state = "tray"
	desc = "A plastic tray to lay food on."
	throwforce = 12.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS | CONDUCT
	m_amt = 3000
	var/food_total= 0
	var/burger_amt = 0
	var/cheese_amt = 0
	var/fries_amt = 0
	var/classyalcdrink_amt = 0
	var/alcdrink_amt = 0
	var/bottle_amt = 0
	var/soda_amt = 0
	var/carton_amt = 0
	var/pie_amt = 0
	var/meatbreadslice_amt = 0
	var/salad_amt = 0
	var/miscfood_amt = 0


/obj/item/weapon/kitchen/utensil
	force = 5.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=1"


/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	icon_state = "fork"

/obj/item/weapon/kitchen/utensil/knife
	name = "knife"
	icon_state = "knife"
	force = 10.0
	throwforce = 10.0

/obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "SPOON!"
	icon_state = "spoon"

/obj/item/weapon/scalpel
	name = "scalpel"
	icon = 'surgery.dmi'
	icon_state = "scalpel"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 10.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/retractor
	name = "retractor"
	icon = 'surgery.dmi'
	icon_state = "retractor"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/hemostat
	name = "hemostat"
	icon = 'surgery.dmi'
	icon_state = "hemostat"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/cautery
	name = "cautery"
	icon = 'surgery.dmi'
	icon_state = "cautery"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	icon = 'surgery.dmi'
	icon_state = "drill"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/circular_saw
	name = "circular saw"
	icon = 'surgery.dmi'
	icon_state = "saw"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 15.0
	w_class = 1.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	m_amt = 20000
	g_amt = 10000
	origin_tech = "materials=1;biotech=1"

/obj/item/weapon/stamp
	desc = "A rubber stamp for stamping important documents."
	name = "rubber stamp"
	icon = 'items.dmi'
	icon_state = "stamp-qm"
	item_state = "stamp"
	flags = FPRINT | TABLEPASS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 60

/obj/item/weapon/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"

/obj/item/weapon/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"

/obj/item/weapon/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"

/obj/item/weapon/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"

/obj/item/weapon/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"

/obj/item/weapon/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"

/obj/item/weapon/stamp/denied
	name = "DENIED rubber stamp"
	icon_state = "stamp-qm"

/obj/item/weapon/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"

/obj/item/weapon/cigpacket
	name = "Cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = 1
	throwforce = 2
	var/cigcount = 6
	flags = ONBELT | TABLEPASS

/*
/obj/item/weapon/cigarpacket
	name = "Pete's Cuban Cigars"
	desc = "The most robust cigars on the planet."
	icon = 'cigarettes.dmi'
	icon_state = "cigarpacket"
	item_state = "cigarpacket"
	w_class = 1
	throwforce = 2
	var/cigarcount = 6
	flags = ONBELT | TABLEPASS */

/obj/item/weapon/cigbutt
	name = "Cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'cigarettes.dmi'
	icon_state = "cigbutt"
	w_class = 1
	throwforce = 1

/obj/item/weapon/cigarbutt
	name = "Cigar butt"
	desc = "A manky old cigar butt."
	icon = 'cigarettes.dmi'
	icon_state = "cigarbutt"
	w_class = 1
	throwforce = 1

/obj/item/weapon/zippo
	name = "Zippo lighter"
	desc = "The detective's zippo."
	icon = 'items.dmi'
	icon_state = "zippo"
	item_state = "zippo"
	w_class = 1
	throwforce = 4
	var/lit = 0
	flags = ONBELT | TABLEPASS | CONDUCT


/obj/item/weapon/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon = 'weapons.dmi'
	icon_state = "mousetrap"
	item_state = "mousetrap"
	w_class = 1
	force = null
	throwforce = null
	var/armed = 0
	origin_tech = "combat=1"

/obj/item/weapon/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = 1

/obj/item/weapon/dice // -- TLE
	name = "d6"
	var/sides = 6
	icon_state = "dice"
	item_state = "dice"

/obj/item/weapon/dice/d20 // -- TLE
	name = "d20"
	sides = 20
	icon_state = "d20"
	item_state = "dice"

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'weapons.dmi'
	var/seed = ""
	var/plantname = ""
	var/productname = ""
	var/species = ""
	var/lifespan = 20
	var/endurance = 15
	var/maturation = 7
	var/production = 7
	var/yield = 2
	var/potency = -1
	var/plant_type = 0
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src


/obj/item/weapon/grown/nettle // -- Skie
	desc = "This is a nettle. It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'weapons.dmi'
	name = "Nettle"
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	flags = TABLEPASS
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	origin_tech = "combat=1"
	seed = "/obj/item/seeds/nettleseed"
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("acid", round(potency, 1))

/obj/item/weapon/grown/deathnettle // -- Skie
	desc = "The \red glowing \black nettle incites \red<B>rage</B>\black in you just from looking at it!"
	icon = 'weapons.dmi'
	name = "Deathnettle"
	icon_state = "deathnettle"
	damtype = "fire"
	force = 30
	flags = TABLEPASS
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed = "/obj/item/seeds/deathnettleseed"
	origin_tech = "combat=3"
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("pacid", round(potency, 1))

/obj/item/weapon/plantbgone // -- Skie
	desc = "Plant-B-Gone! Kill those pesky weeds!"
	icon = 'hydroponics.dmi'
	name = "Plant-B-Gone"
	icon_state = "plantbgone"
	item_state = "plantbgone"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/empty = 0

/*			Commented out due to being redundant. - Darem
/obj/item/weapon/weedspray // -- Skie
	desc = "Toxic mixture in spray form to kill small weeds."
	icon = 'hydroponics.dmi'
	name = "Weed Spray"
	icon_state = "weedspray"
	item_state = "spray"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 4
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/WeedKillStr = 2
*/
/obj/item/weapon/pestspray // -- Skie
	desc = "Pest eliminator spray! Do not inhale!"
	icon = 'hydroponics.dmi'
	name = "Pest Spray"
	icon_state = "pestspray"
	item_state = "spray"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 4
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/PestKillStr = 2

/obj/item/weapon/minihoe // -- Numbers
	name = "Mini hoe"
	desc = "Use for removing weeds or scratching your back."
	icon = 'weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = FPRINT | TABLEPASS | CONDUCT | USEDELAY
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 50

/obj/item/weapon/plastique
	name = "Plastic Explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	icon = 'assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = FPRINT | TABLEPASS | USEDELAY
	w_class = 2.0
	var/timer = 10
	var/atom/target = null

///////////////////////////////////////Stock Parts /////////////////////////////////

/obj/item/weapon/stock_parts
	name = "stock part"
	desc = "What?"
	icon = 'stock_parts.dmi'
	var/rating = 1
	New()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

//Rank 1

/obj/item/weapon/stock_parts/console_screen
	name = "Console Screen"
	desc = "Used in the construction of computers and other devices with a interactive console."
	icon_state = "screen"
	origin_tech = "materials=1"
	g_amt = 200

/obj/item/weapon/stock_parts/capacitor
	name = "Capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor"
	origin_tech = "powerstorage=1"
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module
	name = "Scanning Module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=1"
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator
	name = "Micro-Manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=1;programming=1"
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser
	name = "Micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=1"
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin
	name = "Matter Bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=1"
	m_amt = 80

//Rank 2

/obj/item/weapon/stock_parts/capacitor/adv
	name = "Advanced Capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	origin_tech = "powerstorage=3"
	rating = 2
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/adv
	name = "Advanced Scanning Module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/nano
	name = "Nano-Manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=3,programming=2"
	rating = 2
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/high
	name = "High-Power Micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/adv
	name = "Advanced Matter Bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=3"
	rating = 2
	m_amt = 80

//Rating 3

/obj/item/weapon/stock_parts/capacitor/super
	name = "Super Capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	origin_tech = "powerstorage=5;materials=4"
	rating = 3
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/phasic
	name = "Phasic Scanning Module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/pico
	name = "Pico-Manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	origin_tech = "materials=5,programming=2"
	rating = 3
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/ultra
	name = "Ultra-High-Power Micro-laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/super
	name = "Super Matter Bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	origin_tech = "materials=5"
	rating = 3
	m_amt = 80