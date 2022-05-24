/datum/action/cooldown/spell/voice_of_god
	name = "Voice of God"
	desc = "Speak with an incredibly compelling voice, forcing listeners to obey your commands."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "voice_of_god"
	sound = 'sound/magic/clockwork/invoke_general.ogg'

	cooldown_time = 120 SECONDS // Varies depending on command
	invocation = "" // Handled by the VOICE OF GOD itself
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = NONE

	/// The command to deliver on cast
	var/command
	/// The modifier to the cooldown, after cast
	var/cooldown_mod = 1
	/// The modifier put onto the power of the command
	var/power_mod = 1
	/// A list of spans to apply to commands given
	var/list/spans = list("colossus", "yell")

/datum/action/cooldown/spell/voice_of_god/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	command = tgui_input_text(cast_on, "Speak with the Voice of God", "Command")
	if(QDELETED(src) || QDELETED(cast_on) || !can_cast_spell())
		return . | SPELL_CANCEL_CAST
	if(!command)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/voice_of_god/cast(atom/cast_on)
	. = ..()
	var/command_cooldown = voice_of_god(uppertext(command), cast_on, spans, base_multiplier = power_mod)
	cooldown_time = (command_cooldown * cooldown_mod)

// "Invocation" is done by the actual voice of god proc
/datum/action/cooldown/spell/voice_of_god/invocation()
	return

/datum/action/cooldown/spell/voice_of_god/clown
	name = "Voice of Clown"
	desc = "Speak with an incredibly funny voice, startling people into obeying you for a brief moment."
	sound = 'sound/misc/scary_horn.ogg'
	cooldown_mod = 0.5
	power_mod = 0.1
	spans = list("clown")
