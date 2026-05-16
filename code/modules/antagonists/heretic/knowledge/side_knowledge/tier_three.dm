/*!
 * Tier 3 knowledge: Summons
 */

/datum/heretic_knowledge/summon/rusty
	name = "Rusted Ritual"
	desc = "Summon a Rust Walker.<br>\
		Rust Walkers excel at spreading rust and are moderately strong in combat."
	transmute_text = "Transmute a pool of vomit, some cable coil, and 10 sheets of iron."
	gain_text = "I combined my knowledge of creation with my desire for corruption. The Marshal knew my name, and the Rusted Hills echoed out."
	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/cable_coil = 15,
	)
	mob_to_summon = /mob/living/basic/heretic_summon/rust_walker
	cost = 2
	poll_ignore_define = POLL_IGNORE_RUST_SPIRIT
	drafting_tier = 3

/datum/heretic_knowledge/summon/maid_in_mirror
	name = "Maid in the Mirror"
	desc = "Summon a Maid in the Mirror.<br>\
		Maid in the Mirrors are decent combatants that can become incorporeal by phasing in and out of the mirror realm, \
		serving as powerful scouts and ambushers. Their attacks also apply a stack of void chill."
	transmute_text = "Transmute five sheets of glass, any suit, and a pair of lungs."
	gain_text = "Within each reflection, lies a gateway into an unimaginable world of colors never seen and \
		people never met. The ascent is glass, and the walls are knives. Each step is blood, if you do not have a guide."

	required_atoms = list(
		/obj/item/stack/sheet/glass = 5,
		/obj/item/clothing/suit = 1,
		/obj/item/organ/lungs = 1,
	)
	cost = 2

	mob_to_summon = /mob/living/basic/heretic_summon/maid_in_the_mirror
	poll_ignore_define = POLL_IGNORE_MAID_IN_MIRROR
	drafting_tier = 3

/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "Summon an Ash Spirit.<br>\
		Ash Spirits have a short range jaunt and the ability to cause bleeding in foes at range. \
		They also have the ability to create a ring of fire around themselves for a length of time.<br>\
		They have a low amount of health, but will passively recover given enough time to do so."
	transmute_text = "Transmute a pool of ash, a book, and a bonfire."
	gain_text = "I combined my principle of hunger with my desire for destruction. The Marshal knew my name, and the Nightwatcher gazed on."
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/book = 1,
		/obj/structure/bonfire = 1,
		)
	mob_to_summon = /mob/living/basic/heretic_summon/ash_spirit
	cost = 2

	poll_ignore_define = POLL_IGNORE_ASH_SPIRIT
	drafting_tier = 3

/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Shattered Ritual"
	desc = "Enchant a corpse into a Shattered Risen.<br>\
		Shattered Risen are strong ghouls that have 125 health, but cannot hold items, \
		instead having two brutal weapons for hands. You can only create one at a time."
	transmute_text = "Transmute a corpse with a soul, a pair of latex or nitrile gloves."
	gain_text = "I witnessed a cold, rending force drag this corpse back to near-life. \
		When it moves, it crunches like broken glass. Its hands are no longer recognizable as human - \
		each clenched fist contains a brutal nest of sharp bone-shards instead."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/latex = 1,
	)
	limit = 1
	cost = 2
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"
	drafting_tier = 3

/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("[body] is not in a valid state to be made into a ghoul."))
			continue
		if(!body.mind)
			to_chat(user, span_hierophant_warning("[body] is mindless and cannot be made into a ghoul."))
			continue
		if(!body.client && !body.mind.get_ghost(ghosts_with_clients = TRUE))
			to_chat(user, span_hierophant_warning("[body] is soulless and cannot be made into a ghoul."))
			continue

		// We will only accept valid bodies with a mind, or with a ghost connected that used to control the body
		selected_atoms += body
		return TRUE

	loc.balloon_alert(user, "ritual failed, no valid body!")
	return FALSE

/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	selected_atoms -= soon_to_be_ghoul
	make_risen(user, soon_to_be_ghoul)
	return TRUE

/// Make [victim] into a shattered risen ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/make_risen(mob/living/user, mob/living/carbon/human/victim)
	user.log_message("created a shattered risen out of [key_name(victim)].", LOG_GAME)
	victim.log_message("became a shattered risen of [key_name(user)]'s.", LOG_VICTIM, log_globally = FALSE)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a shattered risen, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		RISEN_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_risen)),
		CALLBACK(src, PROC_REF(remove_from_risen)),
	)

/// Callback for the ghoul status effect - what effects are applied to the ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
	LAZYADD(created_items, WEAKREF(risen))
	risen.AddComponent(/datum/component/mutant_hands, mutant_hand_path = /obj/item/mutant_hand/shattered_risen)

/// Callback for the ghoul status effect - cleaning up effects after the ghoul status is removed.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
	LAZYREMOVE(created_items, WEAKREF(risen))
	qdel(risen.GetComponent(/datum/component/mutant_hands))

#undef RISEN_MAX_HEALTH

/// The "hand" "weapon" used by shattered risen
/obj/item/mutant_hand/shattered_risen
	name = "bone-shards"
	desc = "What once appeared to be a normal human fist, now holds a mauled nest of sharp bone-shards."
	color = "#001aff"
	hitsound = SFX_SHATTER
	force = 16
	wound_bonus = -30
	exposed_wound_bonus = 15
	demolition_mod = 1.5
	sharpness = SHARP_EDGED

/datum/heretic_knowledge/summon/fire_shark
	name = "Scorching Shark"
	desc = "Summon a Fire Shark.<br>\
		Fire Sharks are fast and strong in groups, but fragile to non-burning damage.<br>\
		They also inject phlogiston on attack and spawn plasma on death."
	transmute_text = "Transmute a pool of ash, a liver, and a sheet of plasma."
	gain_text = "The cradle of the nebula was cold, but not dead. Light and heat flits even through the deepest darkness, and is hunted by its own predators."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/liver = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/basic/heretic_summon/fire_shark
	cost = 2

	poll_ignore_define = POLL_IGNORE_FIRE_SHARK

	research_tree_icon_dir = EAST
	drafting_tier = 3

/datum/heretic_knowledge/mad_mask
	name = "Mask of Madness"
	desc = "Create a Mask of Madness.<br>\
		The mask instills fear into heathens who witness it, causing stamina damage, hallucinations, and insanity.<br>\
		It can also be forced onto a heathen, to make them unable to take it off..."
	transmute_text = "Transmute any mask, four lit candles, a stun baton, and a liver."
	gain_text = "The Watch wore strange garb on duty. It allowed them to walk the city, seemingly unnoticed by the masses."
	required_atoms = list(
		/obj/item/organ/liver = 1,
		/obj/item/melee/baton/security = 1,  // Technically means a cattleprod is valid
		/obj/item/clothing/mask = 1,
		/obj/item/flashlight/flare/candle = 4,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/masks.dmi'
	research_tree_icon_state = "mad_mask"
	drafting_tier = 3

/datum/heretic_knowledge/mad_mask/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/flashlight/flare/candle/candle in atoms)
		if(!candle.light_on)
			atoms -= candle

/datum/heretic_knowledge/mad_mask/prepare_atom_for_ritual_test(atom/what)
	. = ..()
	if(istype(what, /obj/item/flashlight/flare/candle))
		what.set_light_on(TRUE)

/datum/heretic_knowledge/mansus_gate
	name = "Keys to the Backdoor"
	desc = "Open a backdoor to the Mansus.<br>\
		Entering the container will transport you to the Mansus, granting you a safe haven to transmute or store equipment."
	transmute_text = "Transmute a locker and a Codex Cicatrix or Codex Morbus."
	notice = "Only willing individuals or the deceased can pass through the backdoor.\
		<br>Attempting to perform a sacrifice so close to the gods may anger them.\
		<br>You can only create one backdoor."
	gain_text = "With any domain, its security is only as strong as its weakest point. \
		The Codex speaks of backdoors to the Mansus - gates with shoddy chains, doors with brittle locks, trapdoors with rusted hinges. \
		With the right key, I could easily exploit these."
	required_atoms = list(
		/obj/structure/closet = 1,
		list(/obj/item/codex_cicatrix, /obj/item/codex_cicatrix/morbus) = 1,
	)
	cost = 2
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "anom"
	drafting_tier = 3
	is_shop_only = TRUE
	VAR_PRIVATE/used = FALSE

/datum/heretic_knowledge/mansus_gate/can_be_invoked(datum/antagonist/heretic/invoker)
	return !used

/datum/heretic_knowledge/mansus_gate/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/obj/structure/closet/locker = locate() in selected_atoms
	if(isnull(locker))
		stack_trace("Locker not found in selected atoms for mansus gate recipe!")
		return FALSE

	used = TRUE
	INVOKE_ASYNC(src, PROC_REF(setup_link), locker)
	return TRUE

/datum/heretic_knowledge/mansus_gate/cleanup_atoms(list/selected_atoms)
	for(var/obj/structure/closet/locker in selected_atoms)
		selected_atoms -= locker
	return ..()

/datum/heretic_knowledge/mansus_gate/proc/setup_link(obj/structure/closet/crate/locker)
	var/datum/map_template/masus_backdoor/backdoor = new()
	var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(
		width = backdoor.width,
		height = backdoor.height,
		reservation_type = /datum/turf_reservation/indestructible_plating,
	)
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	backdoor.load(bottom_left)
	var/obj/structure/closet/new_link = locate() in backdoor.created_atoms
	new_link.resistance_flags |= INDESTRUCTIBLE
	new_link.set_anchored(TRUE)
	new_link.anchorable = FALSE
	new_link.divable = FALSE
	new_link.contents_pressure_protection = 1
	new_link.contents_thermal_insulation = 1
	locker.resistance_flags |= INDESTRUCTIBLE
	locker.divable = FALSE
	locker.contents_pressure_protection = 1
	locker.contents_thermal_insulation = 1
	GLOB.closet_teleport_controller.create_new_link(list(locker, new_link), subtle = TRUE)
	RegisterSignal(new_link, COMSIG_CLOSET_TELEPORTER_PRE_SENDING, PROC_REF(closet_teleport_logic))
	RegisterSignal(locker, COMSIG_CLOSET_TELEPORTER_PRE_SENDING, PROC_REF(closet_teleport_logic))

/datum/heretic_knowledge/mansus_gate/proc/closet_teleport_logic(obj/structure/closet/crate/locker, atom/movable/sending_through)
	SIGNAL_HANDLER

	if(!is_station_level(locker.z))
		return CLOSET_TELEPORT_FORCED

	if(isliving(sending_through) && !consents_to_entry(sending_through))
		locker.balloon_alert(sending_through, "the door refuses you!")
		return CLOSET_TELEPORT_BLOCKED

	for(var/mob/living/entering in sending_through.get_all_contents())
		if(!consents_to_entry(entering))
			if(isliving(sending_through))
				locker.balloon_alert(sending_through, "the door refuses you!")
			return CLOSET_TELEPORT_BLOCKED

	return CLOSET_TELEPORT_FORCED

/datum/heretic_knowledge/mansus_gate/proc/consents_to_entry(mob/living/entering)
	if(IS_HERETIC_OR_MONSTER(entering))
		return TRUE
	if(!INCAPACITATED_IGNORING(entering, INCAPABLE_GRAB|INCAPABLE_STASIS))
		return TRUE
	return FALSE

/datum/map_template/masus_backdoor
	name = "The Mansus"
	mappath = "_maps/templates/mansus_backdoor.dmm"
	width = 59
	height = 51
	returns_created_atoms = TRUE

/area/centcom/heretic_backdoor
	name = "Mansus"
	icon_state = "heretic"
	requires_power = TRUE
	always_unpowered = TRUE
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	area_flags = NOTELEPORT | HIDDEN_AREA | BLOCK_SUICIDE | NO_BOH
	static_lighting = FALSE
	base_lighting_alpha = 200
	base_lighting_color = "#FFF4AA"

/area/centcom/heretic_backdoor/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	if(isliving(arrived))
		var/mob/living/arrived_mob = arrived
		arrived_mob.add_movespeed_modifier(/datum/movespeed_modifier/heretic_backdoor_slowdown)
		arrived_mob.adjust_temp_blindness(1 SECONDS)
		arrived_mob.adjust_eye_blur(2 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(greet_message), arrived_mob), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		if(!IS_HERETIC_OR_MONSTER(arrived_mob))
			arrived_mob.apply_status_effect(/datum/status_effect/necropolis_curse, CURSE_BLINDING)

/area/centcom/heretic_backdoor/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		var/mob/living/gone_mob = gone
		gone_mob.remove_movespeed_modifier(/datum/movespeed_modifier/heretic_backdoor_slowdown)
		gone_mob.remove_status_effect(/datum/status_effect/necropolis_curse)
		gone_mob.adjust_temp_blindness(1 SECONDS)
		gone_mob.adjust_eye_blur(2 SECONDS)

/area/centcom/heretic_backdoor/proc/greet_message(mob/living/arrived_mob)
	if(QDELETED(arrived_mob) || get_area(arrived_mob) != src)
		return
	to_chat(arrived_mob, span_mansus("A hollow sun shines down from above."))

/datum/movespeed_modifier/heretic_backdoor_slowdown
	multiplicative_slowdown = 0.5
