#define STRONG_PUNCH_COMBO "HH"
#define LAUNCH_KICK_COMBO "HD"
#define DROP_KICK_COMBO "HG"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/sleeping_carp_help
	var/datum/action/slipstream/slipstream = new/datum/action/slipstream()
	var/datum/action/roused_anger/rousedanger = new/datum/action/roused_anger()
	
/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,STRONG_PUNCH_COMBO))
		streak = ""
		strongPunch(A,D)
		return TRUE
	if(findtext(streak,LAUNCH_KICK_COMBO))
		streak = ""
		launchKick(A,D)
		return TRUE
	if(findtext(streak,DROP_KICK_COMBO))
		streak = ""
		dropKick(A,D)
		return TRUE
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/strongPunch(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("kick", "chop", "hit", "slam")
	var/crit_damage = 0
	D.visible_message("<span class='danger'>[A] [atk_verb]s [D]!</span>", \
					"<span class='userdanger'>[A] [atk_verb]s you!</span>", null, null, A)
	to_chat(A, "<span class='danger'>You [atk_verb] [D]!</span>")
	if(prob(10))
		crit_damage += 20
		playsound(get_turf(D), 'sound/weapons/bite.ogg', 25, TRUE, -)
		D.visible_message("<span class='warning'>[D] sputters blood as the blow strikes them with inhuman force!</span>", "<span class='userdanger'>You reel from the pain of the blow! [A] has struck you with inhuman strength and speed!</span>")
	else
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	D.apply_damage(20 + crit_damage, A.dna.species.attack_type)
	log_combat(A, D, "strong punched (Sleeping Carp)")
	return

/datum/martial_art/the_sleeping_carp/proc/launchKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	D.visible_message("<span class='warning'>[A] kicks [D] square in the chest, sending them flying!</span>", \
					"<span class='userdanger'>You are kicked square in the chest by [A], sending you flying!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	var/atom/throw_target = get_edge_target_turf(D, A.dir)
	D.throw_at(throw_target, rand(5,6), 7, user)
	D.apply_damage(25, A.dna.species.attack_type)
	log_combat(A, D, "launch kicked (Sleeping Carp)")
	return

/datum/martial_art/the_sleeping_carp/proc/dropKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if((D.mobility_flags & MOBILITY_STAND))
		D.apply_damage(20, A.dna.species.attack_type)
		D.Knockdown(60)
		D.visible_message("<span class='warning'>[A] kicks [D] in the head, sending them face first into the floor!</span>", \
					"<span class='userdanger'>You are kicked in the head by [A], sending you crashing to the floor!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	if(!(D.mobility_flags & MOBILITY_STAND))
		D.apply_damage(20, A.dna.species.attack_type)
		D.adjustStaminaLoss(40)
		D.drop_all_held_items()
		D.visible_message("<span class='warning'>[A] kicks [D] in the head!</span>", \
					"<span class='userdanger'>You are kicked in the head by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	return

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
			return TRUE
	return ..()

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("kick", "chop", "hit", "slam")
	D.visible_message("<span class='danger'>[A] [atk_verb]s [D]!</span>", \
					"<span class='userdanger'>[A] [atk_verb]s you!</span>", null, null, A)
	to_chat(A, "<span class='danger'>You [atk_verb] [D]!</span>")
	D.apply_damage(rand(10,15), BRUTE)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(A, D, "[atk_verb] (Sleeping Carp)")
	return TRUE


/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return ..()

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(H, TRAIT_NOGUNS, TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, SLEEPING_CARP_TRAIT)
	H.physiology.brute_mod *= 0.3
	H.physiology.burn_mod *= 0.3
	H.physiology.stamina_mod *= 0.3
	H.physiology.stun_mod *= 0.3
	H.physiology.pressure_mod *= 0.3 //go hang out with carp
	H.physiology.cold_mod *= 0.3 //seriously go say hi
	
	H.faction |= "carp" //:D

/datum/martial_art/the_sleeping_carp/on_remove(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_NOGUNS, TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, SLEEPING_CARP_TRAIT)
	H.physiology.brute_mod *= 2
	H.physiology.burn_mod *= 2
	H.physiology.stamina_mod *= 2
	H.physiology.stun_mod *= 2
	H.physiology.pressure_mod *= 2 //no more carpies
	H.physiology.cold_mod *= 2
	
	H.faction -= "carp" //:(

/datum/action/slipstream
	name = "Slipstream"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "neckchop"
	
/datum/action/slipstream/Click()
	var/mob/living/carbon/human/A = owner
	A.toggleslipstream

/datum/action/slipstream/proc/toggleslipstream()
	active = !active
	if(active(FALSE))
		active = TRUE
		A.apply_status_effect(/datum/status_effect/slipstream)
		A.visible_message("<span class='danger'>[A] assumes a more streamlined posture!", "<b><i>You active the Slipstream.</i></b>")
	if(active(TRUE))
		active = FALSE
		A.remove_status_effect(/datum/status_effect/slipstream)
		A.visible_message("<span class='danger'>[A] assumes a neutral posture!", "<b><i>You deactive the Slipstream.</i></b>")
	return

/mob/living/carbon/human/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")

	to_chat(usr, "<span class='notice'>Gnashing Teeth</span>: Harm Harm. Gathering moment of punches means that every second punch deals additional damage, with a chance of even more damage.")
	to_chat(usr, "<span class='notice'>Crashing Wave Kick</span>: Harm Disarm. Launch people brutally across rooms, and away from you.")
	to_chat(usr, "<span class='notice'>Keelhaul</span>: Harm Grab. With a powerful kick, send opponents face first into the floor, knocking them down and disarming them of weapons. On opponents on the floor, this deals considerable stamina damage and disarms.")
	to_chat(usr, "<span class='notice'>Slipstream</span>: Move more quickly into combat, gaining additional movement speed. This is obvious to anyone who can see you, however.")
	to_chat(usr, "<span class='notice'>Roused Anger</span>: While on low health, you unleash your latent inner strength to continue fighting beyond the limitations of your failing body, removing damage slowdown and becoming more resistant to disabling effects while close to death.")
	
	to_chat(usr, "<span class='notice'>In addition, your body has become incredibly durable to most forms of attack. Weapons cannot readily pierce your hardened skin, and you are highly resistant to stuns and stamina damage, and quickly recover from stamina damage. However, you are not invincible, and sustained damage will take it's toll.")

/obj/item/twohanded/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 10
	force_wielded = 24
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_chance = 50

/obj/item/twohanded/bostaff/update_icon_state()
	icon_state = "bostaff[wielded]"

/obj/item/twohanded/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class='warning'>You club yourself over the head with [src].</span>")
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
		to_chat(user, "<span class='warning'>It would be dishonorable to attack a foe while they cannot retaliate.</span>")
		return
	if(user.a_intent == INTENT_DISARM)
		if(!wielded)
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("club", "smack", "broadside", "beat", "slam")
		H.visible_message("<span class='warning'>[user] [pick(fluffmessages)]s [H] with [src]!</span>", \
						"<span class='userdanger'>[user] [pick(fluffmessages)]s you with [src]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, user)
		to_chat(user, "<span class='danger'>You [pick(fluffmessages)] [H] with [src]!</span>")
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, TRUE, -1)
		H.adjustStaminaLoss(rand(13,20))
		if(prob(10))
			H.visible_message("<span class='warning'>[H] collapses!</span>", \
							"<span class='userdanger'>Your legs give out!</span>")
			H.Paralyze(80)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message("<span class='warning'>[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!</span>", \
								"<span class='userdanger'>You're knocked unconscious by [user]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, user)
				to_chat(user, "<span class='danger'>You deliver a heavy hit to [H]'s head, knocking [H.p_them()] out cold!</span>")
				H.SetSleeping(600)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/twohanded/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		return ..()
	return FALSE
