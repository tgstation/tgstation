/obj/item/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	var/pointer_icon_state
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=500, /datum/material/glass=500)
	w_class = WEIGHT_CLASS_SMALL
	var/turf/pointer_loc
	var/energy = 10
	var/max_energy = 10
	var/effectchance = 30
	var/recharging = FALSE
	var/recharge_locked = FALSE
	var/obj/item/stock_parts/micro_laser/diode //used for upgrading!

/obj/item/laser_pointer/red
	pointer_icon_state = "red_laser"

/obj/item/laser_pointer/green
	pointer_icon_state = "green_laser"

/obj/item/laser_pointer/blue
	pointer_icon_state = "blue_laser"

/obj/item/laser_pointer/purple
	pointer_icon_state = "purple_laser"

/obj/item/laser_pointer/Initialize(mapload)
	. = ..()
	diode = new(src)
	if(!pointer_icon_state)
		pointer_icon_state = pick("red_laser","green_laser","blue_laser","purple_laser")

/obj/item/laser_pointer/upgraded/Initialize(mapload)
	. = ..()
	diode = new /obj/item/stock_parts/micro_laser/ultra

/obj/item/laser_pointer/screwdriver_act(mob/living/user, obj/item/tool)
	if(diode)
		tool.play_tool_sound(src)
		to_chat(user, span_notice("You remove the [diode.name] from \the [src]."))
		diode.forceMove(drop_location())
		diode = null
		return TRUE

/obj/item/laser_pointer/tool_act(mob/living/user, obj/item/tool, tool_type, is_right_clicking)
	. = ..()
	if(isnull(crystal_lens) || !(tool.tool_behaviour == TOOL_WIRECUTTER || tool.tool_behaviour == TOOL_HEMOSTAT))
		return
	tool.play_tool_sound(src)
	balloon_alert(user, "removed crystal lens")
	crystal_lens.forceMove(drop_location())
	crystal_lens = null
	return TRUE

/obj/item/laser_pointer/attackby(obj/item/attack_item, mob/user, params)
	if(istype(attack_item, /obj/item/stock_parts/micro_laser))
		if(diode)
			balloon_alert(user, "already has a diode!")
			return
		var/obj/item/stock_parts/attack_diode = attack_item
		if(crystal_lens && attack_diode.rating < 3) //only tier 3 and up are small enough to fit
			to_chat(user, span_warning("You try to jam \the [attack_item.name] in place, but \the [crystal_lens.name] is in the way!"))
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 20)
			if(do_after(user, 2 SECONDS, src))
				var/atom/atom_to_teleport = pick(user, attack_item)
				if(atom_to_teleport == user)
					to_chat(user, span_warning("You jam \the [attack_item.name] in too hard and break \the [crystal_lens.name] inside, teleporting you away!"))
					user.drop_all_held_items()
				else if(atom_to_teleport == attack_item)
					attack_item.forceMove(drop_location())
					to_chat(user, span_warning("You jam \the [attack_item.name] in too hard and break \the [crystal_lens.name] inside, teleporting \the [attack_item.name] away!"))
				do_teleport(atom_to_teleport, get_turf(src), crystal_lens.blink_range, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
				qdel(crystal_lens)
			return
		if(!user.transferItemToLoc(attack_item, src))
			return
		playsound(src, 'sound/items/screwdriver.ogg', 30)
		diode = attack_item
		balloon_alert(user, "installed \the [diode.name]")
		//we have a diode now, try starting a charge sequence in case the pointer was charging when we took out the diode
		recharging = TRUE
		START_PROCESSING(SSobj, src)
		return TRUE

	if(istype(attack_item, /obj/item/stack/ore/bluespace_crystal))
		if(crystal_lens)
			balloon_alert(user, "already has a lens!")
			return
		//the crystal stack we're trying to install a crystal from
		var/obj/item/stack/ore/bluespace_crystal/crystal_stack = attack_item
		if(diode && diode.rating < 3) //only lasers of tier 3 and up can house a lens
			to_chat(user, span_warning("You try to jam \the [crystal_stack.name] in front of the diode, but it's a bad fit!"))
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 20)
			if(do_after(user, 2 SECONDS, src))
				var/atom/atom_to_teleport = pick(user, src)
				if(atom_to_teleport == user)
					to_chat(user, span_warning("You press on \the [crystal_stack.name] too hard and are teleported away!"))
					user.drop_all_held_items()
				else if(atom_to_teleport == src)
					forceMove(drop_location())
					to_chat(user, span_warning("You press on \the [crystal_stack.name] too hard and \the [src] is teleported away!"))
				do_teleport(atom_to_teleport, get_turf(src), crystal_stack.blink_range, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
				crystal_stack.use_tool(src, user, amount = 1) //use only one if we were installing from a stack of crystals
			return
		//the single crystal that we actually install
		var/obj/item/stack/ore/bluespace_crystal/single_crystal = crystal_stack.split_stack(null, 1)
		if(isnull(single_crystal))
			return
		if(!user.transferItemToLoc(single_crystal, src))
			return
		crystal_lens = single_crystal
		playsound(src, 'sound/items/screwdriver2.ogg', 30)
		balloon_alert(user, "installed \the [crystal_lens.name]")
		to_chat(user, span_notice("You install a [crystal_lens.name] in [src]. \
			It can now be used to shine through obstacles at the cost of double the energy drain."))
		return TRUE

	return ..()

/obj/item/laser_pointer/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!diode)
			. += span_notice("The diode is missing.")
		else
			. += span_notice("A class <b>[diode.rating]</b> laser diode is installed. It is <i>screwed</i> in place.")

/obj/item/laser_pointer/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	. |= AFTERATTACK_PROCESSED_ITEM
	laser_act(target, user, params)

/obj/item/laser_pointer/proc/laser_act(atom/target, mob/living/user, params)
	if( !(user in (viewers(7,target))) )
		return
	if (!diode)
		to_chat(user, span_notice("You point [src] at [target], but nothing happens!"))
		return
	if (!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return
	if(HAS_TRAIT(user, TRAIT_CHUNKYFINGERS))
		to_chat(user, span_warning("Your fingers can't press the button!"))
		return
	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		to_chat(user, span_notice("You point [src] at [target], but it's still charging."))
		return

	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(user.zone_selected == BODY_ZONE_PRECISE_EYES)

			var/severity = 1
			if(prob(33))
				severity = 2
			else if(prob(50))
				severity = 0

			//chance to actually hit the eyes depends on internal component
			if(prob(effectchance * diode.rating) && C.flash_act(severity))
				outmsg = span_notice("You blind [C] by shining [src] in [C.p_their()] eyes.")
				log_combat(user, C, "blinded with a laser pointer",src)
			else
				outmsg = span_warning("You fail to blind [C] by shining [src] at [C.p_their()] eyes!")
				log_combat(user, C, "attempted to blind with a laser pointer",src)

	//robots
	else if(iscyborg(target))
		var/mob/living/silicon/S = target
		log_combat(user, S, "shone in the sensors", src)
		//chance to actually hit the eyes depends on internal component
		if(prob(effectchance * diode.rating) && S.flash_act(affect_silicon = TRUE))
			S.Paralyze(rand(100,200))
			to_chat(S, span_danger("Your sensors were overloaded by a laser!"))
			outmsg = span_notice("You overload [S] by shining [src] at [S.p_their()] sensors.")
		else
			outmsg = span_warning("You fail to overload [S] by shining [src] at [S.p_their()] sensors!")

	//cameras
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(effectchance * diode.rating))
			C.emp_act(EMP_HEAVY)
			outmsg = span_notice("You hit the lens of [C] with [src], temporarily disabling the camera!")
			log_combat(user, C, "EMPed", src)
		else
			outmsg = span_warning("You miss the lens of [C] with [src]!")

	//catpeople
	for(var/mob/living/carbon/human/H in view(1,targloc))
		if(!HAS_TRAIT(H, TRAIT_CAT))
			continue
		if( H.incapacitated() || H.is_blind())
			continue
		if(user.body_position == STANDING_UP)
			H.setDir(get_dir(H,targloc)) // kitty always looks at the light
			if(prob(effectchance * diode.rating))
				H.visible_message(span_warning("[H] makes a grab for the light!"),span_userdanger("LIGHT!"))
				H.Move(targloc)
				log_combat(user, H, "moved with a laser pointer",src)
			else
				H.visible_message(span_notice("[H] looks briefly distracted by the light."), span_warning("You're briefly tempted by the shiny light..."))
		else
			H.visible_message(span_notice("[H] stares at the light."), span_warning("You stare at the light..."))

	//cats!
	for(var/mob/living/simple_animal/pet/cat/C in view(1,targloc))
		if(prob(effectchance * diode.rating))
			if(C.resting)
				C.set_resting(FALSE, instant = TRUE)
			C.visible_message(span_notice("[C] pounces on the light!"),span_warning("LIGHT!"))
			C.Move(targloc)
			C.Immobilize(1 SECONDS)
		else
			C.visible_message(span_notice("[C] looks uninterested in your games."),span_warning("You spot [user] shining [src] at you. How insulting!"))

	//laser pointer image
	icon_state = "pointer_[pointer_icon_state]"
	var/image/I = image('icons/obj/weapons/guns/projectiles.dmi',targloc,pointer_icon_state,10)
	var/list/modifiers = params2list(params)
	if(modifiers)
		if(LAZYACCESS(modifiers, ICON_X))
			I.pixel_x = (text2num(LAZYACCESS(modifiers, ICON_X)) - 16)
		if(LAZYACCESS(modifiers, ICON_Y))
			I.pixel_y = (text2num(LAZYACCESS(modifiers, ICON_Y)) - 16)
	else
		I.pixel_x = target.pixel_x + rand(-5,5)
		I.pixel_y = target.pixel_y + rand(-5,5)

	if(outmsg)
		to_chat(user, outmsg)
	else
		to_chat(user, span_info("You point [src] at [target]."))

	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = TRUE
			START_PROCESSING(SSobj, src)
		if(energy <= 0)
			to_chat(user, span_warning("[src]'s battery is overused, it needs time to recharge!"))
			recharge_locked = TRUE

	targloc.flick_overlay_view(I, 10)
	icon_state = "pointer"

/obj/item/laser_pointer/process(seconds_per_tick)
	if(!diode)
		recharging = FALSE
		return PROCESS_KILL
	if(SPT_PROB(10 + diode.rating*10 - recharge_locked*1, seconds_per_tick)) //t1 is 20, 2 40
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = FALSE
			recharge_locked = FALSE
			return ..()
