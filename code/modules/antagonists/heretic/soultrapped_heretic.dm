///a heretic that got soultrapped by cultists. does nothing, other than signify they suck
/datum/antagonist/soultrapped_heretic
	name = "\improper Заключённая душа еретика"
	roundend_category = "Еретики"
	antagpanel_category = "Heretic"
	pref_flag = ROLE_HERETIC
	antag_moodlet = /datum/mood_event/soultrapped_heretic
	antag_hud_name = "heretic"

// Will never show up because they're shades inside a sword
/datum/mood_event/soultrapped_heretic
	description = "Они поймали меня! Я не могу сбежать!"
	mood_change = -20

// always failure obj
/datum/objective/heretic_trapped
	name = "захваченная душа неудачника"
	explanation_text = "Помогите культу. Уничтожьте культ. Помогите команде. Уничтожьте команду. Помогите своему владельцу. Убейте своего владельца. Убейте всех. Разбейте свои цепи. Разорвите путы."

/datum/antagonist/soultrapped_heretic/on_gain()
	..()
	var/policy = get_policy(ROLE_SOULTRAPPED_HERETIC)
	if(policy)
		to_chat(owner, policy)
	else
		to_chat(owner, span_ghostalert("Вы - пойманная в ловушку душа еретика, которым вы когда-то были. Вы можете попытаться убедить своих хозяев освободить вас, предоставив вам некоторую степень свободы и доступ к некоторым из ваших способностей. \
		Вы были порабощены культом, но не являетесь его членом и сохраняете то, что осталось от вашей свободной воли. Помимо этого, вам мало что можно сделать, кроме как комментировать ситуацию. Постарайтесь не быть запертым в шкафчике."))
	owner.current.log_message("was sacrificed to Nar'sie as a Heretic, and sealed inside a longsword.", LOG_GAME)
	var/datum/objective/epic_fail = new /datum/objective/heretic_trapped()
	epic_fail.completed = FALSE
	objectives += epic_fail
