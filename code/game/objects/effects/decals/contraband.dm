
//########################## CONTRABAND ;3333333333333333333 -Agouri ###################################################

#define NUM_OF_POSTER_DESIGNS 17

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
	var/obj/effect/decal/poster/resulting_poster = null //The poster that will be created is initialised and stored through contraband/poster's constructor


/obj/item/weapon/contraband/poster/New(turf/loc,var/given_serial=0)
	if(given_serial==0)
		serial_number = rand(1,NUM_OF_POSTER_DESIGNS)
		src.resulting_poster = new(serial_number)
	else
		serial_number = given_serial
		//We don't give it a resulting_poster because if we called it with a given_serial it means that we're rerolling an already used poster.
	src.name += " - No. [serial_number]"
	..(loc)


/*/obj/item/weapon/contraband/poster/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	if(src.resulting_poster)
		src.resulting_poster.add_fingerprint(user)
	..()*/

/*/obj/item/weapon/contraband/poster/attack(atom/A, mob/user as mob) //This shit is handled through the wall's attackby()
	if (istype(A, /turf/simulated/wall))
		if(src.resulting_poster == null)
			return
		else
			var/turf/simulated/wall/W = A
			var/check = 0
			var/stuff_on_wall = 0
			for( var/obj/O in W.contents) //Let's see if it already has a poster on it or too much stuff
				if(istype(O,/obj/effect/decal/poster))
					check = 1
					break
				stuff_on_wall++
				if(stuff_on_wall==3)
					check = 1
					break

			if(check)
				user << "<FONT COLOR='RED'>The wall is far too cluttered to place a poster!</FONT>"
				return

			src.resulting_poster.loc = W //Looks like it's uncluttered enough. Place the poster
			W.contents += src.resulting_poster

			del(src)*/



//############################## THE ACTUAL DECALS ###########################

obj/effect/decal/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper. It's considered contraband."
	icon = 'icons/obj/contraband.dmi'
	anchored = 1
	var/serial_number //Will hold the value of src.loc if nobody initialises it
	var/ruined = 0


obj/effect/decal/poster/New(var/serial)

	src.serial_number = serial

	if(serial_number==src.loc){serial_number = rand(1,NUM_OF_POSTER_DESIGNS);} //This is for the mappers that want individual posters without having to use rolled posters.

	icon_state = "poster[serial_number]"

	switch(serial_number)
		if(1)
			name += " - Unlucky Space Explorer"
			desc += " This particular one depicts a skeletal form within a space suit."
		if(2)
			name += " - Positronic Logic Conflicts"
			desc += " This particular one depicts the cold, unmoving stare of a particular advanced AI."
		if(3)
			name += " - Paranoia"
			desc += " This particular one warns of the dangers of trusting your co-workers too much."
		if(4)
			name += " - Keep Calm"
			desc += " This particular one is of a famous New Earth design, although a bit modified."
		if(5)
			name += " - Martian Warlord"
			desc += " This particular one depicts the cartoony mug of a certain Martial Warmonger."
		if(6)
			name += " - Technological Singularity"
			desc += " This particular one is of the blood-curdling symbol of a long-since defeated enemy of humanity."
		if(7)
			name += " - Wasteland"
			desc += " This particular one is of a couple of ragged gunmen, one male and one female, on top of a mound of rubble. The number \"13\" is visible on their blue jumpsuits."
		if(8)
			name += " - Pinup Girl Cindy"
			desc += " This particular one is of Nanotrasen's PR girl, Cindy, in a particularly feminine pose."
		if(9)
			name += " - Pinup Girl Amy"
			desc += " This particular one is of Amy, the nymphomaniac Urban Legend of Nanotrasen Space Stations. How this photograph came to be is not known."
		if(10)
			name += " - Don't Panic"
			desc += " This particular one depicts some sort of star in a grimace. The \"Don't Panic\" is written in big, friendly letters."
		if(11)
			name += " - Underwater Laboratory"
			desc += " This particular one is of the fabled last crew of Nanotrasen's previous project before going big on Asteroid mining, Sealab."
		if(12)
			name += " - Missing Gloves"
			desc += " This particular one is about the uproar that followed Nanotrasen's financial cuts towards insulated-glove purchases."
		if(13)
			name += " - Rogue AI"
			desc += " This particular one depicts the shell of the infamous AI that catastropically comandeered one of Nanotrasen's earliest space stations. Back then, the corporation was just known as TriOptimum."
		if(14)
			name += " - User of the Arcane Arts"
			desc += " This particular one depicts a wizard, casting a spell. You can't really make out if it's an actial photograph or a computer-generated image."
		if(15)
			name += " - Levitating Skull"
			desc += " This particular one is the portrait of a certain flying, friendly and somewhat sex-crazed enchanted skull. Its adventures along with its fabled companion are now fading through history..."
		if(16)
			name += " - Augmented Legend"
			desc += " This particular one is of an obviously augmented individual, gazing towards the sky. The cyber-city in the backround is rather punkish."
		if(17)
			name += " - Dangerous Static"
			desc += " This particular one depicts nothing remarkable other than a rather mesmerising pattern of monitor static. There's a tag on the sides of the poster, urging you to \"tear this poster in half to receive your free sample\"."
		else
			name = "This shit just bugged. Report it to Agouri - polyxenitopalidou@gmail.com"
			desc = "Why are you still here?"
	..()

obj/effect/decal/poster/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if( istype(W, /obj/item/weapon/wirecutters) )
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		if(src.ruined)
			user << "<FONT COLOR='BLUE'>You remove the remnants of the poster.</FONT>"
			del(src)
		else
			user << "<FONT COLOR='BLUE'>You carefully remove the poster from the wall.</FONT>"
			src.roll_and_drop(user.loc)
		return


/obj/effect/decal/poster/attack_hand(mob/user as mob)
	if(src.ruined)
		return
	var/temp_loc = user.loc
	switch(alert("Do I want to rip the poster from the wall?","You think...","Yes","No"))
		if("Yes")
			if(user.loc != temp_loc)
				return
			for (var/mob/O in hearers(5, src.loc))
				O.show_message("<FONT COLOR='RED'>[user.name] rips the [src.name] in a single, decisive motion!</FONT>" )
				playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
				src.ruined = 1
				src.icon_state = "poster_ripped"
				src.name = "Ripped poster"
				src.desc = "You can't make out anything from the poster's original print. It's ruined."
				src.add_fingerprint(user)
		if("No")
			return

/obj/effect/decal/poster/proc/roll_and_drop(turf/loc)
	var/obj/item/weapon/contraband/poster/P = new(src,src.serial_number)
	P.resulting_poster = src
	P.loc = loc
	src.loc = P


//seperated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_poster(var/obj/item/weapon/contraband/poster/P, var/mob/user)
	if(!P.resulting_poster)	return

	var/stuff_on_wall = 0
	for( var/obj/O in src.contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O,/obj/effect/decal/poster))
			user << "<span class='warning'>The wall is far too cluttered to place a poster!</span>"
			return
		stuff_on_wall++
		if(stuff_on_wall==3)
			user << "<span class='warning'>The wall is far too cluttered to place a poster!</span>"
			return

	user << "<span class='notice'>You start placing the poster on the wall...</span>" //Looks like it's uncluttered enough. Place the poster.

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/effect/decal/poster/D = P.resulting_poster

	var/temp_loc = user.loc
	flick("poster_being_set",D)
	D.loc = src
	del(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	sleep(17)
	if(!D)	return

	if(istype(src,/turf/simulated/wall) && user && user.loc == temp_loc)//Let's check if everything is still there
		user << "<span class='notice'>You place the poster!</span>"
	else
		D.roll_and_drop(temp_loc)
	return