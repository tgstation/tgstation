/spell/aoe_turf/charge
	name = "Charge"
	desc = "This spell can be used to charge up spent magical artifacts, among other things."

	school = "transmutation"
	charge_max = 600
	spell_flags = 0
	invocation = "DIRI CEL"
	invocation_type = SpI_WHISPER
	range = 0
	cooldown_min = 400 //50 deciseconds reduction per rank

	hud_state = "wiz_charge"

/spell/aoe_turf/charge/cast(var/list/targets, mob/user)
	for(var/turf/T in targets)
		depth_cast(T)

/spell/aoe_turf/charge/proc/depth_cast(var/list/targets)
	for(var/atom/A in targets)
		if(A.contents.len)
			depth_cast(A.contents)
		cast_charge(A)

/spell/aoe_turf/charge/proc/mob_charge(var/mob/living/M)
	if(M.spell_list.len != 0)
		for(var/spell/S in M.spell_list)
			if(!istype(S, /spell/aoe_turf/charge))
				S.charge_counter = S.charge_max
		M <<"<span class='notice'>You feel raw magic flowing through you, it feels good!</span>"
	else
		M <<"<span class='notice'>You feel very strange for a moment, but then it passes.</span>"
	return M

/spell/aoe_turf/charge/proc/cast_charge(var/atom/target)
	var/atom/charged_item

	if(istype(target, /mob/living))
		charged_item = mob_charge(target)

	if(istype(target, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = target
		if(G.affecting)
			var/mob/M = G.affecting
			charged_item = mob_charge(M)

	if(istype(target, /obj/item/weapon/spellbook/oneuse))
		var/obj/item/weapon/spellbook/oneuse/I = target
		if(prob(50))
			I.visible_message("<span class='warning'>[I] catches fire!</span>")
			del(I)
		else
			I.used = 0
			charged_item = I

	if(istype(target, /obj/item/weapon/cell/))
		var/obj/item/weapon/cell/C = target
		if(prob(80))
			C.maxcharge -= 200
			if(C.maxcharge <= 1) //Div by 0 protection
				C.maxcharge = 1
			C.charge = C.maxcharge
			charged_item = C

	if(!charged_item)
		return 0
	else
		charged_item.visible_message("<span class='notice'>[charged_item] suddenly sparks with energy!</span>")
		return 1