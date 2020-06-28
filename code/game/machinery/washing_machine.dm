//dye registry, add dye colors and their resulting output here if you want the sprite to change instead of just the color.
GLOBAL_LIST_INIT(dye_registry, list(
	DYE_REGISTRY_UNDER = list(
		DYE_RED = /obj/item/clothing/under/color/red,
		DYE_ORANGE = /obj/item/clothing/under/color/orange,
		DYE_YELLOW = /obj/item/clothing/under/color/yellow,
		DYE_GREEN = /obj/item/clothing/under/color/green,
		DYE_BLUE = /obj/item/clothing/under/color/blue,
		DYE_PURPLE = /obj/item/clothing/under/color/lightpurple,
		DYE_BLACK = /obj/item/clothing/under/color/black,
		DYE_WHITE = /obj/item/clothing/under/color/white,
		DYE_RAINBOW = /obj/item/clothing/under/color/rainbow,
		DYE_MIME = /obj/item/clothing/under/rank/civilian/mime,
		DYE_CLOWN = /obj/item/clothing/under/rank/civilian/clown,
		DYE_CHAP = /obj/item/clothing/under/rank/civilian/chaplain,
		DYE_QM = /obj/item/clothing/under/rank/cargo/qm,
		DYE_LAW = /obj/item/clothing/under/suit/black,
		DYE_CAPTAIN = /obj/item/clothing/under/rank/captain,
		DYE_HOP = /obj/item/clothing/under/rank/civilian/head_of_personnel,
		DYE_HOS = /obj/item/clothing/under/rank/security/head_of_security,
		DYE_CE = /obj/item/clothing/under/rank/engineering/chief_engineer,
		DYE_RD = /obj/item/clothing/under/rank/rnd/research_director,
		DYE_CMO = /obj/item/clothing/under/rank/medical/chief_medical_officer,
		DYE_REDCOAT = /obj/item/clothing/under/costume/redcoat,
		DYE_SYNDICATE = /obj/item/clothing/under/syndicate,
		DYE_CENTCOM = /obj/item/clothing/under/rank/centcom/commander
	),
	DYE_REGISTRY_JUMPSKIRT = list(
		DYE_RED = /obj/item/clothing/under/color/jumpskirt/red,
		DYE_ORANGE = /obj/item/clothing/under/color/jumpskirt/orange,
		DYE_YELLOW = /obj/item/clothing/under/color/jumpskirt/yellow,
		DYE_GREEN = /obj/item/clothing/under/color/jumpskirt/green,
		DYE_BLUE = /obj/item/clothing/under/color/jumpskirt/blue,
		DYE_PURPLE = /obj/item/clothing/under/color/jumpskirt/lightpurple,
		DYE_BLACK = /obj/item/clothing/under/color/jumpskirt/black,
		DYE_WHITE = /obj/item/clothing/under/color/jumpskirt/white,
		DYE_RAINBOW = /obj/item/clothing/under/color/jumpskirt/rainbow,
		DYE_MIME = /obj/item/clothing/under/rank/civilian/mime/skirt,
		DYE_CHAP = /obj/item/clothing/under/rank/civilian/chaplain/skirt,
		DYE_QM = /obj/item/clothing/under/rank/cargo/qm/skirt,
		DYE_CAPTAIN = /obj/item/clothing/under/rank/captain/skirt,
		DYE_HOP = /obj/item/clothing/under/rank/civilian/head_of_personnel/skirt,
		DYE_HOS = /obj/item/clothing/under/rank/security/head_of_security/skirt,
		DYE_CE = /obj/item/clothing/under/rank/engineering/chief_engineer/skirt,
		DYE_RD = /obj/item/clothing/under/rank/rnd/research_director/skirt,
		DYE_CMO = /obj/item/clothing/under/rank/medical/chief_medical_officer/skirt,
	),
	DYE_REGISTRY_GLOVES = list(
		DYE_RED = /obj/item/clothing/gloves/color/red,
		DYE_ORANGE = /obj/item/clothing/gloves/color/orange,
		DYE_YELLOW = /obj/item/clothing/gloves/color/yellow,
		DYE_GREEN = /obj/item/clothing/gloves/color/green,
		DYE_BLUE = /obj/item/clothing/gloves/color/blue,
		DYE_PURPLE = /obj/item/clothing/gloves/color/purple,
		DYE_BLACK = /obj/item/clothing/gloves/color/black,
		DYE_WHITE = /obj/item/clothing/gloves/color/white,
		DYE_RAINBOW = /obj/item/clothing/gloves/color/rainbow,
		DYE_MIME = /obj/item/clothing/gloves/color/white,
		DYE_CLOWN = /obj/item/clothing/gloves/color/rainbow,
		DYE_QM = /obj/item/clothing/gloves/color/brown,
		DYE_CAPTAIN = /obj/item/clothing/gloves/color/captain,
		DYE_HOP = /obj/item/clothing/gloves/color/grey,
		DYE_HOS = /obj/item/clothing/gloves/color/black,
		DYE_CE = /obj/item/clothing/gloves/color/black,
		DYE_RD = /obj/item/clothing/gloves/color/grey,
		DYE_CMO = /obj/item/clothing/gloves/color/latex/nitrile,
		DYE_REDCOAT = /obj/item/clothing/gloves/color/white,
		DYE_SYNDICATE = /obj/item/clothing/gloves/combat,
		DYE_CENTCOM = /obj/item/clothing/gloves/combat
	),
	DYE_REGISTRY_SNEAKERS = list(
		DYE_RED = /obj/item/clothing/shoes/sneakers/red,
		DYE_ORANGE = /obj/item/clothing/shoes/sneakers/orange,
		DYE_YELLOW = /obj/item/clothing/shoes/sneakers/yellow,
		DYE_GREEN = /obj/item/clothing/shoes/sneakers/green,
		DYE_BLUE = /obj/item/clothing/shoes/sneakers/blue,
		DYE_PURPLE = /obj/item/clothing/shoes/sneakers/purple,
		DYE_BLACK = /obj/item/clothing/shoes/sneakers/black,
		DYE_WHITE = /obj/item/clothing/shoes/sneakers/white,
		DYE_RAINBOW = /obj/item/clothing/shoes/sneakers/rainbow,
		DYE_MIME = /obj/item/clothing/shoes/sneakers/black,
		DYE_CLOWN = /obj/item/clothing/shoes/sneakers/rainbow,
		DYE_QM = /obj/item/clothing/shoes/sneakers/brown,
		DYE_CAPTAIN = /obj/item/clothing/shoes/sneakers/brown,
		DYE_HOP = /obj/item/clothing/shoes/sneakers/brown,
		DYE_CE = /obj/item/clothing/shoes/sneakers/brown,
		DYE_RD = /obj/item/clothing/shoes/sneakers/brown,
		DYE_CMO = /obj/item/clothing/shoes/sneakers/brown,
		DYE_SYNDICATE = /obj/item/clothing/shoes/combat,
		DYE_CENTCOM = /obj/item/clothing/shoes/combat
	),
	DYE_REGISTRY_FANNYPACK = list(
		DYE_RED = /obj/item/storage/belt/fannypack/red,
		DYE_ORANGE = /obj/item/storage/belt/fannypack/orange,
		DYE_YELLOW = /obj/item/storage/belt/fannypack/yellow,
		DYE_GREEN = /obj/item/storage/belt/fannypack/green,
		DYE_BLUE = /obj/item/storage/belt/fannypack/blue,
		DYE_PURPLE = /obj/item/storage/belt/fannypack/purple,
		DYE_BLACK = /obj/item/storage/belt/fannypack/black,
		DYE_WHITE = /obj/item/storage/belt/fannypack/white,
		DYE_SYNDICATE = /obj/item/storage/belt/military
	),
	DYE_REGISTRY_BEDSHEET = list(
		DYE_RED = /obj/item/bedsheet/red,
		DYE_ORANGE = /obj/item/bedsheet/orange,
		DYE_YELLOW = /obj/item/bedsheet/yellow,
		DYE_GREEN = /obj/item/bedsheet/green,
		DYE_BLUE = /obj/item/bedsheet/blue,
		DYE_PURPLE = /obj/item/bedsheet/purple,
		DYE_BLACK = /obj/item/bedsheet/black,
		DYE_WHITE = /obj/item/bedsheet,
		DYE_RAINBOW = /obj/item/bedsheet/rainbow,
		DYE_MIME = /obj/item/bedsheet/mime,
		DYE_CLOWN = /obj/item/bedsheet/clown,
		DYE_CHAP = /obj/item/bedsheet/chaplain,
		DYE_QM = /obj/item/bedsheet/qm,
		DYE_LAW = /obj/item/bedsheet/black,
		DYE_CAPTAIN = /obj/item/bedsheet/captain,
		DYE_HOP = /obj/item/bedsheet/hop,
		DYE_HOS = /obj/item/bedsheet/hos,
		DYE_CE = /obj/item/bedsheet/ce,
		DYE_RD = /obj/item/bedsheet/rd,
		DYE_CMO = /obj/item/bedsheet/cmo,
		DYE_COSMIC = /obj/item/bedsheet/cosmos,
		DYE_SYNDICATE = /obj/item/bedsheet/syndie,
		DYE_CENTCOM = /obj/item/bedsheet/centcom
	),
	DYE_LAWYER_SPECIAL = list(
		DYE_COSMIC = /obj/item/clothing/under/rank/civilian/lawyer/galaxy,
		DYE_SYNDICATE = /obj/item/clothing/under/rank/civilian/lawyer/galaxy/red
	)
))

/obj/machinery/washing_machine
	name = "Washing Machine"
	desc = "Gets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_1_0"
	density = TRUE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/washing_machine
	use_power = IDLE_POWER_USE // we are not using auto processing
	idle_power_usage = 5
	active_power_usage = 60
	power_channel = AREA_USAGE_EQUIP
	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/fastprocess


	var/ticks_end = 0	// this just saves an addTimer call
	var/ticks_till_power = 0	// this emulates the evey 20 ticks for auto_power_use rule
	var/bloody_mess = 0
	var/obj/item/color_source

	// changes under upgraded components
	var/ticks_till_finished = 200
	var/max_wash_capacity = 5
	var/clean_mode = CLEAN_WEAK

/obj/machinery/washing_machine/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_blood)

/obj/machinery/washing_machine/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	var/I
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		I += M.rating

	max_wash_capacity  = initial(max_wash_capacity) * E
	ticks_till_finished = initial(ticks_till_finished) / I
	var/IE = I + E
	if(IE > 7) // all bluespace parts
		clean_mode = CLEAN_IMPRESSIVE
	else if(IE > 5)
		clean_mode = CLEAN_MEDIUM
	else if(IE > 3)
		clean_mode = CLEAN_MEDIUM
	else
		clean_mode = CLEAN_WEAK

/obj/machinery/washing_machine/default_pry_open(obj/item/I)
	. = !(state_open || panel_open || is_operational() || locked || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open \the [src].</span>", "<span class='notice'>You pry open \the [src].</span>")
		open_machine()

/obj/machinery/suit_storage_unit/dump_contents()
	dropContents()
	color_source = null

/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	if(!busy)
		. += "<span class='notice'><b>Alt-click</b> it to start a wash cycle.</span>"

/obj/machinery/washing_machine/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(busy)
		return
	if(state_open)
		to_chat(user, "<span class='warning'>Close the door first!</span>")
		return
	if(bloody_mess)
		to_chat(user, "<span class='warning'>[src] must be cleaned up first!</span>")
		return
 	use_power(active_power_use)
	if(is_operational())
		to_chat(user, "<span class='warning'>[src] must be cleaned up first!</span>")
		return
	update_icon()
	ticks_end = ticks_till_finished + world.timeofday
	ticks_till_power = 0	// its run on first tick
	use_power = ACTIVE_POWER_USE
	begin_processing()

/obj/machinery/washing_machine/power_change()
/obj/machinery/ntnet_relay/process()
	if(is_operational())


/obj/machinery/washing_machine/process()
	if(world.timeofday >= ticks_till_power)
		// This emulates the machine process evey 20 ticks
		if(is_operational() && auto_use_power())
			ticks_till_power = world.timeofday + 20
		else
			wash_cycle(FALSE)
			return PROCESS_KILL // just an early return in case we use the last of the power

	if(world.timeofday >= ticks_end)
		wash_cycle(TRUE)	// this is async so don't worry about it
		return PROCESS_KILL

	if(anchored)
		if(prob(5))
			var/matrix/M = new
			M.Translate(rand(-1, 1), rand(0, 1))
			animate(src, transform=M, time=1)
			animate(transform=matrix(), time=1)
	else
		if(prob(1))
			step(src, pick(GLOB.cardinals))
		var/matrix/M = new
		M.Translate(rand(-3, 3), rand(-1, 3))
		animate(src, transform=M, time=2)

/obj/machinery/washing_machine/proc/clean_blood()
	if(current_ticks)
		bloody_mess = FALSE
		update_icon()
/*
** This proc finishes the wash.  It is async so fast proc dosn't have to wait
** on it finishing.  It washes even the contents so you don't even have to
** take it out of the backpack!  Just don't put an rcd in there
**
*/
/obj/machinery/washing_machine/proc/wash_cycle(wash_items)
	set waitfor = FALSE	// this is called from process so we don't want to wait
	animate(src, transform=matrix(), time=2)
	ticks_end = 0
	power_use = IDLE_POWER_USE
	if(!wash_items)
		update_icon()
		return

	// copied from suit decontamination
	var/list/things_to_clear = list() //Done this way since using GetAllContents on the machine itself would include circuitry and such.
	for(var/atom/movable/AM in contents)
	/obj/item/storage/backpack
		things_to_clear += AM.GetAllContents()

	// So currently machine_wash has a bunch of procs depending on the object thrown into
	// the machine.  atom/movable is the basic washed(src,clean_mode) so unless that object
	// does something special, just use the inherted
	for(var/atom/movable/AM in things_to_clear)
		AM.machine_wash(src, clean_mode)

	if(color_source)
		qdel(color_source)
		color_source = null
	update_icon()

/obj/item/proc/dye_item(dye_color, dye_key_override)
	var/dye_key_selector = dye_key_override ? dye_key_override : dying_key
	if(undyeable)
		return FALSE
	if(dye_key_selector)
		if(!GLOB.dye_registry[dye_key_selector])
			log_runtime("Item just tried to be dyed with an invalid registry key: [dye_key_selector]")
			return FALSE
		var/obj/item/target_type = GLOB.dye_registry[dye_key_selector][dye_color]
		if(target_type)
			icon = initial(target_type.icon)
			icon_state = initial(target_type.icon_state)
			lefthand_file = initial(target_type.lefthand_file)
			righthand_file = initial(target_type.righthand_file)
			inhand_icon_state = initial(target_type.inhand_icon_state)
			worn_icon = initial(target_type.worn_icon)
			worn_icon_state = initial(target_type.worn_icon_state)
			inhand_x_dimension = initial(target_type.inhand_x_dimension)
			inhand_y_dimension = initial(target_type.inhand_y_dimension)
			name = initial(target_type.name)
			desc = "[initial(target_type.desc)] The colors look a little dodgy."
			return target_type //successfully "appearance copy" dyed something; returns the target type as a hacky way of extending
	add_atom_colour(dye_color, FIXED_COLOUR_PRIORITY)
	return FALSE

//what happens to this object when washed inside a washing machine
//Also a cheap way to stop the washine machine from washing unnecessary  stuff
/atom/movable/proc/machine_wash(obj/machinery/washing_machine/WM, clean_mode)
	washed(src, clean_mode)
	return

/obj/item/stack/sheet/hairlesshide/machine_wash(obj/machinery/washing_machine/WM)
	new /obj/item/stack/sheet/wethide(drop_location(), amount)
	qdel(src)

/obj/item/clothing/suit/hooded/ian_costume/machine_wash(obj/machinery/washing_machine/WM)
	new /obj/item/reagent_containers/food/snacks/meat/slab/corgi(loc)
	qdel(src)

/mob/living/simple_animal/pet/machine_wash(obj/machinery/washing_machine/WM)
	WM.bloody_mess = TRUE
	gib()

/obj/item/machine_wash(obj/machinery/washing_machine/WM)
	. = ..()
	if(WM.color_source)
		dye_item(WM.color_source.dye_color)

/obj/item/clothing/under/dye_item(dye_color, dye_key)
	. = ..()
	if(.)
		var/obj/item/clothing/under/U = .
		can_adjust = initial(U.can_adjust)
		if(!can_adjust && adjusted) //we deadjust the uniform if it's now unadjustable
			toggle_jumpsuit_adjust()

/obj/item/clothing/under/machine_wash(obj/machinery/washing_machine/WM)
	freshly_laundered = TRUE
	addtimer(VARSET_CALLBACK(src, freshly_laundered, FALSE), 5 MINUTES, TIMER_UNIQUE | TIMER_OVERRIDE)
	. = ..()

/obj/item/clothing/head/mob_holder/machine_wash(obj/machinery/washing_machine/WM)
	. = ..()
	held_mob.machine_wash(WM)

/obj/item/clothing/shoes/sneakers/machine_wash(obj/machinery/washing_machine/WM)
	if(chained)
		chained = 0
		slowdown = SHOES_SLOWDOWN
		new /obj/item/restraints/handcuffs(loc)
	. = ..()

/obj/machinery/washing_machine/relaymove(mob/user)
	container_resist(user)

/obj/machinery/washing_machine/container_resist(mob/living/user)
	if(!current_ticks)
		add_fingerprint(user)
		open_machine()

/obj/machinery/washing_machine/update_icon_state()
	if(current_ticks)
		icon_state = "wm_running_[bloody_mess]"
	else if(bloody_mess)
		icon_state = "wm_[state_open]_blood"
	else
		var/full = contents.len ? 1 : 0
		icon_state = "wm_[state_open]_[full]"

/obj/machinery/washing_machine/update_overlays()
	. = ..()
	if(panel_open)
		. += "wm_panel"

/obj/machinery/washing_machine/on_deconstruction()
	dump_contents()
	. = ..()

/obj/machinery/washing_machine/attackby(obj/item/W, mob/user, params)
	if(panel_open && !current_ticks && default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_screwdriver(user, null, null, W))
		update_icon()
		return

	else if(user.a_intent != INTENT_HARM)
		if (!state_open)
			to_chat(user, "<span class='warning'>Open the door first!</span>")
			return TRUE

		if(bloody_mess)
			to_chat(user, "<span class='warning'>[src] must be cleaned up first!</span>")
			return TRUE

		if(contents.len >= max_wash_capacity)
			to_chat(user, "<span class='warning'>The washing machine is full!</span>")
			return TRUE

		if(!user.transferItemToLoc(W, src))
			to_chat(user, "<span class='warning'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>")
			return TRUE
		if(W.dye_color)
			color_source = W
		update_icon()

	else
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(current_ticks)
		to_chat(user, "<span class='warning'>[src] is busy!</span>")
		return

	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.has_buckled_mobs())
			return
		if(state_open)
			if(istype(L, /mob/living/simple_animal/pet))
				L.forceMove(src)
				update_icon()
		return

	if(!state_open)
		open_machine()
	else
		state_open = FALSE //close the door
		update_icon()


/obj/machinery/washing_machine/open_machine(drop = TRUE)
	density = TRUE //because machinery/open_machine() sets it to 0
	color_source = null
	. = ..()
