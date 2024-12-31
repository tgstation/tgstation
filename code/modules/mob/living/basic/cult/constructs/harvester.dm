/mob/living/basic/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "A long, thin construct built to herald Nar'Sie's rise. It'll be all over soon."
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 40
	health = 40
	sight = SEE_MOBS
	melee_damage_lower = 15
	melee_damage_upper = 20
	attack_verb_continuous = "butchers"
	attack_verb_simple = "butcher"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	construct_spells = list(
		/datum/action/cooldown/spell/aoe/area_conversion,
		/datum/action/cooldown/spell/forcewall/cult,
	)
	playstyle_string = "<B>You are a Harvester. You are incapable of directly killing humans, \
		but your attacks will remove their limbs: Bring those who still cling to this world \
		of illusion back to the Geometer so they may know Truth. Your form and any you are \
		pulling can pass through runed walls effortlessly.</B>"
	can_repair = TRUE
	slowed_by_drag = FALSE

/mob/living/basic/construct/harvester/Initialize(mapload)
	. = ..()
	grant_abilities()

/mob/living/basic/construct/harvester/proc/grant_abilities()
	AddElement(/datum/element/wall_walker, /turf/closed/wall/mineral/cult)
	AddComponent(\
		/datum/component/amputating_limbs,\
		surgery_time = 0,\
		surgery_verb = "slicing",\
		minimum_stat = CONSCIOUS,\
	)
	var/datum/action/innate/seek_prey/seek = new(src)
	seek.Grant(src)
	seek.Activate()

/// If the attack is a limbless carbon, abort the attack, paralyze them, and get a special message from Nar'Sie.
/mob/living/basic/construct/harvester/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	if(!iscarbon(attack_target))
		return ..()
	var/mob/living/carbon/carbon_target = attack_target

	for(var/obj/item/bodypart/limb as anything in carbon_target.bodyparts)
		if(limb.body_part == HEAD || limb.body_part == CHEST)
			continue
		return ..() //if any arms or legs exist, attack

	carbon_target.Paralyze(6 SECONDS)
	visible_message(span_danger("[src] knocks [carbon_target] down!"))
	if(theme == THEME_CULT)
		to_chat(src, span_cult_large("\"Bring [carbon_target.p_them()] to me.\""))

/datum/action/innate/seek_master
	name = "Seek your Master"
	desc = "You and your master share a soul-link that informs you of their location"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	buttontooltipstyle = "cult"
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "cult_mark"
	/// Where is nar nar? Are we even looking?
	var/tracking = FALSE
	/// The construct we're attached to
	var/mob/living/basic/construct/the_construct

/datum/action/innate/seek_master/Grant(mob/living/player)
	the_construct = player
	..()

/datum/action/innate/seek_master/Activate()
	var/datum/antagonist/cult/cult_status = owner.mind.has_antag_datum(/datum/antagonist/cult)
	if(!cult_status)
		return
	var/datum/objective/eldergod/summon_objective = locate() in cult_status.cult_team.objectives

	if(summon_objective.check_completion())
		the_construct.construct_master = cult_status.cult_team.blood_target

	if(!the_construct.construct_master)
		to_chat(the_construct, span_cult_italic("You have no master to seek!"))
		the_construct.seeking = FALSE
		return
	if(tracking)
		tracking = FALSE
		the_construct.seeking = FALSE
		to_chat(the_construct, span_cult_italic("You are no longer tracking your master."))
		return
	else
		tracking = TRUE
		the_construct.seeking = TRUE
		to_chat(the_construct, span_cult_italic("You are now tracking your master."))

/datum/action/innate/seek_prey
	name = "Seek the Harvest"
	desc = "None can hide from Nar'Sie, activate to track a survivor attempting to flee the red harvest!"
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	buttontooltipstyle = "cult"
	button_icon_state = "cult_mark"

/datum/action/innate/seek_prey/Activate()
	if(GLOB.cult_narsie == null)
		return
	var/mob/living/basic/construct/harvester/the_construct = owner

	if(the_construct.seeking)
		desc = "None can hide from Nar'Sie, activate to track a survivor attempting to flee the red harvest!"
		button_icon_state = "cult_mark"
		the_construct.seeking = FALSE
		to_chat(the_construct, span_cult_italic("You are now tracking Nar'Sie, return to reap the harvest!"))
		return

	if(!LAZYLEN(GLOB.cult_narsie.souls_needed))
		to_chat(the_construct, span_cult_italic("Nar'Sie has completed her harvest!"))
		return

	the_construct.construct_master = pick(GLOB.cult_narsie.souls_needed)
	var/mob/living/real_target = the_construct.construct_master //We can typecast this way because Narsie only allows /mob/living into the souls list
	to_chat(the_construct, span_cult_italic("You are now tracking your prey, [real_target.real_name] - harvest [real_target.p_them()]!"))
	desc = "Activate to track Nar'Sie!"
	button_icon_state = "sintouch"
	the_construct.seeking = TRUE

/mob/living/basic/construct/harvester/heretic
	name = "Rusted Harvester"
	real_name = "Rusted Harvester"
	desc = "A long, thin, decrepit construct originally built to herald Nar'Sie's rise, corrupted and rusted by the forces of the Mansus to spread its will instead."
	icon_state = "harvester"
	icon_living = "harvester"
	construct_spells = list(
		/datum/action/cooldown/spell/aoe/rust_conversion,
		/datum/action/cooldown/spell/pointed/rust_construction,
	)
	can_repair = FALSE
	slowed_by_drag = FALSE
	faction = list(FACTION_HERETIC)
	maxHealth = 45
	health = 45
	melee_damage_lower = 20
	melee_damage_upper = 25
	// Dim green
	lighting_cutoff_red = 10
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 5
	playstyle_string = span_bold("You are a Rusted Harvester, built to serve the Sanguine Apostate, twisted to work the will of the Mansus. You are fragile and weak, but you rend cultists (only) apart on each attack. Follow your Master's orders!")
	theme = THEME_HERETIC

/mob/living/basic/construct/harvester/heretic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_MANSUS_TOUCHED, REF(src))
	add_filter("rusted_harvester", 3, list("type" = "outline", "color" = COLOR_GREEN, "size" = 2, "alpha" = 40))
	RegisterSignal(src, COMSIG_MIND_TRANSFERRED, TYPE_PROC_REF(/datum/mind, enslave_mind_to_creator))
	RegisterSignal(src, COMSIG_MOB_ENSLAVED_TO, PROC_REF(link_master))

/mob/living/basic/construct/harvester/heretic/proc/link_master(mob/self, mob/master)
	src.construct_master = master
	RegisterSignal(construct_master, COMSIG_LIVING_DEATH, PROC_REF(on_master_death))
	SIGNAL_HANDLER

/mob/living/basic/construct/harvester/heretic/proc/on_master_death(mob/self, mob/master)
	SIGNAL_HANDLER
	to_chat(src, span_userdanger("Your link to the mansus suddenly snaps as your master [construct_master] perishes! Without [construct_master.p_their()] support, your body crumbles..."))
	visible_message(span_alert("[src] suddenly crumbles to dust!"))
	death()

/mob/living/basic/construct/harvester/heretic/attack_animal(mob/living/simple_animal/user, list/modifiers)
	// They're pretty fragile so this is probably necessary to prevent bullshit deaths.
	if(user == src)
		return
	return ..()

/mob/living/basic/construct/harvester/heretic/grant_abilities()
	AddElement(/datum/element/wall_walker, or_trait = TRAIT_RUSTY)
	AddElement(/datum/element/leeching_walk)
	AddComponent(\
		/datum/component/amputating_limbs,\
		surgery_time = 1.5 SECONDS,\
		surgery_verb = "slicing",\
		minimum_stat = CONSCIOUS,\
		pre_hit_callback = CALLBACK(src, PROC_REF(is_cultist_handler)),\
	)
	AddComponent(/datum/component/damage_aura,\
		range = 3,\
		brute_damage = 0.5,\
		burn_damage = 0.5,\
		toxin_damage = 0.5,\
		stamina_damage = 4,\
		simple_damage = 1.5,\
		immune_factions = list(FACTION_HERETIC),\
		damage_message = span_boldwarning("Your body wilts and withers as it comes near [src]'s aura."),\
		message_probability = 7,\
		current_owner = src,\
	)
	var/datum/action/innate/seek_master/heretic/seek = new(src)
	seek.Grant(src)
	seek.Activate()

// These aren't friends they're assholes
// Don't let them be near you!
/mob/living/basic/construct/harvester/heretic/Life(seconds_per_tick, times_fired)
	. = ..()
	if(!SPT_PROB(7, seconds_per_tick))
		return

	var/turf/adjacent = get_step(src, pick(GLOB.alldirs))
	// 90% chance to be directional, otherwise what we're on top of
	var/turf/open/land = (isopenturf(adjacent) && prob(90)) ? adjacent : get_turf(src)
	do_rust_heretic_act(land)

	if(prob(7))
		to_chat(src, span_notice("Eldritch energies emanate from your body."))

/mob/living/basic/construct/harvester/heretic/proc/is_cultist_handler(mob/victim)
	return IS_CULTIST(victim)

/datum/action/innate/seek_master/heretic
	name = "Seek your Master"
	desc = "Use your direct link to the Mansus to sense where your master is located via the arrow on the top-right of your HUD."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	tracking = TRUE

/datum/action/innate/seek_master/heretic/New(Target)
	. = ..()
	the_construct = Target
	the_construct.seeking = TRUE

// no real reason for most of this weird oldcode
/datum/action/innate/seek_master/Activate()
	return
