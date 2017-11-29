GLOBAL_LIST_INIT(phobia_spider_words, list("spider","web","arachnid"))
GLOBAL_LIST_INIT(phobia_spider_mobs, typecacheof(/mob/living/simple_animal/hostile/poison/giant_spider))
GLOBAL_LIST_INIT(phobia_spider_objs, typecacheof(/obj/structure/spider))

GLOBAL_LIST_INIT(phobia_space_words, list("space", "star", "universe", "void"))
GLOBAL_LIST_INIT(phobia_space_turfs, typecacheof(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace))

GLOBAL_LIST_INIT(phobia_security_words, list(" sec ", "security", "shitcurity", "stunbaton", "taser", "beepsky"))
GLOBAL_LIST_INIT(phobia_security_mobs, typecacheof(/mob/living/simple_animal/bot/secbot))
GLOBAL_LIST_INIT(phobia_security_objs, typecacheof(/obj/item/clothing/under/rank/security, /obj/item/clothing/under/rank/warden, /obj/item/clothing/under/rank/head_of_security,\
				/obj/item/clothing/under/rank/det, /obj/item/melee/baton, /obj/item/gun/energy/taser, /obj/item/restraints/handcuffs, /obj/machinery/door/airlock/security))

GLOBAL_LIST_INIT(phobia_clown_words, list("clown", "honk", "banana", "slip"))
GLOBAL_LIST_INIT(phobia_clown_objs, typecacheof(/obj/item/clothing/under/rank/clown, /obj/item/clothing/shoes/clown_shoes, /obj/item/clothing/mask/gas/clown_hat,\
				/obj/item/device/instrument/bikehorn, /obj/item/device/pda/clown, /obj/item/grown/bananapeel))

GLOBAL_LIST_INIT(phobia_greytide_words, list("assistant", "grey", "gasmask", "gas mask", "stunprod", "spear", "revolution", "viva"))
GLOBAL_LIST_INIT(phobia_greytide_objs, typecacheof(/obj/item/clothing/under/color/grey, /obj/item/melee/baton/cattleprod, /obj/item/twohanded/spear,\
				/obj/item/clothing/mask/gas))

GLOBAL_LIST_INIT(phobia_lizard_words,list("lizard", "ligger", "hiss", " wag "))
GLOBAL_LIST_INIT(phobia_lizard_mobs, typecacheof(/mob/living/simple_animal/hostile/lizard))
GLOBAL_LIST_INIT(phobia_lizard_objs, typecacheof(/obj/item/toy/plush/lizardplushie, /obj/item/reagent_containers/food/snacks/kebab/tail, /obj/item/organ/tail/lizard,\
				/obj/item/reagent_containers/food/drinks/bottle/lizardwine))
GLOBAL_LIST_INIT(phobia_lizard_species, typecacheof(/datum/species/lizard))

GLOBAL_LIST_INIT(phobia_skeleton_words, list("skeleton", "milk", "xylophone", "bone", "calcium", "the ride never ends"))
GLOBAL_LIST_INIT(phobia_skeleton_objs, typecacheof(/obj/item/organ/tongue/bone, /obj/item/clothing/suit/armor/bone, /obj/item/stack/sheet/bone,\
				/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton, /obj/effect/decal/remains/human))
GLOBAL_LIST_INIT(phobia_skeleton_species, typecacheof(/datum/species/skeleton, /datum/species/plasmaman))


/datum/brain_trauma/mild/phobia
	name = "Phobia"
	desc = "Patient is unreasonably afraid of something."
	scan_desc = "phobia"
	gain_text = ""
	lose_text = ""
	var/phobia_type
	var/next_check = 0
	var/next_scare = 0
	var/list/trigger_words
	//instead of cycling every atom, only cycle the relevant types
	var/list/trigger_mobs
	var/list/trigger_objs //also checked in mob equipment
	var/list/trigger_turfs
	var/list/trigger_species

/datum/brain_trauma/mild/phobia/New(mob/living/carbon/C, _permanent, specific_type)
	phobia_type = specific_type
	if(!phobia_type)
		phobia_type = pick("spiders", "space", "security", "clowns", "greytide", "lizards","skeletons")

	gain_text = "<span class='warning'>You start finding [phobia_type] very unnerving...</span>"
	lose_text = "<span class='notice'>You no longer feel afraid of [phobia_type].</span>"
	scan_desc += " of [phobia_type]"
	switch(phobia_type)
		if("spiders")
			trigger_words = GLOB.phobia_spider_words
			trigger_mobs = GLOB.phobia_spider_mobs
			trigger_objs = GLOB.phobia_spider_objs
		if("space")
			trigger_words = GLOB.phobia_space_words
			trigger_turfs = GLOB.phobia_space_turfs
		if("security")
			trigger_words = GLOB.phobia_security_words
			trigger_mobs = GLOB.phobia_security_mobs
			trigger_objs = GLOB.phobia_security_objs
		if("clowns")
			trigger_words = GLOB.phobia_clown_words
			trigger_objs = GLOB.phobia_clown_objs
		if("greytide")
			trigger_words = GLOB.phobia_greytide_words
			trigger_objs = GLOB.phobia_greytide_objs
		if("lizards")
			trigger_words = GLOB.phobia_lizard_words
			trigger_objs = GLOB.phobia_lizard_objs
			trigger_mobs = GLOB.phobia_lizard_mobs
			trigger_species = GLOB.phobia_lizard_species
		if("skeletons")
			trigger_words = GLOB.phobia_skeleton_words
			trigger_objs = GLOB.phobia_skeleton_objs
			trigger_species = GLOB.phobia_skeleton_species

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
		to_chat(owner, "<span class='userdanger'>Hearing \"[trigger_word]\" [message]!</span>")
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
			to_chat(owner, "<span class='warning'>You shut your eyes in terror!</span>")
			owner.blind_eyes(10)
		if(4)
			owner.dizziness += 10
			owner.confused += 10
			owner.Jitter(10)
			owner.stuttering += 10