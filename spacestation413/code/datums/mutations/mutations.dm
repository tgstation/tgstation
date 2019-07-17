/datum/mutation/human/cluwne

	name = "Cluwne"
	quality = NEGATIVE
	locked = TRUE
	text_gain_indication = "<span class='danger'>You feel like your brain is tearing itself apart.</span>"

/datum/mutation/human/cluwne/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.dna.add_mutation(CLOWNMUT)
	owner.dna.add_mutation(EPILEPSY)
	owner.setBrainLoss(BRAIN_DAMAGE_DEATH - 10)

	var/mob/living/carbon/human/H = owner

	if(!istype(H.wear_mask, /obj/item/clothing/mask/spacestation413/cluwne))
		if(!H.doUnEquip(H.wear_mask))
			qdel(H.wear_mask)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/spacestation413/cluwne(H), SLOT_WEAR_MASK)
	if(!istype(H.w_uniform, /obj/item/clothing/under/spacestation413/cluwne))
		if(!H.doUnEquip(H.w_uniform))
			qdel(H.w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/spacestation413/cluwne(H), SLOT_W_UNIFORM)
	if(!istype(H.shoes, /obj/item/clothing/shoes/spacestation413/cluwne))
		if(!H.doUnEquip(H.shoes))
			qdel(H.shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/spacestation413/cluwne(H), SLOT_SHOES)

	owner.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/white(owner), SLOT_GLOVES) // this is purely for cosmetic purposes incase they aren't wearing anything in that slot
	owner.equip_to_slot_or_del(new /obj/item/storage/backpack/clown(owner), SLOT_BACK) // ditto

/datum/mutation/human/cluwne/on_life(mob/living/carbon/human/owner)
	if((prob(15) && owner.IsUnconscious()))
		owner.setBrainLoss(BRAIN_DAMAGE_DEATH - 10) // there I changed it to setBrainLoss
		switch(rand(1, 6))
			if(1)
				owner.say("HONK")
			if(2 to 5)
				owner.emote("scream")
			if(6)
				owner.Stun(1)
				owner.Knockdown(20)
				owner.Jitter(500)

/datum/mutation/human/cluwne/on_losing(mob/living/carbon/human/owner)
	owner.adjust_fire_stacks(1)
	owner.IgniteMob()
	owner.dna.add_mutation(CLUWNEMUT)

/mob/living/carbon/human/proc/cluwneify()
	dna.add_mutation(CLUWNEMUT)
	emote("scream")
	regenerate_icons()
	visible_message("<span class='danger'>[src]'s body glows green, the glow dissipating only to leave behind a cluwne formerly known as [src]!</span>", \
					"<span class='danger'>Your brain feels like it's being torn apart, and after a short while, you notice that you've become a cluwne!</span>")
	flash_act()

/datum/mutation/human/hulk
	species_allowed = list()

/mob/living/carbon/human/proc/spurdofy()
	dna.add_mutation(SPURDOMUT)


/datum/mutation/human/spurdo
	name = "Spurdo"
	desc = "A horrific affliction from the dark realms of Finland."
	quality = MINOR_NEGATIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel an insatiable craving for Euroshopper brand energy drink.</span>"
	text_lose_indication = "<span class='notice'>You no longer feel very ebin.</span>"

/datum/mutation/human/spurdo/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, .proc/handle_speech)

/datum/mutation/human/spurdo/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/spurdo/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message,"c","g")
		message = replacetext(message,"k","g")
		message = replacetext(message,"t","d")
		message = replacetext(message,"th","d")
		if(prob(30))
			message += " :[pick("D", "DD", "DDD")]!"
		speech_args[SPEECH_MESSAGE] = trim(message)