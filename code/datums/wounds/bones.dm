


/*
	Bones
*/
// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons


/datum/wound/brute/bone
	sound_effect = 'sound/effects/crack1.ogg'
	/// If a bone wound is applied to a leg, we store the limp component here so we can delete it when removed
	var/datum/component/limp/current_limp
	wound_type = WOUND_TYPE_BONE

/datum/wound/brute/bone/apply_wound(obj/item/bodypart/L, silent=FALSE, special_arg=NONE)
	. = ..()

	if(L.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/mob/living/carbon/C = L.owner
		if(!(C.get_bodypart(BODY_ZONE_L_LEG) && C.get_bodypart(BODY_ZONE_R_LEG))) // can't limp with one leg
			return
		current_limp = C.AddComponent(/datum/component/limp)
		RegisterSignal(current_limp, COMSIG_PARENT_QDELETING, .proc/remove_limp)

/datum/wound/brute/bone/remove_wound()
	if(current_limp)
		QDEL_NULL(current_limp)
	. = ..()

/// In case we're limping and we lose a leg
/datum/wound/brute/bone/proc/remove_limp()
	current_limp = null

/datum/wound/brute/bone/moderate
	name = "joint dislocation"
	desc = "Patient's bone has been unset from socket, causing pain and reduced motor function."
	treat_text = "Recommended application of bonesetter to affected limb, though manual relocation may suffice."
	examine_desc = "is awkwardly jammed out of place"
	occur_text = "jerks violently and becomes unseated"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 4
	threshold_minimum = 35
	threshold_penalty = 15
	treatable_tool = TOOL_BONESET


/datum/wound/brute/bone/moderate/treat_self(obj/item/I, mob/user)
	victim.visible_message("<span class='danger'>[user] begins resetting [victim.p_their()] [limb.name] with [I].</span>", "<span class='warning'>You begin resetting your [limb.name] with [I]...</span>")
	if(do_after(user, 75 * I.toolspeed, target = victim))
		victim.visible_message("<span class='danger'>[user] finishes resetting [victim.p_their()] [limb.name]!</span>", "<span class='userdanger'>You reset your [limb.name]!</span>")
		victim.emote("scream")
		remove_wound()

/datum/wound/brute/bone/moderate/treat(obj/item/I, mob/user)
	user.visible_message("<span class='danger'>[user] begins resetting [victim]'s [limb.name] with [I].</span>", "<span class='notice'>You begin resetting [victim]'s [limb.name] with [I]...</span>", victim)
	to_chat(victim, "<span class='warning'>[user] begins resetting your [limb.name] with [I].</span>")
	if(do_after(user, 50 * I.toolspeed, target = victim))
		user.visible_message("<span class='danger'>[user] finishes resetting [victim]'s [limb.name]!</span>", "<span class='nicegreen'>You finish resetting [victim]'s [limb.name]!</span>", victim)
		to_chat(victim, "<span class='userdanger'>[user] resets your [limb.name]!</span>")
		victim.emote("scream")
		remove_wound()



/datum/wound/brute/bone/severe
	name = "hairline fracture"
	desc = "Patient's bone has suffered a crack in the foundation, causing serious pain and reduced limb functionality."
	treat_text = "Recommended light surgical application of bone gel, though splinting will prevent worsening situation."
	examine_desc = "appears bruised and grotesquely swollen"
	occur_text = "sprays chips of bone and develops a nasty looking bruise"
	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 7
	threshold_minimum = 55
	threshold_penalty = 30

/datum/wound/brute/bone/critical
	name = "compound fracture"
	desc = "Patient's bones have suffered multiple gruesome fractures, causing significant pain and near uselessness of limb."
	treat_text = "Immediate binding of affected limb, followed by surgical intervention ASAP."
	examine_desc = "has a cracked bone sticking out of it"
	occur_text = "cracks apart, exposing broken bones to open air"
	severity = WOUND_SEVERITY_CRITICAL
	interaction_efficiency_penalty = 4
	limp_slowdown = 12
	sound_effect = 'sound/effects/crack2.ogg'
	threshold_minimum = 110
	threshold_penalty = 50



