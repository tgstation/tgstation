/**
 * ## Charge Spell Component
 *
 * Attached to a spell to make it require the user be miming to cast.
 */
/datum/component/mime_spell
	/// Callback invoked whenever the invocation is checked.
	/// Sets the invocation message emote for the spell to whatever is returned from the callback.
	var/datum/callback/invocation_content_callback

/datum/component/mime_spell/Initialize(datum/callback/invocation_content_callback)
	if(!istype(parent, /datum/action/cooldown/spell))
		return COMPONENT_INCOMPATIBLE

	if(!invocation_content_callback)
		CRASH("[type] was created without an invocation content callback, meaning the spell will have no visible message.")

	src.invocation_content_callback = invocation_content_callback

/datum/component/mime_spell/Destroy(force, silent)
	QDEL_NULL(invocation_content_callback)
	return ..()

/datum/component/mime_spell/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SPELL_CAN_INVOKE, .proc/on_invoke_check)

/datum/component/mime_spell/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_SPELL_CAN_INVOKE)

/**
 * Signal proc for [COMSIG_SPELL_CAN_INVOKE]
 *
 * Checks that the user is miming before they invoke the spell.
 * If they are not miming, stop the invocation -
 * otherwise set the invocation type to emote and
 * invocation message to whatever is returned from the callback.
 */
/datum/component/mime_spell/proc/on_invoke_check(datum/source)
	SIGNAL_HANDLER

	var/datum/action/cooldown/spell/spell = source

	if(spell.owner.mind)
		if(!spell.owner.mind.miming)
			to_chat(spell.owner, span_warning("You must dedicate yourself to silence first!"))
			return COMPONENT_CANCEL_INVOKE

		spell.invocation_type = INVOCATION_EMOTE
		spell.invocation = invocation_content_callback.Invoke(spell.owner)

	else
		spell.invocation_type = INVOCATION_NONE
