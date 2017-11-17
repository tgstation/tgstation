//Used for a super-simple "wiring" system for activating traps. The filaments don't exist physically, and can be cut from either end using wirecutters.
/obj/item/clockwork/brass_filaments
	name = "brass filaments"
	desc = "A spool of very thin brass wiring. It doesn't seem practical for electrical use..."
	clockwork_desc = "<span class='alloy'>A spool of brass filaments that can be used to link traps with triggers.\n\
	To use, use the spool on two objects to link them. You can remove the filaments from either side by using wirecutters.</span>"
	icon_state = "brass_filaments"
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	var/filaments = 50
	var/obj/structure/destructible/clockwork/trap/linking

/obj/item/clockwork/brass_filaments/Initialize(mapload, new_filaments)
	. = ..()
	if(new_filaments)
		filaments = new_filaments

/obj/item/clockwork/brass_filaments/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "It has [filaments] tiles worth of filament.")

/obj/item/clockwork/brass_filaments/attack_self(mob/living/user)
	if(linking && is_servant_of_ratvar(user))
		to_chat(user, "<span class='notice'>You reel in [src].</span>")
		linking = null

/obj/item/clockwork/brass_filaments/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, type))
		var/obj/item/clockwork/brass_filaments/F = I
		filaments += F.filaments
		qdel(F)
		to_chat(user, "<span class='notice'>You combine the two spools of filament.</span>")
		return
	..()
