
/// Slime Extracts ///

/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	force = 1
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=3"
	container_type = INJECTABLE
	var/Uses = 1 // uses before it goes inert
	var/qdel_timer = null // deletion timer, for delayed reactions

/obj/item/slime_extract/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/slimepotion/enhancer))
		if(Uses >= 5)
			to_chat(user, "<span class='warning'>You cannot enhance this extract further!</span>")
			return ..()
		to_chat(user, "<span class='notice'>You apply the enhancer to the slime extract. It may now be reused one more time.</span>")
		Uses++
		qdel(O)
	..()

/obj/item/slime_extract/Initialize()
	. = ..()
	create_reagents(100)

/obj/item/slime_extract/grey
	name = "grey slime extract"
	icon_state = "grey slime extract"

/obj/item/slime_extract/gold
	name = "gold slime extract"
	icon_state = "gold slime extract"

/obj/item/slime_extract/silver
	name = "silver slime extract"
	icon_state = "silver slime extract"

/obj/item/slime_extract/metal
	name = "metal slime extract"
	icon_state = "metal slime extract"

/obj/item/slime_extract/purple
	name = "purple slime extract"
	icon_state = "purple slime extract"

/obj/item/slime_extract/darkpurple
	name = "dark purple slime extract"
	icon_state = "dark purple slime extract"

/obj/item/slime_extract/orange
	name = "orange slime extract"
	icon_state = "orange slime extract"

/obj/item/slime_extract/yellow
	name = "yellow slime extract"
	icon_state = "yellow slime extract"

/obj/item/slime_extract/red
	name = "red slime extract"
	icon_state = "red slime extract"

/obj/item/slime_extract/blue
	name = "blue slime extract"
	icon_state = "blue slime extract"

/obj/item/slime_extract/darkblue
	name = "dark blue slime extract"
	icon_state = "dark blue slime extract"

/obj/item/slime_extract/pink
	name = "pink slime extract"
	icon_state = "pink slime extract"

/obj/item/slime_extract/green
	name = "green slime extract"
	icon_state = "green slime extract"

/obj/item/slime_extract/lightpink
	name = "light pink slime extract"
	icon_state = "light pink slime extract"

/obj/item/slime_extract/black
	name = "black slime extract"
	icon_state = "black slime extract"

/obj/item/slime_extract/oil
	name = "oil slime extract"
	icon_state = "oil slime extract"

/obj/item/slime_extract/adamantine
	name = "adamantine slime extract"
	icon_state = "adamantine slime extract"

/obj/item/slime_extract/bluespace
	name = "bluespace slime extract"
	icon_state = "bluespace slime extract"

/obj/item/slime_extract/pyrite
	name = "pyrite slime extract"
	icon_state = "pyrite slime extract"

/obj/item/slime_extract/cerulean
	name = "cerulean slime extract"
	icon_state = "cerulean slime extract"

/obj/item/slime_extract/sepia
	name = "sepia slime extract"
	icon_state = "sepia slime extract"

/obj/item/slime_extract/rainbow
	name = "rainbow slime extract"
	icon_state = "rainbow slime extract"

////Slime-derived potions///

/obj/item/slimepotion
	name = "slime potion"
	desc = "A hard yet gelatinous capsule excreted by a slime, containing mysterious substances."
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=4"

/obj/item/slimepotion/afterattack(obj/item/weapon/reagent_containers/target, mob/user , proximity)
	if (istype(target))
		to_chat(user, "<span class='notice'>You cannot transfer [src] to [target]! It appears the potion must be given directly to a slime to absorb.</span>" )
		return

/obj/item/slimepotion/docility
	name = "docility potion"
	desc = "A potent chemical mix that nullifies a slime's hunger, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potsilver"

/obj/item/slimepotion/docility/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The potion only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return ..()

	M.docile = 1
	M.nutrition = 700
	to_chat(M, "<span class='warning'>You absorb the potion and feel your intense desire to feed melt away.</span>")
	to_chat(user, "<span class='notice'>You feed the slime the potion, removing its hunger and calming it.</span>")
	var/newname = copytext(sanitize(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text),1,MAX_NAME_LEN)

	if (!newname)
		newname = "pet slime"
	M.name = newname
	M.real_name = newname
	qdel(src)

/obj/item/slimepotion/sentience
	name = "intelligence potion"
	desc = "A miraculous chemical mix that grants human like intelligence to living beings."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpink"
	origin_tech = "biotech=6"
	var/list/not_interested = list()
	var/being_used = 0
	var/sentience_type = SENTIENCE_ORGANIC

/obj/item/slimepotion/sentience/afterattack(mob/living/M, mob/user)
	if(being_used || !ismob(M))
		return
	if(!isanimal(M) || M.ckey) //only works on animals that aren't player controlled
		to_chat(user, "<span class='warning'>[M] is already too intelligent for this to work!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>[M] is dead!</span>")
		return ..()
	var/mob/living/simple_animal/SM = M
	if(SM.sentience_type != sentience_type)
		to_chat(user, "<span class='warning'>[src] won't work on [SM].</span>")
		return ..()



	to_chat(user, "<span class='notice'>You offer [src] to [SM]...</span>")
	being_used = 1

	var/list/candidates = pollCandidatesForMob("Do you want to play as [SM.name]?", ROLE_ALIEN, null, ROLE_ALIEN, 50, SM, POLL_IGNORE_SENTIENCE_POTION) // see poll_ignore.dm
	var/mob/dead/observer/theghost = null
	if(candidates.len)
		theghost = pick(candidates)
		SM.key = theghost.key
		SM.mind.enslave_mind_to_creator(user)
		SM.sentience_act()
		to_chat(SM, "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>")
		to_chat(SM, "<span class='userdanger'>You are grateful to be self aware and owe [user] a great debt. Serve [user], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
		to_chat(user, "<span class='notice'>[SM] accepts [src] and suddenly becomes attentive and aware. It worked!</span>")
		qdel(src)
	else
		to_chat(user, "<span class='notice'>[SM] looks interested for a moment, but then looks back down. Maybe you should try again later.</span>")
		being_used = 0
		..()

/obj/item/slimepotion/transference
	name = "consciousness transference potion"
	desc = "A strange slime-based chemical that, when used, allows the user to transfer their consciousness to a lesser being."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potorange"
	origin_tech = "biotech=6"
	var/prompted = 0
	var/animal_type = SENTIENCE_ORGANIC

/obj/item/slimepotion/transference/afterattack(mob/living/M, mob/user)
	if(prompted || !ismob(M))
		return
	if(!isanimal(M) || M.ckey) //much like sentience, these will not work on something that is already player controlled
		to_chat(user, "<span class='warning'>[M] already has a higher consciousness!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>[M] is dead!</span>")
		return ..()
	var/mob/living/simple_animal/SM = M
	if(SM.sentience_type != animal_type)
		to_chat(user, "<span class='warning'>You cannot transfer your consciousness to [SM].</span>" )
		return ..()
	if(jobban_isbanned(user, ROLE_ALIEN)) //ideally sentience and trasnference potions should be their own unique role.
		to_chat(user, "<span class='warning'>Your mind goes blank as you attempt to use the potion.</span>")
		return

	prompted = 1
	if(alert("This will permanently transfer your consciousness to [SM]. Are you sure you want to do this?",,"Yes","No")=="No")
		prompted = 0
		return

	to_chat(user, "<span class='notice'>You drink the potion then place your hands on [SM]...</span>")


	user.mind.transfer_to(SM)
	SM.faction = user.faction.Copy()
	SM.sentience_act() //Same deal here as with sentience
	user.death()
	to_chat(SM, "<span class='notice'>In a quick flash, you feel your consciousness flow into [SM]!</span>")
	to_chat(SM, "<span class='warning'>You are now [SM]. Your allegiances, alliances, and role is still the same as it was prior to consciousness transfer!</span>")
	SM.name = "[SM.name] as [user.real_name]"
	qdel(src)

/obj/item/slimepotion/steroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a baby slime to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potred"

/obj/item/slimepotion/steroid/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))//If target is not a slime.
		to_chat(user, "<span class='warning'>The steroid only works on baby slimes!</span>")
		return ..()
	if(M.is_adult) //Can't steroidify adults
		to_chat(user, "<span class='warning'>Only baby slimes can use the steroid!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return ..()
	if(M.cores >= 5)
		to_chat(user, "<span class='warning'>The slime already has the maximum amount of extract!</span>")
		return ..()

	to_chat(user, "<span class='notice'>You feed the slime the steroid. It will now produce one more extract.</span>")
	M.cores++
	qdel(src)

/obj/item/slimepotion/enhancer
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a slime extract an additional use."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/stabilizer
	name = "slime stabilizer"
	desc = "A potent chemical mix that will reduce the chance of a slime mutating."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/slimepotion/stabilizer/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The stabilizer only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return ..()
	if(M.mutation_chance == 0)
		to_chat(user, "<span class='warning'>The slime already has no chance of mutating!</span>")
		return ..()

	to_chat(user, "<span class='notice'>You feed the slime the stabilizer. It is now less likely to mutate.</span>")
	M.mutation_chance = Clamp(M.mutation_chance-15,0,100)
	qdel(src)

/obj/item/slimepotion/mutator
	name = "slime mutator"
	desc = "A potent chemical mix that will increase the chance of a slime mutating."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potgreen"

/obj/item/slimepotion/mutator/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The mutator only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return ..()
	if(M.mutator_used)
		to_chat(user, "<span class='warning'>This slime has already consumed a mutator, any more would be far too unstable!</span>")
		return ..()
	if(M.mutation_chance == 100)
		to_chat(user, "<span class='warning'>The slime is already guaranteed to mutate!</span>")
		return ..()

	to_chat(user, "<span class='notice'>You feed the slime the mutator. It is now more likely to mutate.</span>")
	M.mutation_chance = Clamp(M.mutation_chance+12,0,100)
	M.mutator_used = TRUE
	qdel(src)

/obj/item/slimepotion/speed
	name = "slime speed potion"
	desc = "A potent chemical mix that will remove the slowdown from any item."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potyellow"
	origin_tech = "biotech=5"

/obj/item/slimepotion/speed/afterattack(obj/C, mob/user)
	..()
	if(!istype(C))
		to_chat(user, "<span class='warning'>The potion can only be used on items or vehicles!</span>")
		return
	if(isitem(C))
		var/obj/item/I = C
		if(I.slowdown <= 0)
			to_chat(user, "<span class='warning'>The [C] can't be made any faster!</span>")
			return ..()
		I.slowdown = 0

	if(istype(C, /obj/vehicle))
		var/obj/vehicle/V = C
		var/datum/riding/R = V.riding_datum
		if(V.riding_datum)
			if(R.vehicle_move_delay <= 0 )
				to_chat(user, "<span class='warning'>The [C] can't be made any faster!</span>")
				return ..()
			R.vehicle_move_delay = 0

	to_chat(user, "<span class='notice'>You slather the red gunk over the [C], making it faster.</span>")
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#FF0000", FIXED_COLOUR_PRIORITY)
	qdel(src)


/obj/item/slimepotion/fireproof
	name = "slime chill potion"
	desc = "A potent chemical mix that will fireproof any article of clothing. Has three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potblue"
	origin_tech = "biotech=5"
	var/uses = 3

/obj/item/slimepotion/fireproof/afterattack(obj/item/clothing/C, mob/user)
	..()
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		to_chat(user, "<span class='warning'>The potion can only be used on clothing!</span>")
		return
	if(C.max_heat_protection_temperature == FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
		to_chat(user, "<span class='warning'>The [C] is already fireproof!</span>")
		return ..()
	to_chat(user, "<span class='notice'>You slather the blue gunk over the [C], fireproofing it.</span>")
	C.name = "fireproofed [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	C.resistance_flags |= FIRE_PROOF
	uses --
	if(!uses)
		qdel(src)

/obj/item/slimepotion/genderchange
	name = "gender change potion"
	desc = "An interesting chemical mix that changes the biological gender of what its applied to. Cannot be used on things that lack gender entirely."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potlightpink"

/obj/item/slimepotion/genderchange/attack(mob/living/L, mob/user)
	if(!istype(L) || L.stat == DEAD)
		to_chat(user, "<span class='warning'>The potion can only be used on living things!</span>")
		return

	if(L.gender != MALE && L.gender != FEMALE)
		to_chat(user, "<span class='warning'>The potion can only be used on gendered things!</span>")
		return

	if(L.gender == MALE)
		L.gender = FEMALE
		L.visible_message("<span class='boldnotice'>[L] suddenly looks more feminine!</span>", "<span class='boldwarning'>You suddenly feel more feminine!</span>")
	else
		L.gender = MALE
		L.visible_message("<span class='boldnotice'>[L] suddenly looks more masculine!</span>", "<span class='boldwarning'>You suddenly feel more masculine!</span>")
	L.regenerate_icons()
	qdel(src)

////////Adamantine Golem stuff I dunno where else to put it

// This will eventually be removed.

/obj/item/clothing/under/golem
	name = "adamantine skin"
	desc = "a golem's skin"
	icon_state = "golem"
	item_state = "golem"
	item_color = "golem"
	flags = ABSTRACT | NODROP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	has_sensor = NO_SENSORS

/obj/item/clothing/suit/golem
	name = "adamantine shell"
	desc = "a golem's thick outer shell"
	icon_state = "golem"
	item_state = "golem"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = FULL_BODY
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags = ABSTRACT | NODROP

/obj/item/clothing/shoes/golem
	name = "golem's feet"
	desc = "sturdy adamantine feet"
	icon_state = "golem"
	item_state = null
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags = NOSLIP | ABSTRACT | NODROP


/obj/item/clothing/mask/breath/golem
	name = "golem's face"
	desc = "the imposing face of an adamantine golem"
	icon_state = "golem"
	item_state = "golem"
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags = ABSTRACT | NODROP


/obj/item/clothing/gloves/golem
	name = "golem's hands"
	desc = "strong adamantine hands"
	icon_state = "golem"
	item_state = null
	siemens_coefficient = 0
	flags = ABSTRACT | NODROP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/item/clothing/head/space/golem
	icon_state = "golem"
	item_state = "dermal"
	item_color = "dermal"
	name = "golem's head"
	desc = "a golem's head"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags = ABSTRACT | NODROP

/obj/effect/golemrune
	anchored = TRUE
	desc = "a strange rune used to create golems. It glows when spirits are nearby."
	name = "rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "golem"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = TURF_LAYER

/obj/effect/golemrune/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	notify_ghosts("Golem rune created in [get_area(src)].", 'sound/effects/ghost2.ogg', source = src)

/obj/effect/golemrune/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/golemrune/process()
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in src.loc)
		if(!O.client)
			continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
			continue
		if (O.orbiting)
			continue
		ghost = O
		break
	if(ghost)
		icon_state = "golem2"
	else
		icon_state = "golem"

/obj/effect/golemrune/attack_hand(mob/living/user)
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in src.loc)
		if(!O.client)
			continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
			continue
		if (O.orbiting)
			continue
		ghost = O
		break
	if(!ghost)
		to_chat(user, "<span class='warning'>The rune fizzles uselessly! There is no spirit nearby.</span>")
		return
	var/mob/living/carbon/human/G = new /mob/living/carbon/human
	G.set_species(/datum/species/golem/adamantine)
	G.set_cloned_appearance()
	G.real_name = G.dna.species.random_name()
	G.name = G.real_name
	G.dna.unique_enzymes = G.dna.generate_unique_enzymes()
	G.dna.species.auto_equip(G)
	G.loc = src.loc
	G.key = ghost.key
	to_chat(G, "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools. \
	Serve [user], and assist [user.p_them()] in completing their goals at any cost.")
	G.mind.store_memory("<b>Serve [user.real_name], your creator.</b>")
	G.mind.assigned_role = "Servant Golem"

	G.mind.enslave_mind_to_creator(user)

	log_game("[key_name(G)] was made a golem by [key_name(user)].")
	log_admin("[key_name(G)] was made a golem by [key_name(user)].")
	qdel(src)




/obj/effect/timestop
	anchored = TRUE
	name = "chronofield"
	desc = "ZA WARUDO"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	pixel_x = -64
	pixel_y = -64
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/mob/living/immune = list() // the one who creates the timestop is immune
	var/list/stopped_atoms = list()
	var/freezerange = 2
	var/duration = 140
	alpha = 125

/obj/effect/timestop/Initialize()
	. = ..()
	for(var/M in GLOB.player_list)
		var/mob/living/L = M
		if(locate(/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop) in L.mind.spell_list) //People who can stop time are immune to its effects
			immune += L
	timestop()


/obj/effect/timestop/proc/timestop()
	set waitfor = FALSE
	playsound(src, 'sound/magic/timeparadox2.ogg', 75, 1, -1)
	for(var/i in 1 to duration-1)
		for(var/atom/A in orange (freezerange, src.loc))
			if(isliving(A))
				var/mob/living/M = A
				if(M in immune)
					continue
				M.Stun(200, 1, 1)
				M.anchored = TRUE
				if(ishostile(M))
					var/mob/living/simple_animal/hostile/H = M
					H.AIStatus = AI_OFF
					H.LoseTarget()
				stopped_atoms |= M
			else if(istype(A, /obj/item/projectile))
				var/obj/item/projectile/P = A
				P.paused = TRUE
				stopped_atoms |= P

		for(var/mob/living/M in stopped_atoms)
			if(get_dist(get_turf(M),get_turf(src)) > freezerange) //If they lagged/ran past the timestop somehow, just ignore them
				unfreeze_mob(M)
				stopped_atoms -= M
		stoplag()

	//End
	playsound(src, 'sound/magic/timeparadox2.ogg', 75, TRUE, frequency = -1) //reverse!
	for(var/mob/living/M in stopped_atoms)
		unfreeze_mob(M)

	for(var/obj/item/projectile/P in stopped_atoms)
		P.paused = FALSE
	qdel(src)
	return



/obj/effect/timestop/proc/unfreeze_mob(mob/living/M)
	M.AdjustStun(-200, 1, 1)
	M.anchored = FALSE
	if(ishostile(M))
		var/mob/living/simple_animal/hostile/H = M
		H.AIStatus = initial(H.AIStatus)


/obj/effect/timestop/wizard
	duration = 100


/obj/item/stack/tile/bluespace
	name = "bluespace floor tile"
	singular_name = "floor tile"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds"
	icon_state = "tile-bluespace"
	w_class = WEIGHT_CLASS_NORMAL
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/open/floor/bluespace


/obj/item/stack/tile/sepia
	name = "sepia floor tile"
	singular_name = "floor tile"
	desc = "Time seems to flow very slowly around these tiles"
	icon_state = "tile-sepia"
	w_class = WEIGHT_CLASS_NORMAL
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/open/floor/sepia


/obj/item/areaeditor/blueprints/slime
	name = "cerulean prints"
	desc = "A one use yet of blueprints made of jelly like organic material. Renaming an area to 'Xenobiology Lab' will extend the reach of the management console."
	color = "#2956B2"

/obj/item/areaeditor/blueprints/slime/edit_area()
	var/success = ..()
	var/area/A = get_area(src)
	if(success)
		for(var/turf/T in A)
			T.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			T.add_atom_colour("#2956B2", FIXED_COLOUR_PRIORITY)
		qdel(src)
