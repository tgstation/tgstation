/obj/item/weapon/implant
	name = "implant"
	desc = "An implant. Not usually seen outside a body."
	icon = 'items.dmi'
	icon_state = "implant"
	var/implanted = null
	var/mob/imp_in = null
	color = "b"
	var/allow_reagents = 0

	proc/trigger(emote, source as mob)
		return

	proc/activate()
		return

	proc/implanted(source as mob)
		return

	proc/get_data()
		return

	proc/hear(message, source as mob)
		return


	trigger(emote, source as mob)
		return


	activate()
		return

	attackby(obj/item/weapon/I as obj, mob/user as mob)
		..()
		if (istype(I, /obj/item/weapon/implanter))
			if (I:imp)
				return
			else
				src.loc = I
				I:imp = src
//				del(src)
			I:update()
		return

	implanted(source as mob)
		return


	get_data()
		return "No information available"

	hear(message, source as mob)
		return



/obj/item/weapon/implant/uplink
	name = "uplink implant"
	desc = "A micro-telecrystal implant which allows for instant transportation of equipment."
	var/activation_emote = "chuckle"
	var/obj/item/device/uplink/radio/uplink = null


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
	name = "tracking implant"
	desc = "An implant which relays information to the appropriate tracking computer."
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


//Nuke Agent Explosive
/obj/item/weapon/implant/dexplosive
	name = "explosive implant"
	desc = "A military grade micro bio-explosive. Highly dangerous."
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
	name = "chemical implant"
	desc = "A micro-injector that can be triggered remotely."
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
	name = "loyalty implant"
	desc = "An implant which contains a small pod of nanobots which manipulate host mental functions to induce loyalty."

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
			H.visible_message("[H] seems to resist the implant!", "You feel the corporate tendrils of NanoTrasen try to invade your mind!")
			return
		else if(H.mind in ticker.mode:revolutionaries)
			ticker.mode:remove_revolutionary(H.mind)
		H << "\blue You feel a surge of loyalty towards NanoTrasen."
		return


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


	implanted(mob/source as mob)
		source.mind.store_memory("A implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.", 0, 0)
		source << "The implanted freedom implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate."
		return


//BS12 Explosive
/obj/item/weapon/implant/explosive
	name = "explosive implant"
	desc = "A military grade micro bio-explosive. Highly dangerous."
	var/phrase = "supercalifragilisticexpialidocious"


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
		var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "")
		msg = sanitize_simple(msg, replacechars)
		if(findtext(msg,phrase))
			if(istype(imp_in, /mob/))
				var/mob/T = imp_in
				T.gib()
			explosion(get_turf(imp_in), 1, 3, 4, 6, 3)
			var/turf/t = get_turf(imp_in)
			if(t)
				t.hotspot_expose(3500,125)
			del(src)

	implanted(mob/source as mob)
		phrase = input("Choose activation phrase:") as text
		var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "")
		phrase = sanitize_simple(phrase, replacechars)
		usr.mind.store_memory("Explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
		usr << "The implanted explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate."

/obj/item/weapon/implant/death_alarm
	name = "death alarm implant"
	desc = "An alarm which monitors host vital signs and transmits a radio message upon death."
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
		var/mob/M = imp_in

		var/area/t = get_area(M)

		if(isnull(M)) // If the mob got gibbed
			var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
			a.autosay("states, \"[mobname] has died-zzzzt in-in-in...\"", "[mobname]'s Death Alarm")
			del(a)
			processing_objects.Remove(src)
		else if(M.stat == 2)
			var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
			if(istype(t, /area/syndicate_station) || istype(t, /area/syndicate_mothership) || istype(t, /area/shuttle/syndicate_elite) )
				//give the syndies a bit of stealth
				a.autosay("states, \"[mobname] has died in Space!\"", "[mobname]'s Death Alarm")
			else
				a.autosay("states, \"[mobname] has died in [t.name]!\"", "[mobname]'s Death Alarm")
			del(a)
			processing_objects.Remove(src)


	implanted(mob/source as mob)
		mobname = source.real_name
		processing_objects.Add(src)

/obj/item/weapon/implant/compressed
	name = "compressed matter implant"
	desc = "Based on compressed matter technology, can store a single item."
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

/*// --------------------LASERS WORK FROM HERE, AUGMENTATIONS SHIZZLE----------------------
/obj/item/weapon/implant/augmentation/thermalscanner
	name = "Thermal Scanner Augmentation"
	desc = "Makes you see humans through walls"

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> NanoTrasen Thermal Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected with this device tend to be able to see lifeforms through life using thermal.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's eye functions.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat


	implanted(M as mob)
		if(istype(M, /mob/living/carbon/human))
			vision_flags = SEE_MOBS
			invisa_view = 2
			usr << "You suddenly start seeing body temperatures of whoever is around you."
		else
			usr << "This implant is not compatible!"
		return

/obj/item/weapon/implant/augmentation/mesonscanner
	name = "Meson Scanner Augmentation"
	desc = "Makes you see floor and wall layouts through walls."

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> NanoTrasen Meson Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected with this device tend to be able to see floor and wall layouts through walls.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's eye functions.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat


	implanted(M as mob)
		if(istype(M, /mob/living/carbon/human))
			vision_flags = SEE_TURFS
			usr << "You suddenly start seeing body temperatures of whoever is around you."
		else
			usr << "This implant is not compatible!"
		return

/obj/item/weapon/implant/augmentation/medicalhud
	name = "Medical HUD Augmentation"
	desc = "Makes you see the medical condition of a person."

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> NanoTrasen Med HUD Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected with this device tend to be able to see the medical condition of a person.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's eye functions.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat


	implanted(M as mob)
		if(istype(M, /mob/living/carbon/human))

			src.hud = new/obj/item/clothing/glasses/hud/health(src)
			usr << "You suddenly start seeing body temperatures of whoever is around you."
		else
			usr << "This implant is not compatible!"
		return

/obj/item/weapon/implant/augmentation/securityhud
	name = "Security HUD Augmentation"
	desc = "Makes you see the Security standings of a person."

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> NanoTrasen Sec HUD Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected with this device tend to be able to see the security standings of a person.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's eye functions.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat


	implanted(M as mob)
		if(istype(M, /mob/living/carbon/human))
			var/obj/item/clothing/glasses/hud/security/hud = null

			src.hud = new/obj/item/clothing/glasses/hud/security(src)

			usr << "You suddenly start seeing body temperatures of whoever is around you."
		else
			usr << "This implant is not compatible!"
		return*/