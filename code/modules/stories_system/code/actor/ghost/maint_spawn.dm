/datum/story_actor/ghost/spawn_in_maint
	name = "Spawn In Maintenance template"

/datum/story_actor/ghost/spawn_in_maint/send_them_in(mob/living/carbon/human/to_send_human)
	to_send_human.client?.prefs?.safe_transfer_prefs_to(to_send_human)
	. = ..()
	var/atom/spawn_location = SSjob.get_last_resort_spawn_points()
	if(length(GLOB.xeno_spawn))
		spawn_location = pick(GLOB.xeno_spawn)
	spawn_location.JoinPlayerHere(to_send_human, TRUE)

/datum/story_actor/ghost/spawn_in_maint/fugitive
	name = "Fugitive"
	actor_outfits = list(
		/datum/outfit/job/security,
	)
	actor_info = "You've run from the law for so long… it was only a matter of time before you slipped up.\n\n\
	Cornered in a dark maintenance tunnel, with a guard reaching for their alarm, you did what was needed. \
	You snatched their stun baton and zapped 'em until they were singing space shanties. When they stopped moving, you stripped them of their armor and PDA. \
	Not like they need it anymore, and you can't risk getting caught again…"
	actor_goal = "Survive the shift without anyone uncovering your identity."

/datum/story_actor/ghost/spawn_in_maint/fugitive/send_them_in(mob/living/carbon/human/to_send_human)
	. = ..()
	var/obj/item/melee/baton/security/loaded/bloody_baton = new(get_turf(to_send_human))
	bloody_baton.AddElement(/datum/element/decal/blood)
	bloody_baton.deductcharge(bloody_baton.cell_hit_cost * 2)
	var/obj/item/paper/fugitive_newspaper/newspaper_clipping = new(get_turf(to_send_human))
	to_send_human.put_in_hands(bloody_baton, ignore_animation = TRUE)
	to_send_human.put_in_hands(newspaper_clipping, ignore_animation = TRUE)
	// They had these before suiting up as an officer, so their prints will be on them. Since they have the gloves on by default,
	// they don't get the prints, so we manually apply them here with ignoregloves set to true.
	bloody_baton.add_fingerprint(to_send_human, ignoregloves = TRUE)
	newspaper_clipping.add_fingerprint(to_send_human, ignoregloves = TRUE)

/datum/story_actor/ghost/spawn_in_maint/real_guard
	name = "Real Guard"
	actor_outfits = list(
		/datum/outfit/real_guard,
	)
	actor_info = "You groan awake, every muscle in your body begging for solace.\n\n\
	As sense returns, your butt upon the cold steel floor eventually pushes you to your feet. Your head aches and your body shakes, but you're alive at least. \
	As you search the dark tunnels, the memories come flashing back… Someone attacked you. \
	A criminal you cornered in these tunnels, who managed to knock you out with your own stun baton.\n\n\
	And who's now probably running around as a guard."
	actor_goal = "Survive the shift. Find out which of the guards is the fugitive. Convince others of your true identity."

