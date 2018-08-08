/obj/effect/proc_holder/changeling/revive
	name = "Revive"
	desc = "We regenerate, healing all damage from our form."
	helptext = "Does not regrow lost organs or a missing head."
	req_stat = DEAD
	always_keep = TRUE
	ignores_fakedeath = TRUE

//Revive from revival stasis
/obj/effect/proc_holder/changeling/revive/sting_action(mob/living/carbon/user)
	user.cure_fakedeath("changeling")
	user.revive(full_heal = 1)
	var/list/missing = user.get_missing_limbs()
	missing -= BODY_ZONE_HEAD // headless changelings are funny
	if(missing.len)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user]'s missing limbs \
			reform, making a loud, grotesque sound!</span>",
			"<span class='userdanger'>Your limbs regrow, making a \
			loud, crunchy sound and giving you great pain!</span>",
			"<span class='italics'>You hear organic matter ripping \
			and tearing!</span>")
		user.emote("scream")
		user.regenerate_limbs(0, list(BODY_ZONE_HEAD))
	user.regenerate_organs()
	to_chat(user, "<span class='notice'>We have revived ourselves.</span>")
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.purchasedpowers -= src
	return TRUE

/obj/effect/proc_holder/changeling/revive/can_be_used_by(mob/living/user)
	. = ..()
	if(!.)
		return

	if(user.has_trait(CHANGELING_DRAIN) || ((user.stat != DEAD) && !(user.has_trait(TRAIT_DEATHCOMA))))
		var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
		changeling.purchasedpowers -= src
		return FALSE

