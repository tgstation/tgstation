/mob/proc/teleport()
	set category = "Spells"
	set name = "Teleport"
	set desc="Teleport"
	if(!usr.casting()) return
	var/A
	usr.verbs -= /mob/proc/teleport

	var/list/theareas = new/list()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station)) continue
		if(theareas.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == src.z)
			theareas += AR.name
			theareas[AR.name] = AR

	A = input("Area to jump to", "BOOYEA", A) in theareas

	spawn(450)
		usr.verbs += /mob/proc/teleport


	var/area/thearea = theareas[A]

	usr.say("SCYAR NILA [uppertext(A)]")
	usr.spellvoice()

	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, usr.loc)
	smoke.attach(usr)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(T.z != src.z) continue
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	usr.loc = pick(L)

	smoke.start()

/mob/proc/teleportscroll()
	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	var/A

	var/list/theareas = new/list()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station)) continue
		if(theareas.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == src.z)
			theareas += AR.name
			theareas[AR.name] = AR

	A = input("Area to jump to", "BOOYEA", A) in theareas
	var/area/thearea = theareas[A]

	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, usr.loc)
	smoke.attach(usr)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(T.z != src.z) continue
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	usr.loc = pick(L)

	smoke.start()