/mob/living/basic/bot/secbot/ed209
	name = "\improper ED-209 Security Robot"
	desc = "A security robot. He looks less than thrilled."
	icon_state = "ed209"
	base_icon_state = "ed209"
	light_color = "#f84e4e"
	density = TRUE
	health = 100
	maxHealth = 100
	obj_damage = 60
	environment_smash = ENVIRONMENT_SMASH_WALLS //Walls can't stop THE LAW
	mob_size = MOB_SIZE_LARGE
	ai_controller = /datum/ai_controller/basic_controller/bot/ed209
	bot_type = ADVANCED_SEC_BOT
	hackables = "combat inhibitors"
	///sound of the projectiles we shoot
	var/projectile_sound = 'sound/items/weapons/laser.ogg'
	///what projectiles we shoot
	var/projectile_type = /obj/projectile/beam/disabler
	///what projectiles we shoot when emagged
	var/emagged_projectile_type = /obj/projectile/beam
	///sound of emagged projectile
	var/emagged_projectile_sound = 'sound/items/weapons/laser.ogg'
	///special hats that change our personality :mistake:
	var/static/list/sherrif_hats = typecacheof(list(
		/obj/item/clothing/head/cowboy,
	))
	var/datum/action/cooldown/mob_cooldown/ed209_charge/bot_charge
	///our riding component
	var/ride_component = /datum/component/riding/creature/ed_bot
	///have we become a sheriff
	var/sheriffized = FALSE
	///timer till we yell out our war cry again
	COOLDOWN_DECLARE(shoot_cry)


/mob/living/basic/bot/secbot/ed209/Initialize(mapload)
	. = ..()
	set_weapon()
	bot_charge = new(src)
	var/static/list/hat_offset = list(2, 0)
	AddElement(/datum/element/hat_wearer,\
		offsets = hat_offset,\
	)

	AddComponent(/datum/component/defaceable, \
		icon = 'icons/mob/silicon/aibot_faces.dmi', \
		icon_states = list("ed209" = FALSE, "ed209_highlight" = TRUE), \
		drawing_of = "a face", \
	)
	AddComponent(/datum/component/stun_n_cuff,\
		stun_sound = 'sound/items/weapons/egloves.ogg',\
		handcuff_type = /obj/item/restraints/handcuffs/cable/zipties,\
	)
	AddElement(/datum/element/ridable, ride_component)
	RegisterSignal(src, COMSIG_BASICMOB_POST_ATTACK_RANGED, PROC_REF(post_ranged_attack))

/mob/living/basic/bot/secbot/ed209/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	sheriffized = (is_type_in_typecache(arrived, sherrif_hats)) //yeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeehawwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww

/mob/living/basic/bot/secbot/ed209/proc/post_ranged_attack()
	SIGNAL_HANDLER
	if(!HAS_TRAIT(src, TRAIT_BOT_SHERRIF) || !COOLDOWN_FINISHED(src, shoot_cry))
		return
	COOLDOWN_START(src, shoot_cry, 30 SECONDS)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), "YIPPIE-KI-YAY!")

/mob/living/basic/bot/secbot/ed209/Exited(atom/movable/gone, direction)
	. = ..()
	sheriffized = (is_type_in_typecache(gone, sherrif_hats))

/mob/living/basic/bot/secbot/ed209/examine(mob/user)
	. = ..()
	if(sheriffized)
		. += span_notice("Fastest hand in the west.")

/mob/living/basic/bot/secbot/ed209/bot_reset(bypass_ai_reset = FALSE)
	.= ..()
	if(bot_access_flags & BOT_COVER_EMAGGED && isnull(bot_charge.owner))
		bot_charge.Grant(src)
	if(!(bot_access_flags & BOT_COVER_EMAGGED) && !isnull(bot_charge.owner))
		bot_charge.Remove(src)
	set_weapon()

/mob/living/basic/bot/secbot/ed209/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	icon_state = "ed209[bot_mode_flags & BOT_MODE_ON]"
	set_weapon()
	balloon_alert(user, "safeties disabled")
	audible_message(span_bolddanger("[src] buzzes menacingly!"))
	return TRUE

/mob/living/basic/bot/secbot/ed209/proc/set_weapon()
	qdel(GetComponent(/datum/component/ranged_attacks))
	var/projectile = (bot_access_flags & BOT_COVER_EMAGGED) ? emagged_projectile_type : projectile_type
	var/final_projectile_sound = (bot_access_flags & BOT_COVER_EMAGGED) ? emagged_projectile_sound : projectile_sound
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = projectile,\
		projectile_sound = final_projectile_sound,\
	)

/mob/living/basic/bot/secbot/ed209/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || HAS_SILICON_ACCESS(user))
		data["custom_controls"]["handcuff"] = security_mode_flags & SECBOT_HANDCUFF_TARGET
		data["custom_controls"]["check_ids"] = security_mode_flags & SECBOT_CHECK_IDS
		data["custom_controls"]["check_records"] = security_mode_flags & SECBOT_CHECK_RECORDS
	return data

/mob/living/basic/bot/secbot/ed209/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || !isliving(user) || (bot_access_flags & BOT_COVER_LOCKED) && !HAS_SILICON_ACCESS(user))
		return
	switch(action)
		if("handcuff")
			security_mode_flags ^= SECBOT_HANDCUFF_TARGET
		if("check_ids")
			security_mode_flags ^= SECBOT_CHECK_IDS
		if("check_records")
			security_mode_flags ^= SECBOT_CHECK_RECORDS

/mob/living/basic/bot/secbot/ed209/retrieve_secbot_drops(atom/drop_location)
	var/obj/item/bot_assembly/ed209/ed_assembly = new(drop_location)
	ed_assembly.build_step = ASSEMBLY_FIRST_STEP
	ed_assembly.add_overlay("hs_hole")
	ed_assembly.created_name = name
	new /obj/item/assembly/prox_sensor(drop_location)
	var/obj/item/gun/energy/disabler/disabler_gun = new(drop_location)
	disabler_gun.cell.charge = 0
	disabler_gun.update_appearance()
	if(prob(50))
		new /obj/item/bodypart/leg/left/robot(drop_location)
		if(prob(25))
			new /obj/item/bodypart/leg/right/robot(drop_location)
	if(prob(75))//50% chance for a helmet OR vest
		return
	if(prob(50))
		new /obj/item/clothing/head/helmet(drop_location)
	else
		new /obj/item/clothing/suit/armor/vest(drop_location)

/mob/living/basic/bot/secbot/ed209/Destroy()
	. = ..()
	QDEL_NULL(bot_charge)

/mob/living/basic/bot/secbot/ed209/nukie
	name = "\improper ED-209(+1) Syndicate Robot"
	desc = "Wait this one's red? This cannot be good... right??"
	icon_state = "red209"
	light_color = "#5c0909"
	faction = list(ROLE_SYNDICATE)
	health = 250
	maxHealth = 250
	obj_damage = 60
	req_one_access = list(ACCESS_SYNDICATE)
	bot_mode_flags = parent_type::bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED
	radio_key = /obj/item/encryptionkey/syndicate
	additional_access = /datum/id_trim/syndicom/crew
	radio_channel = RADIO_CHANNEL_SYNDICATE
	ai_controller = /datum/ai_controller/basic_controller/bot/ed209/syndicate
	bot_type = ADVANCED_SEC_BOT
	hackables = "combat inhibitors"
	projectile_sound = 'sound/items/weapons/gun/l6/shot.ogg'
	projectile_type = /obj/projectile/bullet/a7mm
	emagged_projectile_sound = 'sound/items/weapons/minebot_rocket.ogg'
	emagged_projectile_type = /obj/projectile/bullet/rocket/weak //lord have mercy
	ride_component = /datum/component/riding/creature/ed_bot/nukie //ride at ur own risk. especially if its emagged. warranty void
