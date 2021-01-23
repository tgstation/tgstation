#define REPULSION_COMBO "HDH"
#define HERESY_COMBO "HDDH"
#define MARK_COMBO "DHH"

/datum/martial_art/ratvar
	name = "Justicar's Light"
	id = MARTIALART_RATVAR
	help_verb = /mob/living/proc/ratvar_martial_help

/datum/martial_art/ratvar/proc/check_streak(mob/living/A, mob/living/D)
	if(findtext(streak,REPULSION_COMBO))
		streak = ""
		Repulsion(A,D)
		return TRUE
	if(findtext(streak,HERESY_COMBO))
		streak = ""
		Heresy(A,D)
		return TRUE
	if(findtext(streak,MARK_COMBO))
		streak = ""
		Mark(A, D) //We don't return anything cuz we still need for our hit to land
	return FALSE

/datum/martial_art/ratvar/proc/Repulsion(mob/living/A, mob/living/D)
	var/obj/item/melee/touch_attack/ratvar_repulse/touch = new(get_turf(A))
	A.put_in_active_hand(touch)
	to_chat(A, "<span class='warning'>Forgotten energy fill your hand, unleash it onto your opponent to throw them back!</span>")
	return

/obj/item/melee/touch_attack/ratvar_repulse
	name = "\improper forgotten energy"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "RA'T ARV NEZB'ERE!!"
	on_use_sound = 'sound/weapons/punch1.ogg'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"

/obj/item/melee/touch_attack/ratvar_repulse/afterattack(mob/living/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !istype(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE))
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>You can't get the words out!</span>")
		return
	target.visible_message("<span class='danger'>[user] hits [target] with their hand, unleashing eldritch energy!</span>", "<span class='userdanger'>You're hit with eldritch energy by [user]!</span>", "<span class='hear'>You hear a sickening sound of burning flesh!</span>", null, user)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(target, user)))
	target.throw_at(throw_target, 200, 4, user)
	target.apply_damage(10, BURN)
	log_combat(user, target, "used repulse(Justicar's Light)")
	return ..()

/datum/martial_art/ratvar/proc/Mark(mob/living/A, mob/living/D)
	D.visible_message("<span class='danger'>[A] kicks [D] into their head and suddenly a bunch of strange smoke appears!</span>", \
					"<span class='userdanger'>You're hit into your head by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, A)
	to_chat(A, "<span class='danger'>You invoke ancient magic onto [D]!</span>")
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	D.apply_damage(5, BURN)
	D.apply_status_effect(/datum/status_effect/ratvar_steam)
	A.say("NA'VAB RE'EB!", forced="justicar's light")
	log_combat(A, D, "marked(Justicar's light)")
	return


/datum/martial_art/ratvar/proc/Heresy(mob/living/A, mob/living/D)
	if(D.has_status_effect(/datum/status_effect/ratvar_steam) && !D.anti_magic_check())
		D.visible_message("<span class='danger'>[A] kicks [D] and strange smoke around them starts to thicken on their skin!</span>", \
						"<span class='userdanger'>[A] kicks you and strange smoke around you starts to thicken, burning your skin!</span>", "<span class='hear'>You can hear sounds of burning flesh!</span>", null, A)
		to_chat(A, "<span class='danger'>You mark [D] as a heretic, boiling them alive!</span>")
		playsound(D.loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
		D.remove_status_effect(/datum/status_effect/ratvar_steam)
		D.apply_damage(50, BURN) //A really damaging combo. Can crit someone badly wounded. It's balanced cuz you need 7 hits to make it work
		if(iscarbon(D))
			var/mob/living/carbon/C = D
			C.adjust_fire_stacks(1)
			C.IgniteMob()
		log_combat(A, D, "marked as a heretic(Justicar's Light)")
	else
		D.visible_message("<span class='danger'>[A] performs a strange combo on [D], but nothing seems to happen!</span>", \
						"<span class='userdanger'>[A] tried to perform a strange combo on you, but nothing happens!</span>", "<span class='hear'>You can hear agressive tapping followed by a sound of flesh hitting flesh!</span>", null, A)
		to_chat(A, "<span class='danger'>You try to mark [D] as a heretic, but nothing seems to happen!</span>")
		playsound(D.loc, 'sound/weapons/punch2.ogg', 50, TRUE, -1)
		log_combat(A, D, "failed to use heresy combo(Justicar's Light)")
	return

/mob/living/proc/ratvar_martial_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Justicar's Light."
	set category = "Justicar's Light"

	to_chat(usr, "<b><i>You clench your fists and have a flashback of knowledge...</i></b>")
	to_chat(usr, "<span class='notice'>Repulse</span>: Harm Disarm Harm. Fills your hand with eldritch energy, allowing you to throw back your opponent.")
	to_chat(usr, "<span class='notice'>Mark</span>: Disarm Harm Harm. Marks your enemy with Ratvar's smoke, dealing some burn damage to them.")
	to_chat(usr, "<span class='notice'>Heresy</span>: Harm Disarm Disarm Harm. Only works on marked foes. Deals a large amount of burn, ignite the enemy and removes mark from them.")


