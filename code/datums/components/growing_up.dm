/**
 * growing up component; for baby animals. CUTE!!!
 *
 * Used by chicks! Could be used on carbons, but switching types kinda implies a fullheal with it, so be wise, mkay?
 */
/datum/component/growing_up
	///The type this animal turns into when all grown up!
	var/mob/living/grown_up_type
	///How many grow cycles have passed for the parent, if grow_cycles > grow_cycles_required then it will turn into grown_up_type
	var/grow_cycles_required
	///How many grow cycles have been gained over time. These tick up on a process by a certain amount
	var/grow_cycles = 0

/datum/component/growing_up/Initialize(grown_up_type, grow_cycles_required)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	src.grown_up_type = grown_up_type
	src.grow_cycles_required = grow_cycles_required
	if(living_parent.stat != DEAD)
		START_PROCESSING(SSdcs, src)

/datum/component/growing_up/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_LIVING_DEATH, .proc/on_death)
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, .proc/on_revive)

/datum/component/growing_up/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE))

///signal called on parent being examined
/datum/component/growing_up/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/grow_cycle_percentage = PERCENT(grow_cycles/grow_cycles_required)
	switch(grow_cycle_percentage)
		if(0 to 15)
			examine_list += span_notice("It seems like a newborn!")
		if(16 to 74)
			examine_list += span_notice("One day, it's going to be a [initial(grown_up_type.name)].")
		if(75 to 100)
			examine_list += span_notice("It's going to be a [initial(grown_up_type.name)] very soon!")

///signal called on parent being examined
/datum/component/growing_up/proc/on_death(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSdcs, src)

///signal called on parent being revived
/datum/component/growing_up/proc/on_revive(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	START_PROCESSING(SSdcs, src)

/datum/component/growing_up/process(delta_time = SSDCS_DT)
	grow_cycles += rand(0.5 * delta_time, 1 * delta_time)
	if(grow_cycles < grow_cycles_required)
		return
	var/mob/living/living_parent = parent
	new grown_up_type(living_parent.loc)
	qdel(living_parent)
