/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING
	pacifist_style = TRUE

/datum/martial_art/boxing/disarm_act(mob/living/attacker, mob/living/defender)
	jab(attacker, defender)
	return TRUE

/datum/martial_art/boxing/grab_act(mob/living/attacker, mob/living/defender)
	to_chat(attacker, span_warning("Can't grab while boxing!"))
	return TRUE

/datum/martial_art/boxing/harm_act(mob/living/attacker, mob/living/defender)
	jab(attacker, defender)
	return TRUE

/datum/martial_art/boxing/proc/jab(mob/living/attacker, mob/living/defender)
	var/mob/living/carbon/human/attacker_human = attacker
	var/obj/item/bodypart/arm/active_arm = attacker_human.get_active_hand()
	var/lower_force = active_arm.unarmed_damage_low
	var/upper_force = active_arm.unarmed_damage_high
	var/base_unarmed_effectiveness = active_arm.unarmed_effectiveness
	var/attack_sound = active_arm.unarmed_attack_sound

	var/obj/item/organ/internal/cyberimp/chest/spine/potential_spine = attacker_human.get_organ_slot(ORGAN_SLOT_SPINE)
	if(potential_spine)
		lower_force *= potential_spine.added_lower_unarmed_force_multiplier
		upper_force *= potential_spine.added_upper_unarmed_force_multiplier
		base_unarmed_effectiveness += potential_spine.added_unarmed_effectiveness
		if(potential_spine.attack_sound_alternative)
			attack_sound = potential_spine.attack_sound_alternative

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(lower_force, upper_force)

	if(!lower_force)
		playsound(defender.loc, active_arm.unarmed_miss_sound, 25, TRUE, -1)
		defender.visible_message(span_warning("[attacker]'s [atk_verb] misses [defender]!"), \
						span_danger("You avoid [attacker]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_warning("Your [atk_verb] misses [defender]!"))
		log_combat(attacker, defender, "attempted to hit", atk_verb)
		return FALSE

	if(damage == upper_force) //lucky you, you discombobulated them
		atk_verb = "discombobulat" //this isn't a spelling mistake, honest
		defender.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH, 10 SECONDS)

	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	var/armor_block = defender.run_armor_check(affecting, MELEE, armour_penetration = base_unarmed_effectiveness)

	playsound(defender.loc, attack_sound, 25, TRUE, -1)

	defender.visible_message(span_danger("[attacker] [atk_verb]ed [defender]!"), \
					span_userdanger("You're [atk_verb]ed by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You [atk_verb]ed [defender]!"))

	defender.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(attacker, defender, "punched (boxing) ")
	if(defender.getStaminaLoss() > 50 && istype(defender.mind?.martial_art, /datum/martial_art/boxing))
		var/final_knockout_probability = defender.getStaminaLoss() + rand(-25,5) + base_unarmed_effectiveness
		if((defender.stat != DEAD) && prob(final_knockout_probability))
			defender.visible_message(span_danger("[attacker] knocks [defender] out with a haymaker!"), \
							span_userdanger("You're knocked unconscious by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
			to_chat(attacker, span_danger("You knock [defender] out with a haymaker!"))
			defender.apply_effect(20 SECONDS,EFFECT_KNOCKDOWN, armor_block)
			defender.SetSleeping(10 SECONDS)
			log_combat(attacker, defender, "knocked out (boxing) ")
	return TRUE

/datum/martial_art/boxing/can_use(mob/living/owner)
	if(!ishuman(owner))
		return FALSE
	return ..()

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/extendohand_l, /datum/crafting_recipe/extendohand_r)

	AddComponent(
		/datum/component/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	..()
	// boxing requires human
	if(!ishuman(user))
		return
	if(slot & ITEM_SLOT_GLOVES)
		var/mob/living/student = user
		style.teach(student, 1)

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/owner = user
	style.remove(owner)
