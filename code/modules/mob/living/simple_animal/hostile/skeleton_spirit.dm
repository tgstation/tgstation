/mob/living/simple_animal/hostile/skeleton_spirit
	name = "Skeleton Spirit"
	desc = "A spine and skull with a fleshy goop holding it all together."
	icon = 'icons/mob/vatgrowing.dmi'
	icon_state = "skeleton_spirit"
	icon_living = "skeleton_spirit"
	mob_biotypes = MOB_SPIRIT | MOB_UNDEAD
	turns_per_move = 10
	maxHealth = 60
	health = 60
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	see_in_dark = 3
	response_help_continuous = "fades"
	response_help_simple = "fade"
	response_harm_continuous = "counters"
	response_harm_simple = "counter"
	melee_damage_type = "burn"
	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 18
	obj_damage = 10
	attack_verb_continuous = "sweeps"
	attack_verb_simple = "sweep"
	attack_sound = "sound/creatures/mime_swing.ogg"
	del_on_death = 1
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 100
	loot = list(/obj/item/stack/sheet/bone, /obj/item/ectoplasm, /obj/effect/gibspawner/generic)
	var/obj/effect/proc_holder/spell/self/phase/phase = null

/mob/living/simple_animal/hostile/skeleton_spirit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	phase = new /obj/effect/proc_holder/spell/self/phase
	AddSpell(phase)
