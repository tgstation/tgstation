/obj/item/weapon/implant
	name = "implant"
	var/implanted = null
	var/mob/imp_in = null
	color = "b"
	var/allow_reagents = 0

	proc/trigger(emote, source as mob)
		return

	proc/activate()
		return
	// What does the implant do upon injection?
	// return 0 if the implant fails to persist (ex. Revhead and loyalty implant.)
	// return 1 if the implant succeeds (ex. Nonrevhead and loyalty implant.)
	proc/implanted(var/mob/source)
		return 1

	proc/get_data()
		return



	trigger(emote, source as mob)
		return


	activate()
		return


	implanted(mob/source)
		return 1


	get_data()
		return "No information available"



/obj/item/weapon/implant/uplink
	name = "uplink"
	desc = "Summon things."
	var/activation_emote = "chuckle"
	var/obj/item/device/uplink/radio/uplink = null


	New()
		activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
		uplink = new /obj/item/device/uplink/radio/implanted(src)
		..()
		return


	implanted(mob/source)
		activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
		source.mind.store_memory("Uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
		source << "The implanted uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."
		return 1


	trigger(emote, mob/source as mob)
		if(emote == activation_emote)
			uplink.attack_self(source)
		return



/obj/item/weapon/implant/tracking
	name = "tracking"
	desc = "Track with this."
	var/id = 1.0


	get_data()
		var/dat = {"<b>Implant Specifications:</b><BR>
<b>Name:</b> Tracking Beacon<BR>
<b>Life:</b> 10 minutes after death of host<BR>
<b>Important Notes:</b> None<BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
<b>Special Features:</b><BR>
<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
a malfunction occurs thereby securing safety of subject. The implant will melt and
disintegrate into bio-safe elements.<BR>
<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
circuitry. As a result neurotoxins can cause massive damage.<HR>
Implant Specifics:<BR>"}
		return dat



/obj/item/weapon/implant/explosive
	name = "explosive"
	desc = "And boom goes the weasel."


	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp RX-78 Employee Management Implant<BR>
<b>Life:</b> Activates upon death.<BR>
<b>Important Notes:</b> Explodes<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
<b>Special Features:</b> Explodes<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat


	trigger(emote, source as mob)
		if(emote == "deathgasp")
			src.activate("death")
		return


	activate(var/cause)
		if((!cause) || (!src.imp_in))	return 0
		explosion(src, -1, 0, 2, 3, 0)//This might be a bit much, dono will have to see.
		if(src.imp_in)
			src.imp_in.gib()



/obj/item/weapon/implant/chem
	name = "chem"
	desc = "Injects things."
	allow_reagents = 1

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp MJ-420 Prisoner Management Implant<BR>
<b>Life:</b> Deactivates upon death but remains within the body.<BR>
<b>Important Notes: Due to the system functioning off of nutrients in the implanted subject's body, the subject<BR>
will suffer from an increased appetite.</B><BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small capsule that can contain various chemicals. Upon receiving a specially encoded signal<BR>
the implant releases the chemicals directly into the blood stream.<BR>
<b>Special Features:</b>
<i>Micro-Capsule</i>- Can be loaded with any sort of chemical agent via the common syringe and can hold 15 units.<BR>
Can only be loaded while still in its original case.<BR>
<b>Integrity:</b> Implant will last so long as the subject is alive. However, if the subject suffers from malnutrition,<BR>
the implant may become unstable and either pre-maturely inject the subject or simply break."}
		return dat


	New()
		..()
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src


	trigger(emote, source as mob)
		if(emote == "deathgasp")
			src.activate(10)
		return


	activate(var/cause)
		if((!cause) || (!src.imp_in))	return 0
		var/mob/living/carbon/R = src.imp_in
		src.reagents.trans_to(R, cause)
		R << "You hear a faint *beep*."
		if(!src.reagents.total_volume)
			R << "You hear a faint click from your chest."
			spawn(0)
				del(src)
		return



/obj/item/weapon/implant/loyalty
	name = "loyalty"
	desc = "Makes you loyal or such."

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen Employee Management Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected with this device tend to be much more loyal to the company.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
		return dat


	implanted(mob/M)
		if(!istype(M, /mob/living/carbon/human))	return 0
		var/mob/living/carbon/human/H = M
		if(H.mind in ticker.mode.head_revolutionaries)
			H.visible_message("[H] seems to resist the implant!", "You feel the corporate tendrils of Nanotrasen try to invade your mind!")
			return 0
		else if(H.mind in ticker.mode:revolutionaries)
			ticker.mode:remove_revolutionary(H.mind)
		H << "\blue You feel a surge of loyalty towards Nanotrasen."
		return 1


/obj/item/weapon/implant/adrenalin
	name = "adrenalin"
	desc = "Removes all stuns and knockdowns."
	var/uses

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Cybersun Industries Adrenalin Implant<BR>
<b>Life:</b> Five days.<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> Subjects injected with implant can activate a massive injection of adrenalin.<BR>
<b>Function:</b> Contains nanobots to stimulate body to mass-produce Adrenalin.<BR>
<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
<b>Integrity:</b> Implant can only be used three times before the nanobots are depleted."}
		return dat


	trigger(emote, mob/source as mob)
		if (src.uses < 1)	return 0
		if (emote == "pale")
			src.uses--
			source << "\blue You feel a sudden surge of energy!"
			source.SetStunned(0)
			source.SetWeakened(0)
			source.SetParalysis(0)

		return


	implanted(mob/source)
		source.mind.store_memory("A implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.", 0, 0)
		source << "The implanted freedom implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate."
		return 1
