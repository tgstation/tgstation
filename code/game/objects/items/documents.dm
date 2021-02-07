/obj/item/documents
	name = "secret documents"
	desc = "\"Top Secret\" documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	inhand_icon_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = MOB_LAYER
	pressure_resistance = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/documents/nanotrasen
	desc = "\"Top Secret\" Nanotrasen documents, filled with complex diagrams and lists of names, dates and coordinates."
	icon_state = "docs_verified"

/obj/item/documents/syndicate
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence."

/obj/item/documents/syndicate/red
	name = "red secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. These documents are verified with a red wax seal."
	icon_state = "docs_red"

/obj/item/documents/syndicate/blue
	name = "blue secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. These documents are verified with a blue wax seal."
	icon_state = "docs_blue"

/obj/item/documents/syndicate/mining
	desc = "\"Top Secret\" documents detailing Syndicate plasma mining operations."

/obj/item/documents/photocopy
	desc = "A copy of some top-secret documents. Nobody will notice they aren't the originals... right?"
	var/forgedseal = 0
	var/copy_type = null

/obj/item/documents/photocopy/New(loc, obj/item/documents/copy=null)
	..()
	if(copy)
		copy_type = copy.type
		if(istype(copy, /obj/item/documents/photocopy)) // Copy Of A Copy Of A Copy
			var/obj/item/documents/photocopy/C = copy
			copy_type = C.copy_type

/obj/item/documents/photocopy/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/toy/crayon/red) || istype(O, /obj/item/toy/crayon/blue))
		if (forgedseal)
			to_chat(user, "<span class='warning'>You have already forged a seal on [src]!</span>")
		else
			var/obj/item/toy/crayon/C = O
			name = "[C.crayon_color] secret documents"
			icon_state = "docs_[C.crayon_color]"
			forgedseal = C.crayon_color
			to_chat(user, "<span class='notice'>You forge the official seal with a [C.crayon_color] crayon. No one will notice... right?</span>")
			update_icon()

/obj/item/inspector
	name = "\improper N-spect scanner"
	desc = "Central Command issued inspection device. Performs inspections according to Nanotrasen protocols when activated, then \
			prints encrypted reports regarding the maintenance of the station. Hard to replace."
	icon = 'icons/obj/device.dmi'
	icon_state = "inspector"
	worn_icon_state = "salestagger"
	inhand_icon_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1

/obj/item/inspector/attack_self(mob/user)
	. = ..()
	if(do_after(user, 5 SECONDS, target = user, progress=TRUE))
		print_report()

///Prints out a report for bounty purposes, and plays a short audio blip.
/obj/item/inspector/proc/print_report()
	// Create our report
	var/obj/item/paper/report/slip = new(get_turf(src))
	slip.scanned_area = get_area(src)
	playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)

/obj/item/paper/report
	name = "encrypted station inspection"
	desc = "Contains detailed information about the station's current status."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "slipfull"
	///What area the inspector scanned when the report was made. Used to verify the security bounty.
	var/area/scanned_area
	show_written_words = FALSE
	info = "^O£%e^d}*a.. whi*$!}e..?An*$!£%d!!£%y~~'..~~'wa-^ m}~~'}a}^^-*£%}*~'b£%a*}ng-^..W....£%ood~-~'^*..y~~'? -~^~'ot$$!!$!}*$!o£%!o!?d}?.?$--!$!} ^e- *..}c£%ou*..-l$~~£%'d n..o*$!*-~~'l£%-o*?*?ger *he£%£%$!$!~'lp!?££%%^!h!!-$-..?!i*^s?**l....^!}}-^!!! *?~~'e? ..$!w?a}*.*-.$!£%}£%$!e.?.?d? ^-!$!as- A$-!nd~~'~~'y-.. ?s$!$!$!$!t-$$!!$~~'!o*-?e? hi!!^~?.~'s j^?i-c}^- k£%?^aw-ai..}$$!^i c*£%~~-'o.-~~'c^~!!'k. H?e~-$!£%~~'^$!!??? ^??£%p$?*$!$!p£%o$!c!!?ed And..^y*£%**$!hi^c*?h}£?%?*$!..!?^$!-t}*~£%'a*tl!-*!-e$!}*£$!%.*$!~~'!!^hi?m a?^*n*$! !!ma£%~!!'!!$!$!$!^ ~~~~~~''?'^h-im}$! ^p^*e-^! ?-.£%~~'e??^!!e^r.}!!..$!w.?.h}er*e$! ^n}!! th!!£?-%? ^*?}*£%..l-o$!!£%!}?$!^*r£%£% ~~'-£%*n.}~-$!'??~~^'- ^-£%}n..* -Wo-o~~'}!.*.d}£% ..£%too?£.!!.^*.!!- !!-B..^%in*..$!...-£^!!%?~~'$!d$!$!~~'^$!^-..e}*c!$!!!~~'£}%!h~~}'e!!~~' i*}? hi~~'!!-}.$!$?!^-r*^in* mad$^}*^^ !!~~'!*^}}-im.... £%$!!!?h-$!?~'$!ar....d$!}er t$!h£%£%a*£%}n e..ver!£% *..~~'£%$!.}--.o$!*!!$!-}y£%£-% }'A?d^y Se!!.n}p?a^i!..^$! }£%'..*} ?}..~~'liv^£££%%%e~~'*£!!}a$^}n-^}}^d ?? ^*!!a!!n££%%~~'t~~'$!}* t^o$!£%$! b^}e ?$!N££%%*}!?!!S-IDE--£%~~'.*.-- £%...*!!O~~'F YO^!!-~~'U!!.' A!!.^?d*y-?* '^h.$!Woo*}..d^ C!!$!£%an^}!..~~'!? I ..£%*?..a*ways$!^k?*?~~-'..?}!£%!!!!!!*}!!*you }£%*%w-*£%..r}~~'e? ^$*!a*~~'^^£!!%-iv*%£%?$}! ^~~'I~~'£%!!$!} ^£$!-%£%..!!!!a-!!$}*~-£%!!..!t} }£%*to ~~'stu^!!f} yo}!! ?£~~'%-up ..?m..-y- k}!!awa*i^^£....~~'$?!^$!i ^ass^'.~~'.£%** Wo}*o}dy!! g*r}~~'~}..'..a£~!!£%~..%bbe!!d }a£%-?~~~~''b£}%?}£!!%n^h o!!^}?-£% £%~~'f^*lavo-e?^-$!-l~*!!~'!^!*e? ^a}n..!^!.-* r£%-ubbed it all*?..?-..^e^-r~~' }h..i~~'s h£%?*ead ?W*£%o?~$!~'d!!y??:-^!!'O$!..h$! !£..%!$!-m-y~~'$*!*?$!$!$$!!$!$}I*t?$$!$!.~!!~'?s~*~'*? c-!!*}£%er..r^*^!?^? ^}lav~..~'o?re*d£% ..-lu..$!£%£%e-}!*?$$!!£%..!*-$!..-C^?^^^h?^..£~~'%e£%*-r..*^!y* $!i!!s}~~' ^.^.$!*$!y*- fa?v}o^i~}~}'}-e??$!-!!.%!!W!!o~~'..o-d$$!!y^~^* t!!^^.*.h^?en *.*.*u~~'f-f}*ed}$-^}!-hi..s!!.....*£%^%~~'hea*^.. ^u£%££%..!! in£%t..}$!o?$! A~~'-}-!!d£%y~~'s $..$!~^'!~^.?.~~~''!!gh^^.£%^.}t£$!% a^^ss..£%*-.. Th!!%!$!}~}$!~'-* -}ot!!?}$!~~'r$!£..?!-!to-^!!!!^! a?rou$!^n*~}~'d- ..th..£%-e}}~~'r-~~^'o£%~~'!?!£%^ ..$!a^t£!!%c^}h~~'~}£%~*}!!-d?!$!!^ £%$!!!n^t!!ent!!!!$-!-~~'!y£%^!!*!!a$..-s$! W$!*..£%o$~~'!d$!.y$!$!!£%..*h^$!..v^}d }}.?...i..s h!!}..e*^ad!! .?.b~~'^ack$!!!!..!-n}d£!!!*!-}!!. f~~!^!?'ort$!~?~'h?^*in^*t^o£?$!!?!% *£%A£~~'..^ndy?'..^-^ *£%-^!}*$!c--..$!}.^!!.^} $!?..as--!~~'£%!-, $*!$!}..on^t~^~£%'}in?u^o^..!!}s?!l--} ..~~'~~'?aki-$!ng..^!!?£% ^!!.}$..!?.~~~~~~''?' .~~'?.^s!!~~'q-~~~~'}*!£}%!-....!!h£%..y w?et n}$!??i-?}e~~'..^.. Th^e? $!o^th..e.*£%}!!r~~'} t!!?}$!}s£*^%..£%a}~~'-lso~~'--$!be$!c..ame !!*}a$!!!..r}.ou..s??.^...$!~}~' }...}£}.*}n^d-! t$!he!!$!y .-.**a}?ll~~'*g}}-£%t}..£%£^%}^r}e^^ a?r}-!!..ou*$!n!!d Wo-^^^d..y-!!} ..$~~'$!£%!nd--......A..n~~~~*^!!^£%y^ an£%?}?£% sta-r?*^!!%t-?-e}}?? t*o-£%* -$!u~^~-'.$!.nate* £%l^!!^..$^£%!!! o$!v~~'..*r..!$!}^the..-m$!,-^a~~'nd$! *t$!£%-..!$!^^??}£^%£%}!$!!^~?'..?th£?%^^e-~~'}£-£%~~'}$!?£$!%.?.~~'%.- s??!~~'?..ta!!rte*d !*!o ?!!..£%a^~~'£!!%}}..turb$!??^$!^e.~~£%'$$!!..-.A..-£~~'%d*??y^£% }'?O£%!~~'!^ }%~~'$!my~$!~'*.. g!!*!!$!^od-e~~'ss,$! ?$!~'^od-*?}£%*£!!%!?y$!^$..^!!!^*?*.£%! You~~'^.$!.}?..r*e$£^..?~*~??!!!^!churn~~'in^g£%~~' !!?*£%..?$!?}!}y i*~~'s}!!...i£%e!!- u!!}-p*} }so**~~'e!?!?l-l!? You}r £?n-^!!!!s^e^ i~~'...?~~'s.!!..£%. s~~'^.^.-}!$!~^imu*!**!^£..%?£%*^..?~~'$!~'ting!! ~~~~'m$-^..!y$!~~'~~'*ro$!s$!t~?^~'a*~~'e}!..}^! OH?£% YE}S!}$$!! A*l.^.^ ^}t..e }$..!?-the!!r* *$!-*££%%*..}ys ..}b£%???^ec?a..me*$!-} s^}o!!}~~'!^^!a}£}%r$!ous?e}-- -*-~~'!!-.- -$$!!£%!*!!is,*.$!! th..^.!!.*^t£% $!*th*y* co$!ul-^d n-!!$}o-t *h$!^l...!!-p }?t*-hemse~~'*!!^l£^%v*es? ?a~~'y£%~^'^$!m$$!~~}$!?..$!!!^-~~..?'~~'re!?**T*?y} $!pu£%!!s}~~'!e~~'d..!--! ^W£%o$!o*d-}-^$!*%c-*om£%£%..^^e!!?e£%l* ?£-£%}}!-~~'nside!!,}?. a*?nd t*h~~'e!!y al?l£%..* w!!ent i..-%-id}-e-?!!^.*? A!!ll~^~'- o-f-$^!th.?^.£%e?%..-$?^*!^.?? wan!!e£%d-..^..o £%be ?*i!!~~'n*..s^i-~~'!^d* }^An}......y?^^~~'**?^s? *$!£%ni~!!^*~!!....-'ce$~~'*!£%* ^£%r..o~~'un..~'?d }ass.} An!!?*d!!y~~}':..$! ?.?.'^}No£~~' £-%wa!!i?~~$!'$!^t£%$!~~'???.....~~'..g..uys*! ....*$!My*~~'a!!!s$!£%^£}c}....*-n^*$£%}t} £..%~~'-£%!!.h??old thi..s }.$!..?}~~'.?uch!!~~'$!~'? ^}I$!'m$*g!!e..~~$}!-*..}!£%~~'^!!^~..-*}g} ~~'$-!..so} }-~*~'--!!£%*l*...l! A}l$!*^-l- £%!}!he..!!t^~!!'-s? went?- ..i£%*$..!$!n~~-'~-~}'!!!!?d^*!?!e..* ^$!?-*f^?~}**.... }!!$!~}?~'~'}}!!-..or !^?s!!q£%u?-$!}-!!r£%$!mi?n£?%g~~'!!! !!^%£%nd}y£%.. ?..*!!d}^ -^p}?rett!..! much,^}!! }h}-e-} £%£-$!$!wa*....?^s? }?e^$!y!£%!$!o~~'$!d- $!-ull-$!%-....-!!£% ~!.£%!~^}~~*'an?d£%d...*.*!ie}d!! ..$!-!!.!!$!o?~~'}~~~'~'m!! h?..~~'-}i^g^ ~~$£%!-£%-^s~~'!!ins$!£-}£$!%?%-i*de!!*?$!$}!c~-'o}m£%*l!!etely da$!}m.?$-!.£%*ge}d*!?.!!.. ^T££%%$!$!e£%?£%..~£%~$~~~~'-!^o.-$!.t}^.-£%^*e^r-..a?-£%--m~~'%}e i£%~?~?!!^~~'!!~~'?de}~~'}£%d-?....!*?f..ound*..!^ ..And£%y?£% d?-~~'e~~'a-£%?d$....-i}$!h ^-a h}*ge- $!^-ss £.£%.%he*m!~~'or~~'*!!}^rh$!a^ge.. on h?i- ?-!!n!!...~~'.-~~£%~~!!'$!-u!!?*s,} $!!!wi^th $!a }HU~~*'!?!G£!!%.}.}E b!!-e~~'l?££%%*$!..!}!..!-£%!£%~~'!}*fu!!l$!l-}!! o*~~'f- *~!!~'$!t**o^ys}."

/obj/item/paper/report/examine(mob/user)
	. = ..()
	if(scanned_area?.name)
		. += "<span class='notice'>\The [src] contains data on [scanned_area.name].</span>"
	else if(scanned_area)
		. += "<span class='notice'>\The [src] contains data on a vague area on station, you should throw it away.</span>"
	else
		. += "<span class='notice'>Wait a minute, this thing's blank! You should throw it away.</span>"
