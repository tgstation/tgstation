#define MALFUNCTION_TEMPORARY 1
#define MALFUNCTION_PERMANENT 2
/obj/item/weapon/implant
	name = "implant"
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	var/implanted = null
	var/mob/imp_in = null
	var/datum/organ/external/part = null
	_color = "b"
	var/allow_reagents = 0
	var/malfunction = 0

/obj/item/weapon/implant/proc/trigger(emote, source as mob)
	return

/obj/item/weapon/implant/proc/activate()
	return


// What does the implant do upon injection?
// return 0 if the implant fails (ex. Revhead and loyalty implant.)
// return 1 if the implant succeeds (ex. Nonrevhead and loyalty implant.)
/obj/item/weapon/implant/proc/implanted(var/mob/source)
	return 1

/obj/item/weapon/implant/proc/get_data()
	return "No information available"

/obj/item/weapon/implant/proc/hear(message, source as mob)
	return

/obj/item/weapon/implant/proc/islegal()
	return 0

/obj/item/weapon/implant/proc/meltdown()	//breaks it down, making implant unrecongizible
	to_chat(imp_in, "<span class = 'warning'> You feel something melting inside [part ? "your [part.display_name]" : "you"]!</span>")
	if (part)
		part.take_damage(burn = 15, used_weapon = "Electronics meltdown")
	else
		var/mob/living/M = imp_in
		M.apply_damage(15,BURN)
	name = "melted implant"
	desc = "Charred circuit in melted plastic case. Wonder what that used to be..."
	icon_state = "implant_melted"
	malfunction = MALFUNCTION_PERMANENT

/obj/item/weapon/implant/Destroy()
	if(part)
		part.implants.Remove(src)
	imp_in = null
	if(reagents)
		qdel(reagents)
	..()

var/global/tracking_implants = list() //fuck me

/obj/item/weapon/implant/tracking
	name = "tracking"
	desc = "Track with this."
	var/id = 1.0

/obj/item/weapon/implant/tracking/New()
	..()
	tracking_implants += src

/obj/item/weapon/implant/tracking/Destroy()
	..()
	tracking_implants -= src

/obj/item/weapon/implant/tracking/get_data()
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

/obj/item/weapon/implant/tracking/emp_act(severity)
	if (malfunction)	//no, dawg, you can't malfunction while you are malfunctioning
		return
	malfunction = MALFUNCTION_TEMPORARY

	var/delay = 20
	switch(severity)
		if(1)
			if(prob(60))
				meltdown()
		if(2)
			delay = rand(5 MINUTES, 15 MINUTES)

	spawn(delay)
		malfunction--

//BS12 Explosive
/obj/item/weapon/implant/explosive
	name = "explosive implant"
	desc = "A military grade micro bio-explosive. Highly dangerous."
	var/phrase = "supercalifragilisticexpialidocious"
	icon_state = "implant_evil"

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Robust Corp RX-78 Intimidation Class Implant<BR>
<b>Life:</b> Activates upon codephrase or detected death.<BR>
<b>Important Notes:</b> Explodes<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
<b>Special Features:</b> Explodes<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
		return dat

/obj/item/weapon/implant/explosive/Hear(var/datum/speech/speech, var/rendered_speech="")
	hear(speech.message)
	return

/obj/item/weapon/implant/explosive/hear(var/msg)
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	msg = sanitize_simple(msg, replacechars)
	if(findtext(msg, phrase))
		activate()

/obj/item/weapon/implant/explosive/trigger(emote, source as mob)
	if(emote == "deathgasp")
		activate()

/obj/item/weapon/implant/explosive/activate()
	if(malfunction == MALFUNCTION_PERMANENT)
		return
	if(istype(imp_in, /mob/))
		var/mob/M = imp_in

		message_admins("Explosive implant triggered in [M] ([M.key]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>) ")
		log_game("Explosive implant triggered in [M] ([M.key]).")

		var/turf/T = get_turf(M)

		explosion(T, 1, 3, 4, 6)
		T.hotspot_expose(3500, 125, surfaces = 1)

		qdel(src)

/obj/item/weapon/implant/explosive/implanted(mob/source as mob)
	phrase = input("Choose activation phrase:") as text
	var/list/replacechars = list("'" = "", "\"" = "", ">" = "", "<" = "", "(" = "", ")" = "")
	phrase = sanitize_simple(phrase, replacechars)
	usr.mind.store_memory("Explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
	to_chat(usr, "The implanted explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.")
	addHear()
	return 1

/obj/item/weapon/implant/explosive/emp_act(severity)
	if(malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY
	switch (severity)
		if(2.0)	//Weak EMP will make implant tear limbs off.
			if(prob(50))
				small_boom()
		if(1.0)	//Strong EMP will melt implant either making it go off, or disarming it
			if(prob(70))
				if(prob(50))
					small_boom()
				else
					if(prob(50))
						activate()		//50% chance of bye bye
					else
						meltdown()		//50% chance of implant disarming
	spawn(20)
		malfunction--

/obj/item/weapon/implant/explosive/islegal()
	return 0

/obj/item/weapon/implant/explosive/proc/small_boom()
	if(ishuman(imp_in) && part)
		imp_in.visible_message("<span class='warning'>Something beeps inside [imp_in][part ? "'s [part.display_name]" : ""]!</span>")
		playsound(loc, 'sound/items/countdown.ogg', 75, 1, -3)
		spawn(25)
			if(ishuman(imp_in) && part)
				//No tearing off these parts since it's pretty much killing
				//and you can't replace groins
				if(istype(part, /datum/organ/external/chest) || istype(part, /datum/organ/external/groin) || istype(part, /datum/organ/external/head))
					part.createwound(BRUISE, 60) //Mangle them instead
				else
					part.droplimb(1)
			explosion(get_turf(imp_in), -1, -1, 2, 3, 3)
			qdel(src)

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
<i>Micro-Capsule</i>- Can be loaded with any sort of chemical agent via the common syringe and can hold 50 units.<BR>
Can only be loaded while still in its original case.<BR>
<b>Integrity:</b> Implant will last so long as the subject is alive. However, if the subject suffers from malnutrition,<BR>
the implant may become unstable and either pre-maturely inject the subject or simply break."}
		return dat

/obj/item/weapon/implant/chem/trigger(emote, source as mob)
	if(emote == "deathgasp")
		src.activate(src.reagents.total_volume)
	return


/obj/item/weapon/implant/chem/activate(var/cause)
	if((!cause) || (!src.imp_in))	return 0
	var/mob/living/carbon/R = src.imp_in
	src.reagents.trans_to(R, cause)
	to_chat(R, "You hear a faint *beep*.")
	if(!src.reagents.total_volume)
		to_chat(R, "You hear a faint click from your chest.")
		spawn(0)
			del(src)
	return

/obj/item/weapon/implant/chem/emp_act(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY

	switch(severity)
		if(1)
			if(prob(60))
				activate(20)
		if(2)
			if(prob(30))
				activate(5)

	spawn(20)
		malfunction--

/obj/item/weapon/implant/chem/New()
	. = ..()
	create_reagents(50)

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


/obj/item/weapon/implant/loyalty/implanted(mob/M)
	if(!istype(M, /mob/living/carbon/human))	return 0
	var/mob/living/carbon/human/H = M
	if(H.mind in ticker.mode.head_revolutionaries)
		H.visible_message("[H] seems to resist the implant!", "You feel the corporate tendrils of Nanotrasen try to invade your mind!")
		return 0
	else if(H.mind in ticker.mode:revolutionaries)
		ticker.mode:remove_revolutionary(H.mind)
	to_chat(H, "<span class = 'notice'> You feel a surge of loyalty towards Nanotrasen.</span>")
	return 1

/obj/item/weapon/implant/traitor
	name = "Greytide Implant"
	desc = "Greytide Station wide"
	icon_state = "implant_evil"

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Greytide Mind-Slave Implant<BR>
<b>Life:</b> ??? <BR>
<b>Important Notes:</b> Any humanoid injected with this implant will become loyal to the injector and the greytide, unless of course the host is already loyal to someone else.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
<b>Special Features:</b> Glory to the Greytide!<BR>
<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
		return dat

/obj/item/weapon/implant/traitor/implanted(mob/M, mob/user)
	var/list/implanters
	var/ref = "\ref[user.mind]"
	if(!ishuman(M)) return 0
	if(!M.mind) return 0
	var/mob/living/carbon/human/H = M
	if(M == user)
		to_chat(user, "<span class='notice'>You feel quite stupid for doing that.</span>")
		if(isliving(user))
			user:brainloss += 10
		return
	if(locate(/obj/item/weapon/implant/traitor) in H.contents || locate(/obj/item/weapon/implant/traitor) in H.contents)
		H.visible_message("[H] seems to resist the implant!", "You feel a strange sensation in your head that quickly dissipates.")
		return 0
	else if(H.mind in ticker.mode.traitors)
		H.visible_message("[H] seems to resist the implant!", "You feel a familiar sensation in your head that quickly dissipates.")
		return 0
	H.implanting = 1
	to_chat(H, "<span class = 'notice'> You feel a surge of loyalty towards [user.name].</span>")
	if(!(user.mind in ticker.mode:implanter))
		ticker.mode:implanter[ref] = list()
	implanters = ticker.mode:implanter[ref]
	implanters.Add(H.mind)
	ticker.mode.implanted.Add(H.mind)
	ticker.mode.implanted[H.mind] = user.mind
	//ticker.mode:implanter[user.mind] += H.mind
	ticker.mode:implanter[ref] = implanters
	ticker.mode.traitors += H.mind
	H.mind.special_role = "traitor"
	to_chat(H, "<B><span class = 'warning'> You've been shown the Greytide by [user.name]!</B> You now must lay down your life to protect them and assist in their goals at any cost.</span>")
	var/datum/objective/protect/p = new
	p.owner = H.mind
	p.target = user:mind
	p.explanation_text = "Protect [user:real_name], the [user:mind:assigned_role=="MODE" ? (user:mind:special_role) : (user:mind:assigned_role)]."
	H.mind.objectives += p
	for(var/datum/objective/objective in H.mind.objectives)
		to_chat(H, "<B>Objective #1</B>: [objective.explanation_text]")
	ticker.mode.update_traitor_icons_added(H.mind)
	ticker.mode.update_traitor_icons_added(user.mind)
	log_admin("[ckey(user.key)] has mind-slaved [ckey(H.key)].")
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


/obj/item/weapon/implant/adrenalin/trigger(emote, mob/source as mob)
	if (src.uses < 1)	return 0
	if (emote == "pale")
		src.uses--
		to_chat(source, "<span class = 'notice'> You feel a sudden surge of energy!</span>")
		source.SetStunned(0)
		source.SetWeakened(0)
		source.SetParalysis(0)

	return


/obj/item/weapon/implant/adrenalin/implanted(mob/source)
		source.mind.store_memory("A implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.", 0, 0)
		to_chat(source, "The implanted freedom implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.")
		return 1


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

/obj/item/weapon/implant/death_alarm/process()
	if (!implanted || timestopped) return
	var/mob/M = imp_in

	if(isnull(M)) // If the mob got gibbed
		if(loc)
			if(loc:timestopped) return
		activate()
	else if(M.stat == 2)
		if(M.timestopped) return
		activate("death")

/obj/item/weapon/implant/death_alarm/activate(var/cause)
	var/mob/M = imp_in
	var/area/t = get_area(M)
	src.name = "\improper [mobname]'s Death Alarm"
	var/datum/speech/speech = create_speech("[mobname] has died in",1459,src)
	speech.name="[mobname]'s Death Alarm"
	speech.job="Death Alarm"
	speech.set_language(LANGUAGE_SOL_COMMON)
	switch (cause)
		if("death")
			if(!announcement_intercom || !istype(announcement_intercom))
				announcement_intercom = new(null)

			if(istype(t, /area/syndicate_station) || istype(t, /area/syndicate_mothership) || istype(t, /area/shuttle/syndicate_elite) )
				//give the syndies a bit of stealth
				speech.message="[mobname] has died in Space!"
			else
				speech.message="[mobname] has died in [t.name]!"
			processing_objects.Remove(src)
		if ("emp")
			var/name = prob(50) ? t.name : pick(teleportlocs)
			speech.message="[mobname] has died in [name]!"
		else
			speech.message="[mobname] has died-zzzzt in-in-in..."
			processing_objects.Remove(src)
	Broadcast_Message(speech, vmask=0, data=0, compression=0, level=list(0,1))
	returnToPool(speech)

/obj/item/weapon/implant/death_alarm/emp_act(severity)			//for some reason alarms stop going off in case they are emp'd, even without this
	if (malfunction)		//so I'm just going to add a meltdown chance here
		return
	malfunction = MALFUNCTION_TEMPORARY

	activate("emp")	//let's shout that this dude is dead
	if(severity == 1)
		if(prob(40))	//small chance of obvious meltdown
			meltdown()
		else if (prob(60))	//but more likely it will just quietly die
			malfunction = MALFUNCTION_PERMANENT
		processing_objects.Remove(src)

	spawn(20)
		malfunction--

/obj/item/weapon/implant/death_alarm/implanted(mob/source as mob)
	mobname = source.real_name
	processing_objects.Add(src)
	return 1

/obj/item/weapon/implant/compressed
	name = "compressed matter implant"
	desc = "Based on compressed matter technology, can store a single item."
	icon_state = "implant_evil"
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

/obj/item/weapon/implant/compressed/trigger(emote, mob/source as mob)
	if (src.scanned == null)
		return 0

	if (emote == src.activation_emote)
		to_chat(source, "The air glows as \the [src.scanned.name] uncompresses.")
		activate()

/obj/item/weapon/implant/compressed/activate()
	var/turf/t = get_turf(src)
	if (imp_in)
		imp_in.put_in_hands(scanned)
	else
		scanned.loc = t
	del src

/obj/item/weapon/implant/compressed/implanted(mob/source as mob)
	src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	if (source.mind)
		source.mind.store_memory("Compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	to_chat(source, "The implanted compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1

/obj/item/weapon/implant/compressed/islegal()
	return 0

/obj/item/weapon/implant/cortical
	name = "cortical stack"
	desc = "A fist-sized mass of biocircuits and chips."
