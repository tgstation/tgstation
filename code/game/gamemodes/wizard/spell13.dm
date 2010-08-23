/client/proc/blink()
	set category = "Spells"
	set name = "Blink"
	set desc="Blink"
	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		usr << "I don't feel strong enough without my robe."
		return
	if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
		usr << "I don't feel strong enough without my sandals."
		return
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		usr << "I don't feel strong enough without my hat."
		return
	var/list/turfs = new/list()
	for(var/turf/T in orange(6))
		if(istype(T,/turf/space)) continue
		if(T.density) continue
		if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-4 || T.y<4)	continue
		turfs += T
	if(!turfs.len) turfs += pick(/turf in orange(6))
	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()
	var/turf/picked = pick(turfs)
	if(!isturf(picked)) return
	usr.loc = picked
	usr.verbs -= /client/proc/blink
	spawn(40)
		usr.verbs += /client/proc/blink