//The base chumbiswork item. Can have an alternate desc and will show up in the list of chumbiswork objects.
/obj/item/chumbiswork
	name = "meme blaster"
	desc = "What the fuck is this? It looks kinda like a frog."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/chumbiswork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to chumbiswork cultists instead of the normal description
	icon = 'icons/obj/chumbiswork_objects.dmi'
	icon_state = "rare_pepe"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/chumbiswork/Initialize()
	. = ..()
	ratvar_act()
	GLOB.all_chumbiswork_objects += src

/obj/item/chumbiswork/Destroy()
	GLOB.all_chumbiswork_objects -= src
	return ..()

/obj/item/chumbiswork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && chumbiswork_desc)
		desc = chumbiswork_desc
	..()
	desc = initial(desc)
