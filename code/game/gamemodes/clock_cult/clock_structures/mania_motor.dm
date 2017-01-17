//Mania Motor: A pair of antenna that, while active, cause braindamage and hallucinations in nearby human mobs.
/obj/structure/destructible/clockwork/powered/mania_motor
	name = "mania motor"
	desc = "A pair of antenna with what appear to be sockets around the base. It reminds you of an antlion."
	clockwork_desc = "A transmitter that allows Sevtug to whisper into the minds of nearby non-servants, causing hallucinations and brain damage as long as it remains powered."
	icon_state = "mania_motor_inactive"
	active_icon = "mania_motor"
	inactive_icon = "mania_motor_inactive"
	unanchored_icon = "mania_motor_unwrenched"
	construction_value = 20
	max_integrity = 80
	obj_integrity = 80
	break_message = "<span class='warning'>The antenna break off, leaving a pile of shards!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/small = 3, \
	/obj/item/clockwork/component/geis_capacitor/antennae = 1)
	var/mania_cost = 200
	var/convert_attempt_cost = 500
	var/convert_cost = 500
	var/static/list/mania_messages = list("Go nuts.", "Take a crack at crazy.", "Make a bid for insanity.", "Get kooky.", "Move towards mania.", "Become bewildered.", "Wax wild.", \
	"Go round the bend.", "Land in lunacy.", "Try dementia.", "Strive to get a screw loose.")
	var/static/list/compel_messages = list("Come closer.", "Approach the transmitter.", "Touch the antennae.", "I always have to deal with idiots. Move towards the mania motor.", \
	"Advance forward and place your head between the antennae - that's all it's good for.", "If you were smarter, you'd be over here already.", "Move FORWARD, you fool.")
	var/static/list/convert_messages = list("You won't do. Go to sleep while I tell these nitwits how to convert you.", "You are insufficient. I must instruct these idiots in the art of conversion.", \
	"Oh of course, someone we can't convert. These servants are fools.", "How hard is it to use a Sigil, anyway? All it takes is dragging someone onto it.", \
	"How do they fail to use a Sigil of Accession, anyway?", "Why is it that all servants are this inept?", "It's quite likely you'll be stuck here for a while.")
	var/static/list/close_messages = list("Well, you can't reach the motor from THERE, you moron.", "Interesting location. I'd prefer if you went somewhere you could ACTUALLY TOUCH THE ANTENNAE!", \
	"Amazing. You somehow managed to wedge yourself somewhere you can't actually reach the motor from.", "Such a show of idiocy is unparalleled. Perhaps I should put you on display?", \
	"Did you do this on purpose? I can't imagine you doing so accidentally. Oh, wait, I can.", "How is it that such smart creatures can still do something AS STUPID AS THIS!")


/obj/structure/destructible/clockwork/powered/mania_motor/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='sevtug_small'>It requires <b>[mania_cost]W</b> to run, and <b>[convert_attempt_cost + convert_cost]W</b> to convert humans adjecent to it.</span>"

/obj/structure/destructible/clockwork/powered/mania_motor/forced_disable(bad_effects)
	if(active)
		if(bad_effects)
			try_use_power(MIN_CLOCKCULT_POWER*4)
		visible_message("<span class='warning'>[src] hums loudly, then the sockets at its base fall dark!</span>")
		playsound(src, 'sound/effects/screech.ogg', 40, 1)
		toggle()
		return TRUE

/obj/structure/destructible/clockwork/powered/mania_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src, !issilicon(user)) && is_servant_of_ratvar(user))
		if(!total_accessable_power() >= mania_cost)
			user << "<span class='warning'>[src] needs more power to function!</span>"
			return 0
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/mania_motor/toggle(fast_process, mob/living/user)
	. = ..()
	if(active)
		SetLuminosity(2, 1)
	else
		SetLuminosity(0)

/obj/structure/destructible/clockwork/powered/mania_motor/process()
	if(try_use_power(mania_cost))
		var/turf/T = get_turf(src)
		var/hum = get_sfx('sound/effects/screech.ogg') //like playsound, same sound for everyone affected
		var/efficiency = get_efficiency_mod()
		for(var/mob/living/carbon/human/H in view(1, src))
			if(is_servant_of_ratvar(H) || H.null_rod_check())
				continue
			if(H.Adjacent(src) && try_use_power(convert_attempt_cost))
				if(is_eligible_servant(H) && try_use_power(convert_cost))
					H << "<span class='sevtug'>\"[text2ratvar("You are mine and his, now.")]\"</span>"
					H.playsound_local(T, hum, 80, 1)
					add_servant_of_ratvar(H)
					H.Paralyse(5)
				else if(!H.stat)
					if(H.getBrainLoss() >= 100)
						H.Paralyse(5)
						H << "<span class='sevtug'>\"[text2ratvar(pick(convert_messages))]\"</span>"
					else
						H.adjustBrainLoss(100 * efficiency)
						H.visible_message("<span class='warning'>[H] reaches out and touches [src].</span>", "<span class='sevtug'>You touch [src] involuntarily.</span>")
			else
				visible_message("<span class='warning'>[src]'s antennae fizzle quietly.</span>")
				playsound(src, 'sound/effects/light_flicker.ogg', 50, 1)
		for(var/mob/living/carbon/human/H in range(10, src))
			if(is_servant_of_ratvar(H))
				if(H.getBrainLoss() || H.hallucination || H.druggy || H.dizziness || H.confused)
					H.adjustBrainLoss(-H.getBrainLoss()) //heals servants of braindamage, hallucination, druggy, dizziness, and confusion
					H.hallucination = 0
					H.adjust_drugginess(-H.druggy)
					H.dizziness = 0
					H.confused = 0
			else if(!H.null_rod_check() && H.stat == CONSCIOUS)
				var/distance = get_dist(T, get_turf(H))
				var/falloff_distance = min((110) - distance * 10, 80)
				var/sound_distance = falloff_distance * 0.5
				var/targetbrainloss = H.getBrainLoss()
				if(distance >= 4 && prob(falloff_distance * 0.5))
					H << "<span class='sevtug_small'>\"[text2ratvar(pick(mania_messages))]\"</span>"
				H.playsound_local(T, hum, sound_distance, 1)
				switch(distance)
					if(2 to 3)
						if(prob(falloff_distance * 0.5))
							if(prob(falloff_distance))
								H << "<span class='sevtug_small'>\"[text2ratvar(pick(mania_messages))]\"</span>"
							else
								H << "<span class='sevtug'>\"[text2ratvar(pick(compel_messages))]\"</span>"
						if(targetbrainloss <= 50)
							H.adjustBrainLoss((50 * efficiency) - targetbrainloss) //got too close had brain eaten
						H.adjust_drugginess(Clamp(7 * efficiency, 0, 100 - H.druggy))
						H.hallucination = min(H.hallucination + (7 * efficiency), 100)
						H.dizziness = min(H.dizziness + (3 * efficiency), 45)
						H.confused = min(H.confused + (3 * efficiency), 45)
					if(4 to 5)
						if(targetbrainloss <= 50)
							H.adjustBrainLoss(1 * efficiency)
						H.adjust_drugginess(Clamp(5 * efficiency, 0, 80 - H.druggy))
						H.hallucination = min(H.hallucination + (5 * efficiency), 80)
						H.dizziness = min(H.dizziness + (2 * efficiency), 30)
						H.confused = min(H.confused + (2 * efficiency), 30)
					if(6 to 7)
						if(targetbrainloss <= 30)
							H.adjustBrainLoss(1 * efficiency)
						H.adjust_drugginess(Clamp(2 * efficiency, 0, 60 - H.druggy))
						H.hallucination = min(H.hallucination + (2 * efficiency), 60)
						H.dizziness = min(H.dizziness + (2 * efficiency), 15)
						H.confused = min(H.confused + (2 * efficiency), 15)
					if(8 to 9)
						if(targetbrainloss <= 10)
							H.adjustBrainLoss(1 * efficiency)
						H.adjust_drugginess(Clamp(2 * efficiency, 0, 40 - H.druggy))
						H.hallucination = min(H.hallucination + (2 * efficiency), 40)
					if(10 to INFINITY)
						H.adjust_drugginess(Clamp(2 * efficiency, 0, 20 - H.druggy))
						H.hallucination = min(H.hallucination + (2 * efficiency), 20)
					else //if it's a distance of 1 and they can't see it/aren't adjacent or they're on top of it(how'd they get on top of it and still trigger this???)
						if(prob(falloff_distance * 0.5))
							if(prob(falloff_distance))
								H << "<span class='sevtug'>\"[text2ratvar(pick(compel_messages))]\"</span>"
							else if(prob(falloff_distance * 0.5))
								H << "<span class='sevtug'>\"[text2ratvar(pick(close_messages))]\"</span>"
							else
								H << "<span class='sevtug_small'>\"[text2ratvar(pick(mania_messages))]\"</span>"
						if(targetbrainloss <= 99)
							H.adjustBrainLoss((99 * efficiency) - targetbrainloss)
						H.adjust_drugginess(Clamp(10 * efficiency, 0, 150 - H.druggy))
						H.hallucination = min(H.hallucination + (10 * efficiency), 150)
						H.dizziness = min(H.dizziness + (5 * efficiency), 60)
						H.confused = min(H.confused + (5 * efficiency), 60)

	else
		forced_disable(FALSE)
