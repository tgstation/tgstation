/mob/living/carbon/human/examine()
	set src in view()

	if(!usr || !src)	return
	if(((usr.sdisabilities & 1) || usr.blinded || usr.stat) && !(istype(usr,/mob/dead/observer/)))
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0

	//exosuits and helmets obscure our view and stuff.
	if (src.wear_suit)
		skipgloves = src.wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = src.wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = src.wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = src.wear_suit.flags_inv & HIDESHOES

	if (src.head)
		skipmask = src.head.flags_inv & HIDEMASK
		skipeyes = src.head.flags_inv & HIDEEYES
		skipears = src.head.flags_inv & HIDEEARS

	// crappy hacks because you can't do \his[src] etc. I'm sorry this proc is so unreadable, blame the text macros :<
	var/t_He = "It" //capitalised for use at the start of each line.
	var/t_his = "its"
	var/t_him = "it"
	var/t_has = "has"
	var/t_is = "is"

	var/msg = "<span class='info'>*---------*\nThis is "

	if( skipjumpsuit && (wear_mask || skipmask) ) //big suits/masks make it hard to tell their gender
		t_He = "They"
		t_his = "their"
		t_him = "them"
		t_has = "have"
		t_is = "are"
	else
		if(src.icon)
			msg += "\icon[src.icon] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated
		switch(src.gender)
			if(MALE)
				t_He = "He"
				t_his = "his"
				t_him = "him"
			if(FEMALE)
				t_He = "She"
				t_his = "her"
				t_him = "her"

	msg += "<EM>\a [src]</EM>!\n"

	//uniform
	if (src.w_uniform && !skipjumpsuit)
		if (src.w_uniform.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[src.w_uniform] [src.w_uniform.gender==PLURAL?"some":"a"] blood-stained [src.w_uniform.name]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[src.w_uniform] \a [src.w_uniform].\n"

	//head
	if (src.head)
		if (src.head.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[src.head] [src.head.gender==PLURAL?"some":"a"] blood-stained [src.head.name] on [t_his] head!</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[src.head] \a [src.head] on [t_his] head.\n"

	//suit/armour
	if (src.wear_suit)
		if (src.wear_suit.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[src.wear_suit] [src.wear_suit.gender==PLURAL?"some":"a"] blood-stained [src.wear_suit.name]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[src.wear_suit] \a [src.wear_suit].\n"

		//suit/armour storage
		if(src.s_store && !skipsuitstorage)
			if(src.s_store.blood_DNA)
				msg += "<span class='warning'>[t_He] [t_is] carrying \icon[src.s_store] [src.s_store.gender==PLURAL?"some":"a"] blood-stained [src.s_store.name] on [t_his] [src.wear_suit.name]!</span>\n"
			else
				msg += "[t_He] [t_is] carrying \icon[src.s_store] \a [src.s_store] on [t_his] [src.wear_suit.name].\n"

	//back
	if (src.back)
		if (src.back.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[src.back] [src.back.gender==PLURAL?"some":"a"] blood-stained [src.back] on [t_his] back.</span>\n"
		else
			msg += "[t_He] [t_has] \icon[src.back] \a [src.back] on [t_his] back.\n"

	//left hand
	if (src.l_hand)
		if (src.l_hand.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] holding \icon[src.l_hand] [src.l_hand.gender==PLURAL?"some":"a"] blood-stained [src.l_hand.name] in [t_his] left hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding \icon[src.l_hand] \a [src.l_hand] in [t_his] left hand.\n"

	//right hand
	if (src.r_hand)
		if (src.r_hand.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] holding \icon[src.r_hand] [src.r_hand.gender==PLURAL?"some":"a"] blood-stained [src.r_hand.name] in [t_his] right hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding \icon[src.r_hand] \a [src.r_hand] in [t_his] right hand.\n"

	//gloves
	if (src.gloves && !skipgloves)
		if (src.gloves.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[src.gloves] [src.gloves.gender==PLURAL?"some":"a"] blood-stained [src.gloves.name] on [t_his] hands!</span>\n"
		else
			msg += "[t_He] [t_has] \icon[src.gloves] \a [src.gloves] on [t_his] hands.\n"
	else if (src.blood_DNA)
		msg += "<span class='warning'>[t_He] [t_has] blood-stained hands!</span>\n"

	//handcuffed?

	//handcuffed?
	if (src.handcuffed)
		if(istype(src.handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] \icon[src.handcuffed] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] \icon[src.handcuffed] handcuffed!</span>\n"

	//belt
	if (src.belt)
		if (src.belt.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[src.belt] [src.belt.gender==PLURAL?"some":"a"] blood-stained [src.belt.name] about [t_his] waist!</span>\n"
		else
			msg += "[t_He] [t_has] \icon[src.belt] \a [src.belt] about [t_his] waist.\n"

	//shoes
	if (src.shoes && !skipshoes)
		if(src.shoes.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[src.shoes] [src.shoes.gender==PLURAL?"some":"a"] blood-stained [src.shoes.name] on [t_his] feet!</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[src.shoes] \a [src.shoes] on [t_his] feet.\n"

	//mask
	if (src.wear_mask && !skipmask)
		if (src.wear_mask.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[src.wear_mask] [src.wear_mask.gender==PLURAL?"some":"a"] blood-stained [src.wear_mask.name] on [t_his] face!</span>\n"
		else
			msg += "[t_He] [t_has] \icon[src.wear_mask] \a [src.wear_mask] on [t_his] face.\n"

	//eyes
	if (src.glasses && !skipeyes)
		if (src.glasses.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] \icon[src.glasses] [src.glasses.gender==PLURAL?"some":"a"] blood-stained [src.glasses] covering [t_his] eyes!</span>\n"
		else
			msg += "[t_He] [t_has] \icon[src.glasses] \a [src.glasses] covering [t_his] eyes.\n"

	//ears
	if (src.ears && !skipears)
		msg += "[t_He] [t_has] \icon[src.ears] \a [src.ears] on [t_his] ears.\n"

	//ID
	if (src.wear_id)
		var/id
		if(istype(src.wear_id, /obj/item/device/pda))
			var/obj/item/device/pda/pda = src.wear_id
			id = pda.owner
		else if(istype(src.wear_id, /obj/item/weapon/card/id)) //just in case something other than a PDA/ID card somehow gets in the ID slot :[
			var/obj/item/weapon/card/id/idcard = src.wear_id
			id = idcard.registered_name
		if (id && (id != src.real_name) && (get_dist(src, usr) <= 1) && prob(10))
			msg += "<span class='warning'>[t_He] [t_is] wearing \icon[src.wear_id] \a [src.wear_id] yet something doesn't seem right...</span>\n"
		else
			msg += "[t_He] [t_is] wearing \icon[src.wear_id] \a [src.wear_id].\n"

	//Jitters
	if (src.is_jittery)
		if(src.jitteriness >= 300)
			msg += "<span class='warning'><B>[t_He] [t_is] convulsing violently!</B></span>\n"
		else if(src.jitteriness >= 200)
			msg += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>\n"
		else if(src.jitteriness >= 100)
			msg += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>\n"

	if (src.suiciding)
		msg += "<span class='warning'>[t_He] [t_has] bitten off [t_his] own tongue and [t_has] suffered major bloodloss!</span>\n"

	if (src.stat == DEAD || (changeling && (changeling.changeling_fakedeath == 1)))
		msg += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive; there are no signs of life"

		if(!src.client)
			var/foundghost = 0
			for(var/mob/dead/observer/G in world)
				if(G.client)
					if(G.corpse == src)
						foundghost++
						break
			if(!foundghost)
				msg += " and [t_his] soul has departed"
		msg += "...</span>\n"

	else
		msg += "<span class='warning'>"

		var/temp = src.getBruteLoss() //no need to calculate each of these twice
		if(temp)
			if (temp < 30)
				msg += "[t_He] [t_has] minor bruising.\n"
			else
				msg += "<B>[t_He] [t_has] severe bruising!</B>\n"

		temp = src.getFireLoss()
		if (temp)
			if (temp < 30)
				msg += "[t_He] [t_has] minor burns.\n"
			else
				msg += "<B>[t_He] [t_has] severe burns!</B>\n"

		temp = src.getCloneLoss()
		if (temp)
			if (temp < 30)
				msg += "[t_He] [t_has] minor genetic deformities.\n"
			else
				msg += "<B>[t_He] [t_has] severe genetic deformities.</B>\n"

		if (src.nutrition < 100)
			msg += "[t_He] [t_is] severely malnourished.\n"
		else if (src.nutrition >= 500)
			if (usr.nutrition < 100)
				msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
			else
				msg += "[t_He] [t_is] quite chubby.\n"

		msg += "</span>"

		if (src.stat == UNCONSCIOUS)
			msg += "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.\n"
		else if (src.getBrainLoss() >= 60)
			msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

		if (!src.client)
			msg += "[t_He] [t_has] a vacant, braindead stare...\n"

	if (src.digitalcamo)
		msg += "[t_He] [t_is] repulsively uncanny!\n"


	if(istype(usr, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = usr
		if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud))
			var/perpname = "wot"
			var/criminal = "None"

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name

			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							criminal = R.fields["criminal"]


			msg += "<span class = 'deptradio'>Criminal status:</span> <a href='?src=\ref[src];criminal=1'>\[[criminal]\]</a>\n"
			//msg += "\[Set Hostile Identification\]\n"

	msg += "*---------*</span>"

	usr << msg
