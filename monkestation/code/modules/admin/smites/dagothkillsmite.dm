// Dagoth KILL Smite! (ported from Biblefart code) - Dexee
// tweaked the name of this to make it extremely apparent that someone's gonna get fucked up. completely and utterly apparent. will be making a separate funny smite that doesn't kill

/datum/smite/dagothkillsmite
	name = "Dagoth KILL Smite"

/datum/smite/dagothkillsmite/effect(client/user, mob/living/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/human/Person = target
	var/turf/Location = get_turf(target)
	var/turf/T = get_step(get_step(Person, NORTH), NORTH)
	to_chat(Person,span_ratvar("What a grand and intoxicating innocence. Perish."))
	T.Beam(Person, icon_state="lightning[rand(1,12)]", time = 1.5 SECONDS)
	Person.unequip_everything()
	Person.Paralyze(15)
	playsound(target,'sound/magic/lightningshock.ogg', 50, 1)
	playsound(target,'monkestation/sound/misc/dagothgod.ogg', 80)
	Person.electrocution_animation(15)
	spawn(15)
		Person.gib()
		playsound(Location,'sound/effects/explosion3.ogg', 75, 1)
	return
