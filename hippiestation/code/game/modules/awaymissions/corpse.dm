/obj/effect/mob_spawn/attack_ghost(mob/user)	//hippie start, re-add cloning
	if(!SSticker.HasRoundStarted() || !loc || !ghost_usable)
		return
	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be revived!)",,"Yes","No")
	if(ghost_role == "No" || !loc || QDELETED(user))
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER) && !(flags_1 & ADMIN_SPAWNED_1))
		to_chat(user, "<span class='warning'>An admin has temporarily disabled non-admin ghost roles!</span>")
		return
	if(!uses)
		to_chat(user, "<span class='warning'>This spawner is out of charges!</span>")
		return
	if(is_banned_from(user.key, banType))
		to_chat(user, "<span class='warning'>You are jobanned!</span>")
		return
	if(!allow_spawn(user))
		return
	if(QDELETED(src) || QDELETED(user))
		return

	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No" || !loc)
		return
	log_game("[key_name(user)] became [mob_name]")
	create(ckey = user.ckey)
