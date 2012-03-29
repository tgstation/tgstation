/mob/living/carbon/human/tajaran/examine()
	set src in oview()

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

	msg += "<EM>\a [src], one of the cat-like Tajarans.</EM>!\n"

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
		msg += "[t_He] [t_is] \icon[src.handcuffed] handcuffed!\n"

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

	if (src.suiciding)
		msg += "<span class='warning'>[t_He] [t_has] bitten off [t_his] own tongue and [t_has] suffered major bloodloss!</span>\n"

	var/distance = get_dist(usr,src)
	if(istype(usr, /mob/dead/observer) || usr.stat == 2) // ghosts can see anything
		distance = 1

	if (src.stat == 1 || stat == 2)
		msg += "<span class='warning'>[name] doesn't seem to be responding to anything around [t_him], [t_his] eyes closed as though asleep.</span>\n"
		if((!isbreathing || holdbreath) && distance <= 3)
			msg += "<span class='warning'>[name] does not appear to be breathing.</span>\n"
		if(istype(usr, /mob/living/carbon/human) && usr.stat == 0 && src.stat == 1 && distance <= 1)
			for(var/mob/O in viewers(usr.loc, null))
				O.show_message("[usr] checks [src]'s pulse.", 1)
			spawn(15)
				usr << "\blue [name] has a pulse!"

	if (src.stat == 2 || (changeling && changeling.changeling_fakedeath == 1))
		if(distance <= 1)
			if(istype(usr, /mob/living/carbon/human) && usr.stat == 0)
				for(var/mob/O in viewers(usr.loc, null))
					O.show_message("[usr] checks [src]'s pulse.", 1)
			spawn(15)
				usr << "\red [name] has no pulse!"

/*	if (src.getBruteLoss())
		if (src.getBruteLoss() < 30)
			usr << "\red [src.name] looks slightly injured!"
		else
			usr << "\red <B>[src.name] looks severely injured!</B>"*/

	if (src.cloneloss)
		if (src.cloneloss < 30)
			msg += "<span class='warning'>[src.name] looks slightly... unfinished?</span>\n"
		else
			msg += "<span class='warning'>[src.name] looks very... unfinished?</B></span>\n"

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

	if (!src.client)
		msg += "[t_He] [t_has] a vacant, braindead stare...\n"

	var/list/wound_descriptions = list()
	var/list/wound_flavor_text = list()
	for(var/named in organs)
		var/datum/organ/external/temp = organs[named]
		if(temp)
			if(temp.destroyed)
				wound_flavor_text["[temp.display_name]"] = "<span class='warning'><b>[src.name] is missing [t_his] [temp.display_name].</b></span>\n"
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
			else
				wound_flavor_text["[temp.display_name]"] = ""
	//Now that we have a big list of all the wounds, on all the limbs.
	for(var/named in wound_descriptions)
		var/list/wound_states = wound_descriptions[named]
		var/list/flavor_text = list()
		for(var/i = 1, i <= 6, i++)
			var/list/wound_state = wound_states[i] //All wounds at this level of healing.
			var/list/tally = list("cut" = 0, "deep cut" = 0, "flesh wound" = 0, "gaping wound" = 0, "big gaping wound" = 0, "massive wound" = 0,\
			 "tiny bruise" = 0, "small bruise" = 0, "moderate bruise" = 0, "large bruise" = 0, "huge bruise" = 0, "monumental bruise" = 0,\
			 "small burn" = 0, "moderate burn" = 0, "large burn" = 0, "severe burn" = 0, "deep burn" = 0, "carbonised area" = 0) //How many wounds of what size.
			for(var/datum/organ/wound/w in wound_state)
				switch(w.wound_size)
					if(1)
						switch(w.wound_type)
							if(0)
								tally["cut"] += 1
							if(1)
								tally["tiny bruise"] += 1
							if(2)
								tally["small burn"] += 1
					if(2)
						switch(w.wound_type)
							if(0)
								tally["deep cut"] += 1
							if(1)
								tally["small bruise"] += 1
							if(2)
								tally["moderate burn"] += 1
					if(3)
						switch(w.wound_type)
							if(0)
								tally["flesh wound"] += 1
							if(1)
								tally["moderate bruise"] += 1
							if(2)
								tally["large burn"] += 1
					if(4)
						switch(w.wound_type)
							if(0)
								tally["gaping wound"] += 1
							if(1)
								tally["large bruise"] += 1
							if(2)
								tally["severe burn"] += 1
					if(5)
						switch(w.wound_type)
							if(0)
								tally["big gaping wound"] += 1
							if(1)
								tally["huge bruise"] += 1
							if(2)
								tally["deep burn"] += 1
					if(6)
						switch(w.wound_type)
							if(0)
								tally["massive wound"] += 1
							if(1)
								tally["monumental bruise"] += 1
							if(2)
								tally["carbonised area"] += 1
			for(var/tallied in tally)
				if(!tally[tallied])
					continue
				//if(flavor_text_string && tally[tallied])
				//	for(
				//	flavor_text_string += pick(list(", as well as", ", in addition to")) //add more later.
				var/tallied_rename = list("cut" = "cut","deep cut" = "deep cut", "flesh wound" = "flesh wound",\
				"gaping wound" = "gaping wound", "big gaping wound" = "big gaping wound", "massive wound" = "massive wound",\
				"tiny bruise" = "tiny bruise", "small bruise" = "small bruise", "moderate bruise" = "moderate bruise",\
				"large bruise" = "large bruise", "huge bruise" = "huge bruise", "monumental bruise" = "monumental bruise",\
			 	"small burn" = "small burn", "moderate burn" = "moderate burn", "large burn" = "large burn",\
			 	"severe burn" = "severe burn", "deep burn" = "deep burn", "carbonised area" = "carbonised area")
				switch(i)
					if(2) //Healing wounds.
						if(tallied in list("cut","tiny bruise","small burn"))
							continue
						tallied_rename = list("deep cut" = "clotted cut", "flesh wound" = "small bandaged wound",\
						"gaping wound" = "bandaged wound", "big gaping wound" = "gauze wrapped wound",\
						"massive wound" = "massive blood soaked bandage", "small bruise" = "small bruise",\
						"moderate bruise" = "moderate bruise", "large bruise" = "large bruise",\
						"huge bruise" = "huge bruise", "monumental bruise" = "monumental bruise",\
						"moderate burn" = "moderate salved burn", "large burn" = "large salved burn",\
						"severe burn" = "severe salved burn", "deep burn" = "deep salved burn",\
						"carbonised area" = "treated carbonised area")
					if(3)
						if(tallied in list("cut","tiny bruise","small burn"))
							continue
						tallied_rename = list("deep cut" = "fading cut", "flesh wound" = "small healing wound",\
						"gaping wound" = "healing wound", "big gaping wound" = "big healing wound",\
						"massive wound" = "massive healing wound", "small bruise" = "tiny bruise",\
						"moderate bruise" = "small bruise", "large bruise" = "moderate bruise",\
						"huge bruise" = "large bruise", "monumental bruise" = "huge bruise",\
						"moderate burn" = "healing moderate burn", "large burn" = "healing large burn",\
						"severe burn" = "healing severe burn", "deep burn" = "healing deep burn",\
						"carbonised area" = "slowly healing carbonised area")
					if(4)
						if(tallied in list("cut","deep cut","tiny bruise", "small bruise","small burn", "moderate burn"))
							continue
						tallied_rename = list("flesh wound" = "small red scar", "gaping wound" = "angry straight scar",\
						"big gaping wound" = "jagged angry scar", "massive wound" = "gigantic angry scar",\
						"moderate bruise" = "tiny bruise", "large bruise" = "small bruise",\
						"huge bruise" = "moderate bruise", "monumental bruise" = "large bruise",\
						"large burn" = "large burn scar", "severe burn" = "severe burn scar",\
						 "deep burn" = "deep burn scar", "carbonised area" = "healing carbonised area")
					if(5)
						if(tallied in list("cut","deep cut","tiny bruise", "small bruise", "moderate bruise","small burn", "moderate burn"))
							continue
						tallied_rename = list("flesh wound" = "small scar", "gaping wound" = "straight scar",\
						"big gaping wound" = "jagged scar", "massive wound" = "gigantic scar",\
						"large bruise" = "tiny bruise",\
						"huge bruise" = "small bruise", "monumental bruise" = "moderate bruise",\
						"large burn" = "large burn scar", "severe burn" = "severe burn scar",\
						 "deep burn" = "deep burn scar", "carbonised area" = "large scarred area")
					if(6)
						if(tallied in list("cut","deep cut","flesh wound","tiny bruise", "small bruise", "moderate bruise", "large bruise", "huge bruise","small burn", "moderate burn"))
							continue
						tallied_rename = list("gaping wound" = "straight scar",\
						"big gaping wound" = "jagged scar", "massive wound" = "gigantic scar",\
						"monumental bruise" = "tiny bruise",\
						"large burn" = "large burn scar", "severe burn" = "severe burn scar",\
						 "deep burn" = "deep burn scar", "carbonised area" = "large scarred area")
				var/list/no_exclude = list("gaping wound", "big gaping wound", "massive wound", "large bruise",\
				"huge bruise", "massive bruise", "severe burn", "large burn", "deep burn", "carbonised area")
				switch(tally[tallied])
					if(1)
						if(!flavor_text.len)
							flavor_text += "<span class='warning'>[src] has[prob(4) && !(tallied in no_exclude)  ? " what might be" : ""] a [tallied_rename[tallied]]"
						else
							flavor_text += "[prob(4) && !(tallied in no_exclude) ? " what might be" : ""] a [tallied_rename[tallied]]"
					if(2)
						if(!flavor_text.len)
							flavor_text += "<span class='warning'>[src] has[prob(4) && !(tallied in no_exclude) ? " what might be" : ""] a pair of [tallied_rename[tallied]]s"
						else
							flavor_text += "[prob(4) && !(tallied in no_exclude) ? " what might be" : ""] a pair of [tallied_rename[tallied]]s"
					if(3 to 5)
						if(!flavor_text.len)
							flavor_text += "<span class='warning'>[src] has several [tallied_rename[tallied]]s"
						else
							flavor_text += " several [tallied_rename[tallied]]s"
					if(6 to INFINITY)
						if(!flavor_text.len)
							flavor_text += "<span class='warning'>[src] has a bunch of [tallied_rename[tallied]]s"
						else
							flavor_text += " a ton of [tallied_rename[tallied]]s"
		if(flavor_text.len)
			var/flavor_text_string = ""
			for(var/text = 1, text <= flavor_text.len, text++)
				if(text == flavor_text.len && flavor_text.len > 1)
					flavor_text_string += ", and"
				else if(flavor_text.len > 1)
					flavor_text_string += ","
				flavor_text_string += flavor_text[text]
			flavor_text_string += " on [t_his] [named].</span><br>"
			wound_flavor_text["[named]"] = flavor_text_string
	if(wound_flavor_text["head"] && !skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))
		msg += wound_flavor_text["head"]
	if(wound_flavor_text["chest"] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text["chest"]
	if(wound_flavor_text["left arm"] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text["left arm"]
	if(wound_flavor_text["left hand"] && !gloves && !skipgloves)
		msg += wound_flavor_text["left hand"]
	if(wound_flavor_text["right arm"] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text["right arm"]
	if(wound_flavor_text["right hand"] && !gloves && !skipgloves)
		msg += wound_flavor_text["right hand"]
	if(wound_flavor_text["groin"] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text["groin"]
	if(wound_flavor_text["left leg"] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text["left leg"]
	if(wound_flavor_text["left foot"]&& !shoes && !skipshoes)
		msg += wound_flavor_text["left foot"]
	if(wound_flavor_text["right leg"] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text["right leg"]
	if(wound_flavor_text["right foot"]&& !shoes  && !skipshoes)
		msg += wound_flavor_text["right foot"]


//		if(w.bleeding)
//			usr << "\red [src.name] is bleeding from a [sizetext] on [t_his] [temp.display_name]."
//			continue

	msg += print_flavor_text()

	msg += "\blue *---------*"
	usr << msg
