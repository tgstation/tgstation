/**
 * ## Mime Spell Element
 *
 * Attached to a spell to make it require the user be miming to cast.
 * Mindless mobs get a free pass, and are able to cast the spell regardless.
 */
/datum/element/mime_spell

/datum/element/mime_spell/Attach(datum/target)
	. = ..()
	if(!istype(target, /datum/action/cooldown/spell))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_SPELL_CAN_INVOKE, .proc/on_invoke_check)

/datum/element/mime_spell/Detach(datum/target)
	UnregisterSignal(target, COMSIG_SPELL_CAN_INVOKE)
	return ..()

/**
 * Signal proc for [COMSIG_SPELL_CAN_INVOKE]
 *
 * Checks that the user is miming before they invoke the spell.
 * If they are not miming, stop the invocation -
 * otherwise set the invocation type to emote and
 * invocation message to whatever is returned from the callback.
 */
/datum/element/mime_spell/proc/on_invoke_check(datum/source, feedback)
	SIGNAL_HANDLER

	var/datum/action/cooldown/spell/spell = source

	if(spell.owner.mind)
		if(!spell.owner.mind.miming)
			if(feedback)
				to_chat(spell.owner, span_warning("You must dedicate yourself to silence first!"))
			return COMPONENT_CANCEL_INVOKE

		spell.invocation_type = INVOCATION_EMOTE

	else
		spell.invocation_type = INVOCATION_NONE
