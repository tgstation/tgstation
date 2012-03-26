/mob/living/carbon/human/examine()
	set src in view()

	usr << "\blue *---------*"

	usr << "\blue This is \icon[src.icon] <B>[src.name]</B>!"

	// crappy hack because you can't do \his[src] etc
	var/t_his = "its"
	var/t_him = "it"
	if (src.gender == MALE)
		t_his = "his"
		t_him = "him"
	else if (src.gender == FEMALE)
		t_his = "her"
		t_him = "her"

	if (src.w_uniform)
		if (src.w_uniform.blood_DNA)
			usr << "\red [src.name] is wearing a[src.w_uniform.blood_DNA ? " bloody " : " "] \icon[src.w_uniform] [src.w_uniform.name]!"
		else
			usr << "\blue [src.name] is wearing a \icon[src.w_uniform] [src.w_uniform.name]."

	if (src.handcuffed)
		usr << "\blue [src.name] is \icon[src.handcuffed] handcuffed!"

	if (src.wear_suit)
		if (src.wear_suit.blood_DNA)
			usr << "\red [src.name] has a[src.wear_suit.blood_DNA ? " bloody " : " "] \icon[src.wear_suit] [src.wear_suit.name] on!"
		else
			usr << "\blue [src.name] has a \icon[src.wear_suit] [src.wear_suit.name] on."

	if (src.l_ear)
		usr << "\blue [src.name] has a \icon[src.l_ear] [src.l_ear.name] on [t_his] left ear."

	if (src.r_ear)
		usr << "\blue [src.name] has a \icon[src.r_ear] [src.r_ear.name] on [t_his] right ear."

	if (src.wear_mask)
		if (src.wear_mask.blood_DNA)
			usr << "\red [src.name] has a[src.wear_mask.blood_DNA ? " bloody " : " "] \icon[src.wear_mask] [src.wear_mask.name] on [t_his] face!"
		else
			usr << "\blue [src.name] has a \icon[src.wear_mask] [src.wear_mask.name] on [t_his] face."

	if (src.head)
		usr << "\blue [src.name] is wearing a[src.head.blood_DNA ? " bloody " : " "] \icon[src.head] [src.head.name] on [t_his] head!"

	if (src.glasses)
		usr << "\blue [src.name] is wearing a pair of [src.glasses.blood_DNA ? " bloody " : " "] \icon[src.glasses] [src.glasses.name]!"



	if (src.l_hand)
		if (src.l_hand.blood_DNA)
			usr << "\red [src.name] has a[src.l_hand.blood_DNA ? " bloody " : " "] \icon[src.l_hand] [src.l_hand.name] in [t_his] left hand!"
		else
			usr << "\blue [src.name] has a \icon[src.l_hand] [src.l_hand.name] in [t_his] left hand."

	if (src.r_hand)
		if (src.r_hand.blood_DNA)
			usr << "\red [src.name] has a[src.r_hand.blood_DNA ? " bloody " : " "] \icon[src.r_hand] [src.r_hand.name] in [t_his] right hand!"
		else
			usr << "\blue [src.name] has a \icon[src.r_hand] [src.r_hand.name] in [t_his] right hand."

	if (src.belt)
		if (src.belt.blood_DNA)
			usr << "\red [src.name] has a[src.belt.blood_DNA ? " bloody " : " "] \icon[src.belt] [src.belt.name] on [t_his] belt!"
		else
			usr << "\blue [src.name] has a \icon[src.belt] [src.belt.name] on [t_his] belt."
	if(src.s_store)
		if(src.s_store.blood_DNA)
			usr << "\red [src.name] has a[src.s_store.blood_DNA ? " bloody " : " "] \icon[src.s_store] [src.s_store.name] on [t_his][src.wear_suit.blood_DNA ? " bloody " : " "] \icon[src.wear_suit] [src.wear_suit.name]!"
		else
			usr << "\blue [src.name] has a \icon[src.s_store] [src.s_store.name] on [t_his][src.wear_suit.blood_DNA ? " bloody " : " "] \icon[src.wear_suit] [src.wear_suit.name]."
	if (src.shoes)
		usr << "[src.shoes.blood_DNA ? "\red" : "\blue"] [src.name] has a[src.shoes.blood_DNA ? " bloody " : " "] \icon[src.shoes] [src.shoes.name] on [t_his] feet."


	if (src.gloves)
		if (src.gloves.blood_DNA)
			usr << "\red [src.name] has bloody \icon[src.gloves] [src.gloves.name] on [t_his] hands!"
		else
			usr << "\blue [src.name] has \icon[src.gloves] [src.gloves.name] on [t_his] hands."
	else if (src.blood_DNA)
		usr << "\red [src.name] has bloody hands!"

	if (src.back)
		usr << "\blue [src.name] has a \icon[src.back] [src.back.name] on [t_his] back."

	if (src.wear_id)
		var/id
		var/photo = 0
		if(istype(src:wear_id, /obj/item/device/pda))
			var/obj/item/device/pda/pda = src:wear_id
			id = pda.owner
		else
			id = src.wear_id.registered_name
			if (src.wear_id.PHOTO)
				photo = 1
		if (id != src.real_name && in_range(src, usr))
			if (photo)
				usr << "\red [src.name] is wearing \icon[src.wear_id] [src.wear_id.name] with a photo yet doesn't seem to be that person!!!"
			else
				usr << "\red [src.name] is wearing \icon[src.wear_id] [src.wear_id.name] yet doesn't seem to be that person!!!"
		else
			if (photo)
				usr << "\blue [src.name] is wearing \icon[src.wear_id] [src.wear_id.name] with a photo."
			else
				usr << "\blue [src.name] is wearing \icon[src.wear_id] [src.wear_id.name]."


	if (src.is_jittery)
		switch(src.jitteriness)
			if(300 to INFINITY)
				usr << "\red [src] is violently convulsing."
			if(200 to 300)
				usr << "\red [src] looks extremely jittery."
			if(100 to 200)
				usr << "\red [src] is twitching ever so slightly."

	if (src.suiciding)
		switch(src.suiciding)
			if(1)
				usr << "\red [src.name] appears to have bitten [t_his] tongue off!"

	var/distance = get_dist(usr,src)
	if(istype(usr, /mob/dead/observer) || usr.stat == 2) // ghosts can see anything
		distance = 1

	if (src.stat == 1 || stat == 2)
		usr << "\red [name] doesn't seem to be responding to anything around [t_him], [t_his] eyes closed as though asleep."
		if((!isbreathing || holdbreath) && distance <= 3)
			usr << "\red [name] does not appear to be breathing."
		if(istype(usr, /mob/living/carbon/human) && usr.stat == 0 && src.stat == 1 && distance <= 1)
			for(var/mob/O in viewers(usr.loc, null))
				O.show_message("[usr] checks [src]'s pulse.", 1)
			sleep(15)
			usr << "\blue [name] has a pulse!"

	if (src.stat == 2 || (changeling && changeling.changeling_fakedeath == 1))
		if(distance <= 1)
			if(istype(usr, /mob/living/carbon/human) && usr.stat == 0)
				for(var/mob/O in viewers(usr.loc, null))
					O.show_message("[usr] checks [src]'s pulse.", 1)
			sleep(15)
			usr << "\red [name] has no pulse!"

	if (src.getBruteLoss())
		if (src.getBruteLoss() < 30)
			usr << "\red [src.name] looks slightly injured!"
		else
			usr << "\red <B>[src.name] looks severely injured!</B>"

	if (src.cloneloss)
		if (src.cloneloss < 30)
			usr << "\red [src.name] looks slightly... unfinished?"
		else
			usr << "\red <B>[src.name] looks very... unfinished?</B>"

	if (src.getFireLoss())
		if (src.getFireLoss() < 30)
			usr << "\red [src.name] looks slightly burned!"
		else
			usr << "\red <B>[src.name] looks severely burned!</B>"

	if (src.nutrition < 100)
		usr << "\red [src.name] looks like flesh and bones."
	else if (src.nutrition >= 500)
		if (usr.nutrition < 100)
			usr << "\red [src.name] looks very round and delicious. Like a little piggy. A tasty piggy."
		else
			usr << "\blue [src.name] looks quite chubby."

	if(!stat)
		if (src.brainloss >= 60)
			usr << "\red [src.name] has a stupid expression on [t_his] face."

	if (!src.client)
		usr << "\red [src.name] doesn't seem as though they want to talk."

	spawn(10) // I think we might be overloading the clients.
		var/list/wound_descriptions = list()
		for(var/named in organs)
			var/datum/organ/external/temp = organs[named]
			if(temp)
				if(temp.destroyed)
					usr << "\red [src.name] is missing [t_his] [temp.display_name]."
					continue
				if(temp.wounds)
					var/list/wounds = list(list(),list(),list(),list(),list(),list())
					for(var/datum/organ/wound/w in temp.wounds)
						switch(w.healing_state)
							if(0)
								var/list/cut = wounds[1]
								cut += w
								wounds[1] = cut
							if(1)
								var/list/cut = wounds[2]
								cut += w
								wounds[2] = cut
							if(2)
								var/list/cut = wounds[3]
								cut += w
								wounds[3] = cut
							if(3)
								var/list/cut = wounds[4]
								cut += w
								wounds[4] = cut
							if(4)
								var/list/cut = wounds[5]
								cut += w
								wounds[5] = cut
							if(5)
								var/list/cut = wounds[6]
								cut += w
								wounds[6] = cut
					wound_descriptions["[temp.display_name]"] = wounds
		//Now that we have a big list of all the wounds, on all the limbs.
		var/list/wound_flavor_text = list()
		for(var/named in wound_descriptions)
			var/list/wound_states = wound_descriptions[named]
			for(var/i = 1, i <= 6, i++)
				var/list/wound_state = wound_states[i] //All wounds at this level of healing.
				var/list/tally = list("cut" = 0, "deep cut" = 0, "flesh wound" = 0, "gaping wound" = 0, "big gaping wound" = 0, "massive wound" = 0) //How many wounds of what size.
				for(var/datum/organ/wound/w in wound_state)
					switch(w.wound_size)
						if(1)
							tally["cut"] += 1
						if(2)
							tally["deep cut"] += 1
						if(3)
							tally["flesh wound"] += 1
						if(4)
							tally["gaping wound"] += 1
						if(5)
							tally["big gaping wound"] += 1
						if(6)
							tally["massive wound"] += 1
				for(var/tallied in tally)
					if(!tally[tallied])
						continue


//		if(w.bleeding)
//			usr << "\red [src.name] is bleeding from a [sizetext] on [t_his] [temp.display_name]."
//			continue

		print_flavor_text()

		usr << "\blue *---------*"
