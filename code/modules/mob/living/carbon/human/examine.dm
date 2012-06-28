/mob/living/carbon/human/examine()
	set src in view()

	if(!usr || !src)	return
	if(((usr.disabilities & 128) || usr.blinded || usr.stat) && !(istype(usr,/mob/dead/observer/)))
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

	switch(get_visible_gender())
		if(MALE)
			t_He = "He"
			t_his = "his"
			t_him = "him"
		if(FEMALE)
			t_He = "She"
			t_his = "her"
			t_him = "her"
		if(NEUTER)
			t_He = "They"
			t_his = "their"
			t_him = "them"
			t_has = "have"
			t_is = "are"

	if(mutantrace == "lizard")
		examine_text = "one of those lizard-like Soghuns"
	if(mutantrace == "skrell")
		examine_text = "one of those gelatinous Skrells"

	if(icon)
		msg += "\icon[icon] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated

	msg += "<EM>\a [src]</EM>[examine_text ? ", [examine_text]":""]!\n"

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
	if (src.handcuffed)
		if(istype(src.handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] \icon[src.handcuffed] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] \icon[src.handcuffed] handcuffed!</span>\n"

	//splints
	for(var/organ in list("l_leg","r_leg","l_arm","r_arm"))
		var/datum/organ/external/o = organs["[organ]"]
		if(o.status & SPLINTED)
			msg += "<span class='warning'>[t_He] [t_has] a splint on his [o.getDisplayName()]!</span>\n"

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

	if (src.l_ear && !skipears)
		msg += "[t_He] [t_has] has a \icon[src.l_ear] [src.l_ear.name] on [t_his] left ear.\n"

	if (src.r_ear && !skipears)
		msg += "[t_He] [t_has] has a \icon[src.r_ear] [src.r_ear.name] on [t_his] right ear.\n"

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

	var/distance = get_dist(usr,src)
	if(istype(usr, /mob/dead/observer) || usr.stat == 2) // ghosts can see anything
		distance = 1

	if (src.stat == 1 || stat == 2)
		msg += "<span class='warning'>[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.</span>\n"
		if((!isbreathing || holdbreath) && distance <= 3)
			msg += "<span class='warning'>[t_He] does not appear to be breathing.</span>\n"
		if(istype(usr, /mob/living/carbon/human) && usr.stat == 0 && src.stat == 1 && distance <= 1)
			for(var/mob/O in viewers(usr.loc, null))
				O.show_message("[usr] checks [src]'s pulse.", 1)
			spawn(15)
				usr << "\blue [t_He] has a pulse!"

	if (src.stat == 2 || (changeling && changeling.changeling_fakedeath == 1))
		if(distance <= 1)
			if(istype(usr, /mob/living/carbon/human) && usr.stat == 0)
				for(var/mob/O in viewers(usr.loc, null))
					O.show_message("[usr] checks [src]'s pulse.", 1)
			spawn(15)
				if(!src.client)
					var/foundghost = 0
					for(var/mob/dead/observer/G in world)
						if(G.client)
							if(G.corpse == src)
								foundghost++
								break
					if(!foundghost)
						usr << "<span class='deadsay'>[t_He] has no pulse and [t_his] soul has departed...</span>"
					else
						usr << "<span class='deadsay'>[t_He] has no pulse...</span>"

	msg += "<span class='warning'>"

/*	if (src.getBruteLoss())
		if (src.getBruteLoss() < 30)
			usr << "\red [src.name] looks slightly injured!"
		else
			usr << "\red <B>[src.name] looks severely injured!</B>"*/

	if (src.cloneloss)
		if (src.cloneloss < 30)
			msg += "[t_He] looks slightly... unfinished?\n"
		else
			msg += "<B>[t_He] looks very... unfinished?</B>\n"

/*	if (src.getFireLoss())
		if (src.getFireLoss() < 30)
			usr << "\red [src.name] looks slightly burned!"
		else
			usr << "\red <B>[src.name] looks severely burned!</B>"*/
	msg += "<span class='warning'>"
	if (src.nutrition < 100)
		msg += "[t_He] [t_is] severely malnourished.\n"
	else if (src.nutrition >= 500)
		if (usr.nutrition < 100)
			msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
		else
			msg += "[t_He] [t_is] quite chubby.\n"

	msg += "</span>"


	if (src.getBrainLoss() >= 60 && !stat)
		msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

	if (!src.client && !admin_observing)
		msg += "[t_He] [t_has] a vacant stare...\n"

	if (src.digitalcamo)
		msg += "[t_He] [t_is] repulsively uncanny!\n"

	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	var/list/is_bleeding = list()
	for(var/named in organs)
		var/datum/organ/external/temp = organs[named]
		if(temp)
			if(temp.status & DESTROYED)
				is_destroyed["[temp.display_name]"] = 1
				wound_flavor_text["[temp.display_name]"] = "<span class='warning'><b>[t_He] is missing [t_his] [temp.display_name].</b></span>\n"
				continue
			if(temp.status & ROBOT)
				if(!(temp.brute_dam + temp.burn_dam))
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] has a robot [temp.display_name]!</span>\n"
					continue
				else
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] has a robot [temp.display_name], it has"
				if(temp.brute_dam) switch(temp.brute_dam)
					if(0 to 20)
						wound_flavor_text["[temp.display_name]"] += " some dents"
					if(21 to INFINITY)
						wound_flavor_text["[temp.display_name]"] += pick(" a lot of dents"," severe denting")
				if(temp.brute_dam && temp.burn_dam)
					wound_flavor_text["[temp.display_name]"] += " and"
				if(temp.burn_dam) switch(temp.burn_dam)
					if(0 to 20)
						wound_flavor_text["[temp.display_name]"] += " some burns"
					if(21 to INFINITY)
						wound_flavor_text["[temp.display_name]"] += pick(" a lot of burns"," severe melting")
				wound_flavor_text["[temp.display_name]"] += "!</span>\n"
			else if(temp.wound_descs.len)
				var/list/wound_descriptors = list()
				for(var/time in temp.wound_descs)
					for(var/wound in temp.wound_descs[time])
						if(wound in wound_descriptors)
							wound_descriptors[wound]++
							continue
						wound_descriptors[wound] = 1
				var/list/flavor_text = list()
				var/list/no_exclude = list("gaping wound", "big gaping wound", "massive wound", "large bruise",\
				"huge bruise", "massive bruise", "severe burn", "large burn", "deep burn", "carbonised area")
				for(var/wound in wound_descriptors)
					switch(wound_descriptors[wound])
						if(1)
							if(!flavor_text.len)
								flavor_text += "<span class='warning'>[t_He] has[prob(10) && !(wound in no_exclude)  ? " what might be" : ""] a [wound]"
							else
								flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a [wound]"
						if(2)
							if(!flavor_text.len)
								flavor_text += "<span class='warning'>[t_He] has[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
							else
								flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
						if(3 to 5)
							if(!flavor_text.len)
								flavor_text += "<span class='warning'>[t_He] has several [wound]s"
							else
								flavor_text += " several [wound]s"
						if(6 to INFINITY)
							if(!flavor_text.len)
								flavor_text += "<span class='warning'>[t_He] has a bunch of [wound]s"
							else
								flavor_text += " a ton of [wound]\s"
				var/flavor_text_string = ""
				for(var/text = 1, text <= flavor_text.len, text++)
					if(text == flavor_text.len && flavor_text.len > 1)
						flavor_text_string += ", and"
					else if(flavor_text.len > 1 && text > 1)
						flavor_text_string += ","
					flavor_text_string += flavor_text[text]
				flavor_text_string += " on [t_his] [named].</span><br>"
				wound_flavor_text["[named]"] = flavor_text_string
				if(temp.status & BLEEDING)
					is_bleeding["[named]"] = 1
			else
				wound_flavor_text["[temp.display_name]"] = ""

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	var/display_chest = 0
	var/display_shoes = 0
	var/display_gloves = 0
	if(wound_flavor_text["head"] && (is_destroyed["head"] || (!skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))))
		msg += wound_flavor_text["head"]
	else if(is_bleeding["head"])
		msg += "<span class='warning'>[src] has blood running down [t_his] face!</span>\n"
	if(wound_flavor_text["chest"] && !w_uniform && !skipjumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text["chest"]
	else if(is_bleeding["chest"])
		display_chest = 1
	if(wound_flavor_text["left arm"] && (is_destroyed["left arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left arm"]
	else if(is_bleeding["left arm"])
		display_chest = 1
	if(wound_flavor_text["left hand"] && (is_destroyed["left hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["left hand"]
	else if(is_bleeding["left hand"])
		display_gloves = 1
	if(wound_flavor_text["right arm"] && (is_destroyed["right arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right arm"]
	else if(is_bleeding["right arm"])
		display_chest = 1
	if(wound_flavor_text["right hand"] && (is_destroyed["right hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["right hand"]
	else if(is_bleeding["right hand"])
		display_gloves = 1
	if(wound_flavor_text["groin"] && (is_destroyed["groin"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["groin"]
	else if(is_bleeding["groin"])
		display_chest = 1
	if(wound_flavor_text["left leg"] && (is_destroyed["left leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left leg"]
	else if(is_bleeding["left leg"])
		display_chest = 1
	if(wound_flavor_text["left foot"]&& (is_destroyed["left foot"] || (!shoes && !skipshoes)))
		msg += wound_flavor_text["left foot"]
	else if(is_bleeding["left foot"])
		display_shoes = 1
	if(wound_flavor_text["right leg"] && (is_destroyed["right leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right leg"]
	else if(is_bleeding["right leg"])
		display_chest = 1
	if(wound_flavor_text["right foot"]&& (is_destroyed["right foot"] || (!shoes  && !skipshoes)))
		msg += wound_flavor_text["right foot"]
	else if(is_bleeding["right foot"])
		display_shoes = 1
	if(display_chest)
		msg += "<span class='warning'><b>[src] has blood soaking through from under [t_his] clothing!</b></span>\n"
	if(display_shoes)
		msg += "<span class='warning'><b>[src] has blood running from [t_his] shoes!</b></span>\n"
	if(display_gloves)
		msg += "<span class='warning'><b>[src] has blood running from under [t_his] gloves!</b></span>\n"


//		if(w.bleeding)
//			usr << "\red [src.name] is bleeding from a [sizetext] on [t_his] [temp.display_name]."
//			continue

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

	if(print_flavor_text()) msg += "[print_flavor_text()]\n"

	msg += "\blue *---------*"
	usr << msg
