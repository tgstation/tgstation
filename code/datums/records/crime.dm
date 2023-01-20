/**
 * Crime data. Used to store information about crimes.
 */
/datum/crime
	/// Name of the crime
	var/name
	/// Details about the crime
	var/details
	/// Player that wrote the crime
	var/author
	/// Time of the crime
	var/time

/datum/crime/New(name = "Crime", details = "No details provided.", author = "Anonymous", time = station_time_timestamp())
	src.author = author
	src.details = details
	src.name = name
	src.time = time

/datum/crime/citation
	/// Fine for the crime
	var/fine
	/// Amount of money paid for the crime
	var/paid

/datum/crime/citation/New(name = "Citation", details = "No details provided.", author = "Anonymous", time = station_time_timestamp(), fine = 0, paid = 0)
	. = ..()
	src.fine = fine
	src.paid = paid

/// Pays off a fine and attempts to fix any weird values.
/datum/crime/citation/proc/pay_fine(amount)
	paid += amount
	if(paid > fine)
		paid = fine

	fine -= amount
	if(fine < 0)
		fine = 0

	return TRUE
