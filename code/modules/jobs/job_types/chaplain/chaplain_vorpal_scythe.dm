/*Vorpal Scythe, or the implant null rod that isn't as strong as other null rods up until you use it to behead someone with the special death knell attack.
If the scythe isn't empowered when you sheath it, you take a heap of damage and probably a wound!*/

#define SCYTHE_WEAK 0
#define SCYTHE_SATED 1
#define SCYTHE_EMPOWERED 2

/obj/item/organ/internal/cyberimp/arm/shard/scythe
	name = "sinister shard"
	desc = "This shard seems to be directly linked to some sinister entity. It might be your god! It also gives you a really horrible rash when you hold onto it for too long."
	items_to_create = list(/obj/item/vorpalscythe)

/obj/item/organ/internal/cyberimp/arm/shard/scythe/Insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	if(receiver.mind)
		ADD_TRAIT(receiver.mind, TRAIT_MORBID, ORGAN_TRAIT)

/obj/item/organ/internal/cyberimp/arm/shard/scythe/Retract()
	var/obj/item/vorpalscythe/scythe = active_item
	if(!scythe)
		return FALSE

	var/obj/item/bodypart/part = hand
	if(isnull(part) || scythe.empowerment >= SCYTHE_SATED)
		return ..()

	to_chat(owner, span_userdanger("[scythe] tears into you for your unworthy display of arrogance!"))
	playsound(owner, 'sound/magic/demon_attack1.ogg', 50, TRUE)
	part.receive_damage(brute = 25, wound_bonus = 10, sharpness = SHARP_EDGED)
	return ..()

/obj/item/vorpalscythe
	name = "vorpal scythe"
	desc = "Reap what you sow."
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "vorpalscythe"
	inhand_icon_state = "vorpalscythe"
	worn_icon_state = null
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_GIGANTIC
	force = 10 //a lot worse than most nullrods initially. Why did you invest so much into making it vorpal, you dork.
	armour_penetration = 50 //Very good armor penetration to make up for our abysmal force
	reach = 2 //why yes, this does have reach
	slot_flags = null
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("chops", "slices", "cuts", "reaps")
	attack_verb_simple = list("chop", "slice", "cut", "reap")
	wound_bonus = 10
	bare_wound_bonus = 15
	/*What state is our scythe in?

	If it is SCYTHE_WEAK, it will harm our reaper on being sheathed.

	if it is SCYTHE_SATED, it will be able to sheath for 4 minutes. Gained from hitting a mob or performing the death knell on mindless humans.

	If it is SCYTHE_EMPOWERED, we've performed the death knell on a human with a mind. Lets you sheath for 2 minutes and grants additional force.*/
	var/empowerment = SCYTHE_WEAK
	///Our bonus to force after we have death knelled. Lasts approximately 2 minutes.
	var/bonus_force_multiplier = 2
	///Our initial force before empowerment. For tracking on the item, and in case the item somehow gains more force for some reason before we death knelled.
	var/original_force

/obj/item/vorpalscythe/examine(mob/user)
	. = ..()
	. += span_notice("You can perform a death knell using [src] on a human with Right-Click. If they were sentient (whether currently or at some point), [src] is empowered on a successful death knell.")
	. += span_notice("[src] seems to have quite a bit of reach. You might be able to hit things from further away.")

	var/current_empowerment = empowerment
	switch(current_empowerment)
		if(SCYTHE_EMPOWERED)
			. += span_notice("[src] is empowered and humming with energy.")
		if(SCYTHE_SATED)
			. += span_notice("[src] is sated, but still demands more. Perform the death knell!")
		else
			. += span_notice("[src] is still. Anticipating the strike. Best not anger it by denying it the opportuntiy to taste blood.")

/obj/item/vorpalscythe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = "TO DUST WITH YE!! AWAY!!", \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed)), \
		effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune) \
	)
	AddComponent(
		/datum/component/butchering, \
		speed = 3 SECONDS, \
		effectiveness = 125, \
	)
	AddElement(/datum/element/bane, mob_biotypes = MOB_PLANT, damage_multiplier = 0.5, requires_combat_mode = FALSE) //less good at killing revenants, much better at killing plants

/obj/item/vorpalscythe/attack(mob/living/target, mob/living/user, params)
	if(ismonkey(target) && !target.mind) //Don't empower from hitting monkeys. Hit a corgi or something, I don't know.
		return ..()

	if(target.stat < DEAD && target != user)
		scythe_empowerment(SCYTHE_SATED)

	return ..()

//Borrows some amputation shear code, but much more specific
/obj/item/vorpalscythe/attack_secondary(mob/living/victim, mob/living/user, params)
	if(!iscarbon(victim) || user.combat_mode)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(user.zone_selected != BODY_ZONE_HEAD)
		return SECONDARY_ATTACK_CALL_NORMAL

	var/mob/living/carbon/potential_reaping = victim

	if(HAS_TRAIT(potential_reaping, TRAIT_NODISMEMBER))
		to_chat(user, span_warning("You do not think you can behead this creature..."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/head_name
	var/obj/item/bodypart/head/reaped_head

	reaped_head = potential_reaping.get_bodypart(check_zone(user.zone_selected))
	if(!reaped_head)
		to_chat(user, span_warning("There is no head to reap."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	head_name = reaped_head.name

	//We're tracking this separately from empowerment so that we can use it to determine whether or not we haunt the heads we cut off.
	var/potential_empowerment = SCYTHE_EMPOWERED

	if(!potential_reaping.mind) //We put this here juuuust in case there is something funky with ling checks
		if(ismonkey(potential_reaping))
			to_chat(user, span_warning("A pointless existence. You'll get no benefit from this death knell beyond the satisfaction of beheading this foul thing."))
			potential_empowerment = SCYTHE_WEAK
		else
			to_chat(user, span_warning("This soul is almost nonexistent. But [src] can still gain something from this sacrifice. A puppet."))
			potential_empowerment = SCYTHE_SATED

	var/death_knell_speed_mod = 1

	potential_reaping.visible_message(span_danger("[user] begins to raise [src] above [potential_reaping]'s [head_name]."), span_userdanger("[user] begins to raise [src], aiming to slice off your [head_name]!"))
	if(potential_reaping.stat >= UNCONSCIOUS || HAS_TRAIT(potential_reaping, TRAIT_INCAPACITATED)) //if the victim is incapacitated (due to paralysis, a stun, being in staminacrit, etc.), critted, unconscious, or dead, it's much easier to properly behead
		death_knell_speed_mod *= 0.5
	if(potential_reaping.stat != DEAD && potential_reaping.has_status_effect(/datum/status_effect/jitter)) //jittering will make it harder to perform the death knell, even if they're still
		death_knell_speed_mod *= 1.5 //Staminacritting someone who's jittering (from, say, a stun baton) won't give you enough time to slice their head off, but staminacritting someone who isn't jittering will
	if(empowerment == SCYTHE_EMPOWERED) //That said, if heads are already rolling, why stop here?
		death_knell_speed_mod *= 0.5
	if(ispodperson(potential_reaping) || ismonkey(potential_reaping)) //And if they're a podperson or monkey, they can just die.
		death_knell_speed_mod *= 0.5

	log_combat(user, potential_reaping, "prepared to use [src] to decapitate")

	if(do_after(user,  15 SECONDS * death_knell_speed_mod, target = potential_reaping))
		playsound(get_turf(potential_reaping), 'sound/weapons/bladeslice.ogg', 250, TRUE)
		reaped_head.dismember()
		user.visible_message(span_danger("[user] swings [src] down, slicing [potential_reaping]'s [head_name] clean off! You think [src] may have grown stronger!"), span_notice("As you perform the death knell on [potential_reaping], [src] gains power! For a time..."))
		if(potential_empowerment == SCYTHE_SATED) //We don't want actual player heads to go wandering off, but it'll be funny if a bunch of monkeyhuman heads started floating around
			reaped_head.AddComponent(/datum/component/haunted_item, \
				haunt_color = "#7be595", \
				haunt_duration = 1 MINUTES, \
				aggro_radius = null, \
				spawn_message = span_revenwarning("[reaped_head] shudders and rises up into the air in a pale green nimbus!"), \
				despawn_message = span_revenwarning("[reaped_head] falls back to the ground, stationary once more."), \
				throw_force_bonus = 0, \
				throw_force_max = 0, \
			)

		scythe_empowerment(potential_empowerment)
		log_combat(user, potential_reaping, "used [src] to decapitate")

		if(HAS_MIND_TRAIT(user, TRAIT_MORBID)) //You feel good about yourself, pal?
			user.add_mood_event("morbid_dismemberment", /datum/mood_event/morbid_dismemberment)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/vorpalscythe/proc/scythe_empowerment(potential_empowerment = SCYTHE_WEAK)
	//Determines if we are entitled to setting/resetting our timer.
	//Only reset SCYTHE_EMPOWERED with an empowerment that would grant that.
	//Only reset SCTHE_SATED if hitting at least simple mobs or nonmonkey carbons.
	var/allow_timer_set = FALSE

	if(potential_empowerment == SCYTHE_EMPOWERED)
		if(empowerment != SCYTHE_EMPOWERED) //We only empower our stats if we beheaded a human with a mind.
			original_force = force
			force *= bonus_force_multiplier
			empowerment = potential_empowerment
		allow_timer_set = TRUE
	else if(empowerment < potential_empowerment) //so we don't end up weakening our scythe somehow and creating an infinite empowerment loop, only update empowerment if it is better
		empowerment = potential_empowerment
		allow_timer_set = TRUE
	if(potential_empowerment != SCYTHE_WEAK && allow_timer_set) //And finally, if the empowerment was improved and wasn't too weak to get an empowerment, we set/reset our timer
		addtimer(CALLBACK(src, PROC_REF(scythe_empowerment_end)), (4 MINUTES / empowerment), TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/vorpalscythe/proc/scythe_empowerment_end()
	if(empowerment == SCYTHE_EMPOWERED)
		force = original_force
		original_force = null
	empowerment = SCYTHE_WEAK

/obj/item/vorpalscythe/proc/on_cult_rune_removed(obj/effect/target, mob/living/user)
	if(!istype(target, /obj/effect/rune))
		return

	var/obj/effect/rune/target_rune = target
	if(target_rune.log_when_erased)
		user.log_message("erased [target_rune.cultist_name] rune using [src]", LOG_GAME)
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_NARNAR] = TRUE

#undef SCYTHE_WEAK
#undef SCYTHE_SATED
#undef SCYTHE_EMPOWERED
