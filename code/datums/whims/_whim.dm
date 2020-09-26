/// The whim is instantiated and possibly scanning, but is not the owner's current whim
#define WHIM_INACTIVE	0
/// The whim is the owner's current whim, and driving control of them (assuming they aren't buckled/have a mind/whatever)
#define WHIM_ACTIVE		1

/**
  * Whims are datums that handle specialized AI behavior for when we want to do behaviors more complex than standing around doing nothing, but don't want to hardcode it in Life()
  *
  * Up to one whim at a time can be active in a simple_animal (their current_whim), and that behavior's [/datum/whim/proc/tick] will run each Life() tick that the mob isn't dead, restrained,
  * or inhabited by a player (mostly). Whims are expected to play nice with each other and not hog control: Since dormant whims have no easy way of overthrowing the currently running whim,
  * it's expected that a whim take control for up to ~30-60 seconds at once at most (mostly less than that), with a sizeable cooldown afterwards.
  *
  * There's no goal oriented planning or robust priority system for which whim will take over at a given time: Each whim is set to perform checks of the surrounding area for environmental factors that
  * would trigger the behavior (ex: a cat might scan for mice, and enter a mice hunting routine upon sighting one nearby). Some whims may have simple and inexpensive checks, like scanning the 8 adjacent
  * tiles for food items, which means they're fine to be run more often. Other whims may be more complex or search a much wider area, at which point it's better for that check to run less frequently to
  * lessen the burden. Basically, the system is chaotic and somewhat unpredictable in busy environments, so try and keep your whim behaviors clean and well defined, so that they function well-enough
  * alongside each other without stepping on each other's toes.
  */
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
	/// Some whims require the owner to "carry" an item with them for some time. This is a convenience var you can store it in
	var/obj/item/carried_cargo

	/// How many times this whim has ticked since it was first activated, for use with checking if we're too frustrated to continue
	var/ticks_since_activation
	/// How many ticks it takes without any intervention for us to give up and abandon this whim
	var/ticks_to_frustrate = 15
	/// How long after we abandon this whim (for any reason) before we can try activating it again
	var/abandon_rescan_length = 5 SECONDS
	/// The actual cooldown tracker
	COOLDOWN_DECLARE(cooldown_abandon_rescan)
	/// Not currently in use, would let you prioritize lower numbers over higher numbers for activation given multiple whims trying to scan the same tick
	var/priority = 1

	/// Most whims involve scanning the area around you for stuff. Use this for your most frequent scan, so we can tell how expensive this whim is per scan at a glance.
	var/scan_radius = 3
	/// We only check [/datum/whim/proc/can_start] every so many ticks. If your whim has a particularly expensive scan (large radius, lots of calcs, etc) you should scan less frequently.
	var/scan_every = 4

	/// i was dumb and made catnip make cats lay down to eat catfood, so i need this, will probably remove soon
	var/allow_resting = FALSE
	/// Whims automatically block [/mob/living/simple_animal/proc/handle_automated_action] and [/mob/living/simple_animal/proc/handle_automated_movement] when active, this lets you choose whether to block speech & emotes too
	var/blocks_auto_speech = FALSE

/// Sets up the connections between the owner and their live_whims and passive_whims lists and such
/datum/whim/New(mob/living/simple_animal/attaching_owner)
	if(allowed_mobtypes && !is_type_in_list(attaching_owner, allowed_mobtypes))
		qdel(src)
		return

	owner = attaching_owner
	if(scan_every)
		LAZYADD(owner.live_whims, src)
	else
		LAZYADD(owner.passive_whims, src)
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, .proc/owner_examined)

/**
  * Note that destroying a whim is different than abandoning it. Destroying it will prevent the mob from ever running the whim again unless it's manually re-added (see: catnip)
  *
  * If you need to cede control or want to block a given whim from activating for a certain time, write those controls into the [/datum/whim/proc/inner_can_start] or [/datum/whim/proc/tick].
  * Otherwise, [/datum/whim/proc/abandon] is what you need whenever you want to deactivate the behavior without outright deleting it
  */
/datum/whim/Destroy(force, ...)
	abandon()
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)
		LAZYREMOVE(owner.live_whims, src)
		LAZYREMOVE(owner.passive_whims, src)
	return ..()

/**
  * Set the mob's current_whim to this, giving us control of the mob. Forces any existing current_whim to abandon itself before we activate.
  *
  * Note that this proc should set up all of the instance vars you need to kick off once we get to tick(), and [/datum/whim/proc/abandon] should then unset all of those
  * instance vars when we're done running. Unless you have a good reason to be carrying over variables from activation to activation (like caching or long term memory),
  * you should make a habit of doing a full reset.
  */
/datum/whim/proc/activate(atom/new_target)
	testing("[owner] activating [name]")
	state = WHIM_ACTIVE
	concerned_target = new_target
	if(owner.current_whim)
		owner.current_whim.abandon()
	owner.current_whim = src
	ticks_since_activation = 0
	RegisterSignal(owner, COMSIG_MOB_DEATH, .proc/abandon)
	return TRUE

/**
  * The counterpart to [/datum/whim/proc/activate], this is what retires our whim from the mob's current_whim and allows the mob's own Life() or another whim to take control
  *
  * As mentioned in activate(), you should be resetting any instance variables you won't need in future iterations of this behavior, so that no loose ends are left behind.
  */
/datum/whim/proc/abandon()
	SHOULD_CALL_PARENT(TRUE)
	if(owner)
		testing("[owner] abandoning [name]")
		owner.current_whim = null
		UnregisterSignal(owner, COMSIG_MOB_DEATH)
		if(carried_cargo && owner && carried_cargo.loc == owner)
			owner.visible_message("<b>[owner]</b> drops [carried_cargo].")
			carried_cargo.forceMove(owner.drop_location())

	carried_cargo = null
	concerned_target = null
	state = WHIM_INACTIVE
	COOLDOWN_START(src, cooldown_abandon_rescan, abandon_rescan_length)

/**
  * Don't change this or overwrite it in child procs (unless you have a reason I guess). This performs standard scan freq and abandon cooldown checks, then passes the torch to [/datum/whim/proc/inner_can_start]
  *
  * Returning FALSE means that this whim didn't meet the requirements to activate, while returning a datum reference (or any truthy value) signals that we have the okay to take control.
  * That shouldn't matter to you for this proc, though, all you care about here is passing along what inner_can_start returns if we call it.
  */
/datum/whim/proc/can_start()
	if(owner.whim_scan_ticks % scan_every != 0) // passive whims with scan_every = 0 call activate directly, so no need to worry about divide by 0
		return FALSE
	testing("[owner] about to try starting [name]")
	if(!COOLDOWN_FINISHED(src, cooldown_abandon_rescan))
		testing("[name] is on cooldown still")
		return FALSE
	return inner_can_start()

/**
  * The individualized logic that controls whether a whim can activate once it's given the green light by [/datum/whim/proc/inner_can_start]
  *
  * Returning FALSE means that this whim didn't meet the requirements to activate, while returning a datum reference (or any truthy value) signals that we have the okay to take control. Note that whatever you
  * return will be passed as the [/datum/whim/var/concerned_target] in [/datum/whim/proc/activate], which is likely whatever initial target you'll be dealing with once we kick off
  */
/datum/whim/proc/inner_can_start()
	return TRUE

/**
  * The actual ticking behavior that drives the whim's behavior. This is nominally run every Life() tick, but certain conditions may interrupt a running whim like the mob being buckled or gaining a mind
  *
  * While your control being paused because someone tied Ian to a chair can be jarring, at least you won't have to write constant checks for seeing if your mob is alive and conscious and unrestricted.
  * If they made it to tick(), you can be sure they have bodily control, no player mind, and are alive. And, if there are any interruptions, you'll pick up where you left off once the conditions are clear again.
  * Unless you don't want an upper limit on how many ticks this whim can be running for, you should be sure to call the parent in any whims you write, since frustration is handled here.
  */
/datum/whim/proc/tick()
	ticks_since_activation++
	if(ticks_to_frustrate && (ticks_since_activation > ticks_to_frustrate))
		abandon()
		return FALSE
	return

/// In case you want to add on extra info to the owner's examine based on the state of the whim
/datum/whim/proc/owner_examined(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(state == WHIM_INACTIVE)
		return

	if(carried_cargo)
		examine_list += "<span class='notice'>[owner.p_they(TRUE)] [owner.p_are()] carrying [icon2html(carried_cargo, user)] \a [carried_cargo].</span>"
