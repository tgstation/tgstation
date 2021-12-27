/// Slime Extracts ///

/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	grind_results = list()
	var/Uses = 1 ///uses before it goes inert
	var/qdel_timer = null ///deletion timer, for delayed reactions
	var/effectmod ///Which type of crossbred
	var/list/activate_reagents = list() ///Reagents required for activation
	var/recurring = FALSE

/obj/item/slime_extract/examine(mob/user)
	. = ..()
	if(Uses > 1)
		. += "It has [Uses] uses remaining."

/obj/item/slime_extract/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/slimepotion/enhancer))
		if(Uses >= 5 || recurring)
			to_chat(user, span_warning("You cannot enhance this extract further!"))
			return ..()
		if(O.type == /obj/item/slimepotion/enhancer) //Seriously, why is this defined here...?
			to_chat(user, span_notice("You apply the enhancer to the slime extract. It may now be reused one more time."))
			Uses++
		if(O.type == /obj/item/slimepotion/enhancer/max)
			to_chat(user, span_notice("You dump the maximizer on the slime extract. It can now be used a total of 5 times!"))
			Uses = 5
		qdel(O)
	..()

/obj/item/slime_extract/Initialize(mapload)
	. = ..()
	create_reagents(100, INJECTABLE | DRAWABLE)

/obj/item/slime_extract/on_grind()
	. = ..()
	if(Uses)
		grind_results[/datum/reagent/toxin/slimejelly] = 20

/**
* Effect when activated by a Luminescent.
*
* This proc is called whenever a Luminescent consumes a slime extract. Each one is separated into major and minor effects depending on the extract. Cooldown is measured in deciseconds.
*
* * arg1 - The mob absorbing the slime extract.
* * arg2 - The valid species for the absorbtion. Should always be a Luminescent unless something very major has changed.
* * arg3 - Whether or not the activation is major or minor. Major activations have large, complex effects, minor are simple.
*/
/obj/item/slime_extract/proc/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	to_chat(user, span_warning("Nothing happened... This slime extract cannot be activated this way."))
	return FALSE

/**
* Core-crossing: Feeding adult slimes extracts to obtain a much more powerful, single extract.
*
* By using a valid core on a living adult slime, then feeding it nine more of the same type, you can mutate it into more useful items. Not every slime type has an implemented core cross.
*/
/obj/item/slime_extract/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		return ..()
	if(M.stat)
		to_chat(user, span_warning("The slime is dead!"))
		return
	if(!M.is_adult)
		to_chat(user, span_warning("The slime must be an adult to cross its core!"))
		return
	if(M.effectmod && M.effectmod != effectmod)
		to_chat(user, span_warning("The slime is already being crossed with a different extract!"))
		return

	if(!M.effectmod)
		M.effectmod = effectmod

	M.applied++
	qdel(src)
	to_chat(user, span_notice("You feed the slime [src], [M.applied == 1 ? "starting to mutate its core." : "further mutating its core."]"))
	playsound(M, 'sound/effects/attackblob.ogg', 50, TRUE)

	if(M.applied >= SLIME_EXTRACT_CROSSING_REQUIRED)
		M.spawn_corecross()

/obj/item/slime_extract/grey
	name = "grey slime extract"
	icon_state = "grey slime extract"
	effectmod = "reproductive"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,/datum/reagent/water)

/obj/item/slime_extract/grey/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			var/obj/item/food/monkeycube/M = new
			if(!user.put_in_active_hand(M))
				M.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			to_chat(user, span_notice("You spit out a monkey cube."))
			return 120
		if(SLIME_ACTIVATE_MAJOR)
			to_chat(user, span_notice("Your [name] starts pulsing..."))
			if(do_after(user, 40, target = user))
				var/mob/living/simple_animal/slime/S = new(get_turf(user), "grey")
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				to_chat(user, span_notice("You spit out [S]."))
				return 350
			else
				return 0

/obj/item/slime_extract/gold
	name = "gold slime extract"
	icon_state = "gold slime extract"
	effectmod = "symbiont"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,/datum/reagent/water)



/obj/item/slime_extract/gold/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			user.visible_message(span_warning("[user] starts shaking!"),span_notice("Your [name] starts pulsing gently..."))
			if(do_after(user, 40, target = user))
				var/mob/living/spawned_mob = create_random_mob(user.drop_location(), FRIENDLY_SPAWN)
				spawned_mob.faction |= "neutral"
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				user.visible_message(span_warning("[user] spits out [spawned_mob]!"), span_notice("You spit out [spawned_mob]!"))
				return 300

		if(SLIME_ACTIVATE_MAJOR)
			user.visible_message(span_warning("[user] starts shaking violently!"),span_warning("Your [name] starts pulsing violently..."))
			if(do_after(user, 50, target = user))
				var/mob/living/spawned_mob = create_random_mob(user.drop_location(), HOSTILE_SPAWN)
				if(!user.combat_mode)
					spawned_mob.faction |= "neutral"
				else
					spawned_mob.faction |= "slime"
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				user.visible_message(span_warning("[user] spits out [spawned_mob]!"), span_warning("You spit out [spawned_mob]!"))
				return 600

/obj/item/slime_extract/silver
	name = "silver slime extract"
	icon_state = "silver slime extract"
	effectmod = "consuming"
	activate_reagents = list(/datum/reagent/toxin/plasma,/datum/reagent/water)



/obj/item/slime_extract/silver/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			var/food_type = get_random_food()
			var/obj/item/food_item = new food_type
			if(!user.put_in_active_hand(food_item))
				food_item.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [food_item]!"), span_notice("You spit out [food_item]!"))
			return 200
		if(SLIME_ACTIVATE_MAJOR)
			var/drink_type = get_random_drink()
			var/obj/O = new drink_type
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 200

/obj/item/slime_extract/metal
	name = "metal slime extract"
	icon_state = "metal slime extract"
	effectmod = "industrial"
	activate_reagents = list(/datum/reagent/toxin/plasma,/datum/reagent/water)

/obj/item/slime_extract/metal/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			var/obj/item/stack/sheet/glass/O = new(null, 5)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 150

		if(SLIME_ACTIVATE_MAJOR)
			var/obj/item/stack/sheet/iron/O = new(null, 5)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 200

/obj/item/slime_extract/purple
	name = "purple slime extract"
	icon_state = "purple slime extract"
	effectmod = "regenerative"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma)

/obj/item/slime_extract/purple/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			user.adjust_nutrition(50)
			user.blood_volume += 50
			to_chat(user, span_notice("You activate [src], and your body is refilled with fresh slime jelly!"))
			return 150

		if(SLIME_ACTIVATE_MAJOR)
			to_chat(user, span_notice("You activate [src], and it releases regenerative chemicals!"))
			user.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)
			return 600

/obj/item/slime_extract/darkpurple
	name = "dark purple slime extract"
	icon_state = "dark purple slime extract"
	effectmod = "self-sustaining"
	activate_reagents = list(/datum/reagent/toxin/plasma)

/obj/item/slime_extract/darkpurple/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			var/obj/item/stack/sheet/mineral/plasma/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 150

		if(SLIME_ACTIVATE_MAJOR)
			var/turf/open/T = get_turf(user)
			if(istype(T))
				T.atmos_spawn_air("plasma=20")
			to_chat(user, span_warning("You activate [src], and a cloud of plasma bursts out of your skin!"))
			return 900

/obj/item/slime_extract/orange
	name = "orange slime extract"
	icon_state = "orange slime extract"
	effectmod = "burning"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,/datum/reagent/water)

/obj/item/slime_extract/orange/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_notice("You activate [src]. You start feeling hot!"))
			user.reagents.add_reagent(/datum/reagent/consumable/capsaicin,10)
			return 150

		if(SLIME_ACTIVATE_MAJOR)
			user.reagents.add_reagent(/datum/reagent/phosphorus,5)//
			user.reagents.add_reagent(/datum/reagent/potassium,5) // = smoke, along with any reagents inside mr. slime
			user.reagents.add_reagent(/datum/reagent/consumable/sugar,5)     //
			to_chat(user, span_warning("You activate [src], and a cloud of smoke bursts out of your skin!"))
			return 450

/obj/item/slime_extract/yellow
	name = "yellow slime extract"
	icon_state = "yellow slime extract"
	effectmod = "charged"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,/datum/reagent/water)

/obj/item/slime_extract/yellow/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			if(species.glow_intensity != LUMINESCENT_DEFAULT_GLOW)
				to_chat(user, span_warning("Your glow is already enhanced!"))
				return
			species.update_glow(user, 5)
			addtimer(CALLBACK(species, /datum/species/jelly/luminescent.proc/update_glow, user, LUMINESCENT_DEFAULT_GLOW), 600)
			to_chat(user, span_notice("You start glowing brighter."))

		if(SLIME_ACTIVATE_MAJOR)
			user.visible_message(span_warning("[user]'s skin starts flashing intermittently..."), span_warning("Your skin starts flashing intermittently..."))
			if(do_after(user, 25, target = user))
				empulse(user, 1, 2)
				user.visible_message(span_warning("[user]'s skin flashes!"), span_warning("Your skin flashes as you emit an electromagnetic pulse!"))
				return 600

/obj/item/slime_extract/red
	name = "red slime extract"
	icon_state = "red slime extract"
	effectmod = "sanguine"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,/datum/reagent/water)

/obj/item/slime_extract/red/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_notice("You activate [src]. You start feeling fast!"))
			user.reagents.add_reagent(/datum/reagent/medicine/ephedrine,5)
			return 450

		if(SLIME_ACTIVATE_MAJOR)
			user.visible_message(span_warning("[user]'s skin flashes red for a moment..."), span_warning("Your skin flashes red as you emit rage-inducing pheromones..."))
			for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(user), null))
				slime.rabid = TRUE
				slime.visible_message(span_danger("The [slime] is driven into a frenzy!"))
			return 600

/obj/item/slime_extract/blue
	name = "blue slime extract"
	icon_state = "blue slime extract"
	effectmod = "stabilized"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,/datum/reagent/water)

/obj/item/slime_extract/blue/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_notice("You activate [src]. Your genome feels more stable!"))
			user.adjustCloneLoss(-15)
			user.reagents.add_reagent(/datum/reagent/medicine/mutadone, 10)
			user.reagents.add_reagent(/datum/reagent/medicine/potass_iodide, 10)
			return 250

		if(SLIME_ACTIVATE_MAJOR)
			user.reagents.create_foam(/datum/effect_system/foam_spread,20)
			user.visible_message(span_danger("Foam spews out from [user]'s skin!"), span_warning("You activate [src], and foam bursts out of your skin!"))
			return 600

/obj/item/slime_extract/darkblue
	name = "dark blue slime extract"
	icon_state = "dark blue slime extract"
	effectmod = "chilling"
	activate_reagents = list(/datum/reagent/toxin/plasma,/datum/reagent/water)

/obj/item/slime_extract/darkblue/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_notice("You activate [src]. You start feeling colder!"))
			user.extinguish_mob()
			user.adjust_fire_stacks(-20)
			user.reagents.add_reagent(/datum/reagent/consumable/frostoil,4)
			user.reagents.add_reagent(/datum/reagent/medicine/cryoxadone,5)
			return 100

		if(SLIME_ACTIVATE_MAJOR)
			var/turf/open/T = get_turf(user)
			if(istype(T))
				T.atmos_spawn_air("nitrogen=40;TEMP=2.7")
			to_chat(user, span_warning("You activate [src], and icy air bursts out of your skin!"))
			return 900

/obj/item/slime_extract/pink
	name = "pink slime extract"
	icon_state = "pink slime extract"
	effectmod = "gentle"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma)

/obj/item/slime_extract/pink/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			if(user.gender != MALE && user.gender != FEMALE)
				to_chat(user, span_warning("You can't swap your gender!"))
				return

			if(user.gender == MALE)
				user.gender = FEMALE
				user.visible_message(span_boldnotice("[user] suddenly looks more feminine!"), span_boldwarning("You suddenly feel more feminine!"))
			else
				user.gender = MALE
				user.visible_message(span_boldnotice("[user] suddenly looks more masculine!"), span_boldwarning("You suddenly feel more masculine!"))
			return 100

		if(SLIME_ACTIVATE_MAJOR)
			user.visible_message(span_warning("[user]'s skin starts flashing hypnotically..."), span_notice("Your skin starts forming odd patterns, pacifying creatures around you."))
			for(var/mob/living/carbon/C in viewers(user, null))
				if(C != user)
					C.reagents.add_reagent(/datum/reagent/pax,2)
			return 600

/obj/item/slime_extract/green
	name = "green slime extract"
	icon_state = "green slime extract"
	effectmod = "mutative"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,/datum/reagent/uranium/radium)

/obj/item/slime_extract/green/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_warning("You feel yourself reverting to human form..."))
			if(do_after(user, 120, target = user))
				to_chat(user, span_warning("You feel human again!"))
				user.set_species(/datum/species/human)
				return
			to_chat(user, span_notice("You stop the transformation."))

		if(SLIME_ACTIVATE_MAJOR)
			to_chat(user, span_warning("You feel yourself radically changing your slime type..."))
			if(do_after(user, 120, target = user))
				to_chat(user, span_warning("You feel different!"))
				user.set_species(pick(/datum/species/jelly/slime, /datum/species/jelly/stargazer))
				return
			to_chat(user, span_notice("You stop the transformation."))

/obj/item/slime_extract/lightpink
	name = "light pink slime extract"
	icon_state = "light pink slime extract"
	effectmod = "loyal"
	activate_reagents = list(/datum/reagent/toxin/plasma)

/obj/item/slime_extract/lightpink/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			var/obj/item/slimepotion/slime/renaming/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 150

		if(SLIME_ACTIVATE_MAJOR)
			var/obj/item/slimepotion/slime/sentience/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 450

/obj/item/slime_extract/black
	name = "black slime extract"
	icon_state = "black slime extract"
	effectmod = "transformative"
	activate_reagents = list(/datum/reagent/toxin/plasma)

/obj/item/slime_extract/black/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_userdanger("You feel something <i>wrong</i> inside you..."))
			user.ForceContractDisease(new /datum/disease/transformation/slime(), FALSE, TRUE)
			return 100

		if(SLIME_ACTIVATE_MAJOR)
			to_chat(user, span_warning("You feel your own light turning dark..."))
			if(do_after(user, 120, target = user))
				to_chat(user, span_warning("You feel a longing for darkness."))
				user.set_species(pick(/datum/species/shadow))
				return
			to_chat(user, span_notice("You stop feeding [src]."))

/obj/item/slime_extract/oil
	name = "oil slime extract"
	icon_state = "oil slime extract"
	effectmod = "detonating"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma)

/obj/item/slime_extract/oil/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_warning("You vomit slippery oil."))
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			new /obj/effect/decal/cleanable/oil/slippery(get_turf(user))
			return 450

		if(SLIME_ACTIVATE_MAJOR)
			user.visible_message(span_warning("[user]'s skin starts pulsing and glowing ominously..."), span_userdanger("You feel unstable..."))
			if(do_after(user, 60, target = user))
				to_chat(user, span_userdanger("You explode!"))
				explosion(user, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 6, explosion_cause = src)
				user.gib()
				return
			to_chat(user, span_notice("You stop feeding [src], and the feeling passes."))

/obj/item/slime_extract/adamantine
	name = "adamantine slime extract"
	icon_state = "adamantine slime extract"
	effectmod = "crystalline"
	activate_reagents = list(/datum/reagent/toxin/plasma)

/obj/item/slime_extract/adamantine/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			if(species.armor > 0)
				to_chat(user, span_warning("Your skin is already hardened!"))
				return
			to_chat(user, span_notice("You feel your skin harden and become more resistant."))
			species.armor += 25
			addtimer(CALLBACK(src, .proc/reset_armor, species), 1200)
			return 450

		if(SLIME_ACTIVATE_MAJOR)
			to_chat(user, span_warning("You feel your body rapidly crystallizing..."))
			if(do_after(user, 120, target = user))
				to_chat(user, span_warning("You feel solid."))
				user.set_species(pick(/datum/species/golem/adamantine))
				return
			to_chat(user, span_notice("You stop feeding [src], and your body returns to its slimelike state."))

/obj/item/slime_extract/adamantine/proc/reset_armor(datum/species/jelly/luminescent/species)
	if(istype(species))
		species.armor -= 25

/obj/item/slime_extract/bluespace
	name = "bluespace slime extract"
	icon_state = "bluespace slime extract"
	effectmod = "warping"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma)
	var/teleport_ready = FALSE
	var/teleport_x = 0
	var/teleport_y = 0
	var/teleport_z = 0

/obj/item/slime_extract/bluespace/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			to_chat(user, span_warning("You feel your body vibrating..."))
			if(do_after(user, 25, target = user))
				to_chat(user, span_warning("You teleport!"))
				do_teleport(user, get_turf(user), 6, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
				return 300

		if(SLIME_ACTIVATE_MAJOR)
			if(!teleport_ready)
				to_chat(user, span_notice("You feel yourself anchoring to this spot..."))
				var/turf/T = get_turf(user)
				teleport_x = T.x
				teleport_y = T.y
				teleport_z = T.z
				teleport_ready = TRUE
			else
				teleport_ready = FALSE
				if(teleport_x && teleport_y && teleport_z)
					var/turf/T = locate(teleport_x, teleport_y, teleport_z)
					to_chat(user, span_notice("You snap back to your anchor point!"))
					do_teleport(user, T,  asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
					return 450


/obj/item/slime_extract/pyrite
	name = "pyrite slime extract"
	icon_state = "pyrite slime extract"
	effectmod = "prismatic"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma)

/obj/item/slime_extract/pyrite/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			var/chosen = pick(difflist(subtypesof(/obj/item/toy/crayon),typesof(/obj/item/toy/crayon/spraycan)))
			var/obj/item/O = new chosen(null)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 150

		if(SLIME_ACTIVATE_MAJOR)
			var/blacklisted_cans = list(/obj/item/toy/crayon/spraycan/borg, /obj/item/toy/crayon/spraycan/infinite)
			var/chosen = pick(subtypesof(/obj/item/toy/crayon/spraycan) - blacklisted_cans)
			var/obj/item/O = new chosen(null)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 250

/obj/item/slime_extract/cerulean
	name = "cerulean slime extract"
	icon_state = "cerulean slime extract"
	effectmod = "recurring"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma)

/obj/item/slime_extract/cerulean/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			user.reagents.add_reagent(/datum/reagent/medicine/salbutamol,15)
			to_chat(user, span_notice("You feel like you don't need to breathe!"))
			return 150

		if(SLIME_ACTIVATE_MAJOR)
			var/turf/open/T = get_turf(user)
			if(istype(T))
				T.atmos_spawn_air("o2=11;n2=41;TEMP=293.15")
				to_chat(user, span_warning("You activate [src], and fresh air bursts out of your skin!"))
				return 600

/obj/item/slime_extract/sepia
	name = "sepia slime extract"
	icon_state = "sepia slime extract"
	effectmod = "lengthened"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,/datum/reagent/water)

/obj/item/slime_extract/sepia/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			var/obj/item/camera/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 150

		if(SLIME_ACTIVATE_MAJOR)
			to_chat(user, span_warning("You feel time slow down..."))
			if(do_after(user, 30, target = user))
				new /obj/effect/timestop(get_turf(user), 2, 50, list(user))
				return 900

/obj/item/slime_extract/rainbow
	name = "rainbow slime extract"
	icon_state = "rainbow slime extract"
	effectmod = "hyperchromatic"
	activate_reagents = list(/datum/reagent/blood,/datum/reagent/toxin/plasma,"lesser plasma",/datum/reagent/toxin/slimejelly,"holy water and uranium") //Curse this snowflake reagent list.

/obj/item/slime_extract/rainbow/activate(mob/living/carbon/human/user, datum/species/jelly/luminescent/species, activation_type)
	switch(activation_type)
		if(SLIME_ACTIVATE_MINOR)
			user.dna.features["mcolor"] = "#[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"
			user.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
			user.updateappearance(mutcolor_update=1)
			species.update_glow(user)
			to_chat(user, span_notice("You feel different..."))
			return 100

		if(SLIME_ACTIVATE_MAJOR)
			var/chosen = pick(subtypesof(/obj/item/slime_extract))
			var/obj/item/O = new chosen(null)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(span_warning("[user] spits out [O]!"), span_notice("You spit out [O]!"))
			return 150

////Slime-derived potions///

/**
* #Slime potions
*
* Feed slimes potions either by hand or using the slime console.
*
* Slime potions either augment the slime's behavior, its extract output, or its intelligence. These all come either from extract effects or cross cores.
* A few of the more powerful ones can modify someone's equipment or gender.
* New ones should probably be accessible only through cross cores as all the normal core types already have uses. Rule of thumb is 'stronger effects go in cross cores'.
*/

/obj/item/slimepotion
	name = "slime potion"
	desc = "A hard yet gelatinous capsule excreted by a slime, containing mysterious substances."
	w_class = WEIGHT_CLASS_TINY

/obj/item/slimepotion/afterattack(obj/item/reagent_containers/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if (istype(target))
		to_chat(user, span_warning("You cannot transfer [src] to [target]! It appears the potion must be given directly to a slime to absorb.") )
		return

/obj/item/slimepotion/slime/docility
	name = "docility potion"
	desc = "A potent chemical mix that nullifies a slime's hunger, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potsilver"

/obj/item/slimepotion/slime/docility/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, span_warning("The potion only works on slimes!"))
		return ..()
	if(M.stat)
		to_chat(user, span_warning("The slime is dead!"))
		return
	if(M.rabid) //Stops being rabid, but doesn't become truly docile.
		to_chat(M, span_warning("You absorb the potion, and your rabid hunger finally settles to a normal desire to feed."))
		to_chat(user, span_notice("You feed the slime the potion, calming its rabid rage."))
		M.rabid = FALSE
		qdel(src)
		return
	M.docile = 1
	M.set_nutrition(700)
	to_chat(M, span_warning("You absorb the potion and feel your intense desire to feed melt away."))
	to_chat(user, span_notice("You feed the slime the potion, removing its hunger and calming it."))
	var/newname = sanitize_name(tgui_input_text(user, "Would you like to give the slime a name?", "Name your new pet", "Pet Slime", MAX_NAME_LEN))

	if (!newname)
		newname = "Pet Slime"
	M.name = newname
	M.real_name = newname
	qdel(src)

/obj/item/slimepotion/slime/sentience
	name = "intelligence potion"
	desc = "A miraculous chemical mix that grants human like intelligence to living beings."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpink"
	var/list/not_interested = list()
	var/being_used = FALSE
	var/sentience_type = SENTIENCE_ORGANIC

/obj/item/slimepotion/slime/sentience/attack(mob/living/dumb_mob, mob/user)
	if(being_used || !ismob(dumb_mob))
		return
	if((!isanimal(dumb_mob) && !isbasicmob(dumb_mob)) || dumb_mob.ckey) //only works on animals that aren't player controlled
		to_chat(user, span_warning("[dumb_mob] is already too intelligent for this to work!"))
		return
	if(dumb_mob.stat)
		to_chat(user, span_warning("[dumb_mob] is dead!"))
		return
	if(isanimal(dumb_mob))
		var/mob/living/simple_animal/dumb_animal = dumb_mob
		if(dumb_animal.sentience_type != sentience_type)
			to_chat(user, span_warning("[src] won't work on [dumb_animal]."))
			return
	else if(isbasicmob(dumb_mob)) //duplicate shit code until all simple animasls are made into basic mobs. sentience_type is not on living, but it duplicated  on basic and animal
		var/mob/living/basic/basic_dumb_bitch = dumb_mob
		if(basic_dumb_bitch.sentience_type != sentience_type)
			to_chat(user, span_warning("[src] won't work on [basic_dumb_bitch]."))
			return

	to_chat(user, span_notice("You offer [src] to [dumb_mob]..."))
	being_used = TRUE

	var/list/candidates = poll_candidates_for_mob("Do you want to play as [dumb_mob.name]?", ROLE_SENTIENCE, ROLE_SENTIENCE, 5 SECONDS, dumb_mob, POLL_IGNORE_SENTIENCE_POTION) // see poll_ignore.dm
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		dumb_mob.key = C.key
		dumb_mob.mind.enslave_mind_to_creator(user)
		SEND_SIGNAL(dumb_mob, COMSIG_SIMPLEMOB_SENTIENCEPOTION, user)
		if(isanimal(dumb_mob))
			var/mob/living/simple_animal/smart_animal = dumb_mob
			smart_animal.sentience_act()
		to_chat(dumb_mob, span_warning("All at once it makes sense: you know what you are and who you are! Self awareness is yours!"))
		to_chat(dumb_mob, span_userdanger("You are grateful to be self aware and owe [user.real_name] a great debt. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost."))
		if(dumb_mob.flags_1 & HOLOGRAM_1) //Check to see if it's a holodeck creature
			to_chat(dumb_mob, span_userdanger("You also become depressingly aware that you are not a real creature, but instead a holoform. Your existence is limited to the parameters of the holodeck."))
		to_chat(user, span_notice("[dumb_mob] accepts [src] and suddenly becomes attentive and aware. It worked!"))
		dumb_mob.copy_languages(user)
		after_success(user, dumb_mob)
		qdel(src)
	else
		to_chat(user, span_notice("[dumb_mob] looks interested for a moment, but then looks back down. Maybe you should try again later."))
		being_used = FALSE
		..()

/obj/item/slimepotion/slime/sentience/proc/after_success(mob/living/user, mob/living/smart_mob)
	return

/obj/item/slimepotion/slime/sentience/nuclear
	name = "syndicate intelligence potion"
	desc = "A miraculous chemical mix that grants human like intelligence to living beings. It has been modified with Syndicate technology to also grant an internal radio implant to the target and authenticate with identification systems."

/obj/item/slimepotion/slime/sentience/nuclear/after_success(mob/living/user, mob/living/smart_mob)
	var/obj/item/implant/radio/syndicate/imp = new(src)
	imp.implant(smart_mob, user)
	smart_mob.AddComponent(/datum/component/simple_access, list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS))

/obj/item/slimepotion/transference
	name = "consciousness transference potion"
	desc = "A strange slime-based chemical that, when used, allows the user to transfer their consciousness to a lesser being."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potorange"
	var/prompted = 0
	var/animal_type = SENTIENCE_ORGANIC

/obj/item/slimepotion/transference/afterattack(mob/living/switchy_mob, mob/living/user, proximity)
	if(!proximity)
		return
	if(prompted || !ismob(switchy_mob))
		return
	if(!(isanimal(switchy_mob) || isbasicmob(switchy_mob))|| switchy_mob.ckey) //much like sentience, these will not work on something that is already player controlled
		to_chat(user, span_warning("[switchy_mob] already has a higher consciousness!"))
		return ..()
	if(switchy_mob.stat)
		to_chat(user, span_warning("[switchy_mob] is dead!"))
		return ..()
	if(isanimal(switchy_mob))
		var/mob/living/simple_animal/switchy_animal= switchy_mob
		if(switchy_animal.sentience_type != animal_type)
			to_chat(user, span_warning("You cannot transfer your consciousness to [switchy_animal].") )
			return ..()
	else	//ugly code duplication, but necccesary as sentience_type is implemented twice.
		var/mob/living/basic/basic_mob = switchy_mob
		if(basic_mob.sentience_type != animal_type)
			to_chat(user, span_warning("You cannot transfer your consciousness to [basic_mob].") )
			return ..()

	var/job_banned = is_banned_from(user.ckey, ROLE_MIND_TRANSFER)
	if(QDELETED(src) || QDELETED(switchy_mob) || QDELETED(user))
		return

	if(job_banned)
		to_chat(user, span_warning("Your mind goes blank as you attempt to use the potion."))
		return

	prompted = 1
	if(tgui_alert(usr,"This will permanently transfer your consciousness to [switchy_mob]. Are you sure you want to do this?",,list("Yes","No"))=="No")
		prompted = 0
		return

	to_chat(user, span_notice("You drink the potion then place your hands on [switchy_mob]..."))

	user.mind.transfer_to(switchy_mob)
	switchy_mob.faction = user.faction.Copy()
	user.death()
	to_chat(switchy_mob, span_notice("In a quick flash, you feel your consciousness flow into [switchy_mob]!"))
	to_chat(switchy_mob, span_warning("You are now [switchy_mob]. Your allegiances, alliances, and role is still the same as it was prior to consciousness transfer!"))
	switchy_mob.name = "[user.real_name]"
	qdel(src)
	if(isanimal(switchy_mob))
		var/mob/living/simple_animal/switchy_animal= switchy_mob
		switchy_animal.sentience_act()

/obj/item/slimepotion/slime/steroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a baby slime to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potred"

/obj/item/slimepotion/slime/steroid/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))//If target is not a slime.
		to_chat(user, span_warning("The steroid only works on baby slimes!"))
		return ..()
	if(M.is_adult) //Can't steroidify adults
		to_chat(user, span_warning("Only baby slimes can use the steroid!"))
		return
	if(M.stat)
		to_chat(user, span_warning("The slime is dead!"))
		return
	if(M.cores >= 5)
		to_chat(user, span_warning("The slime already has the maximum amount of extract!"))
		return

	to_chat(user, span_notice("You feed the slime the steroid. It will now produce one more extract."))
	M.cores++
	qdel(src)

/obj/item/slimepotion/enhancer
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a slime extract an additional use."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/slime/stabilizer
	name = "slime stabilizer"
	desc = "A potent chemical mix that will reduce the chance of a slime mutating."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/slimepotion/slime/stabilizer/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, span_warning("The stabilizer only works on slimes!"))
		return ..()
	if(M.stat)
		to_chat(user, span_warning("The slime is dead!"))
		return
	if(M.mutation_chance == 0)
		to_chat(user, span_warning("The slime already has no chance of mutating!"))
		return

	to_chat(user, span_notice("You feed the slime the stabilizer. It is now less likely to mutate."))
	M.mutation_chance = clamp(M.mutation_chance-15,0,100)
	qdel(src)

/obj/item/slimepotion/slime/mutator
	name = "slime mutator"
	desc = "A potent chemical mix that will increase the chance of a slime mutating."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potgreen"

/obj/item/slimepotion/slime/mutator/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, span_warning("The mutator only works on slimes!"))
		return ..()
	if(M.stat)
		to_chat(user, span_warning("The slime is dead!"))
		return
	if(M.mutator_used)
		to_chat(user, span_warning("This slime has already consumed a mutator, any more would be far too unstable!"))
		return
	if(M.mutation_chance == 100)
		to_chat(user, span_warning("The slime is already guaranteed to mutate!"))
		return

	to_chat(user, span_notice("You feed the slime the mutator. It is now more likely to mutate."))
	M.mutation_chance = clamp(M.mutation_chance+12,0,100)
	M.mutator_used = TRUE
	qdel(src)

/obj/item/slimepotion/speed
	name = "slime speed potion"
	desc = "A potent chemical mix that will remove the slowdown from any item."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potyellow"

/obj/item/slimepotion/speed/afterattack(obj/C, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(C))
		// applying this to vehicles is handled in the ridable element, see [/datum/element/ridable/proc/check_potion]
		to_chat(user, span_warning("The potion can only be used on items or vehicles!"))
		return
	if(isitem(C))
		var/obj/item/I = C
		if(I.slowdown <= 0 || I.obj_flags & IMMUTABLE_SLOW)
			to_chat(user, span_warning("The [C] can't be made any faster!"))
			return ..()
		I.slowdown = 0

	to_chat(user, span_notice("You slather the red gunk over the [C], making it faster."))
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#FF0000", FIXED_COLOUR_PRIORITY)
	qdel(src)

/obj/item/slimepotion/fireproof
	name = "slime chill potion"
	desc = "A potent chemical mix that will fireproof any article of clothing. Has three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potblue"
	resistance_flags = FIRE_PROOF
	var/uses = 3

/obj/item/slimepotion/fireproof/afterattack(obj/item/clothing/C, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!uses)
		qdel(src)
		return
	if(!istype(C))
		to_chat(user, span_warning("The potion can only be used on clothing!"))
		return
	if(C.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		to_chat(user, span_warning("The [C] is already fireproof!"))
		return
	to_chat(user, span_notice("You slather the blue gunk over the [C], fireproofing it."))
	C.name = "fireproofed [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
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
		to_chat(user, span_warning("The potion can only be used on living things!"))
		return

	if(L.gender != MALE && L.gender != FEMALE)
		to_chat(user, span_warning("The potion can only be used on gendered things!"))
		return

	if(L.gender == MALE)
		L.gender = FEMALE
		L.visible_message(span_boldnotice("[L] suddenly looks more feminine!"), span_boldwarning("You suddenly feel more feminine!"))
	else
		L.gender = MALE
		L.visible_message(span_boldnotice("[L] suddenly looks more masculine!"), span_boldwarning("You suddenly feel more masculine!"))
	L.regenerate_icons()
	qdel(src)

/obj/item/slimepotion/slime/renaming
	name = "renaming potion"
	desc = "A potion that allows a self-aware being to change what name it subconciously presents to the world."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potgreen"

	var/being_used = FALSE

/obj/item/slimepotion/slime/renaming/attack(mob/living/M, mob/user)
	if(being_used || !ismob(M))
		return
	if(!M.ckey) //only works on animals that aren't player controlled
		to_chat(user, span_warning("[M] is not self aware, and cannot pick its own name."))
		return

	being_used = TRUE

	to_chat(user, span_notice("You offer [src] to [user]..."))

	var/new_name = sanitize_name(tgui_input_text(M, "What would you like your name to be?", "Input a name", M.real_name, MAX_NAME_LEN))

	if(!new_name || QDELETED(src) || QDELETED(M) || new_name == M.real_name || !M.Adjacent(user))
		being_used = FALSE
		return

	M.visible_message(span_notice("[span_name("[M]")] has a new name, [span_name("[new_name]")]."), span_notice("Your old name of [span_name("[M.real_name]")] fades away, and your new name [span_name("[new_name]")] anchors itself in your mind."))
	message_admins("[ADMIN_LOOKUPFLW(user)] used [src] on [ADMIN_LOOKUPFLW(M)], letting them rename themselves into [new_name].")
	log_game("[key_name(user)] used [src] on [key_name(M)], letting them rename themselves into [new_name].")

	// pass null as first arg to not update records or ID/PDA
	M.fully_replace_character_name(null, new_name)

	qdel(src)

/obj/item/slimepotion/slime/slimeradio
	name = "bluespace radio potion"
	desc = "A strange chemical that grants those who ingest it the ability to broadcast and receive subscape radio waves."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potgrey"

/obj/item/slimepotion/slime/slimeradio/attack(mob/living/M, mob/user)
	if(!ismob(M))
		return
	if(!isanimal(M))
		to_chat(user, span_warning("[M] is too complex for the potion!"))
		return
	if(M.stat)
		to_chat(user, span_warning("[M] is dead!"))
		return

	to_chat(user, span_notice("You feed the potion to [M]."))
	to_chat(M, span_notice("Your mind tingles as you are fed the potion. You can hear radio waves now!"))
	var/obj/item/implant/radio/slime/imp = new(src)
	imp.implant(M, user)
	qdel(src)

///Definitions for slime products that don't have anywhere else to go (Floor tiles, blueprints).

/obj/item/stack/tile/bluespace
	name = "bluespace floor tile"
	singular_name = "floor tile"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds."
	icon_state = "tile_bluespace"
	inhand_icon_state = "tile-bluespace"
	w_class = WEIGHT_CLASS_NORMAL
	force = 6
	mats_per_unit = list(/datum/material/iron=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	max_amount = 60
	turf_type = /turf/open/floor/bluespace
	merge_type = /obj/item/stack/tile/bluespace

/obj/item/stack/tile/sepia
	name = "sepia floor tile"
	singular_name = "floor tile"
	desc = "Time seems to flow very slowly around these tiles."
	icon_state = "tile_sepia"
	inhand_icon_state = "tile-sepia"
	w_class = WEIGHT_CLASS_NORMAL
	force = 6
	mats_per_unit = list(/datum/material/iron=500)
	throwforce = 10
	throw_speed = 0.1
	throw_range = 28
	flags_1 = CONDUCT_1
	max_amount = 60
	turf_type = /turf/open/floor/sepia
	merge_type = /obj/item/stack/tile/sepia

/obj/item/areaeditor/blueprints/slime
	name = "cerulean prints"
	desc = "A one use yet of blueprints made of jelly like organic material. Extends the reach of the management console."
	color = "#2956B2"

/obj/item/areaeditor/blueprints/slime/edit_area()
	..()
	var/area/A = get_area(src)
	for(var/turf/T in A)
		T.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		T.add_atom_colour("#2956B2", FIXED_COLOUR_PRIORITY)
	A.area_flags |= XENOBIOLOGY_COMPATIBLE
	qdel(src)
