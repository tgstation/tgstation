// Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.

/obj/item/weapon/ore/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "bluespace=6;materials=3"
	points = 50
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.
	refined_type = /obj/item/stack/sheet/bluespace_crystal

/obj/item/weapon/ore/bluespace_crystal/refined
	name = "refined bluespace crystal"
	points = 0
	refined_type = null

/obj/item/weapon/ore/bluespace_crystal/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/weapon/ore/bluespace_crystal/attack_self(mob/user)
	user.visible_message("<span class='warning'>[user] crushes [src]!</span>", "<span class='danger'>You crush [src]!</span>")
	PoolOrNew(/obj/effect/particle_effect/sparks, loc)
	playsound(src.loc, "sparks", 50, 1)
	blink_mob(user)
	user.unEquip(src)
	qdel(src)

/obj/item/weapon/ore/bluespace_crystal/proc/blink_mob(mob/living/L)
	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg')

/obj/item/weapon/ore/bluespace_crystal/throw_impact(atom/hit_atom)
	if(!..()) // not caught in mid-air
		visible_message("<span class='notice'>[src] fizzles and disappears upon impact!</span>")
		var/turf/T = get_turf(hit_atom)
		PoolOrNew(/obj/effect/particle_effect/sparks, T)
		playsound(src.loc, "sparks", 50, 1)
		if(isliving(hit_atom))
			blink_mob(hit_atom)
		qdel(src)

// Artifical bluespace crystal, doesn't give you much research.

/obj/item/weapon/ore/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	origin_tech = "bluespace=3;plasmatech=4"
	blink_range = 4 // Not as good as the organic stuff!
	points = 0 // nice try
	refined_type = null

// Polycrystals, aka stacks

/obj/item/stack/sheet/bluespace_crystal
	name = "bluespace polycrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "polycrystal"
	desc = "A stable polycrystal, made of fused-together bluespace crystals. You could probably break one off."
	origin_tech = "bluespace=6;materials=3"
	attack_verb = list("bluespace polybashed", "bluespace polybattered", "bluespace polybludgeoned", "bluespace polythrashed", "bluespace polysmashed")
	var/crystal_type = /obj/item/weapon/ore/bluespace_crystal/refined

/obj/item/stack/sheet/bluespace_crystal/attack_self(mob/user) // to prevent the construction menu from ever happening
	user << "<span class='warning'>You cannot crush the polycrystal in-hand, try breaking one off.</span>"
	return

/obj/item/stack/sheet/bluespace_crystal/attack_hand(mob/user)
	if (user.get_inactive_held_item() == src)
		if(zero_amount()) // in this case, a sanity check
			return
		var/BC = new crystal_type(src)
		user.put_in_hands(BC)
		amount--
		if (amount == 0)
			qdel(src)
			user << "<span class='notice'>You break the final crystal off.</span>"
		else user << "<span class='notice'>You break off a crystal.</span>"
	else
		..()
	return