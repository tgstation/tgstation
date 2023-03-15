//Section for the Mentor Friend verb

/client/proc/imaginary_friend()
	set category = "Mentor"
	set name = "Become Imaginary Friend"
	set hidden = 1

	if(!usr.client.is_mentor())
		return

	if(istype(usr, /mob/camera/imaginary_friend/mentor))
		to_chat(usr, span_warning("You are already someone's imaginary friend!"))
		return

	if(!isobserver(usr))
		to_chat(usr, span_warning("You can only be an imaginary friend when you are observing."))
		return

	var/mob/living/mentee

	switch(input("Select by:", "Imaginary Friend") as null|anything in list("Key", "Mob"))
		if("Key")
			var/list/friendlist = list()
			for(var/mob/living/friend in GLOB.player_list)
				friendlist |= friend.client
			var/client/friendclient = input("Please, select a key.", "Imaginary Friend") as null|anything in sortKey(friendlist)
			if(!friendclient)
				return
			mentee = friendclient.mob
		if("Mob")
			var/list/friendlist = list()
			for(var/mob/living/friend in GLOB.player_list)
				friendlist |= friend
			var/mob/friendmob = input("Please, select a mob.", "Imaginary Friend") as null|anything in sortNames(friendlist)
			if(!friendmob)
				return
			mentee = friendmob

	if(!isobserver(usr))
		return

	if(!istype(mentee))
		to_chat(usr, span_warning("Selected mob is not alive."))
		return

	var/mob/camera/imaginary_friend/mentor/mentorfriend = new(get_turf(mentee), mentee)
	mentorfriend.key = usr.key

	log_admin("[key_name(mentorfriend)] started being the imaginary friend of [key_name(mentee)].")
	message_admins("[key_name(mentorfriend)] started being the imaginary friend of [key_name(mentee)].")

/client/proc/end_imaginary_friendship()
	set category = "Mentor"
	set name = "End Imaginary Friendship"
	set hidden = 1

	if(!usr.client.is_mentor())
		return

	if(!istype(usr, /mob/camera/imaginary_friend/mentor))
		to_chat(usr, span_warning("You aren't anybody's imaginary friend!"))
		return

	var/mob/camera/imaginary_friend/mentor/mentorfriend = usr
	mentorfriend.unmentor()

//Section for the Mentor Friend mob.
/mob/camera/imaginary_friend/mentor

	var/datum/action/innate/imaginary_leave/leave


/mob/camera/imaginary_friend/mentor/greet()
	to_chat(src, "<span class='notice'><b>You are the imaginary friend of [owner]!</b></span>")
	to_chat(src, "<span class='notice'>You are here to help [owner] in any way you can.</span>")
	to_chat(src, "<span class='notice'>You cannot directly influence the world around you, but you can see what [owner] cannot.</span>")

/mob/camera/imaginary_friend/mentor/Login()
	. = ..()
	setup_friend()
	Show()

/mob/camera/imaginary_friend/mentor/Logout()
	. = ..()
	if(!src.key)
		return
	unmentor()

/mob/camera/imaginary_friend/mentor/Initialize(mapload, mob/owner)
	. = ..()
	src.owner = owner
	copy_languages(owner, LANGUAGE_FRIEND)
	join = new
	join.Grant(src)
	hide = new
	hide.Grant(src)
	leave = new
	leave.Grant(src)


/mob/camera/imaginary_friend/mentor/setup_friend()
	name = client.prefs.real_name
	gender = client.prefs.gender
	real_name = name
	human_image = get_flat_human_icon(null, SSjob.GetJobType(/datum/job/assistant), client.prefs,,list(SOUTH),/datum/outfit/job/mentor)

/mob/camera/imaginary_friend/mentor/proc/unmentor()
	icon = human_image
	log_admin("[key_name(src)] stopped being the imaginary friend of [key_name(owner)].")
	message_admins("[key_name(src)] stopped being the imaginary friend of [key_name(owner)].")
	ghostize()
	qdel(src)

/mob/camera/imaginary_friend/mentor/recall()
	if(QDELETED(owner))
		unmentor()
		return FALSE
	if(loc == owner)
		return FALSE
	forceMove(owner)

/datum/action/innate/imaginary_hide/mentor/Deactivate()
	active = FALSE
	var/mob/camera/imaginary_friend/I = owner
	I.hidden = TRUE
	I.Show()
	name = "Show"
	desc = "Become visible to your owner."
	button_icon_state = "unhide"
	UpdateButtonIcon()

/datum/action/innate/imaginary_leave
	name = "Leave"
	desc = "Stop mentoring."
	icon_icon = 'icons/mob/actions/actions_vr.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "logout"

/datum/action/innate/imaginary_leave/Activate()
	var/mob/camera/imaginary_friend/mentor/I = owner
	I.unmentor()


//For use with Mentor Friend (IF) topic calls

/client/proc/create_ifriend(mob/living/friend_owner, seek_confirm = FALSE)
	var/client/C = usr.client
	if(!usr.client.is_mentor())
		return

	if(istype(C.mob, /mob/camera/imaginary_friend))
		var/mob/camera/imaginary_friend/IF = C.mob
		IF.ghostize()
		return

	if(!istype(friend_owner)) // living only
		to_chat(usr, span_warning("That creature cannot have Imaginary Friends!"))
		return

	if(!isobserver(C.mob))
		to_chat(usr, span_warning("You can only be an imaginary friend when you are observing."))
		return


	if(seek_confirm && alert(usr, "Become Imaginary Friend of [friend_owner]?", "Confirm" ,"Yes", "No") != "Yes")
		return

	var/mob/camera/imaginary_friend/mentor/mentorfriend = new(get_turf(friend_owner), friend_owner)
	mentorfriend.key = usr.key

	admin_ticket_log(friend_owner, "[key_name_admin(C)] became an imaginary friend of [key_name(friend_owner)]")
	log_admin("[key_name(mentorfriend)] started being imaginary friend of [key_name(friend_owner)].")
	message_admins("[key_name(mentorfriend)] started being the imaginary friend of [key_name(friend_owner)].")

//topic call
/client/proc/mentor_friend(href_list)
	if(href_list["mentor_friend"])
		var/mob/M = locate(href_list["mentor_friend"])
		create_ifriend(M, TRUE)

//for Mentor Chat Messages

