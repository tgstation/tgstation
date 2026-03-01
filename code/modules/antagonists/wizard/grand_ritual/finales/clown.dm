/// Dress the crew as magical clowns
/datum/grand_finale/clown
	name = "Jubilation"
	desc = "The ultimate use of your gathered power! Rewrite time so that everyone went to clown college! Now they'll prank each other for you!"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "clown"
	glow_colour = "#ffff0048"

/datum/grand_finale/clown/trigger(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/victim as anything in GLOB.human_list)
		victim.Unconscious(3 SECONDS)
		if (victim == invoker)
			if(locate(/datum/action/cooldown/spell/pointed/untie_shoes) in invoker.actions)
				continue
			var/datum/action/cooldown/spell/pointed/untie_shoes/newer_spell = new(invoker)
			newer_spell.Grant(invoker)
			for(var/i in 1 to newer_spell.spell_max_level)
				newer_spell.level_spell()
				newer_spell.invocation_type = INVOCATION_SHOUT
			continue
		if (!victim.mind || IS_HUMAN_INVADER(victim))
			continue
		if (HAS_TRAIT(victim, TRAIT_CLOWN_ENJOYER))
			victim.add_mood_event("clown_world", /datum/mood_event/clown_world)
		to_chat(victim, span_notice("The world spins and dissolves. Your past flashes before your eyes, backwards.\n\
			Life strolls back into the ocean and shrinks into nothingness, planets explode into storms of solar dust, \
			the stars rush back to greet each other at the beginning of things and then... you snap back to the present. \n\
			Everything is just as it was and always has been. \n\n\
			A stray thought sticks in the forefront of your mind. \n\
			[span_hypnophrase("I'm so glad that I work at Clown Research Station [station_name()]!")] \n\
			Is... that right?"))
		if (is_clown_job(victim.mind.assigned_role))
			var/datum/action/cooldown/spell/conjure_item/clown_pockets/new_spell = new(victim)
			new_spell.Grant(victim)
			var/datum/action/cooldown/spell/pointed/untie_shoes/newer_spell = new(victim)
			newer_spell.Grant(victim)
			continue
		dress_as_magic_clown(victim)
		if (prob(15))
			create_vendetta(victim.mind, invoker.mind)

/**
 * Clown enjoyers who are effected by this become ecstatic, they have achieved their life's dream.
 * This moodlet is equivalent to the one for simply being a traitor.
 */
/datum/mood_event/clown_world
	mood_change = 4

/datum/mood_event/clown_world/add_effects(param)
	description = "I LOVE working at Clown Research Station [station_name()]!!"

/// Dress the passed mob as a magical clown, self-explanatory
/datum/grand_finale/clown/proc/dress_as_magic_clown(mob/living/carbon/human/victim)
	var/obj/effect/particle_effect/fluid/smoke/poof = new(get_turf(victim))
	poof.lifetime = 2 SECONDS

	var/obj/item/tank/internal = victim.internal
	// We're about to take off your pants so those are going to fall out
	var/obj/item/pocket_L = victim.get_item_by_slot(ITEM_SLOT_LPOCKET)
	var/obj/item/pocket_R = victim.get_item_by_slot(ITEM_SLOT_RPOCKET)
	var/obj/item/id = victim.get_item_by_slot(ITEM_SLOT_ID)
	var/obj/item/belt = victim.get_item_by_slot(ITEM_SLOT_BELT)

	var/obj/pants = victim.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	var/obj/mask = victim.get_item_by_slot(ITEM_SLOT_MASK)
	QDEL_NULL(pants)
	QDEL_NULL(mask)
	if(isplasmaman(victim))
		victim.equip_to_slot_if_possible(new /obj/item/clothing/under/plasmaman/clown/magic(), ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
		victim.equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clown_hat/plasmaman(), ITEM_SLOT_MASK, disable_warning = TRUE)
	else
		victim.equip_to_slot_if_possible(new /obj/item/clothing/under/rank/civilian/clown/magic(), ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
		victim.equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clown_hat(), ITEM_SLOT_MASK, disable_warning = TRUE)

	var/obj/item/clothing/mask/gas/clown_hat/clown_mask = victim.get_item_by_slot(ITEM_SLOT_MASK)
	if (clown_mask)
		var/list/options = GLOB.clown_mask_options
		clown_mask.icon_state = options[pick(clown_mask.clownmask_designs)]
		victim.update_worn_mask()
		clown_mask.update_item_action_buttons()

	equip_to_slot_then_hands(victim, ITEM_SLOT_LPOCKET, pocket_L)
	equip_to_slot_then_hands(victim, ITEM_SLOT_RPOCKET, pocket_R)
	equip_to_slot_then_hands(victim, ITEM_SLOT_ID, id)
	equip_to_slot_then_hands(victim, ITEM_SLOT_BELT, belt)
	victim.internal = internal
