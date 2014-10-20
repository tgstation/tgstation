
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

/obj/effect/decal/cleanable/blood/xtracks
	icon_state = "xtracks"
	random_icon_states = null

//Xeno blood burns\\

/atom/proc/xeno_acid_blood() //Muh OOP
	return

/obj/effect/decal/cleanable/blood/gibs/xeno/Crossed(atom/movable/O)
	O.xeno_acid_blood()

/obj/effect/decal/cleanable/trail_holder/Crossed(atom/movable/O)
	if(trail_type && trail_type == "xltrails") //This is messy but I'm not doing it with icon_states and trail_holders are snowflake magic shits
		O.xeno_acid_blood()

/obj/effect/decal/cleanable/blood/xeno/Crossed(atom/movable/O)
	O.xeno_acid_blood()

/obj/effect/decal/cleanable/blood/xtracks/Crossed(atom/movable/O)
	O.xeno_acid_blood()

/mob/living/xeno_acid_blood()
	apply_damage(10,BURN)
	src << "<span class='noticealien'>Stepping in the acid burns you!</span>"

/mob/living/carbon/alien/xeno_acid_blood()
	return //Alien blood doesn't harm aliens