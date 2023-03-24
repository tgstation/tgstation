GLOBAL_LIST_EMPTY(bluespace_slime_crystals)

/obj/structure/slime_crystal
	name = "slimic pylon"
	desc = "Glassy, pure, transparent. Powerful artifact that relays the slimecore's influence onto space around it."
	max_integrity = 5
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slime_pylon"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	///Assoc list of affected mobs, the key is the mob while the value of the map is the amount of ticks spent inside of the zone.
	var/list/affected_mobs = list()
	///Used to determine wether we use view or range
	var/range_type = "range"
	///What color is it?
	var/colour
	///Does it use process?
	var/uses_process = TRUE

/obj/structure/slime_crystal/New(loc, obj/structure/slime_crystal/master_crystal, ...)
	. = ..()
	if(master_crystal)
		invisibility = INVISIBILITY_MAXIMUM
		max_integrity = 1000
		atom_integrity = 1000

/obj/structure/slime_crystal/Initialize()
	. = ..()
	name =  "[colour] slimic pylon"
	var/itemcolor = "#FFFFFF"

	switch(colour)
		if("orange")
			itemcolor = "#FFA500"
		if("purple")
			itemcolor = "#B19CD9"
		if("blue")
			itemcolor = "#ADD8E6"
		if("metal")
			itemcolor = "#7E7E7E"
		if("yellow")
			itemcolor = "#FFFF00"
		if("dark purple")
			itemcolor = "#551A8B"
		if("dark blue")
			itemcolor = "#0000FF"
		if("silver")
			itemcolor = "#D3D3D3"
		if("bluespace")
			itemcolor = "#32CD32"
		if("sepia")
			itemcolor = "#704214"
		if("cerulean")
			itemcolor = "#2956B2"
		if("pyrite")
			itemcolor = "#FAFAD2"
		if("red")
			itemcolor = "#FF0000"
		if("green")
			itemcolor = "#00FF00"
		if("pink")
			itemcolor = "#FF69B4"
		if("gold")
			itemcolor = "#FFD700"
		if("oil")
			itemcolor = "#505050"
		if("black")
			itemcolor = "#000000"
		if("light pink")
			itemcolor = "#FFB6C1"
		if("adamantine")
			itemcolor = "#008B8B"
	add_atom_colour(itemcolor, FIXED_COLOUR_PRIORITY)
	if(uses_process)
		START_PROCESSING(SSobj, src)

/obj/structure/slime_crystal/Destroy()
	if(uses_process)
		STOP_PROCESSING(SSobj, src)
	for(var/X in affected_mobs)
		on_mob_leave(X)
	return ..()

/obj/structure/slime_crystal/process()
	if(!uses_process)
		return PROCESS_KILL

	var/list/current_mobs
	if(range_type == "view")
		current_mobs = view(3, src)
	else
		current_mobs = range(3, src)
	for(var/mob/living/mob_in_range in current_mobs)
		if(!(mob_in_range in affected_mobs))
			on_mob_enter(mob_in_range)
			affected_mobs[mob_in_range] = 0

		affected_mobs[mob_in_range]++
		on_mob_effect(mob_in_range)

	for(var/M in affected_mobs - current_mobs)
		on_mob_leave(M)
		affected_mobs -= M

/obj/structure/slime_crystal/proc/master_crystal_destruction()
	qdel(src)

/obj/structure/slime_crystal/proc/on_mob_enter(mob/living/affected_mob)
	return

/obj/structure/slime_crystal/proc/on_mob_effect(mob/living/affected_mob)
	return

/obj/structure/slime_crystal/proc/on_mob_leave(mob/living/affected_mob)
	return

/obj/structure/slime_crystal/grey
	colour = "grey"
	range_type = "view"

/obj/structure/slime_crystal/grey/on_mob_effect(mob/living/affected_mob)
	if(!istype(affected_mob, /mob/living/simple_animal/slime))
		return
	var/mob/living/simple_animal/slime/slime_mob = affected_mob
	slime_mob.nutrition += 2

/obj/structure/slime_crystal/purple
	colour = "purple"

	var/heal_amt = 2

/obj/structure/slime_crystal/purple/on_mob_effect(mob/living/affected_mob)
	if(!istype(affected_mob, /mob/living/carbon))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	var/rand_dam_type = rand(0, 10)

	new /obj/effect/temp_visual/heal(get_turf(affected_mob), "#e180ff")

	switch(rand_dam_type)
		if(0)
			carbon_mob.adjustBruteLoss(-heal_amt)
		if(1)
			carbon_mob.adjustFireLoss(-heal_amt)
		if(2)
			carbon_mob.adjustOxyLoss(-heal_amt)
		if(3)
			carbon_mob.adjustToxLoss(-heal_amt)
		if(4)
			carbon_mob.adjustCloneLoss(-heal_amt)
		if(5)
			carbon_mob.adjustStaminaLoss(-heal_amt)
		if(6 to 10)
			carbon_mob.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_HEART,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS), -heal_amt)

/obj/structure/slime_crystal/metal
	colour = "metal"

	var/heal_amt = 1

/obj/structure/slime_crystal/metal/on_mob_effect(mob/living/affected_mob)
	if(!iscyborg(affected_mob))
		return
	var/mob/living/silicon/borgo = affected_mob
	borgo.adjustBruteLoss(-heal_amt)

/obj/structure/slime_crystal/yellow
	colour = "yellow"
	light_color = COLOR_YELLOW //a good, sickly atmosphere
	light_power = 0.75
	uses_process = FALSE

/obj/structure/slime_crystal/yellow/Initialize()
	. = ..()
	set_light(3)

/obj/structure/slime_crystal/yellow/attacked_by(obj/item/I, mob/living/user)
	if(istype(I,/obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/cell = I
		//Punishment for greed
		if(cell.charge == cell.maxcharge)
			to_chat("<span class = 'danger'> You try to charge the cell, but it is already fully energized. You are not sure if this was a good idea...")
			cell.explode()
			return
		to_chat("<span class = 'notice'> You charged the [I.name] on [name]!")
		cell.give(cell.maxcharge)
		return
	return ..()

/obj/structure/slime_crystal/darkblue
	colour = "dark blue"

/obj/structure/slime_crystal/darkblue/process()
	var/list/listie = range(5,src)
	for(var/turf/open/T in listie)
		if(prob(75))
			continue
		var/turf/open/open_turf = T
		open_turf.MakeDry(TURF_WET_LUBE)

	for(var/obj/item/trash/trashie in listie)
		if(prob(25))
			qdel(trashie)

/obj/structure/slime_crystal/silver
	colour = "silver"

/obj/structure/slime_crystal/silver/process()
	for(var/obj/machinery/hydroponics/hydr in range(5,src))
		hydr.weedlevel = 0
		hydr.pestlevel = 0
		hydr.age ++

/obj/structure/slime_crystal/bluespace
	colour = "bluespace"
	density = FALSE
	uses_process = FALSE
	///Is it in use?
	var/in_use = FALSE

/obj/structure/slime_crystal/bluespace/Initialize()
	. = ..()
	GLOB.bluespace_slime_crystals += src

/obj/structure/slime_crystal/bluespace/Destroy()
	GLOB.bluespace_slime_crystals -= src
	return ..()

/obj/structure/slime_crystal/bluespace/attack_hand(mob/user)

	if(in_use)
		return

	var/list/local_bs_list = GLOB.bluespace_slime_crystals.Copy()
	local_bs_list -= src
	if(!LAZYLEN(local_bs_list))
		return ..()

	if(local_bs_list.len == 1)
		do_teleport(user, local_bs_list[1])
		return

	in_use = TRUE

	var/list/assoc_list = list()

	for(var/BSC in local_bs_list)
		var/area/bsc_area = get_area(BSC)
		var/name = "[bsc_area.name] bluespace slimic pylon"
		var/counter = 0

		do
			counter++
		while(assoc_list["[name]([counter])"])

		name += "([counter])"

		assoc_list[name] = BSC

	var/chosen_input = input(user,"What destination do you want to choose",null) as null|anything in assoc_list
	in_use = FALSE

	if(!chosen_input || !assoc_list[chosen_input])
		return

	do_teleport(user ,assoc_list[chosen_input])

/obj/structure/slime_crystal/sepia
	colour = "sepia"

/obj/structure/slime_crystal/sepia/on_mob_enter(mob/living/affected_mob)
	ADD_TRAIT(affected_mob,TRAIT_NOBREATH,type)
	ADD_TRAIT(affected_mob,TRAIT_NOCRITDAMAGE,type)
	ADD_TRAIT(affected_mob,TRAIT_RESISTLOWPRESSURE,type)
	ADD_TRAIT(affected_mob,TRAIT_RESISTHIGHPRESSURE,type)
	ADD_TRAIT(affected_mob,TRAIT_NOSOFTCRIT,type)
	ADD_TRAIT(affected_mob,TRAIT_NOHARDCRIT,type)

/obj/structure/slime_crystal/sepia/on_mob_leave(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob,TRAIT_NOBREATH,type)
	REMOVE_TRAIT(affected_mob,TRAIT_NOCRITDAMAGE,type)
	REMOVE_TRAIT(affected_mob,TRAIT_RESISTLOWPRESSURE,type)
	REMOVE_TRAIT(affected_mob,TRAIT_RESISTHIGHPRESSURE,type)
	REMOVE_TRAIT(affected_mob,TRAIT_NOSOFTCRIT,type)
	REMOVE_TRAIT(affected_mob,TRAIT_NOHARDCRIT,type)

/obj/structure/cerulean_slime_crystal
	name = "Cerulean slime poly-crystal"
	desc = "Translucent and irregular, it can duplicate matter on a whim"
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "cerulean_crystal"
	max_integrity = 5
	var/stage = 0
	var/max_stage = 5

/obj/structure/cerulean_slime_crystal/Initialize()
	. = ..()
	transform *= 1/(max_stage-1)
	stage_growth()

/obj/structure/cerulean_slime_crystal/proc/stage_growth()
	if(stage == max_stage)
		return

	if(stage == 3)
		density = TRUE

	stage ++

	var/matrix/M = new
	M.Scale(1/max_stage * stage)

	animate(src, transform = M, time = 60 SECONDS)

	addtimer(CALLBACK(src, .proc/stage_growth), 60 SECONDS)

/obj/structure/cerulean_slime_crystal/Destroy()
	if(stage > 1)
		var/obj/item/cerulean_slime_crystal/crystal = new(get_turf(src))
		crystal.amt = stage
	return ..()

/obj/structure/slime_crystal/cerulean
	colour = "cerulean"

/obj/structure/slime_crystal/cerulean/process()
	for(var/turf/T in range(2,src))
		var/obj/structure/cerulean_slime_crystal/CSC = locate() in range(1,T)
		if(CSC)
			continue
		new /obj/structure/cerulean_slime_crystal(T)

/obj/structure/slime_crystal/pyrite
	colour = "pyrite"
	uses_process = FALSE

/obj/structure/slime_crystal/pyrite/Initialize()
	. = ..()
	change_colour()

/obj/structure/slime_crystal/pyrite/proc/change_colour()
	var/list/color_list = list("#FFA500","#B19CD9", "#ADD8E6","#7E7E7E","#FFFF00","#551A8B","#0000FF","#D3D3D3", "#32CD32","#704214","#2956B2","#FAFAD2", "#FF0000",
					"#00FF00", "#FF69B4","#FFD700", "#505050", "#FFB6C1","#008B8B")
	for(var/turf/T in RANGE_TURFS(4,src))
		T.add_atom_colour(pick(color_list), FIXED_COLOUR_PRIORITY)

	addtimer(CALLBACK(src,.proc/change_colour),rand(0.75 SECONDS,1.25 SECONDS))

/obj/structure/slime_crystal/red
	colour = "red"

	var/blood_amt = 0

	var/max_blood_amt = 300

/obj/structure/slime_crystal/red/examine(mob/user)
	. = ..()
	. += "It has [blood_amt] u of blood."

/obj/structure/slime_crystal/red/process()

	if(blood_amt == max_blood_amt)
		return

	for(var/obj/effect/decal/cleanable/blood/B in range(3,src))
		qdel(B)

		blood_amt++
		if(blood_amt == max_blood_amt)
			return

/obj/structure/slime_crystal/red/attack_hand(mob/user)
	if(blood_amt < 100)
		return ..()

	blood_amt -= 100
	var/type = pick(/obj/item/food/meat/slab,/obj/item/organ/internal/heart,/obj/item/organ/internal/lungs,/obj/item/organ/internal/liver,/obj/item/organ/internal/eyes,/obj/item/organ/internal/tongue,/obj/item/organ/internal/stomach,/obj/item/organ/internal/ears)
	new type(get_turf(src))

/obj/structure/slime_crystal/red/attacked_by(obj/item/I, mob/living/user)
	if(blood_amt < 10)
		return ..()

	if(!istype(I, /obj/item/reagent_containers/cup/beaker))
		return ..()

	var/obj/item/reagent_containers/cup/beaker/item_beaker = I

	if(!item_beaker.is_refillable() || (item_beaker.reagents.total_volume + 10 > item_beaker.reagents.maximum_volume))
		return ..()
	blood_amt -= 10
	item_beaker.reagents.add_reagent(/datum/reagent/blood,10)

/obj/structure/slime_crystal/green
	colour = "green"
	var/datum/mutation/stored_mutation

/obj/structure/slime_crystal/green/examine(mob/user)
	. = ..()
	if(stored_mutation)
		. += "It currently stores [stored_mutation.name]"
	else
		. += "It doesn't hold any mutations"

/obj/structure/slime_crystal/green/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/list/mutation_list = human_user.dna.mutations
	stored_mutation = pick(mutation_list)
	stored_mutation = stored_mutation.type

/obj/structure/slime_crystal/green/on_mob_effect(mob/living/affected_mob)
	if(!ishuman(affected_mob) || !stored_mutation || HAS_TRAIT(affected_mob,TRAIT_BADDNA))
		return
	var/mob/living/carbon/human/human_mob = affected_mob
	human_mob.dna.add_mutation(stored_mutation)

	if(affected_mobs[affected_mob] % 60 != 0)
		return

	var/list/mut_list = human_mob.dna.mutations
	var/list/secondary_list = list()

	for(var/X in mut_list)
		if(istype(X,stored_mutation))
			continue
		var/datum/mutation/t_mutation = X
		secondary_list += t_mutation.type

	var/datum/mutation/mutation = pick(secondary_list)
	human_mob.dna.remove_mutation(mutation)

/obj/structure/slime_crystal/green/on_mob_leave(mob/living/affected_mob)
	if(!ishuman(affected_mob))
		return
	var/mob/living/carbon/human/human_mob = affected_mob
	human_mob.dna.remove_mutation(stored_mutation)

/obj/structure/slime_crystal/pink
	colour = "pink"

/obj/structure/slime_crystal/pink/on_mob_enter(mob/living/affected_mob)
	ADD_TRAIT(affected_mob,TRAIT_PACIFISM,type)

/obj/structure/slime_crystal/pink/on_mob_leave(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob,TRAIT_PACIFISM,type)

/obj/structure/slime_crystal/gold
	colour = "gold"

/obj/structure/slime_crystal/gold/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_mob = user
	var/mob/living/basic/pet/chosen_pet = pick(/mob/living/basic/pet/dog/corgi,/mob/living/basic/pet/dog/pug,/mob/living/basic/pet/dog/bullterrier,/mob/living/simple_animal/pet/fox,/mob/living/simple_animal/pet/cat/kitten,/mob/living/simple_animal/pet/cat/space,/mob/living/simple_animal/pet/penguin)
	chosen_pet = new chosen_pet(get_turf(human_mob))
	human_mob.forceMove(chosen_pet)
	human_mob.mind.transfer_to(chosen_pet)

/obj/structure/slime_crystal/gold/on_mob_leave(mob/living/affected_mob)
	if(!istype(affected_mob,/mob/living/basic/pet))
		return

	var/mob/living/carbon/human/human_mob = locate() in affected_mob

	if(!human_mob)
		return

	affected_mob.mind.transfer_to(human_mob)
	human_mob.forceMove(get_turf(affected_mob))
	qdel(affected_mob)

/obj/structure/slime_crystal/oil
	colour = "oil"

/obj/structure/slime_crystal/oil/process()
	for(var/T in RANGE_TURFS(3,src))
		if(!isopenturf(T))
			continue
		var/turf/open/turf_in_range = T
		turf_in_range.MakeSlippery(TURF_WET_LUBE,5 SECONDS)

/obj/structure/slime_crystal/black
	colour = "black"

/obj/structure/slime_crystal/black/on_mob_effect(mob/living/affected_mob)
	if(!ishuman(affected_mob) || isjellyperson(affected_mob))
		return

	if(affected_mobs[affected_mob] < 60) //Around 2 minutes
		return

	var/mob/living/carbon/human/human_transformed = affected_mob
	human_transformed.set_species(pick(typesof(/datum/species/jelly)))

/obj/structure/slime_crystal/lightpink
	colour = "light pink"

/obj/structure/slime_crystal/lightpink/attack_ghost(mob/user)
	. = ..()
	var/mob/living/simple_animal/hostile/lightgeist/slime/L = new(get_turf(src))
	L.ckey = user.ckey
	affected_mobs[L] = 0
	ADD_TRAIT(L,TRAIT_MUTE,type)
	ADD_TRAIT(L,TRAIT_EMOTEMUTE,type)

/obj/structure/slime_crystal/lightpink/on_mob_leave(mob/living/affected_mob)
	if(istype(affected_mob,/mob/living/simple_animal/hostile/lightgeist/slime))
		affected_mob.ghostize(TRUE)
		qdel(affected_mob)

/obj/structure/slime_crystal/adamantine
	colour = "adamantine"

/obj/structure/slime_crystal/adamantine/on_mob_enter(mob/living/affected_mob)
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/human = affected_mob
	human.dna.species.brutemod -= 0.1
	human.dna.species.burnmod -= 0.1

/obj/structure/slime_crystal/adamantine/on_mob_leave(mob/living/affected_mob)
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/human = affected_mob
	human.dna.species.brutemod += 0.1
	human.dna.species.burnmod += 0.1

/obj/structure/slime_crystal/rainbow
	colour = "rainbow"
	uses_process = FALSE
	var/list/inserted_cores = list()

/obj/structure/slime_crystal/rainbow/Initialize()
	. = ..()
	for(var/X in subtypesof(/obj/item/slimecross/crystalized) - /obj/item/slimecross/crystalized/rainbow)
		inserted_cores[X] = FALSE

/obj/structure/slime_crystal/rainbow/attacked_by(obj/item/I, mob/living/user)
	. = ..()

	if(!istype(I,/obj/item/slimecross/crystalized) || istype(I,/obj/item/slimecross/crystalized/rainbow))
		return

	var/obj/item/slimecross/crystalized/slimecross = I

	if(inserted_cores[slimecross.type])
		return

	inserted_cores[slimecross.type] = new slimecross.crystal_type(get_turf(src),src)
	qdel(slimecross)

/obj/structure/slime_crystal/rainbow/Destroy()
	for(var/X in inserted_cores)
		if(inserted_cores[X])
			var/obj/structure/slime_crystal/SC = inserted_cores[X]
			SC.master_crystal_destruction()
	return ..()

/obj/structure/slime_crystal/rainbow/attack_hand(mob/user)
	for(var/X in inserted_cores)
		if(inserted_cores[X])
			var/obj/structure/slime_crystal/SC = inserted_cores[X]
			SC.attack_hand(user)
	. = ..()

/obj/structure/slime_crystal/rainbow/attacked_by(obj/item/I, mob/living/user)
	for(var/X in inserted_cores)
		if(inserted_cores[X])
			var/obj/structure/slime_crystal/SC = inserted_cores[X]
			SC.attacked_by(user)
	. = ..()
