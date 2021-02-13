

/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(15)
	var/hitverb = "hit"
	if(mob_size < MOB_SIZE_LARGE)
		safe_throw_at(get_edge_target_turf(src, get_dir(user, src)), 2, 1, user)
		hitverb = "slam"
	playsound(loc, "punch", 25, TRUE, -1)
	visible_message("<span class='danger'>[user] [hitverb]s [src]!</span>", \
					"<span class='userdanger'>[user] [hitverb]s you!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, user)
	to_chat(user, "<span class='danger'>You [hitverb] [src]!</span>")

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!..() || !user.combat_mode)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if (body_position == STANDING_UP)
			if (prob(5))
				Unconscious(40)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				log_combat(user, src, "pushed")
				visible_message("<span class='danger'>[user] pushes [src] down!</span>", \
								"<span class='userdanger'>[user] pushes you down!</span>", "<span class='hear'>You hear aggressive shuffling followed by a loud thud!</span>", null, user)
				to_chat(user, "<span class='danger'>You push [src] down!</span>")
		return TRUE
	var/damage = rand(1, 9)
	if (prob(90))
		playsound(loc, "punch", 25, TRUE, -1)
		visible_message("<span class='danger'>[user] punches [src]!</span>", \
						"<span class='userdanger'>[user] punches you!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, user)
		to_chat(user, "<span class='danger'>You punch [src]!</span>")
		if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
			Unconscious(40)
			visible_message("<span class='danger'>[user] knocks [src] down!</span>", \
							"<span class='userdanger'>[user] knocks you down!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, user)
			to_chat(user, "<span class='danger'>You knock [src] down!</span>")
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))
		apply_damage(damage, BRUTE, affecting)
		log_combat(user, src, "attacked")
	else
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		visible_message("<span class='danger'>[user]'s punch misses [src]!</span>", \
						"<span class='danger'>You avoid [user]'s punch!</span>", "<span class='hear'>You hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, user)
		to_chat(user, "<span class='warning'>Your punch misses [src]!</span>")


/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
