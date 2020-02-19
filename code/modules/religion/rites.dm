/datum/religion_rites
	var/name = "religious rite"
	var/desc = "immm gonna rooon"
	var/ritual_length = (10 SECONDS) //total length it'll take
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
	var/favor_cost = 0

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(GLOB.sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
			return TRUE
		return FALSE
	var/c_c_combo = 0
	for(var/i in ritual_invocations)
		addtimer(CALLBACK(user, /atom/movable/proc/say, i), (ritual_length/ritual_invocations.len)*c_c_combo) //first one is instant
		c_c_combo++
	if(do_after(user, target = user, delay = ritual_length))
		return TRUE

///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	GLOB.sect.on_riteuse(user,AOG)
	return TRUE


/*********Technophiles**********/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = 1 MINUTES
	ritual_invocations = list("By the inner workings of our god...",
						"... We call upon you, in the face of adversary...",
						"... to complete us, removing that which is undesirable...",
						"... Arise, our champion! Become that which your soul craves, live in the world as your true form!!")
	favor_cost = 500

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!AOG?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2borg
	for(var/i in AOG.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2borg = i
			break
	if(!human2borg)
		return FALSE
	human2borg.set_species(/datum/species/android)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	return TRUE
