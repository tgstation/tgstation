/obj/item/mr_bones_voice_box
	name = "voice box"
	desc = "It sounds like an early era Source game."
	icon = 'icons/obj/storage.dmi'
	icon_state = "giftdeliverypackage3"
	inhand_icon_state = "gift"
	var/list/bone_phrases = list("ERROR: Incorrect Answer","Roleplay","No","Solve the Riddle","Repeat","Your Problem")

/obj/item/mr_bones_voice_box/attack_self(mob/user)
	var/choice = input(user, "Select Your Phrase", "Mr.Bones Rattler 3000") as null|anything in bone_phrases

	switch(choice)
		if("ERROR: Incorrect Answer")
			playsound(user, 'sound/voice/mrbones/error_incorrect.ogg', 50)
			user.say("ERROR: Incorrect answer.")
		if("Solve the Riddle")
			playsound(user, 'sound/voice/mrbones/solve_the_riddle.ogg', 50)
			user.say("You need to solve the riddle.")
		if("Repeat")
			playsound(user, 'sound/voice/mrbones/repeat.ogg', 50)
			user.say("Repeat your answer, please.")
		if("Roleplay")
			playsound(user, 'sound/voice/mrbones/roleplay.ogg', 50)
			user.say("Please roleplay appropriately, ok.")
		if("Your Problem")
			playsound(user, 'sound/voice/mrbones/your_problem_buddy.ogg', 50)
			user.say("That's your problem, buddy.")
		if("No")
			playsound(user, 'sound/voice/mrbones/no.ogg', 50)
			user.say("No.")
	new /obj/effect/temp_visual/source_mic(get_turf(user))
