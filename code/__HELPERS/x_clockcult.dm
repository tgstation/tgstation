#define CLOCKCULT_SERVANTS 4

//component id defines; sometimes these may not make sense in regards to their use in scripture but important ones are bright
#define BELLIGERENT_EYE "belligerent_eye" //! Use this for offensive and damaging scripture!
#define VANGUARD_COGWHEEL "vanguard_cogwheel" //! Use this for defensive and healing scripture!
#define GEIS_CAPACITOR "geis_capacitor" //! Use this for niche scripture!
#define REPLICANT_ALLOY "replicant_alloy"
#define HIEROPHANT_ANSIBLE "hierophant_ansible" //! Use this for construction-related scripture!

//Invokation speech types
#define INVOKATION_WHISPER 1
#define INVOKATION_SPOKEN 2
#define INVOKATION_SHOUT 3

#define DEFAULT_CLOCKSCRIPTS "6:-29,4:-2"

//scripture types
#define SPELLTYPE_ABSTRACT "Abstract"
#define SPELLTYPE_SERVITUDE "Servitude"
#define SPELLTYPE_PRESERVATION "Preservation"
#define SPELLTYPE_STRUCTURES "Structures"

//Trap type
#define TRAPMOUNT_WALL 1
#define TRAPMOUNT_FLOOR 2

//Conversion warnings
#define CONVERSION_WARNING_NONE 0
#define CONVERSION_WARNING_HALFWAY 1
#define CONVERSION_WARNING_THREEQUARTERS 2
#define CONVERSION_WARNING_CRITIAL 3

//Name types
#define CLOCKCULT_PREFIX_EMINENCE 2
#define CLOCKCULT_PREFIX_MASTER 1
#define CLOCKCULT_PREFIX_RECRUIT 0

//from base of atom/ratvar_act(): ()
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"
//from base of atom/eminence_act(): ()
#define COMSIG_ATOM_EMINENCE_ACT "atom_eminence_act"

//from base of atom/ratvar_act(): ()
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"
//from base of atom/eminence_act(): ()
#define COMSIG_ATOM_EMINENCE_ACT "atom_eminence_act"

#define COMSIG_CLOCKWORK_SIGNAL_RECEIVED "clockwork_signal_received"

#define iseminence(A) (istype(A, /mob/living/simple_animal/eminence))

#define iscogscarab(A) (istype(A, /mob/living/simple_animal/drone/cogscarab))

#define TRAIT_STARGAZED "stargazed"	//Affected by a stargazer

#define HOLYWATER_TRAIT "holywater"
#define VANGUARD_TRAIT "vanguard"
#define STARGAZER_TRAIT "stargazer"

GLOBAL_LIST_EMPTY(all_servants_of_ratvar)	//List of minds in the cult
GLOBAL_LIST_EMPTY(human_servants_of_ratvar)	//Humans in the cult
GLOBAL_LIST_EMPTY(cyborg_servants_of_ratvar)

GLOBAL_VAR(ratvar_arrival_tick)	//The world.time that Ratvar will arrive if the gateway is not disrupted

GLOBAL_VAR_INIT(installed_integration_cogs, 0)

GLOBAL_VAR(celestial_gateway)	//The celestial gateway
GLOBAL_VAR_INIT(ratvar_risen, FALSE)	//Has ratvar risen?
GLOBAL_VAR_INIT(gateway_opening, FALSE)	//Is the gateway currently active?

//A useful list containing all scriptures with the index of the name.
//This should only be used for looking up scriptures
GLOBAL_LIST_EMPTY(clockcult_all_scriptures)

GLOBAL_VAR_INIT(clockcult_power, 2500)
GLOBAL_VAR_INIT(clockcult_vitality, 200)

GLOBAL_VAR(clockcult_eminence)

/proc/is_servant_of_ratvar(mob/living/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/servant_of_ratvar)

//Similar to cultist one, except silicons are allowed
/proc/is_convertable_to_clockcult(mob/living/M)
	if(!istype(M))
		return FALSE
	if(!M.mind)
		return FALSE
	if(ishuman(M) && (M.mind.assigned_role in list(JOB_CAPTAIN, JOB_CHAPLAIN)))
		return FALSE
	if(is_servant_of_ratvar(M))
		return FALSE
	if(M.mind.enslaved_to && !is_servant_of_ratvar(M.mind.enslaved_to))
		return FALSE
	if(M.mind.unconvertable)
		return FALSE
	if(IS_CULTIST(M) || isconstruct(M) || ispAI(M))
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return FALSE
	return TRUE

/proc/generate_clockcult_scriptures()
	//Generate scriptures
	for(var/categorypath in subtypesof(/datum/clockcult/scripture))
		var/datum/clockcult/scripture/S = new categorypath
		GLOB.clockcult_all_scriptures[S.name] = S

/proc/flee_reebe()
	for(var/mob/living/M in GLOB.mob_list)
		if(!is_reebe(M.z))
			continue
		var/safe_place = find_safe_turf()
		M.forceMove(safe_place)
		if(!is_servant_of_ratvar(M))
			M.SetSleeping(50)

/proc/hierophant_message(msg, mob/living/sender, span = "<span class='brass'>", use_sanitisation=TRUE, say=TRUE)
	var/hierophant_message = "[span]"
	if(sender?.reagents)
		if(sender.reagents.has_reagent(/datum/reagent/water/holywater, 1))
			to_chat(sender, "<span class='nezbere'>[pick("You fail to transmit your cries for help.", "Your calls into the void go unanswered.", "You try to transmit your message, but the hierophant network is silent.")]</span>")
			return FALSE
	if(!msg)
		if(sender)
			to_chat(sender, "<span class='brass'>You cannot transmit nothing!</span>")
		return FALSE
	if(use_sanitisation)
		msg = sanitize(msg)
	if(sender)
		if(say)
			sender.say("#[text2ratvar(msg)]")
		msg = sender.treat_message(msg)
		var/datum/antagonist/servant_of_ratvar/SoR = is_servant_of_ratvar(sender)
		var/prefix = "Clockbrother"
		switch(SoR.prefix)
			if(CLOCKCULT_PREFIX_EMINENCE)
				prefix = "Master"
			if(CLOCKCULT_PREFIX_MASTER)
				prefix = sender.gender == MALE\
					? "Clockfather"\
					: sender.gender == FEMALE\
						? "Clockmother"\
						: "Clockmaster"
				hierophant_message = "<span class='leader_brass'>"
			if(CLOCKCULT_PREFIX_RECRUIT)
				var/datum/job/role = sender.mind?.assigned_role
				//Ew, this could be done better with a dictionary list, but this isn't much slower
				if(/datum/job_department/command in role.departments_list)
					prefix = "High Priest"
				else if(/datum/job_department/engineering in role.departments_list)
					prefix = "Cogturner"
				else if(/datum/job_department/medical in role.departments_list)
					prefix = "Rejuvinator"
				else if(/datum/job_department/science in role.departments_list)
					prefix = "Calculator"
				else if(/datum/job_department/cargo in role.departments_list)
					prefix = "Pathfinder"
				else if(istype(role, /datum/job/assistant))
					prefix = "Helper"
				else if(istype(role, /datum/job/mime))
					prefix = "Cogwatcher"
				else if(istype(role, /datum/job/clown))
					prefix = "Clonker"
				else if(/datum/job_department/security in role.departments_list)
					prefix = "Warrior"
				else if(/datum/job_department/silicon in role.departments_list)
					prefix = "CPU"
			//Fallthrough is default of "Clockbrother"
		hierophant_message += "<b>[prefix] [sender.name]</b> transmits, \"[msg]\""
	else
		hierophant_message += msg
	if(span)
		hierophant_message += "</span>"
	for(var/datum/mind/mind in GLOB.all_servants_of_ratvar)
		send_hierophant_message_to(mind, hierophant_message)
	for(var/mob/dead/observer/O in GLOB.dead_mob_list)
		if(istype(sender))
			to_chat(O, "[FOLLOW_LINK(O, sender)] [hierophant_message]")
		else
			to_chat(O, hierophant_message)

/proc/send_hierophant_message_to(datum/mind/mind, hierophant_message)
	var/mob/M = mind.current
	if(!isliving(M) || QDELETED(M))
		return
	if(M.reagents)
		if(M.reagents.has_reagent(/datum/reagent/water/holywater, 1))
			if(pick(20))
				to_chat(M, "<span class='nezbere'>You hear the cogs whispering to you, but cannot understand their words.</span>")
			return
	to_chat(M, hierophant_message)

//I hate niggers
#define span_brass(str) ("<span class='brass'>" + str + "</span>")
#define span_heavy_brass(str) ("<span class='heavy_brass'>" + str + "</span>")
#define span_large_brass(str) ("<span class='large_brass'>" + str + "</span>")
#define span_big_brass(str) ("<span class='big_brass'>" + str + "</span>")
#define span_ratvar(str) ("<span class='ratvar'>" + str + "</span>")
#define span_nezbere(str) ("<span class='nezbere'>" + str + "</span>")
#define span_nzcrentr(str) ("<span class='nzcrentr'>" + str + "</span>")
#define span_neovgre(str) ("<span class='neovgre'>" + str + "</span>")
#define span_inathneq(str) ("<span class='inathneq'>" + str + "</span>")
#define span_sevtug(str) ("<span class='sevtug'>" + str + "</span>")
#define span_alloy(str) ("<span class='alloy'>" + str + "</span>")
#define span_caution(str) ("<span class='сaution'>" + str + "</span>")
