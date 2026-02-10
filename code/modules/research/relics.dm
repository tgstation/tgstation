/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold? Maybe Research & Development could find out."
	icon = 'icons/obj/devices/artefacts.dmi'
	icon_state = "debug_artefact"
	//The name this artefact will have when it's activated.
	var/real_name = "artefact"
	//Has this artefact been activated?
	var/activated = FALSE
	//What effect this artefact has when used. Randomly determined when activated.
	var/hidden_power
	//Minimum possible cooldown.
	var/min_cooldown = 6 SECONDS
	//Max possible cooldown.
	var/max_cooldown = 30 SECONDS
	//Cooldown length. Randomly determined at activation if it isn't determined here.
	var/cooldown_timer
	COOLDOWN_DECLARE(cooldown)
	//What visual theme this artefact has. Current possible choices: "prototype", "necrotech"
	var/artifact_theme = "prototype"

/obj/item/relic/Initialize(mapload)
	. = ..()
	random_themed_appearance()

/obj/item/relic/proc/random_themed_appearance()
	var/themed_name_prefix
	var/themed_name_suffix
	if(artifact_theme == "prototype")
		icon_state = pick("prototype1", "prototype2", "prototype3", "prototype4", "prototype5", "prototype6", "prototype7", "prototype8","prototype9")
		themed_name_prefix = pick("experimental","prototype","artificial","handcrafted","ramshackle","odd")
		themed_name_suffix = pick("device","assembly","gadget","gizmo","contraption","machine","widget","object")
		real_name = "[pick(themed_name_prefix)] [pick(themed_name_suffix)]"
		name = "strange [pick(themed_name_suffix)]"
	if(artifact_theme == "necrotech")
		icon_state = pick("necrotech1", "necrotech2", "necrotech3", "necrotech4", "necrotech5", "necrotech6")
		themed_name_prefix = pick("dark","bloodied","unholy","archeotechnological","dismal","ruined","thrumming")
		themed_name_suffix = pick("instrument","shard","fetish","bibelot","trinket","offering","relic")
		real_name = "[pick(themed_name_prefix)] [pick(themed_name_suffix)]"
		name = "strange relic"
	update_appearance()

/obj/item/relic/lavaland
	name = "strange relic"
	artifact_theme = "necrotech"

/obj/item/relic/proc/reveal()
	if(activated) //no rerolling
		return
	activated = TRUE
	name = real_name
	if(!cooldown_timer)
		cooldown_timer = rand(min_cooldown, max_cooldown)
	if(!hidden_power)
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

/obj/item/relic/proc/throw_smoke(turf/where)
	do_smoke(0, src, get_turf(where))

// Artefact Powers \\

/obj/item/relic/proc/corgi_cannon(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/mob/living/basic/pet/dog/corgi/sad_corgi = new(get_turf(user))
	sad_corgi.throw_at(pick(oview(10,user)), 10, rand(3,8), callback = CALLBACK(src, PROC_REF(throw_smoke), sad_corgi))
	warn_admins(user, "Corgi Cannon", 0)

/obj/item/relic/proc/cleaning_foam(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/chem_grenade/cleaner/spawned_foamer = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
	spawned_foamer.detonate()
	qdel(spawned_foamer)
	warn_admins(user, "Foam", 0)

/obj/item/relic/proc/flashbanger(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/flashbang/spawned_flashbang = new/obj/item/grenade/flashbang(user.loc)
	spawned_flashbang.detonate()
	warn_admins(user, "Flash")

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
		to_chat(user, span_warning("[src] falls apart!"))
		qdel(src)

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

/obj/item/relic/proc/heat_and_explode(mob/user)
	to_chat(user, span_danger("[src] begins to heat up!"))
	addtimer(CALLBACK(src, PROC_REF(blow_up), user), rand(3.5 SECONDS, 10 SECONDS))

/obj/item/relic/proc/blow_up(mob/user)
	if(loc == user)
		visible_message(span_notice("\The [src]'s top opens, releasing a powerful blast!"))
		explosion(src, heavy_impact_range = rand(1,5), light_impact_range = rand(1,5), flame_range = 2, flash_range = rand(1,5), adminlog = TRUE)
		warn_admins(user, "Explosion")
		qdel(src) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/obj/item/relic/proc/uncontrolled_teleport(mob/user)
	to_chat(user, span_notice("[src] begins to vibrate!"))
	addtimer(CALLBACK(src, PROC_REF(do_the_teleport), user), rand(1 SECONDS, 3 SECONDS))

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
	warn_admins(user, "Teleport", 0)

// Creates a glass and fills it up with a drink.
/obj/item/relic/proc/drink_dispenser(mob/user)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/freebie = new(get_step_rand(user))
	playsound(freebie, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(5, TRUE, src, src)
	addtimer(CALLBACK(src, PROC_REF(dispense_drink), freebie), 0.5 SECONDS)

/obj/item/relic/proc/dispense_drink(obj/item/reagent_containers/cup/glass/glasser)
	playsound(glasser, 'sound/effects/phasein.ogg', rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	glasser.reagents.add_reagent(get_random_drink_id(), rand(glasser.volume * 0.3, glasser.volume))
	throw_smoke(get_turf(glasser))

// Scrambles your organs. 33% chance to delete after use.
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
		qdel(src)

// Charges an item or two in your inventory. Also yourself.
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

// Hugs/shakes everyone in range!
/obj/item/relic/proc/hugger(mob/user)
	var/list/mob/living/carbon/huggeds = oviewers(3, user)
	for(var/mob/living/carbon/victim in huggeds)
		victim.help_shake_act(user, force_friendly = TRUE)
		new /obj/effect/temp_visual/heart(victim.loc)
	if(length(huggeds))
		to_chat(user, span_nicegreen("You feel friendly!"))
	else
		to_chat(user, pick(span_notice("You hug yourself, for some reason."), span_notice("You have a strange feeling for a moment, but then it passes.")))

// Converts a 3x3 area into a random dimensional theme.
/obj/item/relic/proc/dimensional_shift(mob/user)
	var/new_theme_path = pick(subtypesof(/datum/dimension_theme))
	var/datum/dimension_theme/shifter = SSmaterials.dimensional_themes[new_theme_path]
	for(var/turf/shiftee in range(1, user))
		shifter.apply_theme(shiftee, show_effect = TRUE)
	// prevent *total* spam conversion
	min_cooldown += 2 SECONDS
	max_cooldown += 2 SECONDS

// Replaces your clothing with a random costume, and your ID with a cardboard one.
// TODO: make them part of the same kit (lobster hat, lobster suit)
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

	var/datum/id_trim/random_trim = pick(subtypesof(/datum/id_trim)) // this can pick silly things
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

//Admin Warning proc for relics
/obj/item/relic/proc/warn_admins(mob/user, relic_type, priority = 1)
	var/turf/location = get_turf(src)
	var/log_msg = "[relic_type] relic used by [key_name(user)] in [AREACOORD(location)]"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[relic_type] relic activated by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(location)]")
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")
