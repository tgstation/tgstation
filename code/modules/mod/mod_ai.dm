/obj/item/mod/control/transfer_ai(interaction, mob/user, mob/living/silicon/ai/intAI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(!open) //mod must be open
		balloon_alert(user, "panel closed!")
		return
	switch(interaction)
		if(AI_TRANS_TO_CARD)
			if(!ai_assistant)
				balloon_alert(user, "no ai in unit!")
				return
			balloon_alert(user, "transferring to card...")
			if(!do_after(user, 5 SECONDS, target = src))
				balloon_alert(user, "interrupted!")
				return
			if(!ai_assistant)
				balloon_alert(user, "no ai in unit!")
				return
			balloon_alert(user, "ai transferred to card")
			ai_exit_mod(card)

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to the suit.
			intAI = card.AI
			if(!intAI)
				balloon_alert(user, "no ai in card!")
				return
			if(ai_assistant)
				balloon_alert(user, "already has ai!")
				return
			if(intAI.deployed_shell) //Recall AI if shelled so it can be checked for a client
				intAI.disconnect_shell()
			if(intAI.stat || !intAI.client)
				balloon_alert(user, "ai unresponsive!")
				return
			balloon_alert(user, "transferring to unit...")
			if(!do_after(user, 5 SECONDS, target = src))
				balloon_alert(user, "interrupted!")
				return
			if(ai_assistant)
				return
			balloon_alert(user, "ai transferred to unit")
			ai_enter_mod(intAI)
			card.AI = null

/// Place an AI in control of your suit functions
/obj/item/mod/control/proc/ai_enter_mod(mob/living/silicon/ai/new_ai)
	new_ai.set_control_disabled(FALSE)
	new_ai.radio_enabled = TRUE
	new_ai.ai_restore_power()
	new_ai.cancel_camera()
	new_ai.controlled_equipment = src
	new_ai.remote_control = src
	new_ai.forceMove(src)
	on_gained_assistant(new_ai)

/// Remove an AI's control of your suit functions
/obj/item/mod/control/proc/ai_exit_mod(obj/item/aicard/card)
	var/mob/living/silicon/ai/old_ai = ai_assistant
	old_ai.ai_restore_power()//So the AI initially has power.
	old_ai.set_control_disabled(TRUE)
	old_ai.radio_enabled = FALSE
	old_ai.disconnect_shell()
	old_ai.forceMove(card)
	card.AI = old_ai
	old_ai.controlled_equipment = null
	on_removed_assistant(old_ai)

/// Place a pAI in control of your suit functions
/obj/item/mod/control/proc/insert_pai(mob/user, obj/item/pai_card/card)
	if (!isnull(ai_assistant))
		balloon_alert(user, "slot occupied!")
		return FALSE
	if (isnull(card.pai?.mind))
		balloon_alert(user, "pAI unresponsive!")
		return FALSE
	balloon_alert(user, "transferring to unit...")
	if (!do_after(user, 5 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return FALSE
	if (!user.transferItemToLoc(card, src))
		balloon_alert(user, "transfer failed!")
		return FALSE
	balloon_alert(user, "pAI transferred to unit")
	var/mob/living/silicon/pai/pai_assistant = card.pai
	pai_assistant.can_transmit = TRUE
	pai_assistant.can_receive = TRUE
	pai_assistant.can_holo = FALSE
	if (pai_assistant.holoform)
		pai_assistant.fold_in()
	SStgui.close_uis(card)
	on_gained_assistant(card.pai)
	return TRUE

/// Removes pAI control from a modsuit
/obj/item/mod/control/proc/remove_pai(mob/user, forced = FALSE)
	if (isnull(ai_assistant))
		balloon_alert(user, "no pAI!")
		return FALSE
	if (!forced)
		if (!open)
			balloon_alert(user, "panel closed!")
			return FALSE
		balloon_alert(user, "uninstalling card...")
		if (!do_after(user, 5 SECONDS, target = src))
			balloon_alert(user, "interrupted!")
			return FALSE

	balloon_alert(user, "pAI removed")
	var/mob/living/silicon/pai/pai_helper = ai_assistant
	pai_helper.can_holo = TRUE
	pai_helper.card.forceMove(get_turf(src))
	on_removed_assistant()

/// Called when a new ai assistant is inserted
/obj/item/mod/control/proc/on_gained_assistant(mob/living/silicon/new_helper)
	ai_assistant = new_helper
	balloon_alert(new_helper, "transferred to a mod unit")
	for(var/datum/action/action as anything in actions)
		action.Grant(new_helper)

/// Called when an existing ai assistant is removed
/obj/item/mod/control/proc/on_removed_assistant()
	for(var/datum/action/action as anything in actions)
		action.Remove(ai_assistant)
	ai_assistant.remote_control = null
	balloon_alert(ai_assistant, "transferred to a card")
	ai_assistant = null

#define MOVE_DELAY 2
#define WEARER_DELAY 1
#define LONE_DELAY 5
#define CHARGE_PER_STEP (DEFAULT_CHARGE_DRAIN * 2.5)
#define AI_FALL_TIME (1 SECONDS)

/obj/item/mod/control/relaymove(mob/user, direction)
	if((!active && wearer) || get_charge() < CHARGE_PER_STEP || user != ai_assistant || !COOLDOWN_FINISHED(src, cooldown_mod_move) || (wearer?.pulledby?.grab_state > GRAB_PASSIVE))
		return FALSE
	var/datum/mod_part/legs_to_move = get_part_datum_from_slot(ITEM_SLOT_FEET)
	if(wearer && (!legs_to_move || !legs_to_move.sealed))
		return FALSE
	var/timemodifier = MOVE_DELAY * (ISDIAGONALDIR(direction) ? sqrt(2) : 1) * (wearer ? WEARER_DELAY : LONE_DELAY)
	if(wearer && !wearer.Process_Spacemove(direction))
		return FALSE
	else if(!wearer && (!has_gravity() || !isturf(loc)))
		return FALSE
	COOLDOWN_START(src, cooldown_mod_move, movedelay * timemodifier + slowdown_deployed)
	subtract_charge(CHARGE_PER_STEP)
	playsound(src, 'sound/vehicles/mecha/mechmove01.ogg', 25, TRUE)
	if(ismovable(wearer?.loc))
		return wearer.loc.relaymove(wearer, direction)
	else if(wearer)
		ADD_TRAIT(wearer, TRAIT_FORCED_STANDING, REF(src))
		addtimer(CALLBACK(src, PROC_REF(ai_fall)), AI_FALL_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	var/atom/movable/mover = wearer || src
	return mover.try_step_multiz(direction)

#undef MOVE_DELAY
#undef WEARER_DELAY
#undef LONE_DELAY
#undef CHARGE_PER_STEP

/obj/item/mod/control/proc/ai_fall()
	if(!wearer)
		return
	REMOVE_TRAIT(wearer, TRAIT_FORCED_STANDING, REF(src))

/obj/item/mod/ai_minicard
	name = "AI mini-card"
	desc = "A small card designed to eject dead AIs. You could use an intellicard to recover it."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "minicard"
	var/datum/weakref/stored_ai

/obj/item/mod/ai_minicard/Initialize(mapload, mob/living/silicon/ai/ai)
	. = ..()
	if(isnull(ai))
		return
	ai.controlled_equipment = null
	ai.remote_control = null
	ai.apply_damage(150, BURN)
	INVOKE_ASYNC(ai, TYPE_PROC_REF(/mob/living/silicon/ai, death))
	ai.forceMove(src)
	stored_ai = WEAKREF(ai)
	icon_state = "minicard-filled"

/obj/item/mod/ai_minicard/Destroy()
	QDEL_NULL(stored_ai)
	return ..()

/obj/item/mod/ai_minicard/examine(mob/user)
	. = ..()
	. += span_notice("You see [stored_ai.resolve() || "no AI"] stored inside.")

/obj/item/mod/ai_minicard/transfer_ai(interaction, mob/user, mob/living/silicon/ai/intAI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(interaction != AI_TRANS_TO_CARD)
		return
	var/mob/living/silicon/ai/ai = stored_ai.resolve()
	if(!ai)
		balloon_alert(user, "no ai!")
		return
	balloon_alert(user, "transferring to card...")
	if(!do_after(user, 5 SECONDS, target = src) || !ai)
		balloon_alert(user, "interrupted!")
		return
	icon_state = "minicard"
	ai.forceMove(card)
	card.AI = ai
	ai.notify_revival("You have been recovered from the wreckage!", source = card)
	balloon_alert(user, "ai transferred to card")
	stored_ai = null

#undef AI_FALL_TIME
