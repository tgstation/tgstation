/**
  * # Creamed component
  *
  * For when you have pie on your face
  */
/datum/component/creamed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/creamed/Initialize(datum/source, stunning)
	if(!istype(parent, /mob/living/carbon/human))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/carbon/human/H = parent
	var/mutable_appearance/creamoverlay = mutable_appearance('icons/effects/creampie.dmi')
	if(H.dna.species.limbs_id == "lizard")
		creamoverlay.icon_state = "creampie_lizard"
	else
		creamoverlay.icon_state = "creampie_human"
	pie_hit(source, stunning)

	H.add_overlay(creamoverlay)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "creampie", /datum/mood_event/creampie)

/datum/component/creamed/InheritComponent(datum/component/C, i_am_original, datum/source, stunning)
	pie_hit(source, stunning)

/datum/component/creamed/Destroy(force, silent)
	var/mob/living/carbon/human/H = parent
	H.cut_overlay(mutable_appearance('icons/effects/creampie.dmi', "creampie_lizard"))
	H.cut_overlay(mutable_appearance('icons/effects/creampie.dmi', "creampie_human"))
	return ..()

/**
  * Apply stuns, messages, blurriness
  *
  * Arguments:
  * * source the pie hitting the parent
  * * stunning if it should apply a stun
  */
/datum/component/creamed/proc/pie_hit(datum/source, stunning)
	var/mob/living/carbon/human/H = parent
	if(stunning)
		H.Paralyze(20) //splat!
	H.adjust_blurriness(1)
	H.visible_message("<span class='warning'>[H] is creamed by [source]!</span>", "<span class='userdanger'>You've been creamed by [source]!</span>")
	playsound(H, "desceration", 50, TRUE)

/datum/component/creamed/RegisterWithParent()
	RegisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_COMPONENT_CLEAN_FACE_ACT),
		.proc/clean_up)

/datum/component/creamed/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT, 
		COMSIG_COMPONENT_CLEAN_FACE_ACT))
	
///Callback to remove pieface
/datum/component/creamed/proc/clean_up(datum/source, strength)
	if(strength >= CLEAN_WEAK)
		qdel(src)
