/mob/living/carbon/monkey/examine()
	set src in oview()

	if(!usr || !src)	return
	if(((usr.sdisabilities & 1) || usr.blinded || usr.stat) && !(istype(usr,/mob/dead/observer/)))
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"

	if (src.handcuffed)
		msg += "It is \icon[src.handcuffed] handcuffed!\n"
	if (src.wear_mask)
		msg += "It has \icon[src.wear_mask] \a [src.wear_mask] on its head.\n"
	if (src.l_hand)
		msg += "It has \icon[src.l_hand] \a [src.l_hand] in its left hand.\n"
	if (src.r_hand)
		msg += "It has \icon[src.r_hand] \a [src.r_hand] in its right hand.\n"
	if (src.back)
		msg += "It has \icon[src.back] \a [src.back] on its back.\n"
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>It is limp and unresponsive, with no signs of life.</span>\n"

	var/list/wound_descriptions = list()
	var/list/wound_flavor_text = list()
	for(var/named in organs)
		var/datum/organ/external/temp = organs[named]
		if(temp)
			if(temp.destroyed)
				wound_flavor_text["[temp.display_name]"] = "<span class='warning'><b>It is missing its [temp.display_name].</b></span>\n"
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
	var/list/is_bleeding = list()
	for(var/named in wound_descriptions)
		var/list/wound_states = wound_descriptions[named]
		var/list/flavor_text = list()
		for(var/i = 1, i <= 6, i++)
			var/list/wound_state = wound_states[i] //All wounds at this level of healing.
			var/list/tally = list("cut" = 0, "deep cut" = 0, "flesh wound" = 0, "gaping wound" = 0, "big gaping wound" = 0, "massive wound" = 0,\
			 "tiny bruise" = 0, "small bruise" = 0, "moderate bruise" = 0, "large bruise" = 0, "huge bruise" = 0, "monumental bruise" = 0,\
			 "small burn" = 0, "moderate burn" = 0, "large burn" = 0, "severe burn" = 0, "deep burn" = 0, "carbonised area" = 0) //How many wounds of what size.
			for(var/datum/organ/wound/w in wound_state)
				if(w.bleeding && !is_bleeding[named]) is_bleeding[named] = 1
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
						if(tallied in list("cut","small burn"))
							continue
						tallied_rename = list("deep cut" = "clotted cut", "flesh wound" = "small bandaged wound",\
						"gaping wound" = "bandaged wound", "big gaping wound" = "gauze wrapped wound",\
						"massive wound" = "massive blood soaked bandage", "tiny bruise" = "tiny bruise", "small bruise" = "small bruise",\
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
						if(tallied in list("cut","deep cut","tiny bruise", "moderate bruise", "small bruise","small burn", "moderate burn"))
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
							flavor_text += "<span class='warning'>\The [src] has[prob(4) && !(tallied in no_exclude)  ? " what might be" : ""] a [tallied_rename[tallied]]"
						else
							flavor_text += "[prob(4) && !(tallied in no_exclude) ? " what might be" : ""] a [tallied_rename[tallied]]"
					if(2)
						if(!flavor_text.len)
							flavor_text += "<span class='warning'>\The [src] has[prob(4) && !(tallied in no_exclude) ? " what might be" : ""] a pair of [tallied_rename[tallied]]s"
						else
							flavor_text += "[prob(4) && !(tallied in no_exclude) ? " what might be" : ""] a pair of [tallied_rename[tallied]]s"
					if(3 to 5)
						if(!flavor_text.len)
							flavor_text += "<span class='warning'>\The [src] has several [tallied_rename[tallied]]s"
						else
							flavor_text += " several [tallied_rename[tallied]]s"
					if(6 to INFINITY)
						if(!flavor_text.len)
							flavor_text += "<span class='warning'>\The [src] has a bunch of [tallied_rename[tallied]]s"
						else
							flavor_text += " a ton of [tallied_rename[tallied]]s"
		if(flavor_text.len)
			var/flavor_text_string = ""
			for(var/text = 1, text <= flavor_text.len, text++)
				if(text == flavor_text.len && flavor_text.len > 1)
					flavor_text_string += ", and"
				else if(flavor_text.len > 1 && text > 1)
					flavor_text_string += ","
				flavor_text_string += flavor_text[text]
			flavor_text_string += " on its [named].</span><br>"
			wound_flavor_text["[named]"] = flavor_text_string
	if(wound_flavor_text["head"])
		msg += wound_flavor_text["head"]
	if(wound_flavor_text["chest"])
		msg += wound_flavor_text["chest"]
	if(wound_flavor_text["left arm"])
		msg += wound_flavor_text["left arm"]
	if(wound_flavor_text["left hand"])
		msg += wound_flavor_text["left hand"]
	if(wound_flavor_text["right arm"])
		msg += wound_flavor_text["right arm"]
	if(wound_flavor_text["right hand"])
		msg += wound_flavor_text["right hand"]
	if(wound_flavor_text["groin"])
		msg += wound_flavor_text["groin"]
	if(wound_flavor_text["left leg"])
		msg += wound_flavor_text["left leg"]
	if(wound_flavor_text["left foot"])
		msg += wound_flavor_text["left foot"]
	if(wound_flavor_text["right leg"])
		msg += wound_flavor_text["right leg"]
	if(wound_flavor_text["right foot"])
		msg += wound_flavor_text["right foot"]


	msg += "[print_flavor_text()]\n"

	msg += "*---------*</span>"

	usr << msg
	return