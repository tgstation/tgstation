/obj/item/device/integrated_electronics/analyzer
	name = "circuit analyzer"
	desc = "This tool can scan an assembly and generate code necessary to recreate it in a circuit printer."
	icon = 'icons/obj/assemblies/electronic_tools.dmi'
	icon_state = "analyzer"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL

/obj/item/device/integrated_electronics/analyzer/afterattack(var/atom/A, var/mob/living/user)
	if(istype(A, /obj/item/device/electronic_assembly))
		var/saved = SScircuit.save_electronic_assembly(A)
		if(saved)
			to_chat(user, "<span class='notice'>You scan [A].</span>")
			user << browse(saved, "window=circuit_scan;size=500x600;border=1;can_resize=1;can_close=1;can_minimize=1")
		else
			to_chat(user, "<span class='warning'>[A] is not complete enough to be encoded!</span>")
	else
		..()
