


/*
field_generator power level display
   The icon used for the field_generator need to have 'num_power_levels' number of icon states
   named 'Field_Gen +p[num]' where 'num' ranges from 1 to 'num_power_levels'

   The power level is displayed using overlays. The current displayed power level is stored in 'powerlevel'.
   The overlay in use and the powerlevel variable must be kept in sync.  A powerlevel equal to 0 means that
   no power level overlay is currently in the overlays list.
   -Aygar
*/

#define field_generator_max_power 250

#define FG_OFFLINE 0
#define FG_CHARGING 1
#define FG_ONLINE 2

//field generator construction defines
#define FG_UNSECURED 0
#define FG_SECURED 1
#define FG_WELDED 2

/obj/machinery/field/generator
	name = "field generator"
	desc = "A large thermal battery that projects a high amount of energy when powered."
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	max_integrity = 500
	//100% immune to lasers and energy projectiles since it absorbs their energy.
	armor = list("melee" = 25, "bullet" = 10, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)
	var/const/num_power_levels = 6	// Total number of power level icon has
	var/power_level = 0
	var/active = FG_OFFLINE
	var/power = 20  // Current amount of power
	var/state = FG_UNSECURED
	var/warming_up = 0
	var/list/obj/machinery/field/containment/fields
	var/list/obj/machinery/field/generator/connected_gens
	var/clean_up = 0

/obj/machinery/field/generator/update_icon()
	cut_overlays()
	if(warming_up)
		add_overlay("+a[warming_up]")
	if(fields.len)
		add_overlay("+on")
	if(power_level)
		add_overlay("+p[power_level]")


/obj/machinery/field/generator/Initialize()
	. = ..()
	fields = list()
	connected_gens = list()

/obj/machinery/field/generator/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES)

/obj/machinery/field/generator/process()
	if(active == FG_ONLINE)
		calc_power()

/obj/machinery/field/generator/interact(mob/user)
	if(state == FG_WELDED)
		if(get_dist(src, user) <= 1)//Need to actually touch the thing to turn it on
			if(active >= FG_CHARGING)
				to_chat(user, "<span class='warning'>You are unable to turn off [src] once it is online!</span>")
				return 1
			else
				user.visible_message("[user] turns on [src].", \
					"<span class='notice'>You turn on [src].</span>", \
					"<span class='italics'>You hear heavy droning.</span>")
				turn_on()
				investigate_log("<font color='green'>activated</font> by [key_name(user)].", INVESTIGATE_SINGULO)

				add_fingerprint(user)
	else
		to_chat(user, "<span class='warning'>[src] needs to be firmly secured to the floor first!</span>")

/obj/machinery/field/generator/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, "<span class='warning'>Turn \the [src] off first!</span>")
		return FAILED_UNFASTEN

	else if(state == FG_WELDED)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is welded to the floor!</span>")
		return FAILED_UNFASTEN

	return ..()

/obj/machinery/field/generator/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			state = FG_SECURED
		else
			state = FG_UNSECURED

/obj/machinery/field/generator/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/field/generator/welder_act(mob/living/user, obj/item/I)
	if(active)
		to_chat(user, "<span class='warning'>[src] needs to be off!</span>")
		return TRUE

	switch(state)
		if(FG_UNSECURED)
			to_chat(user, "<span class='warning'>[src] needs to be wrenched to the floor!</span>")

		if(FG_SECURED)
			if(!I.tool_start_check(user, amount=0))
				return TRUE
			user.visible_message("[user] starts to weld [src] to the floor.", \
				"<span class='notice'>You start to weld \the [src] to the floor...</span>", \
				"<span class='italics'>You hear welding.</span>")
			if(I.use_tool(src, user, 20, volume=50) && state == FG_SECURED)
				state = FG_WELDED
				to_chat(user, "<span class='notice'>You weld the field generator to the floor.</span>")

		if(FG_WELDED)
			if(!I.tool_start_check(user, amount=0))
				return TRUE
			user.visible_message("[user] starts to cut [src] free from the floor.", \
				"<span class='notice'>You start to cut \the [src] free from the floor...</span>", \
				"<span class='italics'>You hear welding.</span>")
			if(I.use_tool(src, user, 20, volume=50) && state == FG_WELDED)
				state = FG_SECURED
				to_chat(user, "<span class='notice'>You cut \the [src] free from the floor.</span>")

	return TRUE


/obj/machinery/field/generator/attack_animal(mob/living/simple_animal/M)
	if(M.environment_smash & ENVIRONMENT_SMASH_RWALLS && active == FG_OFFLINE && state != FG_UNSECURED)
		state = FG_UNSECURED
		anchored = FALSE
		M.visible_message("<span class='warning'>[M] rips [src] free from its moorings!</span>")
	else
		..()
	if(!anchored)
		step(src, get_dir(M, src))

/obj/machinery/field/generator/blob_act(obj/structure/blob/B)
	if(active)
		return 0
	else
		..()

/obj/machinery/field/generator/bullet_act(obj/item/projectile/Proj)
	if(Proj.flag != "bullet")
		power = min(power + Proj.damage, field_generator_max_power)
		check_power_level()
	..()


/obj/machinery/field/generator/Destroy()
	cleanup()
	return ..()


/obj/machinery/field/generator/proc/check_power_level()
	var/new_level = round(num_power_levels * power / field_generator_max_power)
	if(new_level != power_level)
		power_level = new_level
		update_icon()

/obj/machinery/field/generator/proc/turn_off()
	active = FG_OFFLINE
	spawn(1)
		cleanup()
		while (warming_up>0 && !active)
			sleep(50)
			warming_up--
			update_icon()

/obj/machinery/field/generator/proc/turn_on()
	active = FG_CHARGING
	spawn(1)
		while (warming_up<3 && active)
			sleep(50)
			warming_up++
			update_icon()
			if(warming_up >= 3)
				start_fields()


/obj/machinery/field/generator/proc/calc_power(set_power_draw)
	var/power_draw = 2 + fields.len
	if(set_power_draw)
		power_draw = set_power_draw

	if(draw_power(round(power_draw/2,1)))
		check_power_level()
		return 1
	else
		visible_message("<span class='danger'>The [name] shuts down!</span>", "<span class='italics'>You hear something shutting down.</span>")
		turn_off()
		investigate_log("ran out of power and <font color='red'>deactivated</font>", INVESTIGATE_SINGULO)
		power = 0
		check_power_level()
		return 0

//This could likely be better, it tends to start loopin if you have a complex generator loop setup.  Still works well enough to run the engine fields will likely recode the field gens and fields sometime -Mport
/obj/machinery/field/generator/proc/draw_power(draw = 0, failsafe = FALSE, obj/machinery/field/generator/G = null, obj/machinery/field/generator/last = null)
	if((G && (G == src)) || (failsafe >= 8))//Loopin, set fail
		return 0
	else
		failsafe++

	if(power >= draw)//We have enough power
		power -= draw
		return 1

	else//Need more power
		draw -= power
		power = 0
		for(var/CG in connected_gens)
			var/obj/machinery/field/generator/FG = CG
			if(FG == last)//We just asked you
				continue
			if(G)//Another gen is askin for power and we dont have it
				if(FG.draw_power(draw,failsafe,G,src))//Can you take the load
					return 1
				else
					return 0
			else//We are askin another for power
				if(FG.draw_power(draw,failsafe,src,src))
					return 1
				else
					return 0


/obj/machinery/field/generator/proc/start_fields()
	if(state != FG_WELDED || !anchored)
		turn_off()
		return
	move_resist = INFINITY
	spawn(1)
		setup_field(1)
	spawn(2)
		setup_field(2)
	spawn(3)
		setup_field(4)
	spawn(4)
		setup_field(8)
	spawn(5)
		active = FG_ONLINE


/obj/machinery/field/generator/proc/setup_field(NSEW)
	var/turf/T = loc
	if(!istype(T))
		return 0

	var/obj/machinery/field/generator/G = null
	var/steps = 0
	if(!NSEW)//Make sure its ran right
		return 0
	for(var/dist in 0 to 7) // checks out to 8 tiles away for another generator
		T = get_step(T, NSEW)
		if(T.density)//We cant shoot a field though this
			return 0

		G = locate(/obj/machinery/field/generator) in T
		if(G)
			steps -= 1
			if(!G.active)
				return 0
			break

		for(var/TC in T.contents)
			var/atom/A = TC
			if(ismob(A))
				continue
			if(A.density)
				return 0

		steps++

	if(!G)
		return 0

	T = loc
	for(var/dist in 0 to steps) // creates each field tile
		var/field_dir = get_dir(T,get_step(G.loc, NSEW))
		T = get_step(T, NSEW)
		if(!locate(/obj/machinery/field/containment) in T)
			var/obj/machinery/field/containment/CF = new(T)
			CF.set_master(src,G)
			CF.setDir(field_dir)
			fields += CF
			G.fields += CF
			for(var/mob/living/L in T)
				CF.Crossed(L)

	connected_gens |= G
	G.connected_gens |= src
	update_icon()


/obj/machinery/field/generator/proc/cleanup()
	clean_up = 1
	for (var/F in fields)
		qdel(F)

	for(var/CG in connected_gens)
		var/obj/machinery/field/generator/FG = CG
		FG.connected_gens -= src
		if(!FG.clean_up)//Makes the other gens clean up as well
			FG.cleanup()
		connected_gens -= FG
	clean_up = 0
	update_icon()

	//This is here to help fight the "hurr durr, release singulo cos nobody will notice before the
	//singulo eats the evidence". It's not fool-proof but better than nothing.
	//I want to avoid using global variables.
	spawn(1)
		var/temp = 1 //stops spam
		for(var/obj/singularity/O in GLOB.singularities)
			if(O.last_warning && temp)
				if((world.time - O.last_warning) > 50) //to stop message-spam
					temp = 0
					var/turf/T = get_turf(src)
					message_admins("A singulo exists and a containment field has failed at [ADMIN_VERBOSEJMP(T)].")
					investigate_log("has <font color='red'>failed</font> whilst a singulo exists at [AREACOORD(T)].", INVESTIGATE_SINGULO)
			O.last_warning = world.time
	
	move_resist = initial(move_resist)

/obj/machinery/field/generator/shock(mob/living/user)
	if(fields.len)
		..()

/obj/machinery/field/generator/bump_field(atom/movable/AM as mob|obj)
	if(fields.len)
		..()

#undef FG_UNSECURED
#undef FG_SECURED
#undef FG_WELDED

#undef FG_OFFLINE
#undef FG_CHARGING
#undef FG_ONLINE
