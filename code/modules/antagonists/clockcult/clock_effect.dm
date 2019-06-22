//The base clockwork effect. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/effect/clockwork
	name = "meme machine"
	desc = "Still don't know what it is."
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "ratvars_flame"
	anchored = TRUE
	density = FALSE
	opacity = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/effect/clockwork/Initialize()
	. = ..()
	GLOB.all_clockwork_objects += src

/obj/effect/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/effect/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	. = ..()
	desc = initial(desc)
