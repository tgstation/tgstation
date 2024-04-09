/*
Charged extracts:
	Have a unique, effect when filled with
	10u plasma and activated in-hand, related to their
	normal extract effect.
*/
/obj/item/slimecross/charged
	name = "charged extract"
	desc = "It sparks with electric power."
	effect = "charged"
	icon_state = "charged"

/obj/item/slimecross/charged/Initialize(mapload)
	. = ..()
	create_reagents(10, INJECTABLE | DRAWABLE)

/obj/item/slimecross/charged/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma, 10))
		to_chat(user, span_warning("This extract needs to be full of plasma to activate!"))
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma, 10)
	to_chat(user, span_notice("You squeeze the extract, and it absorbs the plasma!"))
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	playsound(src, 'sound/effects/light_flicker.ogg', 50, TRUE)
	do_effect(user)

/obj/item/slimecross/charged/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/charged/grey
	colour = SLIME_TYPE_GREY
	effect_desc = "Produces a slime reviver potion, which revives dead slimes."

/obj/item/slimecross/charged/grey/do_effect(mob/user)
	new /obj/item/slimepotion/slime_reviver(get_turf(user))
	user.visible_message(span_notice("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/orange
	colour = SLIME_TYPE_ORANGE
	effect_desc = "Instantly makes a large burst of flame for a moment."

/obj/item/slimecross/charged/orange/do_effect(mob/user)
	var/turf/targetturf = get_turf(user)
	for(var/turf/turf as anything in RANGE_TURFS(5,targetturf))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)
	..()

/obj/item/slimecross/charged/purple
	colour = SLIME_TYPE_PURPLE
	effect_desc = "Creates a packet of omnizine."

/obj/item/slimecross/charged/purple/do_effect(mob/user)
	new /obj/item/slimecrossbeaker/omnizine(get_turf(user))
	user.visible_message(span_notice("[src] sparks, and floods with a regenerative solution!"))
	..()

/obj/item/slimecross/charged/blue
	colour = SLIME_TYPE_BLUE
	effect_desc = "Creates a potion that neuters the mutation chance of a slime, which passes on to new generations."

/obj/item/slimecross/charged/blue/do_effect(mob/user)
	new /obj/item/slimepotion/slime/chargedstabilizer(get_turf(user))
	user.visible_message(span_notice("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/metal
	colour = SLIME_TYPE_METAL
	effect_desc = "Produces a bunch of metal and plasteel."

/obj/item/slimecross/charged/metal/do_effect(mob/user)
	new /obj/item/stack/sheet/iron(get_turf(user), 25)
	new /obj/item/stack/sheet/plasteel(get_turf(user), 10)
	user.visible_message(span_notice("[src] grows into a plethora of metals!"))
	..()

/obj/item/slimecross/charged/yellow
	colour = SLIME_TYPE_YELLOW
	effect_desc = "Creates a hypercharged slime cell battery, which has high capacity but takes longer to recharge."

/obj/item/slimecross/charged/yellow/do_effect(mob/user)
	new /obj/item/stock_parts/cell/high/slime_hypercharged(get_turf(user))
	user.visible_message(span_notice("[src] sparks violently, and swells with electric power!"))
	..()

/obj/item/slimecross/charged/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	effect_desc = "Creates several sheets of plasma."

/obj/item/slimecross/charged/darkpurple/do_effect(mob/user)
	new /obj/item/stack/sheet/mineral/plasma(get_turf(user), 10)
	user.visible_message(span_notice("[src] produces a large amount of plasma!"))
	..()

/obj/item/slimecross/charged/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	effect_desc = "Produces a pressure proofing potion."

/obj/item/slimecross/charged/darkblue/do_effect(mob/user)
	new /obj/item/slimepotion/spaceproof(get_turf(user))
	user.visible_message(span_notice("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/silver
	colour = SLIME_TYPE_SILVER
	effect_desc = "Creates a slime cake and some drinks."

/obj/item/slimecross/charged/silver/do_effect(mob/user)
	new /obj/item/food/cake/slimecake(get_turf(user))
	for(var/i in 1 to 10)
		var/drink_type = get_random_drink()
		new drink_type(get_turf(user))
	user.visible_message(span_notice("[src] produces a party's worth of cake and drinks!"))
	..()

/obj/item/slimecross/charged/bluespace
	colour = SLIME_TYPE_BLUESPACE
	effect_desc = "Makes a bluespace polycrystal."

/obj/item/slimecross/charged/bluespace/do_effect(mob/user)
	new /obj/item/stack/sheet/bluespace_crystal(get_turf(user), 10)
	user.visible_message(span_notice("[src] produces several sheets of polycrystal!"))
	..()

/obj/item/slimecross/charged/sepia
	colour = SLIME_TYPE_SEPIA
	effect_desc = "Creates a camera obscura."

/obj/item/slimecross/charged/sepia/do_effect(mob/user)
	new /obj/item/camera/spooky(get_turf(user))
	user.visible_message(span_notice("[src] flickers in a strange, ethereal manner, and produces a camera!"))
	..()

/obj/item/slimecross/charged/cerulean
	colour = SLIME_TYPE_CERULEAN
	effect_desc = "Creates an extract enhancer, giving whatever it's used on five more uses."

/obj/item/slimecross/charged/cerulean/do_effect(mob/user)
	new /obj/item/slimepotion/enhancer/max(get_turf(user))
	user.visible_message(span_notice("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/pyrite
	colour = SLIME_TYPE_PYRITE
	effect_desc = "Creates bananium. Oh no."

/obj/item/slimecross/charged/pyrite/do_effect(mob/user)
	new /obj/item/stack/sheet/mineral/bananium(get_turf(user), 10)
	user.visible_message(span_warning("[src] solidifies with a horrifying banana stench!"))
	..()

/obj/item/slimecross/charged/red
	colour = SLIME_TYPE_RED
	effect_desc = "Produces a lavaproofing potion"

/obj/item/slimecross/charged/red/do_effect(mob/user)
	new /obj/item/slimepotion/lavaproof(get_turf(user))
	user.visible_message(span_notice("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/green
	colour = SLIME_TYPE_GREEN
	effect_desc = "Lets you choose what slime species you want to be."

/obj/item/slimecross/charged/green/do_effect(mob/user)
	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user))
		to_chat(user, span_warning("You must be a humanoid to use this!"))
		return
	var/list/choice_list = list()
	for(var/datum/species/species_type as anything in subtypesof(/datum/species/jelly))
		choice_list[initial(species_type.name)] = species_type
	var/racechoice = tgui_input_list(human_user, "Choose your slime subspecies", "Slime Selection", sort_list(choice_list))
	if(isnull(racechoice))
		to_chat(user, span_notice("You decide not to become a slime for now."))
		return
	if(!user.can_perform_action(src))
		return
	human_user.set_species(choice_list[racechoice], icon_update=1)
	human_user.visible_message(span_warning("[human_user] suddenly shifts form as [src] dissolves into [human_user.p_their()] skin!"))
	..()

/obj/item/slimecross/charged/pink
	colour = SLIME_TYPE_PINK
	effect_desc = "Produces a... lovepotion... no ERP."

/obj/item/slimecross/charged/pink/do_effect(mob/user)
	new /obj/item/slimepotion/lovepotion(get_turf(user))
	user.visible_message(span_notice("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/gold
	colour = SLIME_TYPE_GOLD
	effect_desc = "Slowly spawns 10 hostile monsters."
	var/max_spawn = 10
	var/spawned = 0

/obj/item/slimecross/charged/gold/do_effect(mob/user)
	user.visible_message(span_warning("[src] starts shuddering violently!"))
	addtimer(CALLBACK(src, PROC_REF(startTimer)), 5 SECONDS)

/obj/item/slimecross/charged/gold/proc/startTimer()
	START_PROCESSING(SSobj, src)

/obj/item/slimecross/charged/gold/process()
	visible_message(span_warning("[src] lets off a spark, and produces a living creature!"))
	new /obj/effect/particle_effect/sparks(get_turf(src))
	playsound(get_turf(src), SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	create_random_mob(get_turf(src), HOSTILE_SPAWN)
	spawned++
	if(spawned >= max_spawn)
		visible_message(span_warning("[src] collapses into a puddle of goo."))
		qdel(src)

/obj/item/slimecross/charged/gold/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/slimecross/charged/oil
	colour = SLIME_TYPE_OIL
	effect_desc = "Creates an explosion after a few seconds."

/obj/item/slimecross/charged/oil/do_effect(mob/user)
	user.visible_message(span_danger("[src] begins to shake with rapidly increasing force!"))
	addtimer(CALLBACK(src, PROC_REF(boom)), 5 SECONDS)

/obj/item/slimecross/charged/oil/proc/boom()
	explosion(src, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4, explosion_cause = src) //Much smaller effect than normal oils, but devastatingly strong where it does hit.
	qdel(src)

/obj/item/slimecross/charged/black
	colour = SLIME_TYPE_BLACK
	effect_desc = "Randomizes the user's species."

/obj/item/slimecross/charged/black/do_effect(mob/user)
	var/mob/living/carbon/human/experiment_subject = user
	if(!istype(experiment_subject))
		balloon_alert(experiment_subject, "incompatible biology!")
		return
	var/list/allowed_species = list()
	for(var/stype in subtypesof(/datum/species))
		var/datum/species/try_species = stype
		if(initial(try_species.changesource_flags) & SLIME_EXTRACT)
			allowed_species += stype

	var/datum/species/changed = pick(allowed_species)
	if(isnull(changed))
		visible_message(span_notice("[src] fizzes uselessly."))
		return
	experiment_subject.set_species(changed, icon_update = TRUE)
	to_chat(experiment_subject, span_danger("You feel very different!"))
	return ..()

/obj/item/slimecross/charged/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	effect_desc = "Produces a pacification potion, which works on monsters and humanoids."

/obj/item/slimecross/charged/lightpink/do_effect(mob/user)
	new /obj/item/slimepotion/peacepotion(get_turf(user))
	user.visible_message(span_notice("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	effect_desc = "Creates a completed golem shell."

/obj/item/slimecross/charged/adamantine/do_effect(mob/user)
	user.visible_message(span_notice("[src] produces a fully formed golem shell!"))
	new /obj/effect/mob_spawn/ghost_role/human/golem/servant(get_turf(src), /datum/species/golem, user)
	..()

/obj/item/slimecross/charged/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_desc = "Produces three living slimes of random colors."

/obj/item/slimecross/charged/rainbow/do_effect(mob/user)
	user.visible_message(span_warning("[src] swells and splits into three new slimes!"))
	for(var/i in 1 to 3)
		var/mob/living/basic/slime/new_slime = new (get_turf(user))
		new_slime.random_colour()
	return ..()
