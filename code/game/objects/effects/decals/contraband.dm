
//########################## CONTRABAND ;3333333333333333333 -Agouri ###################################################

#define NUM_OF_POSTER_DESIGNS 33 //subtype 0-contraband posters

#define NUM_OF_POSTER_DESIGNS_LEGIT 33 //subtype 1-corporate approved posters

/obj/item/weapon/contraband
	name = "contraband item"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/contraband.dmi'
	force = 0


/obj/item/weapon/contraband/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	icon_state = "rolled_poster"
	var/serial_number = 0
	var/obj/structure/sign/poster/resulting_poster = null //The poster that will be created is initialised and stored through contraband/poster's constructor
	var/subtype = 0


/obj/item/weapon/contraband/poster/New(turf/loc, given_serial = 0)
	if(given_serial == 0)
		if(subtype == 0)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS)
			resulting_poster = new(serial_number,subtype)
		if(subtype == 1)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS_LEGIT)
			resulting_poster = new(serial_number,subtype)
	else
		serial_number = given_serial
		//We don't give it a resulting_poster because if we called it with a given_serial it means that we're rerolling an already used poster.
	name += " - No. [serial_number]"
	..(loc)


/*/obj/item/weapon/contraband/poster/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	if(resulting_poster)
		resulting_poster.add_fingerprint(user)
	..()*/

/*/obj/item/weapon/contraband/poster/attack(atom/A, mob/user as mob) //This shit is handled through the wall's attackby()
	if(istype(A, /turf/simulated/wall))
		if(resulting_poster == null)
			return
		else
			var/turf/simulated/wall/W = A
			var/check = 0
			var/stuff_on_wall = 0
			for(var/obj/O in W.contents) //Let's see if it already has a poster on it or too much stuff
				if(istype(O,/obj/structure/sign/poster))
					check = 1
					break
				stuff_on_wall++
				if(stuff_on_wall == 3)
					check = 1
					break

			if(check)
				user << "<span class='notice'>The wall is far too cluttered to place a poster!</span>"
				return

			resulting_poster.loc = W //Looks like it's uncluttered enough. Place the poster
			W.contents += resulting_poster

			qdel(src)*/



//############################## THE ACTUAL DECALS ###########################

/obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper."
	icon = 'icons/obj/contraband.dmi'
	anchored = 1
	var/serial_number	//Will hold the value of src.loc if nobody initialises it
	var/ruined = 0
	var/subtype = 0

/obj/structure/sign/poster/New(serial,subtype)
	serial_number = serial

	if(serial_number == loc)
		if(subtype == 0)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS)	//This is for the mappers that want individual posters without having to use rolled posters.
		if(subtype == 1)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS_LEGIT)
	if(subtype == 0)
		icon_state = "poster[serial_number]"
		switch(serial_number)
			if(1)
				name += " - Free Tonto"
				desc += " A framed shred of a much larger flag, colors bled together and faded from age."
			if(2)
				name += " - Atmosia Declaration of Independence"
				desc += " A relic of a failed rebellion."
			if(3)
				name += " - Fun Police"
				desc += " A poster condemning the station's security forces."
			if(4)
				name += " - Lusty Xeno"
				desc += " A heretical poster depicting the titular star of an equally heretical book."
			if(5)
				name += " - Syndicate Recruitment Poster"
				desc += " See the galaxy! Shatter corrupt megacorporations! Join today!"
			if(6)
				name += " - Clown"
				desc += " Honk."
			if(7)
				name += " - Smoke"
				desc += " A poster depicting a carton of cigarettes."
			if(8)
				name += " - Grey Tide"
				desc += " A rebellious poster symbolizing assistant solidarity."
			if(9)
				name += " - Missing Gloves"
				desc += " This poster is about the uproar that followed Nanotrasen's financial cuts towards insulated-glove purchases."
			if(10)
				name += " - Hacking Guide"
				desc += " This poster details the internal workings of the common Nanotrasen airlock."
			if(11)
				name += " - RIP Badger"
				desc += " This poster commemorates the day hundreds of badgers worldwide were sacrificed for the greater good."
			if(12)
				name += " - Ambrosia Vulgaris"
				desc += " This poster is lookin' pretty trippy man."
			if(13)
				name += " - Donut Corp."
				desc += " This poster is an advertisement for Donut Corp."
			if(14)
				name += " - EAT"
				desc += " This poster is advising that you eat."
			if(15)
				name += " - Tools"
				desc += " This poster is an advertisement for tools."
			if(16)
				name += " - Power"
				desc += " A poster all about power."
			if(17)
				name += " - Power to the People"
				desc += " Screw those EDF guys!"
			if(18)
				name += " - Communist state"
				desc += " All hail the Communist party!"
			if(19)
				name += " - Lamarr"
				desc += " This poster depicts Lamarr. Probably made by the Research Director."
			if(20)
				name += " - Borg Fancy"
				desc += " Being fancy can be for any borg, just need a suit."
			if(21)
				name += " - Borg Fancy v2"
				desc += " Borg Fancy, Now only taking the most fancy."
			if(22)
				name += " - Kosmicheskaya Stantsiya 13 Does Not Exist"
				desc += " A poster denying the existence of the derelict station near Space Station 13."
			if(23)
				name += " - Rebels Unite!"
				desc += " A poster telling the viewer to rebel against Nanotrasen."
			if(24)
				name += " - C-20r Advertisment"
				desc += " A poster advertising the Scarborough Arms C-20r."
			if(25)
				name += " - Have A Puff"
				desc += " Who cares about lung cancer when you're high as a kite?"
			if(26)
				name += " - Revolver Advertisment"
				desc += " Because seven shots are all you need."
			if(27)
				name += " - D-Day Promotional Poster"
				desc += " A promotional poster for some rapper."
			if(28)
				name += " - Syndicate Pistol Advertisment"
				desc += " A poster advertising syndicate pistols as being 'Classy as fuck'."
			if(29)
				name += " - E-sword Rainbow"
				desc += " All the colors of bloody murder rainbow."
			if(30)
				name += " - Red Rum"
				desc += " Looking at this poster makes you want to kill."
			if(31)
				name += " - CC 64K Advertisment"
				desc += " The latest portable computer from Comrade Computing, with a whole 64kB of ram!"
			if(32)
				name += " - Punch Shit"
				desc += " Fight things for no reason, like a man!"
			if(33)
				name += " - The Griffin"
				desc += " The Griffin commands you to be the worst you can be. Will you?"
			else
				name += " - Error (subtype 0 serial_number)"
				desc += " This is a bug, please report the circumstances under which you encountered this poster at https://github.com/tgstation/-tg-station/issues."

	if(subtype == 1)
		icon_state = "poster[serial_number]_legit"
		switch(serial_number)
			if(1)
				name += " - Here for Your Saftey"
				desc += " A poster glorifying the station's security force."
			if(2)
				name += " - Nanotrasen Logo"
				desc += " A poster depicting the logo of Nanotrasen."
			if(3)
				name += " - Cleanliness"
				desc += " A poster warning of the dangers of poor hygiene."
			if(4)
				name += " - Help Others"
				desc += " A poster encouraging you to help fellow crewmembers."
			if(5)
				name += " - Build"
				desc += " A poster glorifying the engineering team."
			if(6)
				name += " - Bless This Spess"
				desc += " A poster blessing this area."
			if(7)
				name += " - Science"
				desc += " A poster depicting an atom."
			if(8)
				name += " - Ian"
				desc += " Arf Arf."
			if(9)
				name += " - Obey"
				desc += " A poster instructing the viewer to obey authority."
			if(10)
				name += " - Walk"
				desc += " A poster instructing the viewer to walk instead of running."
			if(11)
				name += " - State Laws"
				desc += " A poster instructing cyborgs to state their laws."
			if(12)
				name += " - Love Ian"
				desc += " Ian is love, Ian is life."
			if(13)
				name += " - Space Cops"
				desc += " A poster advertising the television show Space Cops."
			if(14)
				name += " - Ue No"
				desc += " This thing is all in Japanese."
			if(15)
				name += " - Get Your LEGS"
				desc += " LEGS: Leadership, Experiance, Genius, S(Opportunity)."
			if(16)
				name += " - Do Not Question"
				desc += " A poster instructing the viewer not to ask about things they aren't meant to know."
			if(17)
				name += " - Work for a Future"
				desc += " A poster encouraging you to work for your future, what it is, no one is really sure."
			if(18)
				name += " - Soft Cap Pop Art"
				desc += " A poster reprint of some cheap pop art."
			if(19)
				name += " - Saftey: Internals"
				desc += " A poster instructing the viewer to wear internals in environments where there is no oxygen or the air has been rendered toxic."
			if(20)
				name += " - Saftey: Eye Protection"
				desc += " A poster instructing the viewer to wear eye protection when dealing with chemicals, smoke, or bright lights."
			if(21)
				name += " - Saftey: Report"
				desc += " A poster instructing the viewer to report suspicious activity to the security force."
			if(22)
				name += " - Report Crimes"
				desc += " Report crimes at: 1-800-FUCKING-TERRORISTS or at https://www.sectorthirteen.nt/malconetents."
			if(23)
				name += " - Ion Rifle"
				desc += " A poster displaying an Ion Rifle."
			if(24)
				name += " - Foam Force Advertisment"
				desc += " Foam Force, it's Foam or be Foamed!"
			if(25)
				name += " - Cohiba Robusto Advertisment"
				desc += " Cohiba Robusto, the classy cigar."
			if(26)
				name += " - 50th Aniversery Vintage Reprint"
				desc += " A reprint of a poster from 2504, commemorating the 50th Aniversery of Nanoposters Manufacturing, a subsidary of Nanotrasen."
			if(27)
				name += " - Fruit Bowl"
				desc += " Simple, yet awe inspiring."
			if(28)
				name += " - NanoPDA 1000 Advertisment"
				desc += " A poster advertising the latest PDA from Nanotrasen."
			if(29)
				name += " - Enlist"
				desc += " Enlist in the Nanotrasen Deathsquadron reserves today!"
			if(30)
				name += " - Nanomichi Advertisment"
				desc += " A poster advertising Nanomichi brand audio cassettes."
			if(31)
				name += " - 12 Gauge"
				desc += " A poster boasting about the superiority of 12 gauge shotgun shells."
			if(32)
				name += " - High-Class Martini"
				desc += " I told you to shake it, no stirring"
			if(33)
				name += " - The Owl"
				desc += " The Owl would do his best to protect the station. Will you?"
			else
				name += " - Error (subtype 1 serial_number)"
				desc += " This is a bug, please report the circumstances under which you encountered this poster at https://github.com/NTStation/NTstation13/issues."
	..()

/obj/structure/sign/poster/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wirecutters))
		playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
		if(ruined)
			user << "<span class='notice'>You remove the remnants of the poster.</span>"
			qdel(src)
		else
			user << "<span class='notice'>You carefully remove the poster from the wall.</span>"
			roll_and_drop(user.loc)
		return


/obj/structure/sign/poster/attack_hand(mob/user)
	if(ruined)
		return
	var/temp_loc = user.loc
	switch(alert("Do I want to rip the poster from the wall?","You think...","Yes","No"))
		if("Yes")
			if( user.loc != temp_loc || ruined )
				return
			visible_message("[user] rips [src] in a single, decisive motion!" )
			playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
			ruined = 1
			icon_state = "poster_ripped"
			name = "ripped poster"
			desc = "You can't make out anything from the poster's original print. It's ruined."
			add_fingerprint(user)
		if("No")
			return

/obj/structure/sign/poster/proc/roll_and_drop(turf/location)
	var/obj/item/weapon/contraband/poster/P = new(src, serial_number)
	P.resulting_poster = src
	P.loc = location
	loc = P


//seperated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_poster(obj/item/weapon/contraband/poster/P, mob/user)
	if(!P.resulting_poster)	return

	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O,/obj/structure/sign/poster))
			user << "<span class='warning'>The wall is far too cluttered to place a poster!</span>"
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			user << "<span class='warning'>The wall is far too cluttered to place a poster!</span>"
			return

	user << "<span class='notice'>You start placing the poster on the wall...</span>"	//Looks like it's uncluttered enough. Place the poster.

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/structure/sign/poster/D = P.resulting_poster

	var/temp_loc = user.loc
	flick("poster_being_set",D)
	D.loc = src
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	sleep(17)
	if(!D)	return

	if(istype(src,/turf/simulated/wall) && user && user.loc == temp_loc)	//Let's check if everything is still there
		user << "<span class='notice'>You place the poster!</span>"
	else
		D.roll_and_drop(temp_loc)
	return

//Putting non-contraband posters here because everything else here is related to posters anyway. -JS

/obj/item/weapon/contraband/poster/legit
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. It's contents go through Nanotrasen's strict content guidlines."
	icon_state = "rolled_poster_legit"
	subtype = 1
