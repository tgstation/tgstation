/**
 * This proc sends the COMSIG_MOB_WON_VIDEOGAME signal
 *
 * This should be called by games when the gamer reaches a winning state
 */
/mob/proc/won_game()
	SEND_SIGNAL(src, COMSIG_MOB_WON_VIDEOGAME)

/**
 * This proc sends the COMSIG_MOB_LOST_VIDEOGAME signal
 *
 * This should be called by games when the gamer reaches a losing state
 */
/mob/proc/lost_game()
	SEND_SIGNAL(src, COMSIG_MOB_LOST_VIDEOGAME)

/**
 * This proc sends the COMSIG_MOB_PLAYED_VIDEOGAME signal
 *
 * This should be called by games whenever the gamer interacts with the device
 */
/mob/proc/played_game()
	SEND_SIGNAL(src, COMSIG_MOB_PLAYED_VIDEOGAME)
