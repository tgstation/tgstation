/obj/item/organ/genital/eggsack
	name 			= "Egg sack"
	desc 			= "An egg producing reproductive organ."
	icon_state 		= "egg_sack"
	icon 			= 'modular_citadel/icons/obj/genitals/ovipositor.dmi'
	zone 			= "groin"
	slot 			= "testicles"
	color			= null //don't use the /genital color since it already is colored
	w_class 		= 3
	internal = TRUE
	var/egg_girth = EGG_GIRTH_DEF
	var/cum_mult = CUM_RATE_MULT
	var/cum_rate = CUM_RATE
	var/cum_efficiency	= CUM_EFFICIENCY
	var/obj/item/organ/ovipositor/linked_ovi
