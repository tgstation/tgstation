/// The realm's ruler on Rockhill: the Grand Duke (Ratwood SSticker.rulermob; the regent is not ported).
/proc/rogue_is_ruler(mob/living/user)
	return istype(user) && user.stat == STABLE && user.mind?.assigned_role?.title == JOB_ROCKHILL_GRAND_DUKE

/// The living ruler, if any.
/proc/rogue_ruler()
	for(var/mob/living/carbon/human/candidate as anything in GLOB.human_list)
		if(candidate.stat != DEAD && candidate.mind?.assigned_role?.title == JOB_ROCKHILL_GRAND_DUKE)
			return candidate
	return null

/// Fills %RULER%, %RULER_NAME% and the region tokens of a charter's text (Ratwood fill_decree_tokens()).
/proc/rogue_fill_decree_tokens(template)
	if(!template)
		return null
	var/mob/living/ruler = rogue_ruler()
	var/text = replacetext(template, "%RULER%", JOB_ROCKHILL_GRAND_DUKE)
	text = replacetext(text, "%RULER_NAME%", ruler ? ruler.real_name : "the Lord")
	return trim(replacetext(text, "%REGION_ROCKHILL%", "Rockhill"))

/**
 * A charter of the realm (Ratwood code/modules/politics/decree.dm, port of Azure Peak #6849): an ancient or new compact that
 * shields some subjects from the Crown's levies, fines and poll tax, or binds the Crown to pay some roles at least so much. The
 * ruler revokes and restores charters, one of each a day, each no sooner than its cooldown; every change is proclaimed.
 */
/datum/rogue_decree
	var/id
	var/name
	/// Year of the charter's seal: an old date for ancient charters, the current year once changed.
	var/year
	var/flavor_text
	var/mechanical_text
	var/category = ROGUE_DECREE_ANCIENT
	var/active = TRUE
	/// Before this world.time the charter cannot change again.
	var/cooldown_expires = 0
	var/revoke_text
	var/restore_text
	/// Was ever in force this round (Ratwood hides never-pressed charters like the Magna Carta from public lists).
	var/has_ever_been_active = FALSE
	/// Suspended by the Crown's sequestration: frozen until the sequestration ends (Ratwood bankruptcy_suspended).
	var/bankruptcy_suspended = FALSE

/datum/rogue_decree/New()
	. = ..()
	year = initial_year()
	if(active)
		has_ever_been_active = TRUE

/datum/rogue_decree/proc/initial_year()
	return ROCKHILL_CALENDAR_EPOCH_YEAR

/datum/rogue_decree/proc/display_name()
	return "[name] of [year]"

/// The charter frees the payer from the Crown's levies and fines.
/datum/rogue_decree/proc/exempts(mob/living/payer)
	return FALSE

/// Narrows the share of the payer's balance one levy or fine may take.
/datum/rogue_decree/proc/rate_cap(mob/living/payer, current_cap)
	return current_cap

/// Narrows the mammons the payer may still be fined today.
/datum/rogue_decree/proc/fine_cap(mob/living/payer, current_remaining)
	return current_remaining

/// Narrows the payer's poll tax per dawn.
/datum/rogue_decree/proc/poll_cap(mob/living/payer, poll_class, current_rate)
	return current_rate

/// The least wage the charter binds the Crown to pay a role.
/datum/rogue_decree/proc/wage_floor(title, current_floor)
	return current_floor

/// Roles whose wage the charter floors.
/datum/rogue_decree/proc/floored_titles()
	return list()

/datum/rogue_decree/proc/on_revoke()
	return

/datum/rogue_decree/proc/on_restore()
	return

/datum/rogue_decree/proc/can_change_state()
	return world.time >= cooldown_expires

/// Puts the charter in or out of force under a new seal and proclaims it (Ratwood set_state()).
/datum/rogue_decree/proc/set_state(new_active)
	if(active == new_active)
		return FALSE
	active = new_active
	year = ROCKHILL_CALENDAR_EPOCH_YEAR
	cooldown_expires = world.time + ROGUE_DECREE_COOLDOWN
	if(active)
		has_ever_been_active = TRUE
		on_restore()
	else
		on_revoke()
	proclaim()
	return TRUE

/datum/rogue_decree/proc/proclaim()
	var/template = active ? restore_text : revoke_text
	if(!template)
		return
	priority_announce(rogue_fill_decree_tokens(template), active ? "BY LORDLY MERCY" : "BY LORDLY DECREE", ROGUE_SOUND_DECREE)

/datum/rogue_decree/great_writ
	id = ROGUE_DECREE_GREAT_WRIT
	name = "The Great Writ of Ferentia"
	mechanical_text = "Titled nobles of this land pay no levies nor fines, and no poll tax."
	flavor_text = {"This Great Writ of Ferentia, pronounced under Astrata's Sun and with Ravox as witness, declareth that the titled nobility of this land, being of lineage blessed by Astrata's grace, shall bear no tax nor levy upon their persons or estates. Untitled blood and the blue blood of foreign realms sojourning within it enjoy no such exemption, and shall render unto the Crown as any other subject.

In return, the nobles of The Realm shall undertake the duty of arms - to defend the Realm in their own person and with their retainers, to answer the Crown's call to war in whatsoever hour it cometh, and to render unto the throne the fealty that is owed by blood and by oath.

Yeven under the seal of the Crown, in witness of the Ten."}
	revoke_text = "The %RULER% has set aside the Great Writ. The nobility of The Realm shall contribute to the Crown, in both blood and gold - let no lineage be too blessed to pay."
	restore_text = "The %RULER% has renewed the Great Writ. The blue blood of The Realm is freed again from the levy, that the nobility may serve the Realm in arms, not in coin."

/datum/rogue_decree/great_writ/initial_year()
	return ROCKHILL_CALENDAR_EPOCH_YEAR - rand(100, 200)

/datum/rogue_decree/great_writ/exempts(mob/living/payer)
	return active && rogue_titled_noble(payer)

/datum/rogue_decree/zenitstadt_concordat
	id = ROGUE_DECREE_CONCORDAT
	name = "The Zenitstadt Concordat"
	mechanical_text = "Church clergy and declared Benefactors of the Faith pay no levies, fines nor poll tax. While it stands, no levy may fall below the Church's tithe, and a share of every taxed sale is tithed from the Crown's Purse to the Church Fund."
	flavor_text = {"This Zenitstadt Concordat, sworne under the Ten's Grace and with Ravox as witness, witnesseth that the Church of the Vale, consecrated beneath the Ten and quickened by Astrata's light, shall keep the peace of the gods upon this land: to pray for the safety and prosperity of the Realm by daye and by night, to maintain the favor of the Ten through proper sacrament and offering, to levy tithe from amongst its own brethren, to shelter the poor and downtrodden, and to furnish its own knightly order of templars that the common defense of the Realm be not wanting.

In exchange, as the sacred envoys of the gods and sworn servants of the Ten, the clergy of the Church of the Vale shall bear no tax nor levy, neither upon their persons nor upon the properties of the Faith; nor shall the Crown intrude upon the internal discipline of the Church, save by lawful counsel taken with the Church of the Ten.

Yeven under the seal of the Crown, in witness of the Ten."}
	revoke_text = "The %RULER% has rescinded the Zenitstadt Concordat. The Church's wealth shall serve the greater good of the Realm - let the Ten judge who betrayed whom."
	restore_text = "The %RULER% has affirmed the Zenitstadt Concordat. The hand of the Crown shall meddle no more in the disposition of the Church's worldly wealth."

/datum/rogue_decree/zenitstadt_concordat/initial_year()
	return ROCKHILL_CALENDAR_EPOCH_YEAR - rand(50, 120)

/datum/rogue_decree/zenitstadt_concordat/exempts(mob/living/payer)
	if(!active)
		return FALSE
	return (payer.mind?.assigned_role?.title in GLOB.rogue_church_roles) || HAS_TRAIT(payer, TRAIT_AGENT_CHURCH)

/datum/rogue_decree/otavan_accords
	id = ROGUE_DECREE_OTAVAN_ACCORDS
	name = "The Otavan Accords"
	category = ROGUE_DECREE_NEW
	mechanical_text = "Members of the Inquisition pay no levies, fines nor poll tax."
	flavor_text = {"In the name of the Ten, under the Almighty Allfather's watch, be it known that the Holy Otavan Inquisition, sworn servants of Psydon and emissaries of the Orthodoxy, shall keep vigil against heresy athupon this land: to defend and protect the Duchy of the Vale from those who would do it harm, and to counsel and advise the leaders and peoples of the nation. The Inquisition is hereby granted the right to try foreigners, those sanctioned and outlawed by the Duchy for crimes of high heresy, or those who are handed over by order of Crown and Court. The Holy Inquisition is to be granted permission to aid in trials of citizenry alongside the lawful authorities of the land, save for the Nobility, who must be tried before the Crown.

In exchange, as foreign adherents sanctioned by treaty, the Inquisition shall bear no tax nor levy, neither upon their persons nor upon the instruments of their office; nor shall the Crown hinder their holy duty, save by lawful cause shown before the Bishop or Council.

Yeven under the seal of the Crown, in witness of Psydon and the Ten."}
	revoke_text = "The %RULER% has broken the Otavan Accords. The Inquisition is stripped of its treaty protections - and Otava shall not take such an insult lightly."
	restore_text = "The %RULER% has affirmed the Otavan Accords. The Holy Otavan Inquisition resumes its duty to purge the land of heretics, free from the Crown's interference."

/datum/rogue_decree/otavan_accords/initial_year()
	return 1492

/datum/rogue_decree/otavan_accords/exempts(mob/living/payer)
	return active && (payer.mind?.assigned_role?.title in GLOB.rogue_inquisition_roles)

/datum/rogue_decree/golden_bull
	id = ROGUE_DECREE_GOLDEN_BULL
	name = "The Golden Bull of Kingsfield"
	mechanical_text = "Burghers and residents give up at most a quarter of their balance to one levy or fine, at most 50m in fines a day, and burghers at most 20m of poll tax a dawn. Wanderers and mercenaries are not covered. While it stands, the burghers renew the Burgher Pledge every dawn, which pays the Crown's commissions and petitions."
	flavor_text = {"This Golden Bull of Kingsfield, sealed under Astrata's Sun and with Ravox as witness, witnesseth the ancient compact between the Crown of the Vale and the makers of her wealth.

It is attested, by name of the Grand Duke of the Vale, and by the Councils of the Notables and Burghers of Rotwood Vale duly assembled to set this seal, that the said Councils do hereby assent, in this yil and in perpetuity, that the Crown shall levy upon the Burghers no greater portion than one quarter part of their nervelock account, and shall exact in fine no more than fifty mammon by the day, nor poll-tax beyond twenty mammon by the day; such being the limits deemed meet in time of peace, of war, and of necessite alike. Beyond these bounds no Burgher shall be taxed, nor deprived of their wealth, save by the law of the land.

In return, the Burghers of the Vale shall undertake to furnish, for the common defense of the Realm against pirates, brigands, and such other malefactors as do threaten the peace, a yearly Budget - the sum collected from amongst their members according to their wealth, and apportioned by their own assembly.

And should the Crown exceed these ratified bounds, or otherwise violate this Charter, the Burghers are absolved of their obligation, that the Realm may know the cost of breaking faith with its makers of wealth.

Yeven under the seal of the Crown."}
	revoke_text = "The %RULER% has suspended the Golden Bull of Kingsfield. The burghers stand exposed to the Crown's full levy, and the outraged merchants shall contribute no more to the common defense of the Realm."
	restore_text = "The %RULER% has restored the Golden Bull of Kingsfield. The compact stands renewed, and the burghers resume their tribute to the common defense."

/datum/rogue_decree/golden_bull/initial_year()
	return ROCKHILL_CALENDAR_EPOCH_YEAR - rand(40, 100)

/// The Bull shields everyone but outlaws, wanderers and mercenaries; residents always (Ratwood is_protected_by_bull()).
/datum/rogue_decree/golden_bull/proc/protects(mob/living/payer)
	if(!active || !payer || HAS_TRAIT(payer, TRAIT_OUTLAW))
		return FALSE
	if(HAS_TRAIT(payer, TRAIT_RESIDENT))
		return TRUE
	var/title = payer.mind?.assigned_role?.title
	return !(title in list(JOB_ROCKHILL_ADVENTURER, JOB_ROCKHILL_ENSLAVED_ADVENTURER, JOB_ROCKHILL_COURT_AGENT, JOB_ROCKHILL_MERCENARY))

/datum/rogue_decree/golden_bull/rate_cap(mob/living/payer, current_cap)
	return protects(payer) ? min(current_cap, ROGUE_BULL_RATE_CAP) : current_cap

/datum/rogue_decree/golden_bull/fine_cap(mob/living/payer, current_remaining)
	return protects(payer) ? min(current_remaining, ROGUE_BULL_FINE_CAP) : current_remaining

/datum/rogue_decree/golden_bull/poll_cap(mob/living/payer, poll_class, current_rate)
	return poll_class == ROGUE_POLL_BURGHER ? min(current_rate, ROGUE_BULL_POLL_CAP) : current_rate

/datum/rogue_decree/noc_pestra_covenant
	id = ROGUE_DECREE_COVENANT
	name = "The Covenant of Noc & Pestra"
	category = ROGUE_DECREE_NEW
	mechanical_text = "Scholars and healers pay at most 10m of poll tax a dawn, and the Crown pays them at least: Court Magician 40m, Archivist 20m, Magicians Associate 10m, Head Physician 40m, Apothecary 15m."
	flavor_text = {"This Covenant of Noc & Pestra, sworne under the watchful eye of Noc and the merciful hand of Pestra, witnesseth that the scholars of the University and the healers of the Apothecary shall bear no greater levy than the lightest measure upon their heads, and shall be paid from the Crown's purse an honest minimum of their due whilst this Covenant standeth.

In exchange, the chartered scholars of the University shall keep the lore and knowledge of the Realm, preserve it, and teach it unto those worthy and of bright minds, for Noc granted humen the gift of magick and wisdom that we may pass it on. And the chartered healers of the Apothecary, agents of Pestra, shall tend the hurt of every subject who cometh to their door, be they beggar or burgher, and shall never refuse the wounded for want of coin, for Pestra is merciful and taught us medicine that we may care for one another.

Yeven under the seal of the Crown, in witness of Noc and Pestra."}
	revoke_text = "The %RULER% has suspended the Covenant of Noc & Pestra. The scholars and healers of the Vale now bear the Crown's common levy in full - and Noc and Pestra may reckon how long their mercy lasts without their chartered hands."
	restore_text = "The %RULER% has affirmed the Covenant of Noc & Pestra. The scholars and healers of the Vale resume their sheltered station, that the Realm may keep both its lore and its mercy."
	/// Least wage of each chartered scholar and healer.
	var/static/list/wage_floors = list(
		JOB_ROCKHILL_COURT_MAGICIAN = 40,
		JOB_ROCKHILL_ARCHIVIST = 20,
		JOB_ROCKHILL_MAGICIANS_ASSOCIATE = 10,
		JOB_ROCKHILL_HEAD_PHYSICIAN = 40,
		JOB_ROCKHILL_APOTHECARY = 15,
	)

/datum/rogue_decree/noc_pestra_covenant/initial_year()
	return ROCKHILL_CALENDAR_EPOCH_YEAR - rand(20, 60)

/datum/rogue_decree/noc_pestra_covenant/poll_cap(mob/living/payer, poll_class, current_rate)
	if(!active || !payer || HAS_TRAIT(payer, TRAIT_OUTLAW) || !(payer.mind?.assigned_role?.title in wage_floors))
		return current_rate
	return min(current_rate, ROGUE_COVENANT_POLL_CAP)

/datum/rogue_decree/noc_pestra_covenant/wage_floor(title, current_floor)
	return max(current_floor, wage_floors[title] || 0)

/datum/rogue_decree/noc_pestra_covenant/floored_titles()
	return wage_floors

/datum/rogue_decree/noc_pestra_covenant/on_restore()
	SSrogue_treasury.enforce_wage_floors()

/datum/rogue_decree/guild_charter_of_arms
	id = ROGUE_DECREE_ARMS_CHARTER
	name = "The Guild Charter of Arms"
	category = ROGUE_DECREE_NEW
	mechanical_text = "Mercenaries of the Guild pay at most 15m of poll tax a dawn, and the Guild adds its tribute to the Burgher Pledge every dawn."
	flavor_text = {"This Guild Charter of Arms, drawn under Ravox's banner and entered unto between the Crown of the Vale and the Guild of Arms, witnesseth that the Crown recognizeth the Guild as a chartered foreign body, self-governing in its own affairs and answerable only to its own captains. Its sworn mercenaries shall bear no common levy save the lightest head-count upon them.

The Crown commandeth no oath of service from the Guild, and oweth it no service in return. The Crown shall not intervene in the contracts the Guild undertaketh, and shall protect its adherents' right to bear arms and to intervene in private warfare as they see fit, so long as the peace of the Realm be not disturbed thereby, and so long as they undertake no contracts of piracy, brigandry, nor such as directly threaten the Crown's interests.

In recognition of this standing, the Guild's treasury, collected from amongst its members as a fee, shall remit a daily tribute unto the Burgher Pledge as a gesture of good will and contribution toward the common wealth of the Realm, as bearers of arms and agents of Ravox for the dispensation of justice therein. And should an outlaw be found wearing the Guild's colours, the Guild answereth for none of it, and the Crown's justice against that individual proceedeth unimpeded.

Yeven under the seal of the Crown and the mark of the Guild."}
	revoke_text = "The %RULER% has suspended the Guild Charter of Arms. The mercenaries of the Vale now bear the Crown's common levy in full - and the Guild's tribute to the Pledge ceases until the compact is renewed."
	restore_text = "The %RULER% has affirmed the Guild Charter of Arms. The Guild's recognition is restored, and its tribute to the Pledge resumes."

/datum/rogue_decree/guild_charter_of_arms/initial_year()
	return ROCKHILL_CALENDAR_EPOCH_YEAR - rand(30, 80)

/datum/rogue_decree/guild_charter_of_arms/poll_cap(mob/living/payer, poll_class, current_rate)
	if(!active || poll_class != ROGUE_POLL_MERCENARY || !payer || HAS_TRAIT(payer, TRAIT_OUTLAW))
		return current_rate
	return min(current_rate, ROGUE_ARMS_POLL_CAP)

/datum/rogue_decree/indenture_of_war
	id = ROGUE_DECREE_INDENTURE_OF_WAR
	name = "The Indenture of War"
	mechanical_text = "The Crown pays its soldiery at least: Marshal 60m, Knight and Sergeant 40m, Man at Arms and Forest Warden 20m, Squire 10m."
	flavor_text = {"This Indenture of War, made betwene the Crown of the Vale on the one part, and the armed men of the Realm on the other part, witnesseth that:

The Crown shall paye unto its soldiery their just wages, by the daye, and without lette or delay, according to the ranks herein set forth. The Marshal of the Realm at threescore marks, the Knights at twoscore, a Sergeant at twoscore likewise, a Man at Armes at a score, a Warden at a score, and a Squire at ten. Beneath these sums no wage shall fall whilst this Indenture stands.

In return, the armed men of the Realm shall do their trewe service to the Duke, and shall obey the Duke's lieutenants and officers in all things lawful and reasonable. And if the saide armed men shall break or contravene this Indenture, they shall be at the Duke's wille and mercye. And if the Crown shall break this Indenture - withholding the wages herein pledged, or setting them lower than here set forth - the soldier is released from his oath, and the Crown shall answer for the faith it hath broken.

In witness whereof, the Crown of the Vale hath set his seale to this Indenture, and the said armed men of the Realm have set their seales in like manner.

Yeven under the seal of the Crown."}
	revoke_text = "The %RULER% has broken the Indenture of War. The soldier's oath is dissolved, and the Crown's armed men stand at liberty of service - let the garrison remember whose seal was cut first."
	restore_text = "The %RULER% has renewed the Indenture of War. The soldier's wage is pledged, and the soldier's oath stands - each binds the other."
	/// Least wage of each military rank.
	var/static/list/wage_floors = list(
		JOB_ROCKHILL_MARSHAL = 60,
		JOB_ROCKHILL_KNIGHT = 40,
		JOB_ROCKHILL_SERGEANT = 40,
		JOB_ROCKHILL_MAN_AT_ARMS = 20,
		JOB_ROCKHILL_FOREST_WARDEN = 20,
		JOB_ROCKHILL_SQUIRE = 10,
	)

/datum/rogue_decree/indenture_of_war/initial_year()
	return ROCKHILL_CALENDAR_EPOCH_YEAR - rand(40, 120)

/datum/rogue_decree/indenture_of_war/wage_floor(title, current_floor)
	return max(current_floor, wage_floors[title] || 0)

/datum/rogue_decree/indenture_of_war/floored_titles()
	return wage_floors

/datum/rogue_decree/indenture_of_war/on_restore()
	SSrogue_treasury.enforce_wage_floors()

/datum/rogue_decree/magna_carta
	id = ROGUE_DECREE_MAGNA_CARTA
	name = "The Magna Carta"
	category = ROGUE_DECREE_NEW
	active = FALSE
	mechanical_text = "Zeroes every Crown levy and poll tax while it stands; revoking it brings the old rates back. Fines remain. The Crown collects only voluntary tribute."
	flavor_text = {"
%RULER_NAME%, by the grace of Astrata, %RULER% of the Vale, Count of Kingsfield, Blackholt, and Saltwick, Overlord of Rosawood, %REGION_ROCKHILL%, and Daftsmarch, Protector of Bleakcoast, Northfort, and Heartfelt, Defender of the Ten, to his archbishops, priests, templars, inquisitors, dukes, princes, consorts, hands, stewards, councillors, clerks, marshals, knights, sergeants, men-at-arms, wardens, squires, court magicians, archivists, apothecaries, head physicians, merchants, innkeepers, bathmasters, guildsmen, burghers, residents, peasants, farmers, cooks, tapsters, bathmaids, servants, soilsons, mercenaries, adventurers, pilgrims, and to all his officials and loyal subjects, Greeting.

Know ye, that for the health of our soul, for the common benefit of the Realm, to the honour of the Ten, the exaltation of the holy Church, and the better ordering of our kingdom, we have granted unto every subject of the Vale, of whatsoever rank, station, or origin, that they shall bear no tax, no levy, no tariff, no duty, nor any fiscal imposition whatsoever upon their persons, estates, goods, labours, or callings, nor upon the instruments thereof, neither in coin nor in kind.

In return, the subjects of the Vale shall remember the Crown in their private thoughts, speak well of its name when it becometh them to do so, and furnish such revenue as conscience may prompt and good weather allow, in such quantity and at such times as each subject shall deem fitting unto themselves.

Yeven under the seal of %RULER_NAME%, %RULER% of this yeer, who shall be remembered for it."}
	revoke_text = "Hear ye, hear ye. %RULER_NAME%, by the grace of Astrata, %RULER% of the Vale, Count of Kingsfield, Blackholt, and Saltwick, Overlord of Rosawood, %REGION_ROCKHILL%, and Daftsmarch, Protector of Bleakcoast, Northfort, and Heartfelt, Defender of the Ten, hath this day set aside the Magna Carta. The Realm's subjects are hereby restored to their accustomed fiscal obligations, and the Crown's revenue is restored in kind. Let the record reflect the reconsideration of %RULER_NAME%."
	/// Levies and poll tax rates before the Carta zeroed them, handed back when it is revoked.
	var/list/saved_tax_rates
	var/list/saved_poll_rates

/datum/rogue_decree/magna_carta/on_restore()
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	if(isnull(saved_tax_rates))
		saved_tax_rates = treasury.tax_rates.Copy()
	if(isnull(saved_poll_rates))
		saved_poll_rates = treasury.poll_tax_rates.Copy()
	for(var/levy in treasury.tax_rates)
		treasury.tax_rates[levy] = 0
	for(var/poll_class in treasury.poll_tax_rates)
		treasury.poll_tax_rates[poll_class] = 0

/datum/rogue_decree/magna_carta/on_revoke()
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	for(var/levy in saved_tax_rates)
		treasury.tax_rates[levy] = saved_tax_rates[levy]
	for(var/poll_class in saved_poll_rates)
		treasury.poll_tax_rates[poll_class] = saved_poll_rates[poll_class]
	saved_tax_rates = null
	saved_poll_rates = null

/// Restoring the Carta reads the whole charter aloud, the ruler's name and all.
/datum/rogue_decree/magna_carta/proclaim()
	if(!active)
		return ..()
	priority_announce(rogue_fill_decree_tokens(flavor_text), "BY LORDLY MERCY", ROGUE_SOUND_DECREE)

/// A titled noble of this land: noble blood that was not drained, and not a foreigner's (Ratwood social_rank >= SOCIAL_RANK_NOBLE).
/proc/rogue_titled_noble(mob/living/subject)
	return HAS_TRAIT(subject, TRAIT_NOBLE) && !HAS_TRAIT(subject, TRAIT_DEFILED_NOBLE) && !HAS_TRAIT(subject, TRAIT_OUTLANDER)

/datum/controller/subsystem/rogue_treasury
	/// Charter id -> charter (Ratwood decrees).
	var/list/decrees = list()
	/// The dawns the ruler last revoked and restored a charter: one of each a day (Ratwood decree_revoke_used_day).
	var/decree_revoke_dawn = -1
	var/decree_restore_dawn = -1
	/// The window of the charters, one for everyone.
	var/datum/rogue_charters_panel/charters_panel

/datum/controller/subsystem/rogue_treasury/proc/init_decrees()
	for(var/decree_type in subtypesof(/datum/rogue_decree))
		var/datum/rogue_decree/decree = new decree_type
		decrees[decree.id] = decree
	charters_panel = new

/datum/controller/subsystem/rogue_treasury/proc/decree_active(decree_id)
	var/datum/rogue_decree/decree = decrees[decree_id]
	return decree?.active

/// A charter frees the payer from the Crown's levies and fines; outlaws and the Crown's own pensioners forfeit charters (Ratwood is_tax_exempt()).
/datum/controller/subsystem/rogue_treasury/proc/tax_exempt(mob/living/payer)
	if(!payer || HAS_TRAIT(payer, TRAIT_OUTLAW) || HAS_TRAIT(payer, TRAIT_ROYAL_SUBSIDY))
		return FALSE
	for(var/id in decrees)
		var/datum/rogue_decree/decree = decrees[id]
		if(decree.exempts(payer))
			return TRUE
	return FALSE

/// The least wage standing charters bind the Crown to pay a role (Ratwood get_wage_floor()).
/datum/controller/subsystem/rogue_treasury/proc/wage_floor(title)
	var/floor_wage = 0
	for(var/id in decrees)
		var/datum/rogue_decree/decree = decrees[id]
		if(decree.active)
			floor_wage = decree.wage_floor(title, floor_wage)
	return floor_wage

/datum/controller/subsystem/rogue_treasury/proc/wage_floored_titles()
	var/list/titles = list()
	for(var/id in decrees)
		var/datum/rogue_decree/decree = decrees[id]
		if(!decree.active)
			continue
		for(var/title in decree.floored_titles())
			titles |= title
	return titles

/// Why the ruler cannot put this charter in or out of force now, or null (Ratwood can_mutate_decree(), can_change_decree_state()).
/datum/controller/subsystem/rogue_treasury/proc/decree_change_blocker(datum/rogue_decree/decree, new_active)
	if(decree.active == new_active)
		return "The charter already stands so."
	if(treasury_state == ROGUE_TREASURY_SEQUESTERED)
		if(decree.bankruptcy_suspended)
			return "The charter is suspended by the Crown's sequestration."
		if(decree.id == ROGUE_DECREE_GOLDEN_BULL && !new_active)
			return "The Company holds the Golden Bull while the realm is sequestered."
	if(!decree.can_change_state())
		return "The seal is still warm; the charter cannot change again so soon."
	if(new_active ? decree_restore_dawn == ROGUE_TREASURY_DAY : decree_revoke_dawn == ROGUE_TREASURY_DAY)
		return new_active ? "A charter has already been restored today." : "A charter has already been revoked today."
	return null

/// The ruler revokes or restores a charter (Ratwood set_decree_active()).
/datum/controller/subsystem/rogue_treasury/proc/set_decree_active(decree_id, new_active, mob/user)
	var/datum/rogue_decree/decree = decrees[decree_id]
	if(!decree)
		return FALSE
	var/blocker = decree_change_blocker(decree, new_active)
	if(blocker)
		to_chat(user, span_warning(blocker))
		return FALSE
	if(!decree.set_state(new_active))
		return FALSE
	if(new_active)
		decree_restore_dawn = ROGUE_TREASURY_DAY
	else
		decree_revoke_dawn = ROGUE_TREASURY_DAY
	log_game("CHARTER: [key_name(user)] [new_active ? "restored" : "revoked"] [decree.name]")
	return TRUE

/// After a sequestration the ruler may restore suspended charters at once, without cooldown (Ratwood restore_charter_via_concession()).
/datum/controller/subsystem/rogue_treasury/proc/restore_charter_by_concession(decree_id, mob/user)
	var/datum/rogue_decree/decree = decrees[decree_id]
	if(concession_picks <= 0 || treasury_state == ROGUE_TREASURY_SEQUESTERED || !decree?.bankruptcy_suspended || decree.active)
		return FALSE
	decree.bankruptcy_suspended = FALSE
	decree.active = TRUE
	decree.year = ROCKHILL_CALENDAR_EPOCH_YEAR
	decree.cooldown_expires = 0
	decree.has_ever_been_active = TRUE
	decree.on_restore()
	decree.proclaim()
	concession_picks--
	enforce_wage_floors()
	log_game("CHARTER: [key_name(user)] restored [decree.name] by concession")
	return TRUE

/**
 * The charters of the realm (Ratwood code/datums/decree_setter.dm, the DecreeSetter window the Lord opens at the Throat): every
 * charter with its text and state. Anyone at the nerve master may read them; only the ruler revokes and restores.
 */
/datum/rogue_charters_panel

/datum/rogue_charters_panel/ui_state(mob/user)
	return GLOB.conscious_state

/datum/rogue_charters_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueCharters", "Charters of the Realm")
		ui.open()

/datum/rogue_charters_panel/ui_data(mob/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/list/charters = list()
	for(var/id in treasury.decrees)
		var/datum/rogue_decree/decree = treasury.decrees[id]
		charters += list(list(
			"id" = decree.id,
			"name" = decree.display_name(),
			"category" = decree.category,
			"mechanical" = decree.mechanical_text,
			"flavor" = rogue_fill_decree_tokens(decree.flavor_text),
			"active" = decree.active,
			"suspended" = decree.bankruptcy_suspended,
			"cooldown" = round(max(0, decree.cooldown_expires - world.time) / (1 SECONDS)),
		))
	return list(
		"charters" = charters,
		"ruler" = rogue_is_ruler(user),
		"revoked_today" = treasury.decree_revoke_dawn == ROGUE_TREASURY_DAY,
		"restored_today" = treasury.decree_restore_dawn == ROGUE_TREASURY_DAY,
		"concessions" = treasury.treasury_state == ROGUE_TREASURY_SEQUESTERED ? 0 : treasury.concession_picks,
		"sequestered" = treasury.treasury_state == ROGUE_TREASURY_SEQUESTERED,
	)

/datum/rogue_charters_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	if(!rogue_is_ruler(user))
		to_chat(user, span_warning("Only the [JOB_ROCKHILL_GRAND_DUKE] may revise the charters of the realm."))
		return TRUE
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/decree_id = params["id"]
	var/datum/rogue_decree/decree = istext(decree_id) ? treasury.decrees[decree_id] : null
	if(!decree)
		return TRUE
	switch(action)
		if("toggle")
			treasury.set_decree_active(decree.id, !decree.active, user)
		if("concede")
			treasury.restore_charter_by_concession(decree.id, user)
	return TRUE
