/**
 * ### Sentience possible element!
 *
 * Makes a mob sentient when a sentience item is used on them and it's of the correct biotype
 */
/datum/element/sentience_possible
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///sentience for robots won't work on organic creatures. this biotype from the mob is checked with the sentience biotype
	var/biotypes

/datum/element/sentience_possible/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/living_target = target
	biotypes = living_target.mob_biotypes
	RegisterSignal(target, COMSIG_LIVING_SENTIENCEPOTION, PROC_REF(on_sentiencepotion))

/datum/element/sentience_possible/Detach(datum/target)
	if(target)
		UnregisterSignal(target, COMSIG_LIVING_SENTIENCEPOTION)
	return ..()

/datum/element/sentience_possible/proc/on_sentiencepotion(datum/target, obj/sentience_source, sentience_biotypes, mob/user, try_sentience)
	SIGNAL_HANDLER
	if(!(biotypes & sentience_biotypes))
		to_chat(user, span_warning("[sentience_source] won't work on [target]."))
		return
	INVOKE_ASYNC(try_sentience, user, target)
