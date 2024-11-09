/// Damn space vultures man! At least they dont go for the brain
/datum/corpse_damage/post_mortem/organ_loss
	damage_type = CORPSE_DAMAGE_ORGAN_LOSS

	/// Chance that the organ is stored and delivered with the body
	var/organ_save_chance = 20
	/// Minimum organs we can lose
	var/min_organs = 2
	/// Maximum organs we can lose
	var/max_organs = 8

/datum/corpse_damage/post_mortem/organ_loss/apply_to_body(mob/living/carbon/human/body, severity, list/saved_movables, list/datum/callback/on_revive_and_player_occupancy)
	var/organs_to_take = round(min_organs + (max_organs - min_organs) * severity)
	var/list/organs_we_can_take = body.organs - body.get_organ_slot(ORGAN_SLOT_BRAIN)

	if (!length(organs_we_can_take))
		return
	for(var/i in 1 to organs_to_take)
		var/obj/organ = pick(organs_we_can_take)
		if(prob(organ_save_chance) && saved_movables) //if lucky, we can save the organ and have it be delivered with the body
			organ.moveToNullspace()
			saved_movables += organ
		else
			qdel(organ)

/// Damn space vultures man! At least they dont go for the chest or head, or they do but we don't get to see those bodies :O
/datum/corpse_damage/post_mortem/limb_loss
	damage_type = CORPSE_DAMAGE_LIMB_LOSS

	/// Chance that the limb is stored and delivered with the body
	var/limb_save_chance = 20
	/// Min limbs we can lose
	var/min_limbs = 1
	/// Max limbs we can lose
	var/max_limbs = 4

/datum/corpse_damage/post_mortem/limb_loss/apply_to_body(mob/living/carbon/human/body, severity, list/saved_movables, list/datum/callback/on_revive_and_player_occupancy)
	var/limbs_to_take = round(min_limbs + (max_limbs - min_limbs) * severity)
	var/list/limbs_we_can_take = body.bodyparts - body.get_bodypart(BODY_ZONE_HEAD) - body.get_bodypart(BODY_ZONE_CHEST)

	if(!limbs_we_can_take.len)
		return
	for(var/i in 1 to limbs_to_take)
		var/obj/limb = pick(limbs_we_can_take)
		if(prob(limb_save_chance) && saved_movables)
			limb.moveToNullspace()
			saved_movables += limb
		else
			qdel(limb)
