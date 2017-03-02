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
	max_integrity = 100
	obj_integrity = 100
	break_message = "<span class='warning'>The antenna break off, leaving a pile of shards!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/large = 2, \
	/obj/item/clockwork/alloy_shards/small = 2, \
	/obj/item/clockwork/component/geis_capacitor/antennae = 1)
	var/mania_cost = 150
	var/convert_cost = 150
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
		user << "<span class='sevtug_small'>It requires <b>[mania_cost]W</b> to run, and at least <b>[convert_cost]W</b> to attempt to convert humans adjacent to it.</span>"

/obj/structure/destructible/clockwork/powered/mania_motor/forced_disable(bad_effects)
	if(active)
		if(bad_effects)
			try_use_power(MIN_CLOCKCULT_POWER*4)
		visible_message("<span class='warning'>[src] hums loudly, then the sockets at its base fall dark!</span>")
		playsound(src, 'sound/effects/screech.ogg', 40, 1)
		toggle()
		return TRUE

/obj/structure/destructible/clockwork/powered/mania_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src, !issilicon(user), NO_DEXTERY) && is_servant_of_ratvar(user))
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
	if(!try_use_power(mania_cost))
		forced_disable(FALSE)
		return
	var/turf/T = get_turf(src)
	var/hum = get_sfx('sound/effects/screech.ogg') //like playsound, same sound for everyone affected
	var/efficiency = get_efficiency_mod()
	for(var/mob/living/carbon/human/H in viewers(7, src))
		if(is_servant_of_ratvar(H)) //heals servants of braindamage, hallucination, druggy, dizziness, and confusion
			var/brainloss = H.getBrainLoss()
			if(brainloss)
				H.adjustBrainLoss(-brainloss)
			if(H.hallucination)
				H.hallucination = 0
			if(H.druggy)
				H.adjust_drugginess(-H.druggy)
			if(H.dizziness)
				H.dizziness = 0
			if(H.confused)
				H.confused = 0
		else if(!H.null_rod_check() && H.stat != DEAD)
			var/distance = 0 + get_dist(T, get_turf(H))
			var/falloff_distance = min((110) - distance * 10, 80)
			var/sound_distance = falloff_distance * 0.5
			var/targetbrainloss = H.getBrainLoss()
			if(distance > 3 && prob(falloff_distance * 0.5))
				H << "<span class='sevtug_small'>\"[text2ratvar(pick(mania_messages))]\"</span>"
			if(distance <= 1)
				if(!H.Adjacent(src))
					H << "<span class='sevtug'>\"[text2ratvar(pick(close_messages))]\"</span>"
					H.playsound_local(T, hum, sound_distance, 1)
				else if(!try_use_power(convert_cost))
					visible_message("<span class='warning'>[src]'s antennae fizzle quietly.</span>")
					playsound(src, 'sound/effects/light_flicker.ogg', 50, 1)
				else
					H.playsound_local(T, hum, 80, 1)
					if(!H.stat)
						if(H.getBrainLoss() < 100)
							H.adjustBrainLoss(20 * efficiency)
							H.visible_message("<span class='warning'>[H] reaches out and touches [src].</span>", "<span class='sevtug'>You touch [src] involuntarily.</span>")
						else
							H.Paralyse(3)
					else if(is_eligible_servant(H))
						H << "<span class='sevtug'>\"[text2ratvar("You are mine and his, now.")]\"</span>"
						add_servant_of_ratvar(H)
						H.Paralyse(5)
			else
				H.playsound_local(T, hum, sound_distance, 1)
			switch(distance)
				if(0 to 3)
					if(prob(falloff_distance * 0.5))
						if(prob(falloff_distance))
							H << "<span class='sevtug_small'>\"[text2ratvar(pick(mania_messages))]\"</span>"
						else
							H << "<span class='sevtug'>\"[text2ratvar(pick(compel_messages))]\"</span>"
					if(targetbrainloss <= 40)
						H.adjustBrainLoss(3 * efficiency)
					H.adjust_drugginess(Clamp(7 * efficiency, 0, 50 - H.druggy))
					H.hallucination = min(H.hallucination + (7 * efficiency), 50)
					H.dizziness = min(H.dizziness + (3 * efficiency), 20)
					H.confused = min(H.confused + (3 * efficiency), 20)
				if(3 to 5)
					if(targetbrainloss <= 20)
						H.adjustBrainLoss(2 * efficiency)
					H.adjust_drugginess(Clamp(5 * efficiency, 0, 25 - H.druggy))
					H.hallucination = min(H.hallucination + (5 * efficiency), 25)
					H.dizziness = min(H.dizziness + (2 * efficiency), 10)
					H.confused = min(H.confused + (2 * efficiency), 10)
				if(5 to 6)
					if(targetbrainloss <= 10)
						H.adjustBrainLoss(1 * efficiency)
					H.adjust_drugginess(Clamp(2 * efficiency, 0, 20 - H.druggy))
					H.hallucination = min(H.hallucination + (2 * efficiency), 20)
					H.dizziness = min(H.dizziness + (2 * efficiency), 5)
					H.confused = min(H.confused + (2 * efficiency), 5)
				if(6 to 7)
					if(targetbrainloss <= 5)
						H.adjustBrainLoss(1 * efficiency)
					H.adjust_drugginess(Clamp(2 * efficiency, 0, 10 - H.druggy))
					H.hallucination = min(H.hallucination + (2 * efficiency), 10)
				if(7 to INFINITY)
					H.adjust_drugginess(Clamp(2 * efficiency, 0, 5 - H.druggy))
					H.hallucination = min(H.hallucination + (2 * efficiency), 5)
