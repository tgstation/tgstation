
/datum/chemical_reaction/slime

/datum/chemical_reaction/slime/on_reaction(datum/reagents/holder)
	delete_extract(holder)

/datum/chemical_reaction/slime/proc/delete_extract(datum/reagents/holder)
	var/obj/item/slime_extract/M = holder.my_atom
	if(M.Uses <= 0)
		if (!results.len) //if the slime doesn't output chemicals
			qdel(M)

//Grey
/datum/chemical_reaction/slime/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slime/slimespawn/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/mob/living/simple_animal/slime/S
	S = new(get_turf(holder.my_atom), "grey")
	S.visible_message("<span class='danger'>Infused with plasma, the \
		core begins to quiver and grow, and soon a new baby slime \
		emerges from it!</span>")
	..()

/datum/chemical_reaction/slime/slimeinaprov
	name = "Slime epinephrine"
	id = "m_inaprov"
	results = list("epinephrine" = 3)
	required_reagents = list("water" = 5)
	required_other = 1
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/slimeinaprov/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()

/datum/chemical_reaction/slime/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slime/slimemonkey/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	for(var/i = 1, i <= 3, i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.loc = get_turf(holder.my_atom)
	..()

//Green
/datum/chemical_reaction/slime/slimemutate
	name = "Mutation Toxin"
	id = "mutationtoxin"
	results = list("mutationtoxin" = 1)
	required_reagents = list("plasma" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime/slimemutate/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()

//Mutated Green
/datum/chemical_reaction/slime/slimemutate_unstable
	name = "Unstable Mutation Toxin"
	id = "unstablemutationtoxin"
	results = list("unstablemutationtoxin" = 1)
	required_reagents = list("radium" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/green
	mix_message = "<span class='info'>The mixture rapidly expands and contracts, its appearance shifting into a sickening green.</span>"

/datum/chemical_reaction/slime/slimemutate_unstable/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()

//Metal
/datum/chemical_reaction/slime/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slime/slimemetal/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/plasteel (location, 5)
	new /obj/item/stack/sheet/metal (location, 15)
	..()

/datum/chemical_reaction/slime/slimeglass
	name = "Slime Glass"
	id = "m_glass"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slime/slimeglass/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/rglass (location, 5)
	new /obj/item/stack/sheet/glass (location, 15)
	..()

//Gold
/datum/chemical_reaction/slime/slimecrit
	name = "Slime Crit"
	id = "m_tele"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slime/slimecrit/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate violently !</span>")
	addtimer(CALLBACK(src, .proc/chemical_mob_spawn, holder, 5, "Gold Slime"), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	M.qdel_timer = addtimer(CALLBACK(src, .proc/delete_extract, holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimecritlesser
	name = "Slime Crit Lesser"
	id = "m_tele3"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slime/slimecritlesser/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate violently !</span>")
	addtimer(CALLBACK(src, .proc/chemical_mob_spawn, holder, 3, "Lesser Gold Slime", "neutral"), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	M.qdel_timer = addtimer(CALLBACK(src, .proc/delete_extract, holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimecritfriendly
	name = "Slime Crit Friendly"
	id = "m_tele5"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slime/slimecritfriendly/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate adorably !</span>")
	addtimer(CALLBACK(src, .proc/chemical_mob_spawn, holder, 1, "Friendly Gold Slime", "neutral"), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	M.qdel_timer = addtimer(CALLBACK(src, .proc/delete_extract, holder), 55, TIMER_STOPPABLE)

//Silver
/datum/chemical_reaction/slime/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slime/slimebork/on_reaction(datum/reagents/holder)

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
		C.flash_act()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))
	..()


/datum/chemical_reaction/slime/slimebork2
	name = "Slime Bork 2"
	id = "m_tele4"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slime/slimebork2/on_reaction(datum/reagents/holder)

	feedback_add_details("slime_cores_used","[type]")
	var/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food/drinks)
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/M in viewers(get_turf(holder.my_atom), null))
		M.flash_act()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))
	..()


//Blue
/datum/chemical_reaction/slime/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	results = list("frostoil" = 10)
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slime/slimefrost/on_reaction(datum/reagents/holder)
		feedback_add_details("slime_cores_used","[type]")
		..()


/datum/chemical_reaction/slime/slimestabilizer
	name = "Slime Stabilizer"
	id = "m_slimestabilizer"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slime/slimestabilizer/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/stabilizer/P = new /obj/item/slimepotion/stabilizer
	P.loc = get_turf(holder.my_atom)
	..()


/datum/chemical_reaction/slime/slimefoam
	name = "Slime Foam"
	id = "m_foam"
	results = list("fluorosurfactant" = 20, "water" = 20)
	required_reagents = list("water" = 5)
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slime/slimefoam/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()


//Dark Blue
/datum/chemical_reaction/slime/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slime/slimefreeze/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate adorably!</span>")
	addtimer(CALLBACK(src, .proc/freeze, holder), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	M.qdel_timer = addtimer(CALLBACK(src, .proc/delete_extract, holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimefreeze/proc/freeze(datum/reagents/holder)
	if(holder && holder.my_atom)
		var/turf/open/T = get_turf(holder.my_atom)
		if(istype(T))
			T.atmos_spawn_air("freon=50;TEMP=120")



/datum/chemical_reaction/slime/slimefireproof
	name = "Slime Fireproof"
	id = "m_fireproof"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slime/slimefireproof/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/fireproof/P = new /obj/item/slimepotion/fireproof
	P.loc = get_turf(holder.my_atom)
	..()

//Orange
/datum/chemical_reaction/slime/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	results = list("capsaicin" = 10)
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slime/slimecasp/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()

/datum/chemical_reaction/slime/slimefire
	name = "Slime fire"
	id = "m_fire"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slime/slimefire/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/TU = get_turf(holder.my_atom)
	TU.visible_message("<span class='danger'>The slime extract begins to vibrate adorably!</span>")
	addtimer(CALLBACK(src, .proc/slime_burn, holder), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	M.qdel_timer = addtimer(CALLBACK(src, .proc/delete_extract, holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimefire/proc/slime_burn(datum/reagents/holder)
	if(holder && holder.my_atom)
		var/turf/open/T = get_turf(holder.my_atom)
		if(istype(T))
			T.atmos_spawn_air("plasma=50;TEMP=1000")


/datum/chemical_reaction/slime/slimesmoke
	name = "Slime Smoke"
	id = "m_smoke"
	results = list("phosphorus" = 10, "potassium" = 10, "sugar" = 10)
	required_reagents = list("water" = 5)
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slime/slimesmoke/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()

//Yellow

/datum/chemical_reaction/slime/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slime/slimeoverload/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[type]")
	empulse(get_turf(holder.my_atom), 3, 7)
	..()


/datum/chemical_reaction/slime/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slime/slimecell/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/weapon/stock_parts/cell/high/slime/P = new /obj/item/weapon/stock_parts/cell/high/slime
	P.loc = get_turf(holder.my_atom)
	..()

/datum/chemical_reaction/slime/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slime/slimeglow/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime begins to emit a soft light. Squeezing it will cause it to grow brightly.</span>")
	var/obj/item/device/flashlight/slime/F = new /obj/item/device/flashlight/slime
	F.loc = get_turf(holder.my_atom)
	..()

//Purple

/datum/chemical_reaction/slime/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slime/slimepsteroid/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/steroid/P = new /obj/item/slimepotion/steroid
	P.loc = get_turf(holder.my_atom)
	..()

/datum/chemical_reaction/slime/slimejam
	name = "Slime Jam"
	id = "m_jam"
	results = list("slimejelly" = 10)
	required_reagents = list("sugar" = 1)
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slime/slimejam/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()


//Dark Purple
/datum/chemical_reaction/slime/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1

/datum/chemical_reaction/slime/slimeplasma/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/plasma (location, 3)
	..()

//Red

/datum/chemical_reaction/slime/slimemutator
	name = "Slime Mutator"
	id = "m_slimemutator"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slime/slimemutator/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/mutator/P = new /obj/item/slimepotion/mutator
	P.loc = get_turf(holder.my_atom)
	..()

/datum/chemical_reaction/slime/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slime/slimebloodlust/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid = 1
		slime.visible_message("<span class='danger'>The [slime] is driven into a frenzy!</span>")
	..()


/datum/chemical_reaction/slime/slimespeed
	name = "Slime Speed"
	id = "m_speed"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slime/slimespeed/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/speed/P = new /obj/item/slimepotion/speed
	P.loc = get_turf(holder.my_atom)
	..()


//Pink
/datum/chemical_reaction/slime/docility
	name = "Docility Potion"
	id = "m_potion"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/pink
	required_other = 1

/datum/chemical_reaction/slime/docility/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/docility/P = new /obj/item/slimepotion/docility
	P.loc = get_turf(holder.my_atom)
	..()

/datum/chemical_reaction/slime/gender
	name = "Gender Potion"
	id = "m_gender"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/pink
	required_other = 1

/datum/chemical_reaction/slime/gender/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/genderchange/G = new /obj/item/slimepotion/genderchange
	G.loc = get_turf(holder.my_atom)
	..()

//Black
/datum/chemical_reaction/slime/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	results = list("amutationtoxin" = 1)
	required_reagents = list("plasma" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/black

/datum/chemical_reaction/slime/slimemutate2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()

//Oil
/datum/chemical_reaction/slime/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/oil
	required_other = 1

/datum/chemical_reaction/slime/slimeexplosion/on_reaction(datum/reagents/holder)
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
	addtimer(CALLBACK(src, .proc/boom, holder), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	M.qdel_timer = addtimer(CALLBACK(src, .proc/delete_extract, holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimeexplosion/proc/boom(datum/reagents/holder)
	if(holder && holder.my_atom)
		explosion(get_turf(holder.my_atom), 1 ,3, 6)


/datum/chemical_reaction/slime/slimecornoil
	name = "Slime Corn Oil"
	id = "m_cornoil"
	results = list("cornoil" = 10)
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/oil
	required_other = 1

/datum/chemical_reaction/slime/slimecornoil/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	..()

//Light Pink
/datum/chemical_reaction/slime/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list("plasma" = 1)
	required_other = 1

/datum/chemical_reaction/slime/slimepotion2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/sentience/P = new /obj/item/slimepotion/sentience
	P.loc = get_turf(holder.my_atom)
	..()

//Adamantine
/datum/chemical_reaction/slime/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1

/datum/chemical_reaction/slime/slimegolem/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/effect/golemrune/Z = new /obj/effect/golemrune
	Z.loc = get_turf(holder.my_atom)
	notify_ghosts("Golem rune created in [get_area(Z)].", 'sound/effects/ghost2.ogg', source = Z)
	..()

/datum/chemical_reaction/slime/slimegolem2
	name = "Slime Golem 2"
	id = "m_golem2"
	required_reagents = list("iron" = 1)
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1

/datum/chemical_reaction/slime/slimegolem2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/golem_shell/artificial/Z = new /obj/item/golem_shell/artificial
	Z.loc = get_turf(holder.my_atom)
	..()

//Bluespace
/datum/chemical_reaction/slime/slimefloor2
	name = "Bluespace Floor"
	id = "m_floor2"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slime/slimefloor2/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/stack/tile/bluespace/P = new /obj/item/stack/tile/bluespace
	P.amount = 25
	P.loc = get_turf(holder.my_atom)
	..()


/datum/chemical_reaction/slime/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slime/slimecrystal/on_reaction(datum/reagents/holder, created_volume)
	feedback_add_details("slime_cores_used","[type]")
	if(holder.my_atom)
		var/obj/item/weapon/ore/bluespace_crystal/BC = new(get_turf(holder.my_atom))
		BC.visible_message("<span class='notice'>The [BC.name] appears out of thin air!</span>")
	..()

//Cerulean
/datum/chemical_reaction/slime/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slime/slimepsteroid2/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/enhancer/P = new /obj/item/slimepotion/enhancer
	P.loc = get_turf(holder.my_atom)
	..()


/datum/chemical_reaction/slime/slime_territory
	name = "Slime Territory"
	id = "s_territory"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slime/slime_territory/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/areaeditor/blueprints/slime/P = new /obj/item/areaeditor/blueprints/slime
	P.loc = get_turf(holder.my_atom)
	..()

//Sepia
/datum/chemical_reaction/slime/slimestop
	name = "Slime Stop"
	id = "m_stop"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slime/slimestop/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/mob/mob = get_mob_by_key(holder.my_atom.fingerprintslast)
	var/obj/effect/timestop/T = new /obj/effect/timestop
	T.loc = get_turf(holder.my_atom)
	T.immune += mob
	T.timestop()
	..()


/datum/chemical_reaction/slime/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	required_reagents = list("water" = 1)
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slime/slimecamera/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/device/camera/P = new /obj/item/device/camera
	P.loc = get_turf(holder.my_atom)
	var/obj/item/device/camera_film/Z = new /obj/item/device/camera_film
	Z.loc = get_turf(holder.my_atom)
	..()

/datum/chemical_reaction/slime/slimefloor
	name = "Sepia Floor"
	id = "m_floor"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slime/slimefloor/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/stack/tile/sepia/P = new /obj/item/stack/tile/sepia
	P.amount = 25
	P.loc = get_turf(holder.my_atom)
	..()


//Pyrite


/datum/chemical_reaction/slime/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	required_reagents = list("plasma" = 1)
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1

/datum/chemical_reaction/slime/slimepaint/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/list/paints = subtypesof(/obj/item/weapon/paint)
	var/chosen = pick(paints)
	var/obj/P = new chosen
	if(P)
		P.loc = get_turf(holder.my_atom)
	..()


/datum/chemical_reaction/slime/slimecrayon
	name = "Slime Crayon"
	id = "s_crayon"
	required_reagents = list("blood" = 1)
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1

/datum/chemical_reaction/slime/slimecrayon/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/list/crayons = difflist(subtypesof(/obj/item/toy/crayon),typesof(/obj/item/toy/crayon/spraycan))
	var/chosen = pick(crayons)
	var/obj/P = new chosen
	if(P)
		P.loc = get_turf(holder.my_atom)
	..()

//Rainbow :o)
/datum/chemical_reaction/slime/slimeRNG
	name = "Random Core"
	id = "slimerng"
	required_reagents = list("plasma" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slimeRNG/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/mob/living/simple_animal/slime/random/S
	S = new(get_turf(holder.my_atom))
	S.visible_message("<span class='danger'>Infused with plasma, the \
		core begins to quiver and grow, and soon a new baby slime emerges \
		from it!</span>")
	..()

/datum/chemical_reaction/slime/slime_transfer
	name = "Transfer Potion"
	id = "slimetransfer"
	required_reagents = list("blood" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slime_transfer/on_reaction(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")
	var/obj/item/slimepotion/transference/P = new /obj/item/slimepotion/transference
	P.loc = get_turf(holder.my_atom)
	..()

