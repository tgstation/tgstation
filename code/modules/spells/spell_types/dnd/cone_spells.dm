/obj/effect/proc_holder/spell/cone/cold
	name = "Cone of Cold"
	desc = "Freezes things in a cone in front of you!"
	school = "evocation"
	charge_max = 100
	clothes_req = TRUE
	invocation = "CHEL AUT"

/obj/effect/proc_holder/spell/cone/cold/do_obj_cone_effect(var/obj/O)
	if(O.resistance_flags & FREEZE_PROOF)
		return
	if(!(O.obj_flags & FROZEN))
		O.make_frozen_visual()

/obj/effect/proc_holder/spell/cone/cold/do_mob_cone_effect(var/mob/M)
	if(isliving(M))
		var/mob/living/L = M
		L.bodytemperature = 20
		L.apply_status_effect(/datum/status_effect/freon)

/obj/effect/proc_holder/spell/cone/cold/do_turf_cone_effect(var/turf/T)
	if(isopenturf(T))
		var/turf/open/O = T
		O.MakeSlippery(TURF_WET_PERMAFROST, 600)
