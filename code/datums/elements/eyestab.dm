// It an item has the eyestab element, when you hit someone while targetting their eyes it stabs them in the eyes
/datum/element/eyestab/Attach(datum/target)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/eyestab)

/datum/element/dunkable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_ATTACK)

/datum/element/eyestab/proc/eyestab(obj/item/source, mob/living/carbon/M, mob/living/carbon/user)
	if(user.zone_selected != BODY_ZONE_PRECISE_EYES)
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		M = user
	var/is_human_victim
	var/obj/item/bodypart/affecting = M.get_bodypart(BODY_ZONE_HEAD)
	if(ishuman(M))
		if(!affecting) //no head!
			return
		is_human_victim = TRUE

	if(source.force && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
		return COMPONENT_ITEM_NO_ATTACK

	if(M.is_eyes_covered())
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "<span class='warning'>You're going to need to remove [M.p_their()] eye protection first!</span>")
		return

	if(isalien(M))//Aliens don't have eyes./N     slimes also don't have eyes!
		to_chat(user, "<span class='warning'>You cannot locate any eyes on this creature!</span>")
		return

	if(isbrain(M))
		to_chat(user, "<span class='warning'>You cannot locate any organic eyes on this brain!</span>")
		return

	source.add_fingerprint(user)

	playsound(source.loc, source.hitsound, 30, TRUE, -1)

	user.do_attack_animation(M)

	if(M != user)
		M.visible_message("<span class='danger'>[user] stabs [M] in the eye with [source]!</span>", \
							"<span class='userdanger'>[user] stabs you in the eye with [source]!</span>")
	else
		user.visible_message( \
			"<span class='danger'>[user] stabs [user.p_them()]self in the eyes with [source]!</span>", \
			"<span class='userdanger'>You stab yourself in the eyes with [source]!</span>" \
		)
	if(is_human_victim)
		var/mob/living/carbon/human/U = M
		U.apply_damage(7, BRUTE, affecting)

	else
		M.take_bodypart_damage(7)

	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "eye_stab", /datum/mood_event/eye_stab)

	log_combat(user, M, "attacked", "[source.name]", "(INTENT: [uppertext(user.a_intent)])")

	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	M.adjust_blurriness(3)
	eyes.applyOrganDamage(rand(2,4))
	if(eyes.damage >= 10)
		M.adjust_blurriness(15)
		if(M.stat != DEAD)
			to_chat(M, "<span class='danger'>Your eyes start to bleed profusely!</span>")
		if(!(M.is_blind() || HAS_TRAIT(M, TRAIT_NEARSIGHT)))
			to_chat(M, "<span class='danger'>You become nearsighted!</span>")
		M.become_nearsighted(EYE_DAMAGE)
		if(prob(50))
			if(M.stat != DEAD)
				if(M.drop_all_held_items())
					to_chat(M, "<span class='danger'>You drop what you're holding and clutch at your eyes!</span>")
			M.adjust_blurriness(10)
			M.Unconscious(20)
			M.Paralyze(40)
		if (prob(eyes.damage - 10 + 1))
			M.become_blind(EYE_DAMAGE)
			to_chat(M, "<span class='danger'>You go blind!</span>")
	return COMPONENT_ITEM_NO_ATTACK