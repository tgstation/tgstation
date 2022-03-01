/obj/item/book/granter/spell/circuit
	name = "Generic Circuit Spellbook"
	desc = "A spellbook which can grant a spell programmable using an integrated circuit. \
	This one is generic, with no code to handle spell-type-specific properties."
	remarks = list(span_boldnotice("reticulating splines..."), \
		span_boldnotice("initializing lists..."), \
		span_boldnotice("checking tick usage..."), \
		span_boldnotice("validating resource cache..."), \
		span_boldnotice("contacting hub..."))
	var/obj/item/circuit_component/spell_handler/handler = /obj/item/circuit_component/spell_handler
	var/list/obj/effect/proc_holder/spell/given_spells

/obj/item/book/granter/spell/circuit/Initialize(mapload)
	. = ..()
	handler = new handler
	AddComponent(/datum/component/shell, \
		unremovable_circuit_components = list(handler))

/obj/item/book/granter/spell/circuit/on_reading_start(mob/user)
	remarks += span_boldwarning("[generate_ion_law()] at [__FILE__]; [__LINE__]: src: [UNLINT(src)] usr: [user].")
	. = ..()

/obj/item/book/granter/spell/circuit/on_reading_stopped(mob/user)
	pop(remarks)
	. = ..()

/obj/item/book/granter/spell/circuit/on_reading_finished(mob/user)
	pop(remarks)
	var/obj/effect/proc_holder/spell/new_spell = new spell
	to_chat(user, span_notice("You feel like you've experienced enough to cast [new_spell]!"))
	LAZYADD(given_spells, new_spell)
	user.mind.AddSpell(new_spell)
	handler.register_spell(new_spell)
	user.log_message("learned the circuit spell [new_spell] from [src])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/spell/circuit/Destroy(force)
	. = ..()
	for(var/obj/effect/proc_holder/spell/spell in given_spells)
		qdel(spell)

/obj/item/book/granter/spell/circuit/already_known(mob/user)
	if(!spell)
		say("No spell to assign!")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
		return TRUE
	for(var/obj/effect/proc_holder/spell/given_spell in given_spells)
		if(given_spell in user.mind.spell_list)
			say("User already has spell!")
			playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
			return TRUE
	return FALSE

/obj/item/book/granter/spell/circuit/recoil(mob/user)
	say("Spell already assigned to other mob!")
	playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)

/obj/item/circuit_component/spell_handler
	display_name = "Circuit Spellbook"
	desc = "Controls the variables of the spells given by the spellbook."
	circuit_flags = CIRCUIT_FLAG_ADMIN | CIRCUIT_FLAG_INSTANT
	category = "Admin"
	var/obj/item/book/granter/spell/circuit/book
	var/list/datum/weakref/spells

	var/list/option_maps
	var/list/spell_var_ports
	var/datum/port/input/apply_vars_signal

	var/datum/port/output/spell_ref_port
	var/datum/port/output/user_port
	var/datum/port/output/targets_port
	var/datum/port/output/spell_learned_signal
	var/datum/port/output/spell_cast_signal

/obj/item/circuit_component/spell_handler/proc/define_option_maps()
	option_maps = list(
		"school" = list(
			"Unset" = SCHOOL_UNSET,
			"Holy" = SCHOOL_HOLY,
			"Mime" = SCHOOL_MIME,
			"Restoration" = SCHOOL_RESTORATION,
			"Evocation" = SCHOOL_EVOCATION,
			"Transmutation" = SCHOOL_TRANSMUTATION,
			"Translocation" = SCHOOL_TRANSLOCATION,
			"Conjuration" = SCHOOL_CONJURATION,
			"Necromancy" = SCHOOL_NECROMANCY,
			"Forbidden" = SCHOOL_FORBIDDEN,
		),
		"selection_type" = list(
			"View" = "view",
			"Range" = "range",
		),
		"charge_type" = list(
			"Recharge" = "recharge",
			"Charges" = "charges",
			"User Variable" = "holder_var",
		),
		"invocation_type" = list(
			"None" = INVOCATION_NONE,
			"Shout" = INVOCATION_SHOUT,
			"Whisper" = INVOCATION_WHISPER,
			"Emote" = INVOCATION_EMOTE,
		),
		"smoke_spread" = list(
			"None" = 0,
			"Harmless" = 1,
			"Harmful" = 2,
			"Sleep-inducing" = 3,
		),
	)

/obj/item/circuit_component/spell_handler/populate_ports()
	define_option_maps()
	spell_var_ports = list()
	populate_spell_var_ports()

	apply_vars_signal = add_input_port("Apply Vars To Spells", PORT_TYPE_SIGNAL, order = INFINITY)

	//Output ports
	spell_ref_port = add_output_port("Spell", PORT_TYPE_ATOM)
	user_port = add_output_port("User", PORT_TYPE_ATOM)
	spell_learned_signal = add_output_port("On Learned", PORT_TYPE_SIGNAL)
	populate_additional_output_ports()

	for(var/disabled_port in default_disabled_ports())
		input_ports -= spell_var_ports["disabled_port"]
	if(parent)
		SStgui.update_uis(parent)

/obj/item/circuit_component/spell_handler/proc/populate_spell_var_ports()
	//Basic Ports
	spell_var_ports["name"] = add_input_port("Name", PORT_TYPE_STRING, order = 1)
	spell_var_ports["desc"] = add_input_port("Desc", PORT_TYPE_STRING, order = 1)
	spell_var_ports["sound"] = add_input_port("Cast Sound", PORT_TYPE_STRING, order = 1)
	spell_var_ports["school"] = add_option_port("School", assoc_to_keys(option_maps["school"]), order = 1)
	spell_var_ports["range"] = add_input_port("Range", PORT_TYPE_NUMBER, order = 1)
	spell_var_ports["message"] = add_input_port("Message For Target", PORT_TYPE_STRING, order = 1)
	spell_var_ports["selection_type"] = add_option_port("Target Selection", assoc_to_keys(option_maps["selection_type"]), order = 1)

	//Charge Type Ports
	spell_var_ports["charge_type"] = add_option_port("Charge Type", assoc_to_keys(option_maps["charge_type"]), order = 1)
	spell_var_ports["charge_max"] = add_input_port("Charge Max", PORT_TYPE_NUMBER, order = 1.1)
	spell_var_ports["still_recharging_msg"] = add_input_port("Recharging Message", PORT_TYPE_STRING, order = 1.1)
	spell_var_ports["holder_var_type"] = add_input_port("User Variable", PORT_TYPE_STRING, order = 1.1)
	spell_var_ports["holder_var_amount"] = add_input_port("User Variable Change", PORT_TYPE_NUMBER, order = 1.1)

	//Restriction Ports
	spell_var_ports["clothes_req"] = add_input_port("Requires Casting Clothes", PORT_TYPE_NUMBER, order = 2)
	spell_var_ports["human_req"] = add_input_port("Only Castable By Humans", PORT_TYPE_NUMBER, order = 2)
	spell_var_ports["nonabstract_req"] = add_input_port("Only Castable By Physical Entities", PORT_TYPE_NUMBER, order = 2)
	spell_var_ports["stat_allowed"] = add_input_port("Castable While Incapacitated", PORT_TYPE_NUMBER, order = 2)
	spell_var_ports["phase_allowed"] = add_input_port("Castable While Jaunting", PORT_TYPE_NUMBER, order = 2)
	spell_var_ports["antimagic_allowed"] = add_input_port("Castable With Antimagic", PORT_TYPE_NUMBER, order = 2)
	spell_var_ports["player_lock"] = add_input_port("Requires Mind To Cast", PORT_TYPE_NUMBER, order = 2)
	spell_var_ports["centcom_cancast"] = add_input_port("Castable On Centcom Z-level", PORT_TYPE_NUMBER, order = 2)

	//Invocation Ports
	spell_var_ports["invocation_type"] = add_option_port("Invocation Type", assoc_to_keys(option_maps["invocation_type"]), order = 2)
	spell_var_ports["invocation"] = add_input_port("Invocation Phrase", PORT_TYPE_STRING, order = 2.1)
	spell_var_ports["invocation_emote_self"] = add_input_port("Invocation Emote", PORT_TYPE_STRING, order = 2.1)

	//Caster Overlay Ports
	spell_var_ports["overlay"] = add_input_port("Apply Overlay To Caster", PORT_TYPE_NUMBER, order = 3)
	spell_var_ports["overlay_icon"] = add_input_port("Overlay Icon", PORT_TYPE_ANY, order = 3.1)
	spell_var_ports["overlay_icon_state"] = add_input_port("Overlay Icon State", PORT_TYPE_STRING, order = 3.1)
	spell_var_ports["overlay_lifespan"] = add_input_port("Overlay Lifespan", PORT_TYPE_NUMBER, order = 3.1)

	//Sparks Ports
	spell_var_ports["sparks_spread"] = add_input_port("Spreads Sparks On Cast", PORT_TYPE_NUMBER, order = 4)
	spell_var_ports["sparks_amt"] = add_input_port("Spark Quantity", PORT_TYPE_NUMBER, order = 4.1)

	//Smoke Ports
	spell_var_ports["smoke_spread"] = add_option_port("Smoke Spread", assoc_to_keys(option_maps["smoke_spread"]), order = 5)
	spell_var_ports["smoke_amount"] = add_input_port("Smoke Quantity", PORT_TYPE_NUMBER, order = 5.1)

	//Action Icon Ports
	spell_var_ports["action_icon"] = add_input_port("Action Icon", PORT_TYPE_ANY, order = 6)
	spell_var_ports["action_icon_state"] = add_input_port("Action Icon State", PORT_TYPE_STRING, order = 6)
	spell_var_ports["action_background_icon_state"] = add_input_port("Action BG Icon State", PORT_TYPE_STRING, order = 6)

/obj/item/circuit_component/spell_handler/proc/populate_additional_output_ports()
	targets_port = add_output_port("Targets", PORT_TYPE_LIST(PORT_TYPE_ATOM))
	spell_cast_signal = add_output_port("On Cast", PORT_TYPE_INSTANT_SIGNAL)

/obj/item/circuit_component/spell_handler/proc/default_disabled_ports()
	return list(
		"holder_var_type",
		"holder_var_amount",
		"invocation_emote_self",
		"overlay_icon",
		"overlay_icon_state",
		"overlay_lifespan",
		"sparks_amount",
		"smoke_amount",
	)

/obj/item/circuit_component/spell_handler/register_shell(atom/movable/shell)
	if(!istype(shell, /obj/item/book/granter/spell/circuit))
		return
	book = shell
	if(book.handler != src)
		QDEL_NULL(book.handler)
		book.handler = src
	if(!ispath(book.spell, /obj/effect/proc_holder/spell))
		return
	var/obj/effect/proc_holder/spell/sample = new book.spell
	for(var/variable in spell_var_ports)
		if(sample.vars.Find(variable))
			var/datum/port/input/var_port = spell_var_ports[variable]
			var_port.set_input(sample.vars[variable])
	qdel(sample)
	for(var/obj/effect/proc_holder/spell/spell in book.given_spells)
		register_spell(spell)

/obj/item/circuit_component/spell_handler/proc/register_spell(obj/effect/proc_holder/spell/spell)
	LAZYOR(spells, WEAKREF(spell))
	apply_spell_vars(spell)
	if("handler" in spell.vars)
		spell.vv_edit_var("handler", src)

/obj/item/circuit_component/spell_handler/proc/apply_spell_vars(obj/effect/proc_holder/spell/spell)
	if(!istype(spell))
		return
	for(var/var_name in spell_var_ports)
		var/datum/port/input/var_port = spell_var_ports[var_name]
		if(!(var_port in input_ports))
			continue
		var/new_value
		if(var_name in option_maps)
			new_value = option_maps[var_name][var_port.value]
		else if(isweakref(var_port.value))
			var/datum/weakref/weakref = var_port.value
			new_value = weakref.resolve()
		else
			new_value = var_port.value
		spell.vv_edit_var(var_name, new_value)
	spell.action.name = spell.name
	spell.action.desc = spell.desc
	spell.action.icon_icon = spell.action_icon
	spell.action.button_icon_state = spell.action_icon_state
	spell.action.background_icon_state = spell.action_background_icon_state
	spell.action.UpdateButtonIcon()

/obj/item/circuit_component/spell_handler/pre_input_received(datum/port/input/port)
	var/list/ports_to_disable = list()
	var/list/ports_to_enable = list()

	handle_contextual_ports(port, ports_to_disable, ports_to_enable)

	for(var/port_to_disable in ports_to_disable)
		if(spell_var_ports[port_to_disable])
			var/datum/port/input/port_datum = spell_var_ports[port_to_disable]
			port_datum.disconnect_all(clear_value = FALSE)
			input_ports -= port_datum
	for(var/port_to_enable in ports_to_enable)
		if(spell_var_ports[port_to_enable])
			input_ports |= spell_var_ports[port_to_enable]
	if((ports_to_enable.len || ports_to_disable.len) && parent)
		sortTim(input_ports, /proc/cmp_port_order_asc)
		SStgui.update_uis(parent)

/obj/item/circuit_component/spell_handler/proc/handle_contextual_ports(datum/port/input/port, list/ports_to_disable, list/ports_to_enable)
	if(port == spell_var_ports["charge_type"])
		switch(port.value)
			if("Recharge", "Charges")
				ports_to_disable |= list("holder_var_type", "holder_var_amount")
				ports_to_enable |= list("charge_max", "still_recharging_msg")
			else
				ports_to_disable |= list("charge_max", "still_recharging_msg")
				ports_to_enable |= list("holder_var_type", "holder_var_amount")
	if(port == spell_var_ports["invocation_type"])
		switch(port.value)
			if("Shout", "Whisper")
				ports_to_disable |= "invocation_emote_self"
				ports_to_enable |= "invocation"
			if("Emote")
				ports_to_disable |= "invocation"
				ports_to_enable |= "invocation_emote_self"
			else
				ports_to_disable |= list("invocation", "invocation_emote_self")
	if(port == spell_var_ports["overlay"])
		if(port.value)
			ports_to_enable |= list("overlay_icon", "overlay_icon_state", "overlay_lifetime")
		else
			ports_to_disable |= list("overlay_icon", "overlay_icon_state", "overlay_lifetime")
	if(port == spell_var_ports["sparks_spread"])
		if(port.value)
			ports_to_enable |= "sparks_amount"
		else
			ports_to_disable |= "sparks_amount"
	if(port == spell_var_ports["smoke_spread"])
		if(port.value != "None")
			ports_to_enable |= "smoke_amount"
		else
			ports_to_disable |= "smoke_amount"

/obj/item/circuit_component/spell_handler/get_ui_notices()
	. = ..()
	. += create_ui_notice("On Learned sets: User, Spell", "orange", "info")
	. += get_additional_ui_notices()

/obj/item/circuit_component/spell_handler/proc/get_additional_ui_notices()
	return create_ui_notice("On Cast sets: User, Spell, Targets", "orange", "info")

/obj/item/circuit_component/spell_handler/input_received(datum/port/input/port, list/return_values)
	if(port == apply_vars_signal)
		for(var/datum/weakref/ref in spells)
			apply_spell_vars(ref.resolve())

/obj/item/circuit_component/spell_handler/proc/on_spell_learned(obj/effect/proc_holder/spell/spell, mob/user)
	spell_ref_port.set_output(spell)
	user_port.set_output(user)
	spell_learned_signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/spell_handler/proc/on_spell_cast(obj/effect/proc_holder/spell, mob/user, list/targets)
	SScircuit_component.queue_instant_run()
	spell_ref_port.set_output(spell)
	user_port.set_output(user)
	targets_port.set_output(targets)
	spell_cast_signal.set_output(COMPONENT_SIGNAL)
	SScircuit_component.execute_instant_run()
