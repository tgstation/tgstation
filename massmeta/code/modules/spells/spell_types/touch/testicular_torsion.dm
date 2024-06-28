/// Weaker smite, not outright gibbing your target, but a lot more bloody, and Sanguine school, so doesn't get affected by splattercasting.
/datum/action/cooldown/spell/touch/testicular_torsion
	name = "Testicular Torsion"
	desc = "This wicked spell twistes and crushes victim's balls \
	causing them to feel immense pain, may also break their legs."
	button_icon_state = "gib"
	sound =  "massmeta/sounds/smites/testicular_torsion.ogg"

	school = SCHOOL_SANGUINE
	invocation_type = INVOCATION_SHOUT
	cooldown_time = 35 SECONDS
	cooldown_reduction_per_rank = 6 SECONDS

	invocation = "T'STICULA' TOR'SION!!"

	hand_path = /obj/item/melee/touch_attack/testicular_torsion

/datum/action/cooldown/spell/touch/testicular_torsion/on_antimagic_triggered(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	caster.visible_message(
		span_warning("The feedback mutilates [caster]'s arm!"),
		span_userdanger("The spell bounces from [victim]'s skin back into your arm!"),
	)
	var/obj/item/bodypart/to_wound = caster.get_holding_bodypart_of_item(hand)
	caster.cause_wound_of_type_and_severity(WOUND_SLASH, to_wound, WOUND_SEVERITY_MODERATE, WOUND_SEVERITY_CRITICAL)

/datum/action/cooldown/spell/touch/testicular_torsion/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	if(!ishuman(victim))
		return
	var/mob/living/carbon/human/human_victim = victim
	human_victim.apply_damage(rand(25, 40), BRUTE, BODY_ZONE_L_LEG, wound_bonus = rand(50,75), forced = TRUE)
	human_victim.apply_damage(rand(25, 40), BRUTE, BODY_ZONE_R_LEG, wound_bonus = rand(50,75), forced = TRUE)
	var/list/phrase = world.file2list("massmeta/strings/balls_phrases.txt")
	human_victim.say(pick(phrase))
	human_victim.emote("screech")
	return TRUE

/obj/item/melee/touch_attack/testicular_torsion
	name = "\improper bloody touch"
	desc = "Guaranteed to make your victims scream, or your money back!"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
