/datum/round_event_control/venom
	name = "Spawn Venom"
	typepath = /datum/round_event/ghost_role/venom
	weight = 50
	max_occurrences = 1
	min_players = 10
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns venom."

/datum/round_event/ghost_role/venom
	minimum_required = 1
	role_name = "Venom"
	announce_when = 10

/datum/round_event/ghost_role/venom/spawn_role()
	var/list/candidates = get_candidates(ROLE_PAI, ROLE_PAI)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/selected = pick(candidates)
	var/key = selected.key
	meteor = spawn_meteor(list(/obj/effect/meteor/venom))
	var/mob/living/simple_animal/hostile/venom/venom = new(meteor)
	venom.key = key
	venom.mind.set_assigned_role(SSjob.GetJobType(/datum/job/venom))
	venom.mind.special_role = ROLE_VENOM
	venom.mind.add_antag_datum(/datum/antagonist/venom)
	message_admins("[ADMIN_LOOKUPFLW(venom)] has been made into Venom by an event.")
	venom.log_message("was spawned as Venom by an event.", LOG_GAME)
	spawned_mobs += venom
	return SUCCESSFUL_SPAWN

/obj/effect/meteor/venom
	name = "weird meteor"
	icon = 'icons/mob/nonhuman-player/venom.dmi'
	icon_state = "meteor"
	hits = 5
	heavy = TRUE
	dropamt = 0
	threat = 100

/obj/effect/meteor/venom/meteor_effect()
	. = ..()
	for(var/atom/movable/atom as anything in src)
		atom.forceMove(loc)

/datum/job/venom
	title = ROLE_VENOM

/datum/antagonist/venom
	name = "\improper Venom"
	antagpanel_category = "Venom"
	job_rank = ROLE_VENOM
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "VENOM- VENOM VEN VENOM!!"

/datum/antagonist/venom/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/venom/greet()
	. = ..()
	owner.announce_objectives()
	to_chat(owner.current, span_danger("You are Venom! You need to find a suitable host to start your spree. They need to be wearing a MODsuit."))
	to_chat(owner.current, span_danger("By using your tentacle on dead bodies with souls, your power grows. Power is used for the strength of your abilities."))

/datum/antagonist/venom/forge_objectives()
	var/datum/objective/new_objective = new /datum/objective
	new_objective.owner = owner
	new_objective.explanation_text = "Kill everyone but your host."
	objectives += new_objective

/datum/antagonist/venom/get_preview_icon()
	return icon('icons/mob/nonhuman-player/venom.dmi', "venom")

/mob/living/simple_animal/hostile/venom
	name = "mysterious blob"
	desc = "What the hell is this!!"
	icon = 'icons/mob/nonhuman-player/venom.dmi'
	icon_state = "venom"
	ranged = TRUE
	ranged_message = "throws itself"
	ranged_cooldown_time = 5 SECONDS
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_EPIC
	see_in_dark = 8
	sight_flags = SEE_MOBS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	var/charging = FALSE
	var/power = 0
	var/datum/song/song

/mob/living/simple_animal/hostile/venom/Initialize(mapload)
	. = ..()
	song = new(src, "piano", 1)
	song.max_repeats = INFINITY
	song.repeats = INFINITY
	song.max_volume = 100
	song.volume = 100
	song.ParseSong(VENOM_SONG)
	song.start_playing(src)
	var/datum/action/cooldown/spell/list_target/telepathy/telepathy = new(src)
	telepathy.Grant(src)
	var/datum/action/cooldown/spell/mind_control/control = new(src)
	control.Grant(src)

/mob/living/simple_animal/hostile/venom/Destroy()
	QDEL_NULL(song)
	return ..()

/mob/living/simple_animal/hostile/venom/get_status_tab_items()
	. = ..()
	. += "Power: [power]"

/mob/living/simple_animal/hostile/venom/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	OpenFire(attack_target)

/mob/living/simple_animal/hostile/venom/OpenFire(atom/target)
	if(charging)
		return
	visible_message(span_danger("<b>[src]</b> [ranged_message] at [target]!"))
	COOLDOWN_START(src, ranged_cooldown, ranged_cooldown_time)
	Shoot(target)

/mob/living/simple_animal/hostile/venom/Shoot(atom/targeted_atom)
	charging = TRUE
	throw_at(targeted_atom, range, speed = 1.5, thrower = src, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(charging_end)))

/mob/living/simple_animal/hostile/venom/proc/charging_end()
	charging = FALSE

/mob/living/simple_animal/hostile/venom/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!charging)
		return ..()
	if(!ishuman(hit_atom))
		return
	var/mob/living/carbon/human/hit_mob = hit_atom
	var/obj/item/mod/control/venom_target = locate() in hit_mob
	if(!venom_target || !venom_target.active || venom_target.activating)
		return
	hit_mob.visible_message(span_danger("[src] jumps onto [hit_mob]!"), span_userdanger("[src] jumps onto you!"))
	shake_camera(hit_mob, 4, 3)
	shake_camera(src, 2, 3)
	venomify_mod(venom_target)

/mob/living/simple_animal/hostile/venom/proc/venomify_mod(obj/item/mod/control/mod)
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(block_mod_activation))
	ADD_TRAIT(mod, TRAIT_NODROP, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_NOHUNGER, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_NODISMEMBER, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_NEVER_WOUNDED, REF(src))
	mod.slowdown_inactive = 0
	mod.slowdown_active = 0
	mod.update_speed()
	mod.set_mod_color(COLOR_BLACK)

/mob/living/simple_animal/hostile/venom/proc/block_mod_activation(datum/source)
	SIGNAL_HANDLER
	return MOD_CANCEL_ACTIVATE

/mob/living/passenger
	name = "control victim"
	real_name = "unknown conscience"

/mob/living/passenger/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	return

/mob/living/passenger/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode)
	to_chat(src, span_warning("You find yourself unable to speak, you aren't in control of your body!"))

/mob/living/passenger/emote(act, m_type, message, intentional, force_silence)
	to_chat(src, span_warning("You find yourself unable to emote, you aren't in control of your body!"))
