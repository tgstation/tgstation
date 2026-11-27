/datum/martial_art/mushpunch
	name = "Mushroom Punch"
	id = MARTIALART_MUSHPUNCH

/datum/martial_art/mushpunch/harm_act(mob/living/attacker, mob/living/defender)
	INVOKE_ASYNC(src, PROC_REF(charge_up_attack), attacker, defender)
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/mushpunch/proc/charge_up_attack(mob/living/attacker, mob/living/defender)

	to_chat(attacker, span_spiderbroodmother("You begin to wind up an attack..."))
	if(!do_after(attacker, 2.5 SECONDS, defender))
		to_chat(attacker, span_spiderbroodmother("<b>Your attack was interrupted!</b>"))
		return

	var/final_damage = rand(15, 30)
	var/atk_verb = pick("punch", "smash", "crack")
	if(defender.check_block(attacker, final_damage, "[attacker]'s [atk_verb]", UNARMED_ATTACK))
		return

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	combat_message(
		attacker = attacker,
		defender = defender,
		to_attacker = "You [atk_verb] [defender] with such inhuman strength that it sends [defender.p_them()] flying backwards!",
		to_defender = "[attacker] [PRESENT_TENSE(atk_verb)] you with such inhuman strength that it sends you flying backwards!",
		to_blind_attacker = "You [atk_verb] someone with such inhuman strength that it sends them flying backwards!",
		to_blind_defender = "Something [PRESENT_TENSE(atk_verb)] you with such inhuman strength that it sends you flying backwards!",
		to_viewers = "[attacker] [PRESENT_TENSE(atk_verb)] [defender] with such inhuman strength that it sends [defender.p_them()] flying backwards!",
		to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
		dangerous = TRUE,
	)
	defender.apply_damage(final_damage, attacker.get_attack_type())
	playsound(defender, 'sound/effects/meteorimpact.ogg', 25, TRUE, -1)
	var/throwtarget = get_edge_target_turf(attacker, get_dir(attacker, get_step_away(defender, attacker)))
	defender.throw_at(throwtarget, 4, 2, attacker)//So stuff gets tossed around at the same time.
	defender.Paralyze(2 SECONDS)
	log_combat(attacker, defender, "[atk_verb] (Mushroom Punch)")

/obj/item/mushpunch
	name = "odd mushroom"
	desc = "<I>Sapienza Ophioglossoides</I>:An odd mushroom from the flesh of a mushroom person. \
		It has apparently retained some innate power of its owner, as it quivers with barely-contained POWER!"
	icon = 'icons/obj/service/hydroponics/seeds.dmi'
	icon_state = "mycelium-angel"

/obj/item/mushpunch/attack_self(mob/living/user)
	if(!istype(user))
		return
	to_chat(user, span_spiderbroodmother("You devour [src], \
		and a confluence of skill and power from the mushroom enhances your punches! \
		You do need a short moment to charge these powerful punches."))
	var/datum/martial_art/mushpunch/mush = new(user)
	mush.teach(user)
	visible_message(
		span_warning("[user] devours [src]."),
		span_notice("You devour [src]."),
	)

	qdel(src)
