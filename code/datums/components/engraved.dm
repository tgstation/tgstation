/**
 * # engraved component!
 *
 * component for walls that applies an engraved overlay and lets you examine it to read a story (+ art element yay)
 * new creations will get a high art value, cross round scrawlings will get a low one.
 * MUST be a component, though it doesn't look like it. SSPersistence demandeth
 */
/datum/component/engraved
	///the generated story string
	var/engraved_description
	///whether this is a new engraving, or a persistence loaded one.
	var/new_creation
	///what random icon state should the engraving have
	var/icon_state_append

/datum/component/engraved/Initialize(engraved_description, new_creation)
	. = ..()
	if(!isclosedturf(parent))
		return COMPONENT_INCOMPATIBLE
	var/turf/closed/engraved_wall = parent

	SSpersistence.wall_engravings += src
	engraved_wall.turf_flags &= ~ENGRAVABLE
	src.engraved_description = engraved_description
	src.new_creation = new_creation
	var/art_value = new_creation ? rand(20, 30) : 10
	engraved_wall.AddElement(/datum/element/art, art_value)
	icon_state_append = rand(1, 2)
	//must be here to allow overlays to be updated
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/on_update_overlays)

/datum/component/engraved/Destroy(force, silent)
	. = ..()
	var/turf/closed/engraved_wall = parent
	SSpersistence.wall_engravings -= src
	engraved_wall.turf_flags |= ENGRAVABLE
	parent.RemoveElement(/datum/element/art)
	engraved_wall.update_appearance()

/datum/component/engraved/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/engraved/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

/// Used to maintain the acid overlay on the parent [/atom].
/datum/component/engraved/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	overlays += mutable_appearance('icons/turf/wall_overlays.dmi', "engraving[icon_state_append]")

///signal called on parent being examined
/datum/component/engraved/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_boldnotice(engraved_description)

///returns all the information SSpersistence needs in a list to load up this engraving on a future round!
/datum/component/engraved/proc/save_persistent()
	var/turf/closed/engraved_wall = parent
	. = list()
	.["x"] = engraved_wall.x
	.["y"] = engraved_wall.y
	.["z"] = engraved_wall.z
	.["story"] = engraved_description
