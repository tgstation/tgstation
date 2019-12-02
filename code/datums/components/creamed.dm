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
	var/already_creamed = FALSE
	var/mob/living/carbon/thrower
	var/stun = FALSE


/datum/component/creamed/Initialize(_thrower, _stun)
	if(!is_type_in_typecache(parent, GLOB.creamable))
		return COMPONENT_INCOMPATIBLE
	if(_thrower)
		thrower = _thrower
	if(_stun)
		stun = _stun
	creamface = mutable_appearance('icons/effects/creampie.dmi')

	cream()

	if(ishuman(parent))
		var/mob/living/carbon/human/H = parent
		if(H.dna.species.limbs_id == "lizard")
			creamface.icon_state = "creampie_lizard"
		else
			creamface.icon_state = "creampie_human"
	else if(ismonkey(parent))
		creamface.icon_state = "creampie_monkey"
	else if(iscorgi(parent))
		creamface.icon_state = "creampie_corgi"
	else if(isAI(parent))
		creamface.icon_state = "creampie_ai"


	var/atom/A = parent
	A.add_overlay(creamface)

/datum/component/creamed/Destroy(force, silent)
	var/atom/A = parent
	A.cut_overlay(creamface)
	qdel(creamface)
	if(ishuman(A))
		SEND_SIGNAL(A, COMSIG_CLEAR_MOOD_EVENT, "creampie")
	return ..()

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

///proc that manages xp and pie stun
/datum/component/creamed/proc/cream()
	if(iscarbon(parent))
		var/mob/living/C = parent
		if(C.client && thrower && thrower.mind) //making sure the target (C)  isnt afk
			SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "creampie", /datum/mood_event/creampie)
			var/experience_given = 30
			if(HAS_TRAIT(C.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
				experience_given *= 3
			if(already_creamed)
				experience_given *= 0.1
			thrower.mind.adjust_experience(/datum/skill/pie_throwing, experience_given)
		if(stun && thrower)
			var/skillmod = thrower.mind.get_skill_speed_modifier(/datum/skill/pie_throwing)
			if(skillmod > 25)// journeyman level or higher
				C.Paralyze(skillmod) //splat!
			else
				C.Knockdown(skillmod) //splish!
			C.adjust_blurriness(1)
		C.visible_message("<span class='warning'>[C] is creamed by a pie!</span>", "<span class='userdanger'>You've been creamed by a pie!</span>")
		playsound(C, "desceration", 50, TRUE)

/datum/component/creamed/InheritComponent(datum/newcomp, orig, list/arglist)
	. = ..()
	already_creamed = TRUE
	cream()
