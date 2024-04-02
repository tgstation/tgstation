/obj/item/deployablemine
	name = "deployable mine"
	desc = "An unarmed landmine. It can be planted to arm it."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "landmine"
	var/mine_type = /obj/effect/mine
	var/arming_time = 3 SECONDS

/obj/item/deployablemine/afterattack(atom/plantspot, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(plantspot,/turf/open/floor))
		to_chat(user, span_warning("You can't plant the mine here!"))
		return
	to_chat(user, span_notice("You start arming the [src]..."))
	if(do_after(user, arming_time, src))
		new mine_type(plantspot)
		to_chat(user, span_notice("You plant and arm the [src]."))
		log_combat(user, src, "planted and armed")
		qdel(src)

/obj/item/deployablemine/stun
	desc = "An unarmed stun mine. It can be planted to arm it."
	mine_type = /obj/effect/mine/stun

/obj/item/deployablemine/heavy
	name = "deployable sledgehammer mine"
	desc = "An unarmed heavy stun mine designed to cripple those who step upon it."
	mine_type = /obj/effect/mine/stun/heavy
	arming_time = 10 SECONDS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/deployablemine/explosive
	mine_type = /obj/effect/mine/explosive

/obj/item/deployablemine/honk
	name = "deployable honkblaster 1000"
	desc = "An advanced pranking landmine for clowns, honk! Delivers an extra loud HONK to the head when triggered. It can be planted to arm it, or have its sound customised with a sound synthesiser."
	mine_type = /obj/effect/mine/sound
/** another time, another place.
/obj/item/deployablemine/traitor
	name = "exploding rubber duck"
	desc = "A pressure activated explosive disguised as a rubber duck. Plant it to arm."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	mine_type = /obj/effect/mine/explosive/traitor

/obj/item/deployablemine/traitor/bigboom
	name = "high yield exploding rubber duck"
	desc = "A pressure activated explosive disguised as a rubber duck. Plant it to arm. This version is fitted with high yield X4 for a larger blast."
	mine_type = /obj/effect/mine/explosive/traitor/bigboom
**/
/obj/item/deployablemine/gas
	name = "oxygen gas mine"
	desc = "An unarmed mine that releases oxygen into the air when triggered. Pretty pointless huh."
	mine_type = /obj/effect/mine/gas

/obj/item/deployablemine/plasma
	name = "incendiary mine"
	desc = "An unarmed mine that releases plasma into the air when triggered, then ignites it."
	mine_type = /obj/effect/mine/gas/plasma

/obj/item/deployablemine/sleepy
	name = "knockout mine"
	desc = "An unarmed mine that releases N2O into the air when triggered. Nighty Night!"
	mine_type = /obj/effect/mine/gas/n2o


