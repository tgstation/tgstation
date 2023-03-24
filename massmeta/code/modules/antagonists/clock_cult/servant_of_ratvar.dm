//==========================
//====  Servant antag   ====
//==========================

/datum/antagonist/servant_of_ratvar
	name = "Servant Of Ratvar"
	roundend_category = "clock cultists"
	antagpanel_category = "Clockcult"
	antag_moodlet = /datum/mood_event/cult
	job_rank = ROLE_SERVANT_OF_RATVAR
	antag_hud_name = "clockwork"

	//The class of the servant
	var/datum/action/cooldown/clockcult/transmit/transmit_spell
	var/datum/team/clock_cult/team

	var/prefix = CLOCKCULT_PREFIX_RECRUIT

	var/counts_towards_total = TRUE//Counts towards the total number of servants.

	var/mutable_appearance/forbearance

/datum/antagonist/servant_of_ratvar/greet()
	if(!owner.current)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/clockcultalr.ogg', 60, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, span_heavy_brass("<font size='7'>Чувствую вспышку света, и мир кружится вокруг меня!</font>"))
	to_chat(owner.current, span_brass("<font size='5'>Используя механизм, я могу призывать различные силы, которые помогут мне выполнить волю Ратвара.</font>"))
	to_chat(owner.current, span_brass("Используя консоли наблюдения Ратвара, я могу следить за командой и перемещаться на станцию."))
	to_chat(owner.current, span_brass("Используя мехазим, я могу вызвать интеграционные шестерни, чтобы разблокировать больше Священных Писаний и откачать энергию."))
	to_chat(owner.current, span_brass("Стоит разблокировать Разжечь, чтобы оглушать цели, Оковы ненависти, чтобы сдерживать их, и надо использовать знак подчинения, чтобы конвертировать их!"))
	to_chat(owner.current, span_brass("В конце нужно будет соберать 6 культистов вокруг Ковчега и активировать его, чтобы вызвать Рат'вара, но сначала надо подготовиться."))

/datum/antagonist/servant_of_ratvar/on_gain()
	. = ..()
	create_team()
	add_objectives()
	GLOB.all_servants_of_ratvar |= owner
	if(counts_towards_total)
		GLOB.servants_of_ratvar |= owner
		if(ishuman(owner.current))
			GLOB.human_servants_of_ratvar |= owner
		else if(iscyborg(owner.current))
			GLOB.cyborg_servants_of_ratvar |= owner
	check_ark_status()
	owner.announce_objectives()

/datum/antagonist/servant_of_ratvar/on_removal()
	team.remove_member(owner)
	GLOB.servants_of_ratvar -= owner
	GLOB.all_servants_of_ratvar -= owner
	GLOB.human_servants_of_ratvar -= owner
	GLOB.cyborg_servants_of_ratvar -= owner
	. = ..()

/datum/antagonist/servant_of_ratvar/apply_innate_effects(mob/living/M)
	. = ..()
	owner.current.faction |= "ratvar"
	transmit_spell = new()
	transmit_spell.Grant(owner.current)
	if(GLOB.gateway_opening && ishuman(owner.current))
		var/mob/living/carbon/owner_mob = owner.current
		forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
		owner_mob.add_overlay(forbearance)
	owner.current.throw_alert("clockinfo", /atom/movable/screen/alert/clockwork/clocksense)
	var/datum/language_holder/LH = owner.current.get_language_holder()
	LH.grant_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_CULTIST)
	add_team_hud(owner.current)

/datum/antagonist/servant_of_ratvar/remove_innate_effects(mob/living/M)
	owner.current.faction -= "ratvar"
	owner.current.clear_alert("clockinfo")
	transmit_spell.Remove(transmit_spell.owner)
	if(forbearance && ishuman(owner.current))
		var/mob/living/carbon/owner_mob = owner.current
		owner_mob.remove_overlay(forbearance)
		qdel(forbearance)
	var/datum/language_holder/LH = owner.current.get_language_holder()
	LH.remove_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_CULTIST)
	. = ..()

/datum/antagonist/servant_of_ratvar/proc/equip_servant_conversion()
	//Equipment apply
	var/mob/living/H = owner.current
	if(istype(H, /mob/living/carbon))
		equip_carbon(H)
	else if(istype(H, /mob/living/silicon))
		equip_silicon(H)

//Remove clown mutation
//Give the device
/datum/antagonist/servant_of_ratvar/proc/equip_servant()
	var/mob/living/H = owner.current
	var/datum/outfit/clockwork_outfit = new /datum/outfit/clockcult
	if(istype(H, /mob/living/carbon))
		clockwork_outfit.equip(H)

/datum/antagonist/servant_of_ratvar/proc/equip_carbon(mob/living/carbon/H)
	//Convert all items in their inventory to Ratvarian
	var/list/contents = H.get_contents()
	for(var/atom/A in contents)
		A.ratvar_act()
	//Equip them with a slab
	var/obj/item/clockwork/clockwork_slab/slab = new(get_turf(H))
	H.put_in_hands(slab)
	slab.pickup(H)
	//Remove cuffs
	H.uncuff()
	return FALSE

//Grant access to the clockwork tools.
//If AI, disconnect all active borgs and make it only able to control converted shells
/datum/antagonist/servant_of_ratvar/proc/equip_silicon(mob/living/silicon/S)
	if(isAI(S))
		var/mob/living/silicon/ai/AI = S
		AI.disconnect_shell()
		for(var/mob/living/silicon/robot/R in AI.connected_robots)
			R.connected_ai = null
		var/mutable_appearance/ai_clock = mutable_appearance('massmeta/icons/mob/clockwork_mobs.dmi', "aiframe")
		AI.add_overlay(ai_clock)
	else if(iscyborg(S))
		var/mob/living/silicon/robot/R = S
		R.connected_ai = null
		R.SetRatvar(TRUE)
	S.laws = new /datum/ai_laws/ratvar     //Laws down here so borgs don't instantly resync their laws
	S.laws.associate(S)
	S.show_laws()

/datum/antagonist/servant_of_ratvar/proc/add_objectives()
	objectives |= team.objectives

/datum/antagonist/servant_of_ratvar/get_team()
	return team

/datum/antagonist/servant_of_ratvar/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_convertable_to_clockcult(new_owner.current)

/datum/antagonist/servant_of_ratvar/create_team()
	for(var/datum/antagonist/servant_of_ratvar/H in GLOB.antagonists)
		if(!H.owner)
			continue
		if(H.team)
			team = H.team
			return
	team = new /datum/team/clock_cult
	team.setup_objectives()

//==========================
//==== Clock cult team  ====
//==========================

/datum/team/clock_cult
	name = "Servants Of Ratvar"

/datum/team/clock_cult/proc/setup_objectives()
	objectives = list(new /datum/objective/clockcult)

/datum/antagonist/servant_of_ratvar/get_preview_icon()
	var/icon/clockie_icon = icon('massmeta/icons/effects/512x512.dmi', "ratvar")

	clockie_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return clockie_icon
