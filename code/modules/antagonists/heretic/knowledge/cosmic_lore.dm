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
	gain_text = "A nebula appeared in the sky, its infernal birth shone upon me. This was the start of a great transcendence."
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
	gain_text = "Some stars dimmed, others' magnitude increased. \
		With newfound strength I could channel the nebula's power into myself."
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
	gain_text = "The distant stars crept into my dreams, roaring and screaming without reason. \
		I spoke, and heard my own words echoed back."
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/mark/cosmic_mark,
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
		will be forced to sleep for 4 seconds. When the victim is hit it also creates a beam that \
		deals a bit of fire damage and damages the cells. \
		The beam lasts a minute, until the beam is obstructed or until a new target has been found."
	gain_text = "After waking in a cold sweat I felt a palm on my scalp, a sigil burned onto me. \
		My veins now emitted a strange purple glow, the Beast knows I will surpass its expectations."
	next_knowledge = list(/datum/heretic_knowledge/spell/star_blast)
	spell_to_add = /datum/action/cooldown/spell/touch/star_touch
	cost = 1
	route = PATH_COSMIC

/datum/heretic_knowledge/spell/star_blast
	name = "Star Blast"
	desc = "Fires a projectile that moves very slowly and creates cosmic fields on impact. \
		Anyone hit by the projectile will recieve burn damage, a knockdown, and give people in a three tile range a star mark."
	gain_text = "The Beast was behind me now at all times, with each sacrifice words of affirmation coursed through me."
	adds_sidepath_points = 1
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
	gain_text = "The Beast took my blades in their hand, I kneeled and felt a sharp pain. \
		The blades now glistened with fragmented power. I fell to the ground and wept at the beast's feet."
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
	var/need_mob_update = FALSE
	need_mob_update += target.adjustFireLoss(4, updating_health = FALSE)
	need_mob_update += target.adjustCloneLoss(2, updating_health = FALSE)
	if(need_mob_update)
		target.updatehealth()
	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return
	if(target.mind && target.stat != DEAD)
		combo_counter += 1
	if(second_target_resolved)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
		playsound(get_turf(second_target_resolved), 'sound/magic/cosmic_energy.ogg', 25, FALSE)
		need_mob_update = FALSE
		need_mob_update += second_target_resolved.adjustFireLoss(10, updating_health = FALSE)
		need_mob_update += second_target_resolved.adjustCloneLoss(6, updating_health = FALSE)
		if(need_mob_update)
			target.updatehealth()
		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
			need_mob_update = FALSE
			need_mob_update += third_target_resolved.adjustFireLoss(20, updating_health = FALSE)
			need_mob_update += third_target_resolved.adjustCloneLoss(12, updating_health = FALSE)
			if(need_mob_update)
				target.updatehealth()
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
	adds_sidepath_points = 1
	next_knowledge = list(
		/datum/heretic_knowledge/eldritch_coin,
		/datum/heretic_knowledge/summon/rusty,
	)
	spell_to_add = /datum/action/cooldown/spell/conjure/cosmic_expansion
	cost = 1
	route = PATH_COSMIC
