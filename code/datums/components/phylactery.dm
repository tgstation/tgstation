/**
 * ## Phylactery component
 *
 * Used for lichtom to turn (almost) any object into a phylactery
 * A mob linked to a phylactery will repeatedly revive on death.
 */
/datum/component/phylactery
	// Set in initialize.
	/// The mind of the lich who is linked to this phylactery.
	var/datum/mind/lich_mind
	/// The respawn timer of the phylactery.
	var/base_respawn_time = 3 MINUTES
	/// How much time is added on to the respawn time per revival.
	var/time_per_resurrection = 0
	/// How much stun (paralyze) is caused on respawn per revival.
	var/stun_per_resurrection = 20 SECONDS
	/// The color of the phylactery itself. Applied on creation.
	var/phylactery_color = COLOR_VERY_DARK_LIME_GREEN

	// Internal vars.
	/// The number of resurrections that have occurred from this phylactery.
	var/num_resurrections = 0
	/// A timerid to the current revival timer.
	var/revive_timer

/datum/component/phylactery/Initialize(
	datum/mind/lich_mind,
	base_respawn_time = 3 MINUTES,
	time_per_resurrection = 0 SECONDS,
	stun_per_resurrection = 20 SECONDS,
	phylactery_color = COLOR_VERY_DARK_LIME_GREEN,
)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	if(isnull(lich_mind))
		stack_trace("A [type] was created with no target lich mind!")
		return COMPONENT_INCOMPATIBLE

	src.lich_mind = lich_mind
	src.base_respawn_time = base_respawn_time
	src.time_per_resurrection = time_per_resurrection
	src.stun_per_resurrection = stun_per_resurrection
	src.phylactery_color = phylactery_color

	RegisterSignal(lich_mind, COMSIG_QDELETING, PROC_REF(on_lich_mind_lost))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(check_if_lich_died))

	var/obj/obj_parent = parent
	obj_parent.name = "ensouled [obj_parent.name]"
	obj_parent.add_atom_colour(phylactery_color, ADMIN_COLOUR_PRIORITY)
	obj_parent.AddComponent(/datum/component/stationloving, FALSE, TRUE)

	RegisterSignal(obj_parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	SSpoints_of_interest.make_point_of_interest(obj_parent)

/datum/component/phylactery/Destroy()
	var/obj/obj_parent = parent
	obj_parent.name = initial(obj_parent.name)
	obj_parent.remove_atom_colour(ADMIN_COLOUR_PRIORITY, phylactery_color)
	// Stationloving items should really never be made a phylactery so I feel safe in doing this
	qdel(obj_parent.GetComponent(/datum/component/stationloving))

	UnregisterSignal(obj_parent, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH)
	// Sweep up any revive signals left on the mind's current
	UnregisterSignal(lich_mind.current, COMSIG_LIVING_REVIVE)

	lich_mind = null
	return ..()

/**
 * Signal proc for [COMSIG_ATOM_EXAMINE].
 *
 * Gives some flavor for the phylactery on examine.
 */
/datum/component/phylactery/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(IS_WIZARD(user) || isobserver(user))
		if(user.mind == lich_mind)
			var/time_to_revive = base_respawn_time + (num_resurrections * time_per_resurrection)
			examine_list += span_green("Your phylactery. The next time you meet an untimely demise, \
				you will revive at this object in <b>[time_to_revive / 10 / 60] minute\s</b>.")
		else
			examine_list += span_green("A lich's phylactery. This one belongs to [lich_mind].")

		if(num_resurrections > 0)
			examine_list += span_green("<i>There's [num_resurrections] notches in the side of it.</i>")

	else
		examine_list += span_green("A terrible aura surrounds this item. Its very existence is offensive to life itself...")

/**
 * Signal proc for [COMSIG_QDELETING] registered on the lich's mind.
 *
 * Minds shouldn't be getting deleted but if for some ungodly reason
 * the lich'd mind is deleted our component should go with it, as
 * we don't have a reason to exist anymore.
 */
/datum/component/phylactery/proc/on_lich_mind_lost(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/**
 * Signal proc for [COMSIG_GLOB_MOB_DEATH].
 *
 * If the mob containing our lich's mind is killed,
 * we can initiate the revival process.
 *
 * We use the global mob death signal here,
 * instead of registering the normal death signal,
 * as it's entirely possible the wizard mindswaps
 * or is gibbed or something wacky happens, and
 * we need to make sure WHOEVER has our mind is dead
 */
/datum/component/phylactery/proc/check_if_lich_died(datum/source, mob/living/died, gibbed)
	SIGNAL_HANDLER

	if(!died.mind)
		return

	if(died.mind != lich_mind)
		return

	// If we aren't gibbed, we need to check if the lich is
	// revived at some point between returning
	if(!gibbed)
		RegisterSignal(died, COMSIG_LIVING_REVIVE, PROC_REF(stop_timer))

	// Start revival
	var/time_to_revive = base_respawn_time + (num_resurrections * time_per_resurrection)
	revive_timer = addtimer(CALLBACK(src, PROC_REF(revive_lich), died), time_to_revive, TIMER_UNIQUE|TIMER_STOPPABLE)
	to_chat(died, span_green("You feel your soul being dragged back to this world... \
		<b>you will revive at your phylactery in [time_to_revive / 10 / 60] minute\s.</b>"))

/**
 * Signal proc for [COMSIG_LIVING_REVIVE].
 *
 * If our lich's mob is revived at some point before returning, stop the timer
 */
/datum/component/phylactery/proc/stop_timer(mob/living/source, full_heal_flags)
	SIGNAL_HANDLER

	deltimer(revive_timer)
	revive_timer = null

	UnregisterSignal(source, COMSIG_LIVING_REVIVE)

/**
 * Actually undergo the process of reviving the lich at the site of the phylactery.
 *
 * Arguments
 * * corpse - optional, the old body of the lich. Can be QDELETED or null.
 */
/datum/component/phylactery/proc/revive_lich(mob/living/corpse)
	// If we have a current, and it's not dead, don't yoink their mind
	// But if we don't have a current (body destroyed) move on like normal
	if(lich_mind.current && lich_mind.current.stat != DEAD)
		CRASH("[type] - revive_lich was called when the lich's mind had a current mob that wasn't dead.")

	var/turf/parent_turf = get_turf(parent)
	if(!istype(parent_turf))
		CRASH("[type] - revive_lich was called when the phylactery was in an invalid location (nullspace?) (was in: [parent_turf]).")

	revive_timer = null
	var/mob/living/carbon/human/lich = new(parent_turf)
	ADD_TRAIT(lich, TRAIT_NO_SOUL, LICH_TRAIT)

	var/obj/item/organ/internal/brain/new_lich_brain = lich.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(new_lich_brain) // Prevent MMI cheese
		new_lich_brain.organ_flags &= ~ORGAN_VITAL
		new_lich_brain.decoy_override = TRUE

	// Give them some duds
	lich.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/magic(lich), ITEM_SLOT_FEET)
	lich.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(lich), ITEM_SLOT_ICLOTHING)
	lich.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(lich), ITEM_SLOT_OCLOTHING)
	lich.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(lich), ITEM_SLOT_HEAD)

	// Fix their name
	lich.dna.real_name = lich_mind.name
	lich.real_name = lich_mind.name
	// Slap the lich mind in and get their ghost
	lich_mind.transfer_to(lich)
	lich_mind.grab_ghost(force = TRUE)
	// Make sure they're a spooky skeleton, and their DNA is right
	lich.set_species(/datum/species/skeleton)
	lich.dna.generate_unique_enzymes()

	to_chat(lich, span_green("Your bones clatter and shudder as you are pulled back into this world!"))
	num_resurrections++
	lich.Paralyze(stun_per_resurrection * num_resurrections)

	if(!QDELETED(corpse))
		UnregisterSignal(corpse, COMSIG_LIVING_REVIVE)

		if(iscarbon(corpse))
			var/mob/living/carbon/carbon_body = corpse
			for(var/obj/item/organ/to_drop as anything in carbon_body.organs)
				// Skip the brain - it can disappear, we don't need it anymore
				if(istype(to_drop, /obj/item/organ/internal/brain))
					continue

				// For the rest, drop all the organs onto the floor (for style)
				to_drop.Remove(carbon_body)
				to_drop.forceMove(corpse.drop_location())

		var/turf/body_turf = get_turf(corpse)
		var/wheres_wizdo = dir2text(get_dir(body_turf, parent_turf))
		if(wheres_wizdo)
			corpse.visible_message(span_warning("Suddenly, [corpse.name]'s corpse falls to pieces! You see a strange energy rise from the remains, and speed off towards the [wheres_wizdo]!"))
			body_turf.Beam(parent_turf, icon_state = "lichbeam", time = 1 SECONDS * (num_resurrections + 1))

		corpse.dust(drop_items = TRUE)

	return TRUE
