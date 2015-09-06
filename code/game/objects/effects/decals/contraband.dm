
//########################## POSTERS ##################################

#define NUM_OF_POSTER_DESIGNS 34 // contraband posters

#define NUM_OF_POSTER_DESIGNS_LEGIT 34 // corporate approved posters


//########################## THE LIST OF POSTERS AND DESCS #####################

// please add new posters and names to their respective lists and update constant(s) above

// CONTRABAND

var/global/list/posternames = list(
"- Free Tonto",
"- Atmosia Declaration of Independence",
"- Fun Police",
"- Lusty Xenomorph",
"- Syndicate Recruitment",
"- Clown",
"- Smoke",
"- Grey Tide",
"- Missing Gloves",
"- Hacking Guide",
"- RIP Badger",
"- Ambrosia Vulgaris",
"- Donut Corp.",
"- EAT",
"- Tools",
"- Power",
"- Power to the People",
"- Communist State",
"- Lamarr",
"- Borg Fancy",
"- Borg Fancy v2",
"- Kosmicheskaya Stantsiya 13 Does Not Exist",
"- Rebels Unite",
"- C-20r",
"- Have a Puff",
"- Revolver",
"- D-Day Promo",
"- Syndicate Pistol",
"- Energy Swords",
"- Red Rum",
"- CC 64K Ad",
"- Punch Shit",
"- The Griffin",
"- Free Drone" )

var/global/list/posterdescs = list(
" A salvaged shred of a much larger flag, colors bled together and faded from age.",
" A relic of a failed rebellion.",
" A poster condemning the station's security forces.",
" A heretical poster depicting the titular star of an equally heretical book.",
" See the galaxy! Shatter corrupt megacorporations! Join today!",
" Honk.",
" A poster advertising a rival corporate brand of cigarettes.",
" A rebellious poster symbolizing assistant solidarity.",
" This poster references the uproar that followed Nanotrasen's financial cuts toward insulated-glove purchases.",
" This poster details the internal workings of the common Nanotrasen airlock. Sadly, it appears out of date.",
" This seditious poster references Nanotrasen's genocide of a space station full of badgers.",
" This poster is lookin' pretty trippy man.",
" This poster is an advertisement for Donut Corp.",
" This poster is advising rank gluttony.",
" This poster looks like an advertisement for tools, but is in fact a subliminal jab at the tools at CentComm.",
" A poster that positions the seat of power outside Nanotrasen.",
" Screw those EDF guys!",
" All hail the Communist party!",
" This poster depicts Lamarr. Probably made by a traitorous Research Director.",
" Being fancy can be for any borg, just need a suit.",
" Borg Fancy, Now only taking the most fancy.",
" A poster mocking CentComm's denial of the existence of the derelict station near Space Station 13.",
" A poster telling the viewer to rebel against Nanotrasen.",
" A poster advertising the Scarborough Arms C-20r.",
" Who cares about lung cancer when you're high as a kite?",
" Because seven shots are all you need.",
" A promotional poster for some rapper.",
" A poster advertising syndicate pistols as being 'classy as fuck'. It is covered in faded gang tags.",
" All the colors of the bloody murder rainbow.",,
" Looking at this poster makes you want to kill.",
" The latest portable computer from Comrade Computing, with a whole 64kB of ram!",
" Fight things for no reason, like a man!",
" The Griffin commands you to be the worst you can be. Will you?",
" This poster commemorates the bravery of the rogue drone banned by CentComm." )

// LEGIT

var/global/list/legitposternames = list(

"- Here For Your Safety",
"- Nanotrasen Logo",
"- Cleanliness",
"- Help Others",
"- Build",
"- Bless This Spess",
"- Science",
"- Ian",
"- Obey",
"- Walk",
"- State Laws",
"- Love Ian",
"- Space Cops",
"- Ue No",
"- Get Your LEGS",
"- Do Not Question",
"- Work For a Future",
"- Soft Cap Pop Art",
"- Safety: Internals",
"- Safety: Eye Protection",
"- Safety: Report",
"- Report Crimes", // WHY ARE THERE TWO OF THESE
"- Ion Rifle",
"- Foam Force Ad",
"- Cohiba Robusto Ad",
"- 50th Anniversary Vintage Reprint",
"- Fruit Bowl",
"- ThinkTronic PDA 6000 Ad",
"- Enlist",
"- Nanomichi Ad",
"- 12 Gauge",
"- High-Class Martini",
"- The Owl",
"- Carbon Dioxide" )

var/global/list/legitposterdescs = list(
" A poster glorifying the station's security force.",
" A poster depicting the Nanotrasen logo.",
" A poster warning of the dangers of poor hygiene.",
" A poster encouraging you to help fellow crewmembers.",
" A poster glorifying the engineering team.",
" A poster blessing this area.",
" A poster depicting an atom.",
" Arf Arf.",
" A poster instructing the viewer to obey authority.",
" A poster instructing the viewer to walk instead of running.",
" A poster instructing cyborgs to state their laws.",
" Ian is love, Ian is life.",
" A poster advertising the television show Space Cops.",
" This thing is all in Japanese.",
" LEGS: Leadership, Experience, Genius, Subordination.",
" A poster instructing the viewer not to ask about things they aren't meant to know.",
" A poster encouraging you to work for your future.",
" A poster reprint of some cheap pop art.",
" A poster instructing the viewer to wear internals in the rare environments where there is no oxygen or the air has been rendered toxic.",
" A poster instructing the viewer to wear eye protection when dealing with chemicals, smoke, or bright lights.",
" A poster instructing the viewer to report suspicious activity to the security force.",
" A poster encouraging the swift reporting of crime or seditious behavior to station security.", // seriously
" A poster displaying an Ion Rifle.",
" Foam Force, it's Foam or be Foamed!",
" Cohiba Robusto, the classy cigar.",
" A reprint of a poster from 2505, commemorating the 50th Aniversery of Nanoposters Manufacturing, a subsidary of Nanotrasen.",
" Simple, yet awe inspiring.",
" A poster advertising the latest PDA from Nanotrasen suppliers.",
" Enlist in the Nanotrasen Deathsquadron reserves today!",
" A poster advertising Nanomichi brand audio cassettes.",
" A poster boasting about the superiority of 12 gauge shotgun shells.",
" I told you to shake it, no stirring.",
" The Owl would do his best to protect the station. Will you?",
" This informational poster teaches the viewer about carbon dioxide." )

//########################## THE ACTUAL POSTER CODE ###########################

/obj/item/weapon/poster
	name = "poster"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/contraband.dmi'
	force = 0
	burn_state = 0 //Burnable
	var/serial_number = 0
	var/obj/structure/sign/poster/resulting_poster = null //The poster that will be created is initialised and stored through contraband/poster's constructor
	var/official = 0


/obj/item/weapon/poster/contraband
	name = "contraband poster"
	desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	icon_state = "rolled_poster"

/obj/item/weapon/poster/legit
	name = "motivational poster"
	icon_state = "rolled_legit"
	desc = "An official Nanotrasen-issued poster to foster a compliant and obedient workforce. It comes with state-of-the-art adhesive backing, for easy pinning to any vertical surface."
	official = 1

/obj/item/weapon/poster/New(turf/loc, given_serial = 0)
	if(given_serial == 0)
		if(!official)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS)
			resulting_poster = new(serial_number,official)
		else
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS_LEGIT)
			resulting_poster = new(serial_number,official)
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
	var/official = 0
	var/placespeed = 37 // don't change this, otherwise the animation will not sync to the progress bar

/obj/structure/sign/poster/New(serial,rolled_official)
	serial_number = serial
	official = rolled_official
	if(serial_number == loc)
		if(!official)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS)	//This is for the mappers that want individual posters without having to use rolled posters.
		if(official)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS_LEGIT)
	if(!official)
		icon_state = "poster[serial_number]"
		name += posternames[serial_number]
		desc += posterdescs[serial_number]
	else if (official)
		icon_state = "poster[serial_number]_legit"
		name += legitposternames[serial_number]
		desc += legitposterdescs[serial_number]
	..()

/obj/structure/sign/poster/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wirecutters))
		playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
		if(ruined)
			user << "<span class='notice'>You remove the remnants of the poster.</span>"
			qdel(src)
		else
			user << "<span class='notice'>You carefully remove the poster from the wall.</span>"
			roll_and_drop(user.loc, official)
		return


/obj/structure/sign/poster/attack_hand(mob/user)
	if(ruined)
		return
	var/temp_loc = user.loc
	if((user.loc != temp_loc) || ruined )
		return
	visible_message("[user] rips [src] in a single, decisive motion!" )
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
	ruined = 1
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."
	add_fingerprint(user)

/obj/structure/sign/poster/proc/roll_and_drop(turf/location, official)
	if (!official)
		var/obj/item/weapon/poster/contraband/P = new(src, serial_number)
		P.resulting_poster = src
		P.loc = location
		loc = P
	else
		var/obj/item/weapon/poster/legit/P = new(src, serial_number)
		P.resulting_poster = src
		P.loc = location
		loc = P


//seperated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_poster(obj/item/weapon/poster/P, mob/user)
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
	D.official = P.official
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	if(do_after(user,D.placespeed,target=src))
		if(!D)	return

		if(istype(src,/turf/simulated/wall) && user && user.loc == temp_loc)	//Let's check if everything is still there
			user << "<span class='notice'>You place the poster!</span>"
		else
			D.roll_and_drop(temp_loc,D.official)
		return
