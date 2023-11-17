/**
 * # The path of VOID.
 *
 * Goes as follows:
 *
 * Glimmer of Winter
 * Grasp of Void
 * Aristocrat's Way
 * > Sidepaths:
 *   Void Cloak
 *   Shattered Ritual
 *
 * Mark of Void
 * Ritual of Knowledge
 * Cone of Cold
 * Void Phase
 * > Sidepaths:
 *   Carving Knife
 *   Blood Siphon
 *
 * Seeking blade
 * Void Pull
 * > Sidepaths:
 *   Cleave
 *   Maid in the Mirror
 *
 * Waltz at the End of Time
 */
/datum/heretic_knowledge/limited_amount/starting/base_void
	name = "Glimmer of Winter"
	desc = "Opens up the Path of Void to you. \
		Allows you to transmute a knife in sub-zero temperatures into a Void Blade. \
		You can only create two at a time."
	gain_text = "I feel a shimmer in the air, the air around me gets colder. \
		I start to realize the emptiness of existence. Something's watching me."
	next_knowledge = list(/datum/heretic_knowledge/void_grasp)
	required_atoms = list(/obj/item/knife = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	route = PATH_VOID

/datum/heretic_knowledge/limited_amount/starting/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "ritual failed, invalid location!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "ritual failed, not cold enough!")
		return FALSE

	return ..()

/datum/heretic_knowledge/void_grasp
	name = "Grasp of Void"
	desc = "Your Mansus Grasp will temporarily mute and chill the victim."
	gain_text = "I saw the cold watcher who observes me. The chill mounts within me. \
		They are quiet. This isn't the end of the mystery."
	next_knowledge = list(/datum/heretic_knowledge/cold_snap)
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/void_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/void_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/void_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.adjust_silence(10 SECONDS)
	carbon_target.apply_status_effect(/datum/status_effect/void_chill)

/datum/heretic_knowledge/cold_snap
	name = "Aristocrat's Way"
	desc = "Grants you immunity to cold temperatures, and removes your need to breathe. \
		You can still take damage due to a lack of pressure."
	gain_text = "I found a thread of cold breath. It lead me to a strange shrine, all made of crystals. \
		Translucent and white, a depiction of a nobleman stood before me."
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/mark/void_mark,
		/datum/heretic_knowledge/void_cloak,
		/datum/heretic_knowledge/limited_amount/risen_corpse,
	)
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/cold_snap/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	user.add_traits(list(TRAIT_NOBREATH, TRAIT_RESISTCOLD), type)

/datum/heretic_knowledge/cold_snap/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	user.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_NOBREATH), type)

/datum/heretic_knowledge/mark/void_mark
	name = "Mark of Void"
	desc = "Your Mansus Grasp now applies the Mark of Void. The mark is triggered from an attack with your Void Blade. \
		When triggered, further silences the victim and swiftly lowers the temperature of their body and the air around them."
	gain_text = "A gust of wind? A shimmer in the air? The presence is overwhelming, \
		my senses began to betray me. My mind is my own enemy."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/void)
	route = PATH_VOID
	mark_type = /datum/status_effect/eldritch/void

/datum/heretic_knowledge/knowledge_ritual/void
	next_knowledge = list(/datum/heretic_knowledge/spell/void_cone)
	route = PATH_VOID

/datum/heretic_knowledge/spell/void_cone
	name = "Void Blast"
	desc = "Grants you Void Blast, a spell that shoots out a freezing blast in a cone in front of you, \
		freezing the ground and any victims within."
	gain_text = "Every door I open racks my body. I am afraid of what is behind them. Someone is expecting me, \
		and my legs start to drag. Is that... snow?"
	next_knowledge = list(/datum/heretic_knowledge/spell/void_phase)
	spell_to_add = /datum/action/cooldown/spell/cone/staggered/cone_of_cold/void
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/spell/void_phase
	name = "Void Phase"
	desc = "Grants you Void Phase, a long range targeted teleport spell. \
		Additionally causes damage to heathens around your original and target destination."
	gain_text = "The entity calls themself the Aristocrat. They effortlessly walk through air like \
		nothing - leaving a harsh, cold breeze in their wake. They disappear, and I am left in the blizzard."
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/blade_upgrade/void,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/spell/blood_siphon,
		/datum/heretic_knowledge/rune_carver,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/void_phase
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/blade_upgrade/void
	name = "Seeking Blade"
	desc = "You can now attack distant marked targets with your Void Blade, teleporting directly next to them."
	gain_text = "Fleeting memories, fleeting feet. I mark my way with frozen blood upon the snow. Covered and forgotten."
	next_knowledge = list(/datum/heretic_knowledge/spell/void_pull)
	route = PATH_VOID

/datum/heretic_knowledge/blade_upgrade/void/do_ranged_effects(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!target.has_status_effect(/datum/status_effect/eldritch))
		return

	var/dir = angle2dir(dir2angle(get_dir(user, target)) + 180)
	user.forceMove(get_step(target, dir))

	INVOKE_ASYNC(src, PROC_REF(follow_up_attack), user, target, blade)

/datum/heretic_knowledge/blade_upgrade/void/proc/follow_up_attack(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	blade.melee_attack_chain(user, target)

/datum/heretic_knowledge/spell/void_pull
	name = "Void Pull"
	desc = "Grants you Void Pull, a spell that pulls all nearby heathens towards you, stunning them briefly."
	gain_text = "All is fleeting, but what else stays? I'm close to ending what was started. \
		The Aristocrat reveals themselves to me again. They tell me I am late. Their pull is immense, I cannot turn back."
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/spell/cleave,
		/datum/heretic_knowledge/summon/maid_in_mirror,
	)
	spell_to_add = /datum/action/cooldown/spell/aoe/void_pull
	cost = 1
	route = PATH_VOID
