/obj/machinery/implantchair
	name = "mindshield implanter"
	desc = "Used to implant occupants with mindshield implants."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	density = TRUE
	opacity = FALSE

	var/ready = TRUE
	var/replenishing = FALSE

	var/ready_implants = 5
	var/max_implants = 5
	var/injection_cooldown = 60 SECONDS
	var/replenish_cooldown = 600 SECONDS
	var/implant_type = /obj/item/implant/mindshield
	var/auto_inject = FALSE
	var/auto_replenish = TRUE
	var/special = FALSE
	var/special_name = "special function"
	var/message_cooldown
	var/breakout_time = 60 SECONDS

/obj/machinery/implantchair/Initialize(mapload)
	. = ..()
	open_machine()
	update_appearance()

/obj/machinery/implantchair/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/implantchair/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ImplantChair", name)
		ui.open()

/obj/machinery/implantchair/ui_data()
	var/list/data = list()
	var/mob/living/mob_occupant = occupant

	data["occupied"] = mob_occupant ? 1 : 0
	data["open"] = state_open

	data["occupant"] = list()
	if(mob_occupant)
		data["occupant"]["name"] = mob_occupant.name
		data["occupant"]["stat"] = mob_occupant.stat

	data["special_name"] = special ? special_name : null
	data["ready_implants"] = ready_implants
	data["ready"] = ready
	data["replenishing"] = replenishing

	return data

/obj/machinery/implantchair/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("implant")
			implant(occupant, usr)
			. = TRUE

/obj/machinery/implantchair/proc/implant(mob/living/living_mob, mob/user)
	if (!istype(living_mob))
		return
	if(!ready_implants || !ready)
		return
	if(implant_action(living_mob, user))
		ready_implants--
		if(!replenishing && auto_replenish)
			replenishing = TRUE
			addtimer(CALLBACK(src, .proc/replenish), replenish_cooldown)
		if(injection_cooldown > 0)
			ready = FALSE
			addtimer(CALLBACK(src, .proc/set_ready), injection_cooldown)
	else
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 25, TRUE)
	update_appearance()

/obj/machinery/implantchair/proc/implant_action(mob/living/living_mob)
	var/obj/item/to_implant = new implant_type
	if(istype(to_implant, /obj/item/implant))
		var/obj/item/implant/implant = to_implant
		if(implant.implant(living_mob))
			visible_message(span_warning("[living_mob] is implanted by [src]."))
			return TRUE
	else if(istype(to_implant, /obj/item/organ))
		var/obj/item/organ/organ = to_implant
		organ.Insert(living_mob, FALSE, FALSE)
		visible_message(span_warning("[living_mob] is implanted by [src]."))
		return TRUE

/obj/machinery/implantchair/update_icon_state()
	icon_state = initial(icon_state)
	if(state_open)
		icon_state += "_open"
	if(occupant)
		icon_state += "_occupied"
	return ..()

/obj/machinery/implantchair/update_overlays()
	. = ..()
	if(ready)
		. += "ready"

/obj/machinery/implantchair/proc/replenish()
	if(ready_implants < max_implants)
		ready_implants++
	if(ready_implants < max_implants)
		addtimer(CALLBACK(src, "replenish"), replenish_cooldown)
	else
		replenishing = FALSE

/obj/machinery/implantchair/proc/set_ready()
	ready = TRUE
	update_appearance()

/obj/machinery/implantchair/container_resist_act(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You see [user] kicking against the door of [src]!"), \
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_hear("You hear a metallic creaking from [src]."))
	if(!do_after(user, (breakout_time), target = src))
		return
	if(!user || user.stat != CONSCIOUS || user.loc != src || state_open)
		return
	user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
		span_notice("You successfully break out of [src]!"))
	open_machine()

/obj/machinery/implantchair/relaymove(mob/living/user, direction)
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 5 SECONDS
		to_chat(user, span_warning("[src]'s door won't budge!"))


/obj/machinery/implantchair/MouseDrop_T(mob/target, mob/user)
	if(user.stat || !Adjacent(user) || !user.Adjacent(target) || !isliving(target) || !ISADVANCEDTOOLUSER(user))
		return
	if(isliving(user))
		var/mob/living/living_user = user
		if(living_user.body_position == LYING_DOWN)
			return
	close_machine(target)


/obj/machinery/implantchair/close_machine(mob/living/user)
	if(!(isnull(user) || istype(user)) || !state_open)
		return
	..(user)
	if(auto_inject && ready && ready_implants > 0)
		implant(user, null)

/obj/machinery/implantchair/genepurge
	name = "Genetic purifier"
	desc = "Used to purge a human genome of foreign influences."
	special = TRUE
	special_name = "Purge genome"
	injection_cooldown = 0
	replenish_cooldown = 30 SECONDS

/obj/machinery/implantchair/genepurge/implant_action(mob/living/carbon/human/human_target, mob/user)
	if(!istype(human_target))
		return FALSE
	human_target.set_species(/datum/species/human, 1)//lizards go home
	purrbation_remove(human_target)//remove cats
	human_target.dna.remove_all_mutations()//hulks out
	return TRUE


/obj/machinery/implantchair/brainwash
	name = "Neural Imprinter"
	desc = "Used to <s>indoctrinate</s> rehabilitate hardened recidivists."
	special_name = "Imprint"
	injection_cooldown = 300 SECONDS
	auto_inject = FALSE
	auto_replenish = FALSE
	special = TRUE
	var/objective = "Obey the law. Praise Nanotrasen."
	var/custom = FALSE
  
/obj/machinery/implantchair/brainwash/implant_action(mob/living/target_carbon, mob/user)
	if(!istype(target_carbon) || !target_carbon.mind) // I don't know how this makes any sense for silicons but laws trump objectives anyway.
		return FALSE
	if(custom)
		if(!user || !user.Adjacent(src))
			return FALSE
		objective = tgui_input_text(user, "What order do you want to imprint on [target_carbon]?", "Brainwashing", max_length = 120)
		message_admins("[ADMIN_LOOKUPFLW(user)] set brainwash machine objective to '[objective]'.")
		log_game("[key_name(user)] set brainwash machine objective to '[objective]'.")
	if(HAS_TRAIT(target_carbon, TRAIT_MINDSHIELD))
		return FALSE
	brainwash(target_carbon, objective)
	message_admins("[ADMIN_LOOKUPFLW(user)] brainwashed [key_name_admin(target_carbon)] with objective '[objective]'.")
	user.log_message("has brainwashed [key_name(target_carbon)] with the objective '[objective]' using \the [src]", LOG_ATTACK)
	target_carbon.log_message("has been brainwashed with the objective '[objective]' by [key_name(user)] using \the [src]", LOG_VICTIM, log_globally = FALSE)
	log_game("[key_name(user)] brainwashed [key_name(target_carbon)] with objective '[objective]'.")
	return TRUE
