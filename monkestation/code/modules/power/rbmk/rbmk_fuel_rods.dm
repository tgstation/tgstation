/obj/item/fuel_rod
	name = "uranium-238 fuel rod"
	desc = "A titanium sheathed rod containing a measure of enriched uranium-dioxide powder inside, and a breeding blanket of uranium-238 around it, used to kick off a fission reaction and breed plutonium fuel respectivly."
	icon = 'monkestation/icons/obj/control_rod.dmi'
	icon_state = "irradiated"
	w_class = WEIGHT_CLASS_BULKY

	var/depletion = 0 //Each fuel rod will deplete in around 30 minutes.
	var/fuel_power = 0.10

	var/rad_strength = 500
	var/half_life = 2000 // how many depletion ticks are needed to half the fuel_power (1 tick = 1 second)
	var/time_created = 0
	var/og_fuel_power = 0.20 //the original fuel power value
	var/process = FALSE
	// The depletion where depletion_final() will be called (and does something)
	var/depletion_threshold = 100
	// How fast this rod will deplete
	var/depletion_speed_modifier = 1
	var/depleted_final = FALSE // depletion_final should run only once
	var/depletion_conversion_type = "plutonium"

/obj/item/fuel_rod/Initialize()
	.=..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	AddComponent(/datum/component/radioactive, 350 , src)

/obj/item/fuel_rod/Initialize(mapload)
	. = ..()
	time_created = world.time
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)
	AddComponent(/datum/component/radioactive, rad_strength, src) // This should be temporary for it won't make rads go lower than 350
	if(process)
		START_PROCESSING(SSobj, src)

/obj/item/fuel_rod/Destroy()
	if(process)
		STOP_PROCESSING(SSobj, src)
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/N = loc
	if(istype(N))
		N.fuel_rods -= src
	return ..()

// This proc will try to convert your fuel rod if you don't override this proc
// So, ideally, you should write an override of this for every fuel rod you want to create
/obj/item/fuel_rod/proc/depletion_final(result_rod)
	if(!result_rod)
		return
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/nuclear_reactor = loc
	// Rod conversion is moot when you can't find the reactor
	if(istype(nuclear_reactor))
		var/obj/item/fuel_rod/fuel_rod
		// You can add your own depletion scheme and not override this proc if you are going to convert a fuel rod into another type
		switch(result_rod)
			if("plutonium")
				fuel_rod = new /obj/item/fuel_rod/plutonium(loc)
				fuel_rod.depletion = depletion
			if("depleted")
				if(fuel_power < 10)
					fuel_power = 0
					playsound(loc, 'sound/effects/supermatter.ogg', 100, TRUE)
					fuel_rod = new /obj/item/fuel_rod/depleted(loc)
					fuel_rod.depletion = depletion

		// Finalization of conversion
		if(istype(fuel_rod))
			nuclear_reactor.fuel_rods += fuel_rod
			qdel(src)
	else
		depleted_final = FALSE // Maybe try again later?

/obj/item/fuel_rod/proc/deplete(amount=0.035)
	depletion += amount * depletion_speed_modifier
	if(depletion >= depletion_threshold && !depleted_final)
		depleted_final = TRUE
		depletion_final(depletion_conversion_type)

/obj/item/fuel_rod/plutonium
	fuel_power = 0.20
	name = "plutonium-239 fuel rod"
	desc = "A highly energetic titanium sheathed rod containing a sizeable measure of weapons grade plutonium, it's highly efficient as nuclear fuel, but will cause the reaction to get out of control if not properly utilised."
	icon_state = "inferior"
	rad_strength = 1500
	process = TRUE
	depletion_threshold = 300
	depletion_conversion_type = "depleted"

/obj/item/fuel_rod/process()
	fuel_power = og_fuel_power * 0.5**((world.time - time_created) / half_life SECONDS) // halves the fuel power every half life (33 minutes)

/obj/item/fuel_rod/depleted
	fuel_power = 0.05
	name = "depleted fuel rod"
	desc = "A highly radioactive fuel rod which has expended most of it's useful energy."
	icon_state = "normal"
	rad_strength = 6000 // smelly
	depletion_conversion_type = null // we don't want it to turn into anything
	process = TRUE

// Master type for material optional (or requiring, wyci) and/or producing rods
/obj/item/fuel_rod/material
	// Whether the rod has been harvested. Should be set in expend().
	var/expended = FALSE
	// The material that will be inserted and then multiplied (or not). Should be some sort of /obj/item/stack
	var/material_type
	// The name of material that'll be used for texts
	var/material_name
	var/material_name_singular
	/// Initial Material in fuel rod
	var/initial_amount = 0
	// The maximum amount of material the rod can hold
	var/max_initial_amount = 10
	var/grown_amount = 0
	// The multiplier for growth. 1 for the same 2 for double etc etc
	var/multiplier = 2
	// After this depletion, you won't be able to add new materials
	var/material_input_deadline = 25
	// Material fuel rods generally don't get converted into another fuel object
	depletion_conversion_type = null

// Called when the rod is fully harvested
/obj/item/fuel_rod/material/proc/expend()
	expended = TRUE

// Basic checks for material rods
/obj/item/fuel_rod/material/proc/check_material_input(mob/user)
	if(depletion >= material_input_deadline)
		to_chat(user, "<span class='warning'>The sample slots have sealed themselves shut, it's too late to add [material_name] now!</span>") // no cheesing in crystals at 100%
		return FALSE
	if(expended)
		to_chat(user, "<span class='warning'>\The [src]'s material slots have already been used.</span>")
		return FALSE
	return TRUE

// The actual growth
/obj/item/fuel_rod/material/depletion_final(result_rod)
	if(result_rod)
		..() // So if you put anything into depletion_conversion_type then your fuel rod will be converted (or not) and *won't grow*
	else
		grown_amount = initial_amount * multiplier

/obj/item/fuel_rod/material/attackby(obj/item/obj_item, mob/user, params)
	var/obj/item/stack/material_stack = obj_item
	if(istype(material_stack, material_type))
		if(!check_material_input(user))
			return
		if(initial_amount < max_initial_amount)
			var/adding = min((max_initial_amount - initial_amount), material_stack.amount)
			material_stack.amount -= adding
			initial_amount += adding
			if(adding == 1)
				to_chat(user, "<span class='notice'>You insert [adding] [material_name_singular] into \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>You insert [adding] [material_name] into \the [src].</span>")
			material_stack.zero_amount()
		else
			to_chat(user, "<span class='warning'>\The [src]'s material slots are full!</span>")
			return
	else
		return ..()

/obj/item/fuel_rod/material/attack_self(mob/user)
	if(expended)
		to_chat(user, "<span class='notice'>You have already removed [material_name] from \the [src].</span>")
		return

	if(depleted_final)
		new material_type(user.loc, grown_amount)
		if(grown_amount == 1)
			to_chat(user, "<span class='notice'>You harvest [grown_amount] [material_name_singular] from \the [src].</span>") // Unlikely
		else
			to_chat(user, "<span class='notice'>You harvest [grown_amount] [material_name] from \the [src].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		grown_amount = 0
		expend()
		return
	if(depletion)
		to_chat(user, "<span class='warning'>\The [src] has not fissiled enough to fully grow the sample. The progress bar shows it is [min(depletion/depletion_threshold*100,100)]% complete.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return
	if(initial_amount)
		new material_type(user.loc, initial_amount)
		if(initial_amount == 1)
			to_chat(user, "<span class='notice'>You remove [initial_amount] [material_name_singular] from \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>You remove [initial_amount] [material_name] from \the [src].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		initial_amount = 0

/obj/item/fuel_rod/material/examine(mob/user)
	. = ..()
	if(expended)
		. += "<span class='warning'>The material slots have been slagged by the extreme heat, you can't grow [material_name] in this rod again...</span>"
		return
	else if(depleted_final)
		if(grown_amount == 1)
			. += "<span class='warning'>This fuel rod's [material_name] are now fully grown, and it currently bears [grown_amount] harvestable [material_name_singular].</span>"
		else
			. += "<span class='warning'>This fuel rod's [material_name] are now fully grown, and it currently bears [grown_amount] harvestable [material_name].</span>"
		return
	if(depletion)
		. += "<span class='danger'>The sample is [min(depletion/depletion_threshold*100,100)]% fissiled.</span>"
	. += "<span class='disarm'>[initial_amount]/[max_initial_amount] of the slots for [material_name] are full.</span>"

/obj/item/fuel_rod/material/bananium
	name = "bananium fuel rod"
	desc = "A hilarious heavy-duty fuel rod which fissiles a bit slower than its cowardly counterparts. However, its cutting-edge cosmic clown technology allows rooms for extraordinarily exhilarating extraterrestrial element called bananium to menacingly multiply."
	icon_state = "bananium"
	fuel_power = 0.15
	depletion_speed_modifier = 3
	rad_strength = 350
	max_initial_amount = 10
	multiplier = 3
	material_type = /obj/item/stack/sheet/mineral/bananium
	material_name = "sheets of bananium"
	material_name_singular = "sheet of bananium"

/obj/item/fuel_rod/material/bananium/deplete(amount=0.035)
	..()
	if(initial_amount == max_initial_amount && prob(10))
		playsound(src, pick('sound/items/bikehorn.ogg', 'sound/misc/bikehorn_creepy.ogg'), 50) // HONK

/obj/item/fuel_rod/material/bananium/depletion_final(result_rod)
	..()
	if(!result_rod)
		fuel_power = 0.3 // Be warned
		name = "Fully Grown Bananium Fuel Rod"
		desc = "A hilarious heavy-duty fuel rod which fissiles a bit slower than it cowardly counterparts. Its greatly grimacing grwoth stage is now over, and bananium outgrowth hums as if it's blatantly honking bike horns."
		icon_state = "bananium_used"
		AddComponent(/datum/component/radioactive, 1250, src)
