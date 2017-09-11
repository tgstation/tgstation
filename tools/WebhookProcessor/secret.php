<?php
//This file contains things that should not be touched by the automatic live tracker
 
//Github lets you have it sign the message with a secret that you can validate. This prevents people from faking events.
//This var should match the secret you configured for this webhook on github.
//This is required as otherwise somebody could trick the script into leaking the api key.

$hookSecret = '08ajh0qj93209qj90jfq932j32r';

//Api key for pushing changelogs.
$apiKey = '209ab8d879c0f987d06a09b9d879c0f987d06a09b9d8787d0a089c';

//Used to prevent potential RCEs
$repoOwnerAndName = "tgstation/tgstation";

//servers to announce PRs to
$servers = array();
/*
$servers[0] = array();
$servers[0]['address'] = 'game.tgstation13.org';
$servers[0]['port'] = '1337';
$servers[0]['comskey'] = '89aj90cq2fm0amc90832mn9rm90';
$servers[1] = array();
$servers[1]['address'] = 'game.tgstation13.org';
$servers[1]['port'] = '2337';
$servers[1]['comskey'] = '89aj90cq2fm0amc90832mn9rm90';
*/

$enable_live_tracking = true;	//auto update this file from the repository
$path_to_script = 'tools/WebhookProcessor/github_webhook_processor.php';
$tracked_branch = "master";

$trackPRBalance = true;	//set this to false to disable PR balance tracking
$prBalanceJson = '';	//Set this to the path you'd like the writable pr balance file to be stored, not setting it writes it to the working directory
$startingPRBalance = 3;	//Starting balance for never before seen users
//team 133041: tgstation/commit-access
$maintainer_team_id = 133041;	//org team id that is exempt from PR balance system, setting this to null will use anyone with write access to the repo. Get from https://api.github.com/orgs/:org/teams


//anti-spam measures. Don't announce PRs in game to people unless they've gotten a pr merged before
//options are:
//	"repo" - user has to have a pr merged in the repo before.
//	"org" - user has to have a pr merged in any repo in the organization (for repos owned directly by users, this applies to any repo directly owned by the same user.)
//	"disable" - disables.
//defaults to org if left blank or given invalid values.
$validation = "org";

//how many merged prs must they have under the rules above to have their pr announced to the game servers.
$validation_count = 1;
