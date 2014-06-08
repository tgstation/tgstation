/*
I..

I'm so sorry.

I'm so very, very sorry.

Here it is: Buttbot.
*/

/obj/machinery/bot/buttbot
	name = "butt bot"
	desc = "Somehow, this doesn't bode well with you."
	icon = 'aibots.dmi'
	icon_state = "buttbot"
	layer = 5.0
	density = 0
	anchored = 0
	//weight = 1.0E7
	health = 25
	maxhealth = 25
	var/buttchance = 10

/obj/machinery/bot/buttbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	speak("butt")



/obj/machinery/bot/buttbot/proc/speak(var/message)
	if((!src.on) || (!message))
		return
	for(var/mob/O in hearers(src, null))
		O.show_message("<b>[src]</b> beeps, '[message]'")
	return


/obj/machinery/bot/buttbot/hear_talk(mob/M as mob, msg)
	if(prob(buttchance))
		msg = html_decode(msg)

		var/list/split_phrase = text2list(msg," ") //Split it up into words.

		var/list/prepared_words = split_phrase.Copy()
		var/i = rand(1,3)
		for(,i > 0,i--) //Pick a few words to change.

			if (!prepared_words.len)
				break
			var/word = pick(prepared_words)
			prepared_words -= word //Remove from unstuttered words so we don't stutter it again.
			var/index = split_phrase.Find(word) //Find the word in the split phrase so we can replace it.

			split_phrase[index] = "butt"

		speak(sanitize(dd_list2text(split_phrase," ")))



/obj/machinery/bot/buttbot/explode()
	src.on = 0
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)
	new /obj/item/clothing/head/butt(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	del(src)

/obj/item/clothing/head/butt/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		var/obj/machinery/bot/buttbot/A = new /obj/machinery/bot/buttbot
		if(user.r_hand == src || user.l_hand == src)
			A.loc = user.loc
		else
			A.loc = src.loc
		user << "You add the robot arm to the butt! Beep boop!"
		del(W)
		loc = A
