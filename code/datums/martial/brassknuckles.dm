/datum/martial_art/brassknuckles
	name = "Krav Maga"
	id = MARTIALART_BRASSKNUCKLES

/datum/martial_art/the_sleeping_carp/proc/strongPunch(mob/living/A, mob/living/D)
	///this var is so that the strong punch is always aiming for the body part the user is targeting and not trying to apply to the chest before deviating
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("pummels", "smokes", "wallops", "knucks", "knuckledusts")
	D.visible_message("<span class='danger'>[A] [atk_verb]s [D]!</span>", \
					"<span class='userdanger'>[A] [atk_verb]s you!</span>", null, null, A)
	to_chat(A, "<span class='danger'>You [atk_verb] [D]!</span>")
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(A, D, "knuckledusted (brass knuckles))")
	D.apply_damage(20, A.get_attack_type(), affecting)
	return

/obj/item/clothing/gloves/brassknuckles/equipped(mob/user, slot)
	..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/student = user
		style.teach(student, 1)

/obj/item/clothing/gloves/brassknuckles/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/owner = user
	style.remove(owner)
