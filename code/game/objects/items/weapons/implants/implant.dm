/obj/item/weapon/implant
	name = "implant"
	var
		implanted = null
		mob/imp_in = null
		color = "b"
		allow_reagents = 0
	proc
		trigger(emote, source as mob)
		activate()
		implanted(source as mob)
		get_data()
		hear(message, source as mob)


	trigger(emote, source as mob)
		return


	activate()
		return


	implanted(source as mob)
		return


	get_data()
		return "No information available"

	hear(message, source as mob)
		return



/obj/item/weapon/implant/uplink
	name = "uplink"
	desc = "Summon things."
	var
		activation_emote = "chuckle"
		obj/item/device/uplink/radio/uplink = null


	New()
		activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
		uplink = new /obj/item/device/uplink/radio/implanted(src)
		..()
		return


	implanted(mob/source as mob)
		activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
		source.mind.store_memory("Uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
		source << "The implanted uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."
		return


	trigger(emote, mob/source as mob)
		if(emote == activation_emote)
			uplink.attack_self(source)
		return



/obj/item/weapon/implant/tracking
	name = "tracking"
	desc = "Track with this."
	var
		id = 1.0


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


//Nuke Agent Explosive
/obj/item/weapon/implant/dexplosive
	name = "explosive"
	desc = "And boom goes the weasel."
	var/activation_emote = "deathgasp"
	var/coded = 0

	New()
		verbs += /obj/item/weapon/implant/dexplosive/proc/set_emote

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
		if(emote == activation_emote)
			src.activate("death")
		return


	activate(var/cause)
		if((!cause) || (!src.imp_in))	return 0
		explosion(src, -1, 0, 2, 3, 0)//This might be a bit much, dono will have to see.
		if(src.imp_in)
			src.imp_in.gib()

	proc/set_emote()
		set name = "Set Emote"
		set category = "Object"
		set src in usr
		if(coded != 0)
			usr << "You've already set up your implant!"
			return
		activation_emote = input("Choose activation emote:") in list("deathgasp","blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
		usr.mind.store_memory("Explosive implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
		usr << "The implanted explosive implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."
		coded = 1
		verbs -= /obj/item/weapon/implant/dexplosive/proc/set_emote
		return



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
<i>Micro-Capsule</i>- Can be loaded with any sort of chemical agent via the common syringe and can hold 25 units.<BR>
Can only be loaded while still in it's original case.<BR>
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
<b>Name:</b> NanoTrasen Employee Management Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected with this device tend to be much more loyal to the company.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
<b>Integrity:</b> Degradation can occur within nanobots, re-application may be necessary to ensure full cooperation."}
		return dat


	implanted(M as mob)
		if(!istype(M, /mob/living/carbon/human))	return
		var/mob/living/carbon/human/H = M
		if(H.mind in ticker.mode.head_revolutionaries)
			for(var/mob/O in (viewers(M) -  M))
				O.show_message("\red [M] seems to resist the implant.", 1)
				M << "\red You resist the implant."
				return
		else if(H.mind in ticker.mode:revolutionaries)
			ticker.mode:remove_revolutionary(H.mind)
		H << "\blue You feel a surge of loyalty towards NanoTrasen."
		return


//BS12 Explosive
/obj/item/weapon/implant/explosive
	name = "explosive"
	desc = "And boom goes the weasel."
	var/phrase = "die"


	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp RX-78 Intimidation Class Implant<BR>
<b>Life:</b> Activates upon codephrase.<BR>
<b>Important Notes:</b> Explodes<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
<b>Special Features:</b> Explodes<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat

	hear_talk(mob/M as mob, msg)
		hear(msg)
		return

	hear(var/msg)
		if(findtext(msg,phrase))
			if(istype(loc, /mob/))
				var/mob/T = loc
				T.gib()
			explosion(find_loc(src), 1, 3, 4, 6, 3)
			var/turf/t = find_loc(src)
			if(t)
				t.hotspot_expose(3500,125)
			del(src)

	implanted(mob/source as mob)
		phrase = input("Choose activation phrase:") as text
		usr.mind.store_memory("Explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
		usr << "The implanted explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate."

/obj/item/weapon/implant/death_alarm
	name = "death alarm"
	desc = "Danger Will Robinson!"
	var/mobname = "Will Robinson"

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> NanoTrasen \"Profit Margin\" Class Employee Lifesign Sensor<BR>
<b>Life:</b> Activates upon death.<BR>
<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
<b>Special Features:</b> Alerts crew to crewmember death.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat

	process()
		var/mob/M = src.loc
		if(M.stat == 2)
			var/turf/t = get_turf(M)
			var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
			a.autosay("states, \"[mobname] has died in [t.loc.name]!\"", "[mobname]'s Death Alarm")
			del(a)
			processing_objects.Remove(src)


	implanted(mob/source as mob)
		mobname = source.real_name
		processing_objects.Add(src)

/obj/item/weapon/implant/compressed
	name = "compressed matter implant"
	desc = "*fwooomp*"
	var/activation_emote = "sigh"
	var/obj/item/scanned = null

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> NanoTrasen \"Profit Margin\" Class Employee Lifesign Sensor<BR>
<b>Life:</b> Activates upon death.<BR>
<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
<b>Special Features:</b> Alerts crew to crewmember death.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat

	trigger(emote, mob/source as mob)
		if (src.scanned == null)
			return 0

		if (emote == src.activation_emote)
			source << "The air glows as \the [src.scanned.name] uncompresses."
			var/turf/t = get_turf(source)
			src.scanned.loc = t
			del src

	implanted(mob/source as mob)
		src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
		source.mind.store_memory("Freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
		source << "The implanted freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."