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

/obj/item/laser_pointer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/micro_laser))
		if(!diode)
			if(!user.transferItemToLoc(W, src))
				return
			diode = W
			to_chat(user, span_notice("You install a [diode.name] in [src]."))
		else
			to_chat(user, span_warning("[src] already has a diode installed!"))

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(diode)
			to_chat(user, span_notice("You remove the [diode.name] from \the [src]."))
			diode.forceMove(drop_location())
			diode = null
	else
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
		if(prob(effectchance * diode.rating))
			S.flash_act(affect_silicon = 1)
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
	for(var/mob/checked_mob as anything in viewers(1, targloc))
		if(checked_mob.incapacitated())
			return
		var/mob/living/carbon/human/human = checked_mob
		if(isfelinid(human) && !human.eye_blind) // person is a cat
			if(user.body_position == STANDING_UP)
				human.setDir(get_dir(human,targloc)) // kitty always looks at the light
				if(prob(effectchance * diode.rating))
					human.visible_message(span_warning("[H] makes a grab for the light!"),span_userdanger("LIGHT!"))
					human.Move(targloc)
					log_combat(user, human, "moved with a laser pointer",src)
				else
					human.visible_message(span_notice("[human] looks briefly distracted by the light."), span_warning("You're briefly tempted by the shiny light..."))
			else
				human.visible_message(span_notice("[human] stares at the light."), span_warning("You stare at the light..."))
		else if(iscat(checked_mob)) //cats!
			var/mob/living/simple_animal/pet/cat/cat = checked_mob
			if(prob(effectchance * diode.rating))
				if(cat.resting)
					cat.set_resting(FALSE, instant = TRUE)
				cat.visible_message("<span class='notice'>[cat] pounces on the light!</span>","<span class='warning'>LIGHT!</span>")
				cat.Move(targloc)
				cat.Immobilize(1 SECONDS)
			else
				cat.visible_message("<span class='notice'>[cat] looks uninterested in your games.</span>","<span class='warning'>You spot [user] shining [src] at you. How insulting!</span>")

	//laser pointer image
	icon_state = "pointer_[pointer_icon_state]"
	var/image/I = image('icons/obj/guns/projectiles.dmi',targloc,pointer_icon_state,10)
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

	flick_overlay_view(I, targloc, 10)
	icon_state = "pointer"

/obj/item/laser_pointer/process(delta_time)
	if(!diode)
		recharging = FALSE
		return PROCESS_KILL
	if(DT_PROB(10 + diode.rating*10 - recharge_locked*1, delta_time)) //t1 is 20, 2 40
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = FALSE
			recharge_locked = FALSE
			return ..()
