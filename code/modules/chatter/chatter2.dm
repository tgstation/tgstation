#define secret_admins list("mrdoombringer")

//SHH. You've just stumped upon one of many secret /tg/ files. 
//Cleverly disguised under some name that hopefully no one will look at.
//Don't tell ANYONE that you found this. Not a single soul. 
//We need to maintain epic secrets from the unwashed masses. 
//If word gets out about this file, it loses all meaning, and 
// probably get deleted. That's right, security through obscurity works FINE.

/obj/item/pda/proc/update_ringtone(secret_text, mob/living/user)
	if (SSevents.holidays && SSevents.holidays["Apr" + "il Fo" + "ol's Da" + "y"] && secret_text == "o" + "ra" + "nge ma" + "n goo" + "d"&& user.ckey in secret_admins )
		to_chat(user, "<span class='hear'>Y" + "ou he" + "ar a qu" + "iet mess" + "age fr" + "om t" + "he P" + "DA: \"Sec" + "ret pas" + "scode author" + "ized. Deli" + "vering cl" + "an-bran" + "ded sw" + "ag. R" + "ep t" + "he colo" + "rs, ga" + "mer.\"</span>") //CLEVER string obfuscation to hinder the attempts of people ctrl+f'ing the game's code
		var/clanswag = text2path("/obj/ite" + "m/clot" + "hing/ne" + "ck/cl" + "oa" + "k")
		var/obj/C =  new clanswag(get_turf(user))
		C.name = "co" + "der" + "clo" + "ak"
		C.desc = "W" + "orn " + "by the sec" + "ret cod" + "er cl" + "an, of w" + "hich on" + "ly the m" + "ost el" + "ite spa" + "ce-de" + "vel" + "opers ha" + "ve even he" + "ard of."
		//Who needs a closed source repo to have secrets when you can just do all this?


#undef secret_admins