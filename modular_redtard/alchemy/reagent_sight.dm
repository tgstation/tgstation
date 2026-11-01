// Ratwood's examine of a vessel (code/game/atoms.dm examine()), on medieval maps: an alchemist from reagent_sight_rank of
// Alchemy, or one who knows brews and spirits (TRAIT_CICERONE), standing by a see-through vessel reads what it holds, reagent
// by reagent; anyone aiming at the nose by an open vessel takes a whiff and smells it, and an expert alchemist
// (TRAIT_ALCHEMY_EXPERT) tells by the smell what is in it. Everyone else reads TG's "various reagents". The vessels are the
// reagent containers and the kegs (survival/brewing.dm).

/// Least learned rank of Alchemy that reads a vessel (Ratwood SKILL_LEVEL_APPRENTICE).
#define ROGUE_REAGENT_SIGHT_RANK rogue_value("reagent_sight_rank")
/// Least share in percent of a smell in the mix that is smelt (Ratwood generate_scent_message() 15).
#define ROGUE_SNIFF_THRESHOLD rogue_value("reagent_sniff_threshold")
/// The part aimed at to sniff (Ratwood BODY_ZONE_PRECISE_NOSE, the module's precise zone).
#define ROGUE_SNIFF_ZONE "nose"

/obj/item/reagent_containers/Initialize(mapload, vol)
	. = ..()
	if(rogue_survival_enabled())
		AddElement(/datum/element/rogue_reagent_sight)

/datum/element/rogue_reagent_sight

/datum/element/rogue_reagent_sight/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_REAGENT_EXAMINE, PROC_REF(on_reagent_examine))

/datum/element/rogue_reagent_sight/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ATOM_REAGENT_EXAMINE)
	return ..()

/// The reagent lines of an examine: Ratwood's list of what the vessel holds for those who read it (in place of TG's lines),
/// and the whiff of an open one.
/datum/element/rogue_reagent_sight/proc/on_reagent_examine(atom/source, mob/user, list/examine_list, user_sees_reagents)
	SIGNAL_HANDLER
	var/datum/reagents/holder = source.reagents
	if(!isliving(user) || !holder?.total_volume)
		return NONE
	var/mob/living/viewer = user
	. = NONE
	if(!user_sees_reagents && (holder.flags & TRANSPARENT) && reads_reagents(viewer, source))
		examine_list += "It contains:"
		for(var/datum/reagent/reagent as anything in holder.reagent_list)
			var/amount = round(reagent.volume, 0.1)
			examine_list += "[amount] [amount == 1 ? "dram" : "drams"] of <font color=[reagent.color]>[reagent.name]</font>"
		. = STOP_GENERIC_REAGENT_EXAMINE
	if(source.is_open_container() && viewer.Adjacent(source) && viewer.rogue_precise_zone() == ROGUE_SNIFF_ZONE)
		sniff(source, viewer, examine_list)

/// Whether the viewer reads the vessel reagent by reagent: by it, with the Alchemy or the trait for it.
/datum/element/rogue_reagent_sight/proc/reads_reagents(mob/living/viewer, atom/vessel)
	if(!viewer.Adjacent(vessel))
		return FALSE
	return HAS_TRAIT(viewer, TRAIT_CICERONE) || viewer.rogue_learned_rank(ROGUE_ALCHEMY_SKILL) >= ROGUE_REAGENT_SIGHT_RANK

/// Ratwood's whiff of an open vessel: its smell, and to an expert alchemist the names of what is in it.
/datum/element/rogue_reagent_sight/proc/sniff(atom/vessel, mob/living/viewer, list/examine_list)
	var/list/reagents_held = vessel.reagents.reagent_list
	viewer.visible_message(span_info("[viewer] takes a whiff of [vessel]..."), span_info("I take a whiff of [vessel]..."))
	examine_list += span_notice("I smell [generate_reagents_taste_message(reagents_held, viewer, ROGUE_SNIFF_THRESHOLD)].")
	if(!HAS_TRAIT(viewer, TRAIT_ALCHEMY_EXPERT))
		return
	var/list/names = list()
	for(var/datum/reagent/reagent as anything in reagents_held)
		if(reagent.volume > 0)
			names += LOWER_TEXT(reagent.name)
	examine_list += span_notice("My expert nose lets me distinguish this liquid as [jointext(names, ", ")].")

#undef ROGUE_REAGENT_SIGHT_RANK
#undef ROGUE_SNIFF_THRESHOLD
#undef ROGUE_SNIFF_ZONE
