/datum/action/cooldown/spell/aoe/mind_swap
	name = "Mind Swap"
	desc = "This spell will randomly swap the minds of everyone around you, yourself included."
	button_icon_state = "mindswap"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 3 MINUTES
	cooldown_reduction_per_rank = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_MIND|SPELL_CASTABLE_AS_BRAIN
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	invocation = "GIN'YU CAPAN"
	invocation_type = INVOCATION_WHISPER

	aoe_radius = 3

	/// If TRUE, we cannot mindswap into mobs with minds if they do not currently have a key / player.
	var/target_requires_key = TRUE
	/// If TRUE, we cannot mindswap into people without a mind.
	/// You may be wondering "What's the point of mindswap if the target has no mind"?
	/// Primarily for debugging - targets hit with this set to FALSE will init a mind, then do the swap.
	var/target_requires_mind = TRUE
	/// For how long are mobs stunned for after the spell
	var/unconscious_amount = 20 SECONDS
	/// List of mobs we cannot mindswap into.
	var/static/list/mob/living/blacklisted_mobs = typecacheof(list(
		/mob/living/brain,
		/mob/living/silicon/pai,
		/mob/living/simple_animal/hostile/megafauna,
		/mob/living/basic/guardian,
	))
	//has the spell made a fake wizard yet
	var/made_false_wizard = FALSE
	//the mob of the wizard, used for what mind to turn into a fake wizard
	var/mob/living/carbon/human/wizard_body
	//carried over to after_cast so it has to be here
	var/list/swap_mobs = list()
	//also carried over
	var/list/swap_ghosts = list()

/datum/action/cooldown/spell/aoe/mind_swap/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(owner))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_SUICIDED))
		if(feedback)
			to_chat(owner, span_warning("You're killing yourself! You can't concentrate enough to do this!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/aoe/mind_swap/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/nearby_mob in range(aoe_radius, get_turf(center)))
		if(is_type_in_typecache(nearby_mob, blacklisted_mobs) || (nearby_mob.stat == DEAD))
			continue
		if(!nearby_mob.mind && target_requires_mind)
			continue

		if(!nearby_mob.key && target_requires_key)
			continue

		if(HAS_TRAIT(nearby_mob, TRAIT_MIND_TEMPORARILY_GONE))
			continue

		if(HAS_TRAIT(nearby_mob, TRAIT_NO_MINDSWAP))
			continue

		things += nearby_mob
	return things

/datum/action/cooldown/spell/aoe/mind_swap/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	// Gives the target a mind if we don't require one and they don't have one
	if(!victim.mind && !target_requires_mind)
		victim.mind_initialize()

	var/datum/mind/mind_to_swap = victim.mind
	if(!mind_to_swap == owner.mind) //always add owner
		if(victim.can_block_magic(antimagic_flags) \
			|| mind_to_swap.has_antag_datum(/datum/antagonist/wizard) \
			|| mind_to_swap.has_antag_datum(/datum/antagonist/cult) \
			|| mind_to_swap.has_antag_datum(/datum/antagonist/changeling) \
			|| mind_to_swap.key?[1] == "@" \
			)
			return

	if(!(made_false_wizard) && ishuman(owner)) //make a fake wizard if swapping with the original body
		wizard_body = owner

	var/mob/dead/observer/ghost = victim.ghostize(TRUE) //we have to manually ghost and then transfer the mind to make sure no one gets left out of their body
	swap_ghosts += ghost
	swap_mobs += victim

/datum/action/cooldown/spell/aoe/mind_swap/after_cast(atom/cast_on)
	. = ..()
	if(!swap_ghosts.len == swap_mobs.len)
		message_admins("Mindswap mob count not equal to ghost count.")

	cycle_inplace(swap_mobs)

	for(var/i=1, i <= swap_mobs.len, ++i)
		var/mob/living/current_mob = swap_mobs[i]
		var/mob/dead/observer/current_ghost = swap_ghosts[i]
		current_ghost.mind.transfer_to(current_mob)
		current_mob.grab_ghost(TRUE)
		if(current_mob == wizard_body && !(made_false_wizard))
			make_fake_wizard(wizard_body)
			made_false_wizard = TRUE

		SEND_SOUND(current_mob, sound('sound/magic/mandswap.ogg'))

		current_mob.Unconscious(unconscious_amount)

	swap_mobs = list()
	swap_ghosts = list()

/datum/action/cooldown/spell/aoe/mind_swap/proc/make_fake_wizard(var/mob/living/imposter_mob) //for making the fake wizard
	var/datum/antagonist/wizard/master = owner.mind.has_antag_datum(/datum/antagonist/wizard)
	if(!master.wiz_team)
		master.create_wiz_team()

	var/datum/antagonist/wizard/apprentice/imposter/imposter = new()
	imposter.master = owner.mind
	imposter.wiz_team = master.wiz_team
	master.wiz_team.add_member(imposter)
	imposter_mob.mind.add_antag_datum(imposter)
	imposter_mob.mind.special_role = "imposter"
	imposter_mob.log_message("is an imposter!", LOG_ATTACK, color="red")

	SEND_SOUND(imposter_mob, sound('sound/effects/magic.ogg')) //I want to replace this with the sus SFX so badly

/datum/action/cooldown/spell/aoe/mind_swap/badmin
	name = "Greater Mind Swap"
	desc = "This spell will randomly swap the minds of everyone around you in a huge area, yourself included."
	aoe_radius = 12
	cooldown_time = 30 SECONDS
