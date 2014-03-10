/*
 * Experimental procs by ESwordTheCat.
 */

/*
 * Get index of last char occurence to string.
 *
 * @args
 * string, string to be search
 * char, char used for search
 *
 * @return
 * >0, index of char at string
 *  0, char not found
 * -1, length of string is < 1
 */
/proc/EgijkAeN(var/const/string, var/const/char)
	if (length(string) < 1)
		return -1

	var/i = findtext(string, char)

	if (0 == i)
		return 0

	while(i)
		. = i
		i = findtext(string, char, i + 1)

	return
