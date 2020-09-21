/**
  * catnip.dm- for when you want something to attract lots of cats
  *
  * When applied to an atom, this component will make any of the specified mobtypes nearby obsessed with said atom and anything holding it. If it's being held by something like a person or a container, the cats will follow after the holder
  * meowing incessantly at it as hungry cats tend to do. If the parent is on the ground (well, a turf), the cats will congregate around it, and if the parent is a snack object, they'll begin feasting on it.
  *
  * Obviously this was all written up with literal cats and catnip in mind, but this can all apply to other simple_animals as well if you take the mentions of cats and catnip less literally. All of the code here is written
  * for simple_animals, the only functional part of the component that explicitly assumes cats is the mob behavior with the meowing and pawing and eating, which can be worked around and made more modular if you wanted, say,
  * a flute that attracts mice. I leave modularizing those specifics to whoever wants to add such a use though, cause you'd know better than me what behavior you want.
  */

///Don't bother if the cat is this far away, just drop them
#define CATNIP_MAX_DISTANCE	20

/datum/component/catnip
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// This is the radius we look for cats to entice each scan
	var/catscan_range = 6
	/// How long we wait to scan for the cats
	var/catscan_delay = 5 SECONDS

	/// Which cats are currently following us, as a lazylist
	var/list/enticed_cats
	/// Despite all the focus on cats in the descriptions and docs, this can affect any listed simple_animals (though you'll need to write their own behavior unless you want a meowing carp). This currently isn't in use.
	var/list/enticed_mobtypes
	/// Cooldown for how long we're waiting to entice cats
	COOLDOWN_DECLARE(catscan_cooldown)

/datum/component/catnip/Initialize(scan_range = 6, scan_interval = 5 SECONDS, duration = 0)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSdcs, src)
	catscan_range = scan_range
	catscan_delay = scan_interval
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

	var/datum/whim/catnip/new_catnip_whim = new(new_cat) // the actual mob behavior of making them go nuts is handled in the catnip whim datum
	new_catnip_whim.referring_source = parent // since the whim datum can't call an area scan for things with compatible catnip components, we just give them a line to this

	LAZYADD(enticed_cats, new_cat)
	RegisterSignal(new_cat, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), .proc/lose_cat)

///A cat is no longer interested in us (or maybe we no longer exist!), so unhook them
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

	for(var/i in hearers(catscan_range, get_turf(parent)))
		var/mob/living/simple_animal/itercat = i
		if(istype(itercat) && !(itercat in enticed_cats) && !(locate(/datum/whim/catnip) in itercat.live_whims) && !itercat.stat)
			register_cat(itercat)

	for(var/i in enticed_cats)
		var/mob/living/simple_animal/itercat = i
		if(!istype(itercat) || itercat.stat || !(locate(/datum/whim/catnip) in itercat.live_whims) || get_dist(itercat, get_turf(parent)) > CATNIP_MAX_DISTANCE)
			lose_cat(itercat)

#undef CATNIP_MAX_DISTANCE
