var/list/admin_datums = list()

/datum/admins
	var/rank			= "Temporary Admin"
	var/client/owner	= null
	var/rights = 0
	var/fakekey			= null

	var/datum/marked_datum

	var/admincaster_screen = 0	//See newscaster.dm under machinery for a full description
	var/datum/feed_message/admincaster_feed_message = new /datum/feed_message   //These two will act as holders.
	var/datum/feed_channel/admincaster_feed_channel = new /datum/feed_channel
	var/admincaster_signature	//What you'll sign the newsfeeds as
	var/sessKey		= 0

/datum/admins/New(initial_rank = "Temporary Admin", initial_rights = 0, ckey)
	if(!ckey)
		error("Admin datum created without a ckey argument. Datum has been deleted")
		del(src)
		return
	admincaster_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	rank = initial_rank
	rights = initial_rights
	admin_datums[ckey] = src

/datum/admins/proc/associate(client/C)
	if(istype(C))
		owner = C
		owner.holder = src
		owner.add_admin_verbs()	//TODO
		admins |= C

/datum/admins/proc/disassociate()
	if(owner)
		admins -= owner
		owner.remove_admin_verbs()
		owner.holder = null
		owner = null

/*
checks if usr is an admin with at least ONE of the flags in rights_required. (Note, they don't need all the flags)
if rights_required == 0, then it simply checks if they are an admin.
if it doesn't return 1 and show_msg=1 it will prints a message explaining why the check has failed
generally it would be used like so:

proc/admin_proc()
	if(!check_rights(R_ADMIN)) return
	world << "you have enough rights!"

NOTE: it checks usr! not src! So if you're checking somebody's rank in a proc which they did not call
you will have to do something like if(client.rights & R_ADMIN) yourself.
*/
/proc/check_rights(rights_required, show_msg=1)
	if(usr && usr.client)
		if(rights_required)
			if(usr.client.holder)
				if(rights_required & usr.client.holder.rights)
					return 1
				else
					if(show_msg)
						usr << "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>"
		else
			if(usr.client.holder)
				return 1
			else
				if(show_msg)
					usr << "<font color='red'>Error: You are not an admin.</font>"
	return 0

// Making this a bit less of a roaring asspain. - N3X
/mob/proc/check_rights(rights_required)
	if(src && src.client)
		if(rights_required)
			if(src.client.holder)
				if(rights_required & src.client.holder.rights)
					return 1
		else
			if(src.client.holder)
				return 1
	return 0

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr && usr.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return 1
			if(usr.client.holder.rights != other.holder.rights)
				if( (usr.client.holder.rights & other.holder.rights) == other.holder.rights )
					return 1	//we have all the rights they have and more
		usr << "<font color='red'>Error: Cannot proceed. They have more or equal rights to us.</font>"
	return 0



/client/proc/deadmin()
	admin_datums -= ckey
	if(holder)
		holder.disassociate()
		del(holder)
	return 1

/datum/admins/proc/checkSessionKey(var/recurse=0)
	if(recurse==5)
		return "\[BROKEN\]";
	recurse++
	var/DBQuery/query = dbcon.NewQuery("DELETE FROM admin_sessions WHERE expires < Now()")
	query.Execute()

	query = dbcon.NewQuery("SELECT sessID FROM admin_sessions WHERE ckey = '[owner.ckey]' AND expires > Now()")
	query.Execute()

	sessKey=0
	while(query.NextRow())
		//sessKey = query.item[1]
		//ALWAYS UPDATE SESSIONKEY
		query=dbcon.NewQuery("UPDATE admin_sessions SET expires=DATE_ADD(NOW(), INTERVAL 12 HOUR), IP='[owner.address]' WHERE ckey='[owner.ckey]'")
		query.Execute()
		query = dbcon.NewQuery("SELECT sessID FROM admin_sessions WHERE ckey = '[owner.ckey]' AND expires > Now()")
		query.Execute()
		while(query.NextRow())
			sessKey = query.item[1]
			break
		return sessKey

	query=dbcon.NewQuery("INSERT INTO admin_sessions (sessID,ckey,expires, IP) VALUES (UUID(), '[owner.ckey]', DATE_ADD(NOW(), INTERVAL 2 HOUR), '[owner.address]')")
	query.Execute()
	return checkSessionKey(recurse)