#define WHIM_INACTIVE	0
#define WHIM_SCANNING	1
#define WHIM_ACTIVE		2

#define WHIM_STILL_COOLING	-1

/datum/whim
	var/name = "Generic Whim"

	var/state = WHIM_INACTIVE

	//var/mob/living/owner
	var/mob/living/simple_animal/owner

	var/list/allowed_mobtypes

	var/atom/concerned_target

	var/priority = 1

	var/scan_every = 3

	var/ticks_since_activation

	var/ticks_to_frustrate = 15

	var/abandon_rescan_length = 5 SECONDS
	COOLDOWN_DECLARE(cooldown_abandon_rescan)

	var/scan_radius = 3

/datum/whim/proc/activate(atom/new_target)
	testing("[owner] activating [name]")
	state = WHIM_ACTIVE
	concerned_target = new_target
	owner.current_whim = src
	ticks_since_activation = 0
	return TRUE

/// Returns the targeted atom or TRUE if we're valid to kickoff, or FALSE if we're not
/datum/whim/proc/can_start()
	if(!COOLDOWN_FINISHED(src, cooldown_abandon_rescan))
		testing("[name] is on cooldown still")
		return FALSE
	return inner_can_start()

/// Returns the targeted atom or TRUE if we're valid to kickoff, or FALSE if we're not
/datum/whim/proc/inner_can_start()
	return TRUE

/// For whatever reason, we're no longer interested in hooping, so unset all the variables for it
/datum/whim/proc/abandon()
	if(owner)
		testing("[owner] abandoning [name]")
		owner.current_whim = null
	concerned_target = null
	state = WHIM_INACTIVE
	COOLDOWN_START(src, cooldown_abandon_rescan, abandon_rescan_length)

/datum/whim/proc/tick()
	ticks_since_activation++
	if(ticks_since_activation > ticks_to_frustrate)
		abandon()
		return FALSE
	return


