/obj/structure/signpost
	name = "signpost"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

/obj/structure/signpost/attackby(obj/item/I, mob/user)
	return attack_hand(user)

/obj/structure/signpost/attack_hand(mob/user)
	switch(alert("Travel back to ss13?",,"Yes","No"))
		if("Yes")
			if(user.z != z)
				return
			user.Move(pick(latejoin))


/obj/structure/showcase
	name = "showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	unacidable = 1	//temporary until I decide whether the borg can be removed. -veyveyr

/obj/structure/showcase/fakeid
	name = "\improper Centcom Identification Console"
	desc = "You can use this to change ID's."
	icon = 'icons/obj/computer.dmi'
	icon_state = "id"

/obj/structure/showcase/fakesec
	name = "\improper Centcom Security Records"
	desc = "Used to view and edit personnel's security records"
	icon = 'icons/obj/computer.dmi'
	icon_state = "security"
