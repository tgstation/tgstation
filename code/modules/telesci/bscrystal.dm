// Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.

/obj/item/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	w_class = 1
	origin_tech = "bluespace=4;materials=3"
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.


/obj/item/bluespace_crystal/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


/obj/item/bluespace_crystal/attack_self(var/mob/user)
	user.visible_message("<span class='warning'>[user] crushes [src]!</span>", "<span class='danger'>You crush [src]!</span>")
	PoolOrNew(/obj/effect/effect/sparks, loc)
	playsound(src.loc, "sparks", 50, 1)
	blink_mob(user)
	user.unEquip(src)
	qdel(src)

/obj/item/bluespace_crystal/proc/blink_mob(var/mob/living/L)
	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg')

/obj/item/bluespace_crystal/throw_impact(atom/hit_atom)
	..()
	visible_message("<span class='notice'>[src] fizzles and disappears upon impact!</span>")
	PoolOrNew(/obj/effect/effect/sparks, loc)
	playsound(src.loc, "sparks", 50, 1)
	if(isliving(hit_atom))
		blink_mob(hit_atom)
	qdel(src)

// Artifical bluespace crystal, doesn't give you much research.

/obj/item/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	origin_tech = "bluespace=2"
	blink_range = 4 // Not as good as the organic stuff!