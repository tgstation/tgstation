
//########################## CONTRABAND ;3333333333333333333 -Agouri ###################################################

#define NUM_OF_POSTER_DESIGNS 11

/obj/item/weapon/contraband
	name = "contraband item"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/contraband.dmi'
	force = 0


/obj/item/weapon/contraband/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as Contraband aboard Nanotrasen© Space Facilities."
	icon_state = "rolled_poster"
	var/serial_number = 0
	var/obj/structure/sign/poster/resulting_poster = null //The poster that will be created is initialised and stored through contraband/poster's constructor


/obj/item/weapon/contraband/poster/New(turf/loc, given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, NUM_OF_POSTER_DESIGNS)
		resulting_poster = new(serial_number)
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

			del(src)*/



//############################## THE ACTUAL DECALS ###########################

obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper. It's considered contraband."
	icon = 'icons/obj/contraband.dmi'
	anchored = 1
	var/serial_number	//Will hold the value of src.loc if nobody initialises it
	var/ruined = 0


obj/structure/sign/poster/New(serial)
	serial_number = serial

	if(serial_number == loc)
		serial_number = rand(1, NUM_OF_POSTER_DESIGNS)	//This is for the mappers that want individual posters without having to use rolled posters.

	icon_state = "poster[serial_number]"

	switch(serial_number)
		if(1)
			name += " - Free Tonto"
			desc += " A framed shred of a much larger flag, colors bled together and faded from age."
		if(2)
			name += " - Atmosia Declaration of Independence"
			desc += " A relic of a failed rebellion"
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
		else
			name = "This shit just bugged. Report it to Agouri - polyxenitopalidou@gmail.com"
			desc = "Why are you still here?"
	..()

obj/structure/sign/poster/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/wirecutters))
		playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
		if(ruined)
			user << "<span class='notice'>You remove the remnants of the poster.</span>"
			del(src)
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
			if(user.loc != temp_loc)
				return
			visible_message("<span class='warning'>[user] rips [src] in a single, decisive motion!</span>" )
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
			user << "<span class='notice'>The wall is far too cluttered to place a poster!</span>"
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			user << "<span class='notice'>The wall is far too cluttered to place a poster!</span>"
			return

	user << "<span class='notice'>You start placing the poster on the wall...</span>"	//Looks like it's uncluttered enough. Place the poster.

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/structure/sign/poster/D = P.resulting_poster

	var/temp_loc = user.loc
	flick("poster_being_set",D)
	D.loc = src
	del(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	sleep(17)
	if(!D)	return

	if(istype(src,/turf/simulated/wall) && user && user.loc == temp_loc)	//Let's check if everything is still there
		user << "<span class='notice'>You place the poster!</span>"
	else
		D.roll_and_drop(temp_loc)
	return