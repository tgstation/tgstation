/obj/effect/proc_holder/changeling/revive
	name = "Revive"
	desc = "We regenerate, healing all damage from our form."
	helptext = "Does not regrow lost organs or a missing head."
	req_stat = DEAD
	always_keep = TRUE
	ignores_fakedeath = TRUE

//Revive from revival stasis
/obj/effect/proc_holder/changeling/revive/sting_action(mob/living/carbon/user)
	user.status_flags &= ~(FAKEDEATH)
	user.tod = null
	user.revive(full_heal = 1)
	var/list/missing = user.get_missing_limbs()
	missing -= "head" // headless changelings are funny
	if(missing.len)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user]'s missing limbs \
			reform, making a loud, grotesque sound!</span>",
			"<span class='userdanger'>Your limbs regrow, making a \
			loud, crunchy sound and giving you great pain!</span>",
			"<span class='italics'>You hear organic matter ripping \
			and tearing!</span>")
		user.emote("scream")
		user.regenerate_limbs(0, list("head"))
		user.regenerate_organs()
	to_chat(user, "<span class='notice'>We have revived ourselves.</span>")
	user.mind.changeling.purchasedpowers -= src
	return TRUE

/obj/effect/proc_holder/changeling/revive/can_be_used_by(mob/user)
	if((user.stat != DEAD) && !(user.status_flags & FAKEDEATH))
		user.mind.changeling.purchasedpowers -= src
		return 0
	. = ..()
