///These are for the medisim shuttle

#define REDFIELD_TEAM "Red"
#define BLUESWORTH_TEAM "Blue"

/obj/machinery/capture_the_flag/medisim
	game_id = "medieval"
	game_area = /area/shuttle/escape/simulation
	ammo_type = null //no guns, no need
	var/total_computers = 0
	var/computers = 0
	var/corruption = 0
	var/list/current_corruptions = list()

/obj/machinery/capture_the_flag/medisim/Initialize(mapload)
	. = ..()
	start_ctf()
	for(var/obj/machinery/computer/reality_simulation/computer in GLOB.machines)
		computers++
		computer.connected_ctf += src
	total_computers = computers

/obj/machinery/capture_the_flag/medisim/proc/corrupt()
	corruption++

	if(MODULUS(corruption, 3) != 0)//3, 6, 9, and 12 apply a special corruption effect
		return


/obj/machinery/capture_the_flag/medisim/victory()
	. = ..()
	start_ctf()//so admins don't have to enable it again, they can just go

/obj/machinery/capture_the_flag/medisim/spawn_team_member(client/new_team_member)
	var/mob/living/carbon/human/human_knight = ..()
	human_knight.remove_all_languages(LANGUAGE_CTF)
	human_knight.grant_language(language = /datum/language/oldworld, understood = TRUE, spoken = TRUE, source = LANGUAGE_CTF)
	randomize_human(human_knight)
	human_knight.dna.add_mutation(MEDIEVAL, MUT_OTHER)
	var/oldname = human_knight.name
	var/title = "error"
	switch (human_knight.gender)
		if (MALE)
			title = pick(list("Sir", "Lord"))
		if (FEMALE)
			title = pick(list("Dame", "Lady"))
		else
			title = "Noble"
	human_knight.real_name = "[title] [oldname]"
	human_knight.name = human_knight.real_name

/obj/machinery/capture_the_flag/medisim/red
	name = "\improper Redfield Data Realizer"
	icon_state = "syndbeacon"
	team = REDFIELD_TEAM
	team_span = "redteamradio"
	ctf_gear = /datum/outfit/medisimred

/obj/machinery/capture_the_flag/medisim/blue
	name = "\improper Bluesworth Data Realizer"
	icon_state = "bluebeacon"
	team = BLUESWORTH_TEAM
	team_span = "blueteamradio"
	ctf_gear = /datum/outfit/medisimblue

/obj/item/ctf/red/medisim
	name = "\improper Redfield Castle Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_nuke"
	game_area = /area/shuttle/escape
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that

/obj/item/ctf/blue/medisim
	name = "\improper Bluesworth Hold Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_slime"
	game_area = /area/shuttle/escape
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that

/datum/outfit/medisimred
	name = "Redfield Castle Knight"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/plate/red
	suit = /obj/item/clothing/suit/armor/riot/knight/red
	gloves = /obj/item/clothing/gloves/plate/red
	head = /obj/item/clothing/head/helmet/knight/red
	r_hand = /obj/item/claymore

/datum/outfit/medisimblue
	name = "Bluesworth Hold Knight"

	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/plate/blue
	suit = /obj/item/clothing/suit/armor/riot/knight/blue
	gloves = /obj/item/clothing/gloves/plate/blue
	head = /obj/item/clothing/head/helmet/knight/blue
	r_hand = /obj/item/claymore

/obj/machinery/computer/reality_simulation
	name = "reality simulation computer"
	desc = "A computer calculating the medieval times. Uh, wow. Is this bad boy quantum?"
	var/list/connected_ctf = list()
	var/corrupted = FALSE

/obj/machinery/computer/reality_simulation/emag_act(mob/user, obj/item/card/emag/E)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The computer is messed up beyond all recognition, no way you're gonna be able to undo that.</span")
		return
	to_chat(user, "<span class='warning'>One short pass of the card and the reality simulations start spewing endless, increasingly conflicting errors!</span>")
	for(var/ctf in connected_ctf)
		var/obj/machinery/capture_the_flag/medisim/ctf_machine = ctf
		ctf_machine.corrupt()
	obj_flags |= EMAGGED
	var/corruption = ctf_machine.corruption
	var/corruption_percent = PERCENT(corruption/ctf_machine.total_computers)
	var/advice
	switch(corruption)
		if(1 to 4)
			advice = "Please consult a network administrator for possible reboot."
		if(5 to 8)
			advice = "Please shut down the machine and contact a reality engineer."
		else
			advice = "FATAL ERROR PREVENTION CORRUPT. REALITY DEATH IMMINENT."
	var/before_percent = "[corruption <= 6 ? "WARNING" : "DANGER"]: Reality fault at "
	var/after_percent = "%. [advice]"
	if(corruption >= 3)
		var/scramble_percentage = PERCENT((corruption-2)/(ctf_machine.total_computers-2)) //so it doesn't jump from 0 percent to 20%
		before_percent = scramble_message_replace_chars(before_percent, replaceprob = scramble_percentage, replace_letters_only = TRUE)
		after_percent = scramble_message_replace_chars(after_percent, replaceprob = scramble_percentage, replace_letters_only = TRUE)
	if(corruption >= 6)
		before_percent = uppertext(before_percent)
		after_percent = uppertext(after_percent)
	say(before_percent + corruption_percent + after_percent)


#undef REDFIELD_TEAM
#undef BLUESWORTH_TEAM
