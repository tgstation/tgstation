//Mild traumas are the most common; they are generally minor annoyances.
//They can be cured with mannitol and patience, although brain surgery still works.
//Most of the old brain damage effects have been transferred to the dumbness trauma.

/datum/brain_trauma/mild

/datum/brain_trauma/mild/hallucinations
	name = "Hallucinations"
	desc = "Patient suffers constant hallucinations."
	scan_desc = "schizophrenia"
	gain_text = "<span class='warning'>You feel your grip on reality slipping...</span>"
	lose_text = "<span class='notice'>You feel more grounded.</span>"

/datum/brain_trauma/mild/hallucinations/on_life()
	owner.hallucination = min(owner.hallucination + 10, 50)
	..()

/datum/brain_trauma/mild/hallucinations/on_lose()
	owner.hallucination = 0
	..()

/datum/brain_trauma/mild/stuttering
	name = "Stuttering"
	desc = "Patient can't speak properly."
	scan_desc = "reduced mouth coordination"
	gain_text = "<span class='warning'>Speaking clearly is getting harder.</span>"
	lose_text = "<span class='notice'>You feel in control of your speech.</span>"

/datum/brain_trauma/mild/stuttering/on_life()
	owner.stuttering = min(owner.stuttering + 5, 25)
	..()

/datum/brain_trauma/mild/stuttering/on_lose()
	owner.stuttering = 0
	..()
#define BRAIN_DAMAGE_FILE "brain_damage_lines.json"
/datum/brain_trauma/mild/dumbness
	name = "Dumbness"
	desc = "Patient has reduced brain activity, making them less intelligent."
	scan_desc = "reduced brain activity"
	gain_text = "<span class='warning'>You feel dumber.</span>"
	lose_text = "<span class='notice'>You feel smart again.</span>"

/datum/brain_trauma/mild/dumbness/on_gain()
	owner.disabilities |= DUMB
	..()

/datum/brain_trauma/mild/dumbness/on_life()
	owner.derpspeech = min(owner.derpspeech + 5, 25)
	if(prob(3))
		owner.emote("drool")
	else if(owner.stat == CONSCIOUS && prob(3))
		owner.say(pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage"))
	..()

/datum/brain_trauma/mild/dumbness/on_lose()
	owner.disabilities &= ~DUMB
	owner.derpspeech = 0
	..()

#undef BRAIN_DAMAGE_FILE

/datum/brain_trauma/mild/speech_impediment
	name = "Speech Impediment"
	desc = "Patient is unable to form coherent sentences."
	scan_desc = "communication disorder"
	gain_text = "" //mutation will handle the text
	lose_text = ""

/datum/brain_trauma/mild/speech_impediment/on_gain()
	owner.dna.add_mutation(UNINTELLIGIBLE)
	..()

//no fiddling with genetics to get out of this one
/datum/brain_trauma/mild/speech_impediment/on_life()
	if(!(GLOB.mutations_list[UNINTELLIGIBLE] in owner.dna.mutations))
		on_gain()
	..()

/datum/brain_trauma/mild/speech_impediment/on_lose()
	owner.dna.remove_mutation(UNINTELLIGIBLE)
	..()

/datum/brain_trauma/mild/concussion
	name = "Concussion"
	desc = "Patient's brain is concussed."
	scan_desc = "a concussion"
	gain_text = "<span class='warning'>You feel a pressure inside of your head.</span>"
	lose_text = "<span class='notice'>Your head feels more clear.</span>"

/datum/brain_trauma/mild/concussion/on_life()
	if(prob(5))
		switch(rand(1,11))
			if(1)
				owner.vomit()
			if(2,3)
				owner.dizziness += 10
			if(4,5)
				owner.confused += 10
				owner.blur_eyes(10)
			if(6 to 9)
				owner.slurring += 30
			if(10)
				to_chat(owner, "<span class='notice'>You forget for a moment what you were doing.</span>")
				owner.Stun(20)
			if(11)
				to_chat(owner, "<span class='warning'>You faint.</span>")
				owner.Unconscious(80)

	..()

/datum/brain_trauma/mild/phobia
	name = "Phobia"
	desc = "Patient is unreasonaly afraid of something."
	scan_desc = "phobia"
	gain_text = ""
	lose_text = ""
	var/phobia_type
	var/next_check = 0
	var/next_scare = 0
	var/list/trigger_words
	//instead of cycling every atom, only cycle the relevant types
	var/list/trigger_mobs = list()
	var/list/trigger_objs = list() //also checked in mob equipment
	var/list/trigger_turfs = list()
	var/list/trigger_species = list()

/datum/brain_trauma/mild/phobia/New(mob/living/carbon/C, _permanent, specific_type)
	phobia_type = specific_type
	if(!phobia_type)
		phobia_type = pick("spiders", "space", "security", "clowns", "greytide", "lizards", "spooky skeletons") // todo: add eldritch, cogs, magic, doctors(additionally do each department), lava, monsters, and mimes

	gain_text = "<span class='warning'>You start finding [phobia_type] very unnerving...</span>"
	lose_text = "<span class='notice'>You no longer feel afraid of [phobia_type].</span>"
	scan_desc += " of [phobia_type]"
	switch(phobia_type)
		if("spiders")
			trigger_words = list("spider","web","arachnid")
			trigger_mobs = list(/mob/living/simple_animal/hostile/poison/giant_spider)
			trigger_objs = list(/obj/structure/spider) //includes webs and spiderlings
		if("space")
			trigger_words = list("space", "star", "universe", "void")
			trigger_turfs = list(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace)
		if("security")
			trigger_words = list(" sec ", "security", "shitcurity", "stunbaton", "taser", "beepsky")
			trigger_mobs = list(/mob/living/simple_animal/bot/secbot)
			trigger_objs = list(/obj/item/clothing/under/rank/security, /obj/item/clothing/under/rank/warden, /obj/item/clothing/under/rank/head_of_security,\
				/obj/item/clothing/under/rank/det, /obj/item/melee/baton, /obj/item/gun/energy/taser, /obj/item/restraints/handcuffs, /obj/machinery/door/airlock/security)
		if("clowns")
			trigger_words = list("clown", "honk", "banana", "slip")
			trigger_objs = list(/obj/item/clothing/under/rank/clown, /obj/item/clothing/shoes/clown_shoes, /obj/item/clothing/mask/gas/clown_hat,\
				/obj/item/device/instrument/bikehorn, /obj/item/device/pda/clown, /obj/item/grown/bananapeel)
		if("greytide")
			trigger_words = list("assistant", "grey", "gasmask", "gas mask", "stunprod", "spear", "revolution", "viva")
			trigger_objs = list(/obj/item/clothing/under/color/grey, /obj/item/melee/baton/cattleprod, /obj/item/twohanded/spear,\
				/obj/item/clothing/mask/gas)
		if("lizards")
			trigger_words = list("lizard", "ligger", "hiss", " wag ")
			trigger_objs = list(/obj/item/toy/plush/lizardplushie, /obj/item/reagent_containers/food/snacks/kebab/tail, /obj/item/severedtail,\
				/obj/item/reagent_containers/food/drinks/bottle/lizardwine)
			trigger_mobs = list(/mob/living/simple_animal/hostile/lizard) //they're hostile! of course they're scary!
			trigger_species = list(/datum/species/lizard)
		if("spooky skeletons")
			trigger_words = list("skeleton", "rattle me bones", "milk", "xylophone", "bone", "calcium", "i want to get off mr bones wild ride", "the ride never ends")
			trigger_objs = list() // todo: find paths for all above
			trigger_mobs = list() // i forget if we have 
			trigger_species = list(/datum/species/skeleton)

	trigger_turfs = typecacheof(trigger_turfs)
	trigger_mobs = typecacheof(trigger_mobs)
	trigger_objs = typecacheof(trigger_objs)
	trigger_species = typecacheof(trigger_species)
	..()

/datum/brain_trauma/mild/phobia/on_life()
	..()
	if(owner.eye_blind)
		return
	if(world.time > next_check && world.time > next_scare)
		next_check = world.time + 200
		next_scare = world.time + 200
		var/list/seen_atoms = view(7, owner)

		if(LAZYLEN(trigger_objs))
			for(var/obj/O in seen_atoms)
				if(is_type_in_typecache(O, trigger_objs))
					freak_out(O)
					return

		if(LAZYLEN(trigger_turfs))
			for(var/turf/T in seen_atoms)
				if(is_type_in_typecache(T, trigger_turfs))
					freak_out(T)
					return

		if(LAZYLEN(trigger_mobs) || LAZYLEN(trigger_objs))
			for(var/mob/M in seen_atoms)
				if(is_type_in_typecache(M, trigger_mobs))
					freak_out(M)
					return

				else if(ishuman(M)) //check their equipment for trigger items
					var/mob/living/carbon/human/H = M

					if(LAZYLEN(trigger_species) && H.dna && H.dna.species && is_type_in_typecache(H.dna.species, trigger_species))
						freak_out(H)

					for(var/X in H.get_all_slots() | H.held_items)
						var/obj/I = X
						if(!QDELETED(I) && is_type_in_typecache(I, trigger_objs))
							freak_out(I)
							return

/datum/brain_trauma/mild/phobia/on_hear(message, speaker, message_language, raw_message, radio_freq)
	if(owner.disabilities & DEAF || world.time < next_scare) //words can't trigger you if you can't hear them *taps head*
		return message
	for(var/word in trigger_words)
		if(findtext(message, word))
			freak_out(null, word)
			next_scare = world.time + 200 //prevents phobia spam
	return message

/datum/brain_trauma/mild/phobia/proc/freak_out(atom/reason, trigger_word)
	var/message = pick("spooks you to the bone", "shakes you up", "terrifies you", "sends you into a panic", "sends chills down your spine")
	if(reason)
		to_chat(owner, "<span class='userdanger'>Seeing [reason] [message]!</span>")
	else if(trigger_word)
		to_chat(owner, "<span class='userdanger'>The word [trigger_word] [message]!</span>")
	else
		to_chat(owner, "<span class='userdanger'>Something [message]!</span>")
	var/reaction = rand(1,4)
	switch(reaction)
		if(1)
			to_chat(owner, "<span class='warning'>You are paralyzed with fear!</span>")
			owner.Stun(70)
			owner.Jitter(8)
		if(2)
			owner.emote("scream")
			owner.Jitter(5)
			owner.say("AAAAH! [uppertext(phobia_type)]!!")
			if(reason)
				owner.pointed(reason)
		if(3)
			to_chat(owner, "<span class='warning'>You shut your eyes in fear!</span>")
			owner.blind_eyes(10)
		if(4)
			owner.dizziness += 10
			owner.confused += 10
			owner.Jitter(10)
			owner.stuttering += 10
