#define GOLIATH_ORGAN_COLOR "#875652"
#define GOLIATH_SCLERA_COLOR "#ac0f32"
#define GOLIATH_PUPIL_COLOR COLOR_RED
#define GOLIATH_COLORS GOLIATH_ORGAN_COLOR + GOLIATH_SCLERA_COLOR + GOLIATH_PUPIL_COLOR

///bonus of the goliath: you can swim through space!
/datum/status_effect/organ_set_bonus/goliath
	id = "organ_set_bonus_goliath"
	organs_needed = 4
	bonus_activate_text = span_notice("goliath DNA is deeply infused with you! You can now endure walking on lava!")
	bonus_deactivate_text = span_notice("You feel your muscle mass shrink and the tendrils around your skin wither. Your Goliath DNA is mostly gone and so is your ability to survive lava.")
	bonus_traits = list(TRAIT_LAVA_IMMUNE)

///goliath eyes, simple night vision
/obj/item/organ/eyes/night_vision/goliath
	name = "goliath eyes"
	desc = "goliath DNA infused into what was once some normal eyes."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "eyes"
	iris_overlays = FALSE
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

	eye_color_left = COLOR_RED
	eye_color_right = COLOR_RED

	low_light_cutoff = list(15, 0, 8)
	medium_light_cutoff = list(35, 15, 25)
	high_light_cutoff = list(50, 10, 40)
	organ_traits = list(TRAIT_UNNATURAL_RED_GLOWY_EYES)

/obj/item/organ/eyes/night_vision/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "%PRONOUN_Their eyes are blood red and stone-like.", BODY_ZONE_PRECISE_EYES)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

///goliath lungs! You can breathe lavaland air mix but can't breath pure O2 from a tank anymore.
/obj/item/organ/lungs/lavaland/goliath
	name = "mutated goliath-lungs"
	desc = "goliath DNA infused into what was once some normal lungs."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "lungs"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

/obj/item/organ/lungs/lavaland/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "%PRONOUN_Their back is covered in small tendrils.", BODY_ZONE_CHEST)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

///goliath brain. you can't use gloves but one of your arms becomes a tendril hammer that can be used to mine!
/obj/item/organ/brain/goliath
	name = "mutated goliath-brain"
	desc = "goliath DNA infused into what was once a normal brain."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "brain"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS
	can_smoothen_out = FALSE

	var/obj/item/goliath_infuser_hammer/hammer

/obj/item/organ/brain/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "%PRONOUN_Their arm is just a mass of plate and tendrils.", BODY_ZONE_CHEST)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)

/obj/item/organ/brain/goliath/on_mob_insert(mob/living/carbon/brain_owner)
	. = ..()
	if(!ishuman(brain_owner))
		return
	var/mob/living/carbon/human/human_receiver = brain_owner
	if(!human_receiver.can_mutate())
		return
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(brain_owner, rec_species.no_equip_flags | ITEM_SLOT_GLOVES)
	hammer = new/obj/item/goliath_infuser_hammer
	brain_owner.put_in_hands(hammer)

/obj/item/organ/brain/goliath/on_mob_remove(mob/living/carbon/brain_owner)
	. = ..()
	UnregisterSignal(brain_owner)
	if(!ishuman(brain_owner))
		return
	var/mob/living/carbon/human/human_receiver = brain_owner
	if(!human_receiver.can_mutate())
		return
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(brain_owner, initial(rec_species.no_equip_flags))
	if(hammer)
		brain_owner.visible_message(span_warning("\The [hammer] disintegrates!"))
		QDEL_NULL(hammer)

/obj/item/goliath_infuser_hammer
	name = "tendril hammer"
	desc = "A mass of plates held by tendrils has replaced an arm."
	icon = 'icons/obj/weapons/goliath_hammer.dmi'
	icon_state = "goliath_hammer"
	inhand_icon_state = "goliath_hammer"
	icon_angle = -90
	lefthand_file = 'icons/mob/inhands/weapons/goliath_hammer_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/goliath_hammer_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	attack_verb_continuous = list("smashes", "bashes", "hammers", "crunches", "punches")
	attack_verb_simple = list("smash", "bash", "hammer", "crunch")
	hitsound = 'sound/effects/bamf.ogg'
	tool_behaviour = TOOL_MINING
	toolspeed = 0.1
	/// Amount of damage we deal to the mining and boss factions.
	var/mining_bonus_force = 80
	/// Our cooldown declare for our special knockback hit
	COOLDOWN_DECLARE(tendril_hammer_cd)

/obj/item/goliath_infuser_hammer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/goliath_infuser_hammer/examine(mob/user)
	. = ..()
	. += "You can use your tendril hammer arm to deliver a devastating blow against mining fauna, but only once every two seconds."

/obj/item/goliath_infuser_hammer/attack(mob/living/target, mob/living/carbon/human/user, click_parameters)
	. = ..()

	//If we're on cooldown, we'll do a normal attack.
	if(!COOLDOWN_FINISHED(src, tendril_hammer_cd))
		return

	//do a normal attack if our target isn't living, since we're gonna define them after this.
	if(!isliving(target))
		return

	var/mob/living/fresh_pancake = target

	// Check for nemesis factions on the target.
	if(!(FACTION_MINING in fresh_pancake.faction) && !(FACTION_BOSS in fresh_pancake.faction))
		// Target is not a nemesis, so attack normally.
		return

	// Apply nemesis-specific effects.
	nemesis_effects(user, fresh_pancake)

	// Target is a nemesis, and so now we do the extra big damage and go on cooldown
	fresh_pancake.apply_damage(mining_bonus_force, damtype) //smush
	COOLDOWN_START(src, tendril_hammer_cd, 2 SECONDS)

/obj/item/goliath_infuser_hammer/proc/nemesis_effects(mob/living/user, mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite))
		return
	///we obtain the relative direction from the bat itself to the target
	if(!QDELETED(target))
		target.throw_at(get_edge_target_turf(target, get_cardinal_dir(src, target)), rand(1, 2), prob(60) ? 1 : 4, user)

/// goliath heart gives you the ability to survive ash storms.
/obj/item/organ/heart/goliath
	name = "mutated goliath-heart"
	desc = "goliath DNA infused into what was once a normal heart."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = GOLIATH_COLORS

	organ_traits = list(TRAIT_ASHSTORM_IMMUNE)

/obj/item/organ/heart/goliath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "%PRONOUN_Their skin has visible hard plates growing from within.", BODY_ZONE_CHEST)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/goliath)
	AddElement(/datum/element/update_icon_blocker)

#undef GOLIATH_ORGAN_COLOR
#undef GOLIATH_SCLERA_COLOR
#undef GOLIATH_PUPIL_COLOR
#undef GOLIATH_COLORS
