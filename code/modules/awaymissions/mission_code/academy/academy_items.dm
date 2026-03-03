//disabler wand
/obj/item/gun/magic/wand/nothing/disabler
    name = "wand of non harmful incapasitation"
    desc = "One of those magic wands you can buy from a costume vendor, this one however is not entirely useless, funny."
    ammo_type = /obj/item/ammo_casing/energy/disabler/smoothbore
    self_charging = TRUE


//real magic missile wand
/obj/item/gun/magic/wand/nothing/missile
    name = "wand of MISSILE"
    desc = "One of those magic wands you can buy from a costume vendor, this one however has a bunch of explosion/missile launcher stickers on it, its also obviously painted red."
    ammo_type = /obj/item/ammo_casing/rocket/heap
    color = "#FF0000"


//arrow wand
/obj/itme/gun/magic/wand/nothing/arrow
    name = "AWSOME WAND OF BULLET MURDER"
    desc = "What the fuck? it looks like one of those wands that you buy from the costume vendor but it has a sticker on it that says 'AWSOME WAND OF BULLET MURDER'"
    ammo_type = /obj/item/ammo_casing/arrow


//20mm wand
/obj/item/gun/magic/wand/nothing/anti_tank
    name = "wand of tank shell"
    desc = "One of those magic wands you can buy from a costume vendor, this one reaks of gunpowder and has a different aura however, be careful where you aim this"
    ammo_type = /obj/item/ammo_casing/mm20x138
    self_charging = TRUE

//the one boulder to rule them all, rust reference
/obj/item/boulder/true_boulder
	name = "One rock to rule them all"
	desc = "A stone that is well weighted and easy to hold, one side is easy and comfortable to hold, you could easily bash somebodys head in with this or mine a metal node."
	icon_state = "ore"
	icon = 'icons/obj/ore.dmi'
	item_flags = NO_MAT_REDEMPTION | SLOWS_WHILE_IN_HAND
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 25 // rock
	throw_range = 5
	force = 25 // the one rock to rule them all
	armour_penetration = 100 //the rock does not care what you wear
	block_chance = 25 // funny
	tk_throw_range = 0 // no fancy magic tricks with the rock
	throw_speed = 0.5
	slowdown = 2
	drag_slowdown = 1.5 // It's still a big rock.
