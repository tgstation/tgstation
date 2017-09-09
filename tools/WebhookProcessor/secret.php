<?php
//This file contains things that should not be touched by the automatic live tracker
 
//Github lets you have it sign the message with a secret that you can validate. This prevents people from faking events.
//This var should match the secret you configured for this webhook on github.
//This is required as otherwise somebody could trick the script into leaking the api key.

global $hookSecret;
$hookSecret = '08ajh0qj93209qj90jfq932j32r';

//Api key for pushing changelogs.
global $apiKey;
$apiKey = '209ab8d879c0f987d06a09b9d879c0f987d06a09b9d8787d0a089c';

//Used to prevent potential RCEs
global $repoOwnerAndName;
$repoOwnerAndName = "tgstation/tgstation";

//servers to announce PRs to.
global $servers;
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
