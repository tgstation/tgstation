/obj/item/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "pointer"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 5)
	w_class = WEIGHT_CLASS_SMALL
	///Currently stored blulespace crystal, if any. Required to use the pointer through walls
	var/obj/item/stack/ore/bluespace_crystal/crystal_lens
	///Currently stored micro-laser diode
	var/obj/item/stock_parts/micro_laser/diode
	///Chance that the pointer dot will trigger a reaction from a mob/object
	var/effectchance = 30
	///Currently available battery charge of the laser pointer
	var/energy = 10
	///Maximum possible battery charge of the laser. Draining the battery puts the pointer in a recharge state, preventing use, which ends upon full recharge
	var/max_energy = 10
	///Maximum use range
	var/max_range = 7
	///Icon for the laser, affects both the laser dot and the laser pointer itself, as it shines a laser on the item itself
	var/pointer_icon_state = null
	///Whether the pointer is currently in a full recharge state. Triggered upon fully draining the battery
	var/recharge_locked = FALSE
	///Whether the pointer is currently recharging or not
	var/recharging = FALSE

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
		pointer_icon_state = pick("red_laser", "green_laser", "blue_laser", "purple_laser")

/obj/item/laser_pointer/Destroy(force)
	QDEL_NULL(crystal_lens)
	QDEL_NULL(diode)
	return ..()

/obj/item/laser_pointer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == crystal_lens)
		crystal_lens = null
	if(gone == diode)
		diode = null

/obj/item/laser_pointer/upgraded/Initialize(mapload)
	. = ..()
	diode = new /obj/item/stock_parts/micro_laser/ultra

/obj/item/laser_pointer/infinite_range
	name = "infinite laser pointer"
	desc = "Used to shine in the eyes of Cyborgs who need a bit of a push, this works through camera consoles."
	max_range = INFINITY

/obj/item/laser_pointer/infinite_range/Initialize(mapload)
	. = ..()
	diode = new /obj/item/stock_parts/micro_laser/quadultra

/obj/item/laser_pointer/screwdriver_act(mob/living/user, obj/item/tool)
	if(diode)
		tool.play_tool_sound(src)
		balloon_alert(user, "removed diode")
		diode.forceMove(drop_location())
		diode = null
		return TRUE

/obj/item/laser_pointer/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(isnull(crystal_lens))
		return ..()
	if(tool_behaviour != TOOL_WIRECUTTER && tool_behaviour != TOOL_HEMOSTAT)
		return ..()
	tool.play_tool_sound(src)
	balloon_alert(user, "removed crystal lens")
	crystal_lens.forceMove(drop_location())
	crystal_lens = null
	return ITEM_INTERACT_SUCCESS

/obj/item/laser_pointer/attackby(obj/item/attack_item, mob/user, params)
	if(istype(attack_item, /obj/item/stock_parts/micro_laser))
		if(diode)
			balloon_alert(user, "already has a diode!")
			return
		var/obj/item/stock_parts/attack_diode = attack_item
		if(crystal_lens && attack_diode.rating < 3) //only tier 3 and up are small enough to fit
			to_chat(user, span_warning("You try to jam \the [attack_item.name] in place, but \the [crystal_lens.name] is in the way!"))
			playsound(src, 'sound/machines/airlock/airlock_alien_prying.ogg', 20)
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
		playsound(src, 'sound/items/tools/screwdriver.ogg', 30)
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
			playsound(src, 'sound/machines/airlock/airlock_alien_prying.ogg', 20)
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
		playsound(src, 'sound/items/tools/screwdriver2.ogg', 30)
		balloon_alert(user, "installed \the [crystal_lens.name]")
		to_chat(user, span_notice("You install a [crystal_lens.name] in [src]. \
			It can now be used to shine through obstacles at the cost of double the energy drain."))
		return TRUE

	return ..()

/obj/item/laser_pointer/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(isnull(diode))
			. += span_notice("The diode is missing.")
		else
			. += span_notice("A class <b>[diode.rating]</b> laser diode is installed. It is <i>screwed</i> in place.")
		. += span_notice("A small display reads out that[recharge_locked ? " it is currently recharging to full, and" : ""] there is <b>[energy * 10]%</b> total charge remaining.")
		if(crystal_lens)
			. += span_notice("There is a <b>[crystal_lens.name]</b> fit neatly before the focus lens. It can be <i>plucked out</i> with some <i>wirecutters</i>.")
		else if(diode) //hint at the ability to modify the pointer with a crystal only if we have a diode
			. += span_notice("<i>You could examine it more thoroughly...</i>")

/obj/item/laser_pointer/examine_more(mob/user)
	. = ..()
	if(!isnull(crystal_lens) || isnull(diode))
		return
	switch(diode.rating)
		if(1)
			. += "<i>\The [diode.name] is fit neatly into the casing.</i>"
		if(2)
			. += "<i>\The [diode.name] is secured in place, with a little bit of room left between it and the focus lens.</i>"
		if(3 to 4)
			. += "<i>\The [diode.name]'s size is much smaller compared to the previous generation lasers, \
			and the wide margin between it and the focus lens could probably house <b>a crystal</b> of some sort.</i>"

/obj/item/laser_pointer/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	laser_act(interacting_with, user, modifiers)
	return ITEM_INTERACT_BLOCKING

/obj/item/laser_pointer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

///Handles shining the clicked atom,
/obj/item/laser_pointer/proc/laser_act(atom/target, mob/living/user, list/modifiers)
	if(isnull(diode))
		to_chat(user, span_notice("You point [src] at [target], but nothing happens!"))
		return
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return
	if(HAS_TRAIT(user, TRAIT_CHUNKYFINGERS))
		to_chat(user, span_warning("Your fingers can't press the button!"))
		return

	if(max_range != INFINITY)
		if(!IN_GIVEN_RANGE(target, user, max_range))
			to_chat(user, span_warning("\The [target] is too far away!"))
			return
		if(!(user in (view(max_range, target)))) //check if we are visible from the target's PoV
			if(isnull(crystal_lens))
				to_chat(user, span_warning("You can't point with [src] through walls!"))
				return
			if(!((user.sight & SEE_OBJS) || (user.sight & SEE_MOBS))) //only let it work if we have xray or thermals. mesons don't count because they are easier to get.
				to_chat(user, span_notice("You can't quite make out your target and you fail to shine at it."))
				return

	add_fingerprint(user)

	//nothing happens if the battery has been drained and has not fully recharged yet
	if(recharge_locked)
		to_chat(user, span_notice("You point [src] at [target], but it's still charging."))
		return

	//The message we send to the user upon using the pointer
	var/outmsg
	//The turf of the target we clicked on
	var/turf/targloc = get_turf(target)

	//human/alien mobs: if we aim for the eyes, chance to flash the target
	if(iscarbon(target))
		var/mob/living/carbon/target_humanoid = target
		if(target_humanoid.stat == DEAD)
			outmsg = span_notice("You point [src] at [target_humanoid], but [target_humanoid.p_they()] appear[target_humanoid.p_s()] to be dead!")
		else if(user.zone_selected == BODY_ZONE_PRECISE_EYES)
			//Intensity of the laser dot to pass to flash_act
			var/severity = pick(0, 1, 2)
			var/always_fail = FALSE
			if(istype(target_humanoid.glasses, /obj/item/clothing/glasses/eyepatch) && prob(50))
				always_fail = TRUE

			//chance to actually hit the eyes depends on internal component
			if(prob(effectchance * diode.rating) && !always_fail && target_humanoid.flash_act(severity))
				outmsg = span_notice("You blind [target_humanoid] by shining [src] in [target_humanoid.p_their()] eyes.")
				log_combat(user, target_humanoid, "blinded with a laser pointer", src)
			else
				outmsg = span_warning("You fail to blind [target_humanoid] by shining [src] at [target_humanoid.p_their()] eyes!")
				log_combat(user, target_humanoid, "attempted to blind with a laser pointer", src)

	//borgs: chance to flash and paralyse the target
	else if(iscyborg(target))
		var/mob/living/silicon/target_sillycone = target
		//chance to actually hit the eyes depends on internal component
		if(target_sillycone.stat == DEAD)
			outmsg = span_notice("You point [src] at [target_sillycone], but [target_sillycone.p_they()] appear[target_sillycone.p_s()] to be non-functioning.")
		if(prob(effectchance * diode.rating) && target_sillycone.flash_act(affect_silicon = TRUE))
			target_sillycone.set_temp_blindness_if_lower(5 SECONDS)
			to_chat(target_sillycone, span_danger("Your sensors were overloaded by a laser!"))
			outmsg = span_notice("You overload [target_sillycone] by shining [src] at [target_sillycone.p_their()] sensors.")
			log_combat(user, target_sillycone, "shone in the sensors", src)
		else
			outmsg = span_warning("You fail to overload [target_sillycone] by shining [src] at [target_sillycone.p_their()] sensors!")
			log_combat(user, target_sillycone, "attempted to shine in the sensors", src)

	//cameras: chance to EMP the camera
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/target_camera = target
		if(!target_camera.camera_enabled && !target_camera.emped)
			outmsg = span_notice("You point [src] at [target_camera], but it seems to be disabled.")
		else if(prob(effectchance * diode.rating))
			target_camera.emp_act(EMP_HEAVY)
			outmsg = span_notice("You hit the lens of [target_camera] with [src], temporarily disabling the camera!")
			log_combat(user, target_camera, "EMPed", src)
		else
			outmsg = span_warning("You miss the lens of [target_camera] with [src]!")

	//catpeople: make any felinid near the target to face the target, chance for felinids to pounce at the light, stepping to the target
	for(var/mob/living/carbon/human/target_felinid in view(1, targloc))
		if(!isfelinid(target_felinid) || target_felinid.stat == DEAD || target_felinid.is_blind() || target_felinid.incapacitated)
			continue
		if(target_felinid.body_position == STANDING_UP)
			target_felinid.setDir(get_dir(target_felinid, targloc)) // kitty always looks at the light
			if(prob(effectchance * diode.rating))
				target_felinid.visible_message(span_warning("[target_felinid] makes a grab for the light!"), span_userdanger("LIGHT!"))
				target_felinid.Move(targloc, get_dir(target_felinid, targloc))
				log_combat(user, target_felinid, "moved with a laser pointer", src)
			else
				target_felinid.visible_message(span_notice("[target_felinid] looks briefly distracted by the light."), span_warning("You're briefly tempted by the shiny light..."))
		else
			target_felinid.visible_message(span_notice("[target_felinid] stares at the light."), span_warning("You stare at the light..."))
	//The pointer is shining, change its sprite to show
	icon_state = "pointer_[pointer_icon_state]"

	//setup pointer blip
	var/mutable_appearance/laser = mutable_appearance('icons/obj/weapons/guns/projectiles.dmi', pointer_icon_state)
	if(modifiers)
		if(LAZYACCESS(modifiers, ICON_X))
			laser.pixel_x = (text2num(LAZYACCESS(modifiers, ICON_X)) - 16)
		if(LAZYACCESS(modifiers, ICON_Y))
			laser.pixel_y = (text2num(LAZYACCESS(modifiers, ICON_Y)) - 16)
	else
		laser.pixel_x = target.pixel_x + rand(-5,5)
		laser.pixel_y = target.pixel_y + rand(-5,5)

	if(outmsg)
		to_chat(user, outmsg)
	else
		to_chat(user, span_info("You point [src] at [target]."))

	//we have successfully shone our pointer, reduce our battery depending on whether we have an extra lens or not
	energy -= crystal_lens ? 2 : 1
	if(energy <= max_energy) //normal recharge, does not stop us from using the pointer
		if(!recharging)
			recharging = TRUE
			START_PROCESSING(SSobj, src)
		if(energy <= 0) //battery is completely dry, recharge the pointer to full then let us use it again
			to_chat(user, span_warning("[src]'s battery is overused, it needs time to recharge!"))
			recharge_locked = TRUE

	//flash a pointer blip at the target
	target.flick_overlay_view(laser, 1 SECONDS)
	//reset pointer sprite
	icon_state = "pointer"

/obj/item/laser_pointer/process(seconds_per_tick)
	if(isnull(diode))
		recharging = FALSE
		return PROCESS_KILL
	if(SPT_PROB(10 + diode.rating * 10, seconds_per_tick)) //+10% chance per diode tier to recharge one use per process
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = FALSE
			recharge_locked = FALSE
			return ..()
