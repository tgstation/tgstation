/obj/item/clothing/mask/gas/cluwne
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	flags_cover = MASKCOVERSEYES
	has_fov = FALSE
	icon_state = "cluwne"
	inhand_icon_state = "cluwne"
	item_flags = DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	modifies_speech = TRUE
	w_class = WEIGHT_CLASS_SMALL
	/// The voice change toggle.
	var/voicechange = TRUE
	/// The last time a sound was played.
	var/last_sound = 0
	/// The delay between sounds.
	var/delay = 2 SECONDS

/obj/item/clothing/mask/gas/cluwne/Initialize(mapload)
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))

/obj/item/clothing/mask/gas/cluwne/proc/play_laugh()
	if(world.time - delay > last_sound)
		playsound (src, pick('sound/items/SitcomLaugh1.ogg', 'sound/items/SitcomLaugh2.ogg', 'sound/items/SitcomLaugh3.ogg'), 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/gas/cluwne/equipped(mob/user, slot) //when you put it on
	if(!user.has_dna())
		return ..()
	var/mob/living/carbon/player = user
	if((player.wear_mask == src) && (voicechange))
		play_laugh()
	return ..()

/obj/item/clothing/mask/gas/cluwne/equipped(mob/user, slot)
	if(slot == ITEM_SLOT_MASK)
		var/mob/living/carbon/player = user
		player.dna.add_mutation(/datum/mutation/human/cluwne)
	return ..()

/obj/item/clothing/mask/gas/cluwne/handle_speech(datum/source, list/speech_args)
	if(!voicechange)
		return ..()

	if(prob(5)) //the brain isn't fully gone yet...
		speech_args[SPEECH_MESSAGE] = pick("AAAAAAA!!", "END MY SUFFERING", "I CANT TAKE THIS ANYMORE!!" ,"SOMEBODY STOP ME!!")
		return SPEECH_MESSAGE

	if(prob(25))
		play_laugh()

	speech_args[SPEECH_MESSAGE] = pick(
		"HEEEENKKKKKK!!", \
		"HONK HONK HONK HONK!!",\
		"HONK HONK!!",\
		"HOOOOOONKKKK!!", \
		"HOOOOINKKKKKKK!!", \
		"HOINK HOINK HOINK HOINK!!", \
		"HOINK HOINK!!", \
		"HOOOOOOIIINKKKK!!"\
		)

	return SPEECH_MESSAGE

/obj/item/clothing/mask/gas/cluwne/happy_cluwne
	name = "Happy Cluwne Mask"
	desc = "The mask of a poor cluwne that has been scrubbed of its curse by the Nanotrasen supernatural machinations division. Guaranteed to be 99% curse free and 99.9% not haunted."
	flags_1 = MASKINTERNALS
	item_flags = ABSTRACT
	/// Is the mask cursed?
	var/is_cursed = FALSE

/obj/item/clothing/mask/gas/cluwne/happy_cluwne/attack_self(mob/user)
	voicechange = !voicechange
	to_chat(user, span_notice("You turn the voice box [voicechange ? "on" : "off"]!"))
	if(voicechange)
		play_laugh()

/obj/item/clothing/mask/gas/cluwne/happy_cluwne/equipped(mob/user, slot)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/victim = user
	if(slot == ITEM_SLOT_MASK && is_cursed)
		log_admin("[key_name(victim)] was made into a cluwne by [src]")
		message_admins("[key_name(victim)] got cluwned by [src]")
		to_chat(victim, span_userdanger("The masks straps suddenly tighten to your face and your thoughts are erased by a horrible green light!"))
		victim.dropItemToGround(src)
		victim.cluwne_transform_dna()
		qdel(src)
	to_chat(victim, span_danger("...dneirf uoy ot gnoleb ton seod tahT"))
	return ..()
