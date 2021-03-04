

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(..())
		var/damage = rand(1, 9)
		if (prob(90))
			playsound(loc, "punch", 25, TRUE, -1)
			log_combat(user, src, "attacked")
			visible_message("<span class='danger'>[user] kicks [src]!</span>", \
							"<span class='userdanger'>[user] kicks you!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='danger'>You kick [src]!</span>")
			if ((stat != DEAD) && (damage > 4.9))
				Unconscious(rand(100,200))

			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))
			apply_damage(damage, BRUTE, affecting)
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[user]'s kick misses [src]!</span>", \
							"<span class='danger'>You avoid [user]'s kick!</span>", "<span class='hear'>You hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='warning'>Your kick misses [src]!</span>")

/mob/living/carbon/alien/larva/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(5 + rand(1,9))
	new /datum/forced_movement(src, get_step_away(user,src, 30), 1)

/mob/living/carbon/alien/larva/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()
