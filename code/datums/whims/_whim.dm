/// The whim is instantiated and possibly scanning, but is not the owner's current whim
#define WHIM_INACTIVE	0
/// The whim is the owner's current whim, and driving control of them (assuming they aren't buckled/have a mind/whatever)
#define WHIM_ACTIVE		1


/datum/whim
	var/name = "Generic Whim"

	/// Whether this is currently the owner's current whim and running its ticks. See the above defines.
	var/state = WHIM_INACTIVE

	/// The simple animal whose behavior this whim is tied to
	var/mob/living/simple_animal/owner
	/// Unused currently, will allow you to prevent whims from running if the owner's type is not included here
	var/list/allowed_mobtypes
	/// Most whims are based around some kind of atom the owner moves or interacts with (like the mouse a cat is hunting). This should refer to their primary target.
	var/atom/concerned_target
	/// How many times this whim has ticked since it was first activated, for use with checking if we're too frustrated to continue
	var/ticks_since_activation
	/// How many ticks it takes without any intervention for us to give up and abandon this whim
	var/ticks_to_frustrate = 15
	/// How long after we abandon this whim (for any reason) before we can try activating it again
	var/abandon_rescan_length = 5 SECONDS
	/// The actual cooldown tracker
	COOLDOWN_DECLARE(cooldown_abandon_rescan)
	/// Not currently in use, would let you prioritize lower numbers over higher numbers for activation
	var/priority = 1

	/// Most whims involve scanning the area around you for stuff. Use this for your most frequent scan, so we can tell how expensive this whim is per scan at a glance.
	var/scan_radius = 3
	/// We only check [/datum/whim/proc/can_start] every so many ticks. If your whim has a particularly expensive scan (large radius, lots of calcs, etc) you should scan less frequently.
	var/scan_every = 3


	var/allow_resting = FALSE

/datum/whim/proc/activate(atom/new_target)
	testing("[owner] activating [name]")
	state = WHIM_ACTIVE
	concerned_target = new_target
	owner.current_whim = src
	ticks_since_activation = 0
	return TRUE

/// Returns the targeted atom or TRUE if we're valid to kickoff, or FALSE if we're not
/datum/whim/proc/can_start()
	if(owner.whim_scan_ticks % scan_every != 0)
		return FALSE
	testing("[owner] about to try starting [name]")
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


