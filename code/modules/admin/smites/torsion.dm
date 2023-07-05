/// twist their nuts john
/datum/smite/torsion
	name = "Testicular Torsion (Gibs)"
	var/devastative_gib = FALSE

/datum/smite/torsion/configure(client/user)
	var/loop_input = tgui_alert(usr,"Gib how?", "Ouch", list("Gib with devastation", "Normal gib"))

	devastative_gib = (loop_input == "Gib with devastation")
	if(!(loop_input in list("Gib with devastation", "Normal gib")))
		return FALSE

/datum/smite/torsion/effect(client/user, mob/living/target)
	. = ..()
	playsound(get_turf(target), 'sound/effects/wounds/crack1.ogg', 100, TRUE, -1)
	target.emote("scream")
	to_chat(user, span_userdanger("You feel a horrible pain in your groin!"))
	if(devastative_gib)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), get_turf(target), 1), 1.5 SECONDS)
	else
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, gib)), 1.5 SECONDS)
