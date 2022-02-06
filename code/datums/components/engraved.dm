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
	var/persistent_save
	///what random icon state should the engraving have
	var/icon_state_append
	///The story value of this piece.
	var/story_value

/datum/component/engraved/Initialize(engraved_description, persistent_save, story_value)
	. = ..()
	if(!isclosedturf(parent))
		return COMPONENT_INCOMPATIBLE
	var/turf/closed/engraved_wall = parent

	src.engraved_description = engraved_description
	src.persistent_save = persistent_save
	src.story_value = story_value

	var/beauty_value
	switch(story_value)
		if(STORY_VALUE_SHIT)
			beauty_value = rand(-50, 50) //Ugly or mediocre at best
		if(STORY_VALUE_NONE)
			beauty_value = rand(0, 100) //No inherent value
		if(STORY_VALUE_MEH)
			beauty_value = rand(100, 200) //Its an okay tale
		if(STORY_VALUE_OKAY)
			beauty_value = rand(150, 300) //Average story! most things are like this
		if(STORY_VALUE_AMAZING)
			beauty_value = rand(300, 600)//Really impactful stories, seeing a lost limb, losing a loved pet.
		if(STORY_VALUE_LEGENDARY)
			beauty_value = rand(500, 800) //Almost always a good story! this is for memories you can barely ever get, killing megafauna, doing ultimate feats!

	engraved_wall.AddElement(/datum/element/art, beauty_value / ENGRAVING_BEAUTY_TO_ART_FACTOR)
	if(persistent_save)
		engraved_wall.AddElement(/datum/element/beauty, beauty_value)
	else
		engraved_wall.AddElement(/datum/element/beauty, beauty_value / ENGRAVING_PERSISTENCE_BEAUTY_LOSS_FACTOR) //Old age does them harm
	icon_state_append = rand(1, 2)
	//must be here to allow overlays to be updated
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/on_update_overlays)
	engraved_wall.update_appearance()

/datum/component/engraved/Destroy(force, silent)
	. = ..()
	parent.RemoveElement(/datum/element/art)
	//must be here to allow overlays to be updated
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	if(parent && !QDELING(parent))
		var/atom/parent_atom = parent
		parent_atom.update_appearance()

/datum/component/engraved/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	//supporting component transfer means putting these here instead of initialize
	SSpersistence.wall_engravings += src
	ADD_TRAIT(parent, TRAIT_NOT_ENGRAVABLE, TRAIT_GENERIC)

/datum/component/engraved/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	//supporting component transfer means putting these here instead of destroy
	SSpersistence.wall_engravings -= src
	REMOVE_TRAIT(parent, TRAIT_NOT_ENGRAVABLE, TRAIT_GENERIC)

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
	var/list/saved_data = list()
	saved_data["story"] = engraved_description
	saved_data["story_value"] = story_value

	return list(saved_data)

