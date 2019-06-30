/obj/item/clothing/mask/spacestation413/cluwne
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	flags_cover = MASKCOVERSEYES
	icon_state = "cluwne"
	item_state = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = MASKINTERNALS
	item_flags = ABSTRACT | DROPDEL
	flags_inv = HIDEEARS|HIDEEYES
	var/voicechange = TRUE
	var/last_sound = 0
	var/delay = 15

/obj/item/clothing/mask/spacestation413/cluwne/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/mask/spacestation413/cluwne/proc/play_laugh1()
	if(world.time - delay > last_sound)
		playsound (src, 'spacestation413/sound/voice/cluwnelaugh1.ogg', 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/spacestation413/cluwne/proc/play_laugh2()
	if(world.time - delay > last_sound)
		playsound (src, 'spacestation413/sound/voice/cluwnelaugh2.ogg', 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/spacestation413/cluwne/proc/play_laugh3()
	if(world.time - delay > last_sound)
		playsound (src, 'spacestation413/sound/voice/cluwnelaugh3.ogg', 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/spacestation413/cluwne/equipped(mob/user, slot) //when you put it on
	var/mob/living/carbon/C = user
	if((C.wear_mask == src) && (voicechange))
		play_laugh1()
	return ..()

/obj/item/clothing/mask/spacestation413/cluwne/handle_speech(datum/source, list/speech_args) //whenever you speak
	var/message = speech_args[SPEECH_MESSAGE]
	if(voicechange)
		if(prob(5)) //the brain isnt fully gone yet...
			message = pick("HELP ME!!","PLEASE KILL ME!!","I WANT TO DIE!!", "END MY SUFFERING", "I CANT TAKE THIS ANYMORE!!" ,"SOMEBODY STOP ME!!")
			play_laugh2()
		if(prob(3))
			message = pick("HOOOOINKKKKKKK!!", "HOINK HOINK HOINK HOINK!!","HOINK HOINK!!","HOOOOOOIIINKKKK!!") //but most of the time they cant speak,
			play_laugh3()
		else
			message = pick("HEEEENKKKKKK!!", "HONK HONK HONK HONK!!","HONK HONK!!","HOOOOOONKKKK!!") //More sounds,
			play_laugh1()
	speech_args[SPEECH_MESSAGE] = trim(message)

/obj/item/clothing/mask/spacestation413/cluwne/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == SLOT_WEAR_MASK)
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return

/obj/item/clothing/mask/spacestation413/cluwne/happy_cluwne
	name = "Happy Cluwne Mask"
	desc = "The mask of a poor cluwne that has been scrubbed of its curse by the Nanotrasen supernatural machinations division. Guaranteed to be %99 curse free and %99.9 not haunted. "
	flags_1 = MASKINTERNALS
	//alternate_screams = list('spacestation413/sound/voice/cluwnelaugh1.ogg','spacestation413/sound/voice/cluwnelaugh2.ogg','spacestation413/sound/voice/cluwnelaugh3.ogg')
	item_flags = ABSTRACT
	var/can_cluwne = FALSE
	var/is_cursed = FALSE //i don't care that this is *slightly* memory wasteful, it's just one more byte and it's not like some madman is going to spawn thousands of these
	var/is_very_cursed = FALSE

/obj/item/clothing/mask/spacestation413/cluwne/happy_cluwne/Initialize()
	.=..()
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	if(prob(1)) //this function pre-determines the logic of the cluwne mask. applying and reapplying the mask does not alter or change anything
		is_cursed = TRUE
		is_very_cursed = FALSE
	else if(prob(0.1))
		is_cursed = FALSE
		is_very_cursed = TRUE

/obj/item/clothing/mask/spacestation413/cluwne/happy_cluwne/attack_self(mob/user)
	voicechange = !voicechange
	to_chat(user, "<span class='notice'>You turn the voice box [voicechange ? "on" : "off"]!</span>")
	if(voicechange)
		play_laugh1()

/obj/item/clothing/mask/spacestation413/cluwne/happy_cluwne/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == SLOT_WEAR_MASK)
		if(is_cursed && can_cluwne) //logic predetermined
			log_admin("[key_name(H)] was made into a cluwne by [src]")
			message_admins("[key_name(H)] got cluwned by [src]")
			to_chat(H, "<span class='userdanger'>The masks straps suddenly tighten to your face and your thoughts are erased by a horrible green light!</span>")
			H.dropItemToGround(src)
			H.cluwneify()
			qdel(src)
		else if(is_very_cursed && can_cluwne)
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
			S.Acquire_Victim(user)
			log_admin("[key_name(user)] summoned a floor cluwne using the [src]")
			message_admins("[key_name(user)] summoned a floor cluwne using the [src]")
			to_chat(H, "<span class='warning'>The mask suddenly slips off your face and... slides under the floor?</span>")
			to_chat(H, "<i>...dneirf uoy ot gnoleb ton seod tahT</i>")
			qdel(src)
