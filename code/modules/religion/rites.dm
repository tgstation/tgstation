/datum/religion_rites
/// name of the religious rite
	var/name = "religious rite"
/// Description of the religious rite
	var/desc = "immm gonna rooon"
/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
/// list of invocations said (strings) throughout the rite
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!ritual_invocations.len) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len)) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	GLOB.religious_sect.on_riteuse(user,AOG)
	return TRUE


/*********Technophiles**********/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = 1 MINUTES
	ritual_invocations = list("By the inner workings of our god...",
						"... We call upon you, in the face of adversity...",
						"... to complete us, removing that which is undesirable...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 500

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!AOG?.buckled_mobs?.len)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE
	return ..()

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

/*********DRUIDS!**********/

/datum/religion_rites/druid
	var/required_thing = list(/obj/item/reagent_containers/food/snacks/grown)
	var/obj/found_thing

/datum/religion_rites/druid/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/turf/T = get_turf(AOG)
	for(var/obj/i in T)
		if(i in required_thing)
			found_thing = i
	if(!found_thing)
		return FALSE
	return ..()

/datum/religion_rites/druid/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/turf/T = get_turf(AOG)
	if(!(found_thing in T))
		return FALSE
	return ..()

/datum/religion_rites/druid/create
	name = "Jungle Armor"
	desc = "Create some druid clothing. Mostly shows how wonderful you are! Needs a plant on the altar."
	ritual_length = 30 SECONDS
	ritual_invocations = list("Nature is beautiful...",
						"... Nature is meaningful...",
						"... Nature is robust...")
	invoke_msg = "... So lets make use of it! This piece is done!"
	favor_cost = 50

/datum/religion_rites/druid/create/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
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

/datum/religion_rites/druid/upgrade
	name = "Jungle Upgrade"
	desc = "Upgrade druid gear placed on the altar! Stun the station! Needs the basic druid clothing you intend to upgrade on the altar."
	ritual_length = 30 SECONDS
	ritual_invocations = list("This needs more potency...",
						"... This needs more yield...",
						"... This needs more panache...")
	invoke_msg = "... So by the power of our wonderful god...This piece has improved!"
	favor_cost = 200
	required_thing = list(/obj/item/clothing/head/druid)

/obj/item/clothing/head/druid
	name = "druidic crown"
	desc = "Like the tuning forks for druids, really. They love this shit."
	icon_state = "druidbasic"
