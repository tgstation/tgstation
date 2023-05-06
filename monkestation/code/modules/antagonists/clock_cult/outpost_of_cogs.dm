/datum/lazy_template/reebe
	key = LAZY_TEMPLATE_KEY_OUTPOST_OF_COGS
	map_dir = "monkestation/_maps/lazy_templates"
	map_name = "reebe"


/// Spawn reebe with the appropriate fanfare after sacrificing a blood cultist
/proc/spawn_reebe(atom/target_atom)
	set waitfor = FALSE

	var/static/reebe_began_spawning = FALSE

	if(reebe_began_spawning)
		return

	GLOB.reebe_began_spawning = TRUE

	var/turf/atom_turf = get_turf(target_atom) // Protection in case this gets deleted
	var/area/atom_area = get_area(target_atom)

	sleep(2 SECONDS)

	send_clock_message(null, "<b>With the draining of one of Nar'sie's heretics, we can now open a portal to the City of Cogs, the blessed sanctuary of Reebe! It shall only be a little longer...</b>", "<span class='brass'>")

	sleep(5 SECONDS)

	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_OUTPOST_OF_COGS)

	for(var/mob/target as anything in GLOB.player_list)
		if(!isnewplayer(target) && target.can_hear() && is_station_level(target.z))
			to_chat(target, span_brass("You hear a distant, faint clanking of cogs..."))

	sleep(7 SECONDS)

	if(!atom_turf)
		atom_turf = get_safe_random_station_turf()

	var/obj/effect/portal/permanent/one_way/reebe/clock_only/portal = new(atom_turf)

	sleep(1 SECONDS)

	if(!atom_area)
		atom_area = get_area(atom_turf)

	send_clock_message(null, "A portal has been opened at [atom_area] to our holy city, it is a glorious day in the name of Ratvar.", "<span class='bigbrass'>", msg_ghosts = FALSE)
	notify_ghosts("A portal has been opened at [atom_area] to our holy city, it is a glorious day in the name of Ratvar.", source = atom_area, action = NOTIFY_JUMP, flashwindow = FALSE, header = "Portal to Reebe")

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(reebe_station_warning), atom_area, portal), 5 MINUTES)


/// Tells the station that there's a clockie portal, along with making it usable by all
/proc/reebe_station_warning(area/atom_area, obj/effect/portal/permanent/one_way/reebe/clock_only/portal)
	if(!portal)
		return

	send_clock_message(null, "The portal's stability is decreasing! Shortly, those not loyal to Ratvar will be able to enter, and more rifts will open!", "<span class='brass'>")

	sleep(15 SECONDS)

	if(!portal)
		return

	if(!atom_area)
		atom_area = get_area(portal)

	priority_announce("An anomalous reading has been picked up at [atom_area], please ensure the safety of the crew in the vicinity.")

	for(var/obj/effect/landmark/late_cog_portals/late_portal in GLOB.landmarks_list)
		var/obj/effect/landmark/portal_exit/new_exit = new(get_turf(late_portal))
		new_exit.id = "reebe_entry"
		qdel(late_portal)

	portal.visible_message("[portal] lets out a hiss of steam as it becomes a more blue color. You feel like it's safer to enter, now.")
	portal.desc += " It feels easier to enter, now."
	new /obj/effect/temp_visual/steam_release(get_turf(portal))
	animate(portal, 3 SECONDS, color = "#326de3")
	portal.clock_only = FALSE



/obj/item/paper/crumpled/ruins/reebe1
	name = "scribbled note"
	default_raw_text = {"The Justicar was wrong.<br>
	This isn't Reebe. I held out hope, hope that some part of Ratvar was still alive on the holy city.<br>
	But there's nothing here, just some... forward outpost. And damn those Nar'sian dogs! I can feel them trying to enter the portal!"}


/obj/item/paper/crumpled/bloody/reebe2
	name = "scribbled note"
	default_raw_text = {"The heretics made it into this holy ground.<br>
	Many of our brothers and sisters fell in this fight, I am the only one left. It is with pleasure that I can die knowing of the deaths of another group of Nar'sians.<br>
	If only that damnable portal could've opened in time..."}


/obj/effect/mob_spawn/corpse/human/blood_cultist
	name = "Blood Cultist"
	outfit = /datum/outfit/blood_cultist


/datum/outfit/blood_cultist
	name = "Blood Cultist"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt
	shoes = /obj/item/clothing/shoes/cult/alt


/datum/outfit/blood_cultist/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	equipped.eye_color_left = BLOODCULT_EYE
	equipped.eye_color_right = BLOODCULT_EYE
	equipped.update_body()

	var/obj/item/clothing/suit/hooded/hooded = locate() in equipped
	hooded.ToggleHood()


/obj/effect/mob_spawn/corpse/human/clock_cultist
	name = "Clock Cultist"
	outfit = /datum/outfit/clock


/obj/effect/landmark/late_cog_portals
	name = "late cog portal spawn"
