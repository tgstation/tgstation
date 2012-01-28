//This looks to be the traitor win tracker code.  Gonna comment it out as we lack it currently.
/*
client/proc/add_roundsjoined()
	if(!makejson)
		return
	var/DBQuery/cquery = dbcon.NewQuery("INSERT INTO `roundsjoined` (`ckey`) VALUES ('[ckey(src.key)]')")
	if(!cquery.Execute()) message_admins(cquery.ErrorMsg())
client/proc/add_roundssurvived()
	if(!makejson)
		return
	var/DBQuery/cquery = dbcon.NewQuery("INSERT INTO `roundsurvived` (`ckey`) VALUES ('[ckey(src.key)]')")
	if(!cquery.Execute()) message_admins(cquery.ErrorMsg())
client/proc/onDeath(var/mob/A = src.mob)
	if(!makejson)
		return
	roundinfo.deaths++
	if(!ismob(A))
		return
	var/ckey = src.ckey
	var/area
	var/attacker
	var/tod = time2text(world.realtime)
	var/health
	var/last
	if(isturf(A.loc))
		area = A.loc:loc:name
	else
		area = A.loc:name
	if(ishuman(A.lastattacker))
		attacker = A.lastattacker:name
	else
		attacker = "None"
	health = "Oxy:[A.oxyloss]Brute:[A.bruteloss]Burn:[A.fireloss]Toxins:[A.toxloss]"
	if(A.logs.len >= 1)
		last = A.logs[A.logs.len]
	else
		last = "None"
	var/DBQuery/cquery = dbcon.NewQuery("INSERT INTO `deathlog` (`ckey`,`location`,`lastattacker`,`ToD`,`health`,`lasthit`) VALUES ('[ckey]',[dbcon.Quote(area)],[dbcon.Quote(attacker)],'[tod]','[health]',[dbcon.Quote(last)])")
	if(!cquery.Execute()) message_admins(cquery.ErrorMsg())
client/proc/onBought(names)
	if(!makejson) return
	if(!names) return
	var/DBQuery/cquery = dbcon.NewQuery("INSERT INTO `traitorbuy` (`type`) VALUES ([dbcon.Quote(names)])")
	if(!cquery.Execute()) message_admins(cquery.ErrorMsg())
*/

datum/roundinfo
	var/core = 0
	var/deaths = 0
	var/revies = 0
	var/starttime = 0
	var/endtime = 0
	var/lenght = 0
	var/mode = 0