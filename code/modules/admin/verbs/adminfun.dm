ADMIN_VERB(admin_explosion, R_ADMIN|R_FUN, "Explosion", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, atom/orignator as obj|mob|turf)
	var/devastation = input(user, "Range of total devastation. -1 to none", "Input")  as num|null
	if(devastation == null)
		return
	var/heavy = input(user, "Range of heavy impact. -1 to none", "Input")  as num|null
	if(heavy == null)
		return
	var/light = input(user, "Range of light impact. -1 to none", "Input")  as num|null
	if(light == null)
		return
	var/flash = input(user, "Range of flash. -1 to none", "Input")  as num|null
	if(flash == null)
		return
	var/flames = input(user, "Range of flames. -1 to none", "Input")  as num|null
	if(flames == null)
		return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if (tgui_alert(user, "Are you sure you want to do this? It will laaag.", "Confirmation", list("Yes", "No")) == "No")
				return

		explosion(orignator, devastation, heavy, light, flames, flash, explosion_cause = user.mob)
		log_admin("[key_name(user)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(orignator)]")
		message_admins("[key_name_admin(user)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(orignator)]")
		BLACKBOX_LOG_ADMIN_VERB("Explosion")

ADMIN_VERB(admin_emp, R_ADMIN|R_FUN, "EM Pulse", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, atom/orignator as obj|mob|turf)
	var/heavy = input(user, "Range of heavy pulse.", "Input")  as num|null
	if(heavy == null)
		return
	var/light = input(user, "Range of light pulse.", "Input")  as num|null
	if(light == null)
		return

	if (heavy || light)
		empulse(orignator, heavy, light)
		log_admin("[key_name(user)] created an EM Pulse ([heavy],[light]) at [AREACOORD(orignator)]")
		message_admins("[key_name_admin(user)] created an EM Pulse ([heavy],[light]) at [AREACOORD(orignator)]")
		BLACKBOX_LOG_ADMIN_VERB("EM Pulse")

ADMIN_VERB(gib_them, R_ADMIN, "Gib", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/victim in GLOB.mob_list)
	var/confirm = tgui_alert(user, "Drop a brain?", "Confirm", list("Yes", "No","Cancel")) || "Cancel"
	if(confirm == "Cancel")
		return
	//Due to the delay here its easy for something to have happened to the mob
	if(isnull(victim))
		return

	log_admin("[key_name(user)] has gibbed [key_name(victim)]")
	message_admins("[key_name_admin(user)] has gibbed [key_name_admin(victim)]")

	if(isobserver(victim))
		new /obj/effect/gibspawner/generic(get_turf(victim))
		return

	var/mob/living/living_victim = victim
	if (istype(living_victim))
		living_victim.investigate_log("has been gibbed by an admin.", INVESTIGATE_DEATHS)
		if(confirm == "Yes")
			living_victim.gib(DROP_ALL_REMAINS)
		else
			living_victim.gib(DROP_ORGANS|DROP_BODYPARTS)

	BLACKBOX_LOG_ADMIN_VERB("Gib")

ADMIN_VERB(gib_self, R_ADMIN, "Gibself", "Give yourself the same treatment you give others.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return
	log_admin("[key_name(user)] used gibself.")
	message_admins(span_adminnotice("[key_name_admin(user)] used gibself."))
	BLACKBOX_LOG_ADMIN_VERB("Gib Self")

	var/mob/living/ourself = user.mob
	if (istype(ourself))
		ourself.gib()

ADMIN_VERB(everyone_random, R_SERVER, "Make Everyone Random", "Make everyone have a random appearance.", ADMIN_CATEGORY_FUN)
	if(SSticker.HasRoundStarted())
		to_chat(user, "Nope you can't do this, the game's already started. This only works before rounds!", confidential = TRUE)
		return

	var/frn = CONFIG_GET(flag/force_random_names)
	if(frn)
		CONFIG_SET(flag/force_random_names, FALSE)
		message_admins("Admin [key_name_admin(user)] has disabled \"Everyone is Special\" mode.")
		to_chat(user, "Disabled.", confidential = TRUE)
		return

	var/notifyplayers = tgui_alert(user, "Do you want to notify the players?", "Options", list("Yes", "No", "Cancel")) || "Cancel"
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(user)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(user)] has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		to_chat(world, span_adminnotice("Admin [user.key] has forced the players to have completely random identities!"), confidential = TRUE)

	to_chat(user, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.", confidential = TRUE)

	CONFIG_SET(flag/force_random_names, TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Make Everyone Random")

ADMIN_VERB(mass_zombie_infection, R_ADMIN, "Mass Zombie Infection", "Infects all humans with a latent organ that will zombify them on death.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "Please confirm you want to add latent zombie organs in all humans?", "Confirm Zombies", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/H = i
		new /obj/item/organ/internal/zombie_infection/nodamage(H)

	message_admins("[key_name_admin(user)] added a latent zombie infection to all humans.")
	log_admin("[key_name(user)] added a latent zombie infection to all humans.")
	BLACKBOX_LOG_ADMIN_VERB("Mass Zombie Infection")

ADMIN_VERB(mass_zombie_cure, R_ADMIN, "Mass Zombie Cure", "Removes the zombie infection from all humans, returning them to normal.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "Please confirm you want to cure all zombies?", "Confirm Zombie Cure", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/item/organ/internal/zombie_infection/nodamage/I in GLOB.zombie_infection_list)
		qdel(I)

	message_admins("[key_name_admin(user)] cured all zombies.")
	log_admin("[key_name(user)] cured all zombies.")
	BLACKBOX_LOG_ADMIN_VERB("Mass Zombie Cure")

ADMIN_VERB(polymorph_all, R_ADMIN, "Polymorph All", "Applies the effects of the bolt of change to every single mob.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "Please confirm you want polymorph all mobs?", "Confirm Polymorph", list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/list/mobs = shuffle(GLOB.alive_mob_list.Copy()) // might change while iterating
	var/who_did_it = key_name_admin(user)

	message_admins("[key_name_admin(user)] started polymorphed all living mobs.")
	log_admin("[key_name(user)] polymorphed all living mobs.")
	BLACKBOX_LOG_ADMIN_VERB("Polymorph All")

	for(var/mob/living/M in mobs)
		CHECK_TICK

		if(!M)
			continue

		M.audible_message(span_hear("...wabbajack...wabbajack..."))
		playsound(M.loc, 'sound/magic/staff_change.ogg', 50, TRUE, -1)

		M.wabbajack()

	message_admins("Mass polymorph started by [who_did_it] is complete.")

ADMIN_VERB_AND_CONTEXT_MENU(admin_smite, R_ADMIN|R_FUN, "Smite", "Smite a player with divine power.", ADMIN_CATEGORY_FUN, mob/living/target in world)
	var/punishment = tgui_input_list(user, "Choose a punishment", "DIVINE SMITING", GLOB.smites)

	if(QDELETED(target) || !punishment)
		return

	var/smite_path = GLOB.smites[punishment]
	var/datum/smite/smite = new smite_path
	var/configuration_success = smite.configure(user)
	if (configuration_success == FALSE)
		return
	smite.effect(user, target)

/// "Turns" people into objects. Really, we just add them to the contents of the item.
/proc/objectify(atom/movable/target, path)
	var/atom/tomb = new path(get_turf(target))
	target.forceMove(tomb)
	target.AddComponent(/datum/component/itembound, tomb)

/**
 * firing_squad is a proc for the :B:erforate smite to shoot each individual bullet at them, so that we can add actual delays without sleep() nonsense
 *
 * Hilariously, if you drag someone away mid smite, the bullets will still chase after them from the original spot, possibly hitting other people. Too funny to fix imo
 *
 * Arguments:
 * * target- guy we're shooting obviously
 * * source_turf- where the bullet begins, preferably on a turf next to the target
 * * body_zone- which bodypart we're aiming for, if there is one there
 * * wound_bonus- the wounding power we're assigning to the bullet, since we don't care about the base one
 * * damage- the damage we're assigning to the bullet, since we don't care about the base one
 */
/proc/firing_squad(mob/living/carbon/target, turf/source_turf, body_zone, wound_bonus, damage)
	if(!target.get_bodypart(body_zone))
		return
	playsound(target, 'sound/weapons/gun/revolver/shot.ogg', 100)
	var/obj/projectile/bullet/smite/divine_wrath = new(source_turf)
	divine_wrath.damage = damage
	divine_wrath.wound_bonus = wound_bonus
	divine_wrath.original = target
	divine_wrath.def_zone = body_zone
	divine_wrath.spread = 0
	divine_wrath.preparePixelProjectile(target, source_turf)
	divine_wrath.fire()

/client/proc/punish_log(whom, punishment)
	var/msg = "[key_name_admin(src)] punished [key_name_admin(whom)] with [punishment]."
	message_admins(msg)
	admin_ticket_log(whom, msg)
	log_admin("[key_name(src)] punished [key_name(whom)] with [punishment].")
