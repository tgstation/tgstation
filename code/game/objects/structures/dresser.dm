/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1

/obj/structure/dresser/attack_hand(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if(H.gender == MALE)
			var/new_undies = input(user, "Select your underwear", "Changing")  as null|anything in underwear_m
			if(!in_range(src, usr))//no tele-grooming
				return
			if(new_undies)
				H.underwear = underwear_m.Find(new_undies)
		else
			var/new_undies = input(user, "Select your underwear", "Changing")  as null|anything in underwear_f
			if(!in_range(src, usr))
				return
			if(new_undies)
				H.underwear = underwear_f.Find(new_undies)

		add_fingerprint(H)
		H.update_body()