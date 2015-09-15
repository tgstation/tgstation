#define GOD_A_COLOR red
#define GOD_B_COLOR blue

/*

HAND OF GOD: Cult versus Cult

Hand of God is a competitive gamemode between two fledgling gods.
Upon the start of the round, four antagonists will be assigned.
Two of these will be Gods. They are invisible and function like an AI eye, but by default can only see what their Prophet can.
Prophets are the herald of their God. They are the only ones who can communicate with their God.
Gods have limited power, increased by the Prophet or Followers corrupting tiles in their name or by placing structures.
Gods can intervene with the station's goings-on by using this power, or manifest if they have enough.
Followers cannot hear the words of their God (except occasional snatches). They are converted directly by the God or by the Prophet.
Holy water can be used to deconvert Followers, but Prophets are immune.

Made by Xhuis

*/

/proc/is_prophet(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (ticker.mode.prophet_a == M.mind || ticker.mode.prophet_b == M.mind)

/proc/is_follower(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.followers_a || M.mind in ticker.mode.followers_b)

/proc/is_god(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (ticker.mode.god_a == M.mind || ticker.mode.god_b == M.mind)

/proc/following_who(var/mob/living/L)
	if(!istype(L) && L.mind && ticker && ticker.mode)
		return 0
	var/datum/mind/M = L.mind
	if(!M.god_following)
		return 0
	return M.god_following

/proc/opposing_who(var/mob/living/L)
	if(!istype(L) && L.mind && ticker && ticker.mode)
		return 0
	var/datum/mind/M = L.mind
	if(!M.god_following)
		return 0
	if(!ticker.mode.god_a || !ticker.mode.god_b)
		return 0

	var/first_god = ticker.mode.god_a.current.real_name
	var/second_god = ticker.mode.god_b.current.real_name

	if(M.god_following.name == first_god)
		return second_god
	else if(M.god_following.name == second_god)
		return first_god)
	return "all"

/datum/game_mode
	var/datum/mind/god_a = null
	var/datum/mind/god_b = null
	var/datum/mind/prophet_a = null
	var/datum/mind/prophet_b = null
	var/list/datum/mind/followers_a = list()
	var/list/datum/mind/followers_b = list()

/datum/game_mode/hand_of_god
	name = "hand of god"
	config_tag = "hand_of_god"
	antag_flag = BE_CULTIST //No reason in separating the two
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	protected_jobs = list()
	required_players = 30
	required_enemies = 4
	recommended_enemies = 4
	enemy_minimum_age = 14
	var/god_a = "Space Jesus"
	var/god_b = "Space Satan"

/datum/game_mode/hand_of_god/announce()
	world << "<b>The current game mode is - Hand of God!</b>"
	world << "<b>Two fledgling gods have appeared at the station, and are attempting to grow their power! \
	<br>Gods: Help your Prophet and Followers thrive by taking over station areas and fending off the rival god. \
	<br>Prophets: Spread the word of your God to gain Followers. Commune with your God and carry out their orders. \
	<br>Followers: Obey the Prophet of your God and ensure the security of your area. Prevent the enemy God from gaining power. \
	<br>Crew: Find and eliminate the Prophets and corrupted areas. Deconvert Followers and ensure none of the Gods gain power!"

/datum/game_mode/hand_of_god/proc/greet_god(datum/mind/M)
	if(!is_prophet(M.current))
		return
	if(!god_a || !god_b)
		return

	var/god_being_followed = following_who(M.current)
	if(!god_being_followed)
		return
	var/god_being_opposed = opposing_who(M.current)
	if(!god_being_opposed)
		return

	if(ticker.mode.prophet_b = M)
		M.current << "<span class='big'><b>You are the Prophet of <font color='[GOD_B_COLOR]'>[god_being_followed]!</font></b></span>"
	else
		M.current << "<span class='big'><b>You are the Prophet of <font color='[GOD_A_COLOR]'>[god_being_followed]!</font></b></span>"
	M.current << "<i>You have been deployed to [station_name()] to spread the word of [god_being_followed] to the unenlightened.</i>"
	M.current << "<i>However, you have been warned that the rival god of <b>[god_being_opposed]</b> has also sent a prophet and is attempting to spread their own word!</i>"
	M.current << "<i>Currently, [god_being_followed] is fledgling and weak. They are locked to what you can see, and invisible to you.</i>"
	M.current << "<i>As the prophet, you are the only one who can communicate with [god_being_followed]. Carry out their wishes and do whatever they ask of you.</i>"







//You could call 'em gangs with magic :^)
