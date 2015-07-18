
//Grey
/datum/chemical_reaction/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slimespawn/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/mob/living/simple_animal/slime/S = new /mob/living/simple_animal/slime
	S.loc = get_turf(holder.my_atom)
	S.visible_message("<span class='danger'>Infused with plasma, the core begins to quiver and grow, and soon a new baby slime emerges from it!</span>")

/datum/chemical_reaction/slimeinaprov
	name = "Slime epinephrine"
	id = "m_inaprov"
	result = "epinephrine"
	required_reagents = list("water" = 5)
	result_amount = 3
	required_other = 1
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slimeinaprov/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

/datum/chemical_reaction/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slimemonkey/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/i = 1, i <= 3, i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.loc = get_turf(holder.my_atom)

//Green
/datum/chemical_reaction/slimemutate
	name = "Mutation Toxin"
	id = "mutationtoxin"
	result = "mutationtoxin"
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slimemutate/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

//Mutated Green
/datum/chemical_reaction/slimemutate_unstable
	name = "Unstable Mutation Toxin"
	id = "unstablemutationtoxin"
	result = "unstablemutationtoxin"
	required_reagents = list("radium" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/green
	mix_message = "<span class='info'>The mixture rapidly expands and contracts, its appearance shifting into a sickening green.</span>"

/datum/chemical_reaction/slimemutate_unstable/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

//Metal
/datum/chemical_reaction/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimemetal/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal
	M.amount = 15
	M.loc = get_turf(holder.my_atom)
	var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel
	P.amount = 5
	P.loc = get_turf(holder.my_atom)

//Gold
/datum/chemical_reaction/slimecrit
	name = "Slime Crit"
	id = "m_tele"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slimecrit/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("<span class='danger'>The slime extract begins to vibrate violently !</span>"), 1)
	spawn(50)

		chemical_mob_spawn(holder, 5, "Gold Slime")

/datum/chemical_reaction/slimecritlesser
	name = "Slime Crit Lesser"
	id = "m_tele3"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slimecritlesser/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("<span class='danger'>The slime extract begins to vibrate violently !</span>"), 1)
	spawn(50)

		chemical_mob_spawn(holder, 1, "Lesser Gold Slime", "neutral")

//Silver
/datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimebork/on_reaction(datum/reagents/holder)

	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/list/blocked = list(/obj/item/weapon/reagent_containers/food/snacks,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake,
		/obj/item/weapon/reagent_containers/food/snacks/cakeslice,
		/obj/item/weapon/reagent_containers/food/snacks/store,
		/obj/item/weapon/reagent_containers/food/snacks/pie,
		/obj/item/weapon/reagent_containers/food/snacks/kebab,
		/obj/item/weapon/reagent_containers/food/snacks/pizza,
		/obj/item/weapon/reagent_containers/food/snacks/pizzaslice,
		/obj/item/weapon/reagent_containers/food/snacks/salad,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/soup,
		/obj/item/weapon/reagent_containers/food/snacks/grown,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		)
	blocked |= typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - blocked
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))


/datum/chemical_reaction/slimebork2
	name = "Slime Bork 2"
	id = "m_tele4"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimebork2/on_reaction(datum/reagents/holder)

	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/list/blocked = list(/obj/item/weapon/reagent_containers/food/drinks)

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/drinks) - blocked
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))


//Blue
/datum/chemical_reaction/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = "frostoil"
	required_reagents = list("plasma" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slimefrost/on_reaction(datum/reagents/holder)
		feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")


/datum/chemical_reaction/slimestabilizer
	name = "Slime Stabilizer"
	id = "m_slimestabilizer"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slimestabilizer/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimestabilizer/P = new /obj/item/weapon/slimestabilizer
	P.loc = get_turf(holder.my_atom)



//Dark Blue
/datum/chemical_reaction/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slimefreeze/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("<span class='danger'>The slime extract begins to vibrate violently !</span>"), 1)
	spawn(50)
		if(holder && holder.my_atom)
			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)
			for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
				M.bodytemperature -= 240
				M << "<span class='notice'>You feel a chill!</span>"

//Orange
/datum/chemical_reaction/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	result = "capsaicin"
	required_reagents = list("blood" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slimecasp/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

/datum/chemical_reaction/slimefire
	name = "Slime fire"
	id = "m_fire"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slimefire/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("<span class='danger'>The slime extract begins to vibrate violently !</span>"), 1)
	spawn(50)
		if(holder && holder.my_atom)
			var/turf/simulated/T = get_turf(holder.my_atom)
			if(istype(T))
				T.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 50)

//Yellow

/datum/chemical_reaction/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimeoverload/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	empulse(get_turf(holder.my_atom), 3, 7)


/datum/chemical_reaction/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimecell/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/stock_parts/cell/high/slime/P = new /obj/item/weapon/stock_parts/cell/high/slime
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimeglow/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("<span class='danger'>The slime begins to emit a soft light. Squeezing it will cause it to grow brightly.</span>"), 1)
	var/obj/item/device/flashlight/slime/F = new /obj/item/device/flashlight/slime
	F.loc = get_turf(holder.my_atom)

//Purple

/datum/chemical_reaction/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slimepsteroid/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	result = "slimejelly"
	required_reagents = list("sugar" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slimejam/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")


//Dark Purple
/datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1

/datum/chemical_reaction/slimeplasma/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/stack/sheet/mineral/plasma/P = new /obj/item/stack/sheet/mineral/plasma
	P.amount = 10
	P.loc = get_turf(holder.my_atom)

//Red
/*/datum/chemical_reaction/slimeglycerol
	name = "Slime Glycerol"
	id = "m_glycerol"
	result = "glycerol"
	required_reagents = list("plasma" = 1)
	result_amount = 8
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimeglycerol/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
*/

/datum/chemical_reaction/slimemutator
	name = "Slime Mutator"
	id = "m_slimemutator"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimemutator/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimemutator/P = new /obj/item/weapon/slimemutator
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimebloodlust/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid = 1
		for(var/mob/O in viewers(get_turf(holder.my_atom), null))
			O.show_message(text("<span class='danger'>The [slime] is driven into a frenzy!</span>"), 1)

//Pink
/datum/chemical_reaction/slimeppotion
	name = "Slime Potion"
	id = "m_potion"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pink
	required_other = 1

/datum/chemical_reaction/slimeppotion/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/slimepotion/P = new /obj/item/slimepotion
	P.loc = get_turf(holder.my_atom)


//Black
/datum/chemical_reaction/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	result = "amutationtoxin"
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/black

/datum/chemical_reaction/slimemutate2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

//Oil
/datum/chemical_reaction/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = 1

/datum/chemical_reaction/slimeexplosion/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("<span class='danger'>The slime extract begins to vibrate violently !</span>"), 1)
	spawn(50)
		if(holder && holder.my_atom)
			explosion(get_turf(holder.my_atom), 1 ,3, 6)

//Light Pink
/datum/chemical_reaction/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list("plasma" = 1)
	required_other = 1

/datum/chemical_reaction/slimepotion2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/slimepotion2/P = new /obj/item/slimepotion2
	P.loc = get_turf(holder.my_atom)

//Adamantine
/datum/chemical_reaction/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1

/datum/chemical_reaction/slimegolem/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/effect/golemrune/Z = new /obj/effect/golemrune
	Z.loc = get_turf(holder.my_atom)
	notify_ghosts("Golem rune created in [get_area(Z)].", 'sound/effects/ghost2.ogg')

//Bluespace
/datum/chemical_reaction/slimefloor2
	name = "Bluespace Floor"
	id = "m_floor2"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slimefloor2/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/stack/tile/bluespace/P = new /obj/item/stack/tile/bluespace
	P.amount = 25
	P.loc = get_turf(holder.my_atom)


/datum/chemical_reaction/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slimecrystal/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if(holder.my_atom)
		var/obj/item/bluespace_crystal/BC = new(get_turf(holder.my_atom))
		BC.visible_message("<span class='notice'>The [BC.name] appears out of thin air!</span>")

//Cerulean
/datum/chemical_reaction/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slimepsteroid2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimesteroid2/P = new /obj/item/weapon/slimesteroid2
	P.loc = get_turf(holder.my_atom)

//Sepia
/datum/chemical_reaction/slimestop
	name = "Slime Stop"
	id = "m_stop"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimestop/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/mob/mob = get_mob_by_key(holder.my_atom.fingerprintslast)
	var/obj/effect/timestop/T = new /obj/effect/timestop
	T.loc = get_turf(holder.my_atom)
	T.immune = mob
	T.timestop()


/datum/chemical_reaction/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimecamera/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/device/camera/P = new /obj/item/device/camera
	P.loc = get_turf(holder.my_atom)
	var/obj/item/device/camera_film/Z = new /obj/item/device/camera_film
	Z.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimefloor
	name = "Sepia Floor"
	id = "m_floor"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimefloor/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/stack/tile/sepia/P = new /obj/item/stack/tile/sepia
	P.amount = 25
	P.loc = get_turf(holder.my_atom)


//Pyrite


/datum/chemical_reaction/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1

/datum/chemical_reaction/slimepaint/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/list/paints = typesof(/obj/item/weapon/paint) - /obj/item/weapon/paint
	var/chosen = pick(paints)
	var/obj/P = new chosen
	if(P)
		P.loc = get_turf(holder.my_atom)

//Rainbow :o)
/datum/chemical_reaction/slimeRNG
	name = "Random Core"
	id = "slimerng"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slimeRNG/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/mob/living/simple_animal/slime/S = new /mob/living/simple_animal/slime
	S.colour = pick("grey","orange", "metal", "blue", "purple", "dark purple", "dark blue", "green", "silver", "yellow", "gold", "yellow", "red", "silver", "pink", "cerulean", "sepia", "bluespace", "pyrite", "light pink", "oil", "adamantine", "black")
	S.loc = get_turf(holder.my_atom)
	S.visible_message("<span class='danger'>Infused with plasma, the core begins to quiver and grow, and soon a new baby slime emerges from it!</span>")
