/client/proc/knock()
	set category = "Spells"
	set name = "Knock"
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
	usr.verbs -= /client/proc/knock
	spawn(100)
		usr.verbs += /client/proc/knock
	usr.say("AULIE OXIN FIERA")
	for(var/obj/machinery/door/G in oview(3))
		spawn(1)
			G.open()
	return
