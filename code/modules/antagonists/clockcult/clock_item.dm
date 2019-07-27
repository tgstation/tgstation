//The base clockwork item. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/item/clockwork
	name = "meme blaster"
	desc = "What the fuck is this? It looks kinda like a frog."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clockwork/Initialize()
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	. = ..()
	desc = initial(desc)
