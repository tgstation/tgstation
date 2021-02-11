/datum/martial_art/brassknuckles
	name = "Brass Knuckles"
	id = MARTIALART_BRASSKNUCKLES

/datum/martial_art/brassknuckles/harm_act(mob/living/A, mob/living/D)
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)
	var/picked_hit_type = pick("punch", "smoke", "knuck", "knuckledust")
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type]s [D]!</span>", \
					"<span class='userdanger'>You're [picked_hit_type]ed by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You [picked_hit_type] [D]!</span>")
	log_combat(A, D, "punched")
	D.apply_damage(rand(5,10), BRUTE, affecting, armor_block, wound_bonus = 15)
	return TRUE

/obj/item/clothing/gloves/brassknuckles
	var/datum/martial_art/brassknuckles/style = new

/obj/item/clothing/gloves/brassknuckles/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		style.teach(user, TRUE)

/obj/item/clothing/gloves/brassknuckles/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(user)

/obj/item/clothing/gloves/brassknuckles
	name = "Brass Knuckles"
	desc = "A contraband item meant to prove that weapons are for pussies. Perfect for any bloodthirsty soldier or lunatics wearing tiger masks."
	icon_state = "brassknuckles"
	inhand_icon_state = "brassknuckles"
