
/obj/item/mounted/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface."
	icon = 'icons/obj/contraband.dmi'
	icon_state = "rolled_poster"
	var/serial_number = 0
	w_type=RECYK_MISC


/obj/item/mounted/poster/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, poster_designs.len)
	else
		serial_number = given_serial
	name += " - No. [serial_number]"
	if(serial_number == -1)
		name = "Commendation Poster"
	..(loc)

/obj/item/mounted/poster/do_build(turf/on_wall, mob/user)
	user << "<span class='notice'>You start placing the poster on the wall...</span>" //Looks like it's uncluttered enough. Place the poster.

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/structure/sign/poster/D = new(src.serial_number)

	var/temp_loc = user.loc
	flick("poster_being_set",D)
	D.loc = on_wall
	qdel(src)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)


	if(!D)	return

	if(do_after(user, 17))//Let's check if everything is still there
		user << "<span class='notice'>You place the poster!</span>"
	else
		D.roll_and_drop(temp_loc)
	return


//############################## THE ACTUAL DECALS ###########################

obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper. "
	icon = 'icons/obj/contraband.dmi'
	anchored = 1
	var/serial_number	//Will hold the value of src.loc if nobody initialises it
	var/ruined = 0


obj/structure/sign/poster/New(var/serial)

	serial_number = serial

	if(serial_number == -1)
		name += "Award of Sufficiency"
		desc += "The mere sight of it makes you very proud."
		icon_state = "goldstar"

	else
		if(serial_number == loc)
			serial_number = rand(1, poster_designs.len)	//This is for the mappers that want individual posters without having to use rolled posters.

		var/designtype = poster_designs[serial_number]
		var/datum/poster/design=new designtype
		name += " - [design.name]"
		desc += " [design.desc]"
		icon_state = design.icon_state // poster[serial_number]
		..()

obj/structure/sign/poster/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wirecutters))
		playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
		if(ruined)
			user << "<span class='notice'>You remove the remnants of the poster.</span>"
			del(src)
		else
			user << "<span class='notice'>You carefully remove the poster from the wall.</span>"
			roll_and_drop(user.loc)
		return

/obj/structure/sign/poster/attack_hand(mob/user as mob)
	if(ruined)
		return
	var/temp_loc = user.loc
	switch(alert("Do I want to rip the poster from the wall?","You think...","Yes","No"))
		if("Yes")
			if(user.loc != temp_loc)
				return
			visible_message("<span class='warning'>[user] rips [src] in a single, decisive motion!</span>" )
			playsound(get_turf(src), 'sound/items/poster_ripped.ogg', 100, 1)
			ruined = 1
			icon_state = "poster_ripped"
			name = "ripped poster"
			desc = "You can't make out anything from the poster's original print. It's ruined."
			add_fingerprint(user)
		if("No")
			return

/obj/structure/sign/poster/proc/roll_and_drop(turf/newloc)
	if(newloc)
		new /obj/item/mounted/poster(newloc, serial_number)
	else
		new /obj/item/mounted/poster(get_turf(src), serial_number)
	qdel(src)

/datum/poster
	// Name suffix. Poster - [name]
	var/name=""
	// Description suffix
	var/desc=""
	var/icon_state=""