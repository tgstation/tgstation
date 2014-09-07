//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	item_color = "r"
	var/activation_emote = "chuckle"
	var/uses = 4.0


/obj/item/weapon/implant/freedom/New()
	src.activation_emote = "shrug"
	src.uses = 4
	..()
	return


/obj/item/weapon/implant/freedom/trigger(emote, mob/living/carbon/source as mob)
	if (src.uses < 1)	return 0
	if (emote == src.activation_emote)
		src.uses--
		source << "You feel a faint click."
		if (source.handcuffed)
			var/obj/item/weapon/W = source.handcuffed
			source.handcuffed = null
			source.update_inv_handcuffed(0)
			if (source.client)
				source.client.screen -= W
			if (W)
				W.loc = source.loc
				dropped(source)
				if (W)
					W.layer = initial(W.layer)
		if (source.legcuffed)
			var/obj/item/weapon/W = source.legcuffed
			source.legcuffed = null
			source.update_inv_legcuffed(0)
			if (source.client)
				source.client.screen -= W
			if (W)
				W.loc = source.loc
				dropped(source)
				if (W)
					W.layer = initial(W.layer)
	return


/obj/item/weapon/implant/freedom/implanted(mob/living/carbon/source)
	source.mind.store_memory("Freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	source << "The implanted freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."
	return 1


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


