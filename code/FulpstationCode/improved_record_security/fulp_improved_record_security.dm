#define SEC_RECORD_BAD_CLEARANCE "ACCESS DENIED: User ID has inadequate clearance."

/obj/machinery/computer/secure_data/proc/check_input_clearance(mob/M, delete = FALSE)
	if(!issilicon(M) && !IsAdminGhost(M)) //Silicons and AdminGhosts ignore access checks.
		var/obj/item/card/id/I = M.get_idcard(TRUE)
		if(!I)
			return FALSE
		req_access = list(ACCESS_SECURITY, ACCESS_ARMORY)
		if(delete) //Wardens can modify security record entries, but cannot delete them; only HoS, Silicons and Captain can do that.
			req_access = list(ACCESS_SECURITY, ACCESS_ARMORY, ACCESS_KEYCARD_AUTH)
		if(!check_access(I))
			req_access = null
			return FALSE
		req_access = null
	return TRUE

/obj/machinery/computer/secure_data/proc/delete_allrecords_feedback()
	temp = ""
	if(check_input_clearance(usr, TRUE))
		temp += "<h5><b>Are you sure you wish to delete all Security records?</b></h5><br>"
		temp += "<a href='?src=[REF(src)];choice=Purge All Records'>Yes</a><br>"
		temp += "<a href='?src=[REF(src)];choice=Clear Screen'>No</a>"
	else
		temp += "<a href='?src=[REF(src)];choice=Clear Screen'><b>[SEC_RECORD_BAD_CLEARANCE]</b></a>"
	return temp


/obj/machinery/computer/secure_data/proc/delete_record_feedback(type = "Security Portion Only")
	temp = ""
	if(check_input_clearance(usr, TRUE))
		temp = "<h5><b>Are you sure you wish to delete the record ([type])?</b></h5><br>"
		temp += "<a href='?src=[REF(src)];choice=Delete Record ([type]) Execute'>Yes</a><br>"
		temp += "<a href='?src=[REF(src)];choice=Clear Screen'>No</a>"
	else
		temp += "<a href='?src=[REF(src)];choice=Clear Screen'><b>[SEC_RECORD_BAD_CLEARANCE]</b></a>"

	return temp