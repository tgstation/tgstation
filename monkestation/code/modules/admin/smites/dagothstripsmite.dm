// The Dagoth Strip! To have something that doesn't kill but you still wanna humiliate someone! -Dexee

/datum/smite/dagothstripsmite
	name = "Dagoth STRIP"

/datum/smite/dagothstripsmite/effect(client/user, mob/living/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/human/Person = target
	to_chat(Person,span_ratvar("Why have you come unprepared?"))
	Person.unequip_everything()
	Person.Paralyze(15)
	playsound(target,'monkestation/sound/misc/dagothgod.ogg', 80)
	return

