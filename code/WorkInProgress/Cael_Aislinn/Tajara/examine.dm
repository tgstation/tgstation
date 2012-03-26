/mob/living/carbon/human/tajaran/examine()
	set src in view()

	usr << "\blue *---------*"

	usr << "\blue This is \icon[src.icon] <B>[src.name]</B>! One of the cat-like Tajarans."

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
		usr << "[src.shoes.blood_DNA ? "\red" : "\blue"][src.name] has a[src.shoes.blood_DNA ? " bloody " : " "] \icon[src.shoes] [src.shoes.name] on [t_his] feet."


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
//		var/photo = 0
		if(istype(src:wear_id, /obj/item/device/pda))
			var/obj/item/device/pda/pda = src:wear_id
			id = pda.owner
		else
			id = src.wear_id.registered
//			if (src.wear_id.PHOTO)
//				photo = 1
		if (id != src.real_name && in_range(src, usr))
//			if (photo)
//				usr << "\red [src.name] is wearing \icon[src.wear_id] [src.wear_id.name] with a photo yet doesn't seem to be that person!!!"
//			else
			usr << "\red [src.name] is wearing \icon[src.wear_id] [src.wear_id.name] yet doesn't seem to be that person!!!"
		else
//			if (photo)
//				usr << "\blue [src.name] is wearing \icon[src.wear_id] [src.wear_id.name] with a photo."
//			else
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
		if(health < 0 && distance <= 3)
			usr << "\red [name] does not appear to be breathing."
		if(ishuman(src) && usr.stat == 0 && src.stat == 1 && distance <= 1)
			for(var/mob/O in viewers(usr.loc, null))
				O.show_message("[usr] checks [src]'s pulse.", 1)
			sleep(15)
			usr << "\blue [name] has a pulse!"

	if (src.stat == 2 || (changeling && changeling.changeling_fakedeath == 1))
		if(distance <= 1)
			if(ishuman(usr) && usr.stat == 0)
				for(var/mob/O in viewers(usr.loc, null) )
					O.show_message("[usr] checks [src]'s pulse.", 1)
			sleep(15)
			usr << "\red [name] has no pulse!"
	else
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

		else if (src.brainloss >= 60)
			usr << "\red [src.name] has a stupid expression on [t_his] face."
		if (!src.client)
			usr << "\red [src.name] doesn't seem as though they want to talk."

	for(var/named in organs)
		var/datum/organ/external/temp = organs[named]
		if(temp.destroyed)
			usr << "\red [src.name] is missing [t_his] [temp.display_name]."
		if(temp.wounds)
			for(var/datum/organ/external/wound/w in temp.wounds)
				var/size = w.wound_size
				var/sizetext
				switch(size)
					if(1)
						sizetext = "cut"
					if(2)
						sizetext = "deep cut"
					if(3)
						sizetext = "flesh wound"
					if(4)
						sizetext = "gaping wound"
					if(5)
						sizetext = "big gaping wound"
					if(6)
						sizetext = "massive wound"
				if(w.bleeding)
					usr << "\red [src.name] is bleeding from a [sizetext] on [t_his] [temp.display_name]."
					continue

	print_flavor_text()

	usr << "\blue *---------*"
