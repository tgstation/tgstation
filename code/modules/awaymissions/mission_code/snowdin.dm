//Snow Valley Areas//--

/area/awaymission/snowdin
	name = "Snowdin"
	icon_state = "awaycontent1"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/awaymission/snowdin/outside
	name = "Snowdin Tundra Plains"
	icon_state = "awaycontent25"

/area/awaymission/snowdin/post
	name = "Snowdin Outpost"
	icon_state = "awaycontent2"
	requires_power = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/snowdin/post/medbay
	name = "Snowdin Outpost - Medbay"
	icon_state = "awaycontent3"

/area/awaymission/snowdin/post/secpost
	name = "Snowdin Outpost - Security Checkpoint"
	icon_state = "awaycontent4"

/area/awaymission/snowdin/post/hydro
	name = "Snowdin Outpost - Hydroponics"
	icon_state = "awaycontent5"

/area/awaymission/snowdin/post/messhall
	name = "Snowdin Outpost - Mess Hall"
	icon_state = "awaycontent6"

/area/awaymission/snowdin/post/gateway
	name = "Snowdin Outpost - Gateway"
	icon_state = "awaycontent7"

/area/awaymission/snowdin/post/dorm
	name = "Snowdin Outpost - Dorms"
	icon_state = "awaycontent8"

/area/awaymission/snowdin/post/kitchen
	name = "Snowdin Outpost - Kitchen"
	icon_state = "awaycontent9"

/area/awaymission/snowdin/post/engineering
	name = "Snowdin Outpost - Engineering"
	icon_state = "awaycontent10"

/area/awaymission/snowdin/post/custodials
	name = "Snowdin Outpost - Custodials"
	icon_state = "awaycontent11"

/area/awaymission/snowdin/post/research
	name = "Snowdin Outpost - Research Area"
	icon_state = "awaycontent12"

/area/awaymission/snowdin/post/garage
	name = "Snowdin Outpost - Garage"
	icon_state = "awaycontent13"

/area/awaymission/snowdin/post/minipost
	name = "Snowdin Outpost - Recon Post"
	icon_state = "awaycontent19"

/area/awaymission/snowdin/post/mining_main
	name = "Snowdin Outpost - Mining Post"
	icon_state = "awaycontent21"

/area/awaymission/snowdin/post/mining_main/mechbay
	name = "Snowdin Outpost - Mining Post Mechbay"
	icon_state = "awaycontent25"

/area/awaymission/snowdin/post/mining_main/robotics
	name = "Snowdin Outpost - Mining Post Robotics"
	icon_state = "awaycontent26"

/area/awaymission/snowdin/post/cavern1
	name = "Snowdin Outpost - Cavern Outpost 1"
	icon_state = "awaycontent27"

/area/awaymission/snowdin/post/cavern2
	name = "Snowdin Outpost - Cavern Outpost 2"
	icon_state = "awaycontent28"

/area/awaymission/snowdin/post/mining_dock
	name = "Snowdin Outpost - Underground Mine Post"
	icon_state = "awaycontent22"

/area/awaymission/snowdin/post/broken_shuttle
	name = "Snowdin Outpost - Broken Transist Shuttle"
	icon_state = "awaycontent20"
	requires_power = FALSE

/area/awaymission/snowdin/igloo
	name = "Snowdin Igloos"
	icon_state = "awaycontent14"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/snowdin/cave
	name = "Snowdin Caves"
	icon_state = "awaycontent15"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/snowdin/cave/cavern
	name = "Snowdin Depths"
	icon_state = "awaycontent23"

/area/awaymission/snowdin/cave/mountain
	name = "Snowdin Mountains"
	icon_state = "awaycontent24"


/area/awaymission/snowdin/base
	name = "Snowdin Main Base"
	icon_state = "awaycontent16"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	requires_power = TRUE

/area/awaymission/snowdin/dungeon1
	name = "Snowdin Depths"
	icon_state = "awaycontent17"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/snowdin/sekret
	name = "Snowdin Operations"
	icon_state = "awaycontent18"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	requires_power = TRUE

/area/shuttle/snowdin/elevator1
	name = "Excavation Elevator"

/area/shuttle/snowdin/elevator2
	name = "Mining Elevator"

//shuttle console for elevators//

/obj/machinery/computer/shuttle/snowdin/mining
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	shuttleId = "snowdin_mining"
	possible_destinations = "snowdin_mining_top;snowdin_mining_down"


//liquid plasma!!!!!!//

/turf/open/lava/plasma
	name = "liquid plasma"
	desc = "A flowing stream of chilled liquid plasma. You probably shouldn't get in."
	icon_state = "liquidplasma"
	initial_gas_mix = "o2=0;n2=82;plasma=24;TEMP=120"
	baseturfs = /turf/open/lava/plasma
	slowdown = 2

	light_range = 3
	light_power = 0.75
	light_color = LIGHT_COLOR_PURPLE

/turf/open/lava/plasma/attackby(obj/item/I, mob/user, params)
	var/obj/item/reagent_containers/glass/C = I
	if(C.reagents.total_volume >= C.volume)
		to_chat(user, "<span class='danger'>[C] is full.</span>")
		return
	C.reagents.add_reagent("plasma", rand(5, 10))
	user.visible_message("[user] scoops some plasma from the [src] with \the [C].", "<span class='notice'>You scoop out some plasma from the [src] using \the [C].</span>")

/turf/open/lava/plasma/burn_stuff(AM)
	. = 0

	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if((O.resistance_flags & (FREEZE_PROOF)) || O.throwing)
				continue

		else if (isliving(thing))
			. = 1
			var/mob/living/L = thing
			if(L.movement_type & FLYING)
				continue	//YOU'RE FLYING OVER IT
			if("snow" in L.weather_immunities)
				continue

			var/buckle_check = L.buckling
			if(!buckle_check)
				buckle_check = L.buckled
			if(isobj(buckle_check))
				var/obj/O = buckle_check
				if(O.resistance_flags & FREEZE_PROOF)
					continue

			else if(isliving(buckle_check))
				var/mob/living/live = buckle_check
				if("snow" in live.weather_immunities)
					continue

			L.adjustFireLoss(2)
			if(L)
				L.adjust_fire_stacks(20) //dipping into a stream of plasma would probably make you more flammable than usual
				L.bodytemperature -=(rand(50,65)) //its cold, man
				if(ishuman(L))//are they a carbon?
					var/list/plasma_parts = list()//a list that'll store the limbs of our victim
					var/mob/living/carbon/human/PP = L
					if(istype(PP.dna.species, /datum/species/plasmaman))
						return //don't bother with plasmamen here

					for(var/BP in PP.bodyparts) //getting the victim's current body parts
						var/obj/item/bodypart/NN = BP
						if(NN.status == BODYPART_ORGANIC || NN.species_id != "plasmaman") //getting every organic, non-plasmaman limb (augments/androids are immune to this)
							plasma_parts += NN //adding the limbs we got to the above-mentioned list

					if(prob(35)) //checking if the delay is over & if the victim actually has any parts to nom
						PP.adjustToxLoss(15)
						PP.adjustFireLoss(25)
						if(plasma_parts.len)
							var/obj/item/bodypart/NB = pick(plasma_parts) //using the above-mentioned list to get a choice of limbs for dismember() to use
							NB.species_id = "plasmaman"//change the species_id of the limb to that of a plasmaman
							PP.visible_message("<span class='warning'>[L] screams in pain as their [NB] melts down to the bone!</span>", \
											  "<span class='userdanger'>You scream out in pain as your [NB] melts down to the bone, leaving an eerie plasma-like glow where flesh used to be!</span>")


/obj/vehicle/ridden/lavaboat/plasma
	name = "plasma boat"
	desc = "A boat used for traversing the streams of plasma without turning into an icecube."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	resistance_flags = FREEZE_PROOF
	can_buckle = TRUE
///////////	papers


/obj/item/paper/crumpled/ruins/snowdin/snowdingatewaynotice
	name = "scribbled note"
	info = {"The gateway has been inactive for months, engineers think it's due to the recent drop in tempature fucking with the
	circuitry or something. Without a constant supply of resources from Central Command, our stock is getting awfully low. Some of the security members have taken to
	using the sparse rifle ammo left to hunting some of the wildlife to try and keep our food supply from emptying. God forbid if the heating goes out, I don't want to
	die as a fucking popsicle down here."}

/obj/item/paper/crumpled/ruins/snowdin/misc1
	name = "Mission Prologue"
	info = {"Holy shit, what a rush! Those Nanotrasen bastards didn't even know what hit 'em! All five of us dropped in right on the captain, didn't even have time to yell! We were in and out with that disk in mere minutes!
	Crew didn't even know what was happening till the delta alert went down and by then we were already gone. We got a case to drink on the way home to celebrate, fuckin' job well done!"}

/obj/item/paper/crumpled/ruins/snowdin/keys
	name = "scribbled note"
	info = {"As a notice for anyone looking to borrow an ATV, some asshat lost the key set for all the vehicles. Nobody has yet to actually come forward about the potential where-abouts, either due to embarrassment or fear of
	reprecussions. I hope they enjoy walking through that shit snow during the next shipment because I sure as hell ain't."}

/obj/item/paper/fluff/awaymissions/snowdin/saw_usage
	name = "SAW Usage"
	info = "YOU SEEN IVAN, WHEN YOU HOLD SAAW LIKE PEESTOL, YOU STRONGER THAN RECOIL FOR FEAR OF HITTING FACE!"

/obj/item/paper/fluff/awaymissions/snowdin/log
	name = "Activity Log"
	info = {"<b><center>ACTIVITY LOG</b></center><br><br><b>June 3rd</b><br>We've moved to the main base in the valley finally, apparently establishing a listening system on a planet
	that never stops fucking snowing is a great idea. There's a few outposts further south we'll be supplying from the main gateway. The summer months are enough already, I can only imagine how bad it'll be during winter.<br><br><b>August 23rd</b><br>
	The colder months are finally hitting, some of the machinery seems to be having trouble starting up sometimes. Central sent some portable heaters to help keep the airlocks from
	freezing shut along with a couple storage crates with supplies. Nothing on the radio so far, what the hell do they even expect to hear down here, anyway?<br><br><b>September 15th</b>
	<br>Another supply shipment through the gateway, they've sent some heavier sets of clothes for the coming winter months. Central said they might encounter issues with shipments
	during December to Feburary, so we should try to be frugal with the next shipment.<br><br><b>November 20th</b><br>Final shipment from Central for the next few months. Going outside
	for more than 10-15 minutes without losing feeling in your fingers is difficult. We've finally gotten a signal on the radio, it's mostly some weird static though. One of the researchers is trying to decypher it.
	<br><br><b>December 10th</b><br>Signal has gotten much stronger, it almost seems like it's coming from under us according to what the researcher managed to decypher. We're waiting from the go from Central before investigating.<br><br>
	<i>The rest of the paper seems to be a mixture of scribbles and smudged ink.</i>"}

/obj/item/paper/fluff/awaymissions/snowdin/log2
	name = "Activity Log"
	info = {"<b><center>ACTIVITY LOG</b></center><br><br><b>June 14th</b><br>Movement to the second post is finally done. We're located on the southernmost area of the valley with a similar objective as the northern post.
	There are two mid-way stops on the eastern and western sides of the valley so movement in between bases isn't horrible. Not too big of a fan of relying on the northern base for
	equal supply distribution, though.<br><br><b>August 27h</b><br>First shipment arrived finally, about 4 days after the gateway shipped. Insulation on these buildings is awful, thank god for the spare heaters at least.<br><br>
	<b>September 20th</b><br>Another shipment arrival, standard shit. Our radios have been picking up a weird signal during the nights recently, we've sent the transcripts over to the northern
	base to be decyphered. Probably some drunk russians or something equally stupid.<br><br><b>November 24th</b><br>We've lost communications with the northern base after recieving the last
	shipment of supplies. The snow has really kicked up recently, shits almost like a constant blizzard right now. Maybe it'll drop down soon so we can get a word in.<br><br>
	<i>The rest of the paper seems to be a mixture of scribbles and smudged ink.</i>"}

//profile of each of the old crewmembers for the outpost

/obj/item/paper/fluff/awaymissions/snowdin/profile/overseer
	name = "Personnel Record AOP#01"
	info = {"<b><center>Personnel Log</b></center><br><br><b>Name:</b>Caleb Reed<br><b>Age:</b>38<br><b>Gender:</b>Male<br><b>On-Site Profession:</b>Outpost Overseer<br><br><center><b>Infomation</b></center><br><center>Caleb Reed lead several expeditions
	 among uncharted planets in search of plasma for Nanotrasen, scouring from hot savanas to freezing arctics. Track record is fairly clean with only incidient including the loss of two researchers during the
	 expedition of <b>_______</b>, where mis-used of explosive ordinance for tunneling causes a cave-in."}

/obj/item/paper/fluff/awaymissions/snowdin/profile/sec1
	name = "Personnel Record AOP#02"
	info = {"<b><center>Personnel Log</b></center><br><br><b>Name:</b>James Reed<br><b>Age:</b>43<br><b>Gender:</b>Male<br><b>On-Site Profession:</b>Outpost Security<br><br><center><b>Infomation</b></center><br><center>James Reed has been a part
	 of Nanotrasen's security force for over 20 years, first joining in 22XX. A clean record and unwavering loyalty to the corperation through numerous deployments to various sites makes him a valuable asset to Natotrasen
	  when it comes to keeping the peace while prioritizing Nanotrasen privacy matters. "}

/obj/item/paper/fluff/awaymissions/snowdin/profile/hydro1
	name = "Personnel Record AOP#03"
	info = {"<b><center>Personnel Log</b></center><br><br><b>Name:</b>Katherine Esterdeen<br><b>Age:</b>27<br><b>Gender:</b>Female<br><b>On-Site Profession:</b>Outpost Botanist<br><br><center><b>Infomation</b></center><br><center>Katherine Esterdeen is a recent
	 graduate with a major in Botany and a PH.D in Ecology. Having a clean record and eager to work, Esterdeen seems to be the right fit for maintaining plants in the middle of nowhere."}

/obj/item/paper/fluff/awaymissions/snowdin/profile/engi1
	name = "Personnel Record AOP#04"
	info = {"<b><center>Personnel Log</b></center><br><br><b>Name:</b>Rachel Migro<br><b>Age:</b>35<br><b>Gender:</b>Female<br><b>On-Site Profession:</b>Outpost Engineer<br><br><center><b>Infomation</b></center><br><center>"}

/obj/item/paper/fluff/awaymissions/snowdin/profile/research1
	name = "Personnel Record AOP#05"
	info = {"<b><center>Personnel Log</b></center><br><br><b>Name:</b>Jacob Ullman<br><b>Age:</b>27<br><b>Gender:</b>Male<br><b>On-Site Profession:</b>Outpost Researcher<br><br><center><b>Infomation</b></center><br><center>"}

/obj/item/paper/fluff/awaymissions/snowdin/profile/research2
	name = "Personnel Record AOP#06"
	info = {"<b><center>Personnel Log</b></center><br><br><b>Name:</b>Elizabeth Queef<br><b>Age:</b>28<br><b>Gender:</b>Female<br><b>On-Site Profession:</b>Outpost Researcher<br><br><center><b>Infomation</b></center><br><center>"}

/obj/item/paper/fluff/awaymissions/snowdin/profile/research3
	name = "Personnel Record AOP#07"
	info = {"<b><center>Personnel Log</b></center><br><br><b>Name:</b>Jouslen McGee<br><b>Age:</b>38<br><b>Gender:</b>Male<br><b>On-Site Profession:</b>Outpost Researcher<br><br><center><b>Infomation</b></center><br><center>"}

/obj/item/paper/fluff/awaymissions/snowdin/secnotice
	name = "Security Notice"
	info = {"You have been assigned a position on a listening outpost. Here you'll be watching over several crewmembers assigned to watching signals of the general area.
	As not much is expected in terms of issues, we've only assigned one guard per outpost. Crewmembers are expected to keep to their regulated work schedules and may be
	disciplined properly if found slacking. Food hoarding is heavily discouraged as all outposts will be sharing from the same shipment every 2-3 months. Hoarding of supplies
	should be punished severely as to prevent future incidients. Mutiny and/or rioting should be reported to Central and dealt with swiftly. You're here to secure and protect
	Nanotrasen assets, not be a police officer. Do what you must, but make sure it's not messy."}

/obj/item/paper/fluff/awaymissions/snowdin/syndienotice
	name = "Assignment Notice"
	info = {"You've been assigned as an agent to listen in on Nanotrasen activities from passing ships and nearby stations. The outpost you've been assigned to is under lays of solid
	ice and we've supplied you with a scrambler to help avoid Nanotrasen discovery, as they've recently built a listening post of their own aboveground. Get aquainted with your new
	crewmates, because you're gonna be here for awhile. Enjoy the free syndicakes."}

/obj/item/paper/crumpled/ruins/snowdin/syndielava
	name = "scribbled note"
	info = {"Some cracks in the ice nearby have exposed some sort of hidden magma stream under all this shit ice. I don't know whats worse at this point honestly; freezing to death or
	burning alive."}

/obj/item/paper/crumpled/ruins/snowdin/lootstructures
	name = "scribbled note"
	info = {"From what we've seen so far, theres a ton of iced-over ruins down here in the caves. We sent a few men out to check things out and they never came back, so we decided to
	border up majority of the ruins. We've heard some weird shit coming out of these caves and I'm not gonna find out the hard way myself."}

/obj/item/paper/crumpled/ruins/snowdin/shovel
	name = "shoveling duties"
	info = {"Snow piles up bad here all-year round, even worse during the winter months. Keeping a constant rotation of shoveling that shit out of the way of the airlocks and keeping the paths decently clear
	is a good step towards not getting stuck walking through knee-deep snow."}

//holo disk recording//--

/obj/item/disk/holodisk/snowdin/weregettingpaidright
	name = "Conversation #AOP#23"
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
	NAME Jacob Ullman
	DELAY 10
	SAY Have you gotten anything interesting on the scanners yet? The deep-drilling from the plasma is making it difficult to get anything that isn't useless noise.
	DELAY 45
	NAME Elizabeth Queef
	DELAY 10
	SAY Nah. I've been feeding the AI the results for the past 2 weeks to sift through the garbage and haven't seen anything out of the usual, at least whatever Nanotrasen is looking for.
	DELAY 45
	NAME Jacob Ullman
	DELAY 10
	SAY Figured as much. Dunno what Nanotrasen expects to find out here past the plasma. At least we're getting paid to fuck around for a couple months while the AI does the hard work.
	DELAY 45
	NAME Elizabeth Queef
	DELAY 10
	SAY . . .
	DELAY 10
	SAY ..We're getting paid?
	DELAY 20
	NAME Jacob Ullman
	DELAY 10
	SAY ..We are getting paid, aren't we..?
	DELAY 15
	PRESET /datum/preset_holoimage/captain
	NAME Caleb Reed
	DELAY 10
	SAY Paid in experience! That's the Nanotrasen Motto!
	DELAY 30;"}

/obj/item/disk/holodisk/snowdin/overrun
	name = "Conversation #AOP#55"
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
	NAME James Reed
	DELAY 10
	SAY Jesus christ, what is that thing??
	DELAY 30
	PRESET /datum/preset_holoimage/researcher
	NAME Elizabeth Queef
	DELAY 10
	SAY Hell if I know! Just shoot it already!
	DELAY 30
	PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
	NAME James Reed
	DELAY 10
	SOUND 'sound/weapons/laser.ogg'
	DELAY 10
	SOUND 'sound/weapons/laser.ogg'
	DELAY 10
	SOUND 'sound/weapons/laser.ogg'
	DELAY 10
	SOUND 'sound/weapons/laser.ogg'
	DELAY 15
	SAY Just go! I'll keep it busy, there's an outpost south of here with an elevator to the surface.
	NAME Jacob Ullman
	PRESET /datum/preset_holoimage/researcher.
	DELAY 15
	Say I don't have to be told twice! Let's get the fuck out of here.
	DELAY 20;"}

/obj/item/disk/holodisk/snowdin/ripjacob
	name = "Conversation #AOP#62"
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
	NAME Jacob Ullman
	DELAY 10
	SAY Get the elevator called. We got no idea how many of those fuckers are down here and I'd rather get off this planet as soon as possible.
	DELAY 45
	NAME Elizabeth Queef
	DELAY 10
	SAY You don't need to tell me twice, I just need to swipe access and then..
	DELAY 15
	SOUND 'sound/effects/glassbr1.ogg'
	DELAY 10
	SOUND 'sound/effects/glassbr2.ogg'
	DELAY 15
	NAME Jacob Ullman
	DELAY 10
	SAY What the FUCK was that?
	DELAY 20
	SAY OH FUCK THERE'S MORE OF THEM. CALL FASTER JESUS CHRIST.
	DELAY 20
	NAME Elizabeth Queef
	DELAY 10
	SAY DON'T FUCKING RUSH ME ALRIGHT IT'S BEING CALLED.
	DELAY 15
	SOUND 'sound/effects/huuu.ogg'
	DELAY 5
	SOUND 'sound/effects/huuu.ogg'
	DELAY 15
	SOUND 'sound/effects/woodhit.ogg'
	DELAY 2
	SOUND 'sound/effects/bodyfall3.ogg'
	DELAY 5
	SOUND 'sound/effects/meow1.ogg'
	DELAY 15
	NAME Jacob Ullman
	DELAY 10
	SAY OH FUCK IT'S GOT ME JESUS CHRIIIiiii-
	NAME Elizabeth Queef
	SAY AAAAAAAAAAAAAAAA FUCK THAT
	DELAY 15;"}

//lootspawners//--

/obj/effect/spawner/lootdrop/snowdin
	name = "why are you using this dummy"
	lootdoubles = 0
	lootcount = 1
	loot = list(/obj/item/bikehorn = 100)

/obj/effect/spawner/lootdrop/snowdin/dungeonlite
	name = "dungeon lite"
	loot = list(/obj/item/melee/classic_baton = 11,
				/obj/item/melee/classic_baton/telescopic = 12,
				/obj/item/spellbook/oneuse/smoke = 10,
				/obj/item/spellbook/oneuse/blind = 10,
				/obj/item/storage/firstaid/regular = 45,
				/obj/item/storage/firstaid/toxin = 35,
				/obj/item/storage/firstaid/brute = 27,
				/obj/item/storage/firstaid/fire = 27,
				/obj/item/storage/toolbox/syndicate = 12,
				/obj/item/grenade/plastic/c4 = 7,
				/obj/item/grenade/clusterbuster/smoke = 15,
				/obj/item/clothing/under/chameleon = 13,
				/obj/item/clothing/shoes/chameleon/noslip = 10,
				/obj/item/borg/upgrade/ddrill = 3,
				/obj/item/borg/upgrade/soh = 3)

/obj/effect/spawner/lootdrop/snowdin/dungeonmid
	name = "dungeon mid"
	loot = list(/obj/item/defibrillator/compact = 6,
				/obj/item/storage/firstaid/tactical = 35,
				/obj/item/shield/energy = 6,
				/obj/item/shield/riot/tele = 12,
				/obj/item/dnainjector/lasereyesmut = 7,
				/obj/item/gun/magic/wand/fireball/inert = 3,
				/obj/item/pneumatic_cannon = 15,
				/obj/item/melee/transforming/energy/sword = 7,
				/obj/item/spellbook/oneuse/knock = 15,
				/obj/item/spellbook/oneuse/summonitem = 20,
				/obj/item/spellbook/oneuse/forcewall = 17,
				/obj/item/storage/backpack/holding = 12,
				/obj/item/grenade/spawnergrenade/manhacks = 6,
				/obj/item/grenade/spawnergrenade/spesscarp = 7,
				/obj/item/grenade/clusterbuster/inferno = 3,
				/obj/item/stack/sheet/mineral/diamond{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/uranium{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/plasma{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/gold{amount = 15} = 10,
				/obj/item/spellbook/oneuse/barnyard = 4,
				/obj/item/pickaxe/drill/diamonddrill = 6,
				/obj/item/borg/upgrade/vtec = 7,
				/obj/item/borg/upgrade/disablercooler = 7)


/obj/effect/spawner/lootdrop/snowdin/dungeonheavy
	name = "dungeon heavy"
	loot = list(/obj/item/twohanded/singularityhammer = 25,
				/obj/item/twohanded/mjollnir = 10,
				/obj/item/twohanded/fireaxe = 25,
				/obj/item/organ/brain/alien = 17,
				/obj/item/twohanded/dualsaber = 15,
				/obj/item/organ/heart/demon = 7,
				/obj/item/gun/ballistic/automatic/c20r/unrestricted = 16,
				/obj/item/gun/magic/wand/resurrection/inert = 15,
				/obj/item/gun/magic/wand/resurrection = 10,
				/obj/item/device/radio/uplink/old = 2,
				/obj/item/spellbook/oneuse/charge = 12,
				/obj/item/grenade/clusterbuster/spawner_manhacks = 15,
				/obj/item/spellbook/oneuse/fireball = 10,
				/obj/item/pickaxe/drill/jackhammer = 30,
				/obj/item/borg/upgrade/syndicate = 13,
				/obj/item/borg/upgrade/selfrepair = 17)

/obj/effect/spawner/lootdrop/snowdin/dungeonmisc
	name = "dungeon misc"
	lootdoubles = 2
	lootcount = 1

	loot = list(/obj/item/stack/sheet/mineral/snow{amount = 25} = 10,
				/obj/item/toy/snowball = 15,
				/obj/item/shovel = 10,
				/obj/item/twohanded/spear = 8,
				)

//special items//--

/obj/item/clothing/under/syndicate/coldres
	name = "insulated tactical turtleneck"
	desc = "A non-descript and slightly suspicious-looking turtleneck with digital camouflage cargo pants. The interior has been padded with special insulation for both warmth and protection."
	armor = list(melee = 20, bullet = 10, laser = 0,energy = 5, bomb = 0, bio = 0, rad = 0, fire = 25, acid = 25)
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
/obj/item/clothing/shoes/combat/coldres
	name = "insulated combat boots"
	desc = "High speed, low drag combat boots, now with an added layer of insulation."
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/gun/magic/wand/fireball/inert
	name = "weakened wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames. The years of the cold have weakened the magic inside the wand."
	max_charges = 4

/obj/item/gun/magic/wand/resurrection/inert
	name = "weakened wand of healing"
	desc = "This wand uses healing magics to heal and revive. The years of the cold have weakened the magic inside the wand."
	max_charges = 5

/obj/effect/mob_spawn/human/syndicatesoldier/coldres
	name = "Syndicate Snow Operative"
	outfit = /datum/outfit/snowsyndie/corpse

/datum/outfit/snowsyndie/corpse
	name = "Syndicate Snow Operative Corpse"
	implants = null

/obj/effect/mob_spawn/human/syndicatesoldier/coldres/alive
	name = "sleeper"
	mob_name = "Syndicate Snow Operative"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	faction = "syndicate"
	outfit = /datum/outfit/snowsyndie
	flavour_text = {"You are a syndicate operative recently awoken from cyrostatis in an underground outpost. Monitor Nanotrasen communications and record information. All intruders should be
	disposed of swirfly to assure no gathered information is stolen or lost. Try not to wander too far from the outpost as the caves can be a deadly place even for a trained operative such as yourself."}

/datum/outfit/snowsyndie
	name = "Syndicate Snow Operative"
	uniform = /obj/item/clothing/under/syndicate/coldres
	shoes = /obj/item/clothing/shoes/combat/coldres
	ears = /obj/item/device/radio/headset/syndicate/alt
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/card/id/syndicate
	implants = list(/obj/item/implant/exile)

/obj/effect/mob_spawn/human/syndicatesoldier/coldres/alive/female
	mob_gender = FEMALE

//mobs//--

//ice spiders moved to giant_spiders.dm

//objs//--

/obj/structure/flora/rock/icy
	name = "icy rock"
	color = rgb(204,233,235)

/obj/structure/flora/rock/pile/icy
	name = "icey rocks"
	color = rgb(204,233,235)

//decals//--
/obj/effect/turf_decal/snowdin_station_sign
	icon_state = "AOP1"

/obj/effect/turf_decal/snowdin_station_sign/two
	icon_state = "AOP2"

/obj/effect/turf_decal/snowdin_station_sign/three
	icon_state = "AOP3"

/obj/effect/turf_decal/snowdin_station_sign/four
	icon_state = "AOP4"

/obj/effect/turf_decal/snowdin_station_sign/five
	icon_state = "AOP5"

/obj/effect/turf_decal/snowdin_station_sign/six
	icon_state = "AOP6"

/obj/effect/turf_decal/snowdin_station_sign/seven
	icon_state = "AOP7"

/obj/effect/turf_decal/snowdin_station_sign/up
	icon_state = "AOPU1"

/obj/effect/turf_decal/snowdin_station_sign/up/two
	icon_state = "AOPU2"

/obj/effect/turf_decal/snowdin_station_sign/up/three
	icon_state = "AOPU3"

/obj/effect/turf_decal/snowdin_station_sign/up/four
	icon_state = "AOPU4"

/obj/effect/turf_decal/snowdin_station_sign/up/five
	icon_state = "AOPU5"

/obj/effect/turf_decal/snowdin_station_sign/up/six
	icon_state = "AOPU6"

/obj/effect/turf_decal/snowdin_station_sign/up/seven
	icon_state = "AOPU7"


