/**
 * ## Headslugs
 *
 * Player-controlled slugs that arise from a changeling ability in order to live on in an extremely limited capacity until they can find a suitable corpse to inhabit.
 */
/mob/living/basic/headslug
	name = "headslug"
	desc = "A small, slug-like creature with a large, gaping maw. It's covered in a thick, slimy mucus."
	icon_state = "headslug"
	icon_living = "headslug"
	icon_dead = "headslug_dead"
	gender = NEUTER
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	faction = list(FACTION_CREATURE)
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("squeaks")

	ai_controller = /datum/ai_controller/basic_controller/headslug

	/// Set to true once we've implanted our egg
	var/egg_lain = FALSE

/mob/living/basic/headslug/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(check_and_implant))

/mob/living/basic/headslug/Destroy()
	UnregisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET)
	return ..()

/mob/living/basic/headslug/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		if(isnull(client))
			. += span_notice("It appears to be moving around listlessly.")
		else
			. += span_warning("It's moving around intelligently!")
	if (egg_lain)
		. += span_notice("Its reproductive equipment appears to have withered.")

/// Signal Handler proc that runs on every attack and checks to see if this is a valid target for implantation. If so, it implants the egg and starts the countdown to death.
/mob/living/basic/headslug/proc/check_and_implant(mob/living/basic/attacker, atom/target)
	SIGNAL_HANDLER

	if (egg_lain || !iscarbon(target) || ismonkey(target))
		return

	var/mob/living/carbon/victim = target
	if(victim.stat != DEAD)
		return
	if(HAS_TRAIT(victim, TRAIT_XENO_HOST))
		target.balloon_alert(src, "already pregnant!") // Maybe the worst balloon alert in the codebase
		return

	if(!infect(victim))
		target.balloon_alert(src, "failed to implant egg!")
		stack_trace("[key] in [src] failed to implant egg in [victim], despite all checks suggesting it should have worked!")
		return

	egg_lain = TRUE
	to_chat(src, span_userdanger("With our egg laid, our death approaches rapidly..."))
	addtimer(CALLBACK(src, PROC_REF(death)), 10 SECONDS)

/// Simply infects the target corpse with our changeling eggs. This shouldn't fail, because all checks should have been done in check_and_implant()
/// Just to be super-duper safe to the player, we do return TRUE if all goes well and read that value in check_and_implant() to be nice to the player.
/mob/living/basic/headslug/proc/infect(mob/living/carbon/victim)
	var/obj/item/organ/internal/body_egg/changeling_egg/egg = new(victim)

	egg.origin = mind

	for(var/obj/item/organ/target in src)
		target.forceMove(egg)

	visible_message(
		span_warning("[src] plants something in [victim]'s flesh!"),
		span_danger("We inject our egg into [victim]'s body!"),
	)

	return TRUE

/// This is a bit neutered since these aren't intended to exist outside of player control, but it's a bit weird to just have these guys be completely stationary.
/// No attacking or anything like that, though. Just something so they seem alive.
/datum/ai_controller/basic_controller/headslug
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

/// Neutered version to prevent people from turning themselves into changelings with sentience potions or transformation
/mob/living/basic/headslug/beakless
	egg_lain = TRUE
