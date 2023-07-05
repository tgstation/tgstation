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
	/// Cooldown for playing the laugh reel
	COOLDOWN_DECLARE(laugh_cooldown)

/obj/item/clothing/mask/gas/cluwne/Initialize(mapload)
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))

/obj/item/clothing/mask/gas/cluwne/proc/play_laugh()
	if(!COOLDOWN_FINISHED(src, laugh_cooldown))
		return

	COOLDOWN_START(src, laugh_cooldown, 5 SECONDS)
	playsound (src, pick('sound/items/SitcomLaugh1.ogg', 'sound/items/SitcomLaugh2.ogg', 'sound/items/SitcomLaugh3.ogg'), 30, 1)

/obj/item/clothing/mask/gas/cluwne/equipped(mob/user, slot) //when you put it on
	if(!user.has_dna())
		return ..()

	var/mob/living/carbon/player = user
	if(slot == ITEM_SLOT_MASK)
		log_admin("[key_name(player)] was made into a cluwne by [src]")
		message_admins("[key_name(player)] got cluwned by [src]")
		to_chat(player, span_userdanger("The masks straps suddenly tighten to your face! Your thoughts are erased by a horrible green light!"))
		player.cluwne_transform_dna()

	return ..()

/obj/item/clothing/mask/gas/cluwne/handle_speech(datum/source, list/speech_args)
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
