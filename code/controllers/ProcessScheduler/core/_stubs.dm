/**
 * _stubs.dm
 *
 * This file contains constructs that the process scheduler expects to exist
 * in a standard ss13 fork.
 */
/*
/**
 * message_admins
 *
 * sends a message to admins
 */
/proc/message_admins(msg)
	world << msg
*/
/**
 * logTheThing
 *
 * In goonstation, this proc writes a message to either the world log or diary.
 *
 * Blame Keelin.
 */
/proc/logTheThing(type, source, target, text, diaryType)
	if(diaryType)
		world << "Diary: \[[diaryType]:[type]] [text]"
	else
		world << "Log: \[[type]] [text]"

/**
 * var/disposed
 *
 * In goonstation, disposed is set to 1 after an object enters the delete queue
 * or the object is placed in an object pool (effectively out-of-play so to speak)
 */
/datum/var/disposed
// Garbage collection (controller).
/datum/var/gcDestroyed
/datum/var/timeDestroyed