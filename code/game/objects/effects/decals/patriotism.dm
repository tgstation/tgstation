
//########################## NOW 200% MORE OFFENSIVE ###################################################

#define NUM_OF_FLAG_DESIGNS 5 //subtype 0-contraband flags

#define NUM_OF_FLAG_DESIGNS_LEGIT 10 //subtype 1-corporate approved flags

/obj/item/weapon/patriotism
	name = "contraband flag"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/patriotism.dmi'
	force = 0


/obj/item/weapon/patriotism/flag
	name = "folded flag"
	desc = "The flag comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its controversal nature has made it contraband aboard Nanotrasen space facilities."
	icon_state = "folded_flag"
	var/serial_number = 0
	var/obj/structure/sign/flag/resulting_flag = null //The flag that will be created is initialised and stored through contraband/flag's constructor
	var/subtype = 0


/obj/item/weapon/patriotism/flag/New(turf/loc, given_serial = 0)
	if(given_serial == 0)
		if(subtype == 0)
			serial_number = rand(1, NUM_OF_FLAG_DESIGNS)
			resulting_flag = new(serial_number,subtype)
		if(subtype == 1)
			serial_number = rand(1, NUM_OF_FLAG_DESIGNS_LEGIT)
			resulting_flag = new(serial_number,subtype)
	else
		serial_number = given_serial
		//We don't give it a resulting_flag because if we called it with a given_serial it means that we're rerolling an already used flag.
	name += " - No. [serial_number]"
	..(loc)


/*/obj/item/weapon/patriotism/flag/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	if(resulting_flag)
		resulting_flag.add_fingerprint(user)
	..()*/

/*/obj/item/weapon/patriotism/flag/attack(atom/A, mob/user as mob) //This shit is handled through the wall's attackby()
	if(istype(A, /turf/simulated/wall))
		if(resulting_flag == null)
			return
		else
			var/turf/simulated/wall/W = A
			var/check = 0
			var/stuff_on_wall = 0
			for(var/obj/O in W.contents) //Let's see if it already has a flag on it or too much stuff
				if(istype(O,/obj/structure/sign/flag))
					check = 1
					break
				stuff_on_wall++
				if(stuff_on_wall == 3)
					check = 1
					break

			if(check)
				user << "<span class='notice'>The wall is far too cluttered to place a flag!</span>"
				return

			resulting_flag.loc = W //Looks like it's uncluttered enough. Place the flag
			W.contents += resulting_flag

			qdel(src)*/



//############################## THE ACTUAL DECALS ###########################

obj/structure/sign/flag
	name = "flag"
	desc = "A large piece of space-resistant printed cloth."
	icon = 'icons/obj/patriotism.dmi'
	anchored = 1
	var/serial_number	//Will hold the value of src.loc if nobody initialises it
	var/ruined = 0
	var/subtype = 0

obj/structure/sign/flag/New(serial,subtype)
	serial_number = serial

	if(serial_number == loc)
		if(subtype == 0)
			serial_number = rand(1, NUM_OF_FLAG_DESIGNS)	//This is for the mappers that want individual flags without having to use rolled flags.
		if(subtype == 1)
			serial_number = rand(1, NUM_OF_FLAG_DESIGNS_LEGIT)
	if(subtype == 0)
		icon_state = "flag[serial_number]"
		switch(serial_number)
			if(1)
				name += " - Flag of Nazi Germany"
				desc += " Arbeit macht frei!"
			if(2)
				name += " - Flag of The Confederate States of America"
				desc += " Sic semper tyrannis!"
			if(3)
				name += " - Flag of The Islamic State of Iraq and the Levant"
				desc += " Allahu ackbar!"
			if(4)
				name += " - Basque Ikurriña"
				desc += " Bietan jarrai!"
			if(5)
				name += " - Flag of The Puerto Rican Nationalist Party"
				desc += " ¡Despierta, borinqueño, que han dado la señal!"
			if(6)
				name += " - Flag of The Democratic People's Republic of Korea"
				desc += " Kangsong Daeguk!"
			else
				name += " - Error (subtype 0 serial_number)"
				desc += " This is a bug, please report the circumstances under which you encountered this flag using the Report Issue button."

	if(subtype == 1)
		icon_state = "flag[serial_number]_legit"
		switch(serial_number)
			if(1)
				name += " - Flag of The United States of America"
				desc += " USA! USA! USA!"
			if(2)
				name += " - Flag of Canada"
				desc += " Eh?"
			if(3)
				name += " - Flag of The Russian Federation"
				desc += " A nu chiki-briki i v damki!"
			if(4)
				name += " - Flag of Japan"
				desc += " go hommu whitu piggu!"
			if(5)
				name += " - Flag of Sweden"
				desc += " Sweden Yes!"
			if(6)
				name += " - Flag of The United Kingdom"
				desc += " God Save The Queen!"
			if(7)
				name += " - Flag of Finland"
				desc += " :DDDDDD"
			if(8)
				name += " - Flag of The Republic of Ireland"
				desc += " Tiocfaidh ár lá!"
			if(9)
				name += " - Flag of France"
				desc += " Vive France!"
			if(10)
				name += " - Flag of The Commonwealth of Puerto Rico"
				desc += " ¡Orgullo!"
			else
				name += " - Error (subtype 1 serial_number)"
				desc += " This is a bug, please report the circumstances under which you encountered this flag using the Report Issue button."
	..()

obj/structure/sign/flag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wirecutters))
		playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
		if(ruined)
			user << "<span class='notice'>You remove the remnants of the flag.</span>"
			qdel(src)
		else
			user << "<span class='notice'>You carefully remove the flag from the wall.</span>"
			roll_and_drop(user.loc)
		return


/obj/structure/sign/flag/attack_hand(mob/user)
	if(ruined)
		return
	var/temp_loc = user.loc
	switch(alert("Do I want to rip the flag from the wall?","You think...","Yes","No"))
		if("Yes")
			if( user.loc != temp_loc || ruined )
				return
			visible_message("<span class='warning'>[user] rips [src] in a single, decisive motion!</span>" )
			playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
			ruined = 1
			icon_state = "flag_ripped"
			name = "ripped flag"
			desc = "You can't make out anything from the flag's original print. It's ruined."
			add_fingerprint(user)
		if("No")
			return

/obj/structure/sign/flag/proc/roll_and_drop(turf/location)
	var/obj/item/weapon/patriotism/flag/P = new(src, serial_number)
	P.resulting_flag = src
	P.loc = location
	loc = P


//seperated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_flag(obj/item/weapon/patriotism/flag/P, mob/user)
	if(!P.resulting_flag)	return

	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a flag on it or too much stuff
		if(istype(O,/obj/structure/sign/flag) || istype(O,/obj/structure/sign/poster))
			user << "<span class='notice'>The wall is far too cluttered to place a flag!</span>"
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			user << "<span class='notice'>The wall is far too cluttered to place a flag!</span>"
			return

	user << "<span class='notice'>You start placing the flag on the wall...</span>"	//Looks like it's uncluttered enough. Place the flag.

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_flag
	var/obj/structure/sign/flag/D = P.resulting_flag

	var/temp_loc = user.loc
	flick("flag_being_set",D)
	D.loc = src
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	sleep(17)
	if(!D)	return

	if(istype(src,/turf/simulated/wall) && user && user.loc == temp_loc)	//Let's check if everything is still there
		user << "<span class='notice'>You place the flag!</span>"
	else
		D.roll_and_drop(temp_loc)
	return

//Putting non-contraband flags here because everything else here is related to flags anyway. -JS

/obj/item/weapon/patriotism/flag/legit
	desc = "The flag comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. It's acceptable to display this flag publicly."
	icon_state = "folded_flag_legit"
	subtype = 1
