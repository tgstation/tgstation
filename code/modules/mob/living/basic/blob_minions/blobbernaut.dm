/**
 * Player-piloted brute mob. Mostly just a "move and click" kind of guy.
 * Has a variant which takes damage when away from blob tiles
 */
/mob/living/basic/blob_minion/blobbernaut
	name = "blobbernaut"
	desc = "A hulking, mobile chunk of blobmass."
	icon_state = "blobbernaut"
	base_icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	health = BLOBMOB_BLOBBERNAUT_HEALTH
	maxHealth = BLOBMOB_BLOBBERNAUT_HEALTH
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_SOLO_LOWER
	melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_SOLO_UPPER
	melee_attack_cooldown = CLICK_CD_MELEE
	obj_damage = BLOBMOB_BLOBBERNAUT_DMG_OBJ
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/effects/blob/blobattack.ogg'
	verb_say = "gurgles"
	verb_ask = "demands"
	verb_exclaim = "roars"
	verb_yell = "bellows"
	pressure_resistance = 50
	mob_size = MOB_SIZE_LARGE
	ai_controller = /datum/ai_controller/basic_controller/blobbernaut
	loot = null
	///The HUD given to blobbernauts, updated by the Blob itself
	var/atom/movable/screen/healths/blob/overmind/overmind_hud
	///The overlay for veins.
	var/mutable_appearance/vein_overlay
	///The overlay for our eyes
	var/mutable_appearance/eyes_overlay
	///emissive eyes
	var/static/mutable_appearance/eyes_emissive

/mob/living/basic/blob_minion/blobbernaut/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBBERNAUT, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/damage_threshold, 10)

	var/static/list/food_types = list(
		/obj/item/food/egg,
		/obj/item/food/rawegg,
		/obj/item/food/friedegg,
		/obj/item/food/boiledegg,
		/obj/item/flashlight/flare,
		/obj/item/reagent_containers/cup/soda_cans/shamblers,

	)
	AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 25, bonus_tame_chance = 15)
	update_appearance()


/mob/living/basic/blob_minion/blobbernaut/Destroy()
	QDEL_NULL(overmind_hud)
	return ..()

/mob/living/basic/blob_minion/blobbernaut/death(gibbed)
	flick("[icon_state]_death", src)
	playsound(src, 'sound/mobs/non-humanoids/blobmob/blobbernaut_death.ogg', 100, TRUE)
	update_overlays()
	return ..()

/mob/living/basic/blob_minion/blobbernaut/create_mob_hud()
	. = ..()
	if(!.)
		return
	overmind_hud = new(null, hud_used)
	hud_used.infodisplay += overmind_hud
	hud_used.show_hud(hud_used.hud_version)

/mob/living/basic/blob_minion/blobbernaut/on_strain_updated(mob/eye/blob/overmind, datum/blobstrain/new_strain)
	. = ..()
	if(new_strain)
		attack_verb_continuous = new_strain.blobbernaut_message
		melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_UPPER
		melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_LOWER
		vein_overlay?.color = new_strain.complementary_color
		eyes_overlay?.color = new_strain.complementary_color
		//revert independent blobbernauts to the pale sprite so they can be recoloured
		icon_dead = "[base_icon_state]_dead"
		icon_living = base_icon_state
		new_strain.RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, TYPE_PROC_REF(/datum/blobstrain/, blobbernaut_attack))
	else
		attack_verb_continuous = initial(attack_verb_continuous)
		melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_SOLO_UPPER
		melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_SOLO_LOWER
		//Our overmind has died and our veins turns a mournful amethyst to complement our pale strainless body.
		vein_overlay?.color = "#7d6eb4"
		eyes_overlay?.color = COLOR_WHITE
	update_appearance()

/mob/living/basic/blob_minion/blobbernaut/update_overlays()
	. = ..()
	if(!vein_overlay)
		vein_overlay = mutable_appearance(icon, "[base_icon_state]_veins", appearance_flags = RESET_COLOR | KEEP_APART)
		///Give it independent olive green veins until strain modifies it
		vein_overlay.color = COLOR_OLIVE_GREEN

	if(!eyes_overlay)
		eyes_overlay = mutable_appearance(icon, "[base_icon_state]_eyes", appearance_flags = RESET_COLOR | KEEP_APART)
		eyes_overlay.color = "#ffc90e" //blobber eye yellow

	if(!eyes_emissive)
		eyes_emissive = emissive_appearance(icon, "[base_icon_state]_eyes", src)

	if(stat != DEAD)
		. += vein_overlay
		. += eyes_overlay
		. += eyes_emissive

/// This variant is the one actually spawned by blob factories, takes damage when away from blob tiles
/mob/living/basic/blob_minion/blobbernaut/minion
	/// Is our factory dead?
	var/orphaned = FALSE

/mob/living/basic/blob_minion/blobbernaut/minion/Life(seconds_per_tick, times_fired)
	. = ..()
	if (!.)
		return FALSE
	var/damage_sources = 0
	var/list/blobs_in_area = range(2, src)

	if(!(locate(/obj/structure/blob) in blobs_in_area))
		damage_sources++

	if (orphaned)
		damage_sources++
	else
		var/particle_colour = atom_colours?[FIXED_COLOUR_PRIORITY] || COLOR_BLACK
		if (locate(/obj/structure/blob/special/core) in blobs_in_area)
			heal_overall_damage(maxHealth * BLOBMOB_BLOBBERNAUT_HEALING_CORE * seconds_per_tick)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src))
			heal_effect.color = particle_colour

		if (locate(/obj/structure/blob/special/node) in blobs_in_area)
			heal_overall_damage(maxHealth * BLOBMOB_BLOBBERNAUT_HEALING_NODE * seconds_per_tick)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src))
			heal_effect.color = particle_colour

	if (damage_sources == 0)
		return FALSE

	// take 2.5% of max health as damage when not near the blob or if the naut has no factory, 5% if both
	apply_damage(maxHealth * BLOBMOB_BLOBBERNAUT_HEALTH_DECAY * damage_sources * seconds_per_tick, damagetype = TOX) // We reduce brute damage

	//hopefully this sound won't get too annoying.
	if(prob(20))
		playsound(src, 'sound/items/weapons/sear.ogg', 5, vary = TRUE)

	//create aooearances for the naut damage effect
	var/mutable_appearance/naut_damage_overlay = mutable_appearance(icon, "[base_icon_state]_veins", appearance_flags = RESET_COLOR | KEEP_APART)

	//modify appearances to intitially have no effect
	naut_damage_overlay.color = vein_overlay.color

	//flick naut damage overlays
	var/atom/movable/flick_visual/naut_damage_animation = flick_overlay_view(naut_damage_overlay, seconds_per_tick)

	//make flick objects obey dirs
	naut_damage_animation.vis_flags |= VIS_INHERIT_DIR

	//animate the naut damage overlays to fade in the 180 vein hue shift and emsissive.
	animate(naut_damage_animation, time = seconds_per_tick / 2, easing = SINE_EASING, color = RotateHue(vein_overlay.color, 180))
	animate(time = seconds_per_tick / 2, easing = SINE_EASING, color = vein_overlay.color)

	return TRUE

/// Called by the blob creation power to give us a mind and a basic task orientation
/mob/living/basic/blob_minion/blobbernaut/minion/proc/assign_key(ckey, datum/blobstrain/blobstrain)
	key = ckey
	flick("blobbernaut_produce", src)
	health = maxHealth / 2 // Start out injured to encourage not beelining away from the blob
	SEND_SOUND(src, sound('sound/effects/blob/blobattack.ogg'))
	SEND_SOUND(src, sound('sound/effects/blob/attackblob.ogg'))
	to_chat(src, span_infoplain("You are powerful, hard to kill, and slowly regenerate near nodes and cores, [span_cult_large("but will slowly die if not near the blob")] or if the factory that made you is killed."))
	to_chat(src, span_infoplain("You can communicate with other blobbernauts and overminds <b>telepathically</b> by attempting to speak normally"))
	to_chat(src, span_infoplain("Your overmind's blob reagent is: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!"))
	to_chat(src, span_infoplain("The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> reagent [blobstrain.shortdesc ? "[blobstrain.shortdesc]" : "[blobstrain.description]"]"))

/// Called by our factory to inform us that it's not going to support us financially any more
/mob/living/basic/blob_minion/blobbernaut/minion/on_factory_destroyed()
	. = ..()
	orphaned = TRUE
	throw_alert("nofactory", /atom/movable/screen/alert/nofactory)

///brand new orange look to match the classic spore.
/mob/living/basic/blob_minion/blobbernaut/independent
	icon_state = "blobbernaut_independent"
	icon_living = "blobbernaut_independent"
	icon_dead = "blobbernaut_independent_dead"
