
/datum/wound/loss
	name = "Dismembered"
	desc = "oof ouch!!"

	sound_effect = 'sound/effects/dismember.ogg'
	severity = WOUND_SEVERITY_LOSS
	threshold_minimum = 180
	status_effect_type = null
	scar_keyword = "dismember"
	biology_required = null // not that it really matters, we don't check anyway for dismembering

/datum/wound/loss/proc/apply_dismember(obj/item/bodypart/L, wounding_type=WOUND_SLASH)
	if(!istype(L) || !L.owner || !(L.body_zone in viable_zones) || isalien(L.owner) || !L.can_dismember())
		qdel(src)
		return

	already_scarred = TRUE // so we don't scar a limb we don't have. If I add different levels of amputation desc, do it here

	switch(wounding_type)
		if(WOUND_BLUNT)
			occur_text = "is shattered through the last bone holding it together, severing it completely!"
		if(WOUND_SLASH)
			occur_text = "is slashed through the last tissue holding it together, severing it completely!"
		if(WOUND_PIERCE)
			occur_text = "is pierced through the last tissue holding it together, severing it completely!"
		if(WOUND_BURN)
			occur_text = "is completely incinerated, falling to dust!"

	victim = L.owner

	var/msg = "<b><span class='danger'>[victim]'s [L.name] [occur_text]!</span></b>"

	victim.visible_message(msg, "<span class='userdanger'>Your [L.name] [occur_text]!</span>")

	limb = L
	if(!limb || !victim)
		return
	severity = WOUND_SEVERITY_LOSS
	second_wind()
	log_wound(victim, src)
	L.dismember(wounding_type == WOUND_BURN ? BURN : BRUTE)
	qdel(src)
