/datum/component/manual_blinking
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/obj/item/organ/eyes/parent_eyes
	var/warn_grace = FALSE
	var/warn_dying = FALSE
	var/last_blink
	/// How long can you not blink before you get a warning?
	var/warning_delay = 20 SECONDS
	/// Delay between getting a warning and you starting to take eye damage
	var/grace_period = 6 SECONDS
	/// Organ damage taken per tick
	var/damage_rate = 1
	/// How much saline needs to be dropper at once for it to count as "blinking"
	var/min_saline = 1
	/// Do we display a message when adding/removing the component
	var/display_message = TRUE
	var/list/valid_emotes = list(/datum/emote/living/carbon/human/blink, /datum/emote/living/carbon/human/blink_r)

/datum/component/manual_blinking/Initialize(damage_rate = 1, warning_delay = 20 SECONDS, grace_period = 6 SECONDS, display_message = TRUE)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	src.damage_rate = damage_rate
	src.warning_delay = warning_delay
	src.grace_period = grace_period
	src.display_message = display_message

	var/mob/living/carbon/carbon_parent = parent
	ADD_TRAIT(carbon_parent, TRAIT_PREVENT_BLINK_LOOPS, REF(src))
	carbon_parent.update_body()
	parent_eyes = carbon_parent.get_organ_slot(ORGAN_SLOT_EYES)

	if(!parent_eyes || IS_ROBOTIC_ORGAN(parent_eyes))
		return

	START_PROCESSING(SSdcs, src)
	last_blink = world.time
	if (display_message)
		to_chat(carbon_parent, span_notice("You suddenly realize you're blinking manually."))

/datum/component/manual_blinking/Destroy(force)
	REMOVE_TRAIT(parent, TRAIT_PREVENT_BLINK_LOOPS, REF(src))
	parent_eyes = null
	STOP_PROCESSING(SSdcs, src)
	if (display_message)
		to_chat(parent, span_notice("You revert back to automatic blinking."))
	var/mob/living/carbon/carbon_parent = parent
	carbon_parent.cure_blind(REF(src))
	carbon_parent.update_body()
	return ..()

/datum/component/manual_blinking/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_EMOTE, PROC_REF(check_emote))
	RegisterSignal(parent, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(check_added_organ))
	RegisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(check_removed_organ))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(restart))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(pause))
	RegisterSignal(parent, COMSIG_MOB_REAGENTS_DROPPED_INTO_EYES, PROC_REF(on_dropper))

/datum/component/manual_blinking/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_EMOTE, COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN, COMSIG_LIVING_REVIVE, COMSIG_LIVING_DEATH, COMSIG_MOB_REAGENTS_DROPPED_INTO_EYES))

/datum/component/manual_blinking/proc/restart()
	SIGNAL_HANDLER

	START_PROCESSING(SSdcs, src)

/datum/component/manual_blinking/proc/pause()
	SIGNAL_HANDLER

	STOP_PROCESSING(SSdcs, src)

/datum/component/manual_blinking/process()
	if(world.time > (last_blink + warning_delay + grace_period))
		if(!warn_dying)
			to_chat(parent, span_userdanger("Your eyes begin to wither, you need to blink!"))
			warn_dying = TRUE
		parent_eyes.apply_organ_damage(damage_rate)
	else if(world.time > (last_blink + warning_delay))
		if(!warn_grace)
			to_chat(parent, span_danger("You feel a need to blink!"))
			warn_grace = TRUE

/datum/component/manual_blinking/proc/check_added_organ(mob/who_cares, obj/item/organ/added_organ)
	SIGNAL_HANDLER

	if(istype(added_organ, /obj/item/organ/eyes))
		parent_eyes = added_organ
		if (IS_ROBOTIC_ORGAN(parent_eyes))
			parent_eyes = null
			return
		last_blink = world.time
		START_PROCESSING(SSdcs, src)

/datum/component/manual_blinking/proc/check_removed_organ(mob/who_cares, obj/item/organ/removed_organ)
	SIGNAL_HANDLER

	if(removed_organ == parent_eyes)
		parent_eyes = null
		STOP_PROCESSING(SSdcs, src)

/datum/component/manual_blinking/proc/check_emote(mob/living/carbon/user, datum/emote/emote)
	SIGNAL_HANDLER

	if(!(emote.type in valid_emotes))
		return

	warn_grace = FALSE
	warn_dying = FALSE
	last_blink = world.time
	user.become_blind(REF(src))
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, remove_status_effect), /datum/status_effect/grouped/blindness, REF(src)), 0.15 SECONDS)

/datum/component/manual_blinking/proc/on_dropper(datum/source, mob/living/user, atom/dropper, datum/reagents/reagents, fraction)
	SIGNAL_HANDLER

	var/saline_amount = reagents.get_reagent_amount(/datum/reagent/medicine/salglu_solution) * fraction
	if (saline_amount >= min_saline)
		warn_grace = FALSE
		warn_dying = FALSE
		last_blink = world.time
