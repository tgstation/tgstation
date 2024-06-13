/*
 * Simple component for something that is able to destroy
 * certain effects (such as cult runes) in one attack.
 */
/datum/component/effect_remover
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Line sent to the user on successful removal.
	var/success_feedback
	/// Line forcesaid by the user on successful removal.
	var/success_forcesay
	/// The text used in the screentip when our parent is hovering over an item we can clear. Ex "Destroy rune"
	var/tip_text
	/// Callback invoked with removal is done.
	var/datum/callback/on_clear_callback
	/// A typecache of all effects we can clear with our item.
	var/list/obj/effect/effects_we_clear
	/// If above 0, how long it takes while standing still to remove the effect.
	var/time_to_remove = 0 SECONDS

/datum/component/effect_remover/Initialize(
	success_forcesay,
	success_feedback,
	tip_text,
	on_clear_callback,
	effects_we_clear,
	time_to_remove,
	)

	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!effects_we_clear)
		stack_trace("[type] was instantiated without any valid removable effects!")
		return COMPONENT_INCOMPATIBLE

	src.success_feedback = success_feedback
	src.success_forcesay = success_forcesay
	src.tip_text = tip_text
	src.on_clear_callback = on_clear_callback
	src.effects_we_clear = typecacheof(effects_we_clear)
	src.time_to_remove = time_to_remove

/datum/component/effect_remover/Destroy(force, silent)
	on_clear_callback = null
	return ..()

/datum/component/effect_remover/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_EFFECT, PROC_REF(try_remove_effect))

	if(tip_text)
		var/obj/item/item_parent = parent
		item_parent.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS
		RegisterSignal(parent, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))

/datum/component/effect_remover/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_EFFECT, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET))

/*
 * Signal proc for [COMSIG_ITEM_ATTACK_EFFECT].
 */
/datum/component/effect_remover/proc/try_remove_effect(datum/source, obj/effect/target, mob/living/user, params)
	SIGNAL_HANDLER

	if(!isliving(user))
		return

	if(effects_we_clear[target.type]) // Make sure we get all subtypes and everything
		INVOKE_ASYNC(src, PROC_REF(do_remove_effect), target, user)
		return COMPONENT_NO_AFTERATTACK

/*
 * Actually removes the effect, invoking our on_clear_callback before it's deleted.
 */
/datum/component/effect_remover/proc/do_remove_effect(obj/effect/target, mob/living/user)
	if(time_to_remove && !do_after(user, time_to_remove, target))
		return

	var/obj/item/item_parent = parent
	if(success_forcesay)
		user.say(success_forcesay, forced = item_parent.name)
	if(success_feedback)
		var/real_feedback = replacetext(success_feedback, "%THEEFFECT", "\the [target]")
		real_feedback = replacetext(real_feedback, "%THEWEAPON", "\the [item_parent]")
		to_chat(user, span_notice(real_feedback))
	on_clear_callback?.Invoke(target, user)

	if(!QDELETED(target))
		qdel(target)

/*
 * Signal proc for [COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET].
 *
 * Adds some context for the target, if we have one set and it's a valid target.
 */
/datum/component/effect_remover/proc/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	SIGNAL_HANDLER

	if(effects_we_clear[target.type])
		context[SCREENTIP_CONTEXT_LMB] = tip_text
		return CONTEXTUAL_SCREENTIP_SET

	return NONE
