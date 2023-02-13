// Admin Tab - Fun Verbs

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Admin.Fun"
	set name = "Explosion"

	if(!check_rights(R_ADMIN))
		return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null)
		return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null)
		return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null)
		return
	var/flames = input("Range of flames. -1 to none", text("Input"))  as num|null
	if(flames == null)
		return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if (tgui_alert(usr, "Are you sure you want to do this? It will laaag.", "Confirmation", list("Yes", "No")) == "No")
				return

		explosion(O, devastation, heavy, light, flames, flash, explosion_cause = mob)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Explosion") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Admin.Fun"
	set name = "EM Pulse"

	if(!check_rights(R_ADMIN))
		return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null)
		return

	if (heavy || light)
		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] created an EM Pulse ([heavy],[light]) at [AREACOORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EM Pulse") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib(mob/victim in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Gib"

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Drop a brain?", "Confirm", list("Yes", "No","Cancel"))
	if(confirm == "Cancel")
		return
	//Due to the delay here its easy for something to have happened to the mob
	if(!victim)
		return

	log_admin("[key_name(usr)] has gibbed [key_name(victim)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(victim)]")

	if(isobserver(victim))
		new /obj/effect/gibspawner/generic(get_turf(victim))
		return

	var/mob/living/living_victim = victim
	if (istype(living_victim))
		living_victim.investigate_log("has been gibbed by an admin.", INVESTIGATE_DEATHS)
		if(confirm == "Yes")
			living_victim.gib()
		else
			living_victim.gib(TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Admin.Fun"

	var/confirm = tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm == "Yes")
		log_admin("[key_name(usr)] used gibself.")
		message_admins(span_adminnotice("[key_name_admin(usr)] used gibself."))
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib Self") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		var/mob/living/ourself = mob
		if (istype(ourself))
			ourself.gib(TRUE, TRUE, TRUE)

/client/proc/everyone_random()
	set category = "Admin.Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(SSticker.HasRoundStarted())
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!", confidential = TRUE)
		return

	var/frn = CONFIG_GET(flag/force_random_names)
	if(frn)
		CONFIG_SET(flag/force_random_names, FALSE)
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.")
		to_chat(usr, "Disabled.", confidential = TRUE)
		return

	var/notifyplayers = tgui_alert(usr, "Do you want to notify the players?", "Options", list("Yes", "No", "Cancel"))
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		to_chat(world, span_adminnotice("Admin [usr.key] has forced the players to have completely random identities!"), confidential = TRUE)

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.", confidential = TRUE)

	CONFIG_SET(flag/force_random_names, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Everyone Random") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/mass_zombie_infection()
	set category = "Admin.Fun"
	set name = "Mass Zombie Infection"
	set desc = "Infects all humans with a latent organ that will zombify \
		them on death."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Please confirm you want to add latent zombie organs in all humans?", "Confirm Zombies", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/H = i
		new /obj/item/organ/internal/zombie_infection/nodamage(H)

	message_admins("[key_name_admin(usr)] added a latent zombie infection to all humans.")
	log_admin("[key_name(usr)] added a latent zombie infection to all humans.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mass Zombie Infection")

/client/proc/mass_zombie_cure()
	set category = "Admin.Fun"
	set name = "Mass Zombie Cure"
	set desc = "Removes the zombie infection from all humans, returning them to normal."
	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Please confirm you want to cure all zombies?", "Confirm Zombie Cure", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/obj/item/organ/internal/zombie_infection/nodamage/I in GLOB.zombie_infection_list)
		qdel(I)

	message_admins("[key_name_admin(usr)] cured all zombies.")
	log_admin("[key_name(usr)] cured all zombies.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mass Zombie Cure")

/client/proc/polymorph_all()
	set category = "Admin.Fun"
	set name = "Polymorph All"
	set desc = "Applies the effects of the bolt of change to every single mob."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "Please confirm you want polymorph all mobs?", "Confirm Polymorph", list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/list/mobs = shuffle(GLOB.alive_mob_list.Copy()) // might change while iterating
	var/who_did_it = key_name_admin(usr)

	message_admins("[key_name_admin(usr)] started polymorphed all living mobs.")
	log_admin("[key_name(usr)] polymorphed all living mobs.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Polymorph All")

	for(var/mob/living/M in mobs)
		CHECK_TICK

		if(!M)
			continue

		M.audible_message(span_hear("...wabbajack...wabbajack..."))
		playsound(M.loc, 'sound/magic/staff_change.ogg', 50, TRUE, -1)

		M.wabbajack()

	message_admins("Mass polymorph started by [who_did_it] is complete.")

/client/proc/smite(mob/living/target as mob)
	set category = "Admin.Fun"
	set name = "Smite"
	if(!check_rights(R_ADMIN) || !check_rights(R_FUN))
		return

	var/punishment = input("Choose a punishment", "DIVINE SMITING") as null|anything in GLOB.smites

	if(QDELETED(target) || !punishment)
		return

	var/smite_path = GLOB.smites[punishment]
	var/datum/smite/smite = new smite_path
	var/configuration_success = smite.configure(usr)
	if (configuration_success == FALSE)
		return
	smite.effect(src, target)

///"Turns" people into bread. Really, we just add them to the contents of the bread food item.
/proc/breadify(atom/movable/target)
	var/obj/item/food/bread/plain/smite/tomb = new(get_turf(target))
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
