// Note: BYOND is object oriented. There is no reason for this to be copy/pasted blood code.

/obj/effect/decal/cleanable/blood/xeno
	name = "pool of acid"
	// This is fetched in /datum/blood_type/xeno/set_up_blood() for all blood decals with default desc
	desc = "It's green and acidic. It looks like... <i>blood?</i>"
	color = /datum/blood_type/xeno::color // For mapper sanity

/obj/effect/decal/cleanable/blood/xeno/get_default_blood_type()
	return get_blood_type(BLOOD_TYPE_XENO)

/obj/effect/decal/cleanable/blood/splatter/xeno
	name = "pool of acid"
	color = /datum/blood_type/xeno::color // For mapper sanity

/obj/effect/decal/cleanable/blood/splatter/xeno/get_default_blood_type()
	return get_blood_type(BLOOD_TYPE_XENO)

/obj/effect/decal/cleanable/blood/gibs/xeno
	name = "xeno gibs"
	desc = "Gnarly..."
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")
	color = /datum/blood_type/xeno::color // For mapper sanity

/obj/effect/decal/cleanable/blood/gibs/xeno/get_default_blood_type()
	return get_blood_type(BLOOD_TYPE_XENO)

/obj/effect/decal/cleanable/blood/gibs/xeno/up
	icon_state = "xgibup1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/effect/decal/cleanable/blood/gibs/xeno/down
	icon_state = "xgibdown1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/effect/decal/cleanable/blood/gibs/xeno/body
	icon_state = "xgibtorso"
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/blood/gibs/xeno/torso
	icon_state = "xgibtorso"
	random_icon_states = list("xgibtorso")

/obj/effect/decal/cleanable/blood/gibs/xeno/limb
	icon_state = "xgibleg"
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/blood/gibs/xeno/core
	icon_state = "xgibmid1"
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/decal/cleanable/blood/gibs/xeno/larva
	icon_state = "xgiblarva1"
	random_icon_states = list("xgiblarva1", "xgiblarva2")

/obj/effect/decal/cleanable/blood/gibs/xeno/larva/body
	icon_state = "xgiblarvatorso"
	random_icon_states = list("xgiblarvahead", "xgiblarvatorso")

/obj/effect/decal/cleanable/blood/tracks/xeno
	color = /datum/blood_type/xeno::color // For mapper sanity

/obj/effect/decal/cleanable/blood/tracks/xeno/get_default_blood_type()
	return get_blood_type(BLOOD_TYPE_XENO)
