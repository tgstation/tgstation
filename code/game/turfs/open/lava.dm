/*
 * LAVA
 * PLASMA LAVA
 * MAFIA PLASMA LAVA
 */

/turf/open/lava
	name = "lava"
	icon_state = "lava"
	desc = "Looks painful to step in. Don't mine down."
	gender = PLURAL //"That's some lava."
	baseturfs = /turf/open/lava //lava all the way down
	slowdown = 2

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	bullet_bounce_sound = 'sound/items/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	/// How much fire damage we deal to living mobs stepping on us
	var/lava_damage = 20
	/// How many firestacks we add to living mobs stepping on us
	var/lava_firestacks = 20
	/// How much temperature we expose objects with
	var/temperature_damage = 10000
	/// mobs with this trait won't burn.
	var/immunity_trait = TRAIT_LAVA_IMMUNE
	/// objects with these flags won't burn.
	var/immunity_resistance_flags = LAVA_PROOF
	/// the temperature that this turf will attempt to heat/cool gasses too in a heat exchanger, in kelvin
	var/lava_temperature = 5000

/turf/open/lava/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, FISHING_SPOT_PRESET_LAVALAND_LAVA)

/turf/open/lava/ex_act(severity, target)
	return

/turf/open/lava/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/lava/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/lava/acid_act(acidpwr, acid_volume)
	return FALSE

/turf/open/lava/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/lava/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/lava/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(burn_stuff(arrived))
		START_PROCESSING(SSobj, src)

/turf/open/lava/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		var/mob/living/L = gone
		if(!islava(get_step(src, direction)))
			REMOVE_TRAIT(L, TRAIT_PERMANENTLY_ONFIRE, TURF_TRAIT)
		if(!L.on_fire)
			L.update_fire()

/turf/open/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/process(delta_time)
	if(!burn_stuff(null, delta_time))
		STOP_PROCESSING(SSobj, src)

/turf/open/lava/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/lava/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, span_notice("You build a floor."))
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE

/turf/open/lava/rust_heretic_act()
	return FALSE

/turf/open/lava/singularity_act()
	return

/turf/open/lava/singularity_pull(S, current_size)
	return

/turf/open/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/lava/GetHeatCapacity()
	. = 700000

/turf/open/lava/GetTemperature()
	. = lava_temperature

/turf/open/lava/TakeTemperature(temp)

/turf/open/lava/attackby(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/stack/rods/lava))
		var/obj/item/stack/rods/lava/R = C
		var/obj/structure/lattice/lava/H = locate(/obj/structure/lattice/lava, src)
		if(H)
			to_chat(user, span_warning("There is already a lattice here!"))
			return
		if(R.use(1))
			to_chat(user, span_notice("You construct a lattice."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/lava(locate(x, y, z))
		else
			to_chat(user, span_warning("You need one rod to build a heatproof lattice."))
		return
	// Light a cigarette in the lava
	if(istype(C, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/ciggie = C
		if(ciggie.lit)
			to_chat(user, span_warning("The [ciggie.name] is already lit!"))
			return TRUE
		var/clumsy_modifier = HAS_TRAIT(user, TRAIT_CLUMSY) ? 2 : 1
		if(prob(25 * clumsy_modifier ))
			ciggie.light(span_warning("[user] expertly dips \the [ciggie.name] into [src], along with the rest of [user.p_their()] arm. What a dumbass."))
			var/obj/item/bodypart/affecting = user.get_active_hand()
			affecting?.receive_damage(burn = 90)
		else
			ciggie.light(span_rose("[user] expertly dips \the [ciggie.name] into [src], lighting it with the scorching heat of the planet. Witnessing such a feat is almost enough to make you cry."))
		return TRUE

/turf/open/lava/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile, /obj/structure/lattice/lava))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

///Generic return value of the can_burn_stuff() proc. Does nothing.
#define LAVA_BE_IGNORING 0
/// Another. Won't burn the target but will make the turf start processing.
#define LAVA_BE_PROCESSING 1
/// Burns the target and makes the turf process (depending on the return value of do_burn()).
#define LAVA_BE_BURNING 2

///Proc that sets on fire something or everything on the turf that's not immune to lava. Returns TRUE to make the turf start processing.
/turf/open/lava/proc/burn_stuff(atom/movable/to_burn, delta_time = 1)
	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (to_burn)
		thing_to_check = list(to_burn)
	for(var/atom/movable/burn_target as anything in thing_to_check)
		switch(can_burn_stuff(burn_target))
			if(LAVA_BE_IGNORING)
				continue
			if(LAVA_BE_BURNING)
				if(!do_burn(burn_target, delta_time))
					continue
		. = TRUE

/turf/open/lava/proc/can_burn_stuff(atom/movable/burn_target)
	if(burn_target.movement_type & (FLYING|FLOATING)) //you're flying over it.
		return LAVA_BE_IGNORING

	if(isobj(burn_target))
		if(burn_target.throwing) // to avoid gulag prisoners easily escaping, throwing only works for objects.
			return LAVA_BE_IGNORING
		var/obj/burn_obj = burn_target
		if((burn_obj.resistance_flags & immunity_resistance_flags))
			return LAVA_BE_PROCESSING
		return LAVA_BE_BURNING

	if (!isliving(burn_target))
		return LAVA_BE_IGNORING

	if(HAS_TRAIT(burn_target, immunity_trait))
		return LAVA_BE_PROCESSING
	var/mob/living/burn_living = burn_target
	var/atom/movable/burn_buckled = burn_living.buckled
	if(burn_buckled)
		if(burn_buckled.movement_type & (FLYING|FLOATING))
			return LAVA_BE_PROCESSING
		if(isobj(burn_buckled))
			var/obj/burn_buckled_obj = burn_buckled
			if(burn_buckled_obj.resistance_flags & immunity_resistance_flags)
				return LAVA_BE_PROCESSING
		else if(HAS_TRAIT(burn_buckled, immunity_trait))
			return LAVA_BE_PROCESSING

	if(iscarbon(burn_living))
		var/mob/living/carbon/burn_carbon = burn_living
		var/obj/item/clothing/burn_suit = burn_carbon.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		var/obj/item/clothing/burn_helmet = burn_carbon.get_item_by_slot(ITEM_SLOT_HEAD)
		if(burn_suit?.clothing_flags & LAVAPROTECT && burn_helmet?.clothing_flags & LAVAPROTECT)
			return LAVA_BE_PROCESSING

	return LAVA_BE_BURNING

#undef LAVA_BE_IGNORING
#undef LAVA_BE_PROCESSING
#undef LAVA_BE_BURNING

/turf/open/lava/proc/do_burn(atom/movable/burn_target, delta_time = 1)
	. = TRUE
	if(isobj(burn_target))
		var/obj/burn_obj = burn_target
		if(burn_obj.resistance_flags & ON_FIRE) // already on fire; skip it.
			return
		if(!(burn_obj.resistance_flags & FLAMMABLE))
			burn_obj.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
		if(burn_obj.resistance_flags & FIRE_PROOF)
			burn_obj.resistance_flags &= ~FIRE_PROOF
		if(burn_obj.get_armor_rating(FIRE) > 50) //obj with 100% fire armor still get slowly burned away.
			burn_obj.set_armor_rating(FIRE, 50)
		burn_obj.fire_act(temperature_damage, 1000 * delta_time)
		if(istype(burn_obj, /obj/structure/closet))
			var/obj/structure/closet/burn_closet = burn_obj
			for(var/burn_content in burn_closet.contents)
				burn_stuff(burn_content)
		return

	var/mob/living/burn_living = burn_target
	ADD_TRAIT(burn_living, TRAIT_PERMANENTLY_ONFIRE, TURF_TRAIT)
	burn_living.update_fire()

	burn_living.adjustFireLoss(lava_damage * delta_time)
	if(!QDELETED(burn_living)) //mobs turning into object corpses could get deleted here.
		burn_living.adjust_fire_stacks(lava_firestacks * delta_time)
		burn_living.ignite_mob()

/turf/open/lava/smooth
	name = "lava"
	baseturfs = /turf/open/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_LAVA
	canSmoothWith = SMOOTH_GROUP_FLOOR_LAVA
	underfloor_accessibility = 2 //This avoids strangeness when routing pipes / wires along catwalks over lava

/turf/open/lava/smooth/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/lava/smooth/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/lava/plasma
	name = "liquid plasma"
	desc = "A flowing stream of chilled liquid plasma. You probably shouldn't get in."
	icon_state = "liquidplasma"
	initial_gas_mix = "n2=82;plasma=24;TEMP=120"
	baseturfs = /turf/open/lava/plasma

	light_range = 3
	light_power = 0.75
	light_color = LIGHT_COLOR_PURPLE
	immunity_trait = TRAIT_SNOWSTORM_IMMUNE
	immunity_resistance_flags = FREEZE_PROOF
	lava_temperature = 100

/turf/open/lava/plasma/examine(mob/user)
	. = ..()
	. += span_info("Some <b>liquid plasma<b> could probably be scooped up with a <b>container</b>.")

/turf/open/lava/plasma/attackby(obj/item/I, mob/user, params)
	if(!I.is_open_container())
		return ..()
	if(!I.reagents.add_reagent(/datum/reagent/toxin/plasma, rand(5, 10)))
		to_chat(user, span_warning("[I] is full."))
		return
	user.visible_message(span_notice("[user] scoops some plasma from the [src] with [I]."), span_notice("You scoop out some plasma from the [src] using [I]."))

/turf/open/lava/plasma/do_burn(atom/movable/burn_target, delta_time = 1)
	. = TRUE
	if(isobj(burn_target))
		return FALSE // Does nothing against objects. Old code.

	var/mob/living/burn_living = burn_target
	burn_living.adjustFireLoss(2)
	if(QDELETED(burn_living))
		return
	burn_living.adjust_fire_stacks(20) //dipping into a stream of plasma would probably make you more flammable than usual
	burn_living.adjust_bodytemperature(-rand(50,65)) //its cold, man
	if(!ishuman(burn_living) || DT_PROB(65, delta_time))
		return
	var/mob/living/carbon/human/burn_human = burn_living
	var/datum/species/burn_species = burn_human.dna.species
	if(istype(burn_species, /datum/species/plasmaman) || istype(burn_species, /datum/species/android)) //ignore plasmamen/robotic species
		return

	var/list/plasma_parts = list()//a list of the organic parts to be turned into plasma limbs
	var/list/robo_parts = list()//keep a reference of robotic parts so we know if we can turn them into a plasmaman
	for(var/obj/item/bodypart/burn_limb as anything in burn_human.bodyparts)
		if(IS_ORGANIC_LIMB(burn_limb) && burn_limb.limb_id != SPECIES_PLASMAMAN) //getting every organic, non-plasmaman limb (augments/androids are immune to this)
			plasma_parts += burn_limb
		if(!IS_ORGANIC_LIMB(burn_limb))
			robo_parts += burn_limb

	burn_human.adjustToxLoss(15, required_biotype = MOB_ORGANIC) // This is from plasma, so it should obey plasma biotype requirements
	burn_human.adjustFireLoss(25)
	if(plasma_parts.len)
		var/obj/item/bodypart/burn_limb = pick(plasma_parts) //using the above-mentioned list to get a choice of limbs
		burn_human.emote("scream")
		var/obj/item/bodypart/plasmalimb
		switch(burn_limb.body_zone) //get plasmaman limb to swap in
			if(BODY_ZONE_L_ARM)
				plasmalimb = new /obj/item/bodypart/arm/left/plasmaman
			if(BODY_ZONE_R_ARM)
				plasmalimb = new /obj/item/bodypart/arm/right/plasmaman
			if(BODY_ZONE_L_LEG)
				plasmalimb = new /obj/item/bodypart/leg/left/plasmaman
			if(BODY_ZONE_R_LEG)
				plasmalimb = new /obj/item/bodypart/leg/right/plasmaman
			if(BODY_ZONE_CHEST)
				plasmalimb = new /obj/item/bodypart/chest/plasmaman
			if(BODY_ZONE_HEAD)
				plasmalimb = new /obj/item/bodypart/head/plasmaman
		burn_human.del_and_replace_bodypart(plasmalimb)
		burn_human.update_body_parts()
		burn_human.emote("scream")
		burn_human.visible_message(span_warning("[burn_human]'s [burn_limb.plaintext_zone] melts down to the bone!"), \
			span_userdanger("You scream out in pain as your [burn_limb.plaintext_zone] melts down to the bone, leaving an eerie plasma-like glow where flesh used to be!"))
	if(!plasma_parts.len && !robo_parts.len) //a person with no potential organic limbs left AND no robotic limbs, time to turn them into a plasmaman
		burn_human.ignite_mob()
		burn_human.set_species(/datum/species/plasmaman)
		burn_human.visible_message(span_warning("[burn_human] bursts into a brilliant purple flame as [burn_human.p_their()] entire body is that of a skeleton!"), \
			span_userdanger("Your senses numb as all of your remaining flesh is turned into a purple slurry, sloshing off your body and leaving only your bones to show in a vibrant purple!"))

//mafia specific tame happy plasma (normal atmos, no slowdown)
/turf/open/lava/plasma/mafia
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/lava/plasma/mafia
	slowdown = 0
