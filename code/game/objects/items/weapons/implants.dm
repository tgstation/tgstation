/*
CONTAINS:
IMPLANT CASE
TRACKER IMPLANT
IMPLANT PAD
FREEDOM IMPLANT
IMPLANTER

*/

/obj/item/weapon/implantcase/proc/update()
	if (src.imp)
		src.icon_state = text("implantcase-[]", src.imp.color)
	else
		src.icon_state = "implantcase-0"
	return

/obj/item/weapon/implantcase/attackby(obj/item/weapon/I as obj, mob/user as mob)
	..()
	if (istype(I, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.equipped() != I)
			return
		if ((!in_range(src, usr) && src.loc != user))
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Glass Case- '[]'", t)
		else
			src.name = "Glass Case"

	else if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		if(src.imp.reagents.total_volume >= 10)
			user << "\red [src] is full."
		else
			spawn(5)
				I.reagents.trans_to(src.imp, 5)
				user << "\blue You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units."
	else if (istype(I, /obj/item/weapon/implanter))
		if (I:imp)
			if ((src.imp || I:imp.implanted))
				return
			I:imp.loc = src
			src.imp = I:imp
			I:imp = null
			src.update()
			I:update()
		else
			if (src.imp)
				if (I:imp)
					return
				src.imp.loc = I
				I:imp = src.imp
				src.imp = null
				update()
			I:update()
	return

/obj/item/weapon/implantcase/tracking/New()

	src.imp = new /obj/item/weapon/implant/tracking( src )
	..()
	return

/obj/item/weapon/implantcase/explosive/New()

	src.imp = new /obj/item/weapon/implant/explosive( src )
	..()
	return

/obj/item/weapon/implant/chem/New()
	..()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src

/obj/item/weapon/implantcase/chem/New()

	src.imp = new /obj/item/weapon/implant/chem( src )
	..()
	return

/obj/item/weapon/implantpad/proc/update()

	if (src.case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return

/obj/item/weapon/implantpad/attack_hand(mob/user as mob)

	if ((src.case && (user.l_hand == src || user.r_hand == src)))
		if (user.hand)
			user.l_hand = src.case
		else
			user.r_hand = src.case
		src.case.loc = user
		src.case.layer = 20
		src.case.add_fingerprint(user)
		src.case = null
		user.update_clothing()
		src.add_fingerprint(user)
		update()
	else
		if (user.contents.Find(src))
			spawn( 0 )
				src.attack_self(user)
				return
		else
			return ..()
	return

/obj/item/weapon/implantpad/attackby(obj/item/weapon/implantcase/C as obj, mob/user as mob)
	..()
	if (istype(C, /obj/item/weapon/implantcase))
		if (!( src.case ))
			user.drop_item()
			C.loc = src
			src.case = C
	else
		return
	src.update()
	return

/obj/item/weapon/implantpad/attack_self(mob/user as mob)

	user.machine = src
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if (src.case)
		if (src.case.imp)
			if (istype(src.case.imp, /obj/item/weapon/implant/tracking))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Tracking Beacon<BR>
<b>Zone:</b> Spinal Column> 2-5 vertebrae<BR>
<b>Power Source:</b> Nervous System Ion Withdrawl Gradient<BR>
<b>Life:</b> 10 minutes after death of host<BR>
<b>Important Notes:</b> None<BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Continuously transmits low power signal on frequency- Useful for tracking.<BR>
Range: 35-40 meters<BR>
<b>Special Features:</b><BR>
<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
a malfunction occurs thereby securing safety of subject. The implant will melt and
disintegrate into bio-safe elements.<BR>
<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
circuitry. As a result neurotoxins can cause massive damage.<HR>
Implant Specifics:
Frequency (144.1-148.9):
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(T.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

ID (1-100):
<A href='byond://?src=\ref[src];id=-10'>-</A>
<A href='byond://?src=\ref[src];id=-1'>-</A> [T.id]
<A href='byond://?src=\ref[src];id=1'>+</A>
<A href='byond://?src=\ref[src];id=10'>+</A><BR>"}
			else if (istype(src.case.imp, /obj/item/weapon/implant/freedom))
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Freedom Beacon<BR>
<b>Zone:</b> Right Hand> Near wrist<BR>
<b>Power Source:</b> Lithium Ion Battery<BR>
<b>Life:</b> optimum 5 uses<BR>
<b>Important Notes: <font color='red'>Illegal</font></b><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
mechanisms<BR>
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system
<BR>
<b>Integrity:</b> The battery is extremely weak and commonly after injection its
life can drive down to only 1 use.<HR>
No Implant Specifics"}
			else if (istype(src.case.imp, /obj/item/weapon/implant/explosive))
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp RX-78 Prisoner Management Implant<BR>
<b>Zone:</b> Spinal Column>Atlantis Vertebrae<BR>
<b>Power Source:</b> Nervous System Ion Withdrawl Gradient<BR>
<b>Life:</b> Deactivates upon death but remains within the body.<BR>
<b>Important Notes:</b><BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal.<BR>
<b>Special Features:</b><BR>
<i>Direct-Interface</i>- You can use the prisoner management system to transmit short messages directly into the brain of the implanted subject.<BR>
<i>Safe-break</i>- Can be safely deactivated remotely.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
			else if (istype(src.case.imp, /obj/item/weapon/implant/chem))
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp MJ-420 Prisoner Management Implant<BR>
<b>Zone:</b> Abdominal Cavity>Abdominal Aorta<BR>
<b>Power Source:</b> Techno-organtic Metabolization System<BR>
<b>Life:</b> Deactivates upon death but remains within the body.<BR>
<b>Important Notes: Due to the system functioning off of nutrients in the implanted subject's body, the subject<BR>
will suffer from an increased appetite.</B><BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small capsule that can contain various chemicals. Upon receiving a specially encoded signal<BR>
the implant releases the chemicals directly into the blood stream.<BR>
<b>Special Features:</b><BR>
<i>Micro-Capsule</i>- Can be loaded with any sort of chemical agent via the common syringe and can hold 25 units.<BR>
Can only be loaded while still in it's original case.<BR>
<b>Integrity:</b> Implant will last so long as the subject is alive. However, if the subject suffers from malnutrition,<BR>
the implant may become unstable and either pre-maturely inject the subject or simply break."}
			else
				dat += "Implant ID not in database"
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(dat, "window=implantpad")
	onclose(user, "implantpad")
	return

/obj/item/weapon/implantpad/Topic(href, href_list)
	..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["freq"])
			if ((istype(src.case, /obj/item/weapon/implantcase) && istype(src.case.imp, /obj/item/weapon/implant/tracking)))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				T.frequency += text2num(href_list["freq"])
				T.frequency = sanitize_frequency(T.frequency)
		if (href_list["id"])
			if ((istype(src.case, /obj/item/weapon/implantcase) && istype(src.case.imp, /obj/item/weapon/implant/tracking)))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				T.id += text2num(href_list["id"])
				T.id = min(100, T.id)
				T.id = max(1, T.id)
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
				//Foreach goto(290)
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=implantpad")
		return
	return

/obj/item/weapon/implant/proc/trigger(emote, source as mob)
	return

/obj/item/weapon/implant/proc/implanted(source as mob)
	return

/obj/item/weapon/implant/freedom/New()
	src.activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	src.uses = rand(1, 5)
	..()
	return

/obj/item/weapon/implant/freedom/trigger(emote, mob/source as mob)
	if (src.uses < 1)
		return 0

	if (emote == src.activation_emote)
		src.uses--
		source << "You feel a faint click."

		if (source.handcuffed)
			var/obj/item/weapon/W = source.handcuffed
			source.handcuffed = null
			if (source.client)
				source.client.screen -= W
			if (W)
				W.loc = source.loc
				dropped(source)
				if (W)
					W.layer = initial(W.layer)

/obj/item/weapon/implant/freedom/implanted(mob/source as mob)
	source.mind.store_memory("Freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	source << "The implanted freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."

/obj/item/weapon/implanter/proc/update()

	if (src.imp)
		src.icon_state = "implanter1"
	else
		src.icon_state = "implanter0"
	return

/obj/item/weapon/implanter/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob/living/carbon))
		return

	if (user && src.imp)
		for (var/mob/O in viewers(M, null))
			O.show_message("\red [M] has been implanted by [user].", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with [src.name] ([src.imp.name])  by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] ([src.imp.name]) to implant [M.name] ([M.ckey])</font>")
		src.imp.loc = M
		src.imp.imp_in = M
		src.imp.implanted = 1
		src.imp.implanted(M)
		src.imp = null
		user.show_message("\red You implanted the implant into [M].")
		src.icon_state = "implanter0"


/obj/item/weapon/implant/uplink
	var/activation_emote = "chuckle"
	var/obj/item/weapon/syndicate_uplink/uplink = null

	New()
		activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
		uplink = new /obj/item/weapon/syndicate_uplink/implanted(src)
		..()

	implanted(mob/source as mob)
		source.mind.store_memory("Uplink implant can be activated by using the [activation_emote] emote, <B>say *[activation_emote]</B> to attempt to activate.", 0, 0)
		source << "The implanted uplink implant can be activated by using the [activation_emote] emote, <B>say *[activation_emote]</B> to attempt to activate."

	trigger(emote, mob/source as mob)
		if(emote == activation_emote)
			uplink.attack_self(source)