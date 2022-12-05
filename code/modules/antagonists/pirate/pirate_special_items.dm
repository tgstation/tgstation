/obj/item/reagent_containers/hypospray/medipen/gore
	name = "gore autoinjector"
	desc = "A ghetto looking autoinjector filled with gore, aka dirty kronkaine. Probably shouldn't take this while in the job, but it is a super-stimulant. Don't take two at once."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/drug/kronkaine/gore = 15)
	icon_state = "maintenance"
	base_icon_state = "maintenance"
	label_examine = FALSE

//Captain's special mental recharge gear

/obj/item/clothing/suit/armor/reactive/psykerboost
	name = "reactive psykerboost armor"
	desc = "An experimental suit of armor psykers use to push their mind further. Reacts to hostiles by powering up the wearer's psychic abilities."
	cooldown_message = span_danger("The psykerboost armor's mental coils are still cooling down!")
	emp_message = span_danger("The psykerboost armor's mental coils recalibrate for a moment with a soft whine.")
	color = "#d6ad8b"

/obj/item/clothing/suit/armor/reactive/psykerboost/cooldown_activation(mob/living/carbon/human/owner)
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	return ..()

/obj/item/clothing/suit/armor/reactive/psykerboost/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], psykerboosting [owner]'s mental powers!"))
	for(var/datum/action/cooldown/spell/psychic_ability in owner.actions)
		if(psychic_ability.school == SCHOOL_PSYCHIC)
			psychic_ability.reset_spell_cooldown()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/psykerboost/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], draining [owner]'s mental powers!"))
	for(var/datum/action/cooldown/spell/psychic_ability in owner.actions)
		if(psychic_ability.school == SCHOOL_PSYCHIC)
			psychic_ability.StartCooldown()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/structure/bouncy_castle
	name = "bouncy castle"
	desc = "And if you do drugs, you go to hell before you die. Please."
	icon = 'icons/obj/bouncy_castle.dmi'
	icon_state = "bouncy_castle"
	anchored = TRUE
	density = TRUE

/obj/structure/bouncy_castle/Initialize(mapload, mob/gored)
	. = ..()
	if(gored)
		name = gored.real_name

/obj/structure/bouncy_castle/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/item/paper/crumpled/fluff/fortune_teller
	name = "scribbled note"
	default_raw_text = "<b>Remember!</b> The customers love that gumball we have as a crystal ball. \
		Even if it's completely useless to us, resist the urge to chew it."
