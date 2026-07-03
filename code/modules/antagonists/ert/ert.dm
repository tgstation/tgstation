//Both ERT and DS are handled by the same datums since they mostly differ in equipment in objective.
/datum/team/ert
	name = "Отряд быстрого реагирования"
	var/datum/objective/mission //main mission

/datum/antagonist/ert
	name = "Офицер ОБР"
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	antagpanel_category = ANTAG_GROUP_ERT
	suicide_cry = "FOR NANOTRASEN!!"
	// Not 'true' antags, this disables certain interactions that assume the owner is a baddie
	antag_flags = ANTAG_FAKE|ANTAG_SKIP_GLOBAL_LIST
	desensitized_modifier = DESENSITIZED_THRESHOLD * 0.5
	var/datum/team/ert/ert_team
	var/leader = FALSE
	var/datum/outfit/outfit = /datum/outfit/centcom/ert/security
	var/datum/outfit/plasmaman_outfit = /datum/outfit/plasmaman/centcom_official
	var/role = "Сотрудник службы безопасности"
	var/list/name_source
	var/random_names = TRUE
	var/rip_and_tear = FALSE
	var/equip_ert = TRUE
	var/forge_objectives_for_ert = TRUE
	/// Typepath indicating the kind of job datum this ert member will have.
	var/ert_job_path = /datum/job/ert_generic


/datum/antagonist/ert/on_gain()
	if(random_names)
		update_name()
	if(forge_objectives_for_ert)
		forge_objectives()
	if(equip_ert)
		equipERT()
	. = ..()

/datum/antagonist/ert/get_team()
	return ert_team

/datum/antagonist/ert/New()
	. = ..()
	name_source = GLOB.last_names

/datum/antagonist/ert/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(name_source)]")

/datum/antagonist/ert/official
	name = "Представитель Центрального Командования"
	show_name_in_check_antagonists = TRUE
	var/datum/objective/mission
	role = "Инспектор"
	random_names = FALSE
	outfit = /datum/outfit/centcom/centcom_official

/datum/antagonist/ert/official/greet()
	. = ..()
	if (ert_team)
		to_chat(owner, "<span class='warningplain'>Центральное командование отправляет вас на [station_name()] с следующей задачей: [ert_team.mission.explanation_text]</span>")
	else
		to_chat(owner, "<span class='warningplain'>Центральное командование отправляет вас на [station_name()] с следующей задачей: [mission.explanation_text]</span>")

/datum/antagonist/ert/official/forge_objectives()
	if (ert_team)
		return ..()
	if(mission)
		return
	var/datum/objective/missionobj = new ()
	missionobj.owner = owner
	missionobj.explanation_text = "Проведите проверку работоспособности [station_name()] и её Капитана."
	missionobj.completed = TRUE
	mission = missionobj
	objectives |= mission

/datum/antagonist/ert/security // kinda handled by the base template but here for completion

/datum/antagonist/ert/security/red
	outfit = /datum/outfit/centcom/ert/security/alert

/datum/antagonist/ert/engineer
	role = "Инженер"
	outfit = /datum/outfit/centcom/ert/engineer

/datum/antagonist/ert/engineer/red
	outfit = /datum/outfit/centcom/ert/engineer/alert

/datum/antagonist/ert/medic
	role = "Медик"
	outfit = /datum/outfit/centcom/ert/medic

/datum/antagonist/ert/medic/red
	outfit = /datum/outfit/centcom/ert/medic/alert

/datum/antagonist/ert/commander
	role = "Командир"
	outfit = /datum/outfit/centcom/ert/commander
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander

/datum/antagonist/ert/commander/red
	outfit = /datum/outfit/centcom/ert/commander/alert

/datum/antagonist/ert/janitor
	role = "Уборщик"
	outfit = /datum/outfit/centcom/ert/janitor

/datum/antagonist/ert/janitor/heavy
	role = "Уборщик-специалист"
	outfit = /datum/outfit/centcom/ert/janitor/heavy

/datum/antagonist/ert/deathsquad
	name = "Deathsquad Trooper"
	outfit = /datum/outfit/centcom/death_commando
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander
	role = "Trooper"
	rip_and_tear = TRUE

/datum/antagonist/ert/deathsquad/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/antagonist/ert/deathsquad/leader
	name = "Deathsquad Officer"
	outfit = /datum/outfit/centcom/death_commando/officer
	role = "Officer"

/datum/antagonist/ert/medic/inquisitor
	outfit = /datum/outfit/centcom/ert/medic/inquisitor

/datum/antagonist/ert/medic/inquisitor/on_gain()
	. = ..()
	owner.set_holy_role(HOLY_ROLE_PRIEST)

/datum/antagonist/ert/security/inquisitor
	outfit = /datum/outfit/centcom/ert/security/inquisitor

/datum/antagonist/ert/security/inquisitor/on_gain()
	. = ..()
	owner.set_holy_role(HOLY_ROLE_PRIEST)

/datum/antagonist/ert/chaplain
	role = "Священник"
	outfit = /datum/outfit/centcom/ert/chaplain

/datum/antagonist/ert/chaplain/inquisitor
	outfit = /datum/outfit/centcom/ert/chaplain/inquisitor

/datum/antagonist/ert/chaplain/on_gain()
	. = ..()
	owner.set_holy_role(HOLY_ROLE_PRIEST)

/datum/antagonist/ert/commander/inquisitor
	outfit = /datum/outfit/centcom/ert/commander/inquisitor

/datum/antagonist/ert/commander/inquisitor/on_gain()
	. = ..()
	owner.set_holy_role(HOLY_ROLE_PRIEST)

/datum/antagonist/ert/intern
	name = "Стажёр ЦК"
	outfit = /datum/outfit/centcom/centcom_intern
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_intern
	random_names = FALSE
	role = "Стажёр ЦК"
	suicide_cry = "FOR MY INTERNSHIP!!"

/datum/antagonist/ert/intern/leader
	name = "Главный стажёр ЦК"
	outfit = /datum/outfit/centcom/centcom_intern/leader
	random_names = FALSE
	role = "Главный стажёр"

/datum/antagonist/ert/intern/unarmed
	outfit = /datum/outfit/centcom/centcom_intern/unarmed

/datum/antagonist/ert/intern/leader/unarmed
	outfit = /datum/outfit/centcom/centcom_intern/leader/unarmed

/datum/antagonist/ert/clown
	role = "Клоун"
	outfit = /datum/outfit/centcom/ert/clown
	plasmaman_outfit = /datum/outfit/plasmaman/party_comedian

/datum/antagonist/ert/clown/New()
	. = ..()
	name_source = GLOB.clown_names

/datum/antagonist/ert/janitor/party
	role = "Служба уборки праздников"
	outfit = /datum/outfit/centcom/ert/janitor/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_janitor

/datum/antagonist/ert/security/party
	role = "Вышибала праздника"
	outfit = /datum/outfit/centcom/ert/security/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_bouncer

/datum/antagonist/ert/engineer/party
	role = "Праздничный строитель"
	outfit = /datum/outfit/centcom/ert/engineer/party
	plasmaman_outfit = /datum/outfit/plasmaman/party_constructor

/datum/antagonist/ert/clown/party
	role = "Праздничный комик"
	outfit = /datum/outfit/centcom/ert/clown/party

/datum/antagonist/ert/commander/party
	role = "Координатор праздника"
	outfit = /datum/outfit/centcom/ert/commander/party

/datum/antagonist/ert/create_team(datum/team/ert/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/ert/bounty_armor
	role = "Бронированный охотник за головами"
	outfit = /datum/outfit/bountyarmor/ert

/datum/antagonist/ert/bounty_hook
	role = "Охотник за головами с крюком"
	outfit = /datum/outfit/bountyhook/ert

/datum/antagonist/ert/bounty_synth
	role = "Синтетический охотник за головами"
	outfit = /datum/outfit/bountysynth/ert

/datum/antagonist/ert/forge_objectives()
	if(ert_team)
		objectives |= ert_team.objectives

/datum/antagonist/ert/proc/equipERT()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	if(isplasmaman(H))
		H.dna.species.outfit_important_for_life = plasmaman_outfit

	H.dna.species.give_important_for_life(H)
	H.equipOutfit(outfit)

	if(isplasmaman(H))
		var/obj/item/mod/control/our_modsuit = locate() in H.get_equipped_items()
		if(our_modsuit)
			our_modsuit.install(new /obj/item/mod/module/plasma_stabilizer)

/datum/antagonist/ert/greet()
	if(!ert_team)
		return

	to_chat(owner, "<span class='warningplain'><B><font size=3 color=red>Вы - [name].</font></B></span>")

	var/missiondesc = "Ваш отряд был отправлен с миссией на [station_name()] департаментом защиты активов Нанотрейзен."
	if(leader) //If Squad Leader
		missiondesc += " Возглавьте свой отряд, чтобы обеспечить выполнение миссии. Отправляйтесь на шаттл, когда ваша команда будет готова."
	else
		missiondesc += " Следуйте приказам, отданным вашим лидером отряда."
	if(!rip_and_tear)
		missiondesc += " Избегайте жертв среди гражданских, если это возможно."

	missiondesc += "<span class='warningplain'><BR><B>Ваша задача</B>: [ert_team.mission.explanation_text]</span>"
	to_chat(owner,missiondesc)

/datum/antagonist/ert/marine
	name = "Командир морпехов"
	outfit = /datum/outfit/centcom/ert/marine
	role = "Командир"

/datum/antagonist/ert/marine/security
	name = "Тяжёлый морпех"
	outfit = /datum/outfit/centcom/ert/marine/security
	role = "Боец"

/datum/antagonist/ert/marine/engineer
	name = "Инженер морпех"
	outfit = /datum/outfit/centcom/ert/marine/engineer
	role = "Инженер"

/datum/antagonist/ert/marine/medic
	name = "Медик морпех"
	outfit = /datum/outfit/centcom/ert/marine/medic
	role = "Медицинский офицер"

/datum/antagonist/ert/militia
	name = "Пограничное ополчение"
	outfit = /datum/outfit/centcom/militia
	role = "Доброволец"

/datum/antagonist/ert/militia/general
	name = "Генерал пограничного ополчения"
	outfit = /datum/outfit/centcom/militia/general
	role = "Генерал"

/datum/antagonist/ert/medical_commander
	role = "Главный парамедик"
	outfit = /datum/outfit/centcom/ert/medical_commander
	plasmaman_outfit = /datum/outfit/plasmaman/medical_commander

/datum/antagonist/ert/medical_technician
	role = "Фельдшер"
	outfit = /datum/outfit/centcom/ert/medical_technician
	plasmaman_outfit = /datum/outfit/plasmaman/medical_technician
