/obj/item/weapon/implant
	name = "implant"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "rom"//Normally, you shouldn't see these. However, they can show up in the game via certain sources, like soul-stoning.
	var/implanted = null
	var/mob/imp_in = null
	item_color = "b"
	var/allow_reagents = 0


/obj/item/weapon/implant/proc/trigger(emote, mob/source)
	return


/obj/item/weapon/implant/proc/activate()
	return


//What does the implant do upon injection?
//return 0 if the implant fails (ex. Revhead and loyalty implant.)
//return 1 if the implant succeeds (ex. Nonrevhead and loyalty implant.)
/obj/item/weapon/implant/proc/implanted(var/mob/source)
	return 1


/obj/item/weapon/implant/proc/get_data()
	return "No information available"

/obj/item/weapon/implant/dropped(mob/user as mob)
	. = 1
	del src
	return .

/obj/item/weapon/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	var/id = 1.0

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



/obj/item/weapon/implant/explosive
	name = "explosive implant"
	desc = "And boom goes the weasel."

/obj/item/weapon/implant/explosive/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-78 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Explodes<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Explodes<BR>
				<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
	return dat

/obj/item/weapon/implant/explosive/trigger(emote, mob/source)
	if(emote == "deathgasp")
		activate("death")

/obj/item/weapon/implant/explosive/activate(var/cause)
	if(!cause || !imp_in)	return 0
	explosion(src, -1, 0, 2, 3, 0)	//This might be a bit much, dono will have to see.
	if(imp_in)
		imp_in.gib()


/obj/item/weapon/implant/chem
	name = "chem implant"
	desc = "Injects things."
	allow_reagents = 1

/obj/item/weapon/implant/chem/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
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

/obj/item/weapon/implant/chem/New()
	..()
	create_reagents(50)

/obj/item/weapon/implant/chem/trigger(emote, mob/source)
	if(emote == "deathgasp")
		activate(reagents.total_volume)

/obj/item/weapon/implant/chem/activate(var/cause)
	if(!cause || !imp_in)	return 0
	var/mob/living/carbon/R = imp_in
	reagents.trans_to(R, cause)
	R << "You hear a faint *beep*."
	if(!reagents.total_volume)
		R << "You hear a faint click from your chest."
		del(src)


/obj/item/weapon/implant/loyalty
	name = "loyalty implant"
	desc = "Makes you loyal or such."

/obj/item/weapon/implant/loyalty/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
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
	if(!ishuman(M))	return 0
	var/mob/living/carbon/human/H = M
	if(H.mind in ticker.mode.head_revolutionaries)
		H.visible_message("<span class='warning'>[H] seems to resist the implant!</span>", "<span class='warning'>You feel the corporate tendrils of Nanotrasen try to invade your mind!</span>")
		return 0
	else if(H.mind in ticker.mode:revolutionaries)
		ticker.mode:remove_revolutionary(H.mind)
	H << "<span class='notice'>You feel a surge of loyalty towards Nanotrasen.</span>"
	return 1


/obj/item/weapon/implant/adrenalin
	name = "adrenal implant"
	desc = "Removes all stuns and knockdowns."
	var/uses = 3

/obj/item/weapon/implant/adrenalin/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries Adrenaline Implant<BR>
				<b>Life:</b> Five days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Subjects injected with implant can activate an injection of medical cocktails.<BR>
				<b>Function:</b> Removes stuns, increases speed, and has a mild healing effect.<BR>
				<b>Integrity:</b> Implant can only be used three times before reserves are depleted."}
	return dat

/obj/item/weapon/implant/adrenalin/trigger(emote, mob/source)
	if(uses < 1)	return 0
	if(emote == "scream")
		uses--
		source << "<span class='notice'>You feel a sudden surge of energy!</span>"
		source.SetStunned(0)
		source.SetWeakened(0)
		source.SetParalysis(0)
		source.lying = 0
		source.update_canmove()

		source.reagents.add_reagent("synaptizine", 10)
		source.reagents.add_reagent("tricordrazine", 10)
		source.reagents.add_reagent("hyperzine", 10)

/obj/item/weapon/implant/adrenalin/implanted(mob/source)
	source.mind.store_memory("An adrenal implant can be activated by using the scream emote, <B>say *scream</B> to attempt to activate.", 0, 0)
	source << "<span class='notice'>The implanted adrenaline implant can be activated by using the scream emote, <B>say *scream</B> to attempt to activate.</span>"
	return 1


/obj/item/weapon/implant/emp
	name = "emp implant"
	desc = "Triggers an EMP."

	var/activation_emote = "chuckle"
	var/uses = 1

/obj/item/weapon/implant/emp/New()
	activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	..()
	return

/obj/item/weapon/implant/emp/trigger(emote, mob/living/carbon/source as mob)
	if (src.uses < 1)	return 0
	if (emote == src.activation_emote)
		src.uses--
		empulse(source, 3, 5)
	return

/obj/item/weapon/implant/emp/implanted(mob/living/carbon/source)
		source.mind.store_memory("EMP implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
		source << "The implanted EMP implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."
		return 1