#define BEE_TRAY_RECENT_VISIT 20 SECONDS //! How long in deciseconds until a tray can be visited by a bee again
#define BEE_DEFAULT_COLOUR "#e5e500" //! the colour we make the stripes of the bee if our reagent has no colour (or we have no reagent)
#define BEE_POLLINATE_YIELD_CHANCE 33 //! chance to increase yield of plant
#define BEE_POLLINATE_PEST_CHANCE 33 //! chance to decrease pest of plant
#define BEE_POLLINATE_POTENCY_CHANCE 50 //! chance to increase potancy of plant
#define BEE_FOODGROUPS RAW | MEAT | GORE | BUGS //! the bee food contents

/mob/living/basic/bee
	name = "bee"
	desc = "Buzzy buzzy bee, stingy sti- Ouch!"
	icon_state = ""
	icon_living = ""
	icon = 'icons/mob/simple/bees.dmi'
	gender = FEMALE
	speak_emote = list("buzzes")

	melee_damage_lower = 1
	melee_damage_upper = 1
	attack_verb_continuous = "stings"
	attack_verb_simple = "sting"
	response_help_continuous = "shoos"
	response_help_simple = "shoo"
	response_disarm_continuous = "swats away"
	response_disarm_simple = "swat away"
	response_harm_continuous = "squashes"
	response_harm_simple = "squash"

	mob_size = MOB_SIZE_LARGE
	pixel_x = -16
	base_pixel_x = -16

	speed = 1
	maxHealth = 10
	health = 10
	melee_damage_lower = 1
	melee_damage_upper = 1
	faction = list(FACTION_HOSTILE)
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | PASSMACHINE
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	density = FALSE
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	environment_smash  = ENVIRONMENT_SMASH_NONE
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/bee
	///the reagent the bee has
	var/datum/reagent/beegent = null
	///the house we live in
	var/obj/structure/beebox/beehome = null
	///our icon base
	var/icon_base = "bee"
	///the bee is a queen?
	var/is_queen = FALSE

/mob/living/basic/bee/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_SPACEWALK, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)
	generate_bee_visuals()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/clickbox, x_offset = -2, y_offset = -2)
	AddComponent(/datum/component/swarming)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_QUEEN_BEE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))

/mob/living/basic/bee/mob_pickup(mob/living/picker)
	if(flags_1 & HOLOGRAM_1)
		return
	var/obj/item/clothing/head/mob_holder/destructible/holder = new(get_turf(src), src, held_state, head_icon, held_lh, held_rh, worn_slot_flags)
	var/list/reee = list(/datum/reagent/consumable/nutriment/vitamin = 5)
	if(beegent)
		reee[beegent.type] = 5
	holder.AddComponent(/datum/component/edible, reee, null, BEE_FOODGROUPS, 10, 0, list("bee"), null, 10)
	picker.visible_message(span_warning("[picker] scoops up [src]!"))
	picker.put_in_hands(holder)

/mob/living/basic/bee/will_escape_storage()
	return TRUE

/mob/living/basic/bee/examine(mob/user)
	. = ..()

	if(isnull(beehome))
		. += span_warning("This bee is homeless!")

/mob/living/basic/bee/Destroy()
	if(beehome)
		beehome.bees -= src
		beehome = null
	beegent = null
	return ..()

/mob/living/basic/bee/death(gibbed)
	if(beehome)
		beehome.bees -= src
		beehome = null
	beegent = null
	if(flags_1 & HOLOGRAM_1 || gibbed)
		return ..()
	new /obj/item/trash/bee(loc, src)
	return ..()

/mob/living/basic/bee/proc/pre_attack(mob/living/puncher, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/hydro = target
		pollinate(hydro)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(istype(target, /obj/structure/beebox))
		var/obj/structure/beebox/hive = target
		handle_habitation(hive)
		return COMPONENT_HOSTILE_NO_ATTACK

/mob/living/basic/bee/proc/handle_habitation(obj/structure/beebox/hive)
	if(hive == beehome) //if its our home, we enter or exit it
		var/drop_location = (src in beehome.contents) ? get_turf(beehome) : beehome
		forceMove(drop_location)
		return
	if(!isnull(hive.queen_bee) && is_queen) //if we are queen and house already have a queen, dont inhabit
		return
	if(!hive.habitable(src) || !isnull(beehome)) //if not habitable or we alrdy have a home
		return
	beehome = hive
	beehome.bees += src
	if(is_queen)
		beehome.queen_bee = src

/mob/living/basic/bee/proc/reagent_incompatible(mob/living/basic/bee/ruler)
	if(!ruler)
		return FALSE
	if(ruler.beegent?.type != beegent?.type)
		return TRUE
	return FALSE

/mob/living/basic/bee/proc/generate_bee_visuals()
	cut_overlays()

	var/bee_color = BEE_DEFAULT_COLOUR
	if(beegent?.color)
		bee_color = beegent.color

	icon_state = "[icon_base]_base"
	add_overlay("[icon_base]_base")

	var/static/mutable_appearance/greyscale_overlay
	greyscale_overlay = greyscale_overlay || mutable_appearance('icons/mob/simple/bees.dmi')
	greyscale_overlay.icon_state = "[icon_base]_grey"
	greyscale_overlay.color = bee_color
	add_overlay(greyscale_overlay)

	add_overlay("[icon_base]_wings")

/mob/living/basic/bee/proc/pollinate(obj/machinery/hydroponics/hydro)
	if(!hydro.can_bee_pollinate())
		return FALSE
	hydro.recent_bee_visit = TRUE
	addtimer(VARSET_CALLBACK(hydro, recent_bee_visit, FALSE), BEE_TRAY_RECENT_VISIT)

	var/growth = health //Health also means how many bees are in the swarm, roughly.
	//better healthier plants!
	hydro.adjust_plant_health(growth*0.5)
	if(prob(BEE_POLLINATE_PEST_CHANCE))
		hydro.adjust_pestlevel(-10)
	if(prob(BEE_POLLINATE_YIELD_CHANCE))
		hydro.myseed.adjust_yield(1)
		hydro.yieldmod = 2
	if(prob(BEE_POLLINATE_POTENCY_CHANCE))
		hydro.myseed.adjust_potency(1)

	if(beehome)
		beehome.bee_resources = min(beehome.bee_resources + growth, 100)

/mob/living/basic/bee/proc/assign_reagent(datum/reagent/toxin)
	if(!istype(toxin))
		return
	var/static/list/injection_range
	if(!injection_range)
		injection_range = string_numbers_list(list(1, 5))
	if(beegent) //clear the old since this one is going to have some new value
		RemoveElement(/datum/element/venomous, beegent.type, injection_range)
	beegent = toxin
	name = "[initial(name)] ([toxin.name])"
	real_name = name
	AddElement(/datum/element/venomous, beegent.type, injection_range)
	generate_bee_visuals()

/mob/living/basic/bee/queen
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ!"
	icon_base = "queen"
	is_queen = TRUE
	ai_controller = /datum/ai_controller/basic_controller/queen_bee

/mob/living/basic/bee/queen/will_escape_storage()
	return FALSE

/mob/living/basic/bee/toxin
	desc = "This bee is holding some sort of fluid."

/mob/living/basic/bee/toxin/Initialize(mapload)
	. = ..()
	var/datum/reagent/toxin = pick(typesof(/datum/reagent/toxin))
	assign_reagent(GLOB.chemical_reagents_list[toxin])

/mob/living/basic/bee/short
	desc = "These bees seem unstable and won't survive for long."

/mob/living/basic/bee/short/Initialize(mapload, timetolive=50 SECONDS)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(death)), timetolive)

/obj/item/queen_bee
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ!"
	icon_state = "queen_item"
	inhand_icon_state = ""
	icon = 'icons/mob/simple/bees.dmi'
	/// The actual mob that our bee item corresponds to
	var/mob/living/basic/bee/queen/queen

/obj/item/queen_bee/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_QUEEN_BEE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	RegisterSignal(src, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_needle))

/obj/item/queen_bee/Destroy()
	QDEL_NULL(queen)
	return ..()

/obj/item/queen_bee/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != queen)
		return
	queen = null
	// the bee should not exist without a bee.
	if(!QDELETED(src))
		qdel(src)

/obj/item/queen_bee/proc/handle_needle(obj/item/source, obj/item/syringe, mob/living/user, params)
	SIGNAL_HANDLER

	if(!istype(syringe, /obj/item/reagent_containers/syringe))
		return
	var/obj/item/reagent_containers/syringe/needle = syringe
	if(needle.reagents.has_reagent(/datum/reagent/royal_bee_jelly, 5)) //checked twice, because I really don't want royal bee jelly to be duped
		needle.reagents.remove_reagent(/datum/reagent/royal_bee_jelly, 5)
		var/obj/item/queen_bee/new_bee = new(get_turf(src))
		new_bee.queen = new(new_bee)
		if(queen?.beegent)
			new_bee.queen.assign_reagent(queen.beegent) //Bees use the global singleton instances of reagents, so we don't need to worry about one bee being deleted and her copies losing their reagents.
		user.put_in_active_hand(new_bee)
		user.visible_message(span_notice("[user] injects [src] with royal bee jelly, causing it to split into two bees, MORE BEES!"),span_warning("You inject [src] with royal bee jelly, causing it to split into two bees, MORE BEES!"))
		return
	var/datum/reagent/chemical = needle.reagents.get_master_reagent()
	if(isnull(chemical))
		return
	if(chemical.type == queen.beegent?.type)
		to_chat(user, span_warning("[queen] already has this chemical!"))
		return
	if(!(needle.reagents.has_reagent(chemical.type, 5)))
		to_chat(user, span_warning("You don't have enough units of that chemical to modify the bee's DNA!"))
		return
	needle.reagents.remove_reagent(chemical.type, 5)
	var/datum/reagent/bee_chem = GLOB.chemical_reagents_list[chemical.type]
	queen.assign_reagent(bee_chem)
	user.visible_message(span_warning("[user] injects [src]'s genome with [chemical.name], mutating its DNA!"),span_warning("You inject [src]'s genome with [chemical.name], mutating its DNA!"))
	name = queen.name

/obj/item/queen_bee/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] eats [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("IT'S HIP TO EAT BEES!")
	qdel(src)
	return TOXLOSS

/obj/item/queen_bee/bought

/obj/item/queen_bee/bought/Initialize(mapload)
	. = ..()
	queen = new(src)

/obj/item/trash/bee
	name = "bee"
	desc = "No wonder the bees are dying out, you monster."
	icon = 'icons/mob/simple/bees.dmi'
	icon_state = "bee_item"
	///the reagent the bee carry
	var/datum/reagent/beegent
	///the bee of this corpse
	var/bee_type = /mob/living/basic/bee

/obj/item/trash/bee/Initialize(mapload, mob/living/basic/bee/dead_bee)
	. = ..()
	AddComponent(/datum/component/edible, list(/datum/reagent/consumable/nutriment/vitamin = 5), null, BEE_FOODGROUPS, 10, 0, list("bee"), null, 10)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_QUEEN_BEE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	RegisterSignal(src, COMSIG_ATOM_ON_LAZARUS_INJECTOR, PROC_REF(use_lazarus))
	if(isnull(dead_bee))
		return
	pixel_x = dead_bee.pixel_x
	pixel_y = dead_bee.pixel_y
	bee_type = dead_bee.type
	if(dead_bee.beegent)
		beegent = dead_bee.beegent
		reagents.add_reagent(beegent.type, 5)
	update_appearance()


/obj/item/trash/bee/Destroy()
	beegent = null
	return ..()

/obj/item/trash/bee/update_overlays()
	. = ..()
	var/mutable_appearance/body_overlay = mutable_appearance(icon = icon, icon_state = "bee_item_overlay")
	body_overlay.color = beegent ? beegent.color : BEE_DEFAULT_COLOUR
	. += body_overlay

///Spawn a new bee from this trash item when hit by a lazarus injector and conditions are met.
/obj/item/trash/bee/proc/use_lazarus(datum/source, obj/item/lazarus_injector/injector, mob/user)
	SIGNAL_HANDLER
	if(injector.revive_type != SENTIENCE_ORGANIC)
		balloon_alert(user, "invalid creature!")
		return
	var/mob/living/basic/bee/revived_bee = new bee_type (drop_location())
	if(beegent)
		revived_bee.assign_reagent(beegent)
	revived_bee.lazarus_revive(user, injector.malfunctioning)
	injector.expend(revived_bee, user)
	qdel(src)
	return LAZARUS_INJECTOR_USED

#undef BEE_DEFAULT_COLOUR
#undef BEE_FOODGROUPS
#undef BEE_POLLINATE_PEST_CHANCE
#undef BEE_POLLINATE_POTENCY_CHANCE
#undef BEE_POLLINATE_YIELD_CHANCE
#undef BEE_TRAY_RECENT_VISIT
