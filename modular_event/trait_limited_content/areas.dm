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
			var/turf/turf = get_turf(mob)
			message_admins("[key_name_admin(mob)] was in [area] without the [area.trait_required] trait! <a href='?src=[REF(src)];area=[REF(area)];mob=[REF(mob)];turf=[REF(turf)]'>GIVE TRAIT (AND TELEPORT BACK)</a>")
			mob.forceMove(mob.mind?.assigned_role?.get_latejoin_spawn_point() || pick(SSjob.latejoin_trackers) || SSjob.get_last_resort_spawn_points())

		if (MC_TICK_CHECK)
			return

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

	mob.forceMove(turf)

/area
	var/trait_required = null

/area/vip_only
	name = "VIP Room"
	icon_state = "yellow"
	trait_required = TRAIT_VIP
