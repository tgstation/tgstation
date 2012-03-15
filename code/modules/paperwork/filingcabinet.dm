/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'bureaucracy.dmi'
	icon_state = "filing_cabinet0"
	density = 1
	anchored = 1

/obj/structure/filingcabinet/attackby(obj/item/P as obj, mob/user as mob)
	if(istype(P, /obj/item/weapon/paper) || istype(P, /obj/item/weapon/folder))
		user << "You put the [P] in the [src]."
		user.drop_item()
		P.loc = src
		spawn()
			icon_state = "filing_cabinet1"
			sleep(5)
			icon_state = "filing_cabinet0"
	else if(istype(P, /obj/item/weapon/wrench))
		playsound(loc, 'Ratchet.ogg', 50, 1)
		anchored = !anchored
		user << "You [anchored ? "wrench" : "unwrench"] the [src]."
	else
		user << "You can't put a [P] in the [src]!"

/obj/structure/filingcabinet/attack_hand(mob/user as mob)
	if(src.contents.len <= 0)
		user << "The [src] is empty."
		return
	icon_state = "filing_cabinet1"	//make it look open for kicks
	var/obj/item/P = input(user,"Choose a file or folder to take out.","[src]", "Cancel") as null|obj in contents
	if(!isnull(P) && in_range(src,user))
		if(!user.get_active_hand())
			user.put_in_hand(P)
		else
			P.loc = get_turf_loc(src)
	icon_state = "filing_cabinet0"
	return