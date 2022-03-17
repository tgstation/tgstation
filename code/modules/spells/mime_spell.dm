/datum/component/mime_spell
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
