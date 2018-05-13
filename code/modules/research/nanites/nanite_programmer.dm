/obj/machinery/nanite_programmer
	name = "nanite programmer"
	desc = "A device that can program nanite epipens to adjust their functionality."
	var/obj/item/reagent_containers/hypospray/medipen/nanite/sample
	var/datum/reagent/nanites/programmed/nanites
	circuit = /obj/item/circuitboard/machine/nanite_programmer
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_programmer"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE

/obj/machinery/nanite_programmer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/hypospray/medipen/nanite))
		var/obj/item/reagent_containers/hypospray/medipen/nanite/syringe = I
		if(!syringe.reagents.total_volume)
			to_chat(user, "<span class='notice'>[syringe] is spent!</span>")
			return
		if(sample)
			eject()
		if(user.transferItemToLoc(I, src))
			to_chat(user, "<span class='notice'>You insert [I] into [src]</span>")
			sample = I
			nanites = locate(/datum/reagent/nanites/programmed) in sample.reagents.reagent_list
	else
		..()

/obj/machinery/nanite_programmer/proc/eject()
	if(!sample)
		return
	sample.forceMove(drop_location())
	sample = null
	nanites = null

/obj/machinery/nanite_programmer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanite_programmer", name, 600, 800, master_ui, state)
		ui.open()

/obj/machinery/nanite_programmer/ui_data()
	var/list/data = list()
	var/has_nanites = istype(nanites)
	data["has_nanites"] = has_nanites
	if(has_nanites)
		data["name"] = nanites.name
		data["desc"] = nanites.description
		data["decay_rate"] = nanites.metabolization_rate
		data["can_trigger"] = nanites.can_trigger
		data["trigger_cost"] = nanites.trigger_cost

		data["activated"] = nanites.data["activated"]
		data["activation_delay"] = nanites.data["activation_delay"] * 2
		data["timer"] = nanites.data["timer"] * 2
		data["activation_code"] = nanites.data["activation_code"]
		data["deactivation_code"] = nanites.data["deactivation_code"]
		data["kill_code"] = nanites.data["kill_code"]
		data["trigger_code"] = nanites.data["trigger_code"]

		switch(nanites.data["timer_type"])
			if(NANITE_TIMER_DEACTIVATE)
				data["timer_type"] = "Deactivate"
			if(NANITE_TIMER_SELFDESTRUCT)
				data["timer_type"] = "Self-Destruct"
			if(NANITE_TIMER_TRIGGER)
				data["timer_type"] = "Trigger"
			if(NANITE_TIMER_RESET)
				data["timer_type"] = "Reset Activation Timer"

		if(istype(nanites, /datum/reagent/nanites/programmed/relay))
			var/datum/reagent/nanites/programmed/relay/S = nanites
			data["is_relay"] = TRUE
			data["relay_code"] = S.data["relay_code"]
	return data

/obj/machinery/nanite_programmer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			eject()
			. = TRUE
		if("toggle_active")
			nanites.data["activated"] = !nanites.data["activated"] //we don't use the activation procs since we aren't in a mob; they'll be handled in on_mob_add
			if(nanites.data["activated"])
				nanites.data["activation_delay"] = 0
			. = TRUE
		if("set_code")
			var/new_code = input("Set code (0000-9999):", name, null) as null|num
			if(!isnull(new_code))
				new_code = CLAMP(round(new_code, 1),0,9999)

			var/target_code = params["target_code"]
			switch(target_code)
				if("activation")
					nanites.data["activation_code"] = new_code
				if("deactivation")
					nanites.data["deactivation_code"] = new_code
				if("kill")
					nanites.data["kill_code"] = new_code
				if("trigger")
					nanites.data["trigger_code"] = new_code
				if("relay")
					if(istype(nanites, /datum/reagent/nanites/programmed/relay))
						var/datum/reagent/nanites/programmed/relay/S = nanites
						S.data["relay_code"] = new_code
			. = TRUE
		if("set_activation_delay")
			var/delay = input("Set activation delay in seconds (0-120):", name, nanites.data["activation_delay"]) as null|num
			if(!isnull(delay))
				delay *= 0.5 //ticks are every 2 seconds
				delay = CLAMP(round(delay, 1),0,60)
				nanites.data["activation_delay"] = delay
				if(delay)
					nanites.data["activated"] = FALSE
			. = TRUE
		if("set_timer")
			var/timer = input("Set timer in seconds (10-300):", name, nanites.data["timer"]) as null|num
			if(!isnull(timer))
				timer *= 0.5 //ticks are every 2 seconds
				timer = CLAMP(round(timer, 1),5,150)
				nanites.data["timer"] = timer
			. = TRUE
		if("set_timer_type")
			var/new_type = input("Choose the timer effect","Timer Effect") as null|anything in list("Deactivate","Self-Destruct","Trigger","Reset Activation Timer")
			if(new_type)
				switch(new_type)
					if("Deactivate")
						nanites.data["timer_type"] = NANITE_TIMER_DEACTIVATE
					if("Self-Destruct")
						nanites.data["timer_type"] = NANITE_TIMER_SELFDESTRUCT
					if("Trigger")
						nanites.data["timer_type"] = NANITE_TIMER_TRIGGER
					if("Reset Activation Timer")
						nanites.data["timer_type"] = NANITE_TIMER_RESET
			. = TRUE