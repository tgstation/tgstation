/**
 * spirit holding component; for items to have spirits inside of them for "advice"
 *
 * Used for the possessed blade and fantasy affixes
 */
/datum/component/spirit_holding
	///bool on if this component is currently polling for observers to inhabit the item
	var/attempting_awakening = FALSE
	/// Allows renaming the bound item
	var/allow_renaming
	/// Allows channeling
	var/allow_channeling
	///mob contained in the item.
	var/mob/living/basic/shade/bound_spirit

/datum/component/spirit_holding/Initialize(datum/mind/soul_to_bind, mob/awakener, allow_renaming = TRUE, allow_channeling = TRUE)
	if(!ismovable(parent)) //you may apply this to mobs, i take no responsibility for how that works out
		return COMPONENT_INCOMPATIBLE
	src.allow_renaming = allow_renaming
	src.allow_channeling = allow_channeling
	if(soul_to_bind)
		bind_the_soule(soul_to_bind, awakener, soul_to_bind.name)

/datum/component/spirit_holding/Destroy(force)
	. = ..()
	if(bound_spirit)
		QDEL_NULL(bound_spirit)

/datum/component/spirit_holding/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_destroy))

/datum/component/spirit_holding/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_ATTACK_SELF, COMSIG_QDELETING))

///signal fired on examining the parent
/datum/component/spirit_holding/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!bound_spirit)
		examine_list += span_notice("[parent] sleeps.[allow_channeling ? " Use [parent] in your hands to attempt to awaken it." : ""]")
		return
	examine_list += span_notice("[parent] is alive.")

///signal fired on self attacking parent
/datum/component/spirit_holding/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(get_ghost), user)

/datum/component/spirit_holding/proc/get_ghost(mob/user)
	var/atom/thing = parent
	if(attempting_awakening)
		thing.balloon_alert(user, "already channeling!")
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		thing.balloon_alert(user, "spirits are unwilling!")
		to_chat(user, span_warning("Anomalous otherworldly energies block you from awakening [parent]!"))
		return
	if(!allow_channeling && bound_spirit)
		to_chat(user, span_warning("Try as you might, the spirit within slumbers."))
		return
	attempting_awakening = TRUE
	thing.balloon_alert(user, "channeling...")
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
		question = "Do you want to play as [span_notice("Spirit of [span_danger("[user.real_name]'s")] blade")]?",
		check_jobban = ROLE_PAI,
		poll_time = 20 SECONDS,
		checked_target = thing,
		ignore_category = POLL_IGNORE_POSSESSED_BLADE,
		alert_pic = thing,
		role_name_text = "possessed blade",
		chat_text_border_icon = thing,
	)
	affix_spirit(user, chosen_one)

/// On conclusion of the ghost poll
/datum/component/spirit_holding/proc/affix_spirit(mob/awakener, mob/dead/observer/ghost)

	var/atom/thing = parent

	if(isnull(ghost))
		thing.balloon_alert(awakener, "silence...")
		attempting_awakening = FALSE
		return

	// Immediately unregister to prevent making a new spirit
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	if(QDELETED(parent)) //if the thing that we're conjuring a spirit in has been destroyed, don't create a spirit
		to_chat(ghost, span_userdanger("The new vessel for your spirit has been destroyed! You remain an unbound ghost."))
		return

	bind_the_soule(ghost, awakener)

	attempting_awakening = FALSE

	if(!allow_renaming)
		return
	// Now that all of the important things are in place for our spirit, it's time for them to choose their name.
	var/valid_input_name = custom_name(awakener)
	if(valid_input_name)
		bound_spirit.fully_replace_character_name(null, "The spirit of [valid_input_name]")

/datum/component/spirit_holding/proc/bind_the_soule(datum/mind/chosen_spirit, mob/awakener, name_override)
	bound_spirit = new(parent)
	chosen_spirit.transfer_to(bound_spirit)
	bound_spirit.fully_replace_character_name(null, "The spirit of [name_override ? name_override : parent]")
	bound_spirit.get_language_holder().omnitongue = TRUE //Grants omnitongue

	RegisterSignal(parent, COMSIG_ATOM_RELAYMOVE, PROC_REF(block_buckle_message))
	RegisterSignal(parent, COMSIG_BIBLE_SMACKED, PROC_REF(on_bible_smacked))

/**
 * custom_name : Simply sends a tgui input text box to the blade asking what name they want to be called, and retries it if the input is invalid.
 *
 * Arguments:
 * * awakener: user who interacted with the blade
 */
/datum/component/spirit_holding/proc/custom_name(mob/awakener)
	var/chosen_name = sanitize_name(tgui_input_text(bound_spirit, "What are you named?", "Spectral Nomenclature", max_length = MAX_NAME_LEN))
	if(!chosen_name) // with the way that sanitize_name works, it'll actually send the error message to the awakener as well.
		to_chat(awakener, span_warning("Your blade did not select a valid name! Please wait as they try again.")) // more verbose than what sanitize_name might pass in it's error message
		return custom_name(awakener)
	return chosen_name

///signal fired from a mob moving inside the parent
/datum/component/spirit_holding/proc/block_buckle_message(datum/source, mob/living/user, direction)
	SIGNAL_HANDLER
	return COMSIG_BLOCK_RELAYMOVE

/datum/component/spirit_holding/proc/on_bible_smacked(datum/source, mob/living/user, ...)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attempt_exorcism), user)

/**
 * attempt_exorcism: called from on_bible_smacked, takes time and if successful
 * resets the item to a pre-possessed state
 *
 * Arguments:
 * * exorcist: user who is attempting to remove the spirit
 */
/datum/component/spirit_holding/proc/attempt_exorcism(mob/exorcist)
	var/atom/movable/exorcised_movable = parent
	to_chat(exorcist, span_notice("You begin to exorcise [parent]..."))
	playsound(parent, 'sound/hallucinations/veryfar_noise.ogg',40,TRUE)
	if(!do_after(exorcist, 4 SECONDS, target = exorcised_movable))
		return
	playsound(parent, 'sound/effects/pray_chaplain.ogg',60,TRUE)
	UnregisterSignal(exorcised_movable, list(COMSIG_ATOM_RELAYMOVE, COMSIG_BIBLE_SMACKED))
	RegisterSignal(exorcised_movable, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	to_chat(bound_spirit, span_userdanger("You were exorcised!"))
	QDEL_NULL(bound_spirit)
	exorcised_movable.name = initial(exorcised_movable.name)
	exorcist.visible_message(span_notice("[exorcist] exorcises [exorcised_movable]!"), \
						span_notice("You successfully exorcise [exorcised_movable]!"))
	return COMSIG_END_BIBLE_CHAIN

///signal fired from parent being destroyed
/datum/component/spirit_holding/proc/on_destroy(datum/source)
	SIGNAL_HANDLER
	to_chat(bound_spirit, span_userdanger("You were destroyed!"))
	QDEL_NULL(bound_spirit)
