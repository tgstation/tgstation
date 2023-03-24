//==================================//
// !      Sigil of Vitality ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_vitality
	name = "Матрица жизнеспособности"
	desc = "Призывает матрицу жизнеспособности, которая истощает жизненную силу не слуг, и может использоваться для исцеления или оживления слуг. Требуется 2 вызывающих."
	tip = "Исцеляйте и воскрешайте мертвых слуг, высасывая при этом здоровье не-слуг."
	button_icon_state = "Sigil of Vitality"
	power_cost = 300
	invokation_time = 50
	invokation_text = list("My life in your hands.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/vitality
	cogs_required = 2
	invokers_required = 2
	category = SPELLTYPE_SERVITUDE

//==========Vitality=========
/obj/structure/destructible/clockwork/sigil/vitality
	name = "матрица жизнеспособности"
	desc = "Извилистый, сбивающий с толку артефакт, истощающий при соприкосновении с неподготовленным."
	clockwork_desc = "Красивый артефакт, который истощит жизнь еретиков, помещенных на него."
	icon_state = "sigilvitality"
	effect_stand_time = 20
	idle_color = "#5e87c4"
	invokation_color = "#83cbe7"
	pulse_color = "#c761d4"
	fail_color = "#525a80"
	looping = TRUE

/obj/structure/destructible/clockwork/sigil/vitality/can_affect(mob/living/M)
	if(is_servant_of_ratvar(M))
		return TRUE
	if(M.stat == DEAD)
		return FALSE
	var/amc = M.can_block_magic(MAGIC_RESISTANCE)
	if(amc)
		return FALSE
	if(HAS_TRAIT(M, TRAIT_NODEATH))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/vitality/apply_effects(mob/living/M)
	if(!..())
		return FALSE
	if(is_servant_of_ratvar(M))
		if(M.stat == DEAD)
			var/damage_healed = 20 + ((M.maxHealth - M.health) * 0.6)
			if(GLOB.clockcult_vitality >= damage_healed)
				GLOB.clockcult_vitality -= damage_healed
				M.revive(TRUE, TRUE)
				if(M.mind)
					M.mind.grab_ghost(TRUE)
				else
					var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Хочешь быть [M.name], который решил выйти из игры?", ROLE_SERVANT_OF_RATVAR, null, 50, M)
					if(LAZYLEN(candidates))
						var/mob/dead/observer/C = pick(candidates)
						message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(M)]) to replace an AFK player.")
						M.key = C.key
			else
				visible_message(span_neovgre("[src] не может воскресить [M]!"))
			return
		var/healing_performed = clamp(M.maxHealth - M.health, 0, 5)	//5 Vitality to heal 5 of all damage types at once
		if(GLOB.clockcult_vitality >= healing_performed * 0.3)
			GLOB.clockcult_vitality -= healing_performed * 0.3
			//Do healing
			M.adjustBruteLoss(-5, FALSE)
			M.adjustFireLoss(-5, FALSE)
			M.adjustOxyLoss(-5, FALSE)
			M.adjustToxLoss(-5, FALSE)
			M.adjustCloneLoss(-5)
		else
			visible_message(span_neovgre("[src] не может воскресить [M]!") , span_neovgre("Недостаточно жизненных сил, чтобы залечить раны!"))
	else
		if(M.can_block_magic(MAGIC_RESISTANCE))
			return
		M.Paralyze(10)
		M.adjustCloneLoss(20)
		playsound(loc, 'sound/magic/clockwork/ratvar_attack.ogg', 40)
		if(M.stat == DEAD && length(GLOB.servant_spawns))
			M.become_husk()
			M.death()
			playsound(loc, 'sound/magic/exit_blood.ogg', 60)
			to_chat(M, span_neovgre("Моя жизнь это ничто..."))
			hierophant_message("[M] был высосан полностью [src]!", null, "<span class='inathneq'>")
			var/mob/cogger = new /mob/living/simple_animal/drone/cogscarab(get_turf(M))
			cogger.key = M.key
			add_servant_of_ratvar(cogger, silent=TRUE)
			return
		if(M.client)
			M.visible_message(span_neovgre("[src] выглядит слабым, так как цвет его тела бледнеет.") , span_neovgre("ДуША рАЗаЛиВаЕтсЯ..."))
			GLOB.clockcult_vitality += 30
		GLOB.clockcult_vitality += 10
