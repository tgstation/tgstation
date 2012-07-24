//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/implant/freedom
	name = "freedom"
	desc = "Use this to escape from those evil Red Shirts."
	color = "r"
	var/activation_emote = "chuckle"
	var/uses = 1.0


	New()
		src.activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
		src.uses = rand(1, 5)
		..()
		return


	trigger(emote, mob/source as mob)
		if (src.uses < 1)	return 0
		if (emote == src.activation_emote)
			src.uses--
			source << "You feel a faint click."
			if (source.handcuffed)
				var/obj/item/weapon/W = source.handcuffed
				source.handcuffed = null
				source.update_inv_handcuffed()
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
				source.update_inv_legcuffed()
				if (source.client)
					source.client.screen -= W
				if (W)
					W.loc = source.loc
					dropped(source)
					if (W)
						W.layer = initial(W.layer)
		return


	implanted(mob/source as mob)
		source.mind.store_memory("Freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
		source << "The implanted freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."
		return


	get_data()
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


