
/*
Warping extracts crossbreed
put up a rune with bluespace effects, lots of those runes are fluff or act as a passive buff, others are just griefing tools */


/obj/item/slimecross/warping
	name = "warped extract"
	desc = "It just won't stay in place."
	icon_state = "warping"
	effect = "warping"
	colour = "grey"
	///what runes will be drawn depending on the crossbreed color
	var/obj/effect/warped_rune/runepath
	/// the number of "charge" a bluespace crossbreed start with
	var/warp_charge = 1
	///max number of charge, might be different depending on the crossbreed
	var/max_charge = 1
	///time it takes to store the rune back into the crossbreed
	var/storing_time = 15
	///time it takes to draw the rune
	var/drawing_time = 15


/obj/effect/warped_rune
	name = "warped rune"
	desc = "An unstable rune born of the depths of bluespace"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "greyspace_rune"
	move_resist = INFINITY  //here to avoid the rune being moved since it only sets it's turf once when it's drawn. doesn't include admin fuckery.
	anchored = TRUE
	layer = MID_TURF_LAYER
	resistance_flags = FIRE_PROOF
	///is only used for bluespace crystal erasing as of now
	var/storing_time = 5
	///Nearly all runes needs to know which turf they are on
	var/turf/rune_turf
	///starting cooldown of the rune.
	var/cooldown = 0
	///duration of the cooldown for the rune only applies to certain runes
	var/max_cooldown = 100

/obj/item/slimecross/warping/Initialize()
	. = ..()
	desc = "It just won't stay in place. it has [warp_charge] charge left"



///runes can also be deleted by bluespace crystals relatively fast as an alternative to cleaning them.
/obj/effect/warped_rune/attackby(obj/item/used_item, mob/user)
	. = ..()
	if(!istype(used_item,/obj/item/stack/sheet/bluespace_crystal) && !istype(used_item,/obj/item/stack/ore/bluespace_crystal))
		return

	var/obj/item/stack/space_crystal = used_item
	if(do_after(user, storing_time,target = src)) //the time it takes to nullify it depends on the rune too
		to_chat(user, "<span class='notice'>You nullify the effects of the rune with the bluespace crystal!</span>")
		qdel(src)
		space_crystal.amount--
		playsound(src, 'sound/effects/phasein.ogg', 20, TRUE)

		if(space_crystal.amount <= 0)
			qdel(space_crystal)


/obj/effect/warped_rune/acid_act()
	. = ..()
	visible_message("<span class='warning'>[src] has been dissolved by the acid</span>")
	playsound(src, 'sound/items/welder.ogg', 150, TRUE)
	qdel(src)


///nearly all runes use their turf in some way so we set rune_turf to their turf automatically, the rune also start on cooldown if it uses one.
/obj/effect/warped_rune/Initialize()
	. = ..()
	rune_turf = get_turf(src)
	RegisterSignal(rune_turf, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_rune)
	cooldown = world.time + max_cooldown


/obj/effect/warped_rune/proc/clean_rune()
	qdel(src)


///using the extract on the floor will "draw" the rune.
/obj/item/slimecross/warping/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(isturf(target) && locate(/obj/effect/warped_rune) in target) //check if the target is a floor and if there's a rune on said floor
		to_chat(user, "<span class='warning'>There is already a bluespace rune here!</span>")
		return

	if(istype(target, runepath))       //checks if the target is a rune and then if you can store it
		if(warp_charge >= max_charge)
			to_chat(user, "<span class='warning'>[src] is already full!</span>")
			return

		if(do_after(user, storing_time,target = target) && warp_charge < max_charge)
			to_chat(user, "<span class='notice'>You store the rune in [src].</span>")
			qdel(target)
			warp_charge++
			desc = "It just won't stay in place. it has [warp_charge] charge left"
			return

	if(!istype(target,/turf/open))
		return

	if(isspaceturf(target))
		to_chat(user, "<span class='warning'>you cannot draw a rune in space!</span>")
		return

	if((istype(target,/turf/open/lava)) || (istype(target,/turf/open/chasm))) // check if there's a wall or a structure in the way
		to_chat(user, "<span class='warning'>You can't draw the rune here!</span>")
		return

	if(warp_charge <= 0) //spawns the right rune if you have charge(s) left
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(do_after(user, drawing_time,target = target))
		if(warp_charge <= 0) //In case the state has changed since we started the do_after
			return

		playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)
		warp_charge--
		desc = "It just won't stay in place. it has [warp_charge] charge left"
		new runepath(target)
		to_chat(user, "<span class='notice'>You carefully draw the rune with [src].</span>")




/obj/item/slimecross/warping/grey
	name = "greyspace crossbreed"
	colour = "grey"
	effect_desc = "Creates a rune. Extracts that are on the rune are absorbed, 8 extracts produces an adult slime of that color."
	runepath = /obj/effect/warped_rune/greyspace


/obj/effect/warped_rune/greyspace
	name = "greyspace rune"
	desc = "Death is merely a setback, anything can be rebuilt given the right components"
	icon_state = "greyspace_rune"
	max_cooldown = 30
	///number of slime extract currently absorbed by the rune
	var/absorbed_extracts = 0
	///mob path of the slime spawned by the rune
	var/mob/living/simple_animal/slime/spawned_slime
	///extractype is used to remember the type of the extract on the rune
	var/extractype = FALSE


/obj/effect/warped_rune/greyspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/greyspace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		slimerevival()


///Makes a slime of the color of the extract that was put on the rune.can only take one type of extract between slime spawning.
/obj/effect/warped_rune/greyspace/proc/slimerevival()
	for(var/obj/item/slime_extract/extract in rune_turf)
		if(extract.color_slime == extractype || !extractype) //check if the extract is the first one or of the right color.
			extractype = extract.color_slime
			qdel(extract)    //vores the slime extract
			playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
			absorbed_extracts++
			if (absorbed_extracts < 8)
				return

			playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
			spawned_slime = new(rune_turf, extractype)  //spawn a slime from the extract's color
			spawned_slime.amount_grown = SLIME_EVOLUTION_THRESHOLD
			spawned_slime.Evolve() //slime starts as an adult
			absorbed_extracts = 0
			extractype = FALSE // reset extractype to FALSE to allow a new extract type
			RegisterSignal(spawned_slime, COMSIG_PARENT_QDELETING, .proc/delete_slime)


/obj/effect/warped_rune/greyspace/proc/delete_slime()
	spawned_slime = null


/obj/effect/warped_rune/greyspace/Destroy()
	extractype = null
	return ..()


/*The orange rune warp basically ignites whoever walks on it,the fire will teleport you at random as long as you are on fire*/


/obj/item/slimecross/warping/orange
	desc = "Creates a rune "
	colour = "orange"
	runepath = /obj/effect/warped_rune/orangespace
	effect_desc = "Creates a rune burning with bluespace fire, anyone walking into the rune will ignite and teleport randomly as long as they are on fire"
	drawing_time = 150


/obj/effect/warped_rune/orangespace
	desc = "When all is reduced to ash, it shall be reborn from the depth of bluespace."
	icon_state = "bluespace_fire"
	max_cooldown = 50


///teleport people and put them on fire if they run into the rune.
/obj/effect/warped_rune/orangespace/Crossed(atom/movable/burned)
	. = ..()
	if(!locate(/obj/effect/hotspot) in rune_turf) //will create a hotspot to burn items passing through too.
		new /obj/effect/hotspot(rune_turf)

	if(istype(burned,/mob/living/carbon/human))
		var/mob/living/carbon/human/burning = burned
		burning.adjust_fire_stacks(10)
		burning.IgniteMob()
		addtimer(CALLBACK(src, .proc/bluespace_fire, burning), 70, TIMER_OVERRIDE|TIMER_UNIQUE)


///will keep teleporting the person every 5 seconds as long as they are on fire
/obj/effect/warped_rune/orangespace/proc/bluespace_fire(mob/living/burning)
	if(burning.fire_stacks > 0)
		do_teleport(burning, get_turf(burning), 5, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
		addtimer(CALLBACK(src, .proc/bluespace_fire, burning), 70, TIMER_OVERRIDE|TIMER_UNIQUE)


/*The purple warp rune makes suture and ointment if you put cloth or plastic on it. */


/obj/item/slimecross/warping/purple
	colour = "purple"
	runepath = /obj/effect/warped_rune/purplespace
	effect_desc = "Draws a rune that transforms plastic into regenerative mesh and cloth into suture"


/obj/effect/warped_rune/purplespace
	desc = "When all that was left were plastic walls and the clothes on their back, they knew what they had to do."
	icon_state = "purplespace"
	max_cooldown = 30
	///object path of the suture spawned
	var/obj/item/stack/medical/suture/suture
	///object path of the regenerative mesh spawned
	var/obj/item/stack/medical/mesh/regen_mesh

/obj/effect/warped_rune/purplespace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/purplespace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		transmute_heal()


///transforms cloth and plastic into suture and regenerative mesh
/obj/effect/warped_rune/purplespace/proc/transmute_heal()
	for(var/obj/item/stack/sheet/plastic/plastic in rune_turf)  //replace plastic with regenerative mesh
		if(plastic.amount < 2)
			return

		plastic.use(2)
		regen_mesh = new (rune_turf,1)
		playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
		if(plastic.amount <= 0)
			qdel(plastic)

	for(var/obj/item/stack/sheet/cloth/cloth in rune_turf) //replace cloth with suture
		if(cloth.amount < 2)
			return

		cloth.use(2)
		suture = new(rune_turf, 1)
		playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
		if(cloth.amount <= 0)
			qdel(cloth)


/* the blue warp rune  keeps a tile slippery CONSTANTLY by adding lube over it. Excellent if you hate standing up.*/


/obj/item/slimecross/warping/blue
	colour = "blue"
	runepath = /obj/effect/warped_rune/cyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "creates a rune that constantly wet itself with slippery lube as long as the rune is up"


/obj/effect/warped_rune/cyanspace
	icon_state = "slipperyspace"
	desc = "You will crawl like the rest. Standing up is not an option."


/obj/effect/warped_rune/cyanspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/cyanspace/process()
	slippery_rune(rune_turf)


///Spawn lube on the tile the rune is on every process, Cannot lube a non open turf
/obj/effect/warped_rune/cyanspace/proc/slippery_rune(turf/open/lube_turf)
	lube_turf.MakeSlippery(TURF_WET_LUBE,min_wet_time = 10 SECONDS, wet_time_to_add = 2 SECONDS)


/*Metal rune : makes an invisible wall. actually I lied, the rune is the wall.*/


/obj/item/slimecross/warping/metal
	colour = "metal"
	runepath = /obj/effect/warped_rune/metalspace
	effect_desc = "Draws a rune that prevents passage above it, takes longer to store and draw than other runes."
	drawing_time = 50  //Longer to draw like most griefing runes
	storing_time = 25
	max_charge = 4 //higher to allow a wider degree of fuckery, still takes a long ass time to draw but you can draw multiple ones at once.
	warp_charge = 4


//It's a wall what do you want from me
/obj/effect/warped_rune/metalspace
	desc = "Words are powerful things, they can stop someone dead in their tracks if used in the right way"
	icon_state = "metal_space"
	density = TRUE
	storing_time = 10 //faster to destroy with the bluespace crystal than with the crossbreed


/*  Yellow rune space acts as an infinite generator, works without power and anywhere, recharges the APC of the room it's in and any battery fueled things.*/


/obj/item/slimecross/warping/yellow
	colour = "yellow"
	runepath = /obj/effect/warped_rune/yellowspace
	effect_desc = "Draws a rune that infinitely recharge any items as long as they have a battery. It will also passively recharge the APC of the room"


/obj/effect/warped_rune/yellowspace
	desc = "Where does all this energy come from? Who knows,the process does not matter, only the result."
	icon_state = "elec_rune"


/obj/effect/warped_rune/yellowspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/yellowspace/process()
	if(cooldown > world.time)
		return

	var/area/rune_area = get_area(rune_turf)
	cooldown = world.time + max_cooldown
	for(var/obj/item/recharged in rune_turf) //recharges items on the rune
		electrishare(recharged)
	for(var/obj/machinery/power/apc/apc_recharged in rune_area) //recharges the APC of the room
		electrishare(apc_recharged)


///charge the battery of an item by 20% every time it's called.
/obj/effect/warped_rune/yellowspace/proc/electrishare(obj/recharged)
	if(recharged.get_cell()) //check if the item has a cell
		var/obj/item/stock_parts/cell/battery = recharged.get_cell()
		if(battery.charge >= battery.maxcharge) //don't charge if the battery is full
			return

		battery.charge += battery.maxcharge * 0.2
		if(battery.charge > battery.maxcharge)
			battery.charge = battery.maxcharge
		battery.update_icon()
		recharged.update_icon()

/* Dark purple crossbreed, Fill up any beaker like container with 50 unit of plasma dust every 30 seconds  */


/obj/item/slimecross/warping/darkpurple
	colour = "dark purple"
	runepath = /obj/effect/warped_rune/darkpurplespace
	effect_desc = "Makes a rune that will periodically create plasma dust,to harvest it simply put a beaker of some kind over the rune."


/obj/effect/warped_rune/darkpurplespace
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "plasma_crystal"
	desc = "The purple ocean would only grow bigger with time."
	max_cooldown = 300 //creates 50 unit every 30 seconds


/obj/effect/warped_rune/darkpurplespace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/darkpurplespace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		dust_maker()


/obj/effect/warped_rune/darkpurplespace/proc/dust_maker()
	for(var/obj/item/reagent_containers/glass/beaker in rune_turf)
		beaker.reagents.add_reagent(/datum/reagent/toxin/plasma,25)


/*People who step on the dark blue rune will suddendly get very cold,pretty straight forward.*/


/obj/item/slimecross/warping/darkblue
	colour = "dark blue"
	runepath = /obj/effect/warped_rune/darkbluespace
	effect_desc = "Draws a rune creating an unbearable cold above the rune."


/obj/effect/warped_rune/darkbluespace
	desc = "Cold,so cold, why does the world always feel so cold?"
	icon_state = "cold_rune"


/obj/effect/warped_rune/darkbluespace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(rune_turf,COMSIG_ATOM_ENTERED,.proc/cold_tile)


/obj/effect/warped_rune/darkbluespace/process() //will keep the person on the tile cold for good measure
	cold_tile()


///it makes people that step on the tile very cold.
/obj/effect/warped_rune/darkbluespace/proc/cold_tile()
	for(var/mob/living/carbon/human in rune_turf)
		human.adjust_bodytemperature(-1000) //Not enough to crit anyone not already weak to cold, might need serious rebalance if cold damage is reworked.


/* makes a rune that absorb food, whenever someone step on the rune the nutrition come back to them, not all of it of course.*/


/obj/item/slimecross/warping/silver
	colour = "silver"
	effect_desc = "Draws a rune that will absorb nutriment from foods that are above it and then redistribute it to anyone passing by."
	runepath = /obj/effect/warped_rune/silverspace


/obj/effect/warped_rune/silverspace
	desc = "Feed me and I will feed you back, such is the deal."
	icon_state = "food_rune"
	///Used to remember how much food/nutriment has been absorbed by the rune
	var/nutriment = 0


/obj/effect/warped_rune/silverspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


///any food put on the rune with nutrients will have said nutrients absorbed by the rune. Then the nutrients will be redirected to the people on the rune
/obj/effect/warped_rune/silverspace/process()
	for(var/obj/item/reagent_containers/food/nutriment_source in rune_turf) //checks if there's snacks on the rune.and then vores the food
		for(var/datum/reagent/consumable/nutriment/nutr in nutriment_source.reagents.reagent_list)
			nutriment += round((nutr.nutriment_factor * nutr.volume) / (nutr.metabolization_rate)) //the value of nutrition for the nutriment unit
			nutriment_source.reagents.remove_reagent(nutr.type,1)
			desc = "Feed me and I will feed you back. I currently hold [nutriment] units of nutrition."

	for(var/mob/living/carbon/human/person_fed in rune_turf)
		if(HAS_TRAIT(person_fed, TRAIT_NOHUNGER) || (person_fed.nutrition >= NUTRITION_LEVEL_WELL_FED) || (nutriment <= 0)) //don't need to feed a perfectly well-fed boi
			return

		var/nutrition_to_add = min(nutriment, max(round(NUTRITION_LEVEL_FULL - 1 - person_fed.nutrition), 0))
		person_fed.nutrition += nutrition_to_add
		nutriment -= nutrition_to_add
		desc = "Feed me and I will feed you back. I currently hold [nutriment] units of nutrition."


/obj/effect/warped_rune/silverspace/Destroy()
	nutriment = null
	return ..()


/* Bluespace rune,reworked so that the last person that walked on the rune will swap place with the next person stepping on it*/


/obj/item/slimecross/warping/bluespace
	colour = "bluespace"
	runepath = /obj/effect/warped_rune/bluespace
	effect_desc = "Puts up a rune that will swap the next two person that walk on the rune."


/obj/effect/warped_rune/bluespace
	desc = "Everyone is everywhere at once, yet so far away from each other"
	icon_state = "bluespace_rune"
	max_cooldown = 30 //only here to avoid spam lag
	/// first person to run into the rune
	var/mob/living/carbon/first_person
	///second person that run into the rune
	var/mob/living/carbon/second_person
	///here to remember if the rune has been stepped on before
	var/stepped_on = 0


///the first two person that stepped on the rune swap places after the second person stepped on it.
/obj/effect/warped_rune/bluespace/Crossed(atom/movable/crossing)
	. = ..()
	if(cooldown > world.time) //checks if 2 seconds have passed to avoid spam.
		return

	cooldown = max_cooldown + world.time
	if(!istype(crossing,/mob/living/carbon/human))
		return

	if(stepped_on == 0)
		first_person = crossing //remember who stepped in so we can teleport them later.
		stepped_on++
		return

	if(crossing == first_person)
		return

	second_person = crossing
	do_teleport(second_person, first_person, forceMove = TRUE)//swap both of their place.
	do_teleport(first_person, rune_turf, forceMove = TRUE)
	stepped_on--


/obj/effect/warped_rune/bluespace/Destroy()
	first_person = null
	second_person = null
	return ..()


/* will make anyone stepping over it older and much slower for a few second, step on it too much or be too old and you'll get dusted.*/


/obj/item/slimecross/warping/sepia
	colour = "sepia"
	runepath = /obj/effect/warped_rune/sepiaspace
	effect_desc = "Draws a rune that make people grow older and slower until they eventually wither away."
	drawing_time = 100 //much longer to draw than other runes because it fucking stops time


/obj/effect/warped_rune/sepiaspace
	icon_state = "time_space"
	desc = "The clock is ticking, but in what direction?"


///slows down whoever walks on the rune and makes them older by five years. if the person goes above 120 years they get dusted.Very similar to the "old timer" reagent code with a few tweaks.
/obj/effect/warped_rune/sepiaspace/Crossed(atom/movable/crossing)
	. = ..()
	var/mob/living/carbon/human/slowed_down
	if(istype(crossing,/mob/living/carbon/human))
		slowed_down = crossing
		if(slowed_down.age < 50) //not counterable by just being ultra young
			slowed_down.age = 50

		slowed_down.age += 5
		if(slowed_down.age < 100)
			to_chat(slowed_down, "<span class='warning'>The rune is absorbing your life force! You feel older!</span>")

		if(slowed_down.age >= 100)
			to_chat(slowed_down, "<span class='warning'>You feel incredibly old! You should avoid this rune at all cost!</span>")
			slowed_down.become_nearsighted(type)
			if(slowed_down.gender == MALE)
				slowed_down.facial_hairstyle = "Beard (Very Long)"
				slowed_down.update_hair()

		if(slowed_down.age >= 120)
			slowed_down.visible_message("<span class='notice'>[slowed_down] is too old and weak to resist the rune anymore!</span>")
			slowed_down.dust(0,1,0)
			return

	slowed_down.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/sepia_rune)
	addtimer(CALLBACK(src, .proc/normal_speed, slowed_down), 50, TIMER_OVERRIDE|TIMER_UNIQUE)


/obj/effect/warped_rune/sepiaspace/proc/normal_speed(mob/living/slowed_down)
	slowed_down.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/sepia_rune)


/obj/effect/warped_rune/sepiaspace/Destroy()
	return ..()


/*Cerulean crossbreed : creates a hologram of the last person that stepped on the tile */


/obj/item/slimecross/warping/cerulean
	colour = "cerulean"
	runepath = /obj/effect/warped_rune/ceruleanspace
	effect_desc = "Draws a rune creating a hologram of the last living thing that stepped on the tile."
	max_charge = 1
	warp_charge = 1


/obj/effect/warped_rune/ceruleanspace
	desc = "A shadow of what once passed these halls, a memory perhaps?"
	icon_state = "holo_rune"
	max_cooldown = 100
	///hologram that will be spawned by the rune
	var/obj/effect/overlay/holotile
	///mob the hologram will copy
	var/mob/living/holo_host
	///used to remember the recent speech of the holo_host
	var/list/recent_speech = list()
	///used to remember the timer ID that activates holo_talk


/obj/effect/warped_rune/ceruleanspace/Initialize()
	. = ..()
	cooldown = 0 //doesn't start on cooldown
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/ceruleanspace/proc/holo_talk()
	if(holotile && length(recent_speech))
		holotile.say(recent_speech[pick(recent_speech)]) //say one of the 10 latest sentence said by the holo_host
		addtimer(CALLBACK(src, .proc/holo_talk), 100, TIMER_OVERRIDE|TIMER_UNIQUE)



///makes a hologram of the mob stepping on the tile, any new person stepping in will replace it with a new hologram
/obj/effect/warped_rune/ceruleanspace/Crossed(atom/movable/crossing)
	. = ..()
	if(!istype(crossing,/mob/living) || cooldown > world.time)
		return

	if(locate(holotile) in rune_turf)//here to delete the previous hologram,
		qdel(holotile)
		holotile = null

	cooldown = max_cooldown + world.time
	holo_host = crossing
	holotile = new(rune_turf) //setting up the hologram to look like the person that just stepped in
	holotile.icon = holo_host.icon
	holotile.icon_state = holo_host.icon_state
	holotile.alpha = 100
	holotile.name = "[holo_host.name] (Hologram)"
	holotile.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	holotile.copy_overlays(holo_host, TRUE)


//the code that follows is basically the code that changeling use to get people's last spoken sentences with a few tweaks.
	recent_speech = list() //resets the list from its previous sentences
	var/list/say_log = list()
	var/log_source = holo_host.logging
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
			var/list/reversed = log_source[log_type]  //reverse the list so we get the last sentences instead of the first
			if(islist(reversed))
				say_log = reverseRange(reversed.Copy())
				break

	if(length(say_log) > 10) //we're going to get up to the last 10 sentences spoken by the holo_host
		recent_speech = say_log.Copy(say_log.len - 11,0)
	else
		for(var/spoken_memory in say_log)
			if(recent_speech.len >= 10)
				break
			recent_speech[spoken_memory] = say_log[spoken_memory]

	addtimer(CALLBACK(src, .proc/holo_talk), 100, TIMER_OVERRIDE|TIMER_UNIQUE)


///destroys the hologram with the rune
/obj/effect/warped_rune/ceruleanspace/Destroy()
	qdel(holotile)
	holotile = null
	holo_host = null
	recent_speech = null
	return ..()


/obj/item/slimecross/warping/pyrite
	colour = "pyrite"
	runepath = /obj/effect/warped_rune/pyritespace
	effect_desc = "draws a rune that will randomly color whatever steps on it"


/obj/effect/warped_rune/pyritespace
	desc = "Who shall we be today? they asked, but not even the canvas would answer."
	icon_state = "colorune"


///colors whatever steps on the rune randomly
/obj/effect/warped_rune/pyritespace/Crossed(atom/movable/AM)
	. = ..()
	AM.color = rgb(rand(0,255),rand(0,255),rand(0,255))


/* Will make anyone on the rune do genetic punch damage. May need rebalancing. Not compatible with gloves of the north star*/


/obj/item/slimecross/warping/red
	colour = "red"
	runepath = /obj/effect/warped_rune/redspace
	effect_desc = "Draws a rune giving your fists the ability to hurt the very soul of whoever you punch, healing you in the process."
	drawing_time = 30


/obj/effect/warped_rune/redspace
	desc = "Progress is made through adversity, power is obtained through violence"
	icon_state = "rage_rune"
	///fire overlay appearing behind someone when they are on the rune
	var/mutable_appearance/hate_fire


/obj/effect/warped_rune/redspace/Initialize()
	. = ..()
	hate_fire = image('icons/mob/OnFire.dmi',"Standing", RAGE_FIRE_LAYER)
	hate_fire.color = "#C01414" //dark red kind of.
	hate_fire.layer = RAGE_FIRE_LAYER

///boost up the unarmed damage of the person currently on the tile.
/obj/effect/warped_rune/redspace/Crossed(atom/movable/crossing)
	. = ..()
	if(!istype(crossing,/mob/living/carbon/human))
		return

	var/mob/living/carbon/human/enraged = crossing
	enraged.add_overlay(hate_fire)
	RegisterSignal(enraged, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/genetic_punch)
	to_chat(enraged, "<span class='warning'>You feel the hate of a thousand souls culminating into your fists!</span>")


/obj/effect/warped_rune/redspace/proc/genetic_punch(mob/living/puncher, atom/attacked)
	if(!istype(attacked,/mob/living/carbon/human) || puncher.a_intent != INTENT_HARM)
		return

	var/mob/living/carbon/human/punched = attacked
	if(punched.mind && punched.stat != DEAD)
		puncher.adjustBruteLoss(-40)//Heal the puncher per punch. Only works on players that are alive.
		puncher.adjustFireLoss(-40)
	punched.adjustCloneLoss(40) //genetic damage is the closest thing we have to soul damage
	playsound(puncher, 'sound/effects/pop_expl.ogg', 75, TRUE)
	to_chat(puncher, "<span class='warning'>You punch [punched]'s soul with all your might!</span>")
	to_chat(punched, "<span class='warning'>You feel like something very important got punched out of you!</span>")
	puncher.do_attack_animation(punched, ATTACK_EFFECT_SMASH)
	return COMPONENT_NO_ATTACK_HAND //here to make sure we replace the original punch with our genetic punch


///takes away the overlay and the genetic punch when you leave the rune
/obj/effect/warped_rune/redspace/Uncrossed(atom/movable/crossing)
	. = ..()
	if(!istype(crossing,/mob/living/carbon/human))
		return
	var/mob/living/carbon/human/enraged = crossing
	UnregisterSignal(enraged, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	enraged.cut_overlay(hate_fire)

///destroying the rune will also remove the punch force of the persons on the rune.
/obj/effect/warped_rune/redspace/Destroy()
	for(var/mob/living/carbon/human/enraged in rune_turf)
		UnregisterSignal(enraged, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
		enraged.cut_overlay(hate_fire)
	return ..()


/* Green rune vores plasma and spews out xeno resin which lets you build xeno structure*/


/obj/item/slimecross/warping/green
	colour = "green"
	runepath = /obj/effect/warped_rune/greenspace
	drawing_time = 100


/obj/effect/warped_rune/greenspace
	icon_state = "xeno_rune"
	desc = "We will build walls out of our fallen foes, they shall fear our very buildings."
	max_cooldown = 100
	///path of the xeno resin sheet to spawn by the rune
	var/obj/item/stack/sheet/xeno_resin/resin


/obj/item/stack/sheet/xeno_resin
	name = "Resin sheets"
	icon = 'icons/mob/alien.dmi'
	icon_state = "nestoverlay" //literally just the xeno nest icon
	merge_type = /obj/item/stack/sheet/xeno_resin


/obj/effect/warped_rune/greenspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/greenspace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		transmute_resin()


/obj/effect/warped_rune/greenspace/proc/transmute_resin()
	for(var/obj/item/stack/sheet/mineral/plasma/plasma_sheet in rune_turf)
		resin = new(rune_turf)
		plasma_sheet.use(1)
		if(plasma_sheet.amount <= 0)
			qdel(plasma_sheet)


//note : some of these can only be built ON resin weeds such as the resin nest.
GLOBAL_LIST_INIT(resin_recipes, list ( \
	new/datum/stack_recipe("Resin seed", /obj/structure/alien/weeds/node, 10, one_per_turf = 1, on_floor = 1, time = 100), \
	new/datum/stack_recipe("Resin Wall", /obj/structure/alien/resin/wall, 3, one_per_turf = 1, on_floor = 1 , time = 50), \
	new/datum/stack_recipe("Fake hatched egg", /obj/structure/alien/egg/burst, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Resin nest", /obj/structure/bed/nest , 5, one_per_turf = 1, on_floor = 0, time = 50), \
	))


/obj/item/stack/sheet/xeno_resin/get_main_recipes()
	. = ..()
	. += GLOB.resin_recipes


/* pink rune, makes people slightly happier after walking on it*/


/obj/item/slimecross/warping/pink
	colour = "pink"
	effect_desc = "Draws a rune that makes people happier!"
	runepath = /obj/effect/warped_rune/pinkspace


/obj/effect/warped_rune/pinkspace
	desc = "Love is the only reliable source of happiness we have left. But like everything, it comes with a price."
	icon_state = "love_rune"


///adds the jolly mood effect along with hug sound effect.
/obj/effect/warped_rune/pinkspace/Crossed(atom/movable/crossing)
	. = ..()
	if(istype(crossing,/mob/living/carbon/human))
		playsound(rune_turf, "sound/weapons/thudswoosh.ogg", 50, TRUE)
		SEND_SIGNAL(crossing, COMSIG_ADD_MOOD_EVENT,"jolly", /datum/mood_event/jolly)
		crossing.visible_message(crossing, "<span class='notice'>You feel happier.</span>")


/*Gold rune : Turn things over it to gold, completely fucks over economy */

/obj/item/slimecross/warping/gold
	colour = "gold"
	runepath = /obj/effect/warped_rune/goldspace
	effect_desc = "Draws a rune that will add hostile animals to the rune's personal army if they stay on it. The next person to walk on the rune will be attacked by the rune's army."


/obj/effect/warped_rune/goldspace
	icon_state = "midas_rune"
	desc = "We will make an army to conquer bluespace itself. We have no shortage of willing soldiers after all."
	max_cooldown = 100
	///used to remember the mobs currently contained by the rune
	var/list/mob_list = list()


/obj/effect/warped_rune/goldspace/Initialize()
	. = ..()
	cooldown = 0 //the cooldown is only used when someone step on the rune


///Will vore hostile mobs on the rune and add them to the mob_list of the rune. 10 maximum number of mobs in the rune.
/obj/effect/warped_rune/goldspace/attack_hand(mob/living/user)
	if(cooldown > world.time)
		to_chat(user,"<span class='notice'>The rune needs a little bit more time before absorbing more animals!</span>")
		return

	if(length(mob_list) >= 10) //no more than 10 good boys allowed.
		to_chat(user,"<span class='notice'>The rune's army is as full as it can be!</span>")
		return

	for(var/mob/living/simple_animal/hostile/captured in rune_turf)
		if(istype(captured,/mob/living/simple_animal/hostile/megafauna) || captured.stat == DEAD) //Megafaunas are too thick to be proper soldiers
			return

		mob_list += captured.type
		qdel(captured)
		playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
		to_chat(user,"<span class='warning'>The rune somehow absorbs [captured] into itself!</span>")


///will unleash all the mobs in the rune on the rune and give them the person that just crossed the rune their first target.
/obj/effect/warped_rune/goldspace/Crossed(atom/movable/crossing)
	. = ..()
	if(!istype(crossing,/mob/living/carbon/human))
		return

	for(var/mob_type in mob_list)
		var/mob/living/simple_animal/hostile/spawned_mob = new mob_type(rune_turf)
		spawned_mob.GiveTarget(crossing)
		//make crossing a priority target for the mobs.
		//they WILL attack others if they lose their target however.
		//Because they are given a target from the get go they will react much faster after spawn than usual.
		mob_list -= mob_type
		cooldown = world.time + max_cooldown //you can't instantly reuse the rune to send the mobs back into the rune.


/obj/effect/warped_rune/goldspace/Destroy()
	mob_list = null
	return ..()


/*Adamantine rune, will spawn ores depending on the mineral rocks surrounding it. Here to make miners do their job even less.  */


/obj/item/slimecross/warping/adamantine
	colour = "adamantine"
	runepath = /obj/effect/warped_rune/adamantinespace
	effect_desc = "draws a rune capable of copying the ores of nearby mineral rocks."


/obj/effect/warped_rune/adamantinespace  //doesn't have a rune icon yet please spriters help me I can't sprite for shit I beg you
	desc = "The universe's ressource are nothing but tools for us to use and abuse."
	max_cooldown = 300  //"mines" things every 30 seconds.
	icon_state = "mining_rune"


/obj/effect/warped_rune/adamantinespace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/adamantinespace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		auto_mining()


/obj/effect/warped_rune/adamantinespace/proc/auto_mining()
	for(var/turf/closed/mineral/ores in range(7,rune_turf)) //the range is pretty big to at least try to rival miners and their plasma cutters.
		if(ores.mineralType != null) //here to counter runtimes when the mineral type of the rock is null
			new ores.mineralType(rune_turf)


/* Lightpink rune. Revive suicided/soulless corpses by yeeting a willing soul into it */


/obj/item/slimecross/warping/lightpink
	colour = "light pink"
	runepath = /obj/effect/warped_rune/lightpinkspace
	effect_desc = "draws a rune that will attempt to repair a soulless humanoid corpse in the hope of bringing them back to life."
	drawing_time = 100


/obj/effect/warped_rune/lightpinkspace
	icon_state = "necro_rune"
	desc = "Souls are like any other material, You just have to find the right place to manufacture them."
	max_cooldown = 600


/obj/effect/warped_rune/lightpinkspace/attack_hand(mob/living/user)
	if(cooldown > world.time)
		to_chat(user, "<span class='warning'>The rune is still charging!</span>")
		return

	for(var/mob/living/carbon/human/host in rune_turf)
		if(!host.getorgan(/obj/item/organ/brain) || host.key || host.get_ghost(FALSE, TRUE)) //checks if the ghost and brain's there
			to_chat(user, "<span class='warning'>This body can't be fixed by the rune in this state!</span>")
			return

		cooldown = world.time + max_cooldown //only start the cooldown if there's an actual body on there and it can be resurrected.
		to_chat(user, "<span class='warning'>The rune is trying to repair [host.name]'s soul!</span>")
		var/list/candidates = pollCandidatesForMob("Do you want to replace the soul of [host.name]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, host,POLL_IGNORE_SENTIENCE_POTION)//sentience flags because lightpink.

		if(length(candidates) && !host.mind) //check if anyone wanted to play as the dead person and check if no one's in control of the body one last time.
			var/mob/dead/observer/ghost = pick(candidates)
			host.key = ghost.key
			host.suiciding = 0 //turns off the suicide var just in case
			host.revive(full_heal = TRUE, admin_revive = TRUE) //might as well heal them all the way back up
			to_chat(host, "<span class='boldwarning'>You may wear the skin of someone else, but you know who and what you are. Pretend to be the original owner of this body as best as you can.</span>")
			to_chat(user, "<span class='notice'>[host.name] is slowly getting back up. It...worked?</span>")
			playsound(host, "sound/magic/castsummon.ogg", 50, TRUE)
			return

		to_chat(user, "<span class='warning'>The rune failed! Maybe you should try again later.</span>")


/* black space rune : will swap out the species of the two next person walking on the rune  */


/obj/item/slimecross/warping/black
	colour = "black"
	runepath = /obj/effect/warped_rune/blackspace
	effect_desc = "Will swap the species of the first two humanoids that walk on the rune. Also works on corpses."
	drawing_time = 100


/obj/effect/warped_rune/blackspace
	icon_state = "cursed_rune"
	desc = "Your body is the problem, limited, so very very limited."
	///first person to step on the rune
	var/mob/living/carbon/human/first_person
	///second person to step on the rune
	var/mob/living/carbon/human/second_person
	///here to check if someone already stepped on the rune
	var/stepped_on = FALSE


/obj/effect/warped_rune/blackspace/Initialize()
	. = ..()
	cooldown = 0 //doesn't start on cooldown like most runes


///will swap the species of the first two human or human subset that walk on the rune
/obj/effect/warped_rune/blackspace/Crossed(atom/movable/crossing)
	. = ..()
	if(cooldown > world.time) //here to avoid spam/lag
		to_chat(crossing, "<span class='warning'>The rune needs a little more time before processing your DNA!</span>")
		return

	if(!istype(crossing,/mob/living/carbon/human))
		return

	var/mob/living/carbon/human/crosser = crossing
	if(!stepped_on)
		first_person = crosser
		stepped_on = TRUE
		return

	if(crosser == first_person || crosser.stat == DEAD)
		return

	second_person = crosser
	var/first_dna = first_person.dna.species
	var/second_dna = second_person.dna.species
	second_person.set_species(first_dna)  //swap the species
	first_person.set_species(second_dna)
	stepped_on = FALSE
	cooldown = max_cooldown + world.time //the default max cooldown is of 10 seconds

/obj/effect/warped_rune/blackspace/Destroy()
	first_person = null
	second_person = null
	return ..()


/*Acts as a bunker making anything into the rune immune to outside explosions and gas leaks. doesn't work if the epicenter of the explosion is IN the rune */


/obj/item/slimecross/warping/oil
	colour = "oil"
	runepath = /obj/effect/warped_rune/oilspace
	effect_desc = "protects anything on the rune from explosions unless the rune is in the center of the explosion."


/obj/effect/warped_rune/oilspace
	icon_state = "oil_rune"
	desc = "The world is ending, but we have one last trick up our sleeve, we will survive."
	///used to remember the oilspace_bunker specific to this rune
	var/list/bunker_list = list()


/obj/effect/oilspace_bunker //we'll surround the rune with these so it "blocks" nearby explosions. Although only the rune itself is 100% protected
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = TRUE //no one can see those
	anchored = TRUE
	explosion_block = INFINITY
	CanAtmosPass = ATMOS_PASS_NO //will also try to stop gas from exiting the rune to keep the pressure and air of the tile.Doesn't always work
	move_resist = INFINITY //we need it to stay in the same place until it's deleted.
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/effect/warped_rune/oilspace/Initialize()
	. = ..()
	for(var/turf/bunker_turf in range(1,rune_turf))
		var/obj/effect/oilspace_bunker/bunker_wall = new /obj/effect/oilspace_bunker(bunker_turf)
		bunker_list += bunker_wall


/obj/effect/warped_rune/oilspace/Destroy()
	for(var/obj/effect/oilspace_bunker/bunker_wall in range(1,rune_turf))
		if(bunker_wall in bunker_list)
			bunker_list -= bunker_wall
			qdel(bunker_wall)
		if(!length(bunker_list))
			bunker_list = null //no need to keep an empty list around
			return ..()


/* Used to teleport anything over it to a unique room similar to hilbert's hotel.*/


/obj/item/slimecross/warping/rainbow
	colour = "rainbow"
	effect_desc = "draws a rune that will teleport anything above it "
	runepath = /obj/effect/warped_rune/rainbowspace
	drawing_time = 150
	storing_time = 100

/obj/effect/warped_rune/rainbowspace
	icon_state = "rainbow_rune"
	desc = "This is where I go when I want to be alone. Yet they keep clawing at the walls until everything crumbles."
	///current x,y,z location of the reserved space for the rune room
	var/datum/turf_reservation/room_reservation
	///the template of the warped_room map
	var/datum/map_template/warped_room/rune_room
	///list of people that teleported into the rune_room. The room will dissapear if the list is empty and the rune is destroyed.
	var/list/customer_list = list()


/obj/effect/warped_room_exit
	name = "warped_rune"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rainbow_rune"
	desc = "Use this rune if you want to leave this place. You will have to leave eventually."
	move_resist = INFINITY
	anchored = TRUE
	///where the rune will teleport you back.
	var/turf/exit_turf
	///rune linked to the exit rune
	var/obj/effect/warped_rune/rainbowspace/enter_rune


/datum/map_template/warped_room
	name = "Warped room"
	mappath = '_maps/templates/warped_room.dmm'


/area/warped_room
	name = "warped room"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = TRUE
	noteleport = TRUE


///creates the warped room and place an exit rune to exit the room
/obj/effect/warped_rune/rainbowspace/Initialize()
	. = ..()
	rune_room = new()
	room_reservation = SSmapping.RequestBlockReservation(rune_room.width, rune_room.height) //monkey sees valid location
	rune_room.load(locate(room_reservation.bottom_left_coords[1], room_reservation.bottom_left_coords[2], room_reservation.bottom_left_coords[3]))//monkey room activate
	var/obj/effect/warped_room_exit/exit_rune = new(locate(room_reservation.bottom_left_coords[1] + 3, room_reservation.bottom_left_coords[2] + 6, room_reservation.bottom_left_coords[3]))
	exit_rune.exit_turf = rune_turf
	exit_rune.enter_rune = src


///here to check if anyone's being transported in or out of the room with the user.
/obj/effect/warped_rune/rainbowspace/proc/customer_check(atom/person_checked ,smuggle_in)
	var/list/hidden_customers = person_checked.GetAllContents(/mob/living/carbon/human)
	if(!length(hidden_customers))
		return
	for(var/mob/living/carbon/human/customer in hidden_customers)
		if(smuggle_in)
			customer_list += customer //if they enter the room
		else
			customer_list -= customer //if they exit the room


/obj/effect/warped_rune/rainbowspace/attack_hand(mob/living/user)
	. = ..()
	for(var/mob/living/carbon/human/customer in rune_turf)
		customer.forceMove(locate(room_reservation.bottom_left_coords[1] + 3, room_reservation.bottom_left_coords[2] + 6, room_reservation.bottom_left_coords[3]))
		customer_check(customer, TRUE)


///Will delete the room when the rune is destroyed if no customer is left in the room
/obj/effect/warped_rune/rainbowspace/Destroy()
	if(!length(customer_list))
		customer_list = null
		qdel(room_reservation)
	return ..()


///anyone on the exit rune when it is used will be teleported to the rune that was used to teleport to the warped room
/obj/effect/warped_room_exit/attack_hand(mob/living/user)
	. = ..()
	for(var/mob/living/carbon/human/customer in get_turf(src))
		customer.forceMove(exit_turf)
		do_sparks(3, FALSE, get_turf(src))
		enter_rune.customer_check(customer, FALSE)

	if(!length(enter_rune.customer_list) && !locate(enter_rune) in exit_turf) //deletes the room if the rune doesn't exist anymore and all customers have left
		enter_rune.customer_list = null
		qdel(enter_rune.room_reservation)
		qdel(src)
		return ..()
