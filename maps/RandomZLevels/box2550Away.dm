//box2550Away areas

/area/awaymission/box2550Away
	name = "TG424"
	icon_state = "away"
	requires_power = 0

/area/awaymission/box2550Away/general
	name = "TG424"

/area/awaymission/box2550Away/maint
	name = "TG424 Maintenance"
	icon_state = "away"

/area/awaymission/box2550Away/solar
	name = "TG424 Solars"
	icon_state = "away"

/area/awaymission/box2550Away/storage
	name = "TG424 Storage"
	icon_state = "away4"

/area/awaymission/box2550Away/security
	name = "TG424 Security"
	icon_state = "away3"
/area/awaymission/box2550Away/medical
	name = "TG424 Medical"
	icon_state = "away1"

/area/awaymission/box2550Away/engineering
	name = "TG424 Engineering"
	icon_state = "away"

/area/awaymission/box2550Away/research
	name = "TG424 Research"
	icon_state = "away2"

/area/awaymission/box2550Away/command
	name = "TG424 Command"
	icon_state = "away3"

/area/awaymission/box2550Away/supply
	name = "TG424 Supply"
	icon_state = "away4"

/area/shuttle/awaymission/box2550Away/prison
	name = "\improper Prison Station Shuttle"

/area/shuttle/awaymission/box2550Away/prison/station
	icon_state = "shuttle"
	destination = /area/shuttle/awaymission/box2550Away/prison/prison

/area/shuttle/awaymission/box2550Away/prison/prison
	icon_state = "shuttle"
	destination = /area/shuttle/awaymission/box2550Away/prison/station

//box2550Away items

/obj/item/clothing/suit/armor/centcom/box2550away
	name = "\improper Captain's armour"
	desc = null

/obj/item/clothing/head/caphat/box2550away
	name = "\improper Captain's hat"
	icon_state = "centcom"
	desc = null
	item_state = "centcom"

/obj/item/clothing/under/gimmick/rank/captain/suit/box2550away
	name = "\improper Captain Jumpsuit"//how does I proper noun

/obj/item/clothing/under/rank/chemist/box2550away/scientist //they wore orange
	name = "\improper Scientist's Jumpsuit"
	desc = "Made of a special fiber that gives special protection against biohazards. Has a toxins rank stripe on it."

/obj/item/clothing/under/rank/medical/box2550/cmo
	name = "\improper Medical Doctor's Jumpsuit" //no CMO jumpsuit back then
	desc = "Made of a special fiber that gives special protection against biohazards. Has a medical rank stripe on it."

/obj/item/clothing/under/rank/head_of_security/box2550
	desc = "It has a Head of Security rank stripe on it."
	name = "\improper Head of Security Jumpsuit"

/obj/item/clothing/suit/labcoat/cmo/box2550
	icon_state = "labcoat_cmo" //buttoned up
	item_state = "labcoat_cmo"

/obj/item/device/radio/headset/heads/box2550/heads/
	name = "\improper Command Radio Headset"
	desc = null
	icon_state = "cent_headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_com

/obj/item/device/radio/headset/heads/box2550/heads/cmo
	name = "\improper Command Radio Headset"
	desc = null
	icon_state = "cent_headset"
	keyslot2 = new /obj/item/device/encryptionkey/heads/cmo

/obj/item/device/radio/headset/box2550away
	name = "\improper Radio Headset"
	desc = null

/obj/item/clothing/glasses/sunglasses/box2550away
	name = "\improper Sunglasses"

/obj/item/clothing/mask/breath/box2550away/
	name = "\improper Breath Mask"
	desc = "A close-fitting mask that can be connected to an air supply but does not work very well in hard vacuum."

/obj/item/clothing/mask/gas/box2550away/
	desc = "A close-fitting mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "gas_mask" //old and ugly looking <3
	item_state = "gas_mask"

/obj/item/clothing/mask/gas/box2550away/emergency
	name = "emergency gas mask"

/obj/item/weapon/tank/emergency_oxygen/box2550away/
	name = "emergency oxygentank"
	desc = null

/obj/item/weapon/card/id/box2550away
	desc = null

/obj/item/weapon/storage/box/box2550away/internals
	name = "\improper Box"
	desc = null
	New()
		..()
		new /obj/item/clothing/mask/breath/box2550away/(src)
		new /obj/item/weapon/tank/emergency_oxygen/box2550away/(src)

/obj/structure/closet/secure_closet/box2550away/scientist //so the items in the locker match what the scientist is wearing
	name = "Scientist's Locker"
	req_access = list(access_tox_storage)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/chemist/box2550away/scientist(src)
		new /obj/item/clothing/suit/labcoat(src)
		new /obj/item/clothing/shoes/white/box2550away(src)
		new /obj/item/device/radio/headset/box2550away(src)
		new /obj/item/weapon/tank/air(src)
		new /obj/item/clothing/mask/gas/box2550away/(src)
		return

/obj/structure/closet/secure_closet/box2550away/captains
	name = "Captain's Locker"
	req_access = list(access_captain)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"

	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/box/box2550away/ids(src)
		new /obj/item/clothing/under/gimmick/rank/captain/suit/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/glasses/sunglasses/box2550away(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/helmet/swat(src)
		return

/obj/structure/closet/box2550away/toxins_white
	name = "Toxins Wardrobe"
	desc = "A bulky (yet mobile) wardrobe closet. Comes prestocked with 6 changes of clothes."
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/box2550away/toxins_white/New()
	new /obj/item/clothing/under/rank/chemist/box2550away/scientist(src)
	new /obj/item/clothing/under/rank/chemist/box2550away/scientist(src)
	new /obj/item/clothing/under/rank/chemist/box2550away/scientist(src)
	new /obj/item/clothing/suit/labcoat(src)
	new /obj/item/clothing/suit/labcoat(src)
	new /obj/item/clothing/suit/labcoat(src)
	new /obj/item/clothing/shoes/white/box2550away(src)
	new /obj/item/clothing/shoes/white/box2550away(src)
	new /obj/item/clothing/shoes/white/box2550away(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/badrecipe/box2550away/rottenfood
	name = "rotten mess"
	desc = "Yum."

/obj/structure/closet/box2550away/lawcloset
	name = "\improper Legal Closet"
	desc = "A bulky (yet mobile) closet. Comes with lawyer apparel and items."

/obj/structure/closet/box2550away/lawcloset/New()
	new /obj/item/clothing/under/lawyer/black(src)
	new /obj/item/clothing/under/lawyer/red(src)
	new /obj/item/clothing/under/lawyer/blue(src)
	new /obj/item/clothing/shoes/brown/box2550away(src)
	new /obj/item/clothing/shoes/brown/box2550away(src)
	new /obj/item/clothing/shoes/black/box2550away(src)
	new /obj/item/weapon/storage/briefcase/box2550away(src)
	new /obj/item/weapon/storage/briefcase/box2550away(src)

/obj/item/weapon/storage/briefcase/box2550away
	desc = null

/obj/item/weapon/storage/box/box2550away/ids
	name = "\improper Spare IDs"
	desc = null
	icon_state = "id"

	New()
		..()
		new /obj/item/weapon/card/id/box2550away(src)
		new /obj/item/weapon/card/id/box2550away(src)
		new /obj/item/weapon/card/id/box2550away(src)
		new /obj/item/weapon/card/id/box2550away(src)
		new /obj/item/weapon/card/id/box2550away(src)
		new /obj/item/weapon/card/id/box2550away(src)
		new /obj/item/weapon/card/id/box2550away(src)

/obj/item/device/transfer_valve/box2550away
	name = "\improper Tank transfer valve"

/obj/item/device/detective_scanner/box2550away
	desc = "Used to scan objects for DNA and fingerprints"
	name = "\improper Scanner"

/obj/item/weapon/storage/backpack/box2550away/captain
	desc = null
	New()
		..()
		new /obj/item/weapon/storage/box/box2550away/ids(src)

/obj/item/weapon/storage/backpack/box2550away/
	desc = null
	New()
		..()
		new /obj/item/weapon/storage/box/box2550away/internals(src)

/obj/item/weapon/bikehorn/box2550
	name = "\improper Bike Horn"

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/box2550away
	name = "\improper Banana"
	desc = "A banana."

/obj/item/weapon/storage/backpack/box2550away/clown
	desc = null
	New()
		..()
		new /obj/item/weapon/bikehorn/box2550(src)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/banana/box2550away(src)

/obj/item/weapon/storage/backpack/box2550away/scientist
	desc = null
	New()
		..()
		new /obj/item/device/transfer_valve/box2550away(src)

/obj/item/weapon/storage/backpack/box2550away/lawyer
	desc = null
	New()
		..()
		new /obj/item/device/detective_scanner/box2550away(src)

/obj/item/weapon/storage/backpack/box2550away/hos
	desc = null
	New()
		..()
		new /obj/item/weapon/handcuffs/box2550away(src)
		new /obj/item/weapon/melee/baton/loaded/box2550(src)

/obj/item/weapon/storage/backpack/box2550away/sec
	desc = null
	New()
		..()
		new /obj/item/weapon/handcuffs/box2550away(src)
		new /obj/item/weapon/handcuffs/box2550away(src)
		new /obj/item/weapon/melee/baton/loaded/box2550(src)

/obj/item/clothing/under/color/red/box2550away
	desc = null
	name = "\improper Red Jumpsuit"

/obj/item/weapon/handcuffs/box2550away
	desc = null

/obj/item/device/flash/box2550away
	desc = null

/obj/item/clothing/shoes/brown/box2550away
	name = "\improper Brown Shoes"
	desc = null

/obj/item/clothing/shoes/white/box2550away
	name = "\improper White Shoes"
	desc = null

/obj/item/clothing/shoes/black/box2550away
	name = "\improper Black Shoes"
	desc = null

/obj/item/device/pda/captain/box2550away
	name = "PDA-Jon Riker"
	owner = "Jon Riker"
	ownjob = "Captain"
	toff = 1 //so players don't see the PDA on their messenger until it's found
	ttone = "hiss" //did he play a lizard in 2010 who knows
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

/obj/item/device/pda/toxins/box2550away
	name = "PDA-Cuban Pete"
	owner = "Cuban Pete"
	ownjob = "Scientist"
	toff = 1
	ttone = "maracas"
	icon_state = "pda-chemistry"
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

/obj/item/device/pda/box2550away/lawyer
	name = "PDA-Bendak Starkiller"
	owner = "Bendak Starkiller"
	ownjob = "Lawyer"
	toff = 1
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

/obj/item/device/pda/box2550away/cmo
	default_cartridge = /obj/item/weapon/cartridge/medical
	name = "PDA-Amy Lessen"
	owner = "Amy Lessen"
	ownjob = "Chief Medical Officer"
	toff = 1
	icon_state = "pda-chef"
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

/obj/item/device/pda/box2550away/hos
	name = "PDA-Broba Fett"
	owner = "Broba Fett"
	ownjob = "Head of Security"
	toff = 1
	icon_state = "pda" //the actual sprite was a lighter shade of green and has since been deleted but no one cares
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

/obj/item/device/pda/box2550away/hop
	name = "PDA-Rebecca Sharpe"
	owner = "Rebecca Sharpe"
	ownjob = "Head of Personnel"
	toff = 1
	icon_state = "pda"
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

/obj/item/device/pda/security/box2550away
	name = "PDA-Hossan Mubarak"
	owner = "Hossan Mubarak"
	ownjob = "Security Officer"
	toff = 1
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

/obj/item/clothing/head/helmet/HoS/box2550away
	name = "\improper HoS Helmet"
	desc = null

/obj/item/device/radio/headset/headset_sec/box2550away
	name = "\improper Security Radio Headset"
	desc = null

/obj/effect/landmark/corpse/away/box2550/captain
	name = "Jon Riker"
	corpseuniform = /obj/item/clothing/under/gimmick/rank/captain/suit/box2550away
	corpsesuit = /obj/item/clothing/suit/armor/centcom/box2550away
	corpseshoes = /obj/item/clothing/shoes/brown/box2550away
	corpseradio = null //same person who took his id took this
	corpsehelmet = /obj/item/clothing/head/caphat/box2550away
	corpseback = /obj/item/weapon/storage/backpack/box2550away/captain
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/captain/box2550away
	corpseglasses = /obj/item/clothing/glasses/sunglasses/box2550away
	corpsehusk = "very yes"
	corpsebrute = 40
	corpseoxy = 120

/obj/effect/landmark/corpse/away/box2550/scientist
	name = "Cuban Pete"//:D
	corpseuniform = /obj/item/clothing/under/rank/chemist/box2550away/scientist
	corpseshoes = /obj/item/clothing/shoes/white/box2550away
	corpseradio = /obj/item/device/radio/headset/box2550away
	corpsemask = /obj/item/clothing/mask/gas/box2550away/
	corpseback = /obj/item/weapon/storage/backpack/box2550away/scientist
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/toxins/box2550away
	corpseid = 1
	corpseidjob = "Scientist"
	corpseidaccess = "Scientist"
	corpsehusk = "chicky boom"
	corpsebrute = 40
	corpseoxy = 120

obj/effect/landmark/corpse/away/box2550/lawyer
	name = "Bendak Starkiller"//u hungry? xD
	corpseuniform = /obj/item/clothing/under/lawyer/blue
	corpseshoes = /obj/item/clothing/shoes/black/box2550away
	corpseradio = /obj/item/device/radio/headset/box2550away
	corpseback = /obj/item/weapon/storage/backpack/box2550away/lawyer
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/box2550away/lawyer
	corpseid = 1
	corpseidjob = "Lawyer"
	corpseidaccess = "Lawyer"
	corpsehusk = "honk"
	corpsebrute = 40
	corpseoxy = 120

obj/effect/landmark/corpse/away/box2550/cmo
	name = "Amy Lessen"
	mobgender = "female"
	corpseuniform = /obj/item/clothing/under/rank/medical/box2550/cmo
	corpsesuit = /obj/item/clothing/suit/labcoat/cmo/box2550
	corpseshoes = /obj/item/clothing/shoes/brown/box2550away
	corpseradio = /obj/item/device/radio/headset/heads/box2550/heads/cmo
	corpseback = /obj/item/weapon/storage/backpack/box2550away/
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/box2550away/cmo
	corpsehusk = "~~~"
	corpsebrute = 40
	corpseoxy = 120

obj/effect/landmark/corpse/away/box2550/hos
	name = "Broba Fett"
	corpseuniform = /obj/item/clothing/under/rank/head_of_security/box2550
	corpsesuit = /obj/item/clothing/suit/armor/hos //exactly the same now as it was in 2010
	corpseshoes = /obj/item/clothing/shoes/brown/box2550away
	corpseradio = /obj/item/device/radio/headset/headset_sec/box2550away
	corpsehelmet = /obj/item/clothing/head/helmet/HoS/box2550away
	corpsemask = /obj/item/clothing/mask/gas/box2550away/emergency
	corpseglasses = /obj/item/clothing/glasses/sunglasses/box2550away
	corpseback = /obj/item/weapon/storage/backpack/box2550away/hos
	corpsepocket1 = /obj/item/device/flash/box2550away
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/box2550away/hos
	corpsehusk = "i'm out of ideas"
	corpsebrute = 40
	corpseoxy = 120

/obj/item/clothing/under/rank/centcom_officer/box2550/hop
	desc = "It has a Head of Personnel rank stripe on it."
	name = "\improper Head of Personnel Jumpsuit"

/obj/item/clothing/head/helmet/box2550away
	desc = null

obj/effect/landmark/corpse/away/box2550/hop
	name = "Rebecca Sharpe"
	mobgender = "female"
	corpseuniform = /obj/item/clothing/under/rank/centcom_officer/box2550/hop
	corpsesuit = /obj/item/clothing/suit/armor/vest //exactly the same now as it was in 2010
	corpseshoes = /obj/item/clothing/shoes/brown/box2550away
	corpseradio = /obj/item/device/radio/headset/heads/box2550/heads/
	corpsehelmet = /obj/item/clothing/head/helmet/box2550away
	corpseglasses = /obj/item/clothing/glasses/sunglasses/box2550away
	corpseback = /obj/item/weapon/storage/backpack/box2550away/captain
	corpsepocket1 = /obj/item/device/flash/box2550away
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/box2550away/hop
	corpsehusk = 1
	corpsebrute = 40
	corpseoxy = 120

/obj/item/clothing/mask/gas/clown_hat/box2550/clown
	desc = "You're gay for even considering wearing this." //check your privilege, coder scum

/obj/item/clothing/shoes/clown_shoes/box2550/clown_shoes
	desc = "Damn, thems some big shoes."

/obj/item/clothing/under/rank/clown/box2550/clown
	desc = "Wearing this, all the children love you, for all the wrong reasons."

/obj/item/device/pda/clown/box2550away/clown
	name = "PDA-Robert Robust"
	owner = "Robert Robust"
	ownjob = "Clown"
	toff = 1
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

obj/effect/landmark/corpse/away/box2550/clown
	name = "Robert Robust"
	corpseuniform = /obj/item/clothing/under/rank/clown/box2550/clown
	corpseshoes = /obj/item/clothing/shoes/clown_shoes/box2550/clown_shoes
	corpseradio = /obj/item/device/radio/headset/box2550away
	corpsemask = /obj/item/clothing/mask/gas/clown_hat/box2550/clown
	corpsepocket2 = /obj/item/weapon/pen
	corpseback = /obj/item/weapon/storage/backpack/box2550away/clown
	corpsebelt = /obj/item/device/pda/clown/box2550away/clown
	corpseid = 1
	corpseidjob = "Clown"
	corpseidaccess = "Clown"
	corpsehusk = 1
	corpsebrute = 40
	corpseoxy = 120

/obj/item/weapon/melee/baton/loaded/box2550
    name = "\improper Stun Baton"
    desc = "Holy shit. This thing is terrible."
    icon = 'box2550Away.dmi'

/obj/item/weapon/melee/baton/loaded/box2550/New()
    ..()
    src.bcell.maxcharge = 1001
    src.bcell.charge = 1001
    src.bcell.name = "\improper Nanotrasen brand rechargable AA battery"
    src.bcell.desc = "You can't top the plasma top."
    src.bcell.icon_state = "cell"
    update_icon()
    return

obj/effect/landmark/corpse/away/box2550/sec
	name = "Hossan Mubarak"
	corpseuniform = /obj/item/clothing/under/color/red/box2550away
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/brown/box2550away
	corpseradio = /obj/item/device/radio/headset/headset_sec/box2550away
	corpsehelmet = /obj/item/clothing/head/helmet/box2550away
	corpseglasses = /obj/item/clothing/glasses/sunglasses/box2550away
	corpseback = /obj/item/weapon/storage/backpack/box2550away/sec
	corpsepocket1 = /obj/item/device/flash/box2550away
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/security/box2550away
	corpsehusk = 1
	corpsebrute = 40
	corpseoxy = 120

/obj/item/clothing/under/rank/janitor/box2550
	name = "Janitor's Jumpsuit"
	desc = "Official clothing of the station's poopscooper."

/obj/item/device/pda/janitor/box2550
	name = "\improper PDA-Jackson Bob"
	owner = "Jackson Bob"
	ownjob = "Janitor"
	toff = 1
	note = "Congratulations, your station has chosen the Thinktronic 5100 Personal Data Assistant!"

/obj/item/device/pda/security/box2550away/det
	name = "\improper PDA-Corbin Riker"
	owner = "Corbin Riker"
	ownjob = "Detective"
	toff = 1

/obj/item/weapon/storage/box/lights/mixed/box2550away/
	desc = null

/obj/item/weapon/reagent_containers/spray/cleaner/box2550away/
    desc = "Space Cleaner!"
    volume = 1000
    w_class = 3

/obj/item/weapon/reagent_containers/spray/cleaner/box2550away/New()
	..()
	reagents.add_reagent("cleaner", rand(0, 100) * 10) //cleaner sprayed only 10 units

/obj/item/weapon/storage/backpack/box2550away/jan/New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/cleaner(src)
		new /obj/item/weapon/grenade/chem_grenade/cleaner(src)
		new /obj/item/weapon/storage/box/lights/box2550away/lights/(src)
		new /obj/item/weapon/reagent_containers/spray/cleaner/box2550away(src)
		new /obj/item/weapon/mop(src)

obj/effect/landmark/corpse/away/box2550/jan
	name = "Jackson Bob"
	corpseuniform = /obj/item/clothing/under/rank/janitor/box2550
	corpseshoes = /obj/item/clothing/shoes/galoshes
	corpseradio = /obj/item/device/radio/headset/box2550away
	corpseback = /obj/item/weapon/storage/backpack/box2550away/jan
	corpsepocket1 = /obj/item/device/flashlight
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/janitor/box2550
	corpsehusk = 1
	corpsebrute = 40
	corpseoxy = 120

/obj/item/weapon/storage/box/lights/box2550away/lights/
	name = "box of replacement lights"
	icon_state = "lightmixed"
	desc = null

/obj/item/weapon/storage/box/lights/box2550away/lights/New()
	..()
	for(var/i = 0; i < 4; i++)
		new /obj/item/weapon/light/tube(src)
	for(var/i = 0; i < 4; i++)
		new /obj/item/weapon/light/bulb(src)

obj/effect/landmark/corpse/away/box2550/jan
	name = "Jackson Bob"
	corpseuniform = /obj/item/clothing/under/rank/janitor/box2550
	corpseshoes = /obj/item/clothing/shoes/galoshes
	corpseradio = /obj/item/device/radio/headset/box2550away
	corpseback = /obj/item/weapon/storage/backpack/box2550away/jan
	corpsepocket1 = /obj/item/device/flashlight
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/janitor/box2550
	corpsehusk = 1
	corpsebrute = 40
	corpseoxy = 120

/obj/item/clothing/gloves/black/box2550away
	name = "Black Gloves"

/obj/item/clothing/suit/det_suit/box2550away
	desc = "Someone who wears this means business"

/obj/item/clothing/head/det_hat/box2550away
	desc = "Someone who wears this will look very smart"

/obj/item/weapon/lighter/zippo/box2550away
	desc = "The detective's zippo."

/obj/item/clothing/under/det/box2550away
	name = "Hard worn suit"
	desc = "Someone who wears this means business"

obj/effect/landmark/corpse/away/box2550/det
	name = "Corbin Riker"
	corpseuniform = /obj/item/clothing/under/det/box2550away
	corpsehelmet = /obj/item/clothing/head/det_hat/box2550away
	corpsesuit = /obj/item/clothing/suit/det_suit/box2550away
	corpseshoes = /obj/item/clothing/shoes/black/box2550away
	corpseradio = /obj/item/device/radio/headset/headset_sec/box2550away
	corpseback = /obj/item/weapon/storage/backpack/box2550away/lawyer
	corpsepocket1 = /obj/item/weapon/lighter/zippo/box2550away
	corpsepocket2 = /obj/item/weapon/pen
	corpsebelt = /obj/item/device/pda/security/box2550away/det
	corpsegloves = /obj/item/clothing/gloves/black/box2550away
	corpsehusk = 1
	corpsebrute = 40
	corpseoxy = 120

/obj/item/clothing/under/rank/engineer/box2550away
	desc = "It has an Engineering rank stripe on it."
	name = "Engineering Jumpsuit"

/obj/item/weapon/storage/toolbox/mechanical/box2550away
	desc = null

/obj/structure/closet/secure_closet/box2550away/engineering_personal
	name = "Engineer's Locker"
	req_access = list(access_engine_equip)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/toolbox/mechanical/box2550away(src)
		new /obj/item/clothing/under/rank/engineer/box2550away(src)
		new /obj/item/clothing/shoes/orange(src)
		new /obj/item/clothing/mask/gas/box2550away/(src)
		new /obj/item/clothing/head/hardhat(src)
		new /obj/item/clothing/ears/earmuffs(src)
		new /obj/item/clothing/glasses/meson(src)
		return

/obj/structure/closet/secure_closet/box2550away/security
	name = "Security Equipment"
	req_access = list(access_security)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"

	New()
		..()
		sleep(2)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/handcuffs/box2550away(src)
//		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/device/flash/box2550away(src)
		new /obj/item/clothing/under/color/red/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/helmet/box2550away(src)
		new /obj/item/clothing/glasses/sunglasses/box2550away(src)
		new /obj/item/weapon/melee/baton/loaded/box2550(src)
		return

/obj/structure/closet/secure_closet/box2550away/hos
	name = "Head Of Security" //in 2010, the head of security was played by a secure locker
	req_access = list(access_hos)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"

	New()
		..()
		sleep(2)
		new /obj/item/weapon/shield/riot(src)
//		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/device/flash/box2550away(src)
		new /obj/item/weapon/storage/box/box2550away/ids(src)
		new /obj/item/clothing/under/rank/head_of_security/box2550(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/glasses/sunglasses/box2550away(src)
		new /obj/item/clothing/suit/armor/hos(src)
		new /obj/item/clothing/head/helmet/box2550away(src)
		new /obj/item/weapon/storage/box/box2550away/ids(src)
//		new /obj/item/weapon/storage/box/flashbangs(src)
		new /obj/item/weapon/handcuffs/box2550away(src)
		new /obj/item/weapon/melee/baton/loaded/box2550(src)
		return


/obj/structure/closet/secure_closet/box2550away/meat
	name = "Meat Locker"
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"


	New()
		..()
		sleep(2)
		for(var/i = 0, i < 4, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/badrecipe/box2550away/rottenfood(src)
		return

/obj/structure/closet/secure_closet/box2550away/engineering_electrical
	name = "Electrical Supplies"
	req_access = list(access_engine)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/weapon/storage/toolbox/electrical(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/multitool(src)
		return

/obj/structure/closet/secure_closet/box2550away/engineering_welding
	name = "Welding Supplies"
	req_access = list(access_engine)
	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_opened = "secureopen"
	icon_broken = "securebroken"
	icon_off = "secureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/head/welding(src)
		new /obj/item/clothing/head/welding(src)
		new /obj/item/clothing/head/welding(src)
		new /obj/item/weapon/weldingtool(src)
		new /obj/item/weapon/weldingtool(src)
		new /obj/item/weapon/weldingtool(src)
		return

/obj/item/weapon/paper/pamphlet/box2550awayInfo
	name = "Visitor Info Pamphlet"
	info = "<b> TG424 Visitor Information </b><br>\
	Welcome, employee, to  TG424! As you may know, this station was once \
	used as Nanotrasen's SPACE STATION 13, primarily to research plasma \
	and its many entertaining uses. <br>\
	Since the finish of the improved TG570 on Dec 8, 2550, TG424 is no longer \
	a plasma research station and has fallen into disuse.<br> \
	Perhaps you stand to gain something from visiting it?<br> \
	Either way, we hope you enjoy yourself!"

/obj/structure/closet/secure_closet/box2550away/ce
	name = "Chief Engineer's Locker"
	req_access = list(access_heads)

	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/clothing/under/rank/chief_engineer(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/ears/earmuffs(src)
		new /obj/item/clothing/glasses/meson(src)
		new /obj/item/clothing/suit/fire(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/head/welding(src)
		new /obj/item/clothing/head/hardhat(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/flash(src)

/obj/structure/closet/secure_closet/box2550away/hop
	name = "Head of Personnel"
	req_access = list(access_heads)

	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/box/box2550away/ids(src)
		new /obj/item/clothing/under/rank/centcom_officer/box2550/hop(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/helmet(src)

/obj/structure/closet/secure_closet/box2550away/det
	name = "Forensics Locker"
	req_access = list(access_forensics_lockers)

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/det/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/head/det_hat/box2550away(src)
		new /obj/item/clothing/suit/det_suit/box2550away(src)
		new /obj/item/clothing/gloves/black/box2550away(src)
		new /obj/item/weapon/storage/box/gloves(src)
		new /obj/item/device/detective_scanner/box2550away(src)
		new /obj/item/device/detective_scanner/box2550away(src)
		new /obj/item/device/detective_scanner/box2550away(src)

/obj/structure/closet/box2550away/red
	name = "\improper Red Wardrobe"
	icon_state = "red"
	icon_closed = "red"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/color/red/box2550away(src)
		new /obj/item/clothing/under/color/red/box2550away(src)
		new /obj/item/clothing/under/color/red/box2550away(src)
		new /obj/item/clothing/under/color/red/box2550away(src)
		new /obj/item/clothing/under/color/red/box2550away(src)
		new /obj/item/clothing/under/color/red/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)
		new /obj/item/clothing/shoes/brown/box2550away(src)