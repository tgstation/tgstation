/**
 * # engraved component!
 *
 * component for walls that applies an engraved overlay and lets you examine it to read a story (+ art element yay)
 * new creations will get a high art value, cross round scrawlings will get a low one.
 */
/datum/component/engraved
	///the generated story string
	var/engraved_description
	///whether this is a new engraving, or a persistence loaded one.
	var/new_creation

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
	//ADD ENGRAVED OVERLAY HERE

/datum/component/engraved/Destroy(force, silent)
	. = ..()
	var/turf/closed/engraved_wall = parent
	SSpersistence.wall_engravings -= src
	engraved_wall.turf_flags |= ENGRAVABLE
	parent.RemoveElement(/datum/element/art)
	//...AND REMOVE ENGRAVED OVERLAY HERE

/datum/component/engraved/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/engraved/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

///signal called on parent being examined
/datum/component/engraved/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_boldnotice("[engraved_description]")

///returns all the information SSpersistence needs in a list to load up this engraving on a future round!
/datum/component/engraved/proc/save_persistent()
	var/turf/closed/engraved_wall = parent
	. = list()
	.["x"] = engraved_wall.x
	.["y"] = engraved_wall.y
	.["z"] = engraved_wall.z
	.["story"] = engraved_description
