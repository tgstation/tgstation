
//var/following = null //Gross, but necessary as we loose all concept of who we're following otherwise
/client/proc/mentor_follow(var/mob/living/M)
	if(!check_mentor())
		return

	if(isnull(M))
		return

	if(!istype(usr, /mob))
		return

	if(!holder)
		var/datum/mentors/mentor = mentor_datums[usr.client.ckey]
		mentor.following = M
/*	else
		holder.following = M*/

	usr.reset_perspective(M)
	src.verbs += /client/proc/mentor_unfollow

	message_admins("<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is now following <EM>[key_name(M)]</span>")
	to_chat(usr, "<span class='info'>You are now following [M]. Click the \"Stop Following\" button in the Mentor tab to stop.</span>")
	log_mentor("[key_name(usr)] began following [key_name(M)]")



/client/proc/mentor_unfollow()
	set category = "Mentor"
	set name = "Stop Following"
	set desc = "Stop following the followed."

	if(!check_mentor())
		return

	usr.reset_perspective(null)
	src.verbs -= /client/proc/mentor_unfollow

	var/following = null
	if(!holder)
		var/datum/mentors/mentor = mentor_datums[usr.client.ckey]
		following = mentor.following
	/*else
		following = holder.following*/


	message_admins("<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is no longer following <EM>[key_name(following)]</span>")
	to_chat(usr, "<span class='info'>You are no longer following [following].</span>")
	log_mentor("[key_name(usr)] stopped following [key_name(following)]")

	following = null
