/obj/item/vibro_weapon/ninjasr
	block_chance = 25
	force = 13

/obj/item/clothing/head/sus_bowler
	name = "Odd Bowler"
	desc = "A deep black bowler. Inside the hat, there is a sleek red S, with a smaller X insignia embroidered within. On closer inspection, the brim feels oddly weighted..."
	icon_state = "bowler"
	inhand_icon_state = "bowler"
	force = 10
	throwforce = 45
	throw_speed = 5
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration = 30 //5 points less then a double esword!
	sharpness = SHARP_POINTY
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

///obj/item/clothing/head/sus_bowler/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	//var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
	//if(thrownby && !caught)
		//addtimer(CALLBACK(src, /atom/movable.proc/throw_at, thrownby, throw_range+2, throw_speed, null, TRUE), 1)
	//else
		//return ..()

///obj/item/clothing/head/sus_bowler/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	//if(ishuman(thrower))
		//var/mob/living/carbon/human/I = thrower
		//I.throw_mode_off(THROW_MODE_TOGGLE) //so they can catch it on the return.
	//return ..()

/obj/item/katana/weak/curator //This has the same stats as the curator's claymore
	desc = "An ancient Katana. Forged by... Well, it doesn't really say, but surely it's authentic! And sharp to boot!"
	force = 15
	block_chance = 30
	armour_penetration = 5
