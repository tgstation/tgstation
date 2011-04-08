/obj/spell/teleport
	name = "Teleport"
	desc = "This spell teleports you to a type of area of your selection."

	school = "abjuration"
	charge_max = 600
	clothes_req = 1
	invocation = "SCYAR NILA"
	invocation_type = "none" //hardcoded into the spell due to its specifics
	range = -1 //can affect only the user by default, but with var editing can be a teleport other spell
	var/smoke_spread = 1 //if set to 0, no smoke spreads when teleporting

/obj/spell/teleport/Click()
	..()

	if(!cast_check())
		return

	var/mob/M

	if(range>=0)
		M = input("Choose whom to teleport", "ABRAKADABRA") as mob in view(usr,range)
	else
		M = usr

	if(!M)
		return

	invocation()

	var/A

	A = input("Area to jump to", "BOOYEA", A) in teleportlocs

	var/area/thearea = teleportlocs[A]

	usr.say("[invocation] [uppertext(A)]")
	if(usr.gender=="male")
		playsound(usr.loc, pick('vs_chant_conj_hm.wav','vs_chant_conj_lm.wav','vs_chant_ench_hm.wav','vs_chant_ench_lm.wav','vs_chant_evoc_hm.wav','vs_chant_evoc_lm.wav','vs_chant_illu_hm.wav','vs_chant_illu_lm.wav','vs_chant_necr_hm.wav','vs_chant_necr_lm.wav'), 100, 1)
	else
		playsound(usr.loc, pick('vs_chant_conj_hf.wav','vs_chant_conj_lf.wav','vs_chant_ench_hf.wav','vs_chant_ench_lf.wav','vs_chant_evoc_hf.wav','vs_chant_evoc_lf.wav','vs_chant_illu_hf.wav','vs_chant_illu_lf.wav','vs_chant_necr_hf.wav','vs_chant_necr_lf.wav'), 100, 1)

	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()

	if(smoke_spread)
		smoke.set_up(5, 0, usr.loc)
		smoke.attach(usr)
		smoke.start()

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	M.loc = pick(L)

	if(smoke_spread)
		smoke.start()