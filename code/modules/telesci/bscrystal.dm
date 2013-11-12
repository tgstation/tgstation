// Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.

/obj/item/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	w_class = 1
	origin_tech = "bluespace=4;materials=3"

/obj/item/bluespace_crystal/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/bluespace_crystal/attack_self(var/mob/user)
	blink_mob(user)
	user.drop_item()
	user.visible_message("<span class='notice'>[user] crushes the [src]!</span>")
	del(src)

/obj/item/bluespace_crystal/proc/blink_mob(var/mob/living/L, var/brange = 7)
	var/turf/T = get_turf(L)
	var/turf/rand_turf = pick(range(L, brange) - T)
	playsound(T, 'sound/effects/phasein.ogg', 100, 1)
	do_teleport(L, rand_turf, 0)

/obj/item/bluespace_crystal/throw_impact(atom/hit_atom)
	..()
	if(isliving(hit_atom))
		blink_mob(hit_atom, 2)
	del(src)

// Artifical bluespace crystal, doesn't give you much research.

/obj/item/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	origin_tech = "bluespace=2"