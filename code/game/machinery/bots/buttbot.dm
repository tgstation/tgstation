/*
I..

I'm so sorry.

I'm so very, very sorry.

Here it is: Buttbot.
*/

/obj/machinery/bot/buttbot
	name = "butt bot"
	desc = "Guaranteed to shitpost for at least 6 months."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "buttbot"
	layer = 5.0
	density = 0
	anchored = 0
	//weight = 1.0E7
	health = 25
	maxhealth = 25
	var/buttchance = 80 //Like an 80% chance of it working. It's just a butt with an arm in it.
	var/sincelastfart = 0
	var/mob/living/carbon/victim = null
	var/mob/living/carbon/oldvictim = null
	var/last_found = 0
	flags = HEAR

/obj/machinery/bot/buttbot/bot_process()

	if(frustration > 8)
		oldvictim = victim
		victim = null
		mode = BOT_IDLE
		last_found = world.time
		path = list()

	victim = scan(/mob/living/carbon/human, oldvictim, 7)

	if(victim && path.len && (get_dist(victim,path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	if(victim && path.len == 0 && (get_dist(src,victim) > 1))
		spawn(0)
			path = get_path_to(loc, get_turf(victim), src, /turf/proc/Distance_cardinal, 0, 30,id=botcard)

	if(path.len > 0 && victim)
		if(!bot_move(victim))
			oldvictim = victim
			victim = null
			mode = BOT_IDLE
			last_found = world.time
		return

	if(path.len > 8 && victim)
		frustration++


/obj/machinery/bot/buttbot/attack_hand(mob/living/user as mob)
	. = ..()
	if (.)
		return
	if(sincelastfart + 5 < world.timeofday)
		speak("butt")
		playsound(get_turf(src), 'sound/items/drink.ogg', 50, 1) //slurp
		sincelastfart = world.timeofday

/obj/machinery/bot/buttbot/Hear(message, atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	if(prob(buttchance) && !findtext(message,"butt"))
		message = strip_html(html_decode(raw_message))

		var/list/split_phrase = text2list(message," ") //Split it up into words.

		var/list/prepared_words = split_phrase.Copy()
		var/i = rand(1,3)
		for(,i > 0,i--) //Pick a few words to change.

			if (!prepared_words.len)
				break
			var/word = pick(prepared_words)
			prepared_words -= word //Remove from unstuttered words so we don't stutter it again.
			var/index = split_phrase.Find(word) //Find the word in the split phrase so we can replace it.

			split_phrase[index] = pick("slurp","meta","cuck","filtered","proprietary","white wash","cancer")

		say(sanitize(list2text(split_phrase," ")))
	return



/obj/machinery/bot/buttbot/explode()
	src.on = 0
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	playsound(get_turf(src), 'sound/items/drink.ogg', 50, 1) //slurp
	var/turf/Tsec = get_turf(src)
	new /obj/item/clothing/head/butt(Tsec)
	for(var/mob/O in hearers(src, null))
		O.show_message("<b>[src]</b> yells: FUCKING FILTERED, YOU METAGAMING CUCK! SLURP SLURP SLURP!")

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/remains/robot(src.loc)
	qdel(src)


/obj/item/clothing/head/butt/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		qdel(W)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/buttbot/A = new /obj/machinery/bot/buttbot(T)
		A.name = src.created_name
		user << "<span class='notice'>You roughly shove the robot arm into the ass! Butt Butt!</span>" //I don't even.
		user.drop_item()
		qdel(W)
		qdel(src)
	else if (istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", src.name, src.created_name)

		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t
