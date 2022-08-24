/datum/element/spooky
	element_flags = ELEMENT_DETACH|ELEMENT_BESPOKE
	id_arg_index = 2
	var/too_spooky = TRUE //will it spawn a new instrument?

/datum/element/spooky/Attach(datum/target, too_spooky = TRUE)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.too_spooky = too_spooky
	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/spectral_attack)

/datum/element/spooky/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_ATTACK)
	return ..()

/datum/element/spooky/proc/spectral_attack(datum/source, mob/living/carbon/C, mob/user)
	SIGNAL_HANDLER

	if(ishuman(user)) //this weapon wasn't meant for mortals.
		var/mob/living/carbon/human/U = user
		if(!istype(U.dna.species, /datum/species/skeleton))
			U.adjustStaminaLoss(35) //Extra Damage
			U.set_timed_status_effect(70 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
			U.set_timed_status_effect(40 SECONDS, /datum/status_effect/speech/stutter)
			if(U.getStaminaLoss() > 95)
				to_chat(U, "<font color ='red', size ='4'><B>Your ears weren't meant for this spectral sound.</B></font>")
				INVOKE_ASYNC(src, .proc/spectral_change, U)
			return

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.dna.species, /datum/species/skeleton))
			return //undeads are unaffected by the spook-pocalypse.
		if(istype(H.dna.species, /datum/species/zombie))
			H.adjustStaminaLoss(25)
			H.Paralyze(15) //zombies can't resist the doot
		C.set_timed_status_effect(70 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
		C.set_timed_status_effect(40 SECONDS, /datum/status_effect/speech/stutter)
		if((!istype(H.dna.species, /datum/species/skeleton)) && (!istype(H.dna.species, /datum/species/golem)) && (!istype(H.dna.species, /datum/species/android)) && (!istype(H.dna.species, /datum/species/jelly)))
			C.adjustStaminaLoss(25) //boneless humanoids don't lose the will to live
		to_chat(C, "<font color='red' size='4'><B>DOOT</B></font>")
		INVOKE_ASYNC(src, .proc/spectral_change, H)

	else //the sound will spook monkeys.
		C.set_timed_status_effect(30 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
		C.set_timed_status_effect(40 SECONDS, /datum/status_effect/speech/stutter)

/datum/element/spooky/proc/spectral_change(mob/living/carbon/human/H, mob/user)
	if((H.getStaminaLoss() > 95) && (!istype(H.dna.species, /datum/species/skeleton)) && (!istype(H.dna.species, /datum/species/golem)) && (!istype(H.dna.species, /datum/species/android)) && (!istype(H.dna.species, /datum/species/jelly)))
		H.Paralyze(20)
		H.set_species(/datum/species/skeleton)
		H.visible_message(span_warning("[H] has given up on life as a mortal."))
		var/T = get_turf(H)
		if(too_spooky)
			if(prob(90))
				var/obj/item/instrument = pick(
					/obj/item/instrument/saxophone/spectral,
					/obj/item/instrument/trumpet/spectral,
					/obj/item/instrument/trombone/spectral,
				)
				new instrument(T)
			else
				to_chat(H, span_boldwarning("The spooky gods forgot to ship your instrument. Better luck next unlife."))
		to_chat(H, span_boldnotice("You are the spooky skeleton!"))
		to_chat(H, span_boldnotice("A new life and identity has begun. Help your fellow skeletons into bringing out the spooky-pocalypse. You haven't forgotten your past life, and are still beholden to past loyalties."))
		change_name(H) //time for a new name!

/datum/element/spooky/proc/change_name(mob/living/carbon/human/spooked)
	var/skeleton_name = sanitize_name(tgui_input_text(spooked, "Enter your new skeleton name", "Spookifier", spooked.real_name, MAX_NAME_LEN))
	if(!skeleton_name)
		skeleton_name = "spooky skeleton"
	spooked.fully_replace_character_name(null, skeleton_name)
