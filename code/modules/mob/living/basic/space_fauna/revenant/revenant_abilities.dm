#define REVENANT_DEFILE_MIN_DAMAGE 30
#define REVENANT_DEFILE_MAX_DAMAGE 50

//Transmit: the revenant's only direct way to communicate. Sends a single message silently to a single mob
/datum/action/cooldown/spell/list_target/telepathy/revenant
	name = "Revenant Transmit"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"

	telepathy_span = "revennotice"
	bold_telepathy_span = "revenboldnotice"

	antimagic_flags = MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND

/datum/action/cooldown/spell/list_target/telepathy/revenant/get_list_targets(atom/center, target_radius = 7)
	if(!istype(center, /mob/living/basic/revenant))
		return ..()
	var/mob/living/basic/revenant/revenant = center
	if(!revenant.dormant)
		return ..()
	return ..(get_turf(revenant), 2)

/datum/action/cooldown/spell/aoe/revenant
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	button_icon = 'icons/mob/actions/actions_revenant.dmi'

	antimagic_flags = MAGIC_RESISTANCE_HOLY
	spell_requirements = NONE

	/// How much essence it costs to unlock
	var/unlock_amount = 100
	/// How much essence it costs to use
	var/cast_amount = 50
	/// How long it reveals the revenant
	var/reveal_duration = 8 SECONDS
	// How long it stuns the revenant
	var/stun_duration = 2 SECONDS

/datum/action/cooldown/spell/aoe/revenant/New(Target)
	. = ..()
	AddComponent(/datum/component/revenant_ability, \
		unlock_amount = unlock_amount, \
		cast_amount = cast_amount, \
		reveal_duration = reveal_duration, \
		stun_duration = stun_duration, \
	)

/datum/action/cooldown/spell/aoe/revenant/get_things_to_cast_on(atom/center)
	return RANGE_TURFS(aoe_radius, center)

/datum/action/cooldown/spell/aoe/revenant/vv_edit_var(var_name, var_value)
	. = ..()
	// gross getcomp, but this is solely to make life easier for badmins/debug. sue me
	var/datum/component/revenant_ability/rev_comp = GetComponent(/datum/component/revenant_ability)
	switch(var_name)
		if(NAMEOF(src, unlock_amount))
			rev_comp.set_unlock_amount(var_value)
		if(NAMEOF(src, cast_amount))
			rev_comp.set_cast_amount(var_value)
		if(NAMEOF(src, reveal_duration), NAMEOF(src, stun_duration))
			rev_comp.set_durations(reveal_duration, stun_duration)

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/datum/action/cooldown/spell/aoe/revenant/overload
	name = "Overload Lights"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	button_icon_state = "overload_lights"
	cooldown_time = 20 SECONDS

	aoe_radius = 5
	unlock_amount = 25
	cast_amount = 40
	stun_duration = 3 SECONDS

	/// The range the shocks from the lights go
	var/shock_range = 2
	/// The damage the shocks from the lights do
	var/shock_damage = 15

/datum/action/cooldown/spell/aoe/revenant/overload/cast_on_thing_in_aoe(turf/victim, mob/living/basic/revenant/caster)
	for(var/obj/machinery/light/light in victim)
		if(!light.on)
			continue

		light.visible_message(span_boldwarning("[light] suddenly flares brightly and begins to spark!"))
		do_sparks(4, FALSE, light)
		new /obj/effect/temp_visual/revenant(get_turf(light))
		addtimer(CALLBACK(src, PROC_REF(overload_shock), light, caster), 2 SECONDS)

/datum/action/cooldown/spell/aoe/revenant/overload/proc/overload_shock(obj/machinery/light/to_shock, mob/living/basic/revenant/caster)
	flick("[to_shock.base_state]2", to_shock)
	for(var/mob/living/carbon/human/human_mob in view(shock_range, to_shock))
		if(human_mob == caster)
			continue
		to_shock.Beam(human_mob, icon_state = "purple_lightning", time = 0.5 SECONDS)
		if(!human_mob.can_block_magic(antimagic_flags))
			human_mob.electrocute_act(shock_damage, to_shock, flags = SHOCK_NOGLOVES)

		do_sparks(4, FALSE, human_mob)
		playsound(human_mob, 'sound/machines/defib/defib_zap.ogg', 50, TRUE, -1)

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/datum/action/cooldown/spell/aoe/revenant/defile
	name = "Defile"
	desc = "Twists and corrupts the nearby area as well as dispelling holy auras on floors."
	button_icon_state = "defile"
	cooldown_time = 15 SECONDS
	aoe_radius = 4
	unlock_amount = 10
	cast_amount = 30
	reveal_duration = 4 SECONDS
	stun_duration = 2 SECONDS

/datum/action/cooldown/spell/aoe/revenant/defile/cast_on_thing_in_aoe(turf/target_turf, mob/living/basic/revenant/caster)
	/// causes the purple sparks defile animation on the turf
	var/turf_was_defiled = FALSE

	// dispel
	for(var/obj/effect/blessing/blessing in target_turf)
		turf_was_defiled = TRUE
		qdel(blessing)
	for(var/obj/effect/decal/cleanable/food/salt/salt in target_turf)
		turf_was_defiled = TRUE
		qdel(salt)

	// damage
	if(!isplatingturf(target_turf) && !istype(target_turf, /turf/open/floor/engine/cult) && isfloorturf(target_turf) && prob(15))
		var/turf/open/floor/floor = target_turf
		if(floor.overfloor_placed && floor.floor_tile)
			new floor.floor_tile(floor)
		floor.broken = 0
		floor.burnt = 0
		floor.make_plating(TRUE)
	for(var/obj/structure/window/window in target_turf)
		if(window.get_integrity() > REVENANT_DEFILE_MAX_DAMAGE)
			window.take_damage(rand(REVENANT_DEFILE_MIN_DAMAGE, REVENANT_DEFILE_MAX_DAMAGE))
		if(window.fulltile)
			new /obj/effect/temp_visual/revenant/cracks(window.loc)

	// rust
	if(target_turf.type == /turf/closed/wall && prob(15) && !HAS_TRAIT(target_turf, TRAIT_RUSTY))
		turf_was_defiled = TRUE
		target_turf.AddElement(/datum/element/rust)
	if(target_turf.type == /turf/closed/wall/r_wall && prob(10) && !HAS_TRAIT(target_turf, TRAIT_RUSTY))
		turf_was_defiled = TRUE
		target_turf.AddElement(/datum/element/rust)

	// alchemy
	for(var/obj/machinery/shower/cursed_shower in target_turf)
		turf_was_defiled = TRUE
		cursed_shower.has_water_reclaimer = FALSE
		cursed_shower.reagents.remove_all(1, relative=TRUE)
		cursed_shower.reagents.add_reagent(/datum/reagent/blood, initial(cursed_shower.reagent_capacity))
		if(prob(50))
			cursed_shower.intended_on = TRUE
			cursed_shower.update_actually_on(TRUE)
	for(var/obj/item/reagent_containers/cursed_container in target_turf)
		if(!cursed_container.is_open_container())
			continue
		if(!cursed_container.reagents.has_reagent(/datum/reagent/consumable/ethanol, check_subtypes=TRUE))
			continue

		turf_was_defiled = TRUE
		var/booze_amount = cursed_container.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol, type_check=REAGENT_PARENT_TYPE)
		cursed_container.reagents.remove_reagent(/datum/reagent/consumable/ethanol, booze_amount, include_subtypes=TRUE)
		cursed_container.reagents.add_reagent(/datum/reagent/blood, booze_amount)
		cursed_container.update_appearance()
	for(var/obj/item/food/cursed_food in target_turf)
		if(cursed_food.trash_type)
			continue // the package protects it
		var/datum/component/germ_sensitive/germs = cursed_food.GetComponent(/datum/component/germ_sensitive)
		germs?.expose_to_germs()

	// opening
	for(var/obj/structure/closet/closet in target_turf.contents)
		if(closet.locked)
			continue

		turf_was_defiled = TRUE
		closet.open()
	for(var/obj/structure/bodycontainer/corpseholder in target_turf)
		turf_was_defiled = TRUE
		if(corpseholder.connected.loc == corpseholder)
			corpseholder.open()
	for(var/obj/machinery/dna_scannernew/dna in target_turf)
		turf_was_defiled = TRUE
		dna.open_machine()
	for(var/obj/machinery/cryo_cell/cursed_cryo_cell in target_turf)
		turf_was_defiled = TRUE
		cursed_cryo_cell.open_machine()
	for(var/obj/machinery/stasis/cursed_stasis in target_turf)
		turf_was_defiled = TRUE
		cursed_stasis.unbuckle_all_mobs()

	// obscure
	for(var/obj/item/reagent_containers/applicator/patch/cursed_patch in target_turf)
		turf_was_defiled = TRUE
		cursed_patch.name = /obj/item/reagent_containers/applicator/patch::name
		cursed_patch.desc = /obj/item/reagent_containers/applicator/patch::desc
		cursed_patch.icon_state = /obj/item/reagent_containers/applicator/patch::icon_state
		cursed_patch.update_appearance()
	for(var/obj/item/storage/pill_bottle/cursed_pill_bottle in target_turf)
		turf_was_defiled = TRUE
		cursed_pill_bottle.name = /obj/item/storage/pill_bottle::name
		cursed_pill_bottle.desc = /obj/item/storage/pill_bottle::desc
	for(var/obj/item/reagent_containers/applicator/pill/cursed_pill in target_turf)
		turf_was_defiled = TRUE
		cursed_pill.name = /obj/item/reagent_containers/applicator/pill::name
		cursed_pill.desc = /obj/item/reagent_containers/applicator/pill::desc
	for(var/obj/item/reagent_containers/cup/bottle/cursed_bottle in target_turf)
		turf_was_defiled = TRUE
		cursed_bottle.name = /obj/item/reagent_containers/cup/bottle::name
		cursed_bottle.desc = /obj/item/reagent_containers/cup/bottle::desc
	for(var/obj/item/reagent_containers/syringe/cursed_syringe in target_turf)
		turf_was_defiled = TRUE
		cursed_syringe.name = /obj/item/reagent_containers/syringe::name
		cursed_syringe.desc = /obj/item/reagent_containers/syringe::desc
	for(var/obj/item/reagent_containers/hypospray/medipen/cursed_medipen in target_turf)
		turf_was_defiled = TRUE
		// the default medipen subtype is epinephrine so we need to use generic hardcoded name/desc
		cursed_medipen.name = "medipen"
		cursed_medipen.desc = "A rapid and safe way to inject reagents into patients for personnel without advanced medical knowledge."
	for(var/obj/item/reagent_containers/medigel/cursed_medigel in target_turf)
		turf_was_defiled = TRUE
		cursed_medigel.name = /obj/item/reagent_containers/medigel::name
		cursed_medigel.desc = /obj/item/reagent_containers/medigel::desc
		cursed_medigel.icon_state = /obj/item/reagent_containers/medigel::icon_state
		cursed_medigel.update_appearance()
	for(var/obj/item/reagent_containers/spray/cursed_spray in target_turf)
		turf_was_defiled = TRUE
		cursed_spray.name = /obj/item/reagent_containers/spray::name
		cursed_spray.desc = /obj/item/reagent_containers/spray::desc
		cursed_spray.icon_state = /obj/item/reagent_containers/spray::icon_state
		cursed_spray.update_appearance()
	for(var/obj/item/dnainjector/cursed_dnainjector in target_turf)
		turf_was_defiled = TRUE
		cursed_dnainjector.name = /obj/item/dnainjector::name
		cursed_dnainjector.desc = /obj/item/dnainjector::desc
	for(var/obj/item/reagent_containers/blood/cursed_blood in target_turf)
		turf_was_defiled = TRUE
		cursed_blood.name = /obj/item/reagent_containers/blood::name
		cursed_blood.desc = /obj/item/reagent_containers/blood::desc
	for(var/obj/machinery/portable_atmospherics/canister/cursed_canister in target_turf)
		turf_was_defiled = TRUE
		cursed_canister.name = /obj/machinery/portable_atmospherics/canister::name
		cursed_canister.desc = /obj/machinery/portable_atmospherics/canister::desc
		cursed_canister.icon_state = /obj/machinery/portable_atmospherics/canister::icon_state
		cursed_canister.base_icon_state = /obj/machinery/portable_atmospherics/canister::icon_state
		cursed_canister.set_greyscale(/obj/machinery/portable_atmospherics/canister::greyscale_colors, /obj/machinery/portable_atmospherics/canister::greyscale_config)
		//cursed_canister.update_appearance()

	for(var/obj/item/storage/lockbox/order/cursed_order in target_turf)
		turf_was_defiled = TRUE
		cursed_order.name = initial(cursed_order.name) // initial() is fine since we just want to remove the cargo info
	for(var/obj/structure/closet/crate/cursed_crate in target_turf)
		turf_was_defiled = TRUE
		cursed_crate.name = initial(cursed_crate.name)

	// spooky
	for(var/obj/machinery/light/light in target_turf)
		light.flicker(rand(3, 5))
	for(var/obj/structure/mirror/mirror in target_turf)
		if(istype(mirror, /obj/structure/mirror/magic))
			continue
		turf_was_defiled = TRUE
		mirror.atom_break("magic")

	if(turf_was_defiled)
		new /obj/effect/temp_visual/revenant(target_turf)

//Malfunction: Makes bad stuff happen to robots and machines.
/datum/action/cooldown/spell/aoe/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	button_icon_state = "malfunction"
	cooldown_time = 20 SECONDS

	aoe_radius = 4
	cast_amount = 60
	unlock_amount = 125

// A note to future coders: do not replace this with an EMP because it will wreck malf AIs and everyone will hate you.
/datum/action/cooldown/spell/aoe/revenant/malfunction/cast_on_thing_in_aoe(turf/victim, mob/living/basic/revenant/caster)
	for(var/mob/living/basic/bot/bot in victim)
		if(!(bot.bot_access_flags & BOT_COVER_EMAGGED))
			new /obj/effect/temp_visual/revenant(bot.loc)
			bot.bot_access_flags &= ~BOT_COVER_LOCKED
			bot.bot_access_flags |= BOT_COVER_MAINTS_OPEN
			bot.emag_act(caster)
	for(var/mob/living/carbon/human/human in victim)
		if(human == caster)
			continue
		if(human.can_block_magic(antimagic_flags))
			continue
		to_chat(human, span_revenwarning("You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")]."))
		new /obj/effect/temp_visual/revenant(human.loc)
		human.emp_act(EMP_HEAVY)
	for(var/obj/thing in victim)
		//Doesn't work on SMES and APCs, to prevent kekkery.
		if(istype(thing, /obj/machinery/power/apc) || istype(thing, /obj/machinery/power/smes))
			continue
		if(prob(20))
			if(prob(50))
				new /obj/effect/temp_visual/revenant(thing.loc)
			thing.emag_act(caster)
	// Only works on cyborgs, not AI!
	for(var/mob/living/silicon/robot/cyborg in victim)
		playsound(cyborg, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		new /obj/effect/temp_visual/revenant(cyborg.loc)
		cyborg.spark_system.start()
		cyborg.emp_act(EMP_HEAVY)

//Blight: Infects nearby humans and in general messes living stuff up.
/datum/action/cooldown/spell/aoe/revenant/blight
	name = "Blight"
	desc = "Causes nearby living things to waste away."
	button_icon_state = "blight"
	cooldown_time = 20 SECONDS

	aoe_radius = 3
	cast_amount = 50
	unlock_amount = 75

/datum/action/cooldown/spell/aoe/revenant/blight/cast_on_thing_in_aoe(turf/victim, mob/living/basic/revenant/caster)
	for(var/mob/living/mob in victim)
		if(mob == caster)
			continue
		if(mob.can_block_magic(antimagic_flags))
			to_chat(caster, span_warning("The spell had no effect on [mob]!"))
			continue
		new /obj/effect/temp_visual/revenant(mob.loc)
		if(iscarbon(mob))
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				H.set_haircolor("#1d2953", override = TRUE) //will be reset when blight is cured
				var/blightfound = FALSE
				for(var/datum/disease/revblight/blight in H.diseases)
					blightfound = TRUE
					if(blight.stage < 5)
						blight.stage++
				if(!blightfound)
					H.ForceContractDisease(new /datum/disease/revblight(), FALSE, TRUE)
					to_chat(H, span_revenminor("You feel [pick("suddenly sick", "a surge of nausea", "like your skin is <i>wrong</i>")]."))
			else
				if(mob.reagents)
					mob.reagents.add_reagent(/datum/reagent/toxin/plasma, 5)
		else
			mob.adjust_tox_loss(5)
	for(var/obj/structure/spacevine/vine in victim) //Fucking with botanists, the ability.
		vine.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(vine.loc)
		QDEL_IN(vine, 10)
	for(var/obj/structure/glowshroom/shroom in victim)
		shroom.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(shroom.loc)
		QDEL_IN(shroom, 10)
	for(var/obj/machinery/hydroponics/tray in victim)
		new /obj/effect/temp_visual/revenant(tray.loc)
		tray.set_pestlevel(rand(8, 10))
		tray.set_weedlevel(rand(8, 10))
		tray.set_toxic(rand(45, 55))

/datum/action/cooldown/spell/aoe/revenant/haunt_object
	name = "Haunt Object"
	desc = "Empower nearby objects to you with ghostly energy, causing them to attack nearby mortals. \
		Items closer to you are more likely to be haunted."
	button_icon_state = "r_haunt"
	max_targets = 7
	aoe_radius = 5

	unlock_amount = 30 // Similar to overload lights
	cast_amount = 50 // but has a longer lasting effect
	stun_duration = 3 SECONDS
	reveal_duration = 6 SECONDS

/datum/action/cooldown/spell/aoe/revenant/haunt_object/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/obj/item/nearby_item in range(aoe_radius, center))
		// Don't throw around anchored things or dense things
		// (Or things not on a turf but I am not sure if range can catch that)
		if(nearby_item.anchored || nearby_item.density || !isturf(nearby_item.loc))
			continue
		// Don't throw abstract things
		if(nearby_item.item_flags & ABSTRACT)
			continue
		// Don't throw things we can't see
		if(nearby_item.invisibility >= INVISIBILITY_REVENANT)
			continue
		// Don't throw things that are already throwing themself
		if(istype(nearby_item.ai_controller, /datum/ai_controller/haunted))
			continue

		things += nearby_item

	return things

/datum/action/cooldown/spell/aoe/revenant/haunt_object/cast_on_thing_in_aoe(obj/item/victim, mob/living/basic/revenant/caster)
	var/distance_from_caster = get_dist(get_turf(victim), get_turf(caster))
	var/chance_of_haunting = 150 * (1 / distance_from_caster)
	if(!prob(chance_of_haunting))
		return

	new /obj/effect/temp_visual/revenant(get_turf(victim))

	victim.AddComponent(/datum/component/haunted_item, \
		haunt_color = "#823abb", \
		haunt_duration = rand(1 MINUTES, 3 MINUTES), \
		aggro_radius = aoe_radius - 1, \
		spawn_message = span_revenwarning("[victim] begins to float and twirl into the air as it glows a ghastly purple!"), \
		despawn_message = span_revenwarning("[victim] falls back to the ground, stationary once more."), \
	)

//Vortex: Causes storage objects to dump their contents and nearby objects to get sucked into the center
/datum/action/cooldown/spell/aoe/revenant/vortex
	name = "Vortex"
	desc = "Causes nearby objects to dump their contents and get sucked towards your location."
	button_icon_state = "r_vortex"
	cooldown_time = 15 SECONDS
	aoe_radius = 1 // only dump contents close by
	unlock_amount = 45
	cast_amount = 30
	stun_duration = 2 SECONDS
	reveal_duration = 5 SECONDS

/datum/action/cooldown/spell/aoe/revenant/vortex/cast_on_thing_in_aoe(turf/target_turf, mob/living/basic/revenant/caster)
	for(var/obj/item/storage/cursed_storage in target_turf)
		if(cursed_storage.atom_storage?.locked)
			continue

		cursed_storage.emptyStorage()
		new /obj/effect/temp_visual/revenant(target_turf)

/datum/action/cooldown/spell/aoe/revenant/vortex/cast(atom/cast_on)
	movement_effect(cast_on)
	. = ..()

/datum/action/cooldown/spell/aoe/revenant/vortex/proc/movement_effect(atom/cast_on)
	goonchem_vortex(get_turf(cast_on), FALSE, 3)
	playsound(cast_on, 'sound/machines/woosh.ogg', 50, TRUE)

//Vortex: Throws nearby objects away with a large force
/datum/action/cooldown/spell/aoe/revenant/vortex/scatter
	name = "Scatter"
	desc = "Causes nearby objects to dump their contents and get thrown away from your location."
	button_icon_state = "r_scatter"
	cooldown_time = 25 SECONDS
	unlock_amount = 60
	cast_amount = 55
	stun_duration = 3 SECONDS
	reveal_duration = 5 SECONDS

/datum/action/cooldown/spell/aoe/revenant/vortex/scatter/movement_effect(atom/cast_on)
	goonchem_vortex(get_turf(cast_on), TRUE, 5) // pushing is much stronger than pulling
	playsound(cast_on, 'sound/machines/hiss.ogg', 50, TRUE)

#undef REVENANT_DEFILE_MIN_DAMAGE
#undef REVENANT_DEFILE_MAX_DAMAGE
