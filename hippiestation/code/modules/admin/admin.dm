/datum/admins/proc/HippiePPoptions(mob/M)
	var/body = "<br>"
	if(M.client)
		body += "<A href='?_src_=mentor;[HrefToken()];makementor=[M.ckey]'>Make mentor</A> | "
		body += "<A href='?_src_=mentor;[HrefToken()];removementor=[M.ckey]'>Remove mentor</A>"
	return body