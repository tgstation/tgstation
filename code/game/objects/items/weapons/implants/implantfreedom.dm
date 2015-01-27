//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom"
	item_color = "r"
	var/uses = 4.0


/obj/item/weapon/implant/freedom/activate()
	if (src.uses < 1)	return 0
	src.uses--
	imp_in << "You feel a faint click."
	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		if (C_imp_in.handcuffed)
			var/obj/item/weapon/W = C_imp_in.handcuffed
			C_imp_in.handcuffed = null
			if(C_imp_in.buckled && C_imp_in.buckled.buckle_requires_restraints)
				C_imp_in.buckled.unbuckle_mob()
			C_imp_in.update_inv_handcuffed(0)
			if (C_imp_in.client)
				C_imp_in.client.screen -= W
			if (W)
				W.loc = C_imp_in.loc
				W.dropped(C_imp_in)
				if (W)
					W.layer = initial(W.layer)
		if (C_imp_in.legcuffed)
			var/obj/item/weapon/W = C_imp_in.legcuffed
			C_imp_in.legcuffed = null
			C_imp_in.update_inv_legcuffed(0)
			if (C_imp_in.client)
				C_imp_in.client.screen -= W
			if (W)
				W.loc = C_imp_in.loc
				W.dropped(C_imp_in)
				if (W)
					W.layer = initial(W.layer)


/obj/item/weapon/implant/freedom/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Freedom Beacon<BR>
<b>Life:</b> optimum 5 uses<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
mechanisms<BR>
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system<BR>
<b>Integrity:</b> The battery is extremely weak and commonly after injection its
life can drive down to only 1 use.<HR>
No Implant Specifics"}
	return dat


