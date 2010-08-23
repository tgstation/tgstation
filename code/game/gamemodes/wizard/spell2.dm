/mob/proc/kill(mob/M as mob in oview(1))
	set category = "Spells"
	set name = "Shocking Grasp"
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
	usr.verbs -= /mob/proc/kill
	spawn(600)
		usr.verbs += /mob/proc/kill
	usr.say("EI NATH")
	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(4, 1, M)
	s.start()

	M.gib(1)
