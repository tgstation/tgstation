/datum/antagonist/vampire
	var/usable_blood = 0
	var/total_blood = 0
	var/fullpower = FALSE
	var/draining
	var/list/objectives_given = list()

	var/iscloaking = FALSE

	var/list/powers = list() // list of current powers

	var/obj/item/clothing/suit/draculacoat/coat

	var/list/upgrade_tiers = list(
		/obj/effect/proc_holder/spell/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/targeted/hypnotise = 0,
		/datum/vampire_passive/vision = 175,
		/obj/effect/proc_holder/spell/self/shapeshift = 175,
		/obj/effect/proc_holder/spell/self/cloak = 225,
		/obj/effect/proc_holder/spell/targeted/disease = 275,
		/obj/effect/proc_holder/spell/bats = 350,
		/obj/effect/proc_holder/spell/self/batform = 350,
		/obj/effect/proc_holder/spell/self/screech = 315,
		/datum/vampire_passive/regen = 425,
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform = 500,
		/datum/vampire_passive/full = 666,
		/obj/effect/proc_holder/spell/self/summon_coat = 666,
		/obj/effect/proc_holder/spell/targeted/vampirize = 700,
		/obj/effect/proc_holder/spell/self/revive = 800)

/datum/antagonist/vampire/on_gain()
	SSticker.mode.vampires += owner
	give_objectives()
	check_vampire_upgrade()
	owner.special_role = "vampire"
	owner.current.faction += "vampire"
	SSticker.mode.update_vampire_icons_added(owner)
	..()

/datum/antagonist/vampire/on_removal()
	remove_vampire_powers()
	owner.current.faction -= "vampire"
	SSticker.mode.vampires -= owner
	owner.special_role = null
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		if(owner && H.hud_used && H.hud_used.vamp_blood_display)
			H.hud_used.vamp_blood_display.invisibility = INVISIBILITY_ABSTRACT
	SSticker.mode.update_vampire_icons_removed(owner)
	for(var/O in objectives_given)
		owner.objectives -= O
	LAZYCLEARLIST(objectives_given)
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'>Your powers have been quenched! You are no longer a vampire</span>")
	owner.special_role = null
	..()

/datum/antagonist/vampire/greet()
	to_chat(owner, "<span class='userdanger'>You are a Vampire!</span>")
	to_chat(owner, "<span class='danger bold'>You are a creature of the night -- holy water, the chapel, and space will cause you to burn.</span>")
	to_chat(owner, "<span class='notice bold'>Hit someone in the head with harm intent to start sucking their blood. However, only blood from living creatures is usable!</span>")
	to_chat(owner, "<span class='notice bold'>Coffins will heal you.</span>")
	if(LAZYLEN(objectives_given))
		owner.announce_objectives()

/datum/antagonist/vampire/proc/give_objectives()
	var/datum/objective/blood/blood_objective = new
	blood_objective.owner = owner
	blood_objective.gen_amount_goal()
	add_objective(blood_objective)

	for(var/i = 1, i < CONFIG_GET(number/traitor_objectives_amount), i++)
		forge_single_objective()

	if(!(locate(/datum/objective/escape) in owner.objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/vampire/proc/add_objective(var/datum/objective/O)
	owner.objectives += O
	objectives_given += O

/datum/antagonist/vampire/proc/forge_single_objective() //Returns how many objectives are added
	.=1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		add_objective(steal_objective)

/datum/antagonist/vampire/proc/vamp_burn(var/severe_burn = FALSE)
	var/mob/living/L = owner.current
	if(!L)
		return
	var/burn_chance = severe_burn ? 35 : 8
	if(prob(burn_chance) && L.health >= 50)
		switch(L.health)
			if(75 to 100)
				L.visible_message("<span class='warning'>[L]'s skin begins to flake!</span>", "<span class='danger'>Your skin flakes away...</span>")
			if(50 to 75)
				L.visible_message("<span class='warning'>[L]'s skin sizzles loudly!</span>", "<span class='danger'>Your skin sizzles!</span>", "You hear sizzling.")
		L.adjustFireLoss(3)
	else if(L.health < 50)
		if(!L.on_fire)
			L.visible_message("<span class='warning'>[L] catches fire!</span>", "<span class='danger'>Your skin catches fire!</span>")
			L.emote("scream")
		else
			L.visible_message("<span class='warning'>[L] continues to burn!</span>", "<span class='danger'>Your continue to burn!</span>")
		L.adjust_fire_stacks(5)
		L.IgniteMob()
	return

/datum/antagonist/vampire/proc/check_sun()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	var/ax = C.x
	var/ay = C.y

	for(var/i = 1 to 20)
		ax += SSsun.dx
		ay += SSsun.dy

		var/turf/T = locate(round(ax, 0.5), round(ay, 0.5), C.z)

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)
			break

		if(T.density)
			return
	vamp_burn(TRUE)

/datum/antagonist/vampire/proc/vampire_life()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	if(owner && C.hud_used && C.hud_used.vamp_blood_display)
		C.hud_used.vamp_blood_display.invisibility = FALSE
		C.hud_used.vamp_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(usable_blood, 1)]</font></div>"
	handle_vampire_cloak()
	if(istype(C.loc, /obj/structure/closet/coffin))
		C.adjustBruteLoss(-4)
		C.adjustFireLoss(-4)
		C.adjustToxLoss(-4)
		C.adjustOxyLoss(-4)
		return
	if(!get_ability(/datum/vampire_passive/full) && istype(get_area(C.loc), /area/chapel))
		vamp_burn()
	if(isspaceturf(C.loc))
		check_sun()


/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/H)
	draining = H
	var/mob/living/carbon/human/O = owner.current
	var/blood = 0
	var/old_bloodtotal = 0 //used to see if we increased our blood total
	var/old_bloodusable = 0 //used to see if we increased our blood usable
	log_attack("[O] ([O.ckey]) bit [H] ([H.ckey]) in the neck")
	O.visible_message("<span class='danger'>[O] grabs [H]'s neck harshly and sinks in their fangs!</span>", "<span class='danger'>You sink your fangs into [H] and begin to drain their blood.</span>", "<span class='notice'>You hear a soft puncture and a wet sucking noise.</span>")
	if(!iscarbon(owner))
		H.LAssailant = null
	else
		H.LAssailant = O
	playsound(O.loc, 'sound/weapons/bite.ogg', 50, 1)
	while(do_mob(O, H, 50))
		if(!is_vampire(O))
			to_chat(O, "<span class='warning'>Your fangs have disappeared!</span>")
			return
		old_bloodtotal = total_blood
		old_bloodusable = usable_blood
		if(!H.blood_volume)
			to_chat(O, "<span class='warning'>They've got no blood left to give.</span>")
			break
		if(H.stat != DEAD)
			blood = min(20, H.blood_volume)// if they have less than 20 blood, give them the remnant else they get 20 blood
			total_blood += blood / 2	//divide by 2 to counted the double suction since removing cloneloss -Melandor0
			usable_blood += blood / 2
		else
			blood = min(5, H.blood_volume)	// The dead only give 5 blood
			total_blood += blood
		check_vampire_upgrade()
		if(old_bloodtotal != total_blood)
			to_chat(O, "<span class='notice'><b>You have accumulated [total_blood] [total_blood > 1 ? "units" : "unit"] of blood[usable_blood != old_bloodusable ? ", and have [usable_blood] left to use" : ""].</b></span>")
		H.blood_volume = max(H.blood_volume - 25, 0)
		if(ishuman(O))
			O.nutrition = min(O.nutrition + (blood / 2), NUTRITION_LEVEL_WELL_FED)
		playsound(O.loc, 'sound/items/eatfood.ogg', 40, 1)

	draining = null
	to_chat(owner, "<span class='notice'>You stop draining [H.name] of blood.</span>")

/datum/antagonist/vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.AddSpell(spell)
	powers += spell

/datum/antagonist/vampire/proc/get_ability(path)
	for(var/P in powers)
		var/datum/power = P
		if(power.type == path)
			return power
	return null

/datum/antagonist/vampire/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)

/datum/antagonist/vampire/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		owner.spell_list.Remove(ability)
		qdel(ability)


/datum/antagonist/vampire/proc/remove_vampire_powers()
	for(var/P in powers)
		remove_ability(P)
	owner.current.alpha = 255

/datum/antagonist/vampire/proc/check_vampire_upgrade(var/announce = TRUE)
	var/list/old_powers = powers.Copy()
	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(total_blood >= level)
			add_ability(ptype)
	if(announce)
		announce_new_power(old_powers)
	owner.current.update_sight() //deal with sight abilities

/datum/antagonist/vampire/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell))
				var/obj/effect/proc_holder/spell/power = p
				to_chat(owner.current, "<span class='notice'>[power.gain_desc]</span>")
			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner, "<span class='notice'>[power.gain_desc]</span>")

/datum/antagonist/vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner.current))
		owner.current.alpha = 255
		return
	var/mob/living/carbon/human/H = owner.current
	var/turf/T = get_turf(H)
	var/light_available = T.get_lumcount()

	if(!istype(T))
		return 0

	if(!iscloaking)
		H.alpha = 255
		return 0

	if(light_available <= 0.25)
		H.alpha = round((255 * 0.15))
		return 1
	else
		H.alpha = round((255 * 0.80))
