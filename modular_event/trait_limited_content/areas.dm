SUBSYSTEM_DEF(trait_limited_areas)
	name = "Event - Trait Limited Areas"
	wait = 2 SECONDS

	var/list/current_run = list()

/datum/controller/subsystem/trait_limited_areas/fire(resumed)
	if (!resumed)
		current_run = GLOB.player_list.Copy()

	while (length(current_run))
		var/mob/mob = pop(current_run)

		if (QDELETED(mob) || isnull(mob.key) || !isliving(mob))
			continue

		var/area/area = get_area(mob)
		if (!isnull(area.trait_required) && !HAS_TRAIT(mob, area.trait_required))
			SEND_SOUND(mob, 'sound/misc/notice1.ogg')
			// mobs norally should not be able to trigger this, mostly for admemes spawning themself in
			to_chat(mob, span_alertwarning("You are not authorized to be in \"[area]\" Leave now or you will be booted to the curb."))
			addtimer(CALLBACK(src, .proc/boot_confirm, area, mob), 5 SECONDS, TIMER_CLIENT_TIME)

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/trait_limited_areas/proc/boot_confirm(area/area, mob/mob)
	if (get_area(mob) != area)
		return
	var/turf/turf = get_turf(mob)
	if (!(mob in area.mobs_booted))
		area.mobs_booted += mob
		message_admins("[key_name_admin(mob)] was in [area] without the [area.trait_required] trait! <a href='?src=[REF(src)];area=[REF(area)];mob=[REF(mob)];turf=[REF(turf)]'>GIVE TRAIT (AND TELEPORT BACK)</a>")
	mob.forceMove(mob.mind?.assigned_role?.get_latejoin_spawn_point() || pick(SSjob.latejoin_trackers) || SSjob.get_last_resort_spawn_points())
	playsound(get_turf(mob), 'sound/effects/assslap.ogg', 100, TRUE)
	log_game("[key_name(mob)] was booted from [area] for lacking the proper trait.")

/datum/controller/subsystem/trait_limited_areas/Topic(href, list/href_list)
	. = ..()
	if (.)
		return

	if (isnull(usr.client?.holder))
		message_admins("[key_name_admin(usr)] tried to use a Topic on the limited areas SS without permission.")
		log_admin_private("[key_name(usr)] tried to use a Topic on the limited areas SS without permission.")

		return

	var/area_ref = href_list["area"]
	if (isnull(area_ref))
		return

	var/area/area = locate(area_ref)
	var/mob/mob = locate(href_list["mob"])
	var/turf/turf = locate(href_list["turf"])

	if (!istype(area))
		to_chat(usr, span_warning("The area ref is invalid!"))
		return

	if (!istype(mob))
		to_chat(usr, span_warning("The mob ref is invalid! Maybe they respawned?"))
		return

	if (isnull(area.trait_required))
		to_chat(usr, span_warning("The area you are limiting to doesn't have a trait!"))
		return

	ADD_TRAIT(mob, area.trait_required, "[type]")

	message_admins("[key_name(usr)] has given [key_name_admin(mob)] the trait required to enter [area].")
	log_admin("[key_name(usr)] has given [key_name(mob)] the trait required to enter [area].")

	to_chat(mob, span_boldnotice("You have been given access to enter [area]!"))

	if (!istype(turf))
		to_chat(usr, span_warning("The mob was given the trait, but somehow, the turf reference is invalid!"))
		return

	// wait to move them back so they don't get re-booted by a still running timer
	addtimer(CALLBACK(mob, /atom/movable/proc/forceMove, turf), 5 SECONDS, TIMER_CLIENT_TIME)

/area
	var/trait_required = null
	var/list/mobs_booted = list()

/area/awaymission/cabin/snowforest/vip_only
	name = "VIP Room"
	icon_state = "bluenew"
	trait_required = TRAIT_VIP
	area_flags = UNIQUE_AREA | NO_ALERTS | NOTELEPORT

/area/awaymission/cabin/snowforest/staff_only
	name = "Casting Booth"
	icon_state = "red"
	trait_required = TRAIT_COMMENTATOR
	area_flags = UNIQUE_AREA | NO_ALERTS | NOTELEPORT
