GLOBAL_LIST_INIT(creamable, typecacheof(list(
	/mob/living/carbon/human,
	/mob/living/carbon/monkey,
	/mob/living/simple_animal/pet/dog/corgi,
	/mob/living/silicon/ai)))

/**
  * # Creamed component
  *
  * For when you have pie on your face
  */
/datum/component/creamed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/mutable_appearance/creamface

/datum/component/creamed/Initialize(datum/source, stunning)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(is_type_in_typecache(parent, GLOB.creamable))
		creamface = mutable_appearance('icons/effects/creampie.dmi')

		if(ishuman(parent))
			var/mob/living/carbon/human/H = parent
			if(H.dna.species.limbs_id == "lizard")
				creamface.icon_state = "creampie_lizard"
			else
				creamface.icon_state = "creampie_human"
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "creampie", /datum/mood_event/creampie)
		else if(ismonkey(parent))
			creamface.icon_state = "creampie_monkey"
		else if(iscorgi(parent))
			creamface.icon_state = "creampie_corgi"
		else if(isAI(parent))
			creamface.icon_state = "creampie_ai"

		var/atom/A = parent
		A.add_overlay(creamface)

	pie_hit(source, stunning)

/datum/component/creamed/InheritComponent(datum/component/C, i_am_original, datum/source, stunning)
	pie_hit(source, stunning)

/datum/component/creamed/Destroy(force, silent)
	if(is_type_in_typecache(parent, GLOB.creamable))
		var/atom/A = parent
		A.cut_overlay(creamface)
		qdel(creamface)
	return ..()

/**
  * Apply stuns, messages, blurriness
  *
  * Arguments:
  * * source the pie hitting the parent
  * * stunning if it should apply a stun
  */
/datum/component/creamed/proc/pie_hit(datum/source, stunning)
	var/mob/living/L = parent
	if(stunning)
		L.Paralyze(20) //splat!
	L.adjust_blurriness(1)
	L.visible_message("<span class='warning'>[L] is creamed by [source]!</span>", "<span class='userdanger'>You've been creamed by [source]!</span>")
	playsound(L, "desceration", 50, TRUE)

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
