
/// Slime Extracts ///

/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	force = 1
	w_class = 1
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=3"
	var/Uses = 1 // uses before it goes inert

/obj/item/slime_extract/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/slimepotion/enhancer))
		if(Uses >= 5)
			user << "<span class='warning'>You cannot enhance this extract further!</span>"
			return ..()
		user <<"<span class='notice'>You apply the enhancer to the slime extract. It may now be reused one more time.</span>"
		Uses++
		qdel(O)
	..()

/obj/item/slime_extract/New()
		..()
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
	w_class = 1
	origin_tech = "biotech=4"

/obj/item/slimepotion/afterattack(obj/item/weapon/reagent_containers/target, mob/user , proximity)
	if (istype(target))
		user << "<span class='notice'>You cannot transfer [src] to [target]! It appears the potion must be given directly to a slime to absorb.</span>" // le fluff faec
		return

/obj/item/slimepotion/docility
	name = "docility potion"
	desc = "A potent chemical mix that nullifies a slime's hunger, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

/obj/item/slimepotion/docility/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		user << "<span class='warning'>The potion only works on slimes!</span>"
		return ..()
	if(M.stat)
		user << "<span class='warning'>The slime is dead!</span>"
		return ..()

	M.docile = 1
	M.nutrition = 700
	M <<"<span class='warning'>You absorb the potion and feel your intense desire to feed melt away.</span>"
	user <<"<span class='notice'>You feed the slime the potion, removing its hunger and calming it.</span>"
	var/newname = copytext(sanitize(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text),1,MAX_NAME_LEN)

	if (!newname)
		newname = "pet slime"
	M.name = newname
	M.real_name = newname
	qdel(src)

/obj/item/slimepotion/sentience
	name = "sentience potion"
	desc = "A miraculous chemical mix that can raise the intelligence of creatures to human levels. Unlike normal slime potions, it can be absorbed by any nonsentient being."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	origin_tech = "biotech=5"
	var/list/not_interested = list()
	var/being_used = 0
	var/sentience_type = SENTIENCE_ORGANIC

/obj/item/slimepotion/sentience/afterattack(mob/living/M, mob/user)
	if(being_used || !ismob(M))
		return
	if(!isanimal(M) || M.ckey) //only works on animals that aren't player controlled
		user << "<span class='warning'>[M] is already too intelligent for this to work!</span>"
		return ..()
	if(M.stat)
		user << "<span class='warning'>[M] is dead!</span>"
		return ..()
	var/mob/living/simple_animal/SM = M
	if(SM.sentience_type != sentience_type)
		user << "<span class='warning'>The potion won't work on [SM].</span>"
		return ..()



	user << "<span class='notice'>You offer the sentience potion to [SM]...</span>"
	being_used = 1

	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [SM.name]?", ROLE_ALIEN, null, ROLE_ALIEN, 50)
	var/mob/dead/observer/theghost = null
	if(candidates.len)
		theghost = pick(candidates)
		SM.key = theghost.key
		SM.languages |= HUMAN
		SM.faction = user.faction
		SM.sentience_act()
		SM << "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>"
		SM << "<span class='userdanger'>You are grateful to be self aware and owe [user] a great debt. Serve [user], and assist them in completing their goals at any cost.</span>"
		user << "<span class='notice'>[SM] accepts the potion and suddenly becomes attentive and aware. It worked!</span>"
		qdel(src)
	else
		user << "<span class='notice'>[SM] looks interested for a moment, but then looks back down. Maybe you should try again later.</span>"
		being_used = 0
		..()

/obj/item/slimepotion/steroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a baby slime to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

/obj/item/slimepotion/steroid/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))//If target is not a slime.
		user << "<span class='warning'>The steroid only works on baby slimes!</span>"
		return ..()
	if(M.is_adult) //Can't steroidify adults
		user << "<span class='warning'>Only baby slimes can use the steroid!</span>"
		return ..()
	if(M.stat)
		user << "<span class='warning'>The slime is dead!</span>"
		return ..()
	if(M.cores >= 5)
		user <<"<span class='warning'>The slime already has the maximum amount of extract!</span>"
		return ..()

	user <<"<span class='notice'>You feed the slime the steroid. It will now produce one more extract.</span>"
	M.cores++
	qdel(src)

/obj/item/slimepotion/enhancer
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a slime extract an additional use."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

/obj/item/slimepotion/stabilizer
	name = "slime stabilizer"
	desc = "A potent chemical mix that will reduce the chance of a slime mutating."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"

/obj/item/slimepotion/stabilizer/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		user << "<span class='warning'>The stabilizer only works on slimes!</span>"
		return ..()
	if(M.stat)
		user << "<span class='warning'>The slime is dead!</span>"
		return ..()
	if(M.mutation_chance == 0)
		user <<"<span class='warning'>The slime already has no chance of mutating!</span>"
		return ..()

	user <<"<span class='notice'>You feed the slime the stabilizer. It is now less likely to mutate.</span>"
	M.mutation_chance = Clamp(M.mutation_chance-15,0,100)
	qdel(src)

/obj/item/slimepotion/mutator
	name = "slime mutator"
	desc = "A potent chemical mix that will increase the chance of a slime mutating."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/slimepotion/mutator/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		user << "<span class='warning'>The mutator only works on slimes!</span>"
		return ..()
	if(M.stat)
		user << "<span class='warning'>The slime is dead!</span>"
		return ..()
	if(M.mutator_used)
		user << "<span class='warning'>This slime has already consumed a mutator, any more would be far too unstable!</span>"
		return ..()
	if(M.mutation_chance == 100)
		user <<"<span class='warning'>The slime is already guaranteed to mutate!</span>"
		return ..()

	user <<"<span class='notice'>You feed the slime the mutator. It is now more likely to mutate.</span>"
	M.mutation_chance = Clamp(M.mutation_chance+12,0,100)
	M.mutator_used = TRUE
	qdel(src)

/obj/item/slimepotion/speed
	name = "slime speed potion"
	desc = "A potent chemical mix that will remove the slowdown from any item."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"

/obj/item/slimepotion/speed/afterattack(obj/C, mob/user)
	..()
	if(!istype(C))
		user << "<span class='warning'>The potion can only be used on items or vehicles!</span>"
		return
	if(istype(C, /obj/item))
		var/obj/item/I = C
		if(I.slowdown <= 0)
			user << "<span class='warning'>The [C] can't be made any faster!</span>"
			return ..()
		I.slowdown = 0

	if(istype(C, /obj/vehicle))
		var/obj/vehicle/V = C
		if(V.vehicle_move_delay <= 0)
			user << "<span class='warning'>The [C] can't be made any faster!</span>"
			return ..()
		V.vehicle_move_delay = 0

	user <<"<span class='notice'>You slather the red gunk over the [C], making it faster.</span>"
	C.color = "#FF0000"
	qdel(src)


/obj/item/slimepotion/fireproof
	name = "slime chill potion"
	desc = "A potent chemical mix that will fireproof any article of clothing. Has three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	var/uses = 3

/obj/item/slimepotion/fireproof/afterattack(obj/item/clothing/C, mob/user)
	..()
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		user << "<span class='warning'>The potion can only be used on clothing!</span>"
		return
	if(C.max_heat_protection_temperature == FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
		user << "<span class='warning'>The [C] is already fireproof!</span>"
		return ..()
	user <<"<span class='notice'>You slather the blue gunk over the [C], fireproofing it.</span>"
	C.name = "fireproofed [C.name]"
	C.color = "#000080"
	C.max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	C.burn_state = FIRE_PROOF
	uses --
	if(!uses)
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
	has_sensor = 0

/obj/item/clothing/suit/golem
	name = "adamantine shell"
	desc = "a golem's thick outter shell"
	icon_state = "golem"
	item_state = "golem"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = FULL_BODY
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	flags = ABSTRACT | NODROP

/obj/item/clothing/shoes/golem
	name = "golem's feet"
	desc = "sturdy adamantine feet"
	icon_state = "golem"
	item_state = null
	flags = NOSLIP | ABSTRACT | NODROP


/obj/item/clothing/mask/breath/golem
	name = "golem's face"
	desc = "the imposing face of an adamantine golem"
	icon_state = "golem"
	item_state = "golem"
	siemens_coefficient = 0
	unacidable = 1
	flags = ABSTRACT | NODROP


/obj/item/clothing/gloves/golem
	name = "golem's hands"
	desc = "strong adamantine hands"
	icon_state = "golem"
	item_state = null
	siemens_coefficient = 0
	flags = ABSTRACT | NODROP


/obj/item/clothing/head/space/golem
	icon_state = "golem"
	item_state = "dermal"
	item_color = "dermal"
	name = "golem's head"
	desc = "a golem's head"
	unacidable = 1
	flags = ABSTRACT | NODROP

/obj/effect/golemrune
	anchored = 1
	desc = "a strange rune used to create golems. It glows when spirits are nearby."
	name = "rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "golem"
	unacidable = 1
	layer = TURF_LAYER

/obj/effect/golemrune/New()
	..()
	SSobj.processing |= src

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
		user << "<span class='warning'>The rune fizzles uselessly! There is no spirit nearby.</span>"
		return
	var/mob/living/carbon/human/G = new /mob/living/carbon/human
	G.set_species(/datum/species/golem/adamantine)
	G.set_cloned_appearance()
	G.real_name = "Adamantine Golem ([rand(1, 1000)])"
	G.name = G.real_name
	G.dna.unique_enzymes = G.dna.generate_unique_enzymes()
	G.dna.species.auto_equip(G)
	G.loc = src.loc
	G.key = ghost.key
	G << "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools. Serve [user], and assist them in completing their goals at any cost."
	G.mind.store_memory("<b>Serve [user.real_name], your creator.</b>")
	if(user.mind.special_role)
		message_admins("[key_name_admin(G)](<A HREF='?_src_=holder;adminmoreinfo=\ref[G]'>?</A>) has been summoned by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>), an antagonist.")
	log_game("[key_name(G)] was made a golem by [key_name(user)].")
	log_admin("[key_name(G)] was made a golem by [key_name(user)].")
	qdel(src)




/obj/effect/timestop
	anchored = 1
	name = "chronofield"
	desc = "ZA WARUDO"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	pixel_x = -64
	pixel_y = -64
	unacidable = 1
	mouse_opacity = 0
	var/mob/living/immune = list() // the one who creates the timestop is immune
	var/list/stopped_atoms = list()
	var/freezerange = 2
	var/duration = 140
	alpha = 125

/obj/effect/timestop/New()
	..()
	for(var/mob/living/M in player_list)
		for(var/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/T in M.mind.spell_list) //People who can stop time are immune to timestop
			immune |= M
	timestop()


/obj/effect/timestop/proc/timestop()
	playsound(get_turf(src), 'sound/magic/TIMEPARADOX2.ogg', 100, 1, -1)
	for(var/i in 1 to duration-1)
		for(var/atom/A in orange (freezerange, src.loc))
			if(istype(A, /mob/living))
				var/mob/living/M = A
				if(M in immune)
					continue
				M.stunned = 10
				M.anchored = 1
				if(istype(M, /mob/living/simple_animal/hostile))
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
		sleep(1)

	//End
	for(var/mob/living/M in stopped_atoms)
		unfreeze_mob(M)

	for(var/obj/item/projectile/P in stopped_atoms)
		P.paused = FALSE
	qdel(src)
	return



/obj/effect/timestop/proc/unfreeze_mob(mob/living/M)
	M.stunned = 0
	M.anchored = 0
	if(istype(M, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/H = M
		H.AIStatus = initial(H.AIStatus)


/obj/effect/timestop/wizard
	duration = 100


/obj/item/stack/tile/bluespace
	name = "bluespace floor tile"
	singular_name = "floor tile"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds"
	icon_state = "tile-bluespace"
	w_class = 3
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/bluespace


/turf/simulated/floor/bluespace
	slowdown = -1
	icon_state = "bluespace"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds"
	floor_tile = /obj/item/stack/tile/bluespace


/obj/item/stack/tile/sepia
	name = "sepia floor tile"
	singular_name = "floor tile"
	desc = "Time seems to flow very slowly around these tiles"
	icon_state = "tile-sepia"
	w_class = 3
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	turf_type = /turf/simulated/floor/sepia


/turf/simulated/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Time seems to flow very slowly around these tiles"
	floor_tile = /obj/item/stack/tile/sepia


/obj/item/areaeditor/blueprints/slime
	name = "cerulean prints"
	desc = "A one use yet of blueprints made of jelly like organic material. Renaming an area to 'Xenobiology Lab' will extend the reach of the management console."
	color = "#2956B2"

/obj/item/areaeditor/blueprints/slime/edit_area()
	var/success = ..()
	var/area/A = get_area(src)
	if(success)
		for(var/turf/T in A)
			T.color = "#2956B2"
		qdel(src)

