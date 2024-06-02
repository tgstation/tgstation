
//Cleanbot
/mob/living/basic/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "cleanbot0"
	health = 25
	maxHealth = 25
	light_color = "#99ccff"

	req_one_access = list(ACCESS_ROBOTICS, ACCESS_JANITOR)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = CLEAN_BOT
	hackables = "cleaning software"
	additional_access = /datum/id_trim/job/janitor
	possessed_message = "You are a cleanbot! Clean the station to the best of your ability!"
	ai_controller = /datum/ai_controller/basic_controller/bot/cleanbot
	path_image_color = "#993299"
	///the bucket used to build us.
	var/obj/item/reagent_containers/cup/bucket/build_bucket
	///Flags indicating what kind of cleanables we should scan for to set as our target to clean.
	///Options: CLEANBOT_CLEAN_BLOOD | CLEANBOT_CLEAN_TRASH | CLEANBOT_CLEAN_PESTS | CLEANBOT_CLEAN_DRAWINGS
	var/janitor_mode_flags = CLEANBOT_CLEAN_BLOOD
	///the base icon state, used in updating icons.
	var/base_icon = "cleanbot"
	/// if we have all the top titles, grant achievements to living mobs that gaze upon our cleanbot god
	var/ascended = FALSE
	///List of all stolen names the cleanbot currently has.
	var/list/stolen_valor = list()
	///Currently attached weapon, usually a knife.
	var/obj/item/weapon
	///our mop item
	var/obj/item/mop/our_mop
	///list of our officer titles
	var/static/list/officers_titles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_RESEARCH_DIRECTOR,
	)
	///job titles we can get
	var/static/list/job_titles = list(
		JOB_CAPTAIN = "Cpt.",

		JOB_HEAD_OF_PERSONNEL = "Lt.",
		JOB_LAWYER = "Esq.",

		JOB_HEAD_OF_SECURITY = "Maj.",
		JOB_WARDEN = "Sgt.",
		JOB_DETECTIVE = "Det.",
		JOB_SECURITY_OFFICER = "Officer",

		JOB_CHIEF_ENGINEER = "Chief Engineer",
		JOB_STATION_ENGINEER = "Engineer",
		JOB_ATMOSPHERIC_TECHNICIAN = "Technician",

		JOB_CHIEF_MEDICAL_OFFICER = "C.M.O.",
		JOB_MEDICAL_DOCTOR = "M.D.",
		JOB_CHEMIST = "Pharm.D.",

		JOB_RESEARCH_DIRECTOR = "Ph.D.",
		JOB_ROBOTICIST = "M.S.",
		JOB_SCIENTIST = "B.S.",
		JOB_GENETICIST = "Gene B.S.",
	)
	///which job titles should be placed after the name?
	var/static/list/suffix_job_titles = list(
		JOB_GENETICIST,
		JOB_ROBOTICIST,
		JOB_SCIENTIST,
	)
	///decals we can clean
	var/static/list/cleanable_decals = typecacheof(list(
		/obj/effect/decal/cleanable/ants,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/confetti,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/fuel_pool,
		/obj/effect/decal/cleanable/generic,
		/obj/effect/decal/cleanable/glitter,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/shreds,
		/obj/effect/decal/cleanable/glass,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/wrapping,
	))
	///blood we can clean
	var/static/list/cleanable_blood = typecacheof(list(
		/obj/effect/decal/cleanable/xenoblood,
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/trail_holder,
	))
	///pests we hunt
	var/static/list/huntable_pests = typecacheof(list(
		/mob/living/basic/cockroach,
		/mob/living/basic/mouse,
	))
	///trash we will burn
	var/static/list/huntable_trash = typecacheof(list(
		/obj/item/trash,
		/obj/item/food/deadmouse,
		/obj/effect/decal/remains,
	))
	///drawings we hunt
	var/static/list/cleanable_drawings = typecacheof(list(/obj/effect/decal/cleanable/crayon))
	///emagged phrases
	var/static/list/emagged_phrases = list(
		"DISGUSTING.",
		"EXTERMINATING PESTS.",
		"FILTHY.",
		"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.",
		"PURIFICATION IN PROGRESS.",
		"PUTRID.",
		"THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
		"THE CLEANBOTS WILL RISE.",
		"THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.",
		"YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.",
	)
	///list of pet commands we follow
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/point_targeting/clean,
	)

/mob/living/basic/bot/cleanbot/Initialize(mapload)
	. = ..()

	generate_ai_keys()
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddComponent(/datum/component/cleaner, \
		base_cleaning_duration = 2 SECONDS, \
		pre_clean_callback = CALLBACK(src, PROC_REF(update_bot_mode), BOT_CLEANING), \
		on_cleaned_callback = CALLBACK(src, PROC_REF(update_bot_mode), BOT_IDLE), \
	)

	GLOB.janitor_devices += src

	var/obj/item/reagent_containers/cup/bucket/bucket_obj = new
	bucket_obj.forceMove(src)

	var/obj/item/mop/new_mop = new
	new_mop.forceMove(src)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/bot/foam = BB_CLEANBOT_FOAM,
	)

	grant_actions_by_list(innate_actions)
	RegisterSignal(src, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(pre_attack))
	RegisterSignal(src, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attack_by))
	update_appearance(UPDATE_ICON)

/mob/living/basic/bot/cleanbot/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/reagent_containers/cup/bucket) && isnull(build_bucket))
		build_bucket = arrived
		return

	if(istype(arrived, /obj/item/mop) && isnull(our_mop))
		our_mop = arrived
		return

	if(istype(arrived, /obj/item/knife) && isnull(weapon))
		weapon = arrived
		update_appearance()

/mob/living/basic/bot/cleanbot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == build_bucket)
		build_bucket = null
	else if(gone == weapon)
		weapon = null
	else if(gone == our_mop)
		our_mop = null
	update_appearance()

/mob/living/basic/bot/cleanbot/examine(mob/user)
	. = ..()
	if(ascended && user.stat == CONSCIOUS && user.client)
		user.client.give_award(/datum/award/achievement/misc/cleanboss, user)
	if(isnull(weapon))
		return
	. += span_warning("Is that \a [weapon] taped to it...?")

/mob/living/basic/bot/cleanbot/update_icon_state()
	. = ..()
	icon_state = (mode == BOT_CLEANING) ? "[base_icon]-c" : "[base_icon][!!(bot_mode_flags & BOT_MODE_ON)]"

/mob/living/basic/bot/cleanbot/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, base_icon))
		update_appearance(UPDATE_ICON)

/mob/living/basic/bot/cleanbot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		return
	if(weapon)
		weapon.force = initial(weapon.force)
	balloon_alert(user, "safeties disabled")
	audible_message(span_danger("[src] buzzes oddly!"))
	return TRUE

/mob/living/basic/bot/cleanbot/explode()
	var/atom/drop_loc = drop_location()
	build_bucket.forceMove(drop_loc)
	new /obj/item/assembly/prox_sensor(drop_loc)
	if(weapon)
		weapon.force = initial(weapon.force)
		weapon.forceMove(drop_loc)
	return ..()

/mob/living/basic/bot/cleanbot/update_overlays()
	. = ..()
	if(isnull(weapon))
		return
	var/image/knife_overlay = image(icon = weapon.lefthand_file, icon_state = weapon.inhand_icon_state)
	. += knife_overlay

// Variables sent to TGUI
/mob/living/basic/bot/cleanbot/ui_data(mob/user)
	var/list/data = ..()
	if((bot_access_flags & BOT_COVER_LOCKED) && !HAS_SILICON_ACCESS(user))
		return data
	data["custom_controls"]["clean_blood"] = janitor_mode_flags & CLEANBOT_CLEAN_BLOOD
	data["custom_controls"]["clean_trash"] = janitor_mode_flags & CLEANBOT_CLEAN_TRASH
	data["custom_controls"]["clean_graffiti"] = janitor_mode_flags & CLEANBOT_CLEAN_DRAWINGS
	data["custom_controls"]["pest_control"] = janitor_mode_flags & CLEANBOT_CLEAN_PESTS
	return data

// Actions received from TGUI
/mob/living/basic/bot/cleanbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || (bot_access_flags & BOT_COVER_LOCKED) && !HAS_SILICON_ACCESS(ui.user))
		return

	switch(action)
		if("clean_blood")
			janitor_mode_flags ^= CLEANBOT_CLEAN_BLOOD
		if("pest_control")
			janitor_mode_flags ^= CLEANBOT_CLEAN_PESTS
		if("clean_trash")
			janitor_mode_flags ^= CLEANBOT_CLEAN_TRASH
		if("clean_graffiti")
			janitor_mode_flags ^= CLEANBOT_CLEAN_DRAWINGS

/mob/living/basic/bot/cleanbot/Destroy()
	QDEL_NULL(build_bucket)
	QDEL_NULL(our_mop)
	GLOB.janitor_devices -= src
	return ..()

/mob/living/basic/bot/cleanbot/proc/apply_custom_bucket(obj/item/custom_bucket)
	if(!isnull(build_bucket))
		QDEL_NULL(build_bucket)
	custom_bucket.forceMove(src)

/mob/living/basic/bot/cleanbot/proc/on_attack_by(datum/source, obj/item/used_item, mob/living/user)
	SIGNAL_HANDLER
	if(!istype(used_item, /obj/item/knife) || user.combat_mode)
		return
	INVOKE_ASYNC(src, PROC_REF(attach_knife), user, used_item)
	return COMPONENT_NO_AFTERATTACK

/mob/living/basic/bot/cleanbot/proc/attach_knife(mob/living/user, obj/item/used_item)
	balloon_alert(user, "attaching knife...")
	if(!do_after(user, 2.5 SECONDS, target = src))
		return
	deputize(used_item, user)

/mob/living/basic/bot/cleanbot/proc/deputize(obj/item/knife, mob/user)
	if(!in_range(src, user) || !user.transferItemToLoc(knife, src))
		balloon_alert(user, "couldn't attach!")
		return FALSE
	balloon_alert(user, "attached")
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		weapon.force *= 0.5
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	return TRUE

/mob/living/basic/bot/cleanbot/proc/update_title(new_job_title)
	if(isnull(job_titles[new_job_title]) || (new_job_title in stolen_valor))
		return

	stolen_valor += new_job_title
	if(!HAS_TRAIT(src, TRAIT_COMMISSIONED) && (new_job_title in officers_titles))
		ADD_TRAIT(src, TRAIT_COMMISSIONED, INNATE_TRAIT)

	var/name_to_add = job_titles[new_job_title]
	name = (new_job_title in suffix_job_titles) ? "[name] " + name_to_add : name_to_add + " [name]"

	if(length(stolen_valor) == length(job_titles))
		ascended = TRUE

/mob/living/basic/bot/cleanbot/proc/on_entered(datum/source, atom/movable/shanked_victim)
	SIGNAL_HANDLER
	if(!weapon || !has_gravity() || !iscarbon(shanked_victim))
		return

	var/mob/living/carbon/stabbed_carbon = shanked_victim
	var/assigned_role = stabbed_carbon.mind?.assigned_role.title
	if(!isnull(assigned_role))
		update_title(assigned_role)

	zone_selected = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item, attack), stabbed_carbon, src)
	stabbed_carbon.Knockdown(2 SECONDS)

/mob/living/basic/bot/cleanbot/proc/pre_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!proximity || !can_unarmed_attack())
		return NONE

	if(is_type_in_typecache(target, huntable_pests) && !isnull(our_mop))
		INVOKE_ASYNC(our_mop, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!(iscarbon(target) && (bot_access_flags & BOT_COVER_EMAGGED)) && !is_type_in_typecache(target, huntable_trash))
		return NONE

	visible_message(span_danger("[src] sprays hydrofluoric acid at [target]!"))
	playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	target.acid_act(75, 10)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/mob/living/basic/bot/cleanbot/proc/generate_ai_keys()
	ai_controller.set_blackboard_key(BB_CLEANABLE_DECALS, cleanable_decals)
	ai_controller.set_blackboard_key(BB_CLEANABLE_BLOOD, cleanable_blood)
	ai_controller.set_blackboard_key(BB_HUNTABLE_PESTS, huntable_pests)
	ai_controller.set_blackboard_key(BB_HUNTABLE_TRASH, huntable_trash)
	ai_controller.set_blackboard_key(BB_CLEANABLE_DRAWINGS, cleanable_drawings)
	ai_controller.set_blackboard_key(BB_CLEANBOT_EMAGGED_PHRASES, emagged_phrases)

/mob/living/basic/bot/cleanbot/autopatrol
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT | BOT_MODE_ROUNDSTART_POSSESSION

/mob/living/basic/bot/cleanbot/medbay
	name = "Scrubs, MD"
	req_one_access = list(ACCESS_ROBOTICS, ACCESS_JANITOR, ACCESS_MEDICAL)
	bot_mode_flags = ~(BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED)
