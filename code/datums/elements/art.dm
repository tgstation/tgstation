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
		if(isstructure(target))
			RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
		else if(isitem(target))
			RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, .proc/on_attack_self)
		else
			RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_obj_examine)
	else
		RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_other_examine)

/datum/element/art/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_PARENT_EXAMINE, COMSIG_ATOM_ATTACK_HAND, COMSIG_ITEM_ATTACK_SELF))
	return ..()

/datum/element/art/proc/apply_moodlet(atom/source, mob/user, impress)
	SIGNAL_HANDLER

	var/msg
	switch(impress)
		if(GREAT_ART to INFINITY)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artgreat", /datum/mood_event/artgreat)
			msg = "What \a [pick("masterpiece", "chef-d'oeuvre")] [source.p_theyre(TRUE)]. So [pick("trascended", "awe-inspiring", "bewitching", "impeccable")]!"
		if (GOOD_ART to GREAT_ART)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artgood", /datum/mood_event/artgood)
			msg = "[source.p_theyre(TRUE)] a [pick("respectable", "commendable", "laudable")] art piece, easy on the keen eye."
		if (BAD_ART to GOOD_ART)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artok", /datum/mood_event/artok)
			msg = "[source.p_theyre(TRUE)] fair to middling, enough to be called an \"art object\"."
		if (0 to BAD_ART)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artbad", /datum/mood_event/artbad)
			msg = "Wow, [source.p_they()] sucks."

	user.visible_message("<span class='notice'>[user] stops and looks intently at [source].</span>", \
						 "<span class='notice'>You appraise [source]... [msg]</span>")

/datum/element/art/proc/on_other_examine(atom/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	apply_moodlet(source, user, impressiveness)

/datum/element/art/proc/on_obj_examine(atom/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	var/obj/art_piece = source
	apply_moodlet(source, user, impressiveness *(art_piece.obj_integrity/art_piece.max_integrity))

/datum/element/art/proc/on_attack_hand(atom/source, mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, .proc/appraise, source, user) //Do not sleep the proc!

/datum/element/art/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, .proc/appraise, source, user)

/datum/element/art/proc/appraise(atom/source, mob/user)
	to_chat(user, "<span class='notice'>You start appraising [source]...</span>")
	if(!do_after(user, 20, target = source))
		return
	on_obj_examine(source, user)

/datum/element/art/rev

/datum/element/art/rev/apply_moodlet(atom/source, mob/user, impress)
	var/msg
	if(user.mind?.has_antag_datum(/datum/antagonist/rev))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artgreat", /datum/mood_event/artgreat)
		msg = "What \a [pick("masterpiece", "chef-d'oeuvre")] [source.p_theyre(TRUE)]. So [pick("subversive", "revolutionary", "unitizing", "egalitarian")]!"
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artbad", /datum/mood_event/artbad)
		msg = "Wow, [source.p_they()] sucks."

	user.visible_message("<span class='notice'>[user] stops to inspect [source].</span>", \
						 "<span class='notice'>You appraise [source], inspecting the fine craftsmanship of the proletariat... [msg]</span>")
