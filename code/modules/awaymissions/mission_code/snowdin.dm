//Snow Valley Areas//--

/area/awaymission/snowdin
	name = "\improper Snowdin Tundra Plains"
	icon_state = "away"

/area/awaymission/snowdin/post
	name = "\improper Snowdin Outpost"
	icon_state = "away1"
	luminosity = 1

/area/awaymission/snowdin/igloo
	name = "\improper Snowdin Igloos"
	icon_state = "away2"
	luminosity = 1

/area/awaymission/snowdin/cave
	name = "\improper Snowdin Caves"
	icon_state = "away2"

/area/awaymission/snowdin/base
	name = "\improper Snowdin Main Base"
	icon_state = "away3"
	luminosity = 1

/area/awaymission/snowdin/dungeon1
	name = "\improper Snowdin Depths"
	icon_state = "away2"
	luminosity = 1

/area/awaymission/snowdin/sekret
	name = "\improper Snowdin Operations"
	luminosity = 1
	icon_state = "away3"

//notes for lore or treasure hints wow//--

/obj/item/weapon/paper/crumpled/snowdin/snowdingatewaynotice
	name = "scribbled note"
	info = {"The gateway has been inactive for months, engineers think its due to the recent drop in tempature fucking with the
	circuitry or something. Without a constant supply of resources from central command, our stock is getting awfully low. Some of the security members have taken to
	using the sparse rifle ammo left to hunting some of the wildlife to try and keep our food supply from emptying. God forbid if the heating goes out, I don't want to
	die as a fucking popsicle down here."}

/obj/item/weapon/paper/crumpled/snowdin/misc1
	name = "Mission Prologe"
	info = {"Holy shit, what a rush! Those Nanotrasen bastards didn't even know what hit 'em! All five of us dropped in right on the captain, didn't even have time to yell! We were in and out with that disk in mere minutes!
	Crew didn't even know what was happening till the delta alert went down and by then were were already gone. We got a case to drink on the way home to celebrate, fuckin' job well done!"}

/obj/item/weapon/paper/snowdin/snowdinlog
	name = "Activity Log"
	info = {"<b><center>ACTIVITY LOG</b></center><br><br><b>June 3rd</b><br>We've moved to the main base in the valley finally, apparently establishing a listening system on a planet
	that never stops fucking snowing is a great idea. There's a few outposts further south we'll be supplying from the main gateway. The summer months are enough already, I can only imagine how bad it'll be during winter.<br><br><b>August 23rd</b><br>
	The colder months are finally hitting, some of the machinery seems to be having trouble starting up sometimes. Central sent some portable heaters to help keep the airlocks from
	freezing shut along with a couple storage crates with supplies. Nothing on the radio so far, what the hell do they even expect to hear down here, anyway?<br><br><b>September 15th</b>
	<br>Another supply shipment through the gateway, they've sent some heavier sets of clothes for the coming winter months. Central said they might encounter issues with shipments
	during December to Feburary, so we should try to be frugal with the next shipment.<br><br><b>November 20th</b><br>Final shipment from central for the next few months. Going outside
	for more than 10-15 minutes without losing feeling in your fingers is difficult. We've finally gotten a signal on the radio, its mostly some weird static though. One of the researchers is trying to decypher it.
	<br><br><b>December 10th</b><br>Signal has gotten much stronger, it almost seems like its coming from under us according to what the researcher managed to decypher. We're waiting from the go from central before investigating.<br><br>
	<i>The rest of the paper seems to be a mixture of scribles and smudged ink.</i> "}

/obj/item/weapon/paper/snowdin/snowdinlog2
	name = "Activity Log"
	info = {"<b><center>ACTIVITY LOG</b></center><br><br><b>June 14th</b><br>Movement to the second post is finally done. We're located on the most-southern area of the valley with a similar objective as the northen post.
	Theres two mid-way stops on the eastern and western sides of the valley so movement inbetween bases isn't horrible. Not too big of a fan of relying on the northen base for
	equal supply distribution, though.<br><br><b>August 27h</b><br>First shipment arrived finally, about 4 days after the gateway shipped. Insulation on these buildings is awful, thank god for the spare heaters at least.<br><br>
	<b>September 20th</b><br>Another shipment arrival, standard shit. Our radios have been picking up a weird signal during the nights recently, we've sent the transcripts over to the northen
	base to be decyphered. Probably some drunk russians or something equally stupid.<br><br><b>November 24th</b><br>We've lost communications with the northern base after recieving the last
	shipment of supplies. The snow has really kicked up recently, shits almost like a constant blizzard right now. Maybe it'll drop down soon so we can get a word in.<br><br>
	<i>The rest of the paper seems to be a mixture of scribles and smudged ink.</i> "}

obj/item/weapon/paper/snowdin/secnotice
	name = "Security Notice"
	info = {"You have been assigned a postion on a listening outpost. Here you'll be watching over a several crewmembers assigned to watching signals of the general area.
	 As not much is expected in terms of issues, we've only assigned one guard per outpost. Crewmembers are expected to keep to their regulated work schedules and may be
	 disciplined properly if found slacking. Food hording is heavily discouraged as all outposts will be sharing from the same shipment every 2-3 months. Hording of supplies
	 should be punished severely as to prevent future incidients. Mutiny and/or rioting should be reported to central and dealt with swiftly. You're here to secure and protect
	 Nanotrasen assets, not be a police officer. Do what you must, but make sure its not messy."}
obj/item/weapon/paper/snowdin/syndienotice
	name = "Assignment Notice"
	info = {"You've been assigned as an agent to listen in on Nanotrasen activities from passing ships and nearby stations. The outpost you've been assigned to is under lays of solid
	ice and we've supplied you with a scrambler to help avoid Nanotrasen discovery, as they've recently built a listening post of their own aboveground. Get aquainted with your new
	crewmates, because you're gonna be here for awhile. Enjoy the free syndicakes."}

//lootspawners//--

/obj/effect/spawner/lootdrop/dungeonlite
	name = "dungeon lite"
	lootdoubles = 1
	lootcount = 5
	loot = list(/obj/item/weapon/melee/classic_baton = 8,
				/obj/item/weapon/melee/classic_baton/telescopic = 12,
				/obj/item/weapon/spellbook/oneuse/smoke = 4,
				/obj/item/weapon/spellbook/oneuse/blind = 3,
				)

/obj/effect/spawner/lootdrop/dungeonmid
	name = "dungeon mid"
	lootdoubles = 0
	lootcount = 3
	loot = list(/obj/item/weapon/defibrillator/compact = 6,
				/obj/item/weapon/storage/firstaid/tactical = 12,
				/obj/item/weapon/teleportation_scroll/apprentice = 4,
				/obj/item/weapon/shield/energy = 6,
				/obj/item/weapon/shield/riot/tele = 8,
				/obj/item/weapon/dnainjector/lasereyesmut = 9,
				/obj/item/weapon/gun/magic/wand/fireball/innert = 3,
				/obj/item/weapon/pneumatic_cannon = 5,
				/obj/item/weapon/melee/energy/sword = 5,
				/obj/item/weapon/spellbook/oneuse/knock = 3,
				/obj/item/weapon/spellbook/oneuse/summonitem = 6,
				/obj/item/weapon/spellbook/oneuse/forcewall = 2)


/obj/effect/spawner/lootdrop/dungeonheavy
	name = "dungeon heavy"
	lootdoubles = 0
	lootcount = 2

	loot = list(/obj/item/weapon/twohanded/singularityhammer = 7,
				/obj/item/weapon/twohanded/mjollnir = 5,
				/obj/item/weapon/twohanded/fireaxe = 12,
				/obj/item/organ/internal/brain/alien = 8,
				/obj/item/weapon/twohanded/dualsaber = 6,
				/obj/item/organ/internal/heart/demon = 4,
				/obj/item/weapon/gun/projectile/automatic/c20r/unrestricted = 6,
				/obj/item/weapon/teleportation_scroll = 3,
				/obj/item/weapon/dice/d20/fate = 1,
				/obj/item/weapon/gun/magic/wand/resurrection/innert = 5,
				/obj/item/device/uplink/old = 2,
				/obj/item/weapon/spellbook/oneuse/charge = 7,
				)

/obj/effect/spawner/lootdrop/dungeonmisc
	name = "dungeon misc"
	lootdoubles = 1
	lootcount = 3

	loot = list(/obj/item/stack/sheet/mineral/snow{amount = 25} = 10,
				/obj/item/toy/snowball = 15,
				/obj/item/weapon/shovel = 10,
				/obj/item/weapon/twohanded/spear = 8,
				)

//special items//--

/obj/item/clothing/under/syndicate/coldres
	name = "insulated tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants. The interior has been padded with special insulation for both warmth and protection"
	armor = list(melee = 20, bullet = 10, laser = 0,energy = 5, bomb = 0, bio = 0, rad = 0)
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/shoes/combat/coldres
	name = "insulated combat boots"
	desc = "High speed, low drag combat boots, now with an added layer of insulation."
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/weapon/gun/magic/wand/fireball/innert
	name = "weakened wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames. The years of the cold have weakened the magic inside the wand."
	max_charges = 4

/obj/item/weapon/gun/magic/wand/resurrection/innert
	name = "weakened wand of healing"
	desc = "This wand uses healing magics to heal and revive. The years of the cold have weakened the magic inside the wand."
	max_charges = 5

/obj/item/device/uplink/old //!!!
	name = "dusty radio"
	desc = "A dusty looking radio."
	uses = 10
	icon = 'icons/obj/radio.dmi'
	icon_state = "walkietalkie"

/obj/effect/landmark/corpse/syndicatesoldier/coldres
	name = "Syndicate Snow Operative"
	corpseuniform = /obj/item/clothing/under/syndicate/coldres
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/combat/coldres
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseradio = /obj/item/device/radio/headset/syndicate/alt
	corpsehelmet = /obj/item/clothing/head/helmet/swat
	corpseback = /obj/item/weapon/storage/backpack
	corpsepocket1 = /obj/item/weapon/gun/projectile/automatic/pistol
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"

/obj/effect/landmark/corpse/syndicatesoldier/coldres/alive
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	faction = "syndicate"
	flavour_text = {"You are a syndicate operative recently awoken from cyrostatis in an underground outpost. Monitor Nanotrasen communications and record infomation. All intruders should be
	disposed of swirfly to assure no gathered infomation is stolen or lost. Try not to wander too far from the outpost as the caves can be a deadly place even for a trained operative such as yourself."}

/obj/effect/landmark/corpse/syndicatesoldier/coldres/alive/female
	mobgender = FEMALE
