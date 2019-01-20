/datum/nanite_program
	var/name = "Generic Nanite Program"
	var/desc = "Warn a coder if you can read this."

	var/datum/component/nanites/nanites
	var/mob/living/host_mob

	var/use_rate = 0 			//Amount of nanites used while active
	var/unique = TRUE			//If there can be more than one copy in the same nanites
	var/can_trigger = FALSE		//If the nanites have a trigger function (used for the programming UI)
	var/trigger_cost = 0		//Amount of nanites required to trigger
	var/trigger_cooldown = 50	//Deciseconds required between each trigger activation
	var/next_trigger = 0		//World time required for the next trigger activation
	var/timer_counter = 0		//Counts up while active. Used for the timer and the activation delay.
	var/program_flags = NONE
	var/passive_enabled = FALSE //If the nanites have an on/off-style effect, it's tracked by this var

	var/list/rogue_types = list(/datum/nanite_program/glitch) //What this can turn into if it glitches.
	//As a rule of thumb, these should be:
	//A: simpler
	//B: negative
	//C: affecting the same parts of the body, roughly
	//B is mostly a consequence of A: it's always going to be simpler to cause damage than to repair it, so a software bug will not randomly make the flesh eating
	//nanites learn how to repair cells.
	//Given enough glitch-swapping you'll end up with stuff like necrotic or toxic nanites, which are very simple as they just try to eat what's in front of them
	//or just lie around polluting the blood


	//The following vars are customizable
	var/activated = TRUE 			//If FALSE, the program won't process, disables passive effects, can't trigger and doesn't consume nanites
	var/activation_delay = 0 		//Seconds before the program self-activates.
	var/timer = 0 					//Seconds before the timer effect activates. Starts counting AFTER the activation delay
	var/timer_type = NANITE_TIMER_DEACTIVATE //What happens when the timer runs out

	//Signal codes, these handle remote input to the nanites. If set to 0 they'll ignore signals.
	var/activation_code 	= 0 	//Code that activates the program [1-9999]
	var/deactivation_code 	= 0 	//Code that deactivates the program [1-9999]
	var/kill_code 			= 0		//Code that permanently removes the program [1-9999]
	var/trigger_code 		= 0 	//Code that triggers the program (if available) [1-9999]

	//Extra settings
	//Must be listed in text form, with the same title they'll be displayed in the programmer UI
	//Changing these values is handled by set_extra_setting()
	//Viewing these values is handled by get_extra_setting()
	//Copying these values is handled by copy_extra_settings_to()
	var/list/extra_settings = list()

/datum/nanite_program/triggered
	use_rate = 0
	trigger_cost = 5
	trigger_cooldown = 50
	can_trigger = TRUE

/datum/nanite_program/Destroy()
	if(host_mob)
		if(activated)
			deactivate()
		if(passive_enabled)
			disable_passive_effect()
	if(nanites)
		nanites.programs -= src
	return ..()

/datum/nanite_program/proc/copy()
	var/datum/nanite_program/new_program = new type()

	new_program.activated = activated
	new_program.activation_delay = activation_delay
	new_program.timer = timer
	new_program.timer_type = timer_type
	new_program.activation_code = activation_code
	new_program.deactivation_code = deactivation_code
	new_program.kill_code = kill_code
	new_program.trigger_code = trigger_code
	copy_extra_settings_to(new_program)

	return new_program

/datum/nanite_program/proc/copy_programming(datum/nanite_program/target, copy_activated = TRUE)
	if(copy_activated)
		target.activated = activated
	target.activation_delay = activation_delay
	target.timer = timer
	target.timer_type = timer_type
	target.activation_code = activation_code
	target.deactivation_code = deactivation_code
	target.kill_code = kill_code
	target.trigger_code = trigger_code
	copy_extra_settings_to(target)

/datum/nanite_program/proc/set_extra_setting(user, setting)
	return

/datum/nanite_program/proc/get_extra_setting(setting)
	return

/datum/nanite_program/proc/copy_extra_settings_to(datum/nanite_program/target)
	return

/datum/nanite_program/proc/on_add(datum/component/nanites/_nanites)
	nanites = _nanites
	if(nanites.host_mob)
		on_mob_add()

/datum/nanite_program/proc/on_mob_add()
	host_mob = nanites.host_mob
	if(activated) //apply activation effects if it starts active
		activate()

/datum/nanite_program/proc/toggle()
	if(!activated)
		activate()
	else
		deactivate()

/datum/nanite_program/proc/activate()
	activated = TRUE
	timer_counter = activation_delay

/datum/nanite_program/proc/deactivate()
	if(passive_enabled)
		disable_passive_effect()
	activated = FALSE

/datum/nanite_program/proc/on_process()
	timer_counter++

	if(activation_delay)
		if(activated && timer_counter < activation_delay)
			deactivate()
		else if(!activated && timer_counter >= activation_delay)
			activate()
	if(!activated)
		return

	if(timer && timer_counter > timer)
		if(timer_type == NANITE_TIMER_DEACTIVATE)
			deactivate()
		else if(timer_type == NANITE_TIMER_SELFDELETE)
			qdel(src)
		else if(can_trigger && timer_type == NANITE_TIMER_TRIGGER)
			trigger()
			timer_counter = activation_delay
		else if(timer_type == NANITE_TIMER_RESET)
			timer_counter = 0
	if(check_conditions() && consume_nanites(use_rate))
		if(!passive_enabled)
			enable_passive_effect()
		active_effect()
	else
		if(passive_enabled)
			disable_passive_effect()

//If false, disables active and passive effects, but doesn't consume nanites
//Can be used to avoid consuming nanites for nothing
/datum/nanite_program/proc/check_conditions()
	return TRUE

//Constantly procs as long as the program is active
/datum/nanite_program/proc/active_effect()
	return

//Procs once when the program activates
/datum/nanite_program/proc/enable_passive_effect()
	passive_enabled = TRUE

//Procs once when the program deactivates
/datum/nanite_program/proc/disable_passive_effect()
	passive_enabled = FALSE

/datum/nanite_program/proc/trigger()
	if(!activated)
		return FALSE
	if(world.time < next_trigger)
		return FALSE
	if(!consume_nanites(trigger_cost))
		return FALSE
	next_trigger = world.time + trigger_cooldown
	return TRUE

/datum/nanite_program/proc/consume_nanites(amount, force = FALSE)
	return nanites.consume_nanites(amount, force)

/datum/nanite_program/proc/on_emp(severity)
	if(program_flags & NANITE_EMP_IMMUNE)
		return
	if(prob(80 / severity))
		software_error()

/datum/nanite_program/proc/on_shock(shock_damage)
	if(!program_flags & NANITE_SHOCK_IMMUNE)
		if(prob(10))
			software_error()
		else if(prob(33))
			qdel(src)

/datum/nanite_program/proc/on_minor_shock()
	if(!program_flags & NANITE_SHOCK_IMMUNE)
		if(prob(10))
			software_error()

/datum/nanite_program/proc/on_death()
	return

/datum/nanite_program/proc/on_hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	return

/datum/nanite_program/proc/software_error(type)
	if(!type)
		type = rand(1,5)
	switch(type)
		if(1)
			qdel(src) //kill switch
			return
		if(2) //deprogram codes
			activation_code = 0
			deactivation_code = 0
			kill_code = 0
			trigger_code = 0
		if(3)
			toggle() //enable/disable
		if(4)
			if(can_trigger)
				trigger()
		if(5) //Program is scrambled and does something different
			var/rogue_type = pick(rogue_types)
			var/datum/nanite_program/rogue = new rogue_type
			nanites.add_program(null, rogue, src)
			qdel(src)

/datum/nanite_program/proc/receive_signal(code, source)
	if(activation_code && code == activation_code && !activated)
		activate()
		host_mob.investigate_log("'s [name] nanite program was activated by [source] with code [code].", INVESTIGATE_NANITES)
	else if(deactivation_code && code == deactivation_code && activated)
		deactivate()
		host_mob.investigate_log("'s [name] nanite program was deactivated by [source] with code [code].", INVESTIGATE_NANITES)
	if(can_trigger && trigger_code && code == trigger_code)
		trigger()
		host_mob.investigate_log("'s [name] nanite program was triggered by [source] with code [code].", INVESTIGATE_NANITES)
	if(kill_code && code == kill_code)
		host_mob.investigate_log("'s [name] nanite program was deleted by [source] with code [code].", INVESTIGATE_NANITES)
		qdel(src)

/datum/nanite_program/proc/get_timer_type_text()
	switch(timer_type)
		if(NANITE_TIMER_DEACTIVATE)
			return "Deactivate"
		if(NANITE_TIMER_SELFDELETE)
			return "Self-Delete"
		if(NANITE_TIMER_TRIGGER)
			return "Trigger"
		if(NANITE_TIMER_RESET)
			return "Reset Activation Timer"

