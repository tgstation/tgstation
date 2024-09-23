/**
 * # The path of Cosmos.
 *
 * Goes as follows:
 *
 * Eternal Gate
 * Grasp of Cosmos
 * Cosmic Runes
 * > Sidepaths:
 *   Priest's Ritual
 *   Scorching Shark
 *
 * Mark of Cosmos
 * Ritual of Knowledge
 * Star Touch
 * Star Blast
 * > Sidepaths:
 *   Curse of Corrosion
 *   Space Phase
 *
 * Cosmic Blade
 * Cosmic Expansion
 * > Sidepaths:
 *   Eldritch Coin
 *
 * Creators's Gift
 */
/datum/heretic_knowledge/limited_amount/starting/base_cosmic
	name = "Eternal Gate"
	desc = "Opens up the Path of Cosmos to you. \
		Allows you to transmute a sheet of plasma and a knife into an Cosmic Blade. \
		You can only create two at a time."
	gain_text = "A nebula appeared in the sky, its infernal birth shone upon me. This was the start of a great transcendence."
	next_knowledge = list(/datum/heretic_knowledge/cosmic_grasp)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/cosmic)
	route = PATH_COSMIC
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "cosmic_blade"

/datum/heretic_knowledge/cosmic_grasp
	name = "Grasp of Cosmos"
	desc = "Your Mansus Grasp will give people a star mark (cosmic ring) and create a cosmic field where you stand. \
		People with a star mark can not pass cosmic fields."
	gain_text = "Some stars dimmed, others' magnitude increased. \
		With newfound strength I could channel the nebula's power into myself."
	next_knowledge = list(/datum/heretic_knowledge/spell/cosmic_runes)
	cost = 1
	route = PATH_COSMIC
	depth = 3
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_cosmos"

/datum/heretic_knowledge/cosmic_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/cosmic_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/// Aplies the effect of the mansus grasp when it hits a target.
/datum/heretic_knowledge/cosmic_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	to_chat(target, span_danger("A cosmic ring appeared above your head!"))
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	new /obj/effect/forcefield/cosmic_field(get_turf(source))

/datum/heretic_knowledge/spell/cosmic_runes
	name = "Cosmic Runes"
	desc = "Grants you Cosmic Runes, a spell that creates two runes linked with each other for easy teleportation. \
		Only the entity activating the rune will get transported, and it can be used by anyone without a star mark. \
		However, people with a star mark will get transported along with another person using the rune."
	gain_text = "The distant stars crept into my dreams, roaring and screaming without reason. \
		I spoke, and heard my own words echoed back."
	next_knowledge = list(
		/datum/heretic_knowledge/summon/fire_shark,
		/datum/heretic_knowledge/mark/cosmic_mark,
		/datum/heretic_knowledge/essence,
	)
	spell_to_add = /datum/action/cooldown/spell/cosmic_rune
	cost = 1
	route = PATH_COSMIC
	depth = 4

/datum/heretic_knowledge/mark/cosmic_mark
	name = "Mark of Cosmos"
	desc = "Your Mansus Grasp now applies the Mark of Cosmos. The mark is triggered from an attack with your Cosmic Blade. \
		When triggered, the victim is returned to the location where the mark was originally applied to them, \
		leaving a cosmic field in their place. \
		They will then be paralyzed for 2 seconds."
	gain_text = "The Beast now whispered to me occasionally, only small tidbits of their circumstances. \
		I can help them, I have to help them."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/cosmic)
	route = PATH_COSMIC
	mark_type = /datum/status_effect/eldritch/cosmic

/datum/heretic_knowledge/knowledge_ritual/cosmic
	next_knowledge = list(/datum/heretic_knowledge/spell/star_touch)
	route = PATH_COSMIC

/datum/heretic_knowledge/spell/star_touch
	name = "Star Touch"
	desc = "Grants you Star Touch, a spell which places a star mark upon your target \
		and creates a cosmic field at your feet and to the turfs next to you. Targets which already have a star mark \
		will be forced to sleep for 4 seconds. When the victim is hit it also creates a beam that burns them. \
		The beam lasts a minute, until the beam is obstructed or until a new target has been found."
	gain_text = "After waking in a cold sweat I felt a palm on my scalp, a sigil burned onto me. \
		My veins now emitted a strange purple glow, the Beast knows I will surpass its expectations."
	next_knowledge = list(/datum/heretic_knowledge/spell/star_blast)
	spell_to_add = /datum/action/cooldown/spell/touch/star_touch
	cost = 1
	route = PATH_COSMIC
	depth = 7

/datum/heretic_knowledge/spell/star_blast
	name = "Star Blast"
	desc = "Fires a projectile that moves very slowly, raising a short-lived wall of cosmic fields where it goes. \
		Anyone hit by the projectile will receive burn damage, a knockdown, and give people in a three tile range a star mark."
	gain_text = "The Beast was behind me now at all times, with each sacrifice words of affirmation coursed through me."
	next_knowledge = list(
		/datum/heretic_knowledge/blade_upgrade/cosmic,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/summon/rusty,
		/datum/heretic_knowledge/spell/space_phase,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/star_blast
	cost = 1
	route = PATH_COSMIC
	depth = 8

/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Cosmic Blade"
	desc = "Your blade now deals damage to people's organs through cosmic radiation. \
		Your attacks will chain bonus damage to up to two previous victims. \
		The combo is reset after two seconds without making an attack, \
		or if you attack someone already marked. If you combo more than four attacks you will receive, \
		a cosmic trail and increase your combo timer up to ten seconds."
	gain_text = "The Beast took my blades in their hand, I kneeled and felt a sharp pain. \
		The blades now glistened with fragmented power. I fell to the ground and wept at the beast's feet."
	next_knowledge = list(/datum/heretic_knowledge/spell/cosmic_expansion)
	route = PATH_COSMIC
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_cosmos"
	/// Storage for the second target.
	var/datum/weakref/second_target
	/// Storage for the third target.
	var/datum/weakref/third_target
	/// When this timer completes we reset our combo.
	var/combo_timer
	/// The active duration of the combo.
	var/combo_duration = 3 SECONDS
	/// The duration of a combo when it starts.
	var/combo_duration_amount = 3 SECONDS
	/// The maximum duration of the combo.
	var/max_combo_duration = 10 SECONDS
	/// The amount the combo duration increases.
	var/increase_amount = 0.5 SECONDS
	/// The hits we have on a mob with a mind.
	var/combo_counter = 0

/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	var/static/list/valid_organ_slots = list(
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_BRAIN
	)
	if(source == target)
		return
	if(combo_timer)
		deltimer(combo_timer)
	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = second_target?.resolve()
	var/mob/living/third_target_resolved = third_target?.resolve()
	var/need_mob_update = FALSE
	need_mob_update += target.adjustFireLoss(5, updating_health = FALSE)
	need_mob_update += target.adjustOrganLoss(pick(valid_organ_slots), 8)
	if(need_mob_update)
		target.updatehealth()
	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return
	if(target.mind && target.stat != DEAD)
		combo_counter += 1
	if(second_target_resolved)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
		playsound(get_turf(second_target_resolved), 'sound/effects/magic/cosmic_energy.ogg', 25, FALSE)
		need_mob_update = FALSE
		need_mob_update += second_target_resolved.adjustFireLoss(14, updating_health = FALSE)
		need_mob_update += second_target_resolved.adjustOrganLoss(pick(valid_organ_slots), 12)
		if(need_mob_update)
			second_target_resolved.updatehealth()
		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'sound/effects/magic/cosmic_energy.ogg', 50, FALSE)
			need_mob_update = FALSE
			need_mob_update += third_target_resolved.adjustFireLoss(28, updating_health = FALSE)
			need_mob_update += third_target_resolved.adjustOrganLoss(pick(valid_organ_slots), 14)
			if(need_mob_update)
				third_target_resolved.updatehealth()
			if(combo_counter > 3)
				target.apply_status_effect(/datum/status_effect/star_mark, source)
				if(target.mind && target.stat != DEAD)
					increase_combo_duration()
					if(combo_counter == 4)
						source.AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
		third_target = second_target
	second_target = WEAKREF(target)

/// Resets the combo.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/reset_combo(mob/living/source)
	second_target = null
	third_target = null
	if(combo_counter > 3)
		source.RemoveElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
	combo_duration = combo_duration_amount
	combo_counter = 0
	new /obj/effect/temp_visual/cosmic_cloud(get_turf(source))
	if(combo_timer)
		deltimer(combo_timer)

/// Increases the combo duration.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/increase_combo_duration()
	if(combo_duration < max_combo_duration)
		combo_duration += increase_amount

/datum/heretic_knowledge/spell/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "Grants you Cosmic Expansion, a spell that creates a 3x3 area of cosmic fields around you. \
		Nearby beings will also receive a star mark."
	gain_text = "The ground now shook beneath me. The Beast inhabited me, and their voice was intoxicating."
	next_knowledge = list(
		/datum/heretic_knowledge/ultimate/cosmic_final,
		/datum/heretic_knowledge/eldritch_coin,
	)
	spell_to_add = /datum/action/cooldown/spell/conjure/cosmic_expansion
	cost = 1
	route = PATH_COSMIC
	depth = 10

/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Creators's Gift"
	desc = "The ascension ritual of the Path of Cosmos. \
		Bring 3 corpses with bluespace dust in their body to a transmutation rune to complete the ritual. \
		When completed, you become the owner of a Star Gazer. \
		You will be able to command the Star Gazer with Alt+click. \
		You can also give it commands through speech. \
		The Star Gazer is a strong ally who can even break down reinforced walls. \
		The Star Gazer has an aura that will heal you and damage opponents. \
		Star Touch can now teleport you to the Star Gazer when activated in your hand. \
		Your cosmic expansion spell and your blades also become greatly empowered."
	gain_text = "The Beast held out its hand, I grabbed hold and they pulled me to them. Their body was towering, but it seemed so small and feeble after all their tales compiled in my head. \
		I clung on to them, they would protect me, and I would protect it. \
		I closed my eyes with my head laid against their form. I was safe. \
		WITNESS MY ASCENSION!"
	route = PATH_COSMIC
	ascension_achievement = /datum/award/achievement/misc/cosmic_ascension
	/// A static list of command we can use with our mob.
	var/static/list/star_gazer_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack/star_gazer
	)

/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return sacrifice.has_reagent(/datum/reagent/bluespace)

/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce(
		text = "[generate_heretic_text()] A Star Gazer has arrived into the station, [user.real_name] has ascended! This station is the domain of the Cosmos! [generate_heretic_text()]",
		title = "[generate_heretic_text()]",
		sound = 'sound/music/antag/heretic/ascend_cosmic.ogg',
		color_override = "pink",
	)
	var/mob/living/basic/heretic_summon/star_gazer/star_gazer_mob = new /mob/living/basic/heretic_summon/star_gazer(loc)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	user.AddComponent(/datum/component/death_linked, star_gazer_mob)
	star_gazer_mob.AddComponent(/datum/component/obeys_commands, star_gazer_commands)
	star_gazer_mob.AddComponent(/datum/component/damage_aura, range = 7, burn_damage = 0.5, simple_damage = 0.5, immune_factions = list(FACTION_HERETIC), current_owner = user)
	star_gazer_mob.befriend(user)
	var/datum/action/cooldown/open_mob_commands/commands_action = new /datum/action/cooldown/open_mob_commands()
	commands_action.Grant(user, star_gazer_mob)
	var/datum/action/cooldown/spell/touch/star_touch/star_touch_spell = locate() in user.actions
	if(star_touch_spell)
		star_touch_spell.set_star_gazer(star_gazer_mob)
		star_touch_spell.ascended = TRUE

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/cosmic/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/cosmic)
	blade_upgrade.combo_duration = 10 SECONDS
	blade_upgrade.combo_duration_amount = 10 SECONDS
	blade_upgrade.max_combo_duration = 30 SECONDS
	blade_upgrade.increase_amount = 2 SECONDS

	var/datum/action/cooldown/spell/conjure/cosmic_expansion/cosmic_expansion_spell = locate() in user.actions
	cosmic_expansion_spell?.ascended = TRUE
