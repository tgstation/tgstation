/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	origin_tech = "biotech=3"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	var/zone = "chest"
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/vital = 0


/obj/item/organ/proc/Insert(mob/living/carbon/M, special = 0)
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)

	owner = M
	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	loc = null
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)


/obj/item/organ/proc/Remove(mob/living/carbon/M, special = 0)
	owner = null
	if(M)
		M.internal_organs -= src
		if(M.internal_organs_slot[slot] == src)
			M.internal_organs_slot.Remove(slot)
		if(vital && !special)
			M.death()
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(M)


/obj/item/organ/proc/on_find(mob/living/finder)
	return

/obj/item/organ/proc/on_life()
	return

/obj/item/organ/examine(mob/user)
	..()
	if(status == ORGAN_ROBOTIC && crit_fail)
		user << "<span class='warning'>[src] seems to be broken!</span>"


/obj/item/organ/proc/prepare_eat()
	var/obj/item/weapon/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.origin_tech = origin_tech
	S.w_class = w_class

	return S

/obj/item/weapon/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'
	list_reagents = list("nutriment" = 5)


/obj/item/organ/Destroy()
	if(owner)
		Remove(owner, 1)
	return ..()

/obj/item/organ/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(status == ORGAN_ORGANIC)
			var/obj/item/weapon/reagent_containers/food/snacks/S = prepare_eat()
			if(S)
				H.drop_item()
				H.put_in_active_hand(S)
				S.attack(H, H)
				qdel(src)
	else
		..()

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm



/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	zone = "chest"
	slot = "heart"
	origin_tech = "biotech=5"
	var/beating = 1
	var/icon_base = "heart"
	attack_verb = list("beat", "thumped")

/obj/item/organ/heart/update_icon()
	if(beating)
		icon_state = "[icon_base]-on"
	else
		icon_state = "[icon_base]-off"

/obj/item/organ/heart/Remove(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.stat == DEAD || H.heart_attack)
			Stop()
			return
		if(!special)
			H.heart_attack = 1

	addtimer(CALLBACK(src, .proc/stop_if_unowned), 120)

/obj/item/organ/heart/proc/stop_if_unowned()
	if(!owner)
		Stop()

/obj/item/organ/heart/attack_self(mob/user)
	..()
	if(!beating)
		visible_message("<span class='notice'>[user] squeezes [src] to \
			make it beat again!</span>")
		Restart()
		addtimer(CALLBACK(src, .proc/stop_if_unowned), 80)

/obj/item/organ/heart/Insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(M) && beating)
		var/mob/living/carbon/human/H = M
		if(H.heart_attack)
			H.heart_attack = 0
			return

/obj/item/organ/heart/proc/Stop()
	beating = 0
	update_icon()
	return 1

/obj/item/organ/heart/proc/Restart()
	beating = 1
	update_icon()
	return 1

/obj/item/organ/heart/prepare_eat()
	var/obj/S = ..()
	S.icon_state = "heart-off"
	return S


/obj/item/organ/heart/cursed
	name = "cursed heart"
	desc = "A heart that, when inserted, will force you to pump it manually."
	icon_state = "cursedheart-off"
	icon_base = "cursedheart"
	origin_tech = "biotech=6"
	actions_types = list(/datum/action/item_action/organ_action/cursed_heart)
	var/last_pump = 0
	var/add_colour = TRUE //So we're not constantly recreating colour datums
	var/pump_delay = 30 //you can pump 1 second early, for lag, but no more (otherwise you could spam heal)
	var/blood_loss = 100 //600 blood is human default, so 5 failures (below 122 blood is where humans die because reasons?)

	//How much to heal per pump, negative numbers would HURT the player
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0


/obj/item/organ/heart/cursed/attack(mob/living/carbon/human/H, mob/living/carbon/human/user, obj/target)
	if(H == user && istype(H))
		playsound(user,'sound/effects/singlebeat.ogg',40,1)
		user.drop_item()
		Insert(user)
	else
		return ..()

/obj/item/organ/heart/cursed/on_life()
	if(world.time > (last_pump + pump_delay))
		if(ishuman(owner) && owner.client) //While this entire item exists to make people suffer, they can't control disconnects.
			var/mob/living/carbon/human/H = owner
			if(H.dna && !(NOBLOOD in H.dna.species.species_traits))
				H.blood_volume = max(H.blood_volume - blood_loss, 0)
				H << "<span class = 'userdanger'>You have to keep pumping your blood!</span>"
				if(add_colour)
					H.add_client_colour(/datum/client_colour/cursed_heart_blood) //bloody screen so real
					add_colour = FALSE
		else
			last_pump = world.time //lets be extra fair *sigh*

/obj/item/organ/heart/cursed/Insert(mob/living/carbon/M, special = 0)
	..()
	if(owner)
		owner << "<span class ='userdanger'>Your heart has been replaced with a cursed one, you have to pump this one manually otherwise you'll die!</span>"

/datum/action/item_action/organ_action/cursed_heart
	name = "Pump your blood"

//You are now brea- pumping blood manually
/datum/action/item_action/organ_action/cursed_heart/Trigger()
	. = ..()
	if(. && istype(target,/obj/item/organ/heart/cursed))
		var/obj/item/organ/heart/cursed/cursed_heart = target

		if(world.time < (cursed_heart.last_pump + (cursed_heart.pump_delay-10))) //no spam
			owner << "<span class='userdanger'>Too soon!</span>"
			return

		cursed_heart.last_pump = world.time
		playsound(owner,'sound/effects/singlebeat.ogg',40,1)
		owner << "<span class = 'notice'>Your heart beats.</span>"

		var/mob/living/carbon/human/H = owner
		if(istype(H))
			if(H.dna && !(NOBLOOD in H.dna.species.species_traits))
				H.blood_volume = min(H.blood_volume + cursed_heart.blood_loss*0.5, BLOOD_VOLUME_MAXIMUM)
				H.remove_client_colour(/datum/client_colour/cursed_heart_blood)
				cursed_heart.add_colour = TRUE
				H.adjustBruteLoss(-cursed_heart.heal_brute)
				H.adjustFireLoss(-cursed_heart.heal_burn)
				H.adjustOxyLoss(-cursed_heart.heal_oxy)


/datum/client_colour/cursed_heart_blood
	priority = 100 //it's an indicator you're dieing, so it's very high priority
	colour = "red"

#define HUMAN_MAX_OXYLOSS 3
#define HUMAN_CRIT_MAX_OXYLOSS (SSmob.wait/30)
#define HEAT_GAS_DAMAGE_LEVEL_1 2
#define HEAT_GAS_DAMAGE_LEVEL_2 4
#define HEAT_GAS_DAMAGE_LEVEL_3 8

#define COLD_GAS_DAMAGE_LEVEL_1 0.5
#define COLD_GAS_DAMAGE_LEVEL_2 1.5
#define COLD_GAS_DAMAGE_LEVEL_3 3

/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	zone = "chest"
	slot = "lungs"
	gender = PLURAL
	w_class = WEIGHT_CLASS_NORMAL
	var/list/breathlevels = list("safe_oxygen_min" = 16,"safe_oxygen_max" = 0,"safe_co2_min" = 0,"safe_co2_max" = 10,
	"safe_toxins_min" = 0,"safe_toxins_max" = 0.05,"SA_para_min" = 1,"SA_sleep_min" = 5,"BZ_trip_balls_min" = 1)

	//Breath damage

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = 0.05
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas.

	var/oxy_breath_dam_min = 1
	var/oxy_breath_dam_max = 10
	var/co2_breath_dam_min = 1
	var/co2_breath_dam_max = 10
	var/tox_breath_dam_min = MIN_PLASMA_DAMAGE
	var/tox_breath_dam_max = MAX_PLASMA_DAMAGE



/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	if((H.status_flags & GODMODE))
		return

	var/species_traits = list()
	if(H && H.dna && H.dna.species && H.dna.species.species_traits)
		species_traits = H.dna.species.species_traits

	if(!breath || (breath.total_moles() == 0))
		if(H.reagents.has_reagent("epinephrine"))
			return
		if(H.health >= HEALTH_THRESHOLD_CRIT)
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else if(!(NOCRITDAMAGE in species_traits))
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		H.failed_last_breath = 1
		if(safe_oxygen_min)
			H.throw_alert("oxy", /obj/screen/alert/oxy)
		else if(safe_toxins_min)
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else if(safe_co2_min)
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		return 0

	var/gas_breathed = 0

	var/list/breath_gases = breath.gases

	breath.assert_gases("o2", "plasma", "co2", "n2o", "bz")

	//Partial pressures in our breath
	var/O2_pp = breath.get_breath_partial_pressure(breath_gases["o2"][MOLES])
	var/Toxins_pp = breath.get_breath_partial_pressure(breath_gases["plasma"][MOLES])
	var/CO2_pp = breath.get_breath_partial_pressure(breath_gases["co2"][MOLES])


	//-- OXY --//

	//Too much oxygen! //Yes, some species may not like it.
	if(safe_oxygen_max)
		if(O2_pp > safe_oxygen_max)
			var/ratio = (breath_gases["o2"][MOLES]/safe_oxygen_max) * 10
			H.adjustOxyLoss(Clamp(ratio,oxy_breath_dam_min,oxy_breath_dam_max))
			H.throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)
		else
			H.clear_alert("too_much_oxy")

	//Too little oxygen!
	if(safe_oxygen_min)
		if(O2_pp < safe_oxygen_min)
			gas_breathed = handle_too_little_breath(H,O2_pp,safe_oxygen_min,breath_gases["o2"][MOLES])
			H.throw_alert("oxy", /obj/screen/alert/oxy)
		else
			H.failed_last_breath = 0
			if(H.getOxyLoss())
				H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["o2"][MOLES]
			H.clear_alert("oxy")

	//Exhale
	breath_gases["o2"][MOLES] -= gas_breathed
	breath_gases["co2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- CO2 --//

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(safe_co2_max)
		if(CO2_pp > safe_co2_max)
			if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				H.co2overloadtime = world.time
			else if(world.time - H.co2overloadtime > 120)
				H.Paralyse(3)
				H.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
				if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					H.adjustOxyLoss(8)
				H.throw_alert("too_much_co2", /obj/screen/alert/too_much_co2)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				H.emote("cough")

		else
			H.co2overloadtime = 0
			H.clear_alert("too_much_co2")

	//Too little CO2!
	if(breathlevels["safe_co2_min"])
		if(CO2_pp < safe_co2_min)
			gas_breathed = handle_too_little_breath(H,CO2_pp, safe_co2_min,breath_gases["co2"][MOLES])
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["co2"][MOLES]
			H.clear_alert("not_enough_co2")

	//Exhale
	breath_gases["co2"][MOLES] -= gas_breathed
	breath_gases["o2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TOX --//

	//Too much toxins!
	if(safe_toxins_max)
		if(Toxins_pp > safe_toxins_max)
			var/ratio = (breath_gases["plasma"][MOLES]/safe_toxins_max) * 10
			if(H.reagents)
				H.reagents.add_reagent("plasma", Clamp(ratio, tox_breath_dam_min, tox_breath_dam_max))
			H.throw_alert("tox_in_air", /obj/screen/alert/tox_in_air)
		else
			H.clear_alert("tox_in_air")


	//Too little toxins!
	if(safe_toxins_min)
		if(Toxins_pp < safe_toxins_min)
			gas_breathed = handle_too_little_breath(H,Toxins_pp, safe_toxins_min, breath_gases["plasma"][MOLES])
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			gas_breathed = breath_gases["plasma"][MOLES]
			H.clear_alert("not_enough_tox")

	//Exhale
	breath_gases["plasma"][MOLES] -= gas_breathed
	breath_gases["co2"][MOLES] += gas_breathed
	gas_breathed = 0


	//-- TRACES --//

	if(breath)	// If there's some other shit in the air lets deal with it here.

	// N2O

		var/SA_pp = breath.get_breath_partial_pressure(breath_gases["n2o"][MOLES])
		if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
			H.Paralyse(3) // 3 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.Sleeping(max(H.sleeping+2, 10))
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))

	// BZ

		var/bz_pp = breath.get_breath_partial_pressure(breath_gases["bz"][MOLES])
		if(bz_pp > BZ_trip_balls_min)
			H.hallucination += 20
			if(prob(33))
				H.adjustBrainLoss(3)
		else if(bz_pp > 0.01)
			H.hallucination += 5//Removed at 2 per tick so this will slowly build up
		handle_breath_temperature(breath, H)
		breath.garbage_collect()

	return 1


/obj/item/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null,breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return 0

	if(prob(20))
		H.emote("gasp")
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		H.failed_last_breath = 1
		. = true_pp*ratio/6
	else
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.failed_last_breath = 1


/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	if(abs(310.15 - breath.temperature) > 50)

		var/species_traits = list()
		if(H && H.dna && H.dna.species && H.dna.species.species_traits)
			species_traits = H.dna.species.species_traits

		if(!(mutations_list[COLDRES] in H.dna.mutations) && !(RESISTCOLD in species_traits)) // COLD DAMAGE
			switch(breath.temperature)
				if(-INFINITY to 120)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head")
				if(120 to 200)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head")
				if(200 to 260)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head")

		if(!(RESISTHOT in species_traits)) // HEAT DAMAGE
			switch(breath.temperature)
				if(360 to 400)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head")
				if(400 to 1000)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head")
				if(1000 to INFINITY)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head")




/obj/item/organ/lungs/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("salbutamol", 5)
	return S


/obj/item/organ/lungs/plasmaman
	name = "plasma filter"

	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0





#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS
#undef HEAT_GAS_DAMAGE_LEVEL_1
#undef HEAT_GAS_DAMAGE_LEVEL_2
#undef HEAT_GAS_DAMAGE_LEVEL_3

#undef COLD_GAS_DAMAGE_LEVEL_1
#undef COLD_GAS_DAMAGE_LEVEL_2
#undef COLD_GAS_DAMAGE_LEVEL_3

/obj/item/organ/tongue
	name = "tongue"
	desc = "A fleshy muscle mostly used for lying."
	icon_state = "tonguenormal"
	zone = "mouth"
	slot = "tongue"
	var/say_mod = null
	attack_verb = list("licked", "slobbered", "slapped", "frenched", "tongued")

/obj/item/organ/tongue/get_spans()
	return list()

/obj/item/organ/tongue/proc/TongueSpeech(var/message)
	return message

/obj/item/organ/tongue/Insert(mob/living/carbon/M, special = 0)
	..()
	if(say_mod && M.dna && M.dna.species)
		M.dna.species.say_mod = say_mod

/obj/item/organ/tongue/Remove(mob/living/carbon/M, special = 0)
	..()
	if(say_mod && M.dna && M.dna.species)
		M.dna.species.say_mod = initial(M.dna.species.say_mod)

/obj/item/organ/tongue/lizard
	name = "forked tongue"
	desc = "A thin and long muscle typically found in reptilian races, apparently moonlights as a nose."
	icon_state = "tonguelizard"
	say_mod = "hisses"

/obj/item/organ/tongue/lizard/TongueSpeech(var/message)
	var/regex/lizard_hiss = new("s+", "g")
	var/regex/lizard_hiSS = new("S+", "g")
	if(copytext(message, 1, 2) != "*")
		message = lizard_hiss.Replace(message, "sss")
		message = lizard_hiSS.Replace(message, "SSS")
	return message

/obj/item/organ/tongue/fly
	name = "proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids."
	icon_state = "tonguefly"
	say_mod = "buzzes"

/obj/item/organ/tongue/fly/TongueSpeech(var/message)
	var/regex/fly_buzz = new("z+", "g")
	var/regex/fly_buZZ = new("Z+", "g")
	if(copytext(message, 1, 2) != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
	return message

/obj/item/organ/tongue/abductor
	name = "superlingual matrix"
	desc = "A mysterious structure that allows for instant communication between users. Pretty impressive until you need to eat something."
	icon_state = "tongueayylmao"
	say_mod = "gibbers"

/obj/item/organ/tongue/abductor/TongueSpeech(var/message)
	//Hacks
	var/mob/living/carbon/human/user = usr
	var/rendered = "<span class='abductor'><b>[user.name]:</b> [message]</span>"
	for(var/mob/living/carbon/human/H in living_mob_list)
		var/obj/item/organ/tongue/T = H.getorganslot("tongue")
		if(!T || T.type != type)
			continue
		else if(H.dna && H.dna.species.id == "abductor" && user.dna && user.dna.species.id == "abductor")
			var/datum/species/abductor/Ayy = user.dna.species
			var/datum/species/abductor/Byy = H.dna.species
			if(Ayy.team != Byy.team)
				continue
		H << rendered
	for(var/mob/M in dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		M << "[link] [rendered]"
	return ""

/obj/item/organ/tongue/zombie
	name = "rotting tongue"
	desc = "Between the decay and the fact that it's just lying there you doubt a tongue has ever seemed less sexy."
	icon_state = "tonguezombie"
	say_mod = "moans"

/obj/item/organ/tongue/zombie/TongueSpeech(var/message)
	var/list/message_list = splittext(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, length(inserttext) - 2) == "..."))
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	return jointext(message_list, " ")

/obj/item/organ/tongue/alien
	name = "alien tongue"
	desc = "According to leading xenobiologists the evolutionary benefit of having a second mouth in your mouth is \"that it looks badass\"."
	icon_state = "tonguexeno"
	say_mod = "hisses"

/obj/item/organ/tongue/alien/TongueSpeech(var/message)
	playsound(owner, "hiss", 25, 1, 1)
	return message

/obj/item/organ/tongue/bone
	name = "bone \"tongue\""
	desc = "Apparently skeletons alter the sounds they produce \
		through oscillation of their teeth, hence their characteristic \
		rattling."
	icon_state = "tonguebone"
	say_mod = "rattles"
	attack_verb = list("bitten", "chattered", "chomped", "enamelled", "boned")

	var/chattering = FALSE
	var/phomeme_type = "sans"
	var/list/phomeme_types = list("sans", "papyrus")

/obj/item/organ/tongue/bone/New()
	. = ..()
	phomeme_type = pick(phomeme_types)

/obj/item/organ/tongue/bone/TongueSpeech(var/message)
	. = message

	if(chattering)
		//Annoy everyone nearby with your chattering.
		chatter(message, phomeme_type, usr)

/obj/item/organ/tongue/bone/get_spans()
	. = ..()
	// Feature, if the tongue talks directly, it will speak with its span
	switch(phomeme_type)
		if("sans")
			. |= SPAN_SANS
		if("papyrus")
			. |= SPAN_PAPYRUS

/obj/item/organ/tongue/bone/chatter
	name = "chattering bone \"tongue\""
	chattering = TRUE

/obj/item/organ/tongue/robot
	name = "robotic voicebox"
	desc = "A voice synthesizer that can interface with organic lifeforms."
	icon_state = "tonguerobot"
	say_mod = "states"
	attack_verb = list("beeped", "booped")

/obj/item/organ/tongue/robot/get_spans()
	return ..() | SPAN_ROBOT

/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	zone = "groin"
	slot = "appendix"
	var/inflamed = 0

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"
	else
		icon_state = "appendix"
		name = "appendix"

/obj/item/organ/appendix/Remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis/A in M.viruses)
		A.cure()
		inflamed = 1
	update_icon()
	..()

/obj/item/organ/appendix/Insert(mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.AddDisease(new /datum/disease/appendicitis)

/obj/item/organ/appendix/prepare_eat()
	var/obj/S = ..()
	if(inflamed)
		S.reagents.add_reagent("bad_food", 5)
	return S

/mob/living/proc/regenerate_organs()
	return 0

/mob/living/carbon/regenerate_organs()
	if(!(NOBREATH in dna.species.species_traits) && !getorganslot("lungs"))
		var/obj/item/organ/lungs/L = new()
		L.Insert(src)

	if(!(NOBLOOD in dna.species.species_traits) && !getorganslot("heart"))
		var/obj/item/organ/heart/H = new()
		H.Insert(src)

	if(!getorganslot("tongue"))
		var/obj/item/organ/tongue/T

		for(var/tongue_type in dna.species.mutant_organs)
			if(ispath(tongue_type, /obj/item/organ/tongue))
				T = new tongue_type()
				T.Insert(src)

		// if they have no mutant tongues, give them a regular one
		if(!T)
			T = new()
			T.Insert(src)

	if(!getorganslot("eye_sight"))
		var/obj/item/organ/eyes/E

		if(dna && dna.species && dna.species.mutanteyes)
			E = new dna.species.mutanteyes()

		else
			E = new()
		E.Insert(src)

//Eyes

/obj/item/organ/eyes
	name = "eyes"
	icon_state = "eyeballs"
	desc = "I see you!"
	zone = "eyes"
	slot = "eye_sight"

	var/sight_flags = 0
	var/see_in_dark = 2
	var/tint = 0
	var/eye_color = "fff"
	var/old_eye_color = "fff"
	var/flash_protect = 0
	var/see_invisible = SEE_INVISIBLE_LIVING

/obj/item/organ/eyes/Insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(owner) && eye_color)
		var/mob/living/carbon/human/HMN = owner
		old_eye_color = HMN.eye_color
		HMN.eye_color = eye_color
		HMN.regenerate_icons()
	M.update_tint()
	owner.update_sight()

/obj/item/organ/eyes/Remove(mob/living/carbon/M, special = 0)
	..()
	M.sight ^= sight_flags
	if(ishuman(M) && eye_color)
		var/mob/living/carbon/human/HMN = owner
		HMN.eye_color = old_eye_color
	M.regenerate_icons()
	M.update_tint()


/obj/item/organ/eyes/night_vision
	name = "shadow eyes"
	desc = "A spooky set of eyes that can see in the dark."
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/night_vision = TRUE

/obj/item/organ/eyes/night_vision/ui_action_click()
	if(night_vision)
		see_in_dark = 4
		see_invisible = SEE_INVISIBLE_LIVING
		night_vision = FALSE
	else
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
		night_vision = TRUE

/obj/item/organ/eyes/night_vision/alien
	name = "alien eyes"
	desc = "It turned out they had them after all!"
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	sight_flags = SEE_MOBS


///Robotic

/obj/item/organ/eyes/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "Your vision is augmented."

/obj/item/organ/eyes/robotic/emp_act(severity)
	if(!owner)
		return
	if(severity > 1)
		if(prob(10 * severity))
			return
	owner << "<span class='warning'>Static obfuscates your vision!</span>"
	owner.flash_act(visual = 1)

/obj/item/organ/eyes/robotic/xray
	name = "X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color = "000"
	see_in_dark = 8
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/eyes/robotic/thermals
	name = "Thermals eyes"
	desc = "These cybernetic eye implants will give you Thermal vision. Vertical slit pupil included."
	eye_color = "FC0"
	origin_tech = "materials=5;programming=4;biotech=4;magnets=4;syndicate=1"
	sight_flags = SEE_MOBS
	see_invisible = SEE_INVISIBLE_MINIMUM
	flash_protect = -1
	see_in_dark = 8

/obj/item/organ/eyes/robotic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someones head?"
	eye_color ="fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = 2
	tint = INFINITY

/obj/item/organ/eyes/robotic/flashlight/emp_act(severity)
	return

/obj/item/organ/eyes/robotic/flashlight/Insert(var/mob/living/carbon/M, var/special = 0)
	..()
	M.AddLuminosity(15)


/obj/item/organ/eyes/robotic/flashlight/Remove(var/mob/living/carbon/M, var/special = 0)
	M.AddLuminosity(-15)
	..()

// Welding shield implant
/obj/item/organ/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	origin_tech = "materials=4;biotech=3;engineering=4;plasmatech=3"
	flash_protect = 2

/obj/item/organ/eyes/robotic/shield/emp_act(severity)
	return