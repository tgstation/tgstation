// Empath quirk component, it's a component because it can be applied in ways that don't give you the quirk. (For health analyzer purposes)

/datum/component/empathy

	// Whether or not we should get scared the next time we see an evil person.
	var/seen_it = FALSE

	// What sort of information we can glean from examining someone, stored in binary (511 = everything)
	var/visible_info = 511

	// Whether or not we can use empathy on ourselves
	var/self_empath = FALSE

	// Whether or not empathy works on humans playing dead
	var/sense_dead = FALSE

	// Whether or not we can tell if people whisper under their mask from far away (We can't hear what they said, we just know they said something)
	var/sense_whisper = TRUE

	// Whether or not we can be smited by someoneone with the evil trait using the mending touch mutation
	var/smite_target = TRUE

/datum/component/empathy/Initialize(seen_it = FALSE, visible_info = 511, self_empath = FALSE, sense_dead = FALSE, sense_whisper = TRUE, smite_target = TRUE)
	if (!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	src.seen_it = seen_it
	src.visible_info = visible_info
	src.self_empath = self_empath
	src.sense_dead = sense_dead
	src.sense_whisper = sense_whisper
	src.smite_target = smite_target
