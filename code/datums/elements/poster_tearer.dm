/// Allows mobs with this element attached to just simply tear down any poster they desire to.
/datum/element/poster_tearer
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The amount of time it takes to tear down a poster.
	var/tear_time
	/// Interaction key to use whilst tearing down a poster.
	var/interaction_key

/datum/element/poster_tearer/Attach(datum/target, tear_time = 2 SECONDS, interaction_key = null)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.tear_time = tear_time
	src.interaction_key = interaction_key

	RegisterSignals(target, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK), PROC_REF(on_attacked_poster))

/datum/element/poster_tearer/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK))

/// Try to tear up a poster on the wall
/datum/element/poster_tearer/proc/on_attacked_poster(mob/living/user, atom/target, proximity_flag)
	SIGNAL_HANDLER
	if(!istype(target, /obj/structure/sign/poster))
		return NONE // don't care we move on

	if(DOING_INTERACTION_WITH_TARGET(user, target) || (!isnull(interaction_key) && DOING_INTERACTION(user, interaction_key)))
		user.balloon_alert(target, "busy!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(tear_it_down), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Actually work on tearing down that poster
/datum/element/poster_tearer/proc/tear_it_down(mob/living/user, obj/structure/sign/poster/target)
	if(!target.check_tearability(user)) // this proc will handle user feedback
		return

	target.balloon_alert(user, "tearing down the poster...")
	if(!do_after(user, tear_time, target, interaction_key = interaction_key)) // just in case the user actually enjoys art
		return
	target.tear_poster(user)
