/datum/element/muffles_speech
	/// Item refs currently muffling each mob, keyed by the mob's ref.
	var/static/list/affected_refs

/datum/element/muffles_speech/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(dropped))

/datum/element/muffles_speech/Detach(obj/item/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	if(ismob(source.loc))
		dropped(source, source.loc)

/datum/element/muffles_speech/proc/equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(!(source.slot_flags & slot))
		return
	var/user_ref = REF(user)
	if(!LAZYACCESS(affected_refs, user_ref))
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(muzzle_talk))
		RegisterSignal(user, COMSIG_MOB_PRE_EMOTED, PROC_REF(emote_override))
		RegisterSignal(user, COMSIG_MOB_BEFORE_SPELL_CAST, PROC_REF(try_spellcast))
		RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_mob_deleted))
	LAZYORASSOCLIST(affected_refs, user_ref, REF(source))

/datum/element/muffles_speech/proc/dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	var/user_ref = REF(user)
	if(!LAZYACCESS(affected_refs, user_ref))
		return
	LAZYREMOVEASSOC(affected_refs, user_ref, REF(source))
	if(LAZYACCESS(affected_refs, user_ref))
		return
	UnregisterSignal(user, list(COMSIG_MOB_PRE_EMOTED, COMSIG_MOB_SAY, COMSIG_MOB_BEFORE_SPELL_CAST, COMSIG_QDELETING))

/datum/element/muffles_speech/proc/on_mob_deleted(mob/source)
	SIGNAL_HANDLER
	LAZYREMOVE(affected_refs, REF(source))

/datum/element/muffles_speech/proc/emote_override(mob/living/source, key, params, type_override, intentional, datum/emote/emote)
	SIGNAL_HANDLER
	if(!emote.hands_use_check && (emote.emote_type & EMOTE_AUDIBLE))
		source.audible_message("makes a [pick("strong ", "weak ", "")]noise.", audible_message_flags = EMOTE_MESSAGE|ALWAYS_SHOW_SELF_MESSAGE)
		return COMPONENT_CANT_EMOTE
	return NONE

/datum/element/muffles_speech/proc/muzzle_talk(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT(source, TRAIT_SIGN_LANG))
		return
	var/spoken_message = speech_args[SPEECH_MESSAGE]
	if(spoken_message)
		var/list/words = splittext(spoken_message, " ")
		var/static/regex/yell_regex = regex(@"!+$")
		var/yell_suffix = yell_regex.Find(spoken_message) ? yell_regex.match : ""
		spoken_message = ""

		for(var/ind = 1 to length(words))
			var/new_word = ""
			for(var/i = 1 to length(words[ind]) + rand(-1,1))
				new_word += "m"
			new_word += "f"
			words[ind] = yell_suffix ? uppertext(new_word) : new_word
		spoken_message = "[jointext(words, " ")][yell_suffix]"
	speech_args[SPEECH_MESSAGE] = spoken_message

/datum/element/muffles_speech/proc/try_spellcast(mob/living/source, datum/action/cooldown/spell/spell, ...)
	SIGNAL_HANDLER

	if(spell.invocation_type != INVOCATION_WHISPER && spell.invocation_type != INVOCATION_SHOUT)
		return NONE

	INVOKE_ASYNC(src, PROC_REF(fail_spellcast), source, spell)
	return SPELL_CANCEL_CAST

/datum/element/muffles_speech/proc/fail_spellcast(mob/living/source, datum/action/cooldown/spell/spell)
	spell.invocation(source)
	to_chat(source, span_warning("Your mouth covering is making it difficult to say the correct words to cast [spell]..."))
	if(source.click_intercept == spell)
		spell.unset_click_ability(source, refund_cooldown = TRUE)
	spell.StartCooldown(2 SECONDS)
