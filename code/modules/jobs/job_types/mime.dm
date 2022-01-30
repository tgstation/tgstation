/datum/job/mime
	title = JOB_MIME
	description = "..."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/mime
	plasmaman_outfit = /datum/outfit/plasmaman/mime

	paycheck = PAYCHECK_MINIMAL
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_MIME
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/food/baguette)

	mail_goodies = list(
		/obj/item/food/baguette = 15,
		/obj/item/food/cheese/wheel = 10,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 10,
		/obj/item/book/mimery = 1,
	)
	rpg_title = "Fool"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

	voice_of_god_power = 0.5 //Why are you speaking
	voice_of_god_silence_power = 3


/datum/job/mime/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!ishuman(spawned))
		return
	spawned.apply_pref_name(/datum/preference/name/mime, player_client)


/datum/outfit/job/mime
	name = "Mime"
	jobtype = /datum/job/mime

	id_trim = /datum/id_trim/job/mime
	uniform = /obj/item/clothing/under/rank/civilian/mime
	suit = /obj/item/clothing/suit/toggle/suspenders
	backpack_contents = list(
		/obj/item/book/mimery = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 1,
		/obj/item/stamp/mime = 1,
		)
	belt = /obj/item/pda/mime
	ears = /obj/item/radio/headset/headset_srv
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/frenchberet
	mask = /obj/item/clothing/mask/gas/mime
	shoes = /obj/item/clothing/shoes/laceup

	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime

	chameleon_extras = /obj/item/stamp/mime

/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = TRUE

	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	fan.add_hud_to(H)

/obj/item/book/mimery
	name = "Guide to Dank Mimery"
	desc = "Teaches one of three classic pantomime routines, allowing a practiced mime to conjure invisible objects into corporeal existence. One use only."
	icon_state = "bookmime"

/obj/item/book/mimery/attack_self(mob/user)
	var/list/spell_icons = list(
		"Invisible Wall" = image(icon = 'icons/mob/actions/actions_mime.dmi', icon_state = "invisible_wall"),
		"Invisible Chair" = image(icon = 'icons/mob/actions/actions_mime.dmi', icon_state = "invisible_chair"),
		"Invisible Box" = image(icon = 'icons/mob/actions/actions_mime.dmi', icon_state = "invisible_box")
		)
	var/picked_spell = show_radial_menu(user, src, spell_icons, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 36, require_near = TRUE)
	switch(picked_spell)
		if("Invisible Wall")
			user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		if("Invisible Chair")
			user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair(null))
		if("Invisible Box")
			user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_box(null))
		else
			return
	to_chat(user, span_warning("The book disappears into thin air."))
	qdel(src)

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The human mob interacting with the menu
 */
/obj/item/book/mimery/proc/check_menu(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!user.mind)
		return FALSE
	return TRUE
