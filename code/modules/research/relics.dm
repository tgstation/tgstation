#define RELIC_PROTOTYPE "prototype"
#define RELIC_NECROTECH "necrotech"

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold? Maybe Research & Development could find out."
	icon = 'icons/obj/devices/artefacts.dmi'
	icon_state = "debug_artefact"
	/// The name this artefact will have when it's activated.
	var/real_name = "artefact"
	/// Has this artefact been activated?
	var/activated = FALSE
	/// What effect this artefact has when used. Randomly determined when activated.
	var/hidden_power
	/// Minimum possible cooldown.
	var/min_cooldown = 6 SECONDS
	/// Max possible cooldown.
	var/max_cooldown = 30 SECONDS
	/// Cooldown length. Randomly determined at activation if it isn't determined here.
	var/cooldown_timer
	/// What visual theme this artefact has. Current possible choices: "prototype", "necrotech"
	var/artifact_theme = RELIC_PROTOTYPE

	COOLDOWN_DECLARE(cooldown)

/obj/item/relic/Initialize(mapload)
	. = ..()
	random_themed_appearance()
	RegisterSignal(src, COMSIG_ITEM_OPENED_FROM_GIFT, PROC_REF(auto_reveal))

/obj/item/relic/proc/auto_reveal(...)
	SIGNAL_HANDLER
	reveal()

/obj/item/relic/proc/random_themed_appearance()
	var/themed_name_prefix
	var/themed_name_suffix
	if(artifact_theme == RELIC_PROTOTYPE)
		icon_state = "[RELIC_PROTOTYPE][rand(1, 9)]"
		themed_name_prefix = pick("experimental", "prototype", "artificial", "handcrafted", "ramshackle", "odd")
		themed_name_suffix = pick("device", "assembly", "gadget", "gizmo", "contraption", "machine", "widget", "object")
		real_name = "[pick(themed_name_prefix)] [pick(themed_name_suffix)]"
		name = "strange [pick(themed_name_suffix)]"
	if(artifact_theme == RELIC_NECROTECH)
		icon_state = "[RELIC_NECROTECH][rand(1, 6)]"
		themed_name_prefix = pick("dark", "bloodied", "unholy", "archeotechnological", "dismal", "ruined", "thrumming")
		themed_name_suffix = pick("instrument", "shard", "fetish", "bibelot", "trinket", "offering", "relic")
		real_name = "[pick(themed_name_prefix)] [pick(themed_name_suffix)]"
		name = "strange relic"
	update_appearance()

/obj/item/relic/lavaland
	name = "strange relic"
	artifact_theme = RELIC_NECROTECH

/obj/item/relic/proc/reveal()
	if(activated) //no rerolling
		return
	activated = TRUE
	name = real_name
	if(!cooldown_timer)
		cooldown_timer = rand(min_cooldown, max_cooldown)
	if(!hidden_power)
		if(artifact_theme == RELIC_PROTOTYPE)
			hidden_power = pick(
				PROC_REF(corgi_cannon),
				PROC_REF(cleaning_foam),
				PROC_REF(flashbanger),
				PROC_REF(summon_animals),
				PROC_REF(uncontrolled_teleport),
				PROC_REF(heat_and_explode),
				PROC_REF(rapid_self_dupe),
				PROC_REF(drink_dispenser),
				PROC_REF(tummy_ache),
				PROC_REF(charger),
				PROC_REF(hugger),
				PROC_REF(dimensional_shift),
				PROC_REF(disguiser),
			)
		if(artifact_theme == RELIC_NECROTECH)
			hidden_power = pick(
				PROC_REF(dimensional_shift),
				PROC_REF(summon_animals_monsters),
				PROC_REF(heat_and_explode),
				PROC_REF(t1_shield_holder),
				PROC_REF(t2_shield_holder),
				PROC_REF(uncontrolled_teleport),
				PROC_REF(uncontrolled_aoe_teleport),
				PROC_REF(charger),
				PROC_REF(place_rocks),
				PROC_REF(yeet_blood),
				PROC_REF(suck_blood),
				PROC_REF(cleaning_foam),
				PROC_REF(cleaning_foam_acid),
			)
	obj_flags |= UNIQUE_RENAME

/obj/item/relic/attack_self(mob/user)
	if(!activated)
		to_chat(user, span_notice("You aren't quite sure what this is. Maybe R&D knows what to do with it?"))
		return
	if(!COOLDOWN_FINISHED(src, cooldown))
		to_chat(user, span_warning("[src] does not react!"))
		return
	if(loc != user)
		return
	COOLDOWN_START(src, cooldown, cooldown_timer)
	call(src, hidden_power)(user)

/// Helper to spawn smoke somewhere
/obj/item/relic/proc/throw_smoke(turf/where)
	do_smoke(0, src, get_turf(where))

/// Helper to show a message to people around the relic
/obj/item/relic/proc/relic_message(message)
	var/atom/message_source = ismob(loc) ? loc : src
	message_source.visible_message(message)

// Artefact Powers \\

/// Throws a corgi somewhere
/obj/item/relic/proc/corgi_cannon(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/mob/living/basic/pet/dog/corgi/sad_corgi = new(get_turf(user))
	sad_corgi.throw_at(pick(oview(10,user)), 10, rand(3,8), callback = CALLBACK(src, PROC_REF(throw_smoke), sad_corgi))
	warn_admins(user, "Corgi Cannon", FALSE)

/// Spawns cleaning foam
/obj/item/relic/proc/cleaning_foam(mob/user)
	playsound(src, SFX_SPARKS, rand(25, 50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/chem_grenade/cleaner/spawned_foamer = new(get_turf(user))
	spawned_foamer.detonate()
	qdel(spawned_foamer)
	warn_admins(user, "Foam", FALSE)

/// Similar to cleaning foam but spawns the acid variant
/obj/item/relic/proc/cleaning_foam_acid(mob/user)
	playsound(src, SFX_SPARKS, rand(25, 50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/chem_grenade/ez_clean/spawned_foamer = new(get_turf(user))
	spawned_foamer.detonate()
	qdel(spawned_foamer)
	warn_admins(user, "Acid Foam", TRUE)
	if(prob(80))
		to_chat(user, span_warning("[src] melts apart!"))
		acid_melt()

/// Flashbangs anyone nearby
/obj/item/relic/proc/flashbanger(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/flashbang/spawned_flashbang = new(get_turf(user))
	spawned_flashbang.detonate()
	warn_admins(user, "Flash")

/// Summon a bunch of random animals, some of which are dangerous
/obj/item/relic/proc/summon_animals(mob/user)
	var/message = span_danger("[src] begins to shake, and in the distance the sound of rampaging animals arises!")
	visible_message(message)
	to_chat(user, message)
	var/static/list/valid_animals = list(
		/mob/living/basic/bear,
		/mob/living/basic/bee,
		/mob/living/basic/butterfly,
		/mob/living/basic/carp,
		/mob/living/basic/crab,
		/mob/living/basic/lizard,
		/mob/living/basic/mouse,
		/mob/living/basic/parrot,
		/mob/living/basic/pet/cat,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/pet/dog/pug,
		/mob/living/basic/pet/fox,
	)
	for(var/counter in 1 to rand(1, 25))
		var/animal_spawn = pick(valid_animals)
		var/mob/living/animal = new animal_spawn(get_turf(src))
		ADD_TRAIT(animal, TRAIT_SPAWNED_MOB, INNATE_TRAIT)
	warn_admins(user, "Mass Mob Spawn")
	if(prob(60))
		relic_message(span_warning("[src] falls apart!"))
		deconstruct(FALSE)

/// Version of summon_animals that spawns mostly lavaland monsters
/obj/item/relic/proc/summon_animals_monsters(mob/user)
	var/message = span_danger("[src] begins to shake, and in the distance the sound of roaring arises!")
	visible_message(message)
	to_chat(user, message)
	var/static/list/valid_monsters = list(
		/mob/living/basic/construct/artificer/hostile,
		/mob/living/basic/construct/juggernaut/hostile,
		/mob/living/basic/construct/proteon/hostile,
		/mob/living/basic/construct/wraith/hostile,
		/mob/living/basic/mining/brimdemon,
		/mob/living/basic/mining/goldgrub,
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/hivelord,
		/mob/living/basic/mining/ice_demon,
		/mob/living/basic/mining/legion,
		/mob/living/basic/mining/lobstrosity,
		/mob/living/basic/mining/watcher,
		/mob/living/basic/raptor/blue,
		/mob/living/basic/raptor/green,
		/mob/living/basic/raptor/purple,
		/mob/living/basic/raptor/red,
		/mob/living/basic/raptor/white,
		/mob/living/basic/raptor/yellow,
	)
	for(var/counter in 1 to rand(3, 9))
		var/animal_spawn = pick(valid_monsters)
		var/mob/living/animal = new animal_spawn(get_turf(src))
		ADD_TRAIT(animal, TRAIT_SPAWNED_MOB, INNATE_TRAIT)
	warn_admins(user, "Mass Mob Spawn (Monster)")
	if(prob(80))
		relic_message(span_warning("[src] falls apart!"))
		deconstruct(FALSE)

/// Spawns a bunch of mimics of the relic which also can spawn relics, but despawn shortly
/obj/item/relic/proc/rapid_self_dupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dummy_artifacts = list()
	for(var/counter in 1 to rand(5,10))
		var/obj/item/relic/duped = new type(get_turf(src))
		duped.name = name
		duped.desc = desc
		duped.real_name = real_name
		duped.hidden_power = hidden_power
		duped.activated = TRUE
		dummy_artifacts += duped
		duped.throw_at(pick(oview(7,get_turf(src))),10,1)
	QDEL_LIST_IN(dummy_artifacts, rand(1 SECONDS, 10 SECONDS))
	warn_admins(user, "Rapid duplicator", 0)

/// Explodes after a few seconds
/obj/item/relic/proc/heat_and_explode(mob/user)
	to_chat(user, span_danger("[src] begins to heat up!"))
	addtimer(CALLBACK(src, PROC_REF(blow_up), user), rand(3.5 SECONDS, 10 SECONDS))

/obj/item/relic/proc/blow_up(mob/user)
	if(loc == user)
		visible_message(span_notice("\The [src]'s top opens, releasing a powerful blast!"))
		explosion(src, heavy_impact_range = rand(1,5), light_impact_range = rand(1,5), flame_range = 2, flash_range = rand(1,5), adminlog = TRUE)
		warn_admins(user, "Explosion")
		deconstruct(FALSE) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/// Teleports the relic, and anyone holding it, to a random location nearby
/obj/item/relic/proc/uncontrolled_teleport(mob/user)
	to_chat(user, span_notice("[src] begins to vibrate!"))

	var/teleport_time = rand(1 SECONDS, 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(do_the_teleport), user), teleport_time)
	Shake(1, 1, teleport_time, 0.05 SECONDS)

/obj/item/relic/proc/do_the_teleport(mob/user)
	var/turf/userturf = get_turf(user)
	//Because Nuke Ops bringing this back on their shuttle, then looting the ERT area is 2fun4you!
	if(is_centcom_level(userturf.z))
		return
	var/to_teleport = ismovable(loc) ? loc : src
	visible_message(span_notice("[to_teleport] twists and bends, relocating itself!"))
	throw_smoke(get_turf(to_teleport))
	do_teleport(to_teleport, userturf, 8, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	throw_smoke(get_turf(to_teleport))
	warn_admins(user, "Teleport", FALSE)

/// Version of uncontrolled_teleport with cult theming, and that affects all nearby movables rather than just the relic
/obj/item/relic/proc/uncontrolled_aoe_teleport(mob/user)
	to_chat(user, span_notice("[src] begins to vibrate intensely!"))

	var/teleport_time = rand(1 SECONDS, 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(do_the_aoe_teleport), user), teleport_time)
	Shake(2, 2, teleport_time, 0.03 SECONDS)

/obj/item/relic/proc/do_the_aoe_teleport(mob/user)
	visible_message(span_notice("[src] twists and bends, relocating anything nearby!"))
	var/turf/teleturf = get_turf(src)
	for(var/atom/movable/nearby in view(2, teleturf))
		if(nearby.anchored || nearby.invisibility || HAS_TRAIT(nearby, TRAIT_UNDERFLOOR))
			continue
		if(isliving(nearby))
			var/mob/living/nearby_living = nearby
			if(nearby_living.can_block_magic(MAGIC_RESISTANCE_HOLY, 1))
				continue

		if(isliving(nearby))
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(nearby.loc, nearby.dir)
		else
			new /obj/effect/temp_visual/cult/sparks(nearby.loc)
		do_teleport(
			teleatom = nearby,
			destination = teleturf,
			precision = 5,
			asoundin = 'sound/effects/phasein.ogg',
			channel = TELEPORT_CHANNEL_CULT,
		)
		if(isliving(nearby))
			new /obj/effect/temp_visual/dir_setting/cult/phase(nearby.loc, nearby.dir)
		else
			new /obj/effect/temp_visual/cult/sparks(nearby.loc)

	warn_admins(user, "AOE Teleport")
	if(prob(30))
		relic_message(span_warning("[src] teleports away, never to be seen again!"))
		qdel(src)

// Creates a glass and fills it up with a drink.
/obj/item/relic/proc/drink_dispenser(mob/user)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/freebie = new(get_step_rand(user))
	playsound(freebie, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(5, TRUE, src, src)
	addtimer(CALLBACK(src, PROC_REF(dispense_drink), freebie), 0.5 SECONDS)

/obj/item/relic/proc/dispense_drink(obj/item/reagent_containers/cup/glass/glasser)
	playsound(glasser, 'sound/effects/phasein.ogg', rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	glasser.reagents.add_reagent(get_random_reagent_id(whitelist = subtypesof(/datum/reagent/consumable/ethanol)), rand(glasser.volume * 0.3, glasser.volume))
	throw_smoke(get_turf(glasser))

/// Scrambles your organs. 33% chance to delete after use.
/obj/item/relic/proc/tummy_ache(mob/user)
	new /obj/effect/temp_visual/circle_wave/bioscrambler/light(get_turf(src))
	to_chat(user, span_notice("Your stomach starts growling..."))
	addtimer(CALLBACK(src, PROC_REF(scrambliticus), user), rand(1 SECONDS, 3 SECONDS)) // throw it away!

/obj/item/relic/proc/scrambliticus(mob/user)
	new /obj/effect/temp_visual/circle_wave/bioscrambler/light(get_turf(src))
	playsound(src, 'sound/effects/magic/cosmic_energy.ogg', vol = 50, vary = TRUE)
	for(var/mob/living/carbon/nearby in range(2, get_turf(src))) //needs get_turf() to work
		nearby.bioscramble(name)
		playsound(nearby, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		throw_smoke(get_turf(nearby))
		to_chat(nearby, span_notice("You feel weird."))
	if(prob(33))
		relic_message(span_warning("[src] falls apart!"))
		deconstruct(FALSE)

/// Charges an item or two in your inventory. Also yourself.
/obj/item/relic/proc/charger(mob/living/user)
	to_chat(user, span_danger("You're recharged!"))
	var/stunner = 1.25 SECONDS
	if(iscarbon(user))
		var/mob/living/carbon/carboner = user
		carboner.electrocute_act(15, src, flags = SHOCK_NOGLOVES, stun_duration = stunner)
	else
		user.electrocute_act(15, src, flags = SHOCK_NOGLOVES)
	playsound(user, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	var/list/chargeable_items = user.get_all_cells(max_percent = 0.95) // otherwise the PDA always gets recharged

	lightning_fx(user, stunner)
	var/recharges = rand(1, 2)
	if(!length(chargeable_items))
		to_chat(user, span_notice("You have a strange feeling for a moment, but then it passes."))
		return
	while(length(chargeable_items) && recharges)
		recharges--
		var/obj/item/to_charge_base = pick_n_take(chargeable_items)
		var/obj/item/stock_parts/power_store/to_charge = chargeable_items[to_charge_base]
		to_charge.charge = to_charge.maxcharge
		to_charge_base.update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)
		to_chat(user, span_notice("[to_charge_base] feels energized!"))
		lightning_fx(to_charge_base, 0.8 SECONDS)

/obj/item/relic/proc/lightning_fx(atom/shocker, time)
	var/lightning = mutable_appearance('icons/effects/effects.dmi', "electricity3", layer = ABOVE_MOB_LAYER)
	shocker.add_overlay(lightning)
	addtimer(CALLBACK(src, PROC_REF(cut_the_overlay), shocker, lightning), time)

/obj/item/relic/proc/cut_the_overlay(atom/shocker, lightning)
	shocker.cut_overlay(lightning)

/// Hugs/shakes everyone in range!
/obj/item/relic/proc/hugger(mob/user)
	var/list/mob/living/carbon/huggeds = oviewers(3, user)
	for(var/mob/living/carbon/victim in huggeds)
		victim.help_shake_act(user, force_friendly = TRUE)
		new /obj/effect/temp_visual/heart(victim.loc)
	if(length(huggeds))
		to_chat(user, span_nicegreen("You feel friendly!"))
	else
		to_chat(user, pick(span_notice("You hug yourself, for some reason."), span_notice("You have a strange feeling for a moment, but then it passes.")))

/// Converts a 3x3 area into a random dimensional theme.
/obj/item/relic/proc/dimensional_shift(mob/user)
	var/new_theme_path = pick(subtypesof(/datum/dimension_theme))
	var/datum/dimension_theme/shifter = SSmaterials.dimensional_themes[new_theme_path]
	for(var/turf/shiftee in range(1, user))
		shifter.apply_theme(shiftee, show_effect = TRUE)
	// prevent *total* spam conversion
	min_cooldown += 2 SECONDS
	max_cooldown += 2 SECONDS

/// Replaces your clothing with a random costume, and your ID with a cardboard one.
/// TODO: make them part of the same kit (lobster hat, lobster suit)
/obj/item/relic/proc/disguiser(mob/user)
	if(!iscarbon(user))
		to_chat(user, span_notice("You have a strange feeling for a moment, but then it passes."))
		return

	if(prob(80)) // >:)
		ADD_TRAIT(user, TRAIT_NO_JUMPSUIT, REF(src)) // prevent dropping pockets & belt

	// magic trick!
	playsound(user, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	throw_smoke(user)

	// carbons always get a hat at least
	var/mob/living/carbon/carbonius = user
	//hat
	var/obj/item/clothing/head/costume/disguise_hat = roll_costume(ITEM_SLOT_HEAD, HIDEMASK)
	carbonius.dropItemToGround(carbonius.head)
	carbonius.equip_to_slot_or_del(disguise_hat, ITEM_SLOT_HEAD)
	if(!ishuman(carbonius))
		to_chat(user, span_notice("You have a peculiar feeling for a moment, but then it passes."))
		return

	var/mob/living/carbon/human/humerus = carbonius
	// uniform
	var/obj/item/clothing/under/costume/disguise_uniform = roll_costume(ITEM_SLOT_ICLOTHING)
	humerus.dropItemToGround(humerus.w_uniform)
	humerus.equip_to_slot_or_del(disguise_uniform, ITEM_SLOT_ICLOTHING)
	// suit
	var/obj/item/clothing/suit/costume/disguise_suit = roll_costume(ITEM_SLOT_OCLOTHING)
	humerus.dropItemToGround(humerus.wear_suit)
	humerus.equip_to_slot_or_del(disguise_suit, ITEM_SLOT_OCLOTHING)
	// id
	var/obj/item/card/cardboard/card_id = new()
	humerus.dropItemToGround(humerus.wear_id)
	humerus.equip_to_slot_or_del(card_id, ITEM_SLOT_ID)

	// edit the card to a random job & name
	if(!card_id)
		return
	card_id.scribbled_name = "[pick(GLOB.first_names)] [pick(GLOB.last_names)]"
	card_id.details_colors = list(ready_random_color(), ready_random_color(), ready_random_color())
	card_id.item_flags |= DROPDEL

	var/datum/id_trim/random_trim = pick(subtypesof(/datum/id_trim))
	random_trim = new random_trim()
	if(random_trim.trim_state && random_trim.assignment)
		card_id.scribbled_trim = replacetext(random_trim.trim_state, "trim_", "cardboard_")
	card_id.scribbled_assignment = random_trim.assignment
	card_id.update_appearance()
	REMOVE_TRAIT(user, TRAIT_NO_JUMPSUIT, REF(src))

/obj/item/relic/proc/roll_costume(slot, flagcheck)
	var/list/candidates = list()
	for(var/obj/item/costume as anything in GLOB.all_autodrobe_items)
		if(flagcheck && !(initial(costume.flags_inv) & flagcheck))
			continue
		if(slot && !(initial(costume.slot_flags) & slot))
			continue
		candidates |= costume
	var/obj/item/new_costume = pick(candidates)
	new_costume = new new_costume()
	new_costume.item_flags |= DROPDEL
	return new_costume

/// Makes the relic holder have a shield that blocks 3 common attacks
/obj/item/relic/proc/t1_shield_holder(mob/user)
	var/datum/component/shield = AddComponent( \
		/datum/component/shielded, \
		max_charges = 3, \
		recharge_start_delay = 0, \
		shield_inhand = TRUE, \
		show_charge_as_alpha = TRUE, \
		can_block_overwhelming = FALSE, \
		shield_icon_file = 'icons/effects/effects.dmi', \
		shield_icon = "at_shield1", \
		run_hit_callback = CALLBACK(src, PROC_REF(shield_hit)), \
	)
	light_system = OVERLAY_LIGHT
	var/datum/component/light = AddComponent( \
		/datum/component/overlay_lighting, \
		_range = 2.5, \
		_power = 1.5, \
		_color = COLOR_BIOLUMINESCENCE_YELLOW, \
		starts_on = TRUE, \
	)

	addtimer(CALLBACK(src, PROC_REF(remove_shield), list(shield, light)), cooldown_timer * 0.5)
	add_filter("block_shield", 1, outline_filter(0, COLOR_BIOLUMINESCENCE_YELLOW), shield)
	transition_filter("block_shield", outline_filter(2, COLOR_BIOLUMINESCENCE_YELLOW), cooldown_timer * 0.5)

	relic_message(span_notice("[src] starts to glow a bright yellow!"))
	warn_admins(user, "Shield", FALSE)

/// Makes the relic holder have a shield that blocks 1 powerful attack
/obj/item/relic/proc/t2_shield_holder(mob/user)
	var/datum/component/shield = AddComponent( \
		/datum/component/shielded, \
		max_charges = 1, \
		recharge_start_delay = 0, \
		shield_inhand = TRUE, \
		show_charge_as_alpha = TRUE, \
		can_block_overwhelming = TRUE, \
		shield_icon_file = 'icons/effects/effects.dmi', \
		shield_icon = "at_shield2", \
		run_hit_callback = CALLBACK(src, PROC_REF(shield_hit)), \
	)
	light_system = OVERLAY_LIGHT
	var/datum/component/light = AddComponent( \
		/datum/component/overlay_lighting, \
		_range = 3, \
		_power = 1.5, \
		_color = COLOR_BIOLUMINESCENCE_YELLOW, \
		starts_on = TRUE, \
	)

	addtimer(CALLBACK(src, PROC_REF(remove_shield), list(shield, light)), cooldown_timer * 0.5)
	add_filter("block_shield", 1, outline_filter(0, COLOR_BIOLUMINESCENCE_YELLOW), shield)
	transition_filter("block_shield", outline_filter(2, COLOR_BIOLUMINESCENCE_YELLOW), cooldown_timer * 0.5)

	relic_message(span_notice("[src] starts to glow a bright yellow!"))
	warn_admins(user, "Shield", FALSE)

/obj/item/relic/proc/shield_hit(mob/living/owner, attack_text, current_charges)
	playsound(src, 'sound/items/weapons/marauder.ogg', 20, TRUE, frequency = 1.25)
	owner.visible_message(span_danger("[owner]'s holds [src] up, blocking [attack_text] with a projected shield!"))
	if(current_charges <= 0)
		set_light_on(FALSE)
		relic_message(span_notice("[src] stops glowing."))
		remove_filter("block_shield")

/obj/item/relic/proc/remove_shield(list/cleanup_components)
	for(var/datum/component/comp as anything in cleanup_components)
		qdel(comp)
	light_system = initial(light_system)
	if(light_on)
		relic_message(span_notice("[src] stops glowing."))
	remove_filter("block_shield")

/// Places rock turfs around the relic
/obj/item/relic/proc/place_rocks(mob/user)
	relic_message(span_notice("A spire of rock erupts from the ground beneath [src]!"))
	playsound(src, 'sound/effects/rock/rock_break.ogg', 50, TRUE)
	var/turf/spawnloc = get_turf(src)
	for(var/turf/open/open_turf in RANGE_TURFS(rand(1, 2), spawnloc))
		var/turf/closed/mineral/asteroid/rock = open_turf.place_on_top(/turf/closed/mineral/asteroid)
		if(istype(rock))
			rock.name = "fragile rock"
			rock.weak_turf = TRUE
			rock.tool_mine_speed = 2 SECONDS
			rock.hand_mine_speed = 10 SECONDS
		for(var/mob/living/within_rock in rock)
			within_rock.Paralyze(1 SECONDS)
			within_rock.Knockdown(3 SECONDS)
			within_rock.apply_damage(10, BRUTE, BODY_ZONE_CHEST, blocked = within_rock.getarmor(BODY_ZONE_CHEST, MELEE), wound_bonus = 10, exposed_wound_bonus = 10)
			to_chat(within_rock, span_danger("You are smashed by [rock]!"))
	warn_admins(user, "Rocks", FALSE)
	if(prob(20))
		relic_message(span_warning("[src] crumbles into dust!"))
		deconstruct(FALSE)

/// User sprays out blood in all directions
/// Has a small chance of changing the power to suck_blood
/obj/item/relic/proc/yeet_blood(mob/living/user)
	var/yeet_time = rand(1 SECONDS, 3 SECONDS)
	add_filter("blood_outgoing", 1, outline_filter(0, COLOR_DARK))
	transition_filter("blood_outgoing", outline_filter(2, BLOOD_COLOR_RED), yeet_time)
	if(istype(user) && CAN_HAVE_BLOOD(user))
		to_chat(user, span_danger("[src] starts glowing an ominous red!"))
	else
		to_chat(user, span_danger("[src] starts glowing an ominous red..."))

	addtimer(CALLBACK(src, PROC_REF(actually_yeet_blood)), yeet_time)

/obj/item/relic/proc/actually_yeet_blood()
	var/mob/living/user = loc
	var/splatcount = 0
	if(istype(user) && CAN_HAVE_BLOOD(user) && !user.can_block_magic(MAGIC_RESISTANCE_HOLY, 1))
		for(var/splatdir in GLOB.alldirs)
			if(prob(splatcount * 5))
				continue
			var/strength = rand(2, 3)
			user.spray_blood(splatdir, strength)
			user.bleed(strength ** 2)
			splatcount += strength

	if(splatcount > 0)
		relic_message(span_warning("Blood sprays out from [src]!"))
		warn_admins(user, "Blood Dispersal", FALSE)
		playsound(src, 'sound/effects/wounds/blood3.ogg', 50, TRUE)
		if(prob(20))
			hidden_power = PROC_REF(suck_blood)
	else
		relic_message(span_warning("[src] pulses ominously, but nothing happens!"))

	transition_filter("blood_outgoing", outline_filter(0, COLOR_DARK), 1 SECONDS)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "blood_outgoing"), 2 SECONDS)

/// Nearby mobs transfer blood to the user
/// Has a small chance of changing the power to yeet_blood
/obj/item/relic/proc/suck_blood(mob/living/user)
	var/suck_time = rand(1 SECONDS, 3 SECONDS)
	add_filter("blood_incoming", 1, outline_filter(0, COLOR_DARK))
	transition_filter("blood_incoming", outline_filter(2, BLOOD_COLOR_RED), suck_time)
	if(istype(user) && CAN_HAVE_BLOOD(user))
		to_chat(user, span_danger("[src] starts glowing an ominous red!"))
	else
		to_chat(user, span_danger("[src] starts glowing an ominous red..."))

	addtimer(CALLBACK(src, PROC_REF(actually_suck_blood)), suck_time)

/obj/item/relic/proc/actually_suck_blood()
	var/mob/living/user = loc
	var/any_affected = FALSE
	if(istype(user) && CAN_HAVE_BLOOD(user) && !user.can_block_magic(MAGIC_RESISTANCE_HOLY, 1))
		for(var/mob/living/nearby in view(2, user))
			if(nearby == user || !CAN_HAVE_BLOOD(nearby) || nearby.can_block_magic(MAGIC_RESISTANCE_HOLY, 1))
				continue
			nearby.transfer_blood_to(user, rand(6, 10), ignore_low_blood = TRUE, ignore_incompatibility = TRUE, transfer_viruses = FALSE)
			to_chat(nearby, span_danger("You feel a sudden weakness as blood is drawn out of you [nearby.is_blind() ? "" : " and into [user]"]!"))
			any_affected = TRUE
			nearby.Beam(user, icon_state = "blood", time = 1 SECONDS)
			new /obj/effect/temp_visual/cult/sparks(nearby.loc)

	if(any_affected)
		playsound(src, 'sound/effects/magic/enter_blood.ogg', 50, TRUE)
		relic_message(span_warning("Blood from nearby creatures is drawn towards [src], and into [user]!"))
		warn_admins(user, "Blood Suck")
		if(prob(10))
			hidden_power = PROC_REF(yeet_blood)
	else
		relic_message(span_warning("[src] pulses ominously, but nothing happens!"))

	transition_filter("blood_incoming", outline_filter(0, COLOR_DARK), 1 SECONDS)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "blood_incoming"), 2 SECONDS)

/// Alerts admins on usage of dagnerous relics
/obj/item/relic/proc/warn_admins(mob/user, relic_type, priority = TRUE)
	var/turf/location = get_turf(src)
	var/log_msg = "[relic_type] relic used by [key_name(user)] in [AREACOORD(location)]"
	if(priority)
		message_admins("[relic_type] relic activated by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(location)]")
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")

// Subtypes that spawn revealed, primarily for debug/testing/badmin purposes
/obj/item/relic/revealed

/obj/item/relic/revealed/Initialize(mapload)
	. = ..()
	auto_reveal()

/obj/item/relic/lavaland

/obj/item/relic/lavaland/revealed/Initialize(mapload)
	. = ..()
	auto_reveal()

#undef RELIC_PROTOTYPE
#undef RELIC_NECROTECH
