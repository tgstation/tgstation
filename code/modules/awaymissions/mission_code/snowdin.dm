
//notes for lore or treasure hints wow//--

/obj/item/weapon/paper/crumpled/snowdin/snowdingatewaynotice
	name = "scribbled note"
	info = {"The gateway has been inactive for months, engineers think it's due to the recent drop in tempature fucking with the
	circuitry or something. Without a constant supply of resources from central command, our stock is getting awfully low. Some of the security members have taken to
	using the sparse rifle ammo left to hunting some of the wildlife to try and keep our food supply from emptying. God forbid if the heating goes out, I don't want to
	die as a fucking popsicle down here."}

/obj/item/weapon/paper/crumpled/snowdin/misc1
	name = "Mission Prologue"
	info = {"Holy shit, what a rush! Those Nanotrasen bastards didn't even know what hit 'em! All five of us dropped in right on the captain, didn't even have time to yell! We were in and out with that disk in mere minutes!
	Crew didn't even know what was happening till the delta alert went down and by then were were already gone. We got a case to drink on the way home to celebrate, fuckin' job well done!"}

/obj/item/weapon/paper/crumpled/snowdin/keys
	name = "scribbled note"
	info = {"As a notice for anyone looking to borrow an ATV, some asshat lost the key set for all the vehicles. Nobody has yet to actually come forward about the potential where-abouts, either due to embarrassment or fear of
	reprecussions. I hope they enjoy walking through that shit snow during the next shipment because I sure as hell ain't."}

/obj/item/weapon/paper/snowdin/snowdinlog
	name = "Activity Log"
	info = {"<b><center>ACTIVITY LOG</b></center><br><br><b>June 3rd</b><br>We've moved to the main base in the valley finally, apparently establishing a listening system on a planet
	that never stops fucking snowing is a great idea. There's a few outposts further south we'll be supplying from the main gateway. The summer months are enough already, I can only imagine how bad it'll be during winter.<br><br><b>August 23rd</b><br>
	The colder months are finally hitting, some of the machinery seems to be having trouble starting up sometimes. Central sent some portable heaters to help keep the airlocks from
	freezing shut along with a couple storage crates with supplies. Nothing on the radio so far, what the hell do they even expect to hear down here, anyway?<br><br><b>September 15th</b>
	<br>Another supply shipment through the gateway, they've sent some heavier sets of clothes for the coming winter months. Central said they might encounter issues with shipments
	during December to Feburary, so we should try to be frugal with the next shipment.<br><br><b>November 20th</b><br>Final shipment from central for the next few months. Going outside
	for more than 10-15 minutes without losing feeling in your fingers is difficult. We've finally gotten a signal on the radio, it's mostly some weird static though. One of the researchers is trying to decypher it.
	<br><br><b>December 10th</b><br>Signal has gotten much stronger, it almost seems like it's coming from under us according to what the researcher managed to decypher. We're waiting from the go from central before investigating.<br><br>
	<i>The rest of the paper seems to be a mixture of scribbles and smudged ink.</i> "}

/obj/item/weapon/paper/snowdin/snowdinlog2
	name = "Activity Log"
	info = {"<b><center>ACTIVITY LOG</b></center><br><br><b>June 14th</b><br>Movement to the second post is finally done. We're located on the southernmost area of the valley with a similar objective as the northern post.
	There are two mid-way stops on the eastern and western sides of the valley so movement in between bases isn't horrible. Not too big of a fan of relying on the northern base for
	equal supply distribution, though.<br><br><b>August 27h</b><br>First shipment arrived finally, about 4 days after the gateway shipped. Insulation on these buildings is awful, thank god for the spare heaters at least.<br><br>
	<b>September 20th</b><br>Another shipment arrival, standard shit. Our radios have been picking up a weird signal during the nights recently, we've sent the transcripts over to the northern
	base to be decyphered. Probably some drunk russians or something equally stupid.<br><br><b>November 24th</b><br>We've lost communications with the northern base after recieving the last
	shipment of supplies. The snow has really kicked up recently, shits almost like a constant blizzard right now. Maybe it'll drop down soon so we can get a word in.<br><br>
	<i>The rest of the paper seems to be a mixture of scribbles and smudged ink.</i> "}

/obj/item/weapon/paper/snowdin/secnotice
	name = "Security Notice"
	info = {"You have been assigned a position on a listening outpost. Here you'll be watching over several crewmembers assigned to watching signals of the general area.
	 As not much is expected in terms of issues, we've only assigned one guard per outpost. Crewmembers are expected to keep to their regulated work schedules and may be
	 disciplined properly if found slacking. Food hoarding is heavily discouraged as all outposts will be sharing from the same shipment every 2-3 months. Hoarding of supplies
	 should be punished severely as to prevent future incidients. Mutiny and/or rioting should be reported to central and dealt with swiftly. You're here to secure and protect
	 Nanotrasen assets, not be a police officer. Do what you must, but make sure it's not messy."}

/obj/item/weapon/paper/snowdin/syndienotice
	name = "Assignment Notice"
	info = {"You've been assigned as an agent to listen in on Nanotrasen activities from passing ships and nearby stations. The outpost you've been assigned to is under lays of solid
	ice and we've supplied you with a scrambler to help avoid Nanotrasen discovery, as they've recently built a listening post of their own aboveground. Get aquainted with your new
	crewmates, because you're gonna be here for awhile. Enjoy the free syndicakes."}

/obj/item/weapon/paper/crumpled/snowdin/syndielava
	name = "scribbled note"
	info = {"Some cracks in the ice nearby have exposed some sort of hidden magma stream under all this shit ice. I don't know whats worse at this point honestly; freezing to death or
	burning alive."}

/obj/item/weapon/paper/crumpled/snowdin/lootstructures
	name = "scribbled note"
	info = {"From what we've seen so far, theres a ton of iced-over ruins down here in the caves. We sent a few men out to check things out and they never came back, so we decided to
	border up majority of the ruins. We've heard some weird shit coming out of these caves and I'm not gonna find out the hard way myself."}

/obj/item/weapon/paper/crumpled/snowdin/shovel
	name = "shoveling duties"
	info = {"Snow piles up bad here all-year round, even worse during the winter months. Keeping a constant rotation of shoveling that shit out of the way of the airlocks and keeping the paths decently clear
	is a good step towards not getting stuck walking through knee-deep snow."}

//lootspawners//--

/obj/effect/spawner/lootdrop/snowdin
	name = "why are you using this dummy"
	lootdoubles = 0
	lootcount = 1
	loot = list(/obj/item/weapon/bikehorn = 100)

/obj/effect/spawner/lootdrop/snowdin/dungeonlite
	name = "dungeon lite"
	loot = list(/obj/item/weapon/melee/classic_baton = 11,
				/obj/item/weapon/melee/classic_baton/telescopic = 12,
				/obj/item/weapon/spellbook/oneuse/smoke = 10,
				/obj/item/weapon/spellbook/oneuse/blind = 10,
				/obj/item/weapon/storage/firstaid/regular = 45,
				/obj/item/weapon/storage/firstaid/toxin = 35,
				/obj/item/weapon/storage/firstaid/brute = 27,
				/obj/item/weapon/storage/firstaid/fire = 27,
				/obj/item/weapon/storage/toolbox/syndicate = 12,
				/obj/item/weapon/grenade/plastic/c4 = 7,
				/obj/item/weapon/grenade/clusterbuster/smoke = 15,
				/obj/item/clothing/under/chameleon = 13,
				/obj/item/clothing/shoes/chameleon = 10,
				/obj/item/borg/upgrade/ddrill = 3,
				/obj/item/borg/upgrade/soh = 3)

/obj/effect/spawner/lootdrop/snowdin/dungeonmid
	name = "dungeon mid"
	loot = list(/obj/item/weapon/defibrillator/compact = 6,
				/obj/item/weapon/storage/firstaid/tactical = 35,
				/obj/item/weapon/shield/energy = 6,
				/obj/item/weapon/shield/riot/tele = 12,
				/obj/item/weapon/dnainjector/lasereyesmut = 7,
				/obj/item/weapon/gun/magic/wand/fireball/inert = 3,
				/obj/item/weapon/pneumatic_cannon = 15,
				/obj/item/weapon/melee/transforming/energy/sword = 7,
				/obj/item/weapon/spellbook/oneuse/knock = 15,
				/obj/item/weapon/spellbook/oneuse/summonitem = 20,
				/obj/item/weapon/spellbook/oneuse/forcewall = 17,
				/obj/item/weapon/storage/backpack/holding = 12,
				/obj/item/weapon/grenade/spawnergrenade/manhacks = 6,
				/obj/item/weapon/grenade/spawnergrenade/spesscarp = 7,
				/obj/item/weapon/grenade/clusterbuster/inferno = 3,
				/obj/item/stack/sheet/mineral/diamond{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/uranium{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/plasma{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/gold{amount = 15} = 10,
				/obj/item/weapon/spellbook/oneuse/barnyard = 4,
				/obj/item/weapon/pickaxe/drill/diamonddrill = 6,
				/obj/item/borg/upgrade/vtec = 7,
				/obj/item/borg/upgrade/disablercooler = 7)


/obj/effect/spawner/lootdrop/snowdin/dungeonheavy
	name = "dungeon heavy"
	loot = list(/obj/item/weapon/twohanded/singularityhammer = 25,
				/obj/item/weapon/twohanded/mjollnir = 10,
				/obj/item/weapon/twohanded/fireaxe = 25,
				/obj/item/organ/brain/alien = 17,
				/obj/item/weapon/twohanded/dualsaber = 15,
				/obj/item/organ/heart/demon = 7,
				/obj/item/weapon/gun/ballistic/automatic/c20r/unrestricted = 16,
				/obj/item/weapon/gun/magic/wand/resurrection/inert = 15,
				/obj/item/weapon/gun/magic/wand/resurrection = 10,
				/obj/item/device/radio/uplink/old = 2,
				/obj/item/weapon/spellbook/oneuse/charge = 12,
				/obj/item/weapon/grenade/clusterbuster/spawner_manhacks = 15,
				/obj/item/weapon/spellbook/oneuse/fireball = 10,
				/obj/item/weapon/pickaxe/drill/jackhammer = 30,
				/obj/item/borg/upgrade/syndicate = 13,
				/obj/item/borg/upgrade/selfrepair = 17)

/obj/effect/spawner/lootdrop/snowdin/dungeonmisc
	name = "dungeon misc"
	lootdoubles = 2
	lootcount = 1

	loot = list(/obj/item/stack/sheet/mineral/snow{amount = 25} = 10,
				/obj/item/toy/snowball = 15,
				/obj/item/weapon/shovel = 10,
				/obj/item/weapon/twohanded/spear = 8,
				)

//special items//--

/obj/item/clothing/under/syndicate/coldres
	name = "insulated tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants. The interior has been padded with special insulation for both warmth and protection"
	armor = list(melee = 20, bullet = 10, laser = 0,energy = 5, bomb = 0, bio = 0, rad = 0, fire = 25, acid = 25)
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
/obj/item/clothing/shoes/combat/coldres
	name = "insulated combat boots"
	desc = "High speed, low drag combat boots, now with an added layer of insulation."
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/weapon/gun/magic/wand/fireball/inert
	name = "weakened wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames. The years of the cold have weakened the magic inside the wand."
	max_charges = 4

/obj/item/weapon/gun/magic/wand/resurrection/inert
	name = "weakened wand of healing"
	desc = "This wand uses healing magics to heal and revive. The years of the cold have weakened the magic inside the wand."
	max_charges = 5

/obj/item/device/radio/uplink/old
	name = "dusty radio"
	desc = "A dusty looking radio."

/obj/item/device/radio/uplink/old/Initialize()
	. = ..()
	hidden_uplink.name = "dusty radio"
	hidden_uplink.telecrystals = 10

/obj/effect/mob_spawn/human/syndicatesoldier/coldres
	name = "Syndicate Snow Operative"
	outfit = /datum/outfit/snowsyndie/corpse

/datum/outfit/snowsyndie/corpse
	name = "Syndicate Snow Operative Corpse"
	implants = null

/obj/effect/mob_spawn/human/syndicatesoldier/coldres/alive
	name = "sleeper"
	mob_name = "Syndicate Snow Operative"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	faction = "syndicate"
	outfit = /datum/outfit/snowsyndie
	flavour_text = {"You are a syndicate operative recently awoken from cyrostatis in an underground outpost. Monitor Nanotrasen communications and record infomation. All intruders should be
	disposed of swirfly to assure no gathered infomation is stolen or lost. Try not to wander too far from the outpost as the caves can be a deadly place even for a trained operative such as yourself."}

/datum/outfit/snowsyndie
	name = "Syndicate Snow Operative"
	uniform = /obj/item/clothing/under/syndicate/coldres
	shoes = /obj/item/clothing/shoes/combat/coldres
	ears = /obj/item/device/radio/headset/syndicate/alt
	r_pocket = /obj/item/weapon/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/weapon/card/id/syndicate
	implants = list(/obj/item/weapon/implant/exile)

/obj/effect/mob_spawn/human/syndicatesoldier/coldres/alive/female
	mob_gender = FEMALE

//mobs//--

//ice spiders moved to giant_spiders.dm

//objs//--

/obj/structure/flora/rock/icy
	name = "icy rock"
	color = rgb(114,228,250)

/obj/structure/flora/rock/pile/icy
	name = "icey rocks"
	color = rgb(114,228,250)


