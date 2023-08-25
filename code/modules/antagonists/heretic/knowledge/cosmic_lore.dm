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
 *   Rusted Ritual
 *
 * Creators's Gift
 */
/datum/heretic_knowledge/limited_amount/starting/base_cosmic
	name = "Eternal Gate"
	desc = "Opens up the Path of Cosmos to you. \
		Allows you to transmute a sheet of plasma and a knife into an Cosmic Blade. \
		You can only create two at a time."
	gain_text = "It looked at the stars to guide himself."
	next_knowledge = list(/datum/heretic_knowledge/cosmic_grasp)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/cosmic)
	route = PATH_COSMIC

/datum/heretic_knowledge/cosmic_grasp
	name = "Grasp of Cosmos"
	desc = "Your Mansus Grasp will give people a star mark (cosmic ring) and create a cosmic field where you stand."
	gain_text = "The more he looked the more everything made sense. \
		The stars traced out the path forward to his home."
	next_knowledge = list(/datum/heretic_knowledge/spell/cosmic_runes)
	cost = 1
	route = PATH_COSMIC

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
	desc = "Grants you Cosmic Runes, a spell that creates two runes linked with eachother for easy teleportation. \
		Only the entity activating the rune will get transported, and it can be used by anyone without a star mark. \
		However, people with a star mark will get transported along with another person using the rune."
	gain_text = "When day came, the Sleeper got lost. \
		The sun outshone the stars, so he lost his guide."
	next_knowledge = list(
		/datum/heretic_knowledge/mark/cosmic_mark,
		/datum/heretic_knowledge/codex_cicatrix,
		/datum/heretic_knowledge/essence,
		/datum/heretic_knowledge/summon/fire_shark,
	)
	spell_to_add = /datum/action/cooldown/spell/cosmic_rune
	cost = 1
	route = PATH_COSMIC

/datum/heretic_knowledge/mark/cosmic_mark
	name = "Mark of Cosmos"
	desc = "Your Mansus Grasp now applies the Mark of Cosmos. The mark is triggered from an attack with your Cosmic Blade. \
		When triggered, the victim is returned to the location where the mark was originally applied to them. \
		They will then be paralyzed for 2 seconds."
	gain_text = "As the guide was lost he found a new. The energy increased as the gaze he threw. \
		He didn't know, but with focus, the Sleepers energy began to flow."
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
		will be forced to sleep for 4 seconds. When the victim is hit it also creates a beam that \
		deals a bit of fire damage and damages the cells. \
		The beam lasts a minute, until the beam is obstructed or until a new target has been found."
	gain_text = "He dreamed to know how the matter travelled from star to star. \
		He lost interest in wanting to find out."
	next_knowledge = list(/datum/heretic_knowledge/spell/star_blast)
	spell_to_add = /datum/action/cooldown/spell/touch/star_touch
	cost = 1
	route = PATH_COSMIC

/datum/heretic_knowledge/spell/star_blast
	name = "Star Blast"
	desc = "Fires a projectile that moves very slowly and creates cosmic fields on impact. \
		Anyone hit by the projectile will recieve burn damage, a knockdown, and give people in a three tile range a star mark."
	gain_text = "He didn't try, yet felt the call of the night's Creator."
	next_knowledge = list(
		/datum/heretic_knowledge/blade_upgrade/cosmic,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/spell/space_phase,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/star_blast
	cost = 1
	route = PATH_COSMIC

/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Cosmic Blade"
	desc = "Your blade now deals damage to people's cells through cosmic radiation. \
		Your attacks will chain bonus damage to up to two previous victims. \
		The combo is reset after two seconds without making an attack, \
		or if you attack someone already marked. If you combo more than four attacks you will recieve, \
		a cosmic trail and increase your combo timer up to ten seconds."
	gain_text = "As he ascended to be a watcher, he needed to gather knowledge. \
		He started to draw it at his home."
	next_knowledge = list(/datum/heretic_knowledge/spell/cosmic_expansion)
	route = PATH_COSMIC
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
	if(source == target)
		return
	if(combo_timer)
		deltimer(combo_timer)
	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = second_target?.resolve()
	var/mob/living/third_target_resolved = third_target?.resolve()
	target.adjustFireLoss(4)
	target.adjustCloneLoss(2)
	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return
	if(target.mind && target.stat != DEAD)
		combo_counter += 1
	if(second_target_resolved)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
		playsound(get_turf(second_target_resolved), 'sound/magic/cosmic_energy.ogg', 25, FALSE)
		second_target_resolved.adjustFireLoss(10)
		second_target_resolved.adjustCloneLoss(6)
		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
			third_target_resolved.adjustFireLoss(20)
			third_target_resolved.adjustCloneLoss(12)
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
	gain_text = "He was well known, so he had a lot of drawing to do to gather as much of the things he forgot."
	next_knowledge = list(
		/datum/heretic_knowledge/ultimate/cosmic_final,
		/datum/heretic_knowledge/eldritch_coin,
		/datum/heretic_knowledge/summon/rusty,
	)
	spell_to_add = /datum/action/cooldown/spell/conjure/cosmic_expansion
	cost = 1
	route = PATH_COSMIC

/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Creators's Gift"
	desc = "The ascension ritual of the Path of Cosmos. \
		Bring 3 corpses with bluespace dust in their body to a transmutation rune to complete the ritual. \
		When completed, you become the owner of a Star Gazer. \
		You will be able to command the Star Gazer with Alt+click. \
		You can also give it commands through speech. \
		The Star Gazer is a strong ally who can even break down reinforced walls. \
		The Star Gazer has an aura that will heal you and damage opponents. \
		Star Touch can now teleport you to the Star Gazer when activated in your hand."
	gain_text = "The past is gone, the Star Gazer became a vessel to watch over the universe. \
		The Creator made this his path and he forgot his purpose. \
		THE TIME IS NOW, WITNESS MY ASCENSION, THE STAR GAZER HAS GAINED PURPOSE ONCE MORE!"
	route = PATH_COSMIC
	/// A static list of command we can use with our mob.
	var/static/list/star_gazer_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targetting/attack/star_gazer
	)

/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return sacrifice.has_reagent(/datum/reagent/bluespace)

/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] A Star Gazer has arrived into the station, [user.real_name] has ascended! This station is the domain of the Cosmos! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	var/mob/living/basic/heretic_summon/star_gazer/star_gazer_mob = new /mob/living/basic/heretic_summon/star_gazer(loc)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	user.AddElement(/datum/element/death_linked, star_gazer_mob)
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

	user.client?.give_award(/datum/award/achievement/misc/cosmic_ascension, user)
