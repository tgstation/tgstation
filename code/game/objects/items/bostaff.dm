/obj/item/melee/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 2
	attack_verb_simple = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "bostaff0"
	base_icon_state = "bostaff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_chance = 50

/obj/item/melee/bostaff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = 14, \
	)

/obj/item/melee/bostaff/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/melee/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='warning'>You club yourself over the head with [src].</span>")
		user.Paralyze(60)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, span_warning("It would be dishonorable to attack a foe while they cannot retaliate."))
		return
	if(!user.combat_mode)
		if(!HAS_TRAIT(src, TRAIT_WIELDED))
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("[user] clubs [H] with [src]!", \
									  "[user] smacks [H] with the butt of [src]!", \
									  "[user] broadsides [H] with [src]!", \
									  "[user] smashes [H]'s head with [src]!", \
									  "[user] beats [H] with the front of [src]!", \
									  "[user] twirls and slams [H] with [src]!")
		H.visible_message(span_warning("[pick(fluffmessages)]"), \
							   span_userdanger("[pick(fluffmessages)]"))
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
		playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 75, 1, -1)
		SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, H, user)
		SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, H, user)
		H.lastattacker = user.real_name
		H.lastattackerckey = user.ckey

		user.do_attack_animation(H)

		log_combat(user, H, "Bo Staffed", src.name, "((DAMTYPE: STAMINA)")
		add_fingerprint(user)
		H.apply_damage(rand(28,33), STAMINA, BODY_ZONE_HEAD)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message(span_warning("[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"), \
									   span_userdanger("[user] knocks you unconscious!"))
				H.SetUnconscious(30 SECONDS)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/melee/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return FALSE
