/obj/item/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom"
	implant_color = "r"
	uses = 4

/obj/item/implant/freedom/activate()
	. = ..()
	if(!iscarbon(imp_in)) //Maybe make it not implantable on these guys?
		return

	var/mob/living/carbon/carbon_imp_in = imp_in
	if(!carbon_imp_in.handcuffed && !carbon_imp_in.legcuffed)
		balloon_alert(carbon_imp_in, "no restraints!")
		return

	uses--

	balloon_alert(carbon_imp_in, "bindings released!")
	carbon_imp_in.uncuff()
	if(!uses)
		balloon_alert(carbon_imp_in, "implant degraded!")
		qdel(src)

/obj/item/implant/freedom/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Freedom Beacon<BR>
<b>Life:</b> Optimum 4 uses<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
mechanisms. These signals will release any bindings on both the arms and legs.<BR>"}
	return dat

/obj/item/implanter/freedom
	name = "implanter (freedom)"
	imp_type = /obj/item/implant/freedom

/obj/item/implantcase/freedom
	name = "implant case - 'Freedom'"
	desc = "A glass case containing a freedom implant."
	imp_type = /obj/item/implant/freedom
