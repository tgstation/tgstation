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
 *   Fire Fish
 *
 * Mark of Cosmos
 * Ritual of Knowledge
 * Star Touch
 * Star Blast
 * > Sidepaths:
 *   Curse of Corrosion
 *   Curse of The Stars
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
	/// Creates a field to stop people with a star mark.
	var/obj/effect/cosmic_field/cosmic_field

/datum/heretic_knowledge/cosmic_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/cosmic_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/cosmic_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	to_chat(target, span_danger("A cosmic ring appeared above your head!"))
	target.apply_status_effect(/datum/status_effect/star_mark)
	cosmic_field = new(get_turf(source))

/datum/heretic_knowledge/spell/cosmic_runes
	name = "Cosmic Runes"
	desc = "Grants you Cosmic Runes, a spell that creates two runes linked with eachother for easy teleportation. \
		Only the entity activating the rune will get transported, and it can be used by anyone without a star mark."
	gain_text = "When day came, the Sleeper got lost. \
		The sun outshined the stars, so he lost his guide."
	next_knowledge = list(
		/datum/heretic_knowledge/mark/cosmic_mark,
		/datum/heretic_knowledge/codex_cicatrix,
		/datum/heretic_knowledge/essence,
		/datum/heretic_knowledge/summon/fire_shark,
	)
	spell_to_add = /datum/action/cooldown/spell/cosmic_rune
	cost = 1
	route = PATH_COSMIc

/datum/heretic_knowledge/mark/cosmic_mark
	name = "Mark of Cosmos"
	desc = "Your Mansus Grasp now applies the Mark of Cosmos. The mark is triggered from an attack with your Cosmic Blade. \
		When triggered, the victim transport back to the Cosmic Diamond, which is the location your mark was applied to them. \
		After getting transported they will be paralyzed for 2 seconds."
	gain_text = "As the guide was lost, he found a new. The energy increased as the gaze he threw. \
		He didn't know, but with focus, the Sleepers energy began to flow."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/cosmic)
	route = PATH_COSMIc
	mark_type = /datum/status_effect/eldritch/cosmic

/datum/heretic_knowledge/knowledge_ritual/cosmic
	next_knowledge = list(/datum/heretic_knowledge/spell/star_touch)
	route = PATH_COSMIC

/datum/heretic_knowledge/spell/star_touch
	name = "Star Touch"
	desc = "Grants you Star Touch, a spell that will give people a star mark (cosmic ring) \
		and create a cosmic field where you stand. People that already have a star mark \
		will be forced to sleep for 6 seconds."
	gain_text = "He dreamed to know, how the matter from star to star traveled. \
		He lost interest in wanting to find out."
	next_knowledge = list(/datum/heretic_knowledge/spell/star_blast)
	spell_to_add = /datum/action/cooldown/spell/touch/star_touch
	cost = 1
	route = PATH_COSMIC

/datum/heretic_knowledge/spell/star_blast
	name = "Star Blast"
	desc = "Fires a projectile that moves very slowly and create a cosmic field on impact. \
		Anyone hit by the projectile will recieve burn damage, a knockdown and a star mark."
	gain_text = "He didn't try, yet felt the call of the nights Creator."
	next_knowledge = list(
		/datum/heretic_knowledge/blade_upgrade/cosmic,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/curse/cosmic_trail,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/star_blast
	cost = 1
	route = PATH_COSMIC

/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Cosmic Blade"
	desc = "Your blade now deals damage to peoples cells through cosmic radiation."
	gain_text = "As he ascended to be a watcher, he needed to gather knowledge. \
		He started to draw it at his home."
	next_knowledge = list(/datum/heretic_knowledge/spell/cosmic_expansion)
	route = PATH_COSMIC

/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target)
		return

	target.apply_damage_type(damage = 5, damagetype = CLONE)

/datum/heretic_knowledge/spell/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "Grants you Cosmic Expansion, a spell that creates a 3x3 area of cosmic fields around you. \
		Nearby beings will also receive a star mark."
	gain_text = "He was well known so he had a lot of drawing to do, to gather as much of the things he forgot."
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
		Bring 3 corpses with bluespacedust in their body to a transmutation rune to complete the ritual. \
		When completed, you become the owner of a Star Gazer. \
		You will be able to command the Star Gazer with Alt+click. \
		You can also give it commands through speech. \
		The Star Gazer is a strong mob that can even break down reinforced walls."
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
		return

	if(sacrifice.has_reagent(/datum/reagent/bluespace))
		return TRUE
	return FALSE

/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] A Star Gazer has arrived into the station, [user.real_name] has ascended! This station is the domain of the Cosmos! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	var/mob/living/basic/star_gazer/star_gazer_mob = new /mob/living/basic/star_gazer(loc)
	star_gazer_mob.AddComponent(/datum/component/obeys_commands, star_gazer_commands)
	star_gazer_mob.befriend(user)

	user.client?.give_award(/datum/award/achievement/misc/cosmic_ascension, user)
