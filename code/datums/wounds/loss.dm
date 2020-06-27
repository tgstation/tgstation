
/datum/wound/loss
	name = "Dismembered"
	desc = "oof ouch!!"

	sound_effect = 'sound/effects/dismember.ogg'
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	severity = WOUND_SEVERITY_LOSS
	threshold_minimum = 180
	status_effect_type = null
	scarring_descriptions = list("is several skintone shades paler than the rest of the body", "is a gruesome patchwork of artificial flesh", "has a large series of attachment scars at the articulation points")

/datum/wound/loss/proc/apply_dismember(obj/item/bodypart/L, wounding_type=WOUND_SLASH)
	if(!istype(L) || !L.owner || !(L.body_zone in viable_zones) || isalien(L.owner) || !L.can_dismember())
		qdel(src)
		return

	if(ishuman(L.owner))
		var/mob/living/carbon/human/H = L.owner
		if(organic_only && ((NOBLOOD in H.dna.species.species_traits) || !L.is_organic_limb()))
			qdel(src)
			return

	switch(wounding_type)
		if(WOUND_BLUNT)
			occur_text = "is shattered through the last bone holding it together, severing it completely!"
		if(WOUND_SLASH)
			occur_text = "is slashed through the last tissue holding it together, severing it completely!"
		if(WOUND_PIERCE)
			occur_text = "is pierced through the last tissue holding it together, severing it completely!"

	var/mob/living/carbon/victim = L.owner
	if(prob(40))
		victim.confused += 5

	var/msg = "<b><span class='danger'>[victim]'s [L.name] [occur_text]!</span></b>"

	victim.visible_message(msg, "<span class='userdanger'>Your [L.name] [occur_text]!</span>")

	second_wind()
	L.dismember()
	qdel(src)
