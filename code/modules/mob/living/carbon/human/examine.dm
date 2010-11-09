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

	if (src.ears)
		usr << "\blue [src.name] has a \icon[src.ears] [src.ears.name] by [t_his] mouth."

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
	if (src.shoes)
		usr << "[src.shoes.blood_DNA ? "\red" : "\blue"] [src.name] has a[src.shoes.blood_DNA ? " bloody " : " "] \icon[src.shoes] [src.shoes.name] on [t_his] feet."


	if (src.gloves)
		if (src.gloves.blood_DNA)
			usr << "\red [src.name] has bloody \icon[src.gloves] [src.gloves.name] on [t_his] hands!"
		else
			usr << "\blue [src.name] has \icon[src.gloves] [src.gloves.name] on [t_his] hands."
	else if (src.blood_DNA)
		usr << "\red [src.name] has[src.blood_DNA ? " bloody " : " "] hands!"

	if (src.back)
		usr << "\blue [src.name] has a \icon[src.back] [src.back.name] on [t_his] back."

	if (src.wear_id)
		if (src.wear_id.registered != src.real_name && in_range(src, usr) && prob(10))
			usr << "\red [src.name] is wearing \icon[src.wear_id] [src.wear_id.name] yet doesn't seem to be that person!!!"
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

	if (src.stat == 2 || src.changeling_fakedeath == 1)
		usr << "\red [src] is limp and unresponsive, a dull lifeless look in [t_his] eyes."
	else
		if (src.bruteloss)
			if (src.bruteloss < 30)
				usr << "\red [src.name] looks slightly injured!"
			else
				usr << "\red <B>[src.name] looks severely injured!</B>"

		if (src.fireloss)
			if (src.fireloss < 30)
				usr << "\red [src.name] looks slightly burned!"
			else
				usr << "\red <B>[src.name] looks severely burned!</B>"

		if (src.stat == 1)
			usr << "\red [src.name] doesn't seem to be responding to anything around [t_him], [t_his] eyes closed as though asleep."
		else if (src.brainloss >= 60)
			usr << "\red [src.name] has a stupid expression on [t_his] face."
		if (!src.client)
			usr << "\red [src.name] doesn't seem as though they want to talk."

	usr << "\blue *---------*"
