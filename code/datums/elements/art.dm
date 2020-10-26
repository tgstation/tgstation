/datum/element/art
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	var/impressiveness = 0

/datum/element/art/Attach(datum/target, impress)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	impressiveness = impress
	if(isobj(target))
		RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_obj_examine)
		if(isstructure(target))
			RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
		if(isitem(target))
			RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, .proc/apply_moodlet)
	else
		RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_other_examine)

/datum/element/art/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_PARENT_EXAMINE, COMSIG_ATOM_ATTACK_HAND, COMSIG_ITEM_ATTACK_SELF))
	return ..()

/datum/element/art/proc/apply_moodlet(atom/source, mob/M, impress)
	SIGNAL_HANDLER

	M.visible_message("<span class='notice'>[M] stops and looks intently at [source].</span>", \
						 "<span class='notice'>You stop to take in [source].</span>")
	switch(impress)
		if (0 to BAD_ART)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artbad", /datum/mood_event/artbad)
		if (BAD_ART to GOOD_ART)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artok", /datum/mood_event/artok)
		if (GOOD_ART to GREAT_ART)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artgood", /datum/mood_event/artgood)
		if(GREAT_ART to INFINITY)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artgreat", /datum/mood_event/artgreat)

/datum/element/art/proc/on_other_examine(atom/source, mob/M)
	SIGNAL_HANDLER

	apply_moodlet(source, M, impressiveness)

/datum/element/art/proc/on_obj_examine(atom/source, mob/M)
	SIGNAL_HANDLER

	var/obj/O = source
	apply_moodlet(source, M, impressiveness *(O.obj_integrity/O.max_integrity))

/datum/element/art/proc/on_attack_hand(atom/source, mob/M)
	SIGNAL_HANDLER_DOES_SLEEP

	to_chat(M, "<span class='notice'>You start examining [source]...</span>")
	if(!do_after(M, 20, target = source))
		return
	on_obj_examine(source, M)

/datum/element/art/rev

/datum/element/art/rev/apply_moodlet(atom/source, mob/M, impress)
	M.visible_message("<span class='notice'>[M] stops to inspect [source].</span>", \
						 "<span class='notice'>You take in [source], inspecting the fine craftsmanship of the proletariat.</span>")

	if(M.mind && M.mind.has_antag_datum(/datum/antagonist/rev))
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artgreat", /datum/mood_event/artgreat)
	else
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "artbad", /datum/mood_event/artbad)
