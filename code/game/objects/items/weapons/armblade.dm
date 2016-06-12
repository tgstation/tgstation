/obj/item/weapon/armblade
	name = "arm blade"
	desc = "A vicious looking blade made of flesh and bone that tears through people with horrifying ease."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "armblade"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 30
	sharpness = 1.5
	throwforce = 0
	throw_speed = 0
	throw_range = 0
	w_class = W_CLASS_LARGE
	attack_verb = list("attacks", "slashes", "rends", "slices", "tears", "rips", "shreds", "cuts")
	hitsound = "sound/weapons/bloodyslice.ogg"
	cant_drop = 1

/obj/item/weapon/armblade/IsShield()
    return 1

/obj/item/weapon/armblade/dropped()
	qdel(src)
