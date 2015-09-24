/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1

/obj/structure/dresser/attack_hand(mob/user)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/choice = input(user, "Underwear, Undershirt, or Socks?", "Changing") as null|anything in list("Underwear","Undershirt","Socks")

		if(!Adjacent(user))
			return
		switch(choice)
			if("Underwear")
				var/new_undies = input(user, "Select your underwear", "Changing")  as null|anything in underwear_list
				if(new_undies)
					H.underwear = new_undies

			if("Undershirt")
				var/new_undershirt = input(user, "Select your undershirt", "Changing") as null|anything in undershirt_list
				if(new_undershirt)
					H.undershirt = new_undershirt
			if("Socks")
				var/new_socks = input(user, "Select your socks", "Changing") as null|anything in socks_list
				if(new_socks)
					H.socks= new_socks

		add_fingerprint(H)
		H.update_body()