//The base chumbiswork effect. Can have an alternate desc and will show up in the list of chumbiswork objects.
/obj/effect/chumbiswork
	name = "meme machine"
	desc = "Still don't know what it is."
	var/chumbiswork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to chumbiswork cultists instead of the normal description
	icon = 'icons/effects/chumbiswork_effects.dmi'
	icon_state = "ratvars_flame"
	anchored = TRUE
	density = FALSE
	opacity = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/effect/chumbiswork/Initialize()
	. = ..()
	GLOB.all_chumbiswork_objects += src

/obj/effect/chumbiswork/Destroy()
	GLOB.all_chumbiswork_objects -= src
	return ..()

/obj/effect/chumbiswork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && chumbiswork_desc)
		desc = chumbiswork_desc
	..()
	desc = initial(desc)