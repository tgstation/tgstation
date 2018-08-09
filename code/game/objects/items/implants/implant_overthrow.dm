/obj/item/implant/overthrow
	name = "overthrow implant"
	desc = "Wakes up syndicate sleeping agents."
	uses = 2

/obj/item/implant/overthrow/implant(mob/living/target, mob/user) // Should probably also delete any mindshield implant. Not sure.
	if(target && target.mind && user && user.mind)
		var/datum/mind/target_mind = target.mind
		var/datum/mind/user_mind = user.mind
		var/datum/antagonist/overthrow/TO = target_mind.has_antag_datum(/datum/antagonist/overthrow)
		var/datum/antagonist/overthrow/UO = user_mind.has_antag_datum(/datum/antagonist/overthrow)
		if(!UO)
			to_chat(user, "<span class='danger'>You don't know how to use this thing!</span>") // It needs a valid team to work, if you aren't an antag don't use this thing
			return FALSE
		if(TO)
			to_chat(user, "<span class='notice'>[target.name] woke up already, the implant would be ineffective against him!</span>")
			return FALSE
		target_mind.add_antag_datum(/datum/antagonist/overthrow, UO.team)
		add_logs(user, target, "implanted", "\a [name]")
		qdel(src)
		return TRUE

/obj/item/implanter/overthrow
	name = "implanter (overthrow)"
	imp_type = /obj/item/implant/overthrow

/obj/item/implantcase/overthrow
	name = "implant case - 'overthrow'"
	desc = "A glass case containing an overthrow implant."
	imp_type = /obj/item/implant/overthrow