/datum/religion_rites/dream_projection
	name = "Dream Projection"
	desc = "Astrally project your dream consciousness into the mind of one of your followers. \
		While projecting, you are asleep, and can communicate with only and see through the eyes of the chosen follower, \
		but cannot interact with the world in any way. The projection can be ended at any time, \
			ends if you are woken up or attacked, and ends if the follower dies."
	favor_cost = 100
	ritual_length = 15 SECONDS

/datum/religion_rites/dream_projection/New()
	. = ..()
	ritual_invocations = list(
		"A member of the flock has gone astray, lost in the waking world...",
		"It is the duty of the shepard to guide them back to the fold, even if they cannot find their way themselves...",
		"Let me walk through their waking dream, and show them the way back...",
	)

/datum/religion_rites/dream_projection/perform_rite(mob/living/user, atom/religious_tool)
	var/list/followers = list()
	for(var/mob/living/follower as anything in GLOB.mob_living_list)
		if(follower.mind?.holy_role && user != follower)
			followers += follower

	if(!length(followers))
		to_chat(user, span_warning("You have no followers to project into!"))
		return FALSE

	return ..()

/datum/religion_rites/dream_projection/post_invoke_effects(mob/living/user, atom/religious_tool)
	. = ..()
	var/list/followers = list()
	for(var/mob/living/follower as anything in GLOB.mob_living_list)
		if(follower.mind?.holy_role && user != follower)
			followers += follower

	if(!length(followers))
		refund(0.8)
		return

	var/mob/living/carbon/human/target = tgui_input_list(user, "Choose a follower to project into:", "Dream Projection", followers)
	if(QDELETED(target) || target.stat == DEAD || isnull(target.mind?.holy_role))
		refund(0.8)
		return

	if(!user.apply_status_effect(/datum/status_effect/dream_projection, target))
		to_chat(user, span_warning("You fail to fall asleep."))
		refund(0.8)
		return

/datum/status_effect/dream_projection
	id = "dream_projection"
	duration = STATUS_EFFECT_PERMANENT
	alert_type = null
	on_remove_on_mob_delete = TRUE

	/// Target of the projection
	VAR_PRIVATE/mob/living/carbon/human/target
	/// Projection mob that the owner is put into
	VAR_PRIVATE/mob/eye/imaginary_friend/dream_projection/projection

/datum/status_effect/dream_projection/on_creation(mob/living/new_owner, mob/living/carbon/human/target)
	if(isnull(target))
		stack_trace("Dream projection created without a target!")
		qdel(src)
		return

	src.target = target
	return ..()

/datum/status_effect/dream_projection/get_examine_text()
	return "[owner.p_They()] are in a deep slumber, yet [owner.p_their()] eyes show a distant look, as if [owner.p_they()] are somewhere far away..."

/datum/status_effect/dream_projection/on_apply()
	for(var/obj/item/book/bible/bible in owner.held_items)
		ADD_TRAIT(bible, TRAIT_NODROP, id)

	if(!owner.SetSleeping(20 SECONDS))
		to_chat(owner, span_warning("You fail to fall asleep."))
		for(var/obj/item/book/bible/bible in owner.held_items)
			REMOVE_TRAIT(bible, TRAIT_NODROP, id)
		return FALSE

	. = ..()
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(end_projection))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(end_projection))

	ADD_TRAIT(owner, TRAIT_DREAMING, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(interrupt_projection))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(interrupt_projection))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(interrupt_projection))

	projection = new(target.loc)
	projection.AddComponent(/datum/component/temporary_body, old_mind = owner.mind)
	projection.real_name = owner.real_name
	projection.gender = owner.gender
	projection.human_icon = getFlatIcon(owner)
	projection.PossessByPlayer(owner.ckey)
	projection.attach_to_owner(target)

	RegisterSignal(projection, COMSIG_QDELETING, PROC_REF(stop_projection))

	owner.add_filter(id, 1, outline_filter(color = "#aee2b2"))
	var/filter = owner.get_filter(id)
	animate(filter, size = 2, 2 SECONDS, easing = SINE_EASING|EASE_IN, loop = -1)
	animate(size = 0, 2 SECONDS, easing = SINE_EASING|EASE_OUT, loop = -1)

/datum/status_effect/dream_projection/on_remove()
	. = ..()
	UnregisterSignal(target, COMSIG_QDELETING)
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	target = null

	REMOVE_TRAIT(owner, TRAIT_DREAMING, TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT))
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	owner.adjust_drowsiness(10 SECONDS)
	for(var/obj/item/book/bible/bible in owner.held_items)
		REMOVE_TRAIT(bible, TRAIT_NODROP, id)

	UnregisterSignal(projection, COMSIG_QDELETING)
	if(QDELING(projection))
		projection = null
	else
		QDEL_NULL(projection)

/datum/status_effect/dream_projection/tick(seconds_between_ticks)
	if(isnull(owner.mind?.holy_role))
		end_projection()
		return

	owner.SetSleeping(20 SECONDS) // keep the owner asleep

/datum/status_effect/dream_projection/proc/end_projection()
	SIGNAL_HANDLER
	to_chat(owner, span_warning("Your dream projection ends as your target is no longer valid."))
	owner.SetSleeping(10 SECONDS)
	qdel(src)

/datum/status_effect/dream_projection/proc/interrupt_projection()
	SIGNAL_HANDLER
	to_chat(owner, span_warning("Your dream projection is interrupted!"))
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "gasp")
	owner.visible_message(span_notice("[owner]'s eyes snap open as they are jolted awake!"), vision_distance = COMBAT_MESSAGE_RANGE, ignored_mobs = owner)
	qdel(src)

/datum/status_effect/dream_projection/proc/stop_projection()
	SIGNAL_HANDLER
	to_chat(owner, span_warning("You end your dream projection and return to your body."))
	owner.SetSleeping(10 SECONDS)
	qdel(src)

/mob/eye/imaginary_friend/dream_projection
	name = "dream projection"

/mob/eye/imaginary_friend/dream_projection/Initialize(mapload)
	. = ..()
	var/datum/action/innate/stop_projection/exit_action = new(src)
	exit_action.Grant(src)
	overlay_fullscreen("curse", /atom/movable/screen/fullscreen/curse, 1) // todo

/mob/eye/imaginary_friend/dream_projection/Login()
	. = ..()
	client.eye = owner || src

/mob/eye/imaginary_friend/dream_projection/greet()
	return

/mob/eye/imaginary_friend/dream_projection/verb/stop_projection()
	set category = "IC"
	set name = "Stop Projection"
	set desc = "Stop astrally projecting and return to your body."

	qdel(src)

/mob/eye/imaginary_friend/dream_projection/attach_to_owner(mob/living/imaginary_friend_owner)
	. = ..()
	client?.eye = owner

/datum/action/innate/stop_projection
	name = "Stop Projection"
	desc = "Stop astrally projecting and return to your body."

/datum/action/innate/stop_projection/Activate()
	qdel(owner)
