
//Grey
/datum/chemical_reaction/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slimespawn/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/mob/living/simple_animal/slime/S
	S = new(get_turf(holder.my_atom), "grey")
	S.visible_message("<span class='danger'>Infused with plasma, the \
		core begins to quiver and grow, and soon a new baby slime \
		emerges from it!</span>")

/datum/chemical_reaction/slimeinaprov
	name = "Slime epinephrine"
	id = "m_inaprov"
	results = list("epinephrine" = 3)
	required_reagents = list("water" = 5)
	required_other = 1
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slimeinaprov/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")

/datum/chemical_reaction/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slimemonkey/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	for(var/i = 1, i <= 3, i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.loc = get_turf(holder.my_atom)

//Green
/datum/chemical_reaction/slimemutate
	name = "Mutation Toxin"
	id = "mutationtoxin"
	results = list("mutationtoxin" = 1)
	required_reagents = list("plasma" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slimemutate/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")

//Mutated Green
/datum/chemical_reaction/slimemutate_unstable
	name = "Unstable Mutation Toxin"
	id = "unstablemutationtoxin"
	results = list("unstablemutationtoxin" = 1)
	required_reagents = list("radium" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/green
	mix_message = "<span class='info'>The mixture rapidly expands and contracts, its appearance shifting into a sickening green.</span>"

/datum/chemical_reaction/slimemutate_unstable/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")

//Metal
/datum/chemical_reaction/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimemetal/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/plasteel (location, 5)
	new /obj/item/stack/sheet/metal (location, 15)

/datum/chemical_reaction/slimeglass
	name = "Slime Glass"
	id = "m_glass"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimeglass/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/rglass (location, 5)
	new /obj/item/stack/sheet/glass (location, 15)

//Gold
/datum/chemical_reaction/slimecrit
	name = "Slime Crit"
	id = "m_tele"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slimecrit/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate violently !</span>")
	addtimer(src, "chemical_mob_spawn", 50, FALSE, holder, 5, "Gold Slime")

/datum/chemical_reaction/slimecritlesser
	name = "Slime Crit Lesser"
	id = "m_tele3"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slimecritlesser/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate violently !</span>")
	addtimer(src, "chemical_mob_spawn", 50, FALSE, holder, 3, "Lesser Gold Slime", "neutral")

/datum/chemical_reaction/slimecritfriendly
	name = "Slime Crit Friendly"
	id = "m_tele5"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slimecritfriendly/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate adorably !</span>")
	addtimer(src, "chemical_mob_spawn", 50, FALSE, holder, 1, "Friendly Gold Slime", "neutral")

//Silver
/datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimebork/on_reaction(datum/reagents/holder)

	feedback_add_details("slime_cores_used","[type]")
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
		/obj/item/weapon/reagent_containers/food/snacks/meat/slab,
		/obj/item/weapon/reagent_containers/food/snacks/soup,
		/obj/item/weapon/reagent_containers/food/snacks/grown,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom,
		)
	blocked |= typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable)

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - blocked
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
		C.flash_eyes()

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
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimebork2/on_reaction(datum/reagents/holder)

	feedback_add_details("slime_cores_used","[type]")
	var/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food/drinks)
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/M in viewers(get_turf(holder.my_atom), null))
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
	results = list("frostoil" = 10)
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slimefrost/on_reaction(datum/reagents/holder)
		feedback_add_details("slime_cores_used","[type]")


/datum/chemical_reaction/slimestabilizer
	name = "Slime Stabilizer"
	id = "m_slimestabilizer"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slimestabilizer/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/stabilizer/P = new /obj/item/slimepotion/stabilizer
	P.loc = get_turf(holder.my_atom)



//Dark Blue
/datum/chemical_reaction/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slimefreeze/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate adorably!</span>")
	addtimer(src, "freeze", 50, FALSE, holder)
/datum/chemical_reaction/slimefreeze/proc/freeze(datum/reagents/holder)
	if(holder && holder.my_atom)
		var/turf/T = get_turf(holder.my_atom)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/M in range(T, 7))
			M.bodytemperature -= 240
			M << "<span class='notice'>You feel a chill!</span>"


/datum/chemical_reaction/slimefireproof
	name = "Slime Fireproof"
	id = "m_fireproof"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slimefireproof/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/fireproof/P = new /obj/item/slimepotion/fireproof
	P.loc = get_turf(holder.my_atom)

//Orange
/datum/chemical_reaction/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	results = list("capsaicin" = 10)
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slimecasp/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")

/datum/chemical_reaction/slimefire
	name = "Slime fire"
	id = "m_fire"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slimefire/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/TU = get_turf(holder.my_atom)
	TU.visible_message("<span class='danger'>The slime extract begins to vibrate adorably!</span>")
	addtimer(src, "burn", 50, FALSE, holder)


/datum/chemical_reaction/slimefire/proc/burn(datum/reagents/holder)
	if(holder && holder.my_atom)
		var/turf/open/T = get_turf(holder.my_atom)
		if(istype(T))
			T.atmos_spawn_air("plasma=50;TEMP=1000")

//Yellow

/datum/chemical_reaction/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimeoverload/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[type]")
	empulse(get_turf(holder.my_atom), 3, 7)


/datum/chemical_reaction/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimecell/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/weapon/stock_parts/cell/high/slime/P = new /obj/item/weapon/stock_parts/cell/high/slime
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimeglow/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime begins to emit a soft light. Squeezing it will cause it to grow brightly.</span>")
	var/obj/item/device/flashlight/slime/F = new /obj/item/device/flashlight/slime
	F.loc = get_turf(holder.my_atom)

//Purple

/datum/chemical_reaction/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slimepsteroid/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/steroid/P = new /obj/item/slimepotion/steroid
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	results = list("slimejelly" = 10)
	required_reagents = list("sugar" = 1)
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slimejam/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")


//Dark Purple
/datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1

/datum/chemical_reaction/slimeplasma/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/plasma (location, 3)

//Red

/datum/chemical_reaction/slimemutator
	name = "Slime Mutator"
	id = "m_slimemutator"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimemutator/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/mutator/P = new /obj/item/slimepotion/mutator
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimebloodlust/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid = 1
		slime.visible_message("<span class='danger'>The [slime] is driven into a frenzy!</span>")


/datum/chemical_reaction/slimespeed
	name = "Slime Speed"
	id = "m_speed"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimespeed/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/speed/P = new /obj/item/slimepotion/speed
	P.loc = get_turf(holder.my_atom)


//Pink
/datum/chemical_reaction/docility
	name = "Docility Potion"
	id = "m_potion"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/pink
	required_other = 1

/datum/chemical_reaction/docility/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/docility/P = new /obj/item/slimepotion/docility
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/gender
	name = "Gender Potion"
	id = "m_gender"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/pink
	required_other = 1

/datum/chemical_reaction/gender/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/genderchange/G = new /obj/item/slimepotion/genderchange
	G.loc = get_turf(holder.my_atom)

//Black
/datum/chemical_reaction/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	results = list("amutationtoxin" = 1)
	required_reagents = list("plasma" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/black

/datum/chemical_reaction/slimemutate2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")

//Oil
/datum/chemical_reaction/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/oil
	required_other = 1

/datum/chemical_reaction/slimeexplosion/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[key_name_admin(lastkey)]<A HREF='?_src_=holder;adminmoreinfo=\ref[toucher]'>?</A>(<A HREF='?_src_=holder;adminplayerobservefollow=\ref[toucher]'>FLW</A>)."
	message_admins("Slime Explosion reaction started at <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[T.loc.name] (JMP)</a>. Last Fingerprint: [touch_msg]")
	log_game("Slime Explosion reaction started at [T.loc.name] ([T.x],[T.y],[T.z]). Last Fingerprint: [lastkey ? lastkey : "N/A"].")
	T.visible_message("<span class='danger'>The slime extract begins to vibrate violently !</span>")
	addtimer(src, "boom", 50, FALSE, holder)

/datum/chemical_reaction/slimeexplosion/proc/boom(datum/reagents/holder)
	if(holder && holder.my_atom)
		explosion(get_turf(holder.my_atom), 1 ,3, 6)

//Light Pink
/datum/chemical_reaction/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list("plasma" = 1)
	required_other = 1

/datum/chemical_reaction/slimepotion2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/sentience/P = new /obj/item/slimepotion/sentience
	P.loc = get_turf(holder.my_atom)

//Adamantine
/datum/chemical_reaction/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1

/datum/chemical_reaction/slimegolem/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/effect/golemrune/Z = new /obj/effect/golemrune
	Z.loc = get_turf(holder.my_atom)
	notify_ghosts("Golem rune created in [get_area(Z)].", 'sound/effects/ghost2.ogg', source = Z)

//Bluespace
/datum/chemical_reaction/slimefloor2
	name = "Bluespace Floor"
	id = "m_floor2"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slimefloor2/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/stack/tile/bluespace/P = new /obj/item/stack/tile/bluespace
	P.amount = 25
	P.loc = get_turf(holder.my_atom)


/datum/chemical_reaction/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slimecrystal/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[type]")
	if(holder.my_atom)
		var/obj/item/weapon/ore/bluespace_crystal/BC = new(get_turf(holder.my_atom))
		BC.visible_message("<span class='notice'>The [BC.name] appears out of thin air!</span>")

//Cerulean
/datum/chemical_reaction/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slimepsteroid2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/enhancer/P = new /obj/item/slimepotion/enhancer
	P.loc = get_turf(holder.my_atom)



/datum/chemical_reaction/slime_territory
	name = "Slime Territory"
	id = "s_territory"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slime_territory/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/areaeditor/blueprints/slime/P = new /obj/item/areaeditor/blueprints/slime
	P.loc = get_turf(holder.my_atom)

//Sepia
/datum/chemical_reaction/slimestop
	name = "Slime Stop"
	id = "m_stop"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimestop/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/mob/mob = get_mob_by_key(holder.my_atom.fingerprintslast)
	var/obj/effect/timestop/T = new /obj/effect/timestop
	T.loc = get_turf(holder.my_atom)
	T.immune += mob
	T.timestop()


/datum/chemical_reaction/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimecamera/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/device/camera/P = new /obj/item/device/camera
	P.loc = get_turf(holder.my_atom)
	var/obj/item/device/camera_film/Z = new /obj/item/device/camera_film
	Z.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimefloor
	name = "Sepia Floor"
	id = "m_floor"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimefloor/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/stack/tile/sepia/P = new /obj/item/stack/tile/sepia
	P.amount = 25
	P.loc = get_turf(holder.my_atom)


//Pyrite


/datum/chemical_reaction/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1

/datum/chemical_reaction/slimepaint/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/list/paints = subtypesof(/obj/item/weapon/paint)
	var/chosen = pick(paints)
	var/obj/P = new chosen
	if(P)
		P.loc = get_turf(holder.my_atom)

//Rainbow :o)
/datum/chemical_reaction/slimeRNG
	name = "Random Core"
	id = "slimerng"
	required_reagents = list("plasma" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slimeRNG/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/mob/living/simple_animal/slime/random/S
	S = new(get_turf(holder.my_atom))
	S.visible_message("<span class='danger'>Infused with plasma, the \
		core begins to quiver and grow, and soon a new baby slime emerges \
		from it!</span>")

/datum/chemical_reaction/slime_transfer
	name = "Transfer Potion"
	id = "slimetransfer"
	required_reagents = list("blood" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime_transfer/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/transference/P = new /obj/item/slimepotion/transference
	P.loc = get_turf(holder.my_atom)

