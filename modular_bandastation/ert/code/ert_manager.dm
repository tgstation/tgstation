/// If we spawn an ERT with the "choose experienced leader" option, select the leader from the top X playtimes
#define ERT_EXPERIENCED_LEADER_CHOOSE_TOP 3

///Dummy mob reserve slot for admin use
#define DUMMY_HUMAN_SLOT_ADMIN "admintools"

GLOBAL_VAR_INIT(ert_request_answered, FALSE)
GLOBAL_LIST_EMPTY(ert_request_messages)

ADMIN_VERB(ert_manager, R_ADMIN, "ERT Manager", "Manage ERT reqests.", ADMIN_CATEGORY_GAME)
	var/datum/ert_manager/tgui = new(user)
	tgui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("ERT Manager")

/datum/ert_manager
	var/name = "ERT Manager"
	var/ert_type = "Red"
	var/admin_slots = 0 // default
	var/commander_slots = 1 // defaults for open slots
	var/security_slots = 0
	var/medical_slots = 0
	var/engineering_slots = 0
	var/janitor_slots = 0
	var/chaplain_slots = 0
	var/clown_slots = 0
	var/should_be_announced = TRUE

/datum/ert_manager/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/ert_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ErtManager", name)
		ui.autoupdate = TRUE
		ui.open()

/datum/ert_manager/ui_data(mob/user)
	var/list/data = list()
	data["securityLevel"] = capitalize(SSsecurity_level.get_current_level_as_text())
	data["securityLevelColor"] = SSsecurity_level.current_security_level.announcement_color
	data["ertRequestAnswered"] = GLOB.ert_request_answered
	data["ertType"] = ert_type
	data["adminSlots"] = admin_slots
	data["commanderSlots"] = commander_slots
	data["securitySlots"] = security_slots
	data["medicalSlots"] = medical_slots
	data["engineeringSlots"] = engineering_slots
	data["janitorSlots"] = janitor_slots
	data["chaplainSlots"] = chaplain_slots
	data["clownSlots"] = clown_slots
	data["totalSlots"] = commander_slots + security_slots + medical_slots + engineering_slots + janitor_slots + chaplain_slots + clown_slots
	data["ertSpawnpoints"] = length(GLOB.emergencyresponseteamspawn)
	data["shouldBeAnnounced"] = should_be_announced

	data["ertRequestMessages"] = GLOB.ert_request_messages
	return data

/datum/ert_manager/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("toggleErtRequestAnswered")
			GLOB.ert_request_answered = !GLOB.ert_request_answered
		if("ertType")
			ert_type = params["ertType"]
		if("toggleAdmin")
			admin_slots = admin_slots ? 0 : 1
		if("toggleCom")
			commander_slots = commander_slots ? 0 : 1
		if("toggleAnnounce")
			should_be_announced = !should_be_announced
		if("setSec")
			security_slots = text2num(params["setSec"])
		if("setMed")
			medical_slots = text2num(params["setMed"])
		if("setEng")
			engineering_slots = text2num(params["setEng"])
		if("setJan")
			janitor_slots = text2num(params["setJan"])
		if("setInq")
			chaplain_slots = text2num(params["setInq"])
		if("setClw")
			clown_slots = text2num(params["setClw"])
		if("dispatchErt")
			var/datum/ert/ert_type_path
			switch(ert_type)
				if("Amber")
					ert_type_path = /datum/ert/amber
				if("Red")
					ert_type_path = /datum/ert/red
				if("Gamma")
					ert_type_path = /datum/ert/gamma
				if("Inquisition")
					ert_type_path = /datum/ert/inquisition
				else
					to_chat(usr, "<span class='userdanger'>Invalid ERT type.</span>")
					return

			if((commander_slots + medical_slots + janitor_slots + clown_slots + chaplain_slots + security_slots + engineering_slots) == 0)
				message_admins("[key_name_admin(usr)] tried to create a [ert_type] ERT with zero slots available!")
				log_admin("[key_name(usr)] tried to create a [ert_type] ERT with zero slots available.")
				to_chat(usr, span_userdanger("ERT must have at least 1 slot available!"))
				return

			GLOB.ert_request_answered = TRUE
			var/slots_list = list()
			if(commander_slots > 0)
				slots_list += "commander: [commander_slots]"
			if(security_slots > 0)
				slots_list += "security: [security_slots]"
			if(medical_slots > 0)
				slots_list += "medical: [medical_slots]"
			if(engineering_slots > 0)
				slots_list += "engineering: [engineering_slots]"
			if(janitor_slots > 0)
				slots_list += "janitor: [janitor_slots]"
			if(chaplain_slots > 0)
				slots_list += "chaplain: [chaplain_slots]"
			if(clown_slots > 0)
				slots_list += "clown: [clown_slots]"

			var/slot_text = english_list(slots_list)
			message_admins("[key_name_admin(usr)] dispatched a [ert_type] ERT. Slots: [slot_text]")
			log_admin("[key_name(usr)] dispatched a [ert_type] ERT. Slots: [slot_text]")
			if(should_be_announced)
				priority_announce("Внимание, [station_name()]. Ваш запрос ОБР санкционирован. Идёт проверка доступности ресурсов. Результат будет объявлен в течении нескольких минут.", "Активирован протокол ОБР")
			makeERTFromSlots(ert_type_path, admin_slots, commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, chaplain_slots, clown_slots)

		if("view_player_panel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/show_player_panel, locate(params["uid"]))

		if("denyErt")
			GLOB.ert_request_answered = TRUE
			var/message = "[station_name()], уведомляем вас, что развёртывание ОБР в данный момент невозможно."
			if(params["reason"])
				message += " Ваш запрос ОБР был отклонён по данной причине:\n\n[params["reason"]]"
			priority_announce(message, "ОБР недоступен")
		else
			return FALSE

/datum/ert_manager/proc/slots_to_roles(security_slots, medical_slots, engineering_slots, janitor_slots, chaplain_slots, clown_slots, ert_type)
	var/list/roles = list()
	var/slots_sans_leader = security_slots + medical_slots + engineering_slots + janitor_slots + chaplain_slots + clown_slots
	if(ert_type == "Amber")
		for(var/role in 1 to slots_sans_leader)
			if(security_slots > 0)
				roles.Add(/datum/antagonist/ert/security/amber)
				security_slots--
			if(medical_slots > 0)
				roles.Add(/datum/antagonist/ert/medic/amber)
				medical_slots--
			if(engineering_slots > 0)
				roles.Add(/datum/antagonist/ert/engineer/amber)
				engineering_slots--
			if(janitor_slots > 0)
				roles.Add(/datum/antagonist/ert/janitor/amber)
				janitor_slots--
			if(chaplain_slots > 0)
				roles.Add(/datum/antagonist/ert/chaplain/amber)
				chaplain_slots--
			if(clown_slots > 0)
				roles.Add(/datum/antagonist/ert/clown/amber)
				clown_slots--
	if(ert_type == "Red")
		for(var/role in 1 to slots_sans_leader)
			if(security_slots > 0)
				roles.Add(/datum/antagonist/ert/security/red)
				security_slots--
			if(medical_slots > 0)
				roles.Add(/datum/antagonist/ert/medic/red)
				medical_slots--
			if(engineering_slots > 0)
				roles.Add(/datum/antagonist/ert/engineer/red)
				engineering_slots--
			if(janitor_slots > 0)
				roles.Add(/datum/antagonist/ert/janitor/red)
				janitor_slots--
			if(chaplain_slots > 0)
				roles.Add(/datum/antagonist/ert/chaplain/red)
				chaplain_slots--
			if(clown_slots > 0)
				roles.Add(/datum/antagonist/ert/clown/red)
				clown_slots--
	if(ert_type == "Gamma")
		for(var/role in 1 to slots_sans_leader)
			if(security_slots > 0)
				roles.Add(/datum/antagonist/ert/security/gamma)
				security_slots--
			if(medical_slots > 0)
				roles.Add(/datum/antagonist/ert/medic/gamma)
				medical_slots--
			if(engineering_slots > 0)
				roles.Add(/datum/antagonist/ert/engineer/gamma)
				engineering_slots--
			if(janitor_slots > 0)
				roles.Add(/datum/antagonist/ert/janitor/gamma)
				janitor_slots--
			if(chaplain_slots > 0)
				roles.Add(/datum/antagonist/ert/chaplain/gamma)
				chaplain_slots--
			if(clown_slots > 0)
				roles.Add(/datum/antagonist/ert/clown/gamma)
				clown_slots--
	if(ert_type == "Inquisition")
		for(var/role in 1 to slots_sans_leader)
			if(security_slots > 0)
				roles.Add(/datum/antagonist/ert/security/inquisitor)
				security_slots--
			if(medical_slots > 0)
				roles.Add(/datum/antagonist/ert/medic/inquisitor)
				medical_slots--
			if(chaplain_slots > 0)
				roles.Add(/datum/antagonist/ert/chaplain/inquisitor)
				chaplain_slots--
	return roles

/datum/ert_manager/proc/makeERTFromSlots(datum/ert/ert_type_path, admin_slots, commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, chaplain_slots, clown_slots)
	var/datum/ert/ertemplate = new ert_type_path()
	ertemplate.teamsize = commander_slots + security_slots + medical_slots + engineering_slots + janitor_slots + chaplain_slots + clown_slots
	ertemplate.roles = slots_to_roles(security_slots, medical_slots, engineering_slots, janitor_slots, chaplain_slots, clown_slots, ert_type)
	ertemplate.spawn_admin = admin_slots
	ertemplate.leader_role = commander_slots > 0 ? ertemplate.leader_role : null

	var/datum/admins/admin_holder = GLOB.admin_datums[usr.ckey]
	if(!admin_holder)
		stack_trace("Cannot determine the admin executing this proc!")
		return FALSE

	var/spawn_success = admin_holder.make_emergency_response_team(ertemplate, skip_preference_menu = TRUE)

	if(!spawn_success)
		if(should_be_announced)
			minor_announce("[station_name()], уведомляем вас, что развёртывание ОБР в данный момент невозможно.", "ОБР недоступен")
		return FALSE

	if(should_be_announced)
		var/list/team_adj = list("Amber" = "стандартный", "Red" = "усиленный", "Gamma" = "элитный", "Inquisition" = "инквизиторский")
		var/list/team_code = list("Amber" = "ЭМБЕР", "Red" = "РЭД", "Gamma" = "ГАММА", "Inquisition" = "ГАММА")
		var/announcement = "Внимание, [station_name()]. Мы направляем [team_adj[ert_type] || "специальный"] отряд быстрого реагирования кода «[team_code[ert_type] || "ХЗ"]». Ожидайте."
		priority_announce(announcement, "ОБР в пути")

	return TRUE

/obj/effect/landmark/ert_brief_spawn
	name = "ertbriefspawn"
	icon_state = "ert_brief_spawn"

#undef ERT_EXPERIENCED_LEADER_CHOOSE_TOP
#undef DUMMY_HUMAN_SLOT_ADMIN
