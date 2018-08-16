/obj/item/organ/genital/ovipositor
	name = "Ovipositor"
	desc = "An egg laying reproductive organ."
	icon_state = "ovi_knotted_2"
	icon = 'modular_citadel/icons/obj/genitals/ovipositor.dmi'
	zone = "groin"
	slot = "penis"
	w_class = 3
	shape = "knotted"
	size = 3
	var/length = 6								//inches
	var/girth  = 0
	var/girth_ratio = COCK_GIRTH_RATIO_DEF 		//citadel_defines.dm for these defines
	var/knot_girth_ratio = KNOT_GIRTH_RATIO_DEF
	var/list/oviflags = list()
	var/obj/item/organ/eggsack/linked_eggsack
