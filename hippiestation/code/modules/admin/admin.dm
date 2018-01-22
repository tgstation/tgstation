/datum/admins/proc/HippiePPoptions(mob/M)
	var/body = "<br>"
	if(M.client)
		body += "<A href='?_src_=holder;[HrefToken()];makementor=[M.ckey]'>Make mentor</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];removementor=[M.ckey]'>Remove mentor</A>"
	return body