<?php
/*
 *	Github webhook In-game PR Announcer and Changelog Generator for /tg/Station13
 *	Author: MrStonedOne
 *	For documentation on the changelog generator see https://tgstation13.org/phpBB/viewtopic.php?f=5&t=5157
 *	To hide prs from being announced in game, place a [s] in front of the title
 *	All runtime errors are echo'ed to the webhook's logs in github
 */

/**CREDITS:
 * GitHub webhook handler template.
 * 
 * @see  https://developer.github.com/webhooks/
 * @author  Miloslav Hula (https://github.com/milo)
 */


//CONFIG START (all defaults are random examples, do change them)
//Use single quotes for config options that are strings.

//These are all default settings that are described in secret.php
$hookSecret = '08ajh0qj93209qj90jfq932j32r';
$apiKey = '209ab8d879c0f987d06a09b9d879c0f987d06a09b9d8787d0a089c';
$repoOwnerAndName = "tgstation/tgstation";
$servers = array();
$enable_live_tracking = true;
$path_to_script = 'tools/WebhookProcessor/github_webhook_processor.php';
$tracked_branch = "master";
$trackPRBalance = true;
$prBalanceJson = '';
$startingPRBalance = 3;
$maintainer_team_id = 133041;
$validation = "org";
$validation_count = 1;
$tracked_branch = 'master';

require_once 'secret.php';

//CONFIG END
set_error_handler(function($severity, $message, $file, $line) {
	throw new \ErrorException($message, 0, $severity, $file, $line);
});
set_exception_handler(function($e) {
	header('HTTP/1.1 500 Internal Server Error');
	echo "Error on line {$e->getLine()}: " . htmlSpecialChars($e->getMessage());
	die();
});
$rawPost = NULL;
if (!$hookSecret || $hookSecret == '08ajh0qj93209qj90jfq932j32r')
	throw new \Exception("Hook secret is required and can not be default");
if (!isset($_SERVER['HTTP_X_HUB_SIGNATURE'])) {
	throw new \Exception("HTTP header 'X-Hub-Signature' is missing.");
} elseif (!extension_loaded('hash')) {
	throw new \Exception("Missing 'hash' extension to check the secret code validity.");
}
list($algo, $hash) = explode('=', $_SERVER['HTTP_X_HUB_SIGNATURE'], 2) + array('', '');
if (!in_array($algo, hash_algos(), TRUE)) {
	throw new \Exception("Hash algorithm '$algo' is not supported.");
}
$rawPost = file_get_contents('php://input');
if ($hash !== hash_hmac($algo, $rawPost, $hookSecret)) {
	throw new \Exception('Hook secret does not match.');
}

$contenttype = null;
//apache and nginx/fastcgi/phpfpm call this two different things.
if (!isset($_SERVER['HTTP_CONTENT_TYPE'])) {
	if (!isset($_SERVER['CONTENT_TYPE']))
		throw new \Exception("Missing HTTP 'Content-Type' header.");
	else
		$contenttype = $_SERVER['CONTENT_TYPE'];
} else {
	$contenttype = $_SERVER['HTTP_CONTENT_TYPE'];
}
if (!isset($_SERVER['HTTP_X_GITHUB_EVENT'])) {
	throw new \Exception("Missing HTTP 'X-Github-Event' header.");
}
switch ($contenttype) {
	case 'application/json':
		$json = $rawPost ?: file_get_contents('php://input');
		break;
	case 'application/x-www-form-urlencoded':
		$json = $_POST['payload'];
		break;
	default:
		throw new \Exception("Unsupported content type: $contenttype");
}
# Payload structure depends on triggered event
# https://developer.github.com/v3/activity/events/types/
$payload = json_decode($json, true);

switch (strtolower($_SERVER['HTTP_X_GITHUB_EVENT'])) {
	case 'ping':
		echo 'pong';
		break;
	case 'pull_request':
		handle_pr($payload);
		break;
	default:
		header('HTTP/1.0 404 Not Found');
		echo "Event:$_SERVER[HTTP_X_GITHUB_EVENT] Payload:\n";
		print_r($payload); # For debug only. Can be found in GitHub hook log.
		die();
}

function apisend($url, $method = 'GET', $content = NULL) {
	global $apiKey;
	if (is_array($content))
		$content = json_encode($content);
	
	$scontext = array('http' => array(
		'method'	=> $method,
		'header'	=>
			"Content-type: application/json\r\n".
			'Authorization: token ' . $apiKey,
		'ignore_errors' => true,
		'user_agent' 	=> 'tgstation13.org-Github-Automation-Tools'
	));
	if ($content)
		$scontext['http']['content'] = $content;
	
	return file_get_contents($url, false, stream_context_create($scontext));
}
function validate_user($payload) {
	global $validation, $validation_count;
	$query = array();
	if (empty($validation))
		$validation = 'org';
	switch (strtolower($validation)) {
		case 'disable':
			return TRUE;
		case 'repo':
			$query['repo'] = $payload['pull_request']['base']['repo']['full_name'];
			break;
		default:
			$query['user'] = $payload['pull_request']['base']['repo']['owner']['login'];
			break;
	}
	$query['author'] = $payload['pull_request']['user']['login'];
	$query['is'] = 'merged';
	$querystring = '';
	foreach($query as $key => $value)
		$querystring .= ($querystring == '' ? '' : '+') . urlencode($key) . ':' . urlencode($value);
	$res = apisend('https://api.github.com/search/issues?q='.$querystring);
	$res = json_decode($res, TRUE);
	return $res['total_count'] >= (int)$validation_count;
	
}
//rip bs-12
function tag_pr($payload, $opened) {
	//get the mergeable state
	$url = $payload['pull_request']['url'];
	$payload['pull_request'] = json_decode(apisend($url), TRUE);
	if($payload['pull_request']['mergeable'] == null) {
		//STILL not ready. Give it a bit, then try one more time
		sleep(10);
		$payload['pull_request'] = json_decode(apisend($url), TRUE);
	}

	$tags = array();
	$title = $payload['pull_request']['title'];
	if($opened) {	//you only have one shot on these ones so as to not annoy maintainers
		$tags = checkchangelog($payload, true, false);

		if(strpos(strtolower($title), 'refactor') !== FALSE)
			$tags[] = 'Refactor';
		
		if(strpos(strtolower($title), 'revert') !== FALSE || strpos(strtolower($title), 'removes') !== FALSE)
			$tags[] = 'Revert/Removal';
	}

	$remove = array();

	$mergeable = $payload['pull_request']['mergeable'];
	if($mergeable === TRUE)	//only look for the false value
		$remove[] = 'Merge Conflict';
	else if ($mergable === FALSE)
		$tags[] = 'Merge Conflict';

	$treetags = array('_maps' => 'Map Edit', 'tools' => 'Tools', 'SQL' => 'SQL');
	$addonlytags = array('icons' => 'Sprites', 'sounds' => 'Sound', 'config' => 'Config Update');
	foreach($treetags as $tree => $tag)
		if(has_tree_been_edited($payload, $tree))
			$tags[] = $tag;
		else
			$remove[] = $tag;
	foreach($addonlytags as $tree => $tag)
		if(has_tree_been_edited($payload, $tree))
			$tags[] = $tag;

	//only maintners should be able to remove these
	if(strpos(strtolower($title), '[dnm]') !== FALSE)
		$tags[] = 'Do Not Merge';

	if(strpos(strtolower($title), '[wip]') !== FALSE)
		$tags[] = 'Work In Progress';

	$url = $payload['pull_request']['issue_url'] . '/labels';

	$existing_labels = json_decode(apisend($url), true);

	$existing = array();
	foreach($existing_labels as $label)
		$existing[] = $label['name'];
	$tags = array_merge($tags, $existing);
	$tags = array_unique($tags);
	$tags = array_diff($tags, $remove);

	$final = array();
	foreach($tags as $t)
		$final[] = $t;


	echo apisend($url, 'PUT', $final);

	return $final;
}

function remove_ready_for_review($payload, $labels, $r4rlabel){
	$index = array_search($r4rlabel, $labels);
	if($index !== FALSE)
		unset($labels[$index]);
	$url = $payload['pull_request']['issue_url'] . '/labels';
	apisend($url, 'PUT', $labels);
}

function check_ready_for_review($payload, $labels){
	$r4rlabel =  'Ready for Review';
	$has_label_already = false;
	//if the label is already there we may need to remove it
	foreach($labels as $L)
		if($L == $r4rlabel){
			$has_label_already = true;
			break;
		}

	//find all reviews to see if changes were requested at some point
	$reviews = json_decode(apisend($payload['pull_request']['url'] . '/reviews'), true);

	$reviews_ids_with_changes_requested = array();

	foreach($reviews as $R){
		if($R['state'] == 'CHANGES_REQUESTED' && isset($R['author_association']) && ($R['author_association'] == 'MEMBER' || $R['author_association'] == 'CONTRIBUTOR' || $R['author_association'] == 'OWNER'))
			$reviews_ids_with_changes_requested[] = $R['id'];
	}

	if(count($reviews_ids_with_changes_requested) == 0){
		if($has_label_already)
			remove_ready_for_review($payload, $labels, $r4rlabel);
		return;	//no need to be here
	}

	echo count($reviews_ids_with_changes_requested) . ' offending reviews';

	//now get the review comments for the offending reviews

	$review_comments = json_decode(apisend($payload['pull_request']['review_comments_url']), true);

	foreach($review_comments as $C){
		//make sure they are part of an offending review
		if(!in_array($C['pull_request_review_id'], $reviews_ids_with_changes_requested))
			continue;
		
		//review comments which are outdated have a null position
		if($C['position'] !== null){
			if($has_label_already)
				remove_ready_for_review($payload, $labels, $r4rlabel);
			return;	//no need to tag
		}
	}

	$labels[] = $r4rlabel;
	$url = $payload['pull_request']['issue_url'] . '/labels';
	apisend($url, 'PUT', $labels);
}

function handle_pr($payload) {
	$action = 'opened';
	$validated = validate_user($payload);
	switch ($payload["action"]) {
		case 'opened':
			tag_pr($payload, true);
			if(get_pr_code_friendliness($payload) < 0){
				$balances = pr_balances();
				$author = $payload['pull_request']['user']['login'];
				if(isset($balances[$author]) && $balances[$author] < 0)
					create_comment($payload, 'You currently have a negative Fix/Feature pull request delta of ' . $balances[$author] . '. Maintainers may close this PR at will. Fixing issues or improving the codebase will improve this score.');
			}
			break;
		case 'edited':
		case 'synchronize':
			$labels = tag_pr($payload, false);
			check_ready_for_review($payload, $labels);
			return;
		case 'reopened':
			$action = $payload['action'];
			break;
		case 'closed':
			if (!$payload['pull_request']['merged']) {
				$action = 'closed';
			}
			else {
				$action = 'merged';
				auto_update($payload);
				checkchangelog($payload, true, true);
				update_pr_balance($payload);
				$validated = TRUE; //pr merged events always get announced.
			}
			break;
		default:
			return;
	} 
	
	if (strpos(strtolower($payload['pull_request']['title']), '[s]') !== false) {
		echo "PR Announcement Halted; Secret tag detected.\n";
		return;
	}
	if (!$validated) {
		echo "PR Announcement Halted; User not validated.\n";
		return;
	}
		
	$msg = '['.$payload['pull_request']['base']['repo']['full_name'].'] Pull Request '.$action.' by '.htmlSpecialChars($payload['sender']['login']).': <a href="'.$payload['pull_request']['html_url'].'">'.htmlSpecialChars('#'.$payload['pull_request']['number'].' '.$payload['pull_request']['user']['login'].' - '.$payload['pull_request']['title']).'</a>';
	sendtoallservers('?announce='.urlencode($msg), $payload);
}

//creates a comment on the payload issue
function create_comment($payload, $comment){
	apisend($payload['pull_request']['comments_url'], 'POST', json_encode(array('body' => $comment)));
}

//returns the payload issue's labels as a flat array
function get_pr_labels_array($payload){
	$url = $payload['pull_request']['issue_url'] . '/labels';
	$issue = json_decode(apisend($url), true);
	$result = array();
	foreach($issue as $l)
		$result[] = $l['name'];
	return $result;
}

//helper for getting the path the the balance json file
function pr_balance_json_path(){
	global $prBalanceJson;
	return $prBalanceJson != '' ? $prBalanceJson : 'pr_balances.json';
}

//return the assoc array of login -> balance for prs
function pr_balances(){
	$path = pr_balance_json_path();
	if(file_exists($path))
		return json_decode(file_get_contents($path), true);
	else
		return array();
}

//returns the difference in PR balance a pull request would cause
function get_pr_code_friendliness($payload, $oldbalance = null){
	global $startingPRBalance;
	if($oldbalance == null)
		$oldbalance = $startingPRBalance;
	$labels = get_pr_labels_array($payload);
	//anything not in this list defaults to 0
	$label_values = array(
		'Fix' => 2,
		'Refactor' => 2,
		'Code Improvement' => 1,
		'Priority: High' => 4,
		'Priority: CRITICAL' => 5,
		'Atmospherics' => 4,
		'Logging' => 1,
		'Feedback' => 1,
		'Performance' => 3,
		'Feature' => -1,
		'Balance/Rebalance' => -1,
		'Tweak' => -1,
		'PRB: Reset' => $startingPRBalance - $oldbalance,
	);

	$affecting = 0;
	$is_neutral = FALSE;
	$found_something_positive = false;
	foreach($labels as $l){
		if($l == 'PRB: No Update') {	//no effect on balance
			$affecting = 0;
			break;
		}
		else if(isset($label_values[$l])) {
			$friendliness = $label_values[$l];
			if($friendliness > 0)
				$found_something_positive = true;
			$affecting = $found_something_positive ? max($affecting, $friendliness) : $friendliness;
		}
	}
	return $affecting;
}

function is_maintainer($payload, $author){
	global $maintainer_team_id;
	$repo_is_org = $payload['pull_request']['base']['repo']['owner']['type'] == 'Organization';
	if($maintainer_team_id == null || !$repo_is_org) {
		$collaburl = $payload['pull_request']['base']['repo']['collaborators_url'] . '/' . $author . '/permissions';
		$perms = json_decode(apisend($collaburl), true);
		$permlevel = $perms['permission'];
		return $permlevel == 'admin' || $permlevel == 'write';
	}
	else {
		$check_url = 'https://api.github.com/teams/' . $maintainer_team_id . '/memberships/' . $author;
		$result = json_decode(apisend($check_url), true);
		return isset($result['state']);	//this field won't be here if they aren't a member
	}
}

//payload is a merged pull request, updates the pr balances file with the correct positive or negative balance based on comments
function update_pr_balance($payload) {
	global $startingPRBalance;
	global $trackPRBalance;
	if(!$trackPRBalance)
		return;
	$author = $payload['pull_request']['user']['login'];
	if(is_maintainer($payload, $author))	//immune
		return;
	$balances = pr_balances();
	if(!isset($balances[$author]))
		$balances[$author] = $startingPRBalance;
	$friendliness = get_pr_code_friendliness($payload, $balances[$author]);
	$balances[$author] += $friendliness;
	if($balances[$author] < 0 && $friendliness < 0)
		create_comment($payload, 'Your Fix/Feature pull request delta is currently below zero (' . $balances[$author] . '). Maintainers may close future Feature/Tweak/Balance PRs. Fixing issues or helping to improve the codebase will raise this score.');
	else if($balances[$author] >= 0 && ($balances[$author] - $friendliness) < 0)
		create_comment($payload, 'Your Fix/Feature pull request delta is now above zero (' . $balances[$author] . '). Feel free to make Feature/Tweak/Balance PRs.');
	$balances_file = fopen(pr_balance_json_path(), 'w');
	fwrite($balances_file, json_encode($balances));
	fclose($balances_file);
}

function auto_update($payload){
	global $enable_live_tracking;
	global $path_to_script;
	global $repoOwnerAndName;
	global $tracked_branch;
	if(!$enable_live_tracking || !has_tree_been_edited($payload, $path_to_script) || $payload['pull_request']['base']['ref'] != $tracked_branch)
		return;
	
	$content = file_get_contents('https://raw.githubusercontent.com/' . $repoOwnerAndName . '/' . $tracked_branch . '/'. $path_to_script);

	create_comment($payload, "Edit detected. Self updating... Here is my new code:\n``" . "`HTML+PHP\n" . $content . "\n``" . '`');

	$code_file = fopen(basename($path_to_script), 'w');
	fwrite($code_file, $content);
	fclose($code_file);
}

function has_tree_been_edited($payload, $tree){
	//go to the diff url
	$url = $payload['pull_request']['diff_url'];
	$content = file_get_contents($url);
	//find things in the _maps/map_files tree
	//e.g. diff --git a/_maps/map_files/Cerestation/cerestation.dmm b/_maps/map_files/Cerestation/cerestation.dmm
	return $content !== FALSE && strpos($content, 'diff --git a/' . $tree) !== FALSE;
}

function checkchangelog($payload, $merge = false, $compile = true) {
	if (!$merge)
		return;
	if (!isset($payload['pull_request']) || !isset($payload['pull_request']['body'])) {
		return;
	}
	if (!isset($payload['pull_request']['user']) || !isset($payload['pull_request']['user']['login'])) {
		return;
	}
	$body = $payload['pull_request']['body'];

	$tags = array();

	if(preg_match('/(?i)(fix|fixes|fixed|resolve|resolves|resolved)\s*#[0-9]+/',$body))	//github autoclose syntax
		$tags[] = 'Fix';

	$body = str_replace("\r\n", "\n", $body);
	$body = explode("\n", $body);

	$username = $payload['pull_request']['user']['login'];
	$incltag = false;
	$changelogbody = array();
	$currentchangelogblock = array();
	$foundcltag = false;
	foreach ($body as $line) {
		$line = trim($line);
		if (substr($line,0,4) == ':cl:' || substr($line,0,4) == '🆑') {
			$incltag = true;
			$foundcltag = true;
			$pos = strpos($line, " ");
			if ($pos) {
				$tmp = substr($line, $pos+1);
				if (trim($tmp) != 'optional name here')
					$username = $tmp;
			}
			continue;
		} else if (substr($line,0,5) == '/:cl:' || substr($line,0,6) == '/ :cl:' || substr($line,0,5) == ':/cl:' || substr($line,0,5) == '/🆑' || substr($line,0,6) == '/ 🆑' ) {
			$incltag = false;
			$changelogbody = array_merge($changelogbody, $currentchangelogblock);
			continue;
		}
		if (!$incltag)
			continue;
		
		$firstword = explode(' ', $line)[0];
		$pos = strpos($line, " ");
		$item = '';
		if ($pos) {
			$firstword = trim(substr($line, 0, $pos));
			$item = trim(substr($line, $pos+1));
		} else {
			$firstword = $line;
		}
		
		if (!strlen($firstword)) {
			$currentchangelogblock[count($currentchangelogblock)-1]['body'] .= "\n";
			continue;
		}
		//not a prefix line.
		//so we add it to the last changelog entry as a separate line
		if (!strlen($firstword) || $firstword[strlen($firstword)-1] != ':') {
			if (count($currentchangelogblock) <= 0)
				continue;
			$currentchangelogblock[count($currentchangelogblock)-1]['body'] .= "\n".$line;
			continue;
		}
		$cltype = strtolower(substr($firstword, 0, -1));
		switch ($cltype) {
			case 'fix':
			case 'fixes':
			case 'bugfix':
				if($item != 'fixed a few things') {
					$tags[] = 'Fix';
					$currentchangelogblock[] = array('type' => 'bugfix', 'body' => $item);
				}
				break;
			case 'wip':
				if($item != 'added a few works in progress')
					$currentchangelogblock[] = array('type' => 'wip', 'body' => $item);
				break;
			case 'rsctweak':
			case 'tweaks':
			case 'tweak':
				if($item != 'tweaked a few things') {
					$tags[] = 'Tweak';
					$currentchangelogblock[] = array('type' => 'tweak', 'body' => $item);
				}
				break;
			case 'soundadd':
				if($item != 'added a new sound thingy') {
					$tags[] = 'Sound';
					$currentchangelogblock[] = array('type' => 'soundadd', 'body' => $item);
				}
				break;
			case 'sounddel':
				if($item != 'removed an old sound thingy') {
					$tags[] = 'Sound';
					$tags[] = 'Revert/Removal';
					$currentchangelogblock[] = array('type' => 'sounddel', 'body' => $item);
				}
				break;
			case 'add':
			case 'adds':
			case 'rscadd':
				if($item != 'Added new things' && $item != 'Added more things') {
					$tags[] = 'Feature';
					$currentchangelogblock[] = array('type' => 'rscadd', 'body' => $item);
				}
				break;
			case 'del':
			case 'dels':
			case 'rscdel':
				if($item != 'Removed old things') {
					$tags[] = 'Revert/Removal';
					$currentchangelogblock[] = array('type' => 'rscdel', 'body' => $item);
				}
				break;
			case 'imageadd':
				if($item != 'added some icons and images') {
					$tags[] = 'Sprites';
					$currentchangelogblock[] = array('type' => 'imageadd', 'body' => $item);
				}
				break;
			case 'imagedel':
				if($item != 'deleted some icons and images') {
					$tags[] = 'Sprites';
					$tags[] = 'Revert/Removal';
					$currentchangelogblock[] = array('type' => 'imagedel', 'body' => $item);
				}
				break;
			case 'typo':
			case 'spellcheck':
				if($item != 'fixed a few typos') {
					$tags[] = 'Grammar and Formatting';
					$currentchangelogblock[] = array('type' => 'spellcheck', 'body' => $item);
				}
				break;
			case 'experimental':
			case 'experiment':
				if($item != 'added an experimental thingy')
					$currentchangelogblock[] = array('type' => 'experiment', 'body' => $item);
				break;
			case 'balance':
			case 'rebalance':
				if($item != 'rebalanced something'){
					$tags[] = 'Balance/Rebalance';
					$currentchangelogblock[] = array('type' => 'balance', 'body' => $item);
				}
				break;
			case 'tgs':
				$currentchangelogblock[] = array('type' => 'tgs', 'body' => $item);
				break;
			default:
				//we add it to the last changelog entry as a separate line
				if (count($currentchangelogblock) > 0)
					$currentchangelogblock[count($currentchangelogblock)-1]['body'] .= "\n".$line;
				break;
		}
	}

	if (!count($changelogbody) || !$compile)
		return $tags;

	$file = 'author: "'.trim(str_replace(array("\\", '"'), array("\\\\", "\\\""), $username)).'"'."\n";
	$file .= "delete-after: True\n";
	$file .= "changes: \n";
	foreach ($changelogbody as $changelogitem) {
		$type = $changelogitem['type'];
		$body = trim(str_replace(array("\\", '"'), array("\\\\", "\\\""), $changelogitem['body']));
		$file .= '  - '.$type.': "'.$body.'"';
		$file .= "\n";
	}
	$content = array (
		'branch' 	=> $payload['pull_request']['base']['ref'],
		'message' 	=> 'Automatic changelog generation for PR #'.$payload['pull_request']['number'].' [ci skip]',
		'content' 	=> base64_encode($file)
	);

	$filename = '/html/changelogs/AutoChangeLog-pr-'.$payload['pull_request']['number'].'.yml';
	echo apisend($payload['pull_request']['base']['repo']['url'].'/contents'.$filename, 'PUT', $content);
}

function sendtoallservers($str, $payload = null) {
	global $servers;
	if (!empty($payload))
		$str .= '&payload='.urlencode(json_encode($payload));
	foreach ($servers as $serverid => $server) {
		$msg = $str;
		if (isset($server['comskey']))
			$msg .= '&key='.urlencode($server['comskey']);
		$rtn = export($server['address'], $server['port'], $msg);
		echo "Server Number $serverid replied: $rtn\n";
	}
}



function export($addr, $port, $str) {
	// All queries must begin with a question mark (ie "?players")
	if($str{0} != '?') $str = ('?' . $str);
	
	/* --- Prepare a packet to send to the server (based on a reverse-engineered packet structure) --- */
	$query = "\x00\x83" . pack('n', strlen($str) + 6) . "\x00\x00\x00\x00\x00" . $str . "\x00";
	
	/* --- Create a socket and connect it to the server --- */
	$server = socket_create(AF_INET,SOCK_STREAM,SOL_TCP) or exit("ERROR");
	socket_set_option($server, SOL_SOCKET, SO_SNDTIMEO, array('sec' => 2, 'usec' => 0)); //sets connect and send timeout to 2 seconds
	if(!socket_connect($server,$addr,$port)) {
		return "ERROR: Connection failed";
	}

	
	/* --- Send bytes to the server. Loop until all bytes have been sent --- */
	$bytestosend = strlen($query);
	$bytessent = 0;
	while ($bytessent < $bytestosend) {
		//echo $bytessent.'<br>';
		$result = socket_write($server,substr($query,$bytessent),$bytestosend-$bytessent);
		//echo 'Sent '.$result.' bytes<br>';
		if ($result===FALSE) 
			return "ERROR: " . socket_strerror(socket_last_error());
		$bytessent += $result;
	}
	
	/* --- Idle for a while until recieved bytes from game server --- */
	$result = socket_read($server, 10000, PHP_BINARY_READ);
	socket_close($server); // we don't need this anymore
	
	if($result != "") {
		if($result{0} == "\x00" || $result{1} == "\x83") { // make sure it's the right packet format
			
			// Actually begin reading the output:
			$sizebytes = unpack('n', $result{2} . $result{3}); // array size of the type identifier and content
			$size = $sizebytes[1] - 1; // size of the string/floating-point (minus the size of the identifier byte)
			
			if($result{4} == "\x2a") { // 4-byte big-endian floating-point
				$unpackint = unpack('f', $result{5} . $result{6} . $result{7} . $result{8}); // 4 possible bytes: add them up together, unpack them as a floating-point
				return $unpackint[1];
			}
			else if($result{4} == "\x06") { // ASCII string
				$unpackstr = ""; // result string
				$index = 5; // string index
				
				while($size > 0) { // loop through the entire ASCII string
					$size--;
					$unpackstr .= $result{$index}; // add the string position to return string
					$index++;
				}
				return $unpackstr;
			}
		}
	}
	return "";
}
?>
