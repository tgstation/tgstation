/**
  * catnip.dm- for when you want something to attract lots of cats
  *
  * When applied to an atom, this component will make any cats nearby obsessed with said atom and anything holding it. If it's being held by something like a person or a container, the cats will follow after the holder
  * meowing incessantly at it as hungry cats tend to do. If the parent is on the ground (well, a turf), the cats will congregate around it, and if the parent is a snack object, they'll begin feasting on it.
  */

///If a catscan hits prob(catscan_horde_chance), we ignore visibility and multiply the scan range by this. Set to x3 both because it's a reasonable size boost, and also cause x3 looks like a cat face :3c
#define CATSCAN_HORDE_MULT	3
///Don't bother if the cat is this far away, just drop them
#define CATNIP_MAX_DISTANCE	20

/datum/component/catnip
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// This is the radius we look for cats to entice each scan
	var/catscan_range = 6
	/// How long we wait to scan for the cats
	var/catscan_delay = 5 SECONDS
	/// Every catscan, we run prob(this) to see if we should check a much larger radius (x3) for cats
	var/catscan_horde_chance = 0

	/// Which cats are currently following us, as a lazylist
	var/list/enticed_cats
	/// Despite all the focus on cats in the descriptions and docs, this can affect any listed simple_mobs (though you'll need to write their own behavior unless you want a meowing carp)
	var/list/enticed_mobtypes
	/// Cooldown for how long we're waiting to entice cats
	COOLDOWN_DECLARE(catscan_cooldown)

/datum/component/catnip/Initialize(scan_range = 6, scan_interval = 5 SECONDS, horde_chance = 0, duration = 0)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSdcs, src)
	catscan_range = scan_range
	catscan_delay = scan_interval
	catscan_horde_chance = horde_chance
	if(duration)
		QDEL_IN(src, duration)

/datum/component/catnip/Destroy(force, silent)
	for(var/i in enticed_cats)
		lose_cat(i)
	LAZYCLEARLIST(enticed_cats)
	return ..()

///We're adding a new cat to our harem, hook em up
/datum/component/catnip/proc/register_cat(mob/living/simple_animal/new_cat)
	if(!istype(new_cat) || (new_cat in enticed_cats))
		return

	var/datum/whim/catnip/new_catnip_whim = new(new_cat)
	new_catnip_whim.referring_source = parent

	LAZYADD(enticed_cats, new_cat)
	RegisterSignal(new_cat, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), .proc/lose_cat)

///A cat is no longer interested in us (or maybe we no longer exist!), so unhook the cat
/datum/component/catnip/proc/lose_cat(mob/living/simple_animal/bye_cat)
	UnregisterSignal(bye_cat, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))
	LAZYREMOVE(enticed_cats, bye_cat) // do this before the typecheck just in case it's not a cat anymore
	if(!istype(bye_cat))
		return

	var/removable_whim = (locate(/datum/whim/catnip) in bye_cat.live_whims)
	if(removable_whim)
		qdel(removable_whim)

/datum/component/catnip/process()
	if(!COOLDOWN_FINISHED(src, catscan_cooldown))
		return
	COOLDOWN_START(src, catscan_cooldown, catscan_delay)

	var/list/scannables
	if(prob(catscan_horde_chance))
		scannables = range(catscan_range * CATSCAN_HORDE_MULT, get_turf(parent)) //horde scans don't care about visibility, so range instead of hearers
	else
		scannables = hearers(catscan_range, get_turf(parent))

	for(var/i in scannables)
		var/mob/living/simple_animal/itercat = i
		if(istype(itercat) && !(itercat in enticed_cats) && !(locate(/datum/whim/catnip) in itercat.live_whims) && !itercat.stat)
			register_cat(itercat)

	for(var/i in enticed_cats)
		var/mob/living/simple_animal/itercat = i
		if(!istype(itercat) || itercat.stat || !(locate(/datum/whim/catnip) in itercat.live_whims) || get_dist(itercat, get_turf(parent)) > CATNIP_MAX_DISTANCE)
			lose_cat(itercat)

#undef CATSCAN_HORDE_MULT
#undef CATNIP_MAX_DISTANCE
