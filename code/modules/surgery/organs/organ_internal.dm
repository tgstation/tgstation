/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	origin_tech = "biotech=3"
	force = 1
	w_class = 2
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

	addtimer(src, "stop_if_unowned", 120)

/obj/item/organ/heart/proc/stop_if_unowned()
	if(!owner)
		Stop()

/obj/item/organ/heart/attack_self(mob/user)
	..()
	if(!beating)
		visible_message("<span class='notice'>[user] squeezes [src] to \
			make it beat again!</span>")
		Restart()
		addtimer(src, "stop_if_unowned", 80)

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
	desc = "it needs to be pumped..."
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
			if(H.dna && !(NOBLOOD in H.dna.species.specflags))
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
	name = "pump your blood"

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
			if(H.dna && !(NOBLOOD in H.dna.species.specflags))
				H.blood_volume = min(H.blood_volume + cursed_heart.blood_loss*0.5, BLOOD_VOLUME_MAXIMUM)
				H.remove_client_colour(/datum/client_colour/cursed_heart_blood)
				cursed_heart.add_colour = TRUE
				H.adjustBruteLoss(-cursed_heart.heal_brute)
				H.adjustFireLoss(-cursed_heart.heal_burn)
				H.adjustOxyLoss(-cursed_heart.heal_oxy)


/datum/client_colour/cursed_heart_blood
	priority = 100 //it's an indicator you're dieing, so it's very high priority
	colour = "red"



/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	zone = "chest"
	slot = "lungs"
	gender = PLURAL
	w_class = 3

/obj/item/organ/lungs/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("salbutamol", 5)
	return S

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
	say_mod = "hiss"

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
		S.reagents.add_reagent("????", 5)
	return S
