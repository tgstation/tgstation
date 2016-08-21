/obj/effect/lightning
	name = "divine retribution"
	icon = 'icons/effects/224x224.dmi'
	icon_state = null
	pixel_y = -32
	pixel_x = -100
	layer = 16

	proc/start()
		icon_state = "lightning" //i'm sure there's a more elegant way to do this.
		spawn(20)
			qdel(src)

/client/proc/cmd_smite(mob/living/M in mob_list)
	set category = "Fun"
	set name = "Smite"
	if(!holder)
		usr << "no"
		return

	var/confirm = null
	confirm = input(src, "Really smite [M.name]([M.ckey])?", "Divine Retribution") in list("Yeah", "Nah")
	if(confirm == "Nah")
		return
	// Changed so that the damtype isn't used where it shouldn't be used. damtype_word is the word... damtype is an int.
	var/damtype_word = input(src, "What kind of damage?", "PUT YOUR FAITH IN THE LIGHT") in list("burn","brute","oxy","tox","clone","heal","gib")
	var/dam = input(src, "How much damage?", "THE LIGHT SHALL BURN YOU") as num
	var/obj/effect/lightning/L = new /obj/effect/lightning()
	L.loc = get_turf(M.loc)
	L.start()
	playsound(M,'sound/effects/thunder.ogg',50,1)
	switch(damtype_word)
		if("burn")
			M.adjustFireLoss(dam)
		if("brute")
			M.adjustBruteLoss(dam)
		if("oxy")
			M.adjustOxyLoss(dam)
		if("tox")
			M.adjustToxLoss(dam)
		if("heal")
			M.revive()
		if("gib")
			spawn(10) // adding this because it looks a LOT better with this ~ds
				M.gib()

	log_admin("[src]([src.ckey]) smote [M] ([M.ckey]) in [damtype_word] for [dam] damage.")
	message_admins("[src]([src.ckey]) smote [M] ([M.ckey]) in [damtype_word] for [dam] damage.")
