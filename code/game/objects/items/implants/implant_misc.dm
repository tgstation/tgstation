/obj/item/implant/weapons_auth
	name = "firearms authentication implant"
	desc = "Lets you shoot your guns."
	icon_state = "auth"
	activated = 0

/obj/item/implant/weapons_auth/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Firearms Authentication Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Allows operation of implant-locked weaponry, preventing equipment from falling into enemy hands."}
	return dat


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
	uses--
	to_chat(imp_in, "<span class='notice'>You feel a sudden surge of energy!</span>")
	imp_in.SetStun(0)
	imp_in.SetKnockdown(0)
	imp_in.SetUnconscious(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.lying = 0
	imp_in.update_canmove()

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine", 10)
	imp_in.reagents.add_reagent("stimulants", 10)
	if(!uses)
		qdel(src)


/obj/item/implant/emp
	name = "emp implant"
	desc = "Triggers an EMP."
	icon_state = "emp"
	uses = 3

/obj/item/implant/emp/activate()
	uses--
	empulse(imp_in, 3, 5)
	if(!uses)
		qdel(src)


//Health Tracker Implant

/obj/item/implant/health
	name = "health implant"
	activated = 0
	var/healthstring = ""

/obj/item/implant/health/proc/sensehealth()
	if (!imp_in)
		return "ERROR"
	else
		if(isliving(imp_in))
			var/mob/living/L = imp_in
			healthstring = "<small>Oxygen Deprivation Damage => [round(L.getOxyLoss())]<br />Fire Damage => [round(L.getFireLoss())]<br />Toxin Damage => [round(L.getToxLoss())]<br />Brute Force Damage => [round(L.getBruteLoss())]</small>"
		if (!healthstring)
			healthstring = "ERROR"
		return healthstring

/obj/item/implant/radio
	name = "internal radio implant"
	desc = "Are you there God? It's me, Syndicate Comms Agent."
	activated = TRUE
	var/obj/item/device/radio/radio
	var/radio_key = /obj/item/device/encryptionkey/syndicate
	icon = 'icons/obj/radio.dmi'
	icon_state = "walkietalkie"

/obj/item/implant/radio/activate()
	// needs to be GLOB.deep_inventory_state otherwise it won't open
	radio.ui_interact(usr, "main", null, FALSE, null, GLOB.deep_inventory_state)

/obj/item/implant/radio/Initialize(mapload)
	. = ..()

	radio = new(src)
	// almost like an internal headset, but without the
	// "must be in ears to hear" restriction.
	radio.name = "internal radio"
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.keyslot = new radio_key
	radio.recalculateChannels()


/obj/item/implant/radio/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Internal Radio Implant<BR>
				<b>Life:</b> 24 hours<BR>
				<b>Implant Details:</b> Allows user to use an internal radio, useful if user expects equipment loss, or cannot equip conventional radios."}
	return dat

/obj/item/implanter/radio
	name = "implanter (internal radio)"
	imp_type = /obj/item/implant/radio

/obj/item/implant/health_monitor
	name = "health monitor implant"
	activated = TRUE
	var/obj/item/device/radio/internal_radio
	var/triggered_in_crit = FALSE

/obj/item/implant/health_monitor/Initialize()
	. = ..()
	internal_radio = new/obj/item/device/radio(src)
	internal_radio.keyslot = new /obj/item/device/encryptionkey/headset_med
	internal_radio.subspace_transmission = TRUE
	internal_radio.listening = FALSE
	internal_radio.broadcasting = FALSE
	internal_radio.recalculateChannels()

/obj/item/implant/health_monitor/removed(source, silent = 0, special = 0)
	if(..())
		if(iscarbon(source))
			var/mob/living/carbon/C = source
			C.adv_health_hud = FALSE
			to_chat(C, "<span class='notice'>You feel less in-tune with your body.</span>")

/obj/item/implant/health_monitor/implant(mob/living/target, mob/user, silent = 0)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adv_health_hud = TRUE
		to_chat(C, "<span class='notice'>You feel more in-tune with your body.</span>")
	return ..()

/obj/item/implant/health_monitor/on_life(mob/living/carbon/source)
	if(!triggered_in_crit && source.InCritical())
		triggered_in_crit = TRUE
		var/area/location = get_area(src)
		internal_radio.talk_into(src, "Medical emergency! [source] is in critical condition at [location]!", "Medical", SPAN_ROBOT)
	else
		triggered_in_crit = FALSE