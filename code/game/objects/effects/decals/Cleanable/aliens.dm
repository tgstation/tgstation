// Note: BYOND is object oriented. There is no reason for this to be copy/pasted blood code.

/obj/effect/decal/cleanable/blood/xeno
	name = "xeno blood"
	desc = "It's green and acidic. It looks like... <i>blood?</i>"
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")
	splatter_type = /obj/effect/decal/cleanable/blood/splatter/xeno

/obj/effect/decal/cleanable/blood/splatter/xeno
	random_icon_states = list("xgibbl1", "xgibbl2", "xgibbl3", "xgibbl4", "xgibbl5")

/obj/effect/decal/cleanable/blood/gibs/xeno
	name = "xeno gibs"
	desc = "Gnarly..."
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")

/obj/effect/decal/cleanable/blood/gibs/xeno/up
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/effect/decal/cleanable/blood/gibs/xeno/down
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/effect/decal/cleanable/blood/gibs/xeno/body
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/blood/gibs/xeno/limb
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/blood/gibs/xeno/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/decal/cleanable/blood/tracks/xeno
	icon_state = "xtracks"
	desc = "It's green and acidic. It looks like... <i>blood?</i>"



//Xeno blood melts you
/atom/proc/xeno_acid_blood() //Wrapper proc for blood + acid_act() interaction
	acid_act(10, 1, 5) //Arbitrary numbers

/atom/movable/xeno_acid_blood()
	if(!throwing)
		..()

/obj/item/projectile/xeno_acid_blood()
	return

/obj/effect/decal/cleanable/blood/gibs/xeno/Crossed(atom/movable/O)
	O.xeno_acid_blood()
	qdel(src)

/obj/effect/decal/cleanable/trail_holder/Crossed(atom/movable/O)
	//This is messy but I'm not doing it with icon_states and trail_holders are awkward to work with
	if(trail_type && trail_type == "xltrails")
		O.xeno_acid_blood()
		qdel(src)

/obj/effect/decal/cleanable/blood/xeno/Crossed(atom/movable/O)
	O.xeno_acid_blood()
	qdel(src)

/obj/effect/decal/cleanable/blood/tracks/xeno/Crossed(atom/movable/O)
	O.xeno_acid_blood()
	qdel(src)

/mob/living/carbon/alien/xeno_acid_blood()
	return //Alien blood doesn't harm aliens

/mob/living/carbon/human/xeno_acid_blood()
	if(shoes)
		if(!(shoes.acid_act(10, 1, 5)))
			return
	update_inv_shoes()
	apply_damage(10, BURN)
	src << "<span class='noticealien'>You step in acid!</span>"
	qdel(src)

