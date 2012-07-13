
//########################## CONTRABAND ;3333333333333333333 -Agouri ###################################################

#define NUM_OF_POSTER_DESIGNS 27
#define BS12_POSTERS_START 18

/obj/item/weapon/contraband
	name = "contraband item"
	desc = "You probably shouldn't be holding this."
	icon = 'contraband.dmi'
	force = 0


/obj/item/weapon/contraband/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as Contraband aboard Nanotrasen© Space Facilities."
	icon_state = "rolled_poster"
	var/serial_number = 0
	var/obj/effect/decal/poster/resulting_poster = null //The poster that will be created is initialised and stored through contraband/poster's constructor


/obj/item/weapon/contraband/poster/New(turf/loc,var/given_serial=0)
	if(given_serial==0)
		//add an increased chance for BS12 specific posters to spawn
		if(prob(10))
			serial_number = rand(BS12_POSTERS_START,NUM_OF_POSTER_DESIGNS)
		else
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
	icon = 'contraband.dmi'
	anchored = 1
	var/serial_number //Will hold the value of src.loc if nobody initialises it
	var/ruined = 0


obj/effect/decal/poster/New(var/serial)

	src.serial_number = serial

	restart_proc:
	if(serial_number==src.loc)
		//add an increased chance for BS12 specific posters to spawn
		if(prob(10))
			serial_number = rand(BS12_POSTERS_START,NUM_OF_POSTER_DESIGNS)
		else
			serial_number = rand(1,NUM_OF_POSTER_DESIGNS)

	icon_state = "poster[serial_number]"

	//This is for the mappers that want individual posters without having to use rolled posters.
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

		//bs12 specific posters
		if(18)
			name += " - Pinup Girl Val"		//art thou incensed, brethren?
			desc += " Luscious Val McNeil, the vertically challenged Legal Extraordinaire, winner of Miss Space two years running and favoured pinup girl of Lawyers Weekly."
		if(19)
			name += " - Derpman, Enforcer of the State"
			desc += " Here to protect and serve... your donuts! A generously proportioned man, he teaches you the value of hiding your snacks."
		if(20)
			name += " - Tajaran Today, Special #222"
			desc += " A controversial front page pinup from NTFashion, banned on numerous stations for its unreasonably cute depictions."
		if(21)
			name += " - Respect a Soghun"
			desc += " This poster depicts a well dressed looking Soghun receiving a prestigious award. It appears to espouse greater co-operation and harmony between the two races."
		if(22)
			name += " - Skrell Twilight"
			desc += " This poster depicts a mysteriously inscrutable, alien scene. Numerous Skrell can be seen conversing amidst great, crystalline towers rising above crashing waves"
		if(23)
			name += " - Join the Fuzz!"
			desc += " It's a nice recruitment poster of a white haired Chinese woman that says; \"Big Guns, Hot Women, Good Times. Security. We get it done.\""
		if(24)
			name += " - Looking for a career with excitement?"
			desc += " A recruitment poster starring a dark haired woman with glasses and a purple shirt that has \"Got Brains? Got Talent? Not afraid of electric flying monsters that want to suck the soul out of you? Then Xenobiology could use someone like you!\" written on the bottom."
		if(25)
			name += " - Safety first: because electricity doesn't wait!"
			desc += " A safety poster starring a clueless looking redhead with frazzled hair. \"Every year, hundreds of NT employees expose themselves to electric shock. Play it safe. Avoid suspicious doors after electrical storms, and always wear protection when doing electric maintenance.\""
		if(26)
			name += " - Responsible medbay habits, No #259"
			desc += " A poster with a nervous looking geneticist on it states; \"Friends Don't Tell Friends They're Clones. It can cause severe and irreparable emotional trauma. Always do the right thing and never tell them that they were dead.\""
		if(27)
			name += " - Irresponsible medbay habits, No #2"
			desc += " This is a safety poster starring a perverted looking naked doctor. \"Sexual harassment is never okay. REPORT any acts of sexual deviance or harassment that disrupt a healthy working environment.\""
		/*if(20)
			name += " - the Disabled Triptarch: Ironfoot, Seber and Ore"
			desc += " This poster depicts a genetics researcher, a chemist and a medical doctor in various states of miscommunication."*/
		else
			//properly handle unhinged logic states
			src.serial_number = src.loc
			goto restart_proc
	..()

obj/effect/decal/poster/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if( istype(W, /obj/item/weapon/wirecutters) )
		playsound(src.loc, 'Wirecutter.ogg', 100, 1)
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
				playsound(src.loc, 'poster_ripped.ogg', 100, 1)
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
	playsound(D.loc, 'poster_being_created.ogg', 100, 1)

	sleep(17)
	if(!D)	return

	if(istype(src,/turf/simulated/wall) && user && user.loc == temp_loc)//Let's check if everything is still there
		user << "<span class='notice'>You place the poster!</span>"
	else
		D.roll_and_drop(temp_loc)
	return