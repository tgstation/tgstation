//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	icon = "beer"
	value = 4
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = span_notice("You feel like you could drink a whole keg!")
	lose_text = span_danger("You don't feel as resistant to alcohol anymore. Somehow.")
	medical_record_text = "Patient demonstrates a high tolerance for alcohol."
	mail_goodies = list(/obj/item/skillchip/wine_taster)

/datum/quirk/apathetic
	name = "Apathetic"
	desc = "You just don't care as much as other people. That's nice to have in a place like this, I guess."
	icon = "meh"
	value = 4
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	medical_record_text = "Patient was administered the Apathy Evaluation Scale but did not bother to complete it."
	mail_goodies = list(/obj/item/hourglass)

/datum/quirk/apathetic/add(client/client_source)
	quirk_holder.mob_mood?.mood_modifier -= 0.2

/datum/quirk/apathetic/remove()
	quirk_holder.mob_mood?.mood_modifier += 0.2

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	icon = "wine-bottle"
	value = 8
	gain_text = span_notice("You feel like a drink would do you good.")
	lose_text = span_danger("You no longer feel like drinking would ease your pain.")
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/booze)

/datum/quirk/drunkhealing/process(delta_time)
	switch(quirk_holder.get_drunk_amount())
		if (6 to 40)
			quirk_holder.adjustBruteLoss(-0.1 * delta_time, FALSE, required_bodytype = BODYTYPE_ORGANIC)
			quirk_holder.adjustFireLoss(-0.05 * delta_time, required_bodytype = BODYTYPE_ORGANIC)
		if (41 to 60)
			quirk_holder.adjustBruteLoss(-0.4 * delta_time, FALSE, required_bodytype = BODYTYPE_ORGANIC)
			quirk_holder.adjustFireLoss(-0.2 * delta_time, required_bodytype = BODYTYPE_ORGANIC)
		if (61 to INFINITY)
			quirk_holder.adjustBruteLoss(-0.8 * delta_time, FALSE, required_bodytype = BODYTYPE_ORGANIC)
			quirk_holder.adjustFireLoss(-0.4 * delta_time, required_bodytype = BODYTYPE_ORGANIC)

/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	icon = "smile-beam"
	value = 8
	mob_trait = TRAIT_EMPATH
	gain_text = span_notice("You feel in tune with those around you.")
	lose_text = span_danger("You feel isolated from others.")
	medical_record_text = "Patient is highly perceptive of and sensitive to social cues, or may possibly have ESP. Further testing needed."
	mail_goodies = list(/obj/item/toy/foamfinger)

/datum/quirk/item_quirk/clown_enjoyer
	name = "Clown Enjoyer"
	desc = "You enjoy clown antics and get a mood boost from wearing your clown pin."
	icon = "map-pin"
	value = 2
	mob_trait = TRAIT_CLOWN_ENJOYER
	gain_text = span_notice("You are a big enjoyer of clowns.")
	lose_text = span_danger("The clown doesn't seem so great.")
	medical_record_text = "Patient reports being a big enjoyer of clowns."
	mail_goodies = list(
		/obj/item/bikehorn,
		/obj/item/stamp/clown,
		/obj/item/megaphone/clown,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/bedsheet/clown,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/storage/backpack/clown,
		/obj/item/storage/backpack/duffelbag/clown,
		/obj/item/toy/crayon/rainbow,
		/obj/item/toy/figure/clown,
	)

/datum/quirk/item_quirk/clown_enjoyer/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/accessory/clown_enjoyer_pin, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/clown_enjoyer/add(client/client_source)
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	fan.show_to(quirk_holder)

/datum/quirk/item_quirk/mime_fan
	name = "Mime Fan"
	desc = "You're a fan of mime antics and get a mood boost from wearing your mime pin."
	icon = "thumbtack"
	value = 2
	mob_trait = TRAIT_MIME_FAN
	gain_text = span_notice("You are a big fan of the Mime.")
	lose_text = span_danger("The mime doesn't seem so great.")
	medical_record_text = "Patient reports being a big fan of mimes."
	mail_goodies = list(
		/obj/item/toy/crayon/mime,
		/obj/item/clothing/mask/gas/mime,
		/obj/item/storage/backpack/mime,
		/obj/item/clothing/under/rank/civilian/mime,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing,
		/obj/item/stamp/mime,
		/obj/item/storage/box/survival/hug/black,
		/obj/item/bedsheet/mime,
		/obj/item/clothing/shoes/sneakers/mime,
		/obj/item/toy/figure/mime,
		/obj/item/toy/crayon/spraycan/mimecan,
	)

/datum/quirk/item_quirk/mime_fan/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/accessory/mime_fan_pin, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/mime_fan/add(client/client_source)
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	fan.show_to(quirk_holder)

/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly and take no damage from short falls."
	icon = "running"
	value = 8
	mob_trait = TRAIT_FREERUNNING
	gain_text = span_notice("You feel lithe on your feet!")
	lose_text = span_danger("You feel clumsy again.")
	medical_record_text = "Patient scored highly on cardio tests."
	mail_goodies = list(/obj/item/melee/skateboard, /obj/item/clothing/shoes/wheelys/rollerskates)

/datum/quirk/friendly
	name = "Friendly"
	desc = "You give the best hugs, especially when you're in the right mood."
	icon = "hands-helping"
	value = 2
	mob_trait = TRAIT_FRIENDLY
	gain_text = span_notice("You want to hug someone.")
	lose_text = span_danger("You no longer feel compelled to hug others.")
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	medical_record_text = "Patient demonstrates low-inhibitions for physical contact and well-developed arms. Requesting another doctor take over this case."
	mail_goodies = list(/obj/item/storage/box/hug)

/datum/quirk/jolly
	name = "Jolly"
	desc = "You sometimes just feel happy, for no reason at all."
	icon = "grin"
	value = 4
	mob_trait = TRAIT_JOLLY
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	medical_record_text = "Patient demonstrates constant euthymia irregular for environment. It's a bit much, to be honest."
	mail_goodies = list(/obj/item/clothing/mask/joy)

/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step; footsteps and stepping on sharp objects is quieter and less painful. Also, your hands and clothes will not get messed in case of stepping in blood."
	icon = "shoe-prints"
	value = 4
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = span_notice("You walk with a little more litheness.")
	lose_text = span_danger("You start tromping around like a barbarian.")
	medical_record_text = "Patient's dexterity belies a strong capacity for stealth."
	mail_goodies = list(/obj/item/clothing/shoes/sandal)

/datum/quirk/item_quirk/musician
	name = "Musician"
	desc = "You can tune handheld musical instruments to play melodies that clear certain negative effects and soothe the soul."
	icon = "guitar"
	value = 2
	mob_trait = TRAIT_MUSICIAN
	gain_text = span_notice("You know everything about musical instruments.")
	lose_text = span_danger("You forget how musical instruments work.")
	medical_record_text = "Patient brain scans show a highly-developed auditory pathway."
	mail_goodies = list(/obj/effect/spawner/random/entertainment/musical_instrument, /obj/item/instrument/piano_synth/headphones)

/datum/quirk/item_quirk/musician/add_unique(client/client_source)
	give_item_to_holder(/obj/item/choice_beacon/music, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	icon = "eye"
	value = 4
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = span_notice("The shadows seem a little less dark.")
	lose_text = span_danger("Everything seems a little darker.")
	medical_record_text = "Patient's eyes show above-average acclimation to darkness."
	mail_goodies = list(
		/obj/item/flashlight/flashdark,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom,
		/obj/item/skillchip/light_remover,
	)

/datum/quirk/night_vision/add(client/client_source)
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/remove()
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/proc/refresh_quirk_holder_eyes()
	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	var/obj/item/organ/internal/eyes/eyes = human_quirk_holder.getorgan(/obj/item/organ/internal/eyes)
	if(!eyes || eyes.lighting_cutoff)
		return
	// We've either added or removed TRAIT_NIGHT_VISION before calling this proc. Just refresh the eyes.
	eyes.refresh()

/datum/quirk/item_quirk/poster_boy
	name = "Poster Boy"
	desc = "You have some great posters! Hang them up and make everyone have a great time."
	icon = "tape"
	value = 4
	mob_trait = TRAIT_POSTERBOY
	medical_record_text = "Patient reports a desire to cover walls with homemade objects."
	mail_goodies = list(/obj/item/poster/random_official)

/datum/quirk/item_quirk/poster_boy/add_unique()
	var/mob/living/carbon/human/posterboy = quirk_holder
	var/obj/item/storage/box/posterbox/newbox = new()
	newbox.add_quirk_posters(posterboy.mind)
	give_item_to_holder(newbox, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/obj/item/storage/box/posterbox
	name = "Box of Posters"
	desc = "You made them yourself!"

/// fills box of posters based on job, one neutral poster and 2 department posters
/obj/item/storage/box/posterbox/proc/add_quirk_posters(datum/mind/posterboy)
	new /obj/item/poster/quirk/crew/random(src)
	var/department = posterboy.assigned_role.paycheck_department
	if(department == ACCOUNT_CIV) //if you are not part of a department you instead get 3 neutral posters
		for(var/i in 1 to 2)
			new /obj/item/poster/quirk/crew/random(src)
		return
	for(var/obj/item/poster/quirk/potential_poster as anything in subtypesof(/obj/item/poster/quirk))
		if(initial(potential_poster.quirk_poster_department) != department)
			continue
		new potential_poster(src)

/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "You know your body well, and can accurately assess the extent of your wounds."
	icon = "bone"
	value = 8
	mob_trait = TRAIT_SELF_AWARE
	medical_record_text = "Patient demonstrates an uncanny knack for self-diagnosis."
	mail_goodies = list(/obj/item/clothing/neck/stethoscope, /obj/item/skillchip/entrails_reader)

/datum/quirk/skittish
	name = "Skittish"
	desc = "You're easy to startle, and hide frequently. Run into a closed locker to jump into it, as long as you have access. You can walk to avoid this."
	icon = "trash"
	value = 8
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient demonstrates a high aversion to danger and has described hiding in containers out of fear."
	mail_goodies = list(/obj/structure/closet/cardboard)

/datum/quirk/item_quirk/spiritual
	name = "Spiritual"
	desc = "You hold a spiritual belief, whether in God, nature or the arcane rules of the universe. You gain comfort from the presence of holy people, and believe that your prayers are more special than others. Being in the chapel makes you happy."
	icon = "bible"
	value = 4
	mob_trait = TRAIT_SPIRITUAL
	gain_text = span_notice("You have faith in a higher power.")
	lose_text = span_danger("You lose faith!")
	medical_record_text = "Patient reports a belief in a higher power."
	mail_goodies = list(
		/obj/item/storage/book/bible/booze,
		/obj/item/reagent_containers/cup/glass/bottle/holywater,
		/obj/item/bedsheet/chaplain,
		/obj/item/toy/cards/deck/tarot,
		/obj/item/storage/fancy/candle_box,
	)

/datum/quirk/item_quirk/spiritual/add_unique(client/client_source)
	give_item_to_holder(/obj/item/storage/fancy/candle_box, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(/obj/item/storage/box/matches, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/tagger
	name = "Tagger"
	desc = "You're an experienced artist. People will actually be impressed by your graffiti, and you can get twice as many uses out of drawing supplies."
	icon = "spray-can"
	value = 4
	mob_trait = TRAIT_TAGGER
	gain_text = span_notice("You know how to tag walls efficiently.")
	lose_text = span_danger("You forget how to tag walls properly.")
	medical_record_text = "Patient was recently seen for possible paint huffing incident."
	mail_goodies = list(
		/obj/item/toy/crayon/spraycan,
		/obj/item/canvas/nineteen_nineteen,
		/obj/item/canvas/twentythree_nineteen,
		/obj/item/canvas/twentythree_twentythree
	)

/datum/quirk/item_quirk/tagger/add_unique(client/client_source)
	give_item_to_holder(/obj/item/toy/crayon/spraycan, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/throwingarm
	name = "Throwing Arm"
	desc = "Your arms have a lot of heft to them! Objects that you throw just always seem to fly further than everyone elses, and you never miss a toss."
	icon = "baseball"
	value = 7
	mob_trait = TRAIT_THROWINGARM
	gain_text = span_notice("Your arms are full of energy!")
	lose_text = span_danger("Your arms ache a bit.")
	medical_record_text = "Patient displays mastery over throwing balls."
	mail_goodies = list(/obj/item/toy/beach_ball/baseball, /obj/item/toy/beach_ball/holoball, /obj/item/toy/beach_ball/holoball/dodgeball)

/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine."
	icon = "drumstick-bite"
	value = 4
	mob_trait = TRAIT_VORACIOUS
	gain_text = span_notice("You feel HONGRY.")
	lose_text = span_danger("You no longer feel HONGRY.")
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/dinner)

/datum/quirk/item_quirk/signer
	name = "Signer"
	desc = "You possess excellent communication skills in sign language."
	icon = "hands"
	value = 4
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/gloves/radio)

/datum/quirk/item_quirk/signer/add_unique(client/client_source)
	quirk_holder.AddComponent(/datum/component/sign_language)
	var/obj/item/clothing/gloves/gloves_type = /obj/item/clothing/gloves/radio
	if(isplasmaman(quirk_holder))
		gloves_type = /obj/item/clothing/gloves/color/plasmaman/radio
	give_item_to_holder(gloves_type, list(LOCATION_GLOVES = ITEM_SLOT_GLOVES, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/signer/remove()
	qdel(quirk_holder.GetComponent(/datum/component/sign_language))
