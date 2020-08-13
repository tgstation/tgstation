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

	///This is the radius we look for cats to entice each scan
	var/catscan_range = 6
	///How long we wait to scan for the cats
	var/catscan_delay = 5 SECONDS
	///Every catscan, we run prob(this) to see if we should check a much larger radius (x3) for cats
	var/catscan_horde_chance = 0

	///Which cats are currently following us, as a lazylist
	var/list/enticed_cats
	///Cooldown for how long we're waiting to entice cats
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
/datum/component/catnip/proc/register_cat(mob/living/simple_animal/pet/cat/new_cat)
	if(!istype(new_cat) || (new_cat in enticed_cats))
		return
	LAZYADD(enticed_cats, new_cat)
	new_cat.current_catnip = parent
	COOLDOWN_START(new_cat, munchy_frustration, 1 MINUTES)
	RegisterSignal(new_cat, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), .proc/lose_cat)

///A cat is no longer interested in us (or maybe we no longer exist!), so unhook the cat
/datum/component/catnip/proc/lose_cat(mob/living/simple_animal/pet/cat/bye_cat)
	UnregisterSignal(bye_cat, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))
	LAZYREMOVE(enticed_cats, bye_cat) // do this before the typecheck just in case it's not a cat anymore
	if(!istype(bye_cat))
		return
	bye_cat.current_catnip = null

/datum/component/catnip/process()
	if(!COOLDOWN_FINISHED(src, catscan_cooldown))
		return
	COOLDOWN_START(src, catscan_cooldown, catscan_delay)

	var/list/scannables
	if(prob(catscan_horde_chance))
		scannables = range(catscan_range * CATSCAN_HORDE_MULT, get_turf(parent)) //horde scans don't care about visibility, so range instead of hearers
	else
		scannables = hearers(catscan_range, get_turf(parent))

	var/mob/living/simple_animal/pet/cat/itercat
	for(itercat in scannables)
		if(!(itercat in enticed_cats) && COOLDOWN_FINISHED(itercat, munchy_break) && !itercat.stat)
			register_cat(itercat)

	for(itercat in enticed_cats)
		if(itercat.stat || itercat.current_catnip != parent || get_dist(itercat, get_turf(parent)) > CATNIP_MAX_DISTANCE)
			lose_cat(itercat)

#undef CATSCAN_HORDE_MULT
#undef CATNIP_MAX_DISTANCE
