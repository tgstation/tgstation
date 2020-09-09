
/datum/wound/slash/critical/loss
	name = "Dismembered stump"
	desc = "Patient's limb has been violently dismembered, leaving only a severely damaged stump in it's place. Extreme blood loss will lead to quick death without intervention."
	examine_desc = "has been violently severed from their chest"
	sound_effect = 'sound/effects/dismember.ogg'
	severity = WOUND_SEVERITY_LOSS
	threshold_minimum = WOUND_DISMEMBER_OUTRIGHT_THRESH // not actually used since dismembering is handled differently, but may as well assign it since we got it
	status_effect_type = /datum/status_effect/wound/slash/dismemberment
	scar_keyword = "dismember"
	demotes_to = null
	wound_flags = (FLESH_WOUND | ACCEPTS_GAUZE | IGNORES_EXISTING_WOUNDS)

/// Our special proc for our special dismembering, the wounding type only matters for what text we have
/datum/wound/slash/critical/loss/proc/apply_dismember(obj/item/bodypart/dismembered_part, wounding_type=WOUND_SLASH, outright = FALSE)
	if(!istype(dismembered_part) || !dismembered_part.owner || !(dismembered_part.body_zone in viable_zones) || isalien(dismembered_part.owner) || !dismembered_part.can_dismember())
		qdel(src)
		return

	already_scarred = TRUE // so we don't scar a limb we don't have. If I add different levels of amputation desc, do it here
	victim = dismembered_part.owner
	phantom_body_zone = dismembered_part.body_zone

	if(dismembered_part.body_zone == BODY_ZONE_CHEST)
		occur_text = "is split open, causing [victim.p_their()] internals organs to spill out!"
	else if(outright)
		switch(wounding_type)
			if(WOUND_BLUNT)
				occur_text = "is outright smashed to a gross pulp, severing it completely!"
			if(WOUND_SLASH)
				occur_text = "is outright slashed off, severing it completely!"
			if(WOUND_PIERCE)
				occur_text = "is outright blasted apart, severing it completely!"
			if(WOUND_BURN)
				occur_text = "is outright incinerated, falling to dust!"
	else
		switch(wounding_type)
			if(WOUND_BLUNT)
				occur_text = "is shattered through the last bone holding it together, severing it completely!"
			if(WOUND_SLASH)
				occur_text = "is slashed through the last tissue holding it together, severing it completely!"
			if(WOUND_PIERCE)
				occur_text = "is pierced through the last tissue holding it together, severing it completely!"
			if(WOUND_BURN)
				occur_text = "is completely incinerated, falling to dust!"

	var/msg = "<span class='bolddanger'>[victim]'s [dismembered_part.name] [occur_text]!</span>"

	victim.visible_message(msg, "<span class='userdanger'>Your [dismembered_part.name] [occur_text]!</span>")

	severity = WOUND_SEVERITY_LOSS
	second_wind()
	log_wound(victim, src)
	dismembered_part.dismember(wounding_type == WOUND_BURN ? BURN : BRUTE, silent = TRUE)

	/// We apply ourselves to the chest now that we've ripped the bodypart off
	name = "[parse_zone(dismembered_part.body_zone)] stump"
	desc = "Patient's [parse_zone(dismembered_part.body_zone)] has been violently dismembered, leaving only a severely damaged stump in it's place."
	var/obj/item/bodypart/chest/chest = victim.get_bodypart(BODY_ZONE_CHEST)
	if((dismembered_part.body_zone != BODY_ZONE_CHEST) && chest)
		apply_wound(chest, TRUE)
	else
		qdel(src)

/datum/wound/slash/critical/loss/get_examine_description(mob/user)
	. = ..()
	if(fake_body_zone == BODY_ZONE_HEAD)
		return "<span class='deadsay'>[.]</span>"
