//Snow Valley Areas//--

/area/awaymission/snowdin
	name = "\improper Snowdin Tundra Plains"
	icon_state = "away"

/area/awaymission/snowdin/post
	name = "\improper Snowdin Outpost"
	icon_state = "away1"
	luminosity = 1
	requires_power = 1

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
	requires_power = 1

/area/awaymission/snowdin/dungeon1
	name = "\improper Snowdin Depths 1"
	icon_state = "away4"

/area/awaymission/snowdin/dungeon2
	name = "\improper Snowdin Depths 2"
	icon_state = "away4"

//notes for lore or treasure hints wow//--

/obj/item/weapon/paper/crumpled/snowdin/snowdingatewaynotice
	name = "scribbled note"
	info = {"The gateway has been inactive for months, engineers think its due to the recent drop in tempature fucking with the
	circuitry or something. Without a constant supply of resources from central command, our stock is getting awfully low. Some of the security members have taken to
	using the sparse rifle ammo left to hunting some of the wildlife to try and keep our food supply from emptying. God forbid if the heating goes out, I don't want to
	die as a fucking popsicle down here."}

/obj/item/weapon/paper/crumpled/snowdin/misc1
	name = "blankspace"
	info = {"blankspace"}

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

//lootspawners//--

/obj/effect/spawner/lootdrop/dungeon1start
	name = "dungeon 1 start"
	lootdoubles = 0

	loot = list()

/obj/effect/spawner/lootdrop/dungeon1mid
	name = "dungeon 1 mid"
	lootdoubles = 0

	loot = list()

/obj/effect/spawner/lootdrop/dungeon1end
	name = "dungeon 1 end"
	lootdoubles = 0

	loot = list()

/obj/effect/spawner/lootdrop/dungeon2start
	name = "dungeon 2 start"
	lootdoubles = 0

	loot = list()

/obj/effect/spawner/lootdrop/dungeon2mid
	name = "dungeon 2 mid"
	lootdoubles = 0

	loot = list()

/obj/effect/spawner/lootdrop/dungeon2end
	name = "dungeon 2 end"
	lootdoubles = 0

	loot = list()

/obj/effect/spawner/lootdrop/dungeonmisc
	name = "dungeon misc"
	lootdoubles = 0

	loot = list()