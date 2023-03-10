///List of all vars that will not be copied over when using duplicate_object()
GLOBAL_LIST_INIT(duplicate_forbidden_vars, list(
	"AIStatus",
	"actions",
	"active_hud_list",
	"active_timers",
	"appearance",
	"area",
	"atmos_adjacent_turfs",
	"bodyparts",
	"ckey",
	"client_mobs_in_contents",
	"comp_lookup",
	"computer_id",
	"contents",
	"cooldowns",
	"datum_components",
	"external_organs",
	"external_organs_slot",
	"group",
	"hand_bodyparts",
	"held_items",
	"hud_list",
	"implants",
	"important_recursive_contents",
	"internal_organs",
	"internal_organs_slot",
	"key",
	"lastKnownIP",
	"loc",
	"locs",
	"managed_overlays",
	"managed_vis_overlays",
	"overlays",
	"overlays_standing",
	"parent",
	"parent_type",
	"power_supply",
	"quirks",
	"reagents",
	"signal_procs",
	"stat",
	"status_effects",
	"status_traits",
	"tag",
	"tgui_shared_states",
	"type",
	"update_on_z",
	"vars",
	"verbs",
	"x", "y", "z",
))
GLOBAL_PROTECT(duplicate_forbidden_vars)

/**
 * # duplicate_object
 *
 * Makes a copy of an item and transfers most vars over, barring GLOB.duplicate_forbidden_vars
 * Args:
 * original - Atom being duplicated
 * spawning_location - Turf where the duplicated atom will be spawned at.
 */
/proc/duplicate_object(atom/original, turf/spawning_location)
	RETURN_TYPE(original.type)
	if(!original)
		return

	var/atom/made_copy = new original.type(spawning_location)

	for(var/atom_vars in original.vars - GLOB.duplicate_forbidden_vars)
		if(islist(original.vars[atom_vars]))
			var/list/var_list = original.vars[atom_vars]
			made_copy.vars[atom_vars] = var_list.Copy()
			continue
		else if(istype(original.vars[atom_vars], /datum) || ismob(original.vars[atom_vars]))
			continue // this would reference the original's object, that will break when it is used or deleted.
		made_copy.vars[atom_vars] = original.vars[atom_vars]

	if(isliving(made_copy))
		if(iscarbon(made_copy))
			var/mob/living/carbon/original_carbon = original
			var/mob/living/carbon/copied_carbon = made_copy
			//transfer DNA over (also body features), then update skin color.
			original_carbon.dna.copy_dna(copied_carbon.dna)
			copied_carbon.updateappearance(mutcolor_update = TRUE)

		var/mob/living/original_living = original
		var/mob/living/copied_living = made_copy
		//transfer implants, we do this so the original's implants being removed won't destroy ours.
		for(var/obj/item/implant/original_implants as anything in original_living.implants)
			var/obj/item/implant/copied_implant = new original_implants.type
			copied_implant.implant(made_copy, silent = TRUE, force = TRUE)
		//transfer quirks, we do this because transfering the original's quirks keeps the 'owner' as the original.
		for(var/datum/quirk/original_quirks as anything in original_living.quirks)
			copied_living.add_quirk(original_quirks.type)

	return made_copy
