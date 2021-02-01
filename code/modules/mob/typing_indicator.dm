/mob/verb/say_wrapper()
	set name = ".say"
	set hidden = TRUE

	var/image/typing_indicator = image('icons/mob/talk.dmi', src, "default0", FLY_LAYER)
	if(isliving(src)) //only living mobs have the bubble_icon var
		var/mob/living/L = src
		typing_indicator = image('icons/mob/talk.dmi', src, L.bubble_icon + "0", FLY_LAYER) //get unique speech bubble icons for different species

	typing_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	overlays += typing_indicator

	if(ishuman(src))
		var/mob/living/carbon/human/H = src

		if(H.dna.check_mutation(MUT_MUTE) || H.silent) //Check for mute or silent, remove the overlay if true
			overlays -= typing_indicator
			return

	if(client)
		if(stat != CONSCIOUS || is_muzzled())
			overlays -= typing_indicator

	var/message = input("", "Say \"text\"") as null|text

	overlays -= typing_indicator

	say_verb(message)

/mob/verb/me_wrapper()
	set name = ".me"
	set hidden = TRUE

	var/image/typing_indicator = image('icons/mob/talk.dmi', src, "default0", FLY_LAYER)
	if(isliving(src)) //only living mobs have the bubble_icon var
		typing_indicator = image('icons/mob/talk.dmi', src, "emoting", FLY_LAYER)

	typing_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	overlays += typing_indicator

	if(client)
		if(stat != CONSCIOUS)
			overlays -= typing_indicator

	var/message = input("", "Me \"text\"") as null|text

	overlays -= typing_indicator

	me_verb(message)