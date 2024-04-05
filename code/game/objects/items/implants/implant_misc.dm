/obj/item/implant/weapons_auth
	name = "firearms authentication implant"
	desc = "Lets you shoot your guns."
	icon_state = "auth"
	actions_types = null

/obj/item/implant/weapons_auth/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Firearms Authentication Implant<BR> \
		<b>Life:</b> 4 hours after death of host<BR> \
		<b>Implant Details:</b> <BR> \
		<b>Function:</b> Allows operation of implant-locked weaponry, preventing equipment from falling into enemy hands."

/obj/item/implanter/weapons_auth
	name = "implanter (weapon authentication)"
	imp_type = /obj/item/implant/weapons_auth

/obj/item/implant/adrenalin
	name = "adrenal implant"
	desc = "Removes all stuns."
	icon_state = "adrenal"
	uses = 3

/obj/item/implant/adrenalin/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries Adrenaline Implant<BR>
				<b>Life:</b> Five days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Subjects injected with implant can activate an injection of medical cocktails.<BR>
				<b>Function:</b> Removes stuns, increases speed, and has a mild healing effect.<BR>
				<b>Integrity:</b> Implant can only be used three times before reserves are depleted."}
	return dat

/obj/item/implant/adrenalin/activate()
	. = ..()
	uses--
	to_chat(imp_in, span_notice("You feel a sudden surge of energy!"))
	imp_in.SetStun(0)
	imp_in.SetKnockdown(0)
	imp_in.SetUnconscious(0)
	imp_in.SetParalyzed(0)
	imp_in.SetImmobilized(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.set_resting(FALSE)

	imp_in.reagents.add_reagent(/datum/reagent/medicine/synaptizine, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/omnizine, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/stimulants, 10)
	if(!uses)
		qdel(src)

/obj/item/implanter/adrenalin
	name = "implanter (adrenalin)"
	imp_type = /obj/item/implant/adrenalin

/obj/item/implant/emp
	name = "emp implant"
	desc = "Triggers an EMP."
	icon_state = "emp"
	uses = 3

/obj/item/implant/emp/activate()
	. = ..()
	uses--
	empulse(imp_in, 3, 5)
	if(!uses)
		qdel(src)

/obj/item/implanter/emp
	name = "implanter (EMP)"
	imp_type = /obj/item/implant/emp

/obj/item/implant/radio
	name = "internal radio implant"
	var/obj/item/radio/radio
	var/radio_key
	var/subspace_transmission = FALSE
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "walkietalkie"

/obj/item/implant/radio/activate()
	. = ..()
	// needs to be GLOB.deep_inventory_state otherwise it won't open
	radio.ui_interact(usr, state = GLOB.deep_inventory_state)

/obj/item/implant/radio/Initialize(mapload)
	. = ..()

	radio = new(src)
	// almost like an internal headset, but without the
	// "must be in ears to hear" restriction.
	radio.name = "internal radio"
	radio.subspace_transmission = subspace_transmission
	radio.canhear_range = 0
	if(radio_key)
		radio.keyslot = new radio_key
	radio.recalculateChannels()

/obj/item/implant/radio/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/item/implant/radio/mining
	radio_key = /obj/item/encryptionkey/headset_cargo

/obj/item/implant/radio/syndicate
	desc = "Are you there God? It's me, Syndicate Comms Agent."
	radio_key = /obj/item/encryptionkey/syndicate
	subspace_transmission = TRUE

/obj/item/implant/radio/slime
	name = "slime radio"
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "adamantine_resonator"
	radio_key = /obj/item/encryptionkey/headset_sci
	subspace_transmission = TRUE

/obj/item/implant/radio/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Internal Radio Implant<BR> \
		<b>Life:</b> 24 hours<BR> \
		<b>Implant Details:</b> Allows user to use an internal radio, useful if user expects equipment loss, or cannot equip conventional radios."

/obj/item/implanter/radio
	name = "implanter (internal radio)"
	imp_type = /obj/item/implant/radio

/obj/item/implanter/radio/syndicate
	name = "implanter (internal syndicate radio)"
	imp_type = /obj/item/implant/radio/syndicate

/obj/item/implant/empshield
	name = "EMP shield implant"
	desc = "An implant that completely protects from electro-magnetic pulses. It will shut down briefly if triggered too often."
	actions_types = null
	var/lastemp = 0
	var/numrecent = 0
	var/warning = TRUE
	var/overloadtimer = 10 SECONDS

/obj/item/implant/empshield/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(..())
		if(ishuman(target))
			target.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
			RegisterSignal(target, COMSIG_ATOM_EMP_ACT, PROC_REF(overloaded), target)
		return TRUE

/obj/item/implant/empshield/removed(mob/target, silent = FALSE, special = 0)
	if(..())
		if(ishuman(target))
			target.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
			UnregisterSignal(target, COMSIG_ATOM_EMP_ACT)
		return TRUE

/obj/item/implant/empshield/proc/overloaded(mob/living/target, severity)
	if(world.time - lastemp > overloadtimer)
		numrecent = 0
	numrecent += severity
	lastemp = world.time

	if(numrecent >= (5 * EMP_HEAVY) && ishuman(target))
		if(warning)
			to_chat(target, span_userdanger("You feel a twinge inside from your [src], you get the feeling it won't protect you anymore."))
			warning = FALSE
		target.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
		addtimer(CALLBACK(src, PROC_REF(refreshed), target), overloadtimer, TIMER_OVERRIDE | TIMER_UNIQUE)

/obj/item/implant/empshield/proc/refreshed(mob/living/target)
	to_chat(target, span_notice("A familiar feeling resonates from your [src], it seems to be functioning properly again."))
	warning = TRUE
	if(ishuman(target))
		target.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/obj/item/implanter/empshield
	name = "implanter (EMP shield)"
	imp_type = /obj/item/implant/empshield
