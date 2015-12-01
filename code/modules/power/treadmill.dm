//The ultimate in green energy, a treadmill generates very low power each time it is bumped, which also updates its icon
//to move. You can still optimize this, though, by making yourself a workout machine -- be full, have sugar,
//have sports drink, have a high movespeed, have HULK as a mutation.
//Doesn't consume any idle power, you must Bump() it from its own square. Bump works like a window.
//Using a treadmill uses up hunger faster

#define DEFAULT_BUMP_ENERGY 400

/obj/machinery/power/treadmill
	name = "treadmill generator"
	desc = "A low-power device that generates power based on how quickly someone walks."
	icon_state = "treadmill"
	density = 1
	flags = ON_BORDER
	machine_flags = SCREWTOGGLE | WRENCHMOVE
	anchored = 1
	use_power = 0
	idle_power_usage = 0
	var/count_power = 0 //How much power have we produced SO FAR this count?
	var/tick_power = 0 //How much power did we produce last count?
	var/power_efficiency = 1 //Based on parts
	component_parts = newlist(
		/obj/item/weapon/circuitboard/treadmill,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/console_screen
	)

/obj/machinery/power/treadmill/New()
	if(anchored) connect_to_network()
	RefreshParts()
	..()

/obj/machinery/power/treadmill/RefreshParts()
	var/calc = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor)) calc+=SP.rating
	power_efficiency = calc/4 //Possible results 1, 2, and 3 -- basically, what tier we have

/obj/machinery/power/treadmill/examine(mob/user as mob)
	..()
	to_chat(user, "<span class='info'>During the last cycle, it produced [tick_power] watts.</span>")

/obj/machinery/power/treadmill/process()
	tick_power = count_power
	count_power = 0
	add_avail(tick_power)

/obj/machinery/power/treadmill/proc/powerwalk(atom/movable/AM as mob)
	if(!ismob(AM)) return //Can't walk on a treadmill if you aren't animated
	if(get_turf(AM) != loc) return //Can't bump from the outside
	var/mob/runner = AM
	if(!istype(runner,/mob/living/simple_animal)&&runner.bodytemperature <= 360)
		runner.bodytemperature += 2 //Same heating pattern as being fat
	if(runner.nutrition && runner.stat != DEAD)
		runner.nutrition -= HUNGER_FACTOR*2 //Running on a treadmill makes you hungry fast
	flick("treadmill-running", src)
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
	var/calc = DEFAULT_BUMP_ENERGY * power_efficiency * runner.treadmill_speed
	if(runner.reagents) //Sanity
		for(var/datum/reagent/R in runner.reagents.reagent_list)
			calc *= R.sport
	if(M_HULK in runner.mutations) calc *= 5
	count_power += calc

/obj/machinery/power/treadmill/CheckExit(var/atom/movable/O, var/turf/target)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		powerwalk(O)
		return 0
	return 1

/obj/machinery/power/treadmill/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		if(air_group) return 1
		return 0
	else
		return 1

/obj/machinery/power/treadmill/wrenchAnchor(mob/user)
	..()
	if(anchored) connect_to_network()
	else disconnect_from_network()
