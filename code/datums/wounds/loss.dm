// TODO: see about moving dismemberment over to this, i'll have to add judging dismembering power/wound potential wrt item size i guess
/datum/wound/slash/loss
	name = "Dismembered"
	desc = "oof ouch!!"
	occur_text = "is slashed through the last tissue holding it together, severing it completely!"
	sound_effect = 'sound/effects/dismember.ogg'
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	severity = WOUND_SEVERITY_LOSS
	threshold_minimum = 180
	status_effect_type = null

/datum/wound/slash/loss/apply_wound(obj/item/bodypart/L, silent, datum/wound/slash/old_wound, smited = FALSE)
	if(!L.dismemberable)
		qdel(src)
		return

	var/mob/living/carbon/victim = L.owner
	var/msg = "<b><span class='danger'>[victim]'s [L.name] [occur_text]!</span></b>"

	victim.visible_message(msg, "<span class='userdanger'>Your [L.name] [occur_text]!</span>")

	L.dismember()
	qdel(src)

// TODO: see about moving dismemberment over to this, i'll have to add judging dismembering power/wound potential wrt item size i guess
/datum/wound/pierce/loss
	name = "Dismembered"
	desc = "oof ouch!!"
	occur_text = "is pierced through the last tissue holding it together, severing it completely!"
	sound_effect = 'sound/effects/dismember.ogg'
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	severity = WOUND_SEVERITY_LOSS
	threshold_minimum = 180
	status_effect_type = null

/datum/wound/pierce/loss/apply_wound(obj/item/bodypart/L, silent, datum/wound/slash/old_wound, smited = FALSE)
	if(!L.dismemberable)
		qdel(src)
		return

	var/mob/living/carbon/victim = L.owner
	var/msg = "<b><span class='danger'>[victim]'s [L.name] [occur_text]!</span></b>"

	victim.visible_message(msg, "<span class='userdanger'>Your [L.name] [occur_text]!</span>")

	L.dismember()
	qdel(src)

// TODO: see about moving dismemberment over to this, i'll have to add judging dismembering power/wound potential wrt item size i guess
/datum/wound/blunt/loss
	name = "Dismembered"
	desc = "oof ouch!!"
	occur_text = "is shattered through the last bone holding it together, severing it completely!"
	sound_effect = 'sound/effects/dismember.ogg'
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	severity = WOUND_SEVERITY_LOSS
	threshold_minimum = 180
	status_effect_type = null

/datum/wound/blunt/loss/apply_wound(obj/item/bodypart/L, silent, datum/wound/slash/old_wound, smited = FALSE)
	if(!L.dismemberable)
		qdel(src)
		return

	var/mob/living/carbon/victim = L.owner
	var/msg = "<b><span class='danger'>[victim]'s [L.name] [occur_text]!</span></b>"

	victim.visible_message(msg, "<span class='userdanger'>Your [L.name] [occur_text]!</span>")

	L.dismember()
	qdel(src)
