/datum/religion_rites
	var/name = "religious rite"
	var/desc = "immm gonna rooon"
	var/ritual_length = (10 SECONDS) //total length it'll take
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
	var/favor_cost = 0
	var/datum/religion_sect/owned_sect

/datum/religion_rites/New(obj/structure/altar_of_gods/AOG)
	if(!istype(AOG,/obj/structure/altar_of_gods))
		return
	owned_sect = AOG.sect_to_altar



///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && istype(AOG, /obj/structure/altar_of_gods))
		owned_sect = AOG.sect_to_altar
	if(owned_sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
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
/datum/religion_rites/proc/InvokeEffect(mob/living/user, obj/structure/altar_of_gods/AOG)
	return TRUE

/datum/religion_rites/tester
	name = "aheal rite"
	desc = "aheals the user"
	ritual_length = (10 SECONDS)
	ritual_invocations = list("hey babe", "what's your number", "got kik?", "winky face!")
	favor_cost = 1

/datum/religion_rites/tester/InvokeEffect(mob/living/user)
	return user.fully_heal(admin_revive = TRUE)

/datum/religion_rites/tester2
	name = "color rite"
	desc = "aheals the user"
	ritual_length = (10 SECONDS)
	ritual_invocations = list("hey babe", "what's your number", "got kik?", "winky face!")
	favor_cost = 1

/datum/religion_rites/tester2/InvokeEffect(mob/living/user)
	. = ..()
	user.color = COLOR_RED
