/datum/wires/vending
	holder_type = /obj/machinery/vending
	proper_name = "Vending Unit"
	/// Keeps track of which language is selected
	var/language_iterator = 1

/datum/wires/vending/New(atom/holder)
	wires = list(
		WIRE_THROW, WIRE_SHOCK, WIRE_SPEAKER,
		WIRE_CONTRABAND, WIRE_IDSCAN
	)
	add_duds(1)

	var/obj/machinery/vending/vending_machine = holder
	var/datum/language_holder/vending_languages = vending_machine.get_language_holder()

	if(!length(vending_languages.spoken_languages))
		CRASH("Vending machine [vending_machine] does not have any spoken languages in its language holder.")

	// synch the current language to the language_iterator
	for(var/i in vending_languages.spoken_languages)
		if(vending_languages.selected_language == vending_languages.spoken_languages[i])
			language_iterator = i
			break
	..()

/datum/wires/vending/interact(mob/user)
	var/obj/machinery/vending/vending_machine = holder
	if (!HAS_SILICON_ACCESS(user) && vending_machine.seconds_electrified && vending_machine.shock(user, 100))
		return

	return ..()

/datum/wires/vending/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/vending/vending_machine = holder
	if(!HAS_SILICON_ACCESS(user) && vending_machine.seconds_electrified)
		var/mob/living/carbon/carbon_user = user
		if (!istype(carbon_user) || carbon_user.should_electrocute(get_area(vending_machine)))
			return FALSE
	if(vending_machine.panel_open)
		return TRUE

/datum/wires/vending/get_status()
	var/obj/machinery/vending/vending_machine = holder
	var/datum/language_holder/vending_languages = vending_machine.get_language_holder()
	var/datum/language/current_language = GLOB.language_datum_instances[vending_languages.get_selected_language()]
	var/list/status = list()
	status += "The orange light is [vending_machine.seconds_electrified ? "on" : "off"]."
	status += "The red light is [vending_machine.shoot_inventory ? "off" : "blinking"]."
	status += "The green light is [vending_machine.extended_inventory ? "on" : "off"]."
	status += "A [vending_machine.scan_id ? "purple" : "yellow"] light is on."
	status += "A white light is [vending_machine.age_restrictions ? "on" : "off"]."
	status += "The speaker light is [vending_machine.shut_up ? "off" : "on"]. The language is set to [current_language.name]."
	return status

/datum/wires/vending/on_pulse(wire)
	var/obj/machinery/vending/vending_machine = holder
	var/datum/language_holder/vending_languages = vending_machine.get_language_holder()

	switch(wire)
		if(WIRE_THROW)
			vending_machine.shoot_inventory = !vending_machine.shoot_inventory
		if(WIRE_CONTRABAND)
			vending_machine.extended_inventory = !vending_machine.extended_inventory
		if(WIRE_SHOCK)
			vending_machine.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME
			vending_machine.shock(usr, 100)
		if(WIRE_IDSCAN)
			vending_machine.scan_id = !vending_machine.scan_id
		if(WIRE_SPEAKER)
			language_iterator %= length(vending_languages.spoken_languages)
			language_iterator += 1
			vending_languages.selected_language = vending_languages.spoken_languages[language_iterator]
		if(WIRE_AGELIMIT)
			vending_machine.age_restrictions = !vending_machine.age_restrictions

/datum/wires/vending/on_cut(wire, mend, source)
	var/obj/machinery/vending/vending_machine = holder
	switch(wire)
		if(WIRE_THROW)
			vending_machine.shoot_inventory = !mend
		if(WIRE_CONTRABAND)
			vending_machine.extended_inventory = FALSE
		if(WIRE_SHOCK)
			if (mend)
				vending_machine.seconds_electrified = MACHINE_NOT_ELECTRIFIED
			else
				vending_machine.seconds_electrified = MACHINE_ELECTRIFIED_PERMANENT
				vending_machine.shock(usr, 100)
		if(WIRE_IDSCAN)
			vending_machine.scan_id = mend
		if(WIRE_SPEAKER)
			vending_machine.shut_up = mend
