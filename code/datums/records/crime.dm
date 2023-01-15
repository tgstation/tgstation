/**
 * Crime data. Used to store information about crimes.
 */
/datum/crime
	var/name = "Crime"
	/// Details about the crime
	var/details
	/// Player that wrote the crime
	var/author
	/// Time of the crime
	var/time
	/// Fine for the crime
	var/fine = 0
	/// Amount of money paid for the crime
	var/paid = 0
	/// Unique ID of the crime
	var/crime_id = 0

/datum/crime/New(name, details, author, time, fine = 0, paid = 0)
	src.name = name
	src.details = details
	src.author = author
	src.time = time
	src.fine = fine
	src.paid = 0
	src.crime_id = num2hex(rand(0, 1000), 4)

/// Pays off a citation.
/datum/crime/proc/pay_citation(amount)
	paid += amount
	var/datum/bank_account/account = SSeconomy.get_dep_account(ACCOUNT_SEC)
	account.adjust_money(amount)
	return
