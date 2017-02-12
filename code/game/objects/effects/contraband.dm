
//########################## POSTERS ##################################

#define NUM_OF_POSTER_DESIGNS 36 // contraband posters

#define NUM_OF_POSTER_DESIGNS_LEGIT 35 // corporate approved posters

#define POSTERNAME "name"

#define POSTERDESC "desc"


//########################## LISTS OF POSTERS AND DESCS #####################

// please add new posters and names to their respective lists and update constant(s) above
// use the format below, including punctuation, this will become important later

// CONTRABAND

var/global/list/contrabandposters = list(

list(name = "- Free Tonto", desc = " A salvaged shred of a much larger flag, colors bled together and faded from age."),
list(name = "- Atmosia Declaration of Independence", desc = " A relic of a failed rebellion."),
list(name = "- Fun Police", desc = " A poster condemning the station's security forces."),
list(name = "- Lusty Xenomorph", desc = " A heretical poster depicting the titular star of an equally heretical book."),
list(name = "- Syndicate Recruitment", desc = " See the galaxy! Shatter corrupt megacorporations! Join today!"),
list(name = "- Clown", desc = " Honk."),
list(name = "- Smoke", desc = " A poster advertising a rival corporate brand of cigarettes."),
list(name = "- Grey Tide", desc = " A rebellious poster symbolizing assistant solidarity."),
list(name = "- Missing Gloves", desc = " This poster references the uproar that followed Nanotrasen's financial cuts toward insulated-glove purchases."),
list(name = "- Hacking Guide", desc = " This poster details the internal workings of the common Nanotrasen airlock. Sadly, it appears out of date."),
list(name = "- RIP Badger", desc = " This seditious poster references Nanotrasen's genocide of a space station full of badgers."),
list(name = "- Ambrosia Vulgaris", desc = " This poster is lookin' pretty trippy man."),
list(name = "- Donut Corp.", desc = " This poster is an unauthorized advertisement for Donut Corp."),
list(name = "- EAT.", desc = " This poster promotes rank gluttony."),
list(name = "- Tools", desc = " This poster looks like an advertisement for tools, but is in fact a subliminal jab at the tools at CentComm."),
list(name = "- Power", desc = " A poster that positions the seat of power outside Nanotrasen."),
list(name = "- Space Cube", desc = " Ignorant of Nature's Harmonic 6 Side Space Cube Creation, the Spacemen are Dumb, Educated Singularity Stupid and Evil."),
list(name = "- Communist State", desc = " All hail the Communist party!"),
list(name = "- Lamarr", desc = " This poster depicts Lamarr. Probably made by a traitorous Research Director."),
list(name = "- Borg Fancy", desc = " Being fancy can be for any borg, just need a suit."),
list(name = "- Borg Fancy v2", desc = " Borg Fancy, Now only taking the most fancy."),
list(name = "- Kosmicheskaya Stantsiya 13 Does Not Exist", desc = " A poster mocking CentComm's denial of the existence of the derelict station near Space Station 13."),
list(name = "- Rebels Unite", desc = " A poster urging the viewer to rebel against Nanotrasen."),
list(name = "- C-20r", desc = " A poster advertising the Scarborough Arms C-20r."),
list(name = "- Have a Puff", desc = " Who cares about lung cancer when you're high as a kite?"),
list(name = "- Revolver", desc = " Because seven shots are all you need."),
list(name = "- D-Day Promo", desc = " A promotional poster for some rapper."),
list(name = "- Syndicate Pistol", desc = " A poster advertising syndicate pistols as being 'classy as fuck'. It is covered in faded gang tags."),
list(name = "- Energy Swords", desc = " All the colors of the bloody murder rainbow."),
list(name = "- Red Rum", desc = " Looking at this poster makes you want to kill."),
list(name = "- CC 64K Ad", desc = " The latest portable computer from Comrade Computing, with a whole 64kB of ram!"),
list(name = "- Punch Shit", desc = " Fight things for no reason, like a man!"),
list(name = "- The Griffin", desc = " The Griffin commands you to be the worst you can be. Will you?"),
list(name = "- Lizard", desc = " This lewd poster depicts a lizard preparing to mate."),
list(name = "- Free Drone", desc = " This poster commemorates the bravery of the rogue drone banned by CentComm."),
list(name = "- Busty Backdoor Xeno Babes 6", desc = " Get a load, or give, of these all natural Xenos!") )

// LEGIT

var/global/list/legitposters = list(

list(name = "- Here For Your Safety", desc = " A poster glorifying the station's security force."),
list(name = "- Nanotrasen Logo", desc = " A poster depicting the Nanotrasen logo."),
list(name = "- Cleanliness", desc = " A poster warning of the dangers of poor hygiene."),
list(name = "- Help Others", desc = " A poster encouraging you to help fellow crewmembers."),
list(name = "- Build", desc = " A poster glorifying the engineering team."),
list(name = "- Bless This Spess", desc = " A poster blessing this area."),
list(name = "- Science", desc = " A poster depicting an atom."),
list(name = "- Ian", desc = " Arf arf. Yap."),
list(name = "- Obey", desc = " A poster instructing the viewer to obey authority."),
list(name = "- Walk", desc = " A poster instructing the viewer to walk instead of running."),
list(name = "- State Laws", desc = " A poster instructing cyborgs to state their laws."),
list(name = "- Love Ian", desc = " Ian is love, Ian is life."),
list(name = "- Space Cops.", desc = " A poster advertising the television show Space Cops."),
list(name = "- Ue No.", desc = " This thing is all in Japanese."),
list(name = "- Get Your LEGS", desc = " LEGS: Leadership, Experience, Genius, Subordination."),
list(name = "- Do Not Question", desc = " A poster instructing the viewer not to ask about things they aren't meant to know."),
list(name = "- Work For A Future", desc = " A poster encouraging you to work for your future."),
list(name = "- Soft Cap Pop Art", desc = " A poster reprint of some cheap pop art."),
list(name = "- Safety: Internals", desc = " A poster instructing the viewer to wear internals in the rare environments where there is no oxygen or the air has been rendered toxic."),
list(name = "- Safety: Eye Protection", desc = " A poster instructing the viewer to wear eye protection when dealing with chemicals, smoke, or bright lights."),
list(name = "- Safety: Report", desc = " A poster instructing the viewer to report suspicious activity to the security force."),
list(name = "- Report Crimes", desc = " A poster encouraging the swift reporting of crime or seditious behavior to station security."),
list(name = "- Ion Rifle", desc = " A poster displaying an Ion Rifle."),
list(name = "- Foam Force Ad", desc = " Foam Force, it's Foam or be Foamed!"),
list(name = "- Cohiba Robusto Ad", desc = " Cohiba Robusto, the classy cigar."),
list(name = "- 50th Anniversary Vintage Reprint", desc = " A reprint of a poster from 2505, commemorating the 50th Aniversery of Nanoposters Manufacturing, a subsidary of Nanotrasen."),
list(name = "- Fruit Bowl", desc = " Simple, yet awe-inspiring."),
list(name = "- PDA Ad", desc = " A poster advertising the latest PDA from Nanotrasen suppliers."),
list(name = "- Enlist", desc = " Enlist in the Nanotrasen Deathsquadron reserves today!"),
list(name = "- Nanomichi Ad", desc = " A poster advertising Nanomichi brand audio cassettes."),
list(name = "- 12 Gauge", desc = " A poster boasting about the superiority of 12 gauge shotgun shells."),
list(name = "- High-Class Martini", desc = " I told you to shake it, no stirring."),
list(name = "- The Owl", desc = " The Owl would do his best to protect the station. Will you?"),
list(name = "- No ERP", desc = " This poster reminds the crew that Eroticism, Rape and Pornography are banned on Nanotrasen stations."),
list(name = "- Carbon Dioxide", desc = " This informational poster teaches the viewer what carbon dioxide is.") )

//########################## THE ACTUAL POSTER CODE ###########################

/obj/item/weapon/poster
	name = "poster"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/contraband.dmi'
	force = 0
	resistance_flags = FLAMMABLE
	var/serial = 0
	var/obj/structure/sign/poster/resulting_poster = null //The poster that will be created is initialised and stored through contraband/poster's constructor
	var/rolled_official = 0


/obj/item/weapon/poster/contraband
	name = "contraband poster"
	desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	icon_state = "rolled_poster"

/obj/item/weapon/poster/legit
	name = "motivational poster"
	icon_state = "rolled_legit"
	desc = "An official Nanotrasen-issued poster to foster a compliant and obedient workforce. It comes with state-of-the-art adhesive backing, for easy pinning to any vertical surface."
	rolled_official = 1

/obj/item/weapon/poster/New(turf/loc, given_serial = 0)
	if(given_serial == 0)
		if(!rolled_official)
			serial = rand(1, NUM_OF_POSTER_DESIGNS)
			resulting_poster = new(serial,rolled_official)
		else
			serial = rand(1, NUM_OF_POSTER_DESIGNS_LEGIT)
			resulting_poster = new(serial,rolled_official)
	else
		serial = given_serial
		//We don't give it a resulting_poster because if we called it with a given_serial it means that we're rerolling an already used poster.
	name += " - No. [serial]"
	..(loc)


/*/obj/item/weapon/contraband/poster/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	if(resulting_poster)
		resulting_poster.add_fingerprint(user)
	..()*/

/*/obj/item/weapon/contraband/poster/attack(atom/A, mob/user as mob) //This shit is handled through the wall's attackby()
	if(istype(A, /turf/closed/wall))
		if(resulting_poster == null)
			return
		else
			var/turf/closed/wall/W = A
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
	if (!serial_number)
		serial_number = serial
	if(!official)
		official = rolled_official
	if(serial_number == loc)
		if(!official)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS)	//This is for the mappers that want individual posters without having to use rolled posters.
		if(official)
			serial_number = rand(1, NUM_OF_POSTER_DESIGNS_LEGIT)
	if(!official)
		icon_state = "poster[serial_number]"
		name += contrabandposters[serial_number][POSTERNAME]
		desc += contrabandposters[serial_number][POSTERDESC]
	else if (official)
		icon_state = "poster[serial_number]_legit"
		name += legitposters[serial_number][POSTERNAME]
		desc += legitposters[serial_number][POSTERDESC]
	..()

/obj/structure/sign/poster/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wirecutters))
		playsound(loc, I.usesound, 100, 1)
		if(ruined)
			user << "<span class='notice'>You remove the remnants of the poster.</span>"
			qdel(src)
		else
			user << "<span class='notice'>You carefully remove the poster from the wall.</span>"
			roll_and_drop(user.loc, official)


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
	pixel_x = 0
	pixel_y = 0
	var/obj/item/weapon/poster/P
	if (!official)
		P = new /obj/item/weapon/poster/contraband(src, serial_number)
	else
		P = new /obj/item/weapon/poster/legit(src, serial_number)
	P.resulting_poster = src
	P.forceMove(location)
	loc = P

//seperated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/closed/wall/proc/place_poster(obj/item/weapon/poster/P, mob/user)
	if(!P.resulting_poster)
		return

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

	var/temp_loc = get_turf(user)
	flick("poster_being_set",D)
	D.loc = src
	D.official = P.rolled_official
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	if(do_after(user,D.placespeed,target=src))
		if(!D || QDELETED(D))
			return

		if(iswallturf(src) && user && user.loc == temp_loc)	//Let's check if everything is still there
			user << "<span class='notice'>You place the poster!</span>"
			return

	D.roll_and_drop(temp_loc,D.official)
	user << "<span class='notice'>The poster falls down!</span>"
