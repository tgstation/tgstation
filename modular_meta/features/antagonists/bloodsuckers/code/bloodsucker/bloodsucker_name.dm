
/datum/antagonist/bloodsucker/proc/return_full_name()
	var/fullname = bloodsucker_name ? bloodsucker_name : owner.current.name
	if(bloodsucker_title)
		fullname = "[bloodsucker_title] [fullname]"
	if(bloodsucker_reputation)
		fullname += " the [bloodsucker_reputation]"

	return fullname

///Returns a First name for the Bloodsucker.
/datum/antagonist/bloodsucker/proc/SelectFirstName()
	if(owner.current.gender == MALE)
		bloodsucker_name = pick(
			"Desmond","Rudolph","Dracula","Vlad","Pyotr","Gregor",
			"Cristian","Christoff","Marcu","Andrei","Constantin",
			"Gheorghe","Grigore","Ilie","Iacob","Luca","Mihail","Pavel",
			"Vasile","Octavian","Sorin","Sveyn","Aurel","Alexe","Iustin",
			"Theodor","Dimitrie","Octav","Damien","Magnus","Caine","Abel", // Romanian/Ancient
			"Lucius","Gaius","Otho","Balbinus","Arcadius","Romanos","Alexios","Vitellius", // Latin
			"Melanthus","Teuthras","Orchamus","Amyntor","Axion", // Greek
			"Thoth","Thutmose","Osorkon,","Nofret","Minmotu","Khafra", // Egyptian
			"Dio",
		)
	else
		bloodsucker_name = pick(
			"Islana","Tyrra","Greganna","Pytra","Hilda",
			"Andra","Crina","Viorela","Viorica","Anemona",
			"Camelia","Narcisa","Sorina","Alessia","Sophia",
			"Gladda","Arcana","Morgan","Lasarra","Ioana","Elena",
			"Alina","Rodica","Teodora","Denisa","Mihaela",
			"Svetla","Stefania","Diyana","Kelssa","Lilith", // Romanian/Ancient
			"Alexia","Athanasia","Callista","Karena","Nephele","Scylla","Ursa", // Latin
			"Alcestis","Damaris","Elisavet","Khthonia","Teodora", // Greek
			"Nefret","Ankhesenpep", // Egyptian
		)

///Returns a Title for the Bloodsucker.
/datum/antagonist/bloodsucker/proc/SelectTitle(am_fledgling = 0, forced = FALSE)
	// Already have Title
	if(!forced && bloodsucker_title != null)
		return
	// Titles [Master]
	if(am_fledgling)
		bloodsucker_title = null
		return
	if(owner.current.gender == MALE)
		bloodsucker_title = pick(
			"Count",
			"Baron",
			"Viscount",
			"Prince",
			"Duke",
			"Tzar",
			"Dreadlord",
			"Lord",
			"Master",
		)
	else
		bloodsucker_title = pick(
			"Countess",
			"Baroness",
			"Viscountess",
			"Princess",
			"Duchess",
			"Tzarina",
			"Dreadlady",
			"Lady",
			"Mistress",
		)
	to_chat(owner, span_announce("You have earned a title! You are now known as <i>[return_full_name()]</i>!"))

///Returns a Reputation for the Bloodsucker.
/datum/antagonist/bloodsucker/proc/SelectReputation(am_fledgling = FALSE, forced = FALSE)
	// Already have Reputation
	if(!forced && bloodsucker_reputation != null)
		return

	if(am_fledgling)
		bloodsucker_reputation = pick(
			"Crude",
			"Callow",
			"Unlearned",
			"Neophyte",
			"Novice",
			"Unseasoned",
			"Fledgling",
			"Young",
			"Neonate",
			"Scrapling",
			"Untested",
			"Unproven",
			"Unknown",
			"Newly Risen",
			"Born",
			"Scavenger",
			"Unknowing",
			"Unspoiled",
			"Disgraced",
			"Defrocked",
			"Shamed",
			"Meek",
			"Timid",
			"Broken",
			"Fresh",
		)
	else if(owner.current.gender == MALE && prob(10))
		bloodsucker_reputation = pick(
			"King of the Damned",
			"Blood King",
			"Emperor of Blades",
			"Sinlord",
			"God-King",
		)
	else if(owner.current.gender == FEMALE && prob(10))
		bloodsucker_reputation = pick(
			"Queen of the Damned",
			"Blood Queen",
			"Empress of Blades",
			"Sinlady",
			"God-Queen",
		)
	else
		bloodsucker_reputation = pick(
			"Butcher","Blood Fiend","Crimson","Red","Black","Terror",
			"Nightman","Feared","Ravenous","Fiend","Malevolent","Wicked",
			"Ancient","Plaguebringer","Sinister","Forgotten","Wretched","Baleful",
			"Inqisitor","Harvester","Reviled","Robust","Betrayer","Destructor",
			"Damned","Accursed","Terrible","Vicious","Profane","Vile",
			"Depraved","Foul","Slayer","Manslayer","Sovereign","Slaughterer",
			"Forsaken","Mad","Dragon","Savage","Villainous","Nefarious",
			"Inquisitor","Marauder","Horrible","Immortal","Undying","Overlord",
			"Corrupt","Hellspawn","Tyrant","Sanguineous",
		)

	to_chat(owner, span_announce("You have earned a reputation! You are now known as <i>[return_full_name()]</i>!"))
