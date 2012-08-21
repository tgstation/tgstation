//*******************************
//
//	Forum SQL Account Activation
//
//*******************************
//
// This module allows players to associate their BYOND keys with a specific forum username on the /tg/station forums.
// Its original intent is to disable posting for any non-associated forum accounts, and only allow players who've activated
// their account in-game to be able to post, hopefully reducing the spam the forum receives dramatically.
//
// This effect, of course, is not achieved entirely within BYOND. Some configuration on the forum-side is required as well.
// Targetted for phpBB3, not tested with earlier versions.
//
//
// Requires Dantom.DB library ( http://www.byond.com/developer/Dantom/DB )
//
// Written by TLE for /tg/station13


/proc/associate_key_with_forum(var/accname as text, var/playerkey as text)
	var/DBConnection/dbcon = new()
	var/uid

	// TODO: Replace local vars with global var references
	var/TG13user = forumsqllogin
	var/TG13pass = forumsqlpass
	var/TG13db = forumsqldb
	var/TG13address = forumsqladdress
	var/TG13port = forumsqlport

	dbcon.Connect("dbi:mysql:[TG13db]:[TG13address]:[TG13port]","[TG13user]","[TG13pass]")
	if(!dbcon.IsConnected())
		src << "<font color=red><b>Server Connection Error</b> : Unable to open a connection with the forum database.</font>"
		src << "<i>Potential causes for this problem: Incorrect login information, incorrect server connection information, the forum server is down or not responding to requests, your firewall is blocking outgoing SQL requests.</i>"
		return

	// Sanitize inputs to avoid SQL injection attacks
	accname = sanitizeSQL(accname)
	playerkey = sanitizeSQL(playerkey)


	var/DBQuery/query = dbcon.NewQuery("SELECT user_id FROM [forumsqldb].phpbb_users WHERE username = '[accname]'")
	query.Execute()
	while(query.NextRow())
		uid = query.item[1]		// Find and save the account's user_id
	if(!uid)
		src << "Forum account not found!"
		dbcon.Disconnect()
		return

	query = dbcon.NewQuery("SELECT pf_byondkey FROM [forumsqldb].phpbb_profile_fields_data WHERE user_id = '[uid]'")
	if(!query.Execute())
		src << "Unable to verify whether account is already associated with a BYOND key or not. This error shouldn't occur, please contact an administrator."
		dbcon.Disconnect()
		return
	if(query.RowCount() > 0)
		query.NextRow()
		var/currentholder = query.item[1]
		src << "Forum account already has a BYOND key associated with it. The current BYOND key associated with the account is \"[currentholder]\"."
		src << "If this is not a key you own and you feel that someone has wrongfully authenticated your forum account please contact an administrator to have your account returned to you."
		dbcon.Disconnect()
		return

	query = dbcon.NewQuery("SELECT * FROM [forumsqldb].phpbb_user_group WHERE user_id = '[uid]' AND group_id = '[forum_authenticated_group]'")
	if(!query.Execute())
		src << "Unable to verify whether account is already part of the authenticated group or not. This error should not occur, please contact an administrator."
		dbcon.Disconnect()
		return
	if(query.RowCount() > 0)
		src << "Forum account already belongs to the authenticated group. If this is your account and you did not authenticate it please contact an administrator to have your account returned to you."
		dbcon.Disconnect()
		return

	query = dbcon.NewQuery("INSERT INTO [forumsqldb].phpbb_profile_fields_data (user_id, pf_byondkey) VALUES ('[uid]', '[playerkey]')") // Remember which key is associated with the account
	if(!query.Execute())
		src << "Unable to associate key with account. Authentication failed."
		dbcon.Disconnect()
		return

	query = dbcon.NewQuery("UPDATE [forumsqldb].phpbb_user_group SET group_id = '[forum_authenticated_group]' WHERE user_id = '[uid]' AND group_id = '[forum_activated_group]'") // Replace 'registered_name Users' group with 'Activated Users'
	if(!query.Execute())
		src << "Unable to move account into authenticated group. This error shouldn't occur, contact an administrator for help. Authentication failed."
		dbcon.Disconnect()
		return

	query = dbcon.NewQuery("UPDATE [forumsqldb].phpbb_users SET group_id = '[forum_authenticated_group]' WHERE user_id = '[uid]'") // Change 'default group' the the authenticated group. Not doing so was causing many authenticated accounts to retain their unauthenticated permissions, despite being succesfully authenticated.
	if(!query.Execute())
		src << "Unable to modify default group for account. This error should never occur, contact an administrator for help. Authentication failed."
	else
		src << "Authentication succeeded. You may now start posting on the <a href=http://nanotrasen.com/phpBB3/>tgstation forums</a>."
	dbcon.Disconnect()


// This actually opens up a bunch of security holes to the forum DB. Given that it's not used much in the first place,
// I'm going to keep this commented out until we're sure everything's secure.	-- TLE
/*
/client/verb/activate_forum_account(var/a as text)
	set name = "Activate Forum Account"
	set category = "Special Verbs"
	set desc = "Associate a tgstation forum account with your BYOND key to enable posting."
	associate_key_with_forum(a, src.key)
*/