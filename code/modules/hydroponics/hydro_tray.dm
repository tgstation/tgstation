/obj/machinery/portable_atmospherics/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	flags = OPENCONTAINER | PROXMOVE // PROXMOVE could be added and removed as necessary if it causes lag
	volume = 100

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/draw_warnings = 1 // Set to 0 to stop it from drawing the alert lights.
	var/tmp/update_icon_after_process = 0 // Will try to only call update_icon() when necessary.

	// Plant maintenance vars.
	var/waterlevel = 100       // Water (max 100)
	var/nutrilevel = 100       // Nutrient (max 100)
	var/pestlevel = 0          // Pests (max 10)
	var/weedlevel = 0          // Weeds (max 10)
	var/toxins = 0             // Toxicity in the tray (max 100)
	var/improper_light = 0	   // Becomes 1 when the plant has improper lighting, only used for update_icon purposes.
	var/improper_kpa = 0       // Becomes 1 when the environment pressure is too high/too low, only used for update_icon purposes.
	var/improper_heat = 0	   // Becomes 1 when the environment temperature is too low/too high, only used for update_icon purposes.
	var/missing_gas = 0		   // Adds +1 for every type of gas missing, used in process().

	// Tray state vars.
	var/dead = 0               // Is it dead?
	var/harvest = 0            // Is it ready to harvest?
	var/age = 0                // Current plant age
	var/sampled = 0            // Have we taken a sample?

	// Harvest/mutation mods.
	var/yield_mod = 1          // Multiplier to yield for the next harvest.
	var/mutation_mod = 1       // Modifier to mutation_level increase.
	var/mutation_level = 0     // Increases as mutagenic compounds are added, determines potency of resulting mutation when it's called.
	var/is_somatoraying = 0    // Lazy way to make it so that the Floral Somatoray can only cause one mutation at a time.

	// Mechanical concerns.
	var/health = 0             // Plant health.
	var/lastproduce = 0        // Last time tray was harvested.
	var/lastcycle = 0          // Cycle timing/tracking var.
	var/cycledelay = 150       // Delay per cycle.
	var/closed_system          // If set, the tray will attempt to take atmos from a pipe.
	var/force_update           // Set this to bypass the cycle time check.
	var/skip_aging = 0		   // Don't advance age for the next N cycles.

	var/bees = 0				//Are there currently bees above the tray?

	//var/decay_reduction = 0     //How much is mutation decay reduced by?
	var/weed_coefficient = 1    //Coefficient to the chance of weeds appearing
	var/internal_light = 1
	var/light_on = 0

	// Seed details/line data.
	var/datum/seed/seed = null // The currently planted seed

/obj/machinery/portable_atmospherics/hydroponics/New()
	..()
	create_reagents(200)
	connect()
	update_icon()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/hydroponics,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()
	if(closed_system)
		flags &= ~OPENCONTAINER

/obj/machinery/portable_atmospherics/hydroponics/RefreshParts()
	var/capcount = 0
	//var/scancount = 0
	var/mattercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor)) capcount += SP.rating
		//if(istype(SP, /obj/item/weapon/stock_parts/scanning_module)) scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin)) mattercount += SP.rating
	//decay_reduction = scancount
	weed_coefficient = 2/mattercount
	internal_light = capcount

/obj/machinery/portable_atmospherics/hydroponics/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

//Makes the plant not-alive, with proper sanity.
/obj/machinery/portable_atmospherics/hydroponics/proc/die()
	dead = 1
	harvest = 0
	mutation_level = 0
	yield_mod = 1
	mutation_mod = 1
	improper_light = 0
	improper_kpa = 0
	improper_heat = 0
	// When the plant dies, weeds thrive and pests die off.
	weedlevel += 1 * HYDRO_SPEED_MULTIPLIER
	pestlevel = 0
	update_icon()

//Calls necessary sanity when a plant is removed from the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_plant()
	yield_mod = 1
	mutation_mod = 1
	pestlevel = 0
	seed = null
	dead = 0
	age = 0
	sampled = 0
	harvest = 0
	improper_light = 0
	improper_kpa = 0
	improper_heat = 0
	set_light(0)
	update_icon()

//Harvests the product of a plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/harvest(var/mob/user)


	//Harvest the product of the plant,
	if(!seed || !harvest || !user)
		return

	if(closed_system)
		to_chat(user, "You can't harvest from the plant while the lid is shut.")
		return

	if(!seed.check_harvest(user))
		return

	seed.harvest(user,yield_mod)

	// Reset values.
	harvest = 0
	lastproduce = age

	if(!seed.harvest_repeat)
		remove_plant()

	check_level_sanity()
	update_icon()
	return

//Clears out a dead plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_dead(var/mob/user)
	if(!user || !dead) return

	if(closed_system)
		to_chat(user, "You can't remove the dead plant while the lid is shut.")
		return

	remove_plant()

	to_chat(user, "You remove the dead plant from the [src].")
	check_level_sanity()
	update_icon()
	return

 // If a weed growth is sufficient, this proc is called.
/obj/machinery/portable_atmospherics/hydroponics/proc/weed_invasion()


	//Remove the seed if something is already planted.
	if(seed) remove_plant()
	seed = plant_controller.seeds[pick(list("reishi","nettles","amanita","mushrooms","plumphelmet","towercap","harebells","weeds"))]
	if(!seed) return //Weed does not exist, someone fucked up.

	health = seed.endurance
	lastcycle = world.time
	weedlevel = 0
	update_icon()
	visible_message("<span class='info'>[initial(name)] has been overtaken by [seed.display_name]</span>.")

	return

/obj/machinery/portable_atmospherics/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(O.is_open_container())
		return 0

	if (istype(O, /obj/item/seeds))

		if(!seed)

			var/obj/item/seeds/S = O
			user.drop_item(S)

			if(!S.seed)
				to_chat(user, "The packet seems to be empty. You throw it away.")
				qdel(O)
				return

			to_chat(user, "You plant the [S.seed.seed_name] [S.seed.seed_noun].")
			switch(S.seed.spread)
				if(1)
					var/turf/T = get_turf(src)
					msg_admin_attack("[key_name(user)] has planted a creeper packet. <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>")
				if(2)
					var/turf/T = get_turf(src)
					msg_admin_attack("[key_name(user)] has planted a spreading vine packet. <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>")

			seed = S.seed //Grab the seed datum.
			dead = 0
			age = 1
			if(seed.hematophage) nutrilevel = 1

			//Snowflakey, maybe move this to the seed datum
			health = (istype(S, /obj/item/seeds/cutting) ? round(seed.endurance/rand(2,5)) : seed.endurance)

			lastcycle = world.time

			qdel(O)

			check_level_sanity()
			update_icon()

		else
			to_chat(user, "<span class='alert'>\The [src] already has seeds in it!</span>")

	else if(O.force && seed && user.a_intent == I_HURT)
		visible_message("<span class='danger'>\The [seed.display_name] has been attacked by [user] with \the [O]!</span>")
		if(!dead)
			health -= O.force
			check_health()
		user.delayNextAttack(5)

	else if(istype(O, /obj/item/claypot))
		to_chat(user, "<span class='warning'>You must place the pot on the ground and use a spade on \the [src] to make a transplant.</span>")
		return

	else if(seed && istype(O, /obj/item/weapon/pickaxe/shovel))
		var/obj/item/claypot/C = locate() in range(user,1)
		if(!C)
			to_chat(user, "<span class='warning'>You need an empty clay pot next to you.</span>")
			return
		playsound(loc, 'sound/items/shovel.ogg', 50, 1)
		if(do_after(user, src, 50))
			user.visible_message(	"<span class='notice'>[user] transplants \the [seed.display_name] into \the [C].</span>",
									"<span class='notice'>[bicon(src)] You transplant \the [seed.display_name] into \the [C].</span>",
									"<span class='notice'>You hear a ratchet.</span>")

			var/obj/structure/claypot/S = new(get_turf(C))
			transfer_fingerprints(C, S)
			qdel(C)

			if(seed.large)
				S.icon_state += "-large"

			if(dead)
				S.overlays += image(seed.plant_dmi,"[seed.plant_icon]-dead")
			else if(harvest)
				S.overlays += image(seed.plant_dmi,"[seed.plant_icon]-harvest")
			else if(age < seed.maturation)
				var/t_growthstate = max(1,round((age * seed.growth_stages) / seed.maturation))
				S.overlays += image(seed.plant_dmi,"[seed.plant_icon]-grow[t_growthstate]")
			else
				S.overlays += image(seed.plant_dmi,"[seed.plant_icon]-grow[seed.growth_stages]")

			S.plant_name = seed.display_name

			if(seed.biolum)
				S.set_light(round(seed.potency/10))
				if(seed.biolum_colour)
					S.light_color = seed.biolum_colour

			remove_plant()

			check_level_sanity()
			update_icon()

		return

	else if(is_type_in_list(O, list(/obj/item/weapon/wirecutters, /obj/item/weapon/scalpel)))

		if(!seed)
			to_chat(user, "There is nothing to take a sample from in \the [src].")
			return

		if(sampled)
			to_chat(user, "You have already sampled from this plant.")
			return

		if(dead)
			to_chat(user, "The plant is dead.")
			return

		// Create a sample.
		seed.spawn_seed_packet(get_turf(user))
		to_chat(user, "You take a sample from the [seed.display_name].")
		health -= (rand(3,5)*10)

		if(prob(30))
			sampled = 1

		// Bookkeeping.
		check_level_sanity()
		force_update = 1
		process()

		return

	else if (istype(O, /obj/item/weapon/minihoe))

		if(weedlevel > 0)
			user.visible_message("<span class='alert'>[user] starts uprooting the weeds.</span>", "<span class='alert'>You remove the weeds from the [src].</span>")
			weedlevel = 0
			update_icon()
		else
			to_chat(user, "<span class='alert'>This plot is completely devoid of weeds. It doesn't need uprooting.</span>")

	else if (istype(O, /obj/item/weapon/storage/bag/plants))

		attack_hand(user)

		var/obj/item/weapon/storage/bag/plants/S = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)

	else if ( istype(O, /obj/item/weapon/plantspray) )

		var/obj/item/weapon/plantspray/spray = O
		user.drop_item(spray, force_drop = 1)
		toxins += spray.toxicity
		pestlevel -= spray.pest_kill_str
		weedlevel -= spray.weed_kill_str
		to_chat(user, "You spray [src] with [O].")
		playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
		qdel(O)

		check_level_sanity()
		update_icon()

	else if(istype(O, /obj/item/weapon/tank))
		return // Maybe someday make it draw atmos from it so you don't need a whoopin canister, but for now, nothing.

	else if(iswrench(O) && istype(src, /obj/machinery/portable_atmospherics/hydroponics/soil)) //Soil isn't a portable atmospherics machine by any means
		return //Don't call parent. I mean, soil shouldn't be a child of portable_atmospherics at all, but that's not very feasible.

	else if(istype(O, /obj/item/apiary))

		if(seed)
			to_chat(user, "<span class='alert'>[src] is already occupied!</span>")
		else
			user.drop_item(O, force_drop = 1)
			qdel(O)

			var/obj/machinery/apiary/A = new(src.loc)
			A.icon = src.icon
			A.icon_state = src.icon_state
			A.hydrotray_type = src.type
			A.component_parts = component_parts.Copy()
			A.contents = contents.Copy()
			contents.len = 0
			component_parts.len = 0
			qdel(src)

	else if(O.is_sharp() && harvest)
		attack_hand(user)

	else
		return ..()

/obj/machinery/portable_atmospherics/hydroponics/attack_tk(mob/user as mob)

	if(harvest)
		harvest(user)

	else if(dead)
		remove_dead(user)

/obj/machinery/portable_atmospherics/hydroponics/attack_ai(mob/user as mob)

	return //Until we find something smart for you to do, please steer clear. Thanks

/obj/machinery/portable_atmospherics/hydroponics/attack_robot(mob/user as mob)

	if(isMoMMI(user) && Adjacent(user)) //Are we a beep ping ?
		return attack_hand(user) //Let them use the tray

/obj/machinery/portable_atmospherics/hydroponics/attack_hand(mob/user as mob)

	if(isobserver(user))
		if(!(..()))
			return 0
	if(harvest)
		harvest(user)
	else if(dead)
		remove_dead(user)

	else
		examine(user) //using examine() to display the reagents inside the tray as well

/obj/machinery/portable_atmospherics/hydroponics/examine(mob/user)
	..()
	view_contents(user)

/obj/machinery/portable_atmospherics/hydroponics/proc/view_contents(mob/user)
	if(src.seed && !src.dead)
		to_chat(user, "<span class='info'>[src.seed.display_name]</span> is growing here.")
		if(src.health <= (src.seed.endurance / 2))
			to_chat(user, "The plant looks <span class='alert'>[age > seed.lifespan ? "old and wilting" : "unhealthy"].</span>")
	else if(src.seed && src.dead)
		to_chat(user, "[src] is full of dead plant matter.")
	else
		to_chat(user, "[src] has nothing planted.")
	if (Adjacent(user) || isobserver(user) || issilicon(user))
		to_chat(user, "Water: [round(src.waterlevel,0.1)]/100")
		if(seed && seed.hematophage) to_chat(user, "<span class='danger'>Blood:</span> [round(src.nutrilevel,0.1)]/10") //so edgy!!
		else to_chat(user, "Nutrient: [round(src.nutrilevel,0.1)]/10")
		if(src.weedlevel >= 5)
			to_chat(user, "[src] is <span class='alert'>filled with weeds!</span>")
		if(src.pestlevel >= 5)
			to_chat(user, "[src] is <span class='alert'>filled with tiny worms!</span>")
		if(draw_warnings)
			if(src.toxins >= 40)
				to_chat(user, "The tray's <span class='alert'>toxicity level alert</span> is flashing red.")
			if(improper_light)
				to_chat(user, "The tray's <span class='alert'>improper light level alert</span> is blinking.")
			if(improper_heat)
				to_chat(user, "The tray's <span class='alert'>improper temperature alert</span> is blinking.")
			if(improper_kpa)
				to_chat(user, "The tray's <span class='alert'>improper environment pressure alert</span> is blinking.")
			if(missing_gas)
				to_chat(user, "The tray's <span class='alert'>improper gas environment alert</span> is blinking.")

		if(!istype(src,/obj/machinery/portable_atmospherics/hydroponics/soil))

			var/turf/T = loc
			var/datum/gas_mixture/environment

			if(closed_system && (connected_port || holding))
				environment = air_contents

			if(!environment)
				if(istype(T))
					environment = T.return_air()

			if(!environment)
				if(istype(T, /turf/space))
					environment = space_gas
				else //Somewhere we shouldn't be, panic
					return

			var/light_available = 5
			if(T.dynamic_lighting)
				light_available = T.get_lumcount() * 10

			to_chat(user, "The tray's sensor suite is reporting a light level of [round(light_available, 0.1)] lumens and a temperature of [environment.temperature]K.")

/obj/machinery/portable_atmospherics/hydroponics/verb/close_lid()
	set name = "Toggle Tray Lid"
	set category = "Object"
	set src in view(1)

	if(!usr || usr.isUnconscious() || usr.restrained())
		return

	closed_system = !closed_system
	to_chat(usr, "You [closed_system ? "close" : "open"] the tray's lid.")
	if(closed_system)
		flags &= ~OPENCONTAINER
	else
		flags |= OPENCONTAINER

	update_icon()

/obj/machinery/portable_atmospherics/hydroponics/verb/light_toggle()
	set name = "Toggle Light"
	set category = "Object"
	set src in view(1)
	if(!usr || usr.isUnconscious() || usr.restrained())
		return
	light_on = !light_on
	calculate_light()

/obj/machinery/portable_atmospherics/hydroponics/verb/set_label()
	set name = "Set Tray Label"
	set category = "Object"
	set src in view(1)

	if(!usr || usr.isUnconscious() || usr.restrained())
		return

	var/n_label = copytext(reject_bad_text(input(usr, "What would you like to set the tray's label display to?", "Hydroponics Tray Labeling", null) as text), 1, MAX_NAME_LEN)
	if(!usr || !n_label || !Adjacent(usr) || usr.isUnconscious() || usr.restrained())
		return

	labeled = copytext(n_label, 1, 32) //technically replaces any traditional hand labeler labels, but will anyone really complain?
	update_name()
	new/atom/proc/remove_label(src)

/obj/machinery/portable_atmospherics/hydroponics/remove_label()
	..()
	update_name()

/obj/machinery/portable_atmospherics/hydroponics/HasProximity(mob/living/simple_animal/M)
	if(seed && !dead && seed.carnivorous == 2 && age > seed.maturation)
		if(istype(M, /mob/living/simple_animal/mouse) || istype(M, /mob/living/simple_animal/lizard) && !M.locked_to && !M.anchored)
			spawn(10)
				if(!M || !Adjacent(M) || M.locked_to || M.anchored) return // HasProximity() will likely fire a few times almost simultaneously, so spawn() is tricky with it's sanity
				visible_message("<span class='warning'>\The [seed.display_name] hungrily lashes a vine at \the [M]!</span>")
				if(M.health > 0)
					M.Die()
				lock_atom(M, /datum/locking_category/hydro_tray)
				spawn(30)
					if(M && M.loc == get_turf(src))
						unlock_atom(M)
						M.gib(meat = 0) //"meat" argument only exists for mob/living/simple_animal/gib()
						nutrilevel += 6
						check_level_sanity()
						update_icon()

/obj/machinery/portable_atmospherics/hydroponics/bullet_act(var/obj/item/projectile/Proj)

	//Don't act on seeds like dionaea that shouldn't change.
	if(seed && seed.immutable > 0)
		return

	//Override for somatoray projectiles.
	if(!is_somatoraying && istype(Proj ,/obj/item/projectile/energy/floramut))
		var/obj/item/projectile/energy/floramut/P = Proj
		var/sev = P.mutstrength
		is_somatoraying = 1
		spawn(4*sev)
			is_somatoraying = 0
			if(src && seed && !seed.immutable && !dead) //spawn() is tricky with sanity
				mutate(sev)
				if(prob(30) && seed.yield != -1)
					apply_mut("plusstat_yield", sev)
				return
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		if(seed && !dead)
			yield_mod = Clamp(yield_mod + (rand(3,5)/10), 1, 2)
			if(yield_mod >= 2)
				visible_message("<span class='notice'>\The [seed.display_name] looks lush and healthy.</span>")
			return

	..()

/datum/locking_category/hydro_tray
