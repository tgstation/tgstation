/*An alternative to exit gateways, signposts send you back to the arrivals shuttle with their semiotic magic.*/
/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

/obj/structure/signpost/attackby(obj/item/weapon/W, mob/user, params)
	return attack_hand(user)

/obj/structure/signpost/attack_hand(mob/user)
	switch(alert("Travel back to ss13?",,"Yes","No"))
		if("Yes")
			if(user.z != src.z)	return
			user.loc.loc.Exited(user)
			user.loc = pick(latejoin)
		if("No")
			return