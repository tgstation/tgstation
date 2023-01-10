<?php
/*
 *	Github webhook In-game PR Announcer and Changelog Generator for /tg/Station13
 *	Author: MrStonedOne
 *	For documentation on the changelog generator see https://tgstation13.org/phpBB/viewtopic.php?f=5&t=5157
 *	To hide prs from being announced in game, place a [s] in front of the title
 *	All runtime errors are echo'ed to the webhook's logs in github
 *  Events to be sent via GitHub webhook: Pull Requests, Pushes
 *  Any other Event will result in a 404 returned to the webhook.
 */

/**CREDITS:
 * GitHub webhook handler template.
 *
 * @see  https://developer.github.com/webhooks/
 * @author  Miloslav Hula (https://github.com/milo)
 */

define('S_LINK_EMBED', 1<<0);
define('S_MENTIONS', 1<<1);
define('S_MARKDOWN', 1<<2);
define('S_HTML_COMMENTS', 1<<3);

define('F_UNVALIDATED_USER', 1<<0);
define('F_SECRET_PR', 1<<1);

//CONFIGS ARE IN SECRET.PHP, THESE ARE JUST DEFAULTS!

$hookSecret = '08ajh0qj93209qj90jfq932j32r';
$apiKey = '209ab8d879c0f987d06a09b9d879c0f987d06a09b9d8787d0a089c';
$repoOwnerAndName = "tgstation/tgstation";
$servers = array();
$enable_live_tracking = true;
$path_to_script = 'tools/WebhookProcessor/github_webhook_processor.php';
$tracked_branch = "master";
$maintainer_team_id = 133041;
$validation = "org";
$validation_count = 1;
$tracked_branch = 'master';
$require_changelogs = false;
$discordWebHooks = array();

// Only these repositories will announce in game.
// Any repository that players actually care about.
$game_announce_whitelist = array(
	"tgstation",
	"TerraGov-Marine-Corps",
);

// Any repository that matches in this blacklist will not appear on Discord.
$discord_announce_blacklist = array(
	"/^event-.*$/",
);

require_once 'secret.php';

//CONFIG END
function log_error($msg) {
	echo htmlSpecialChars($msg);
	file_put_contents('htwebhookerror.log', '['.date(DATE_ATOM).'] '.$msg.PHP_EOL, FILE_APPEND);
}
set_error_handler(function($severity, $message, $file, $line) {
	throw new \ErrorException($message, 0, $severity, $file, $line);
});
set_exception_handler(function($e) {
	header('HTTP/1.1 500 Internal Server Error');
	log_error('Error on line ' . $e->getLine() . ': ' . $e->getMessage());
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
	case 'pull_request_review':
		if($payload['action'] == 'submitted'){
			$lower_state = strtolower($payload['review']['state']);
			if(($lower_state == 'approved' || $lower_state == 'changes_requested') && is_maintainer($payload, $payload['review']['user']['login']))
				remove_ready_for_review($payload);
		}
		break;
	default:
		header('HTTP/1.0 404 Not Found');
		echo "Event:$_SERVER[HTTP_X_GITHUB_EVENT] Payload:\n";
		print_r($payload); # For debug only. Can be found in GitHub hook log.
		die();
}

function apisend($url, $method = 'GET', $content = null, $authorization = null) {
	if (is_array($content))
		$content = json_encode($content);

	$headers = array();
	$headers[] = 'Content-type: application/json';
	if ($authorization)
		$headers[] = 'Authorization: ' . $authorization;

	$scontext = array('http' => array(
		'method'		=> $method,
		'header'		=> implode("\r\n", $headers),
		'ignore_errors' => true,
		'user_agent' 	=> 'tgstation13.org-Github-Automation-Tools'
	));

	if ($content)
		$scontext['http']['content'] = $content;

	return file_get_contents($url, false, stream_context_create($scontext));

}

function github_apisend($url, $method = 'GET', $content = NULL) {
	global $apiKey;
	return apisend($url, $method, $content, 'token ' . $apiKey);
}

function discord_webhook_send($webhook, $content) {
	return apisend($webhook, 'POST', $content);
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
	$res = github_apisend('https://api.github.com/search/issues?q='.$querystring);
	$res = json_decode($res, TRUE);
	return (isset($res['total_count']) && $res['total_count'] >= (int)$validation_count);

}

function get_labels($payload){
	$url = $payload['pull_request']['issue_url'] . '/labels';
	$existing_labels = json_decode(github_apisend($url), true);
	$existing = array();
	foreach((array) $existing_labels as $label)
		$existing[] = $label['name'];
	return $existing;
}

function check_tag_and_replace($payload, $title_tag, $label, &$array_to_add_label_to){
	$title = $payload['pull_request']['title'];
	if(stripos($title, $title_tag) !== FALSE){
		$array_to_add_label_to[] = $label;
		return true;
	}
	return false;
}

function set_labels($payload, $labels, $remove) {
	$existing = get_labels($payload);
	$tags = array();

	$tags = array_merge($labels, $existing);
	$tags = array_unique($tags);
	if($remove) {
		$tags = array_diff($tags, $remove);
	}

	$final = array();
	foreach($tags as $t)
		$final[] = $t;

	$url = $payload['pull_request']['issue_url'] . '/labels';
	echo github_apisend($url, 'PUT', $final);
}

//rip bs-12
function tag_pr($payload, $opened) {
	//get the mergeable state
	$url = $payload['pull_request']['url'];
	$payload['pull_request'] = json_decode(github_apisend($url), TRUE);
	if($payload['pull_request']['mergeable'] == null) {
		//STILL not ready. Give it a bit, then try one more time
		sleep(10);
		$payload['pull_request'] = json_decode(github_apisend($url), TRUE);
	}

	$tags = array();
	$title = $payload['pull_request']['title'];
	if($opened) {	//you only have one shot on these ones so as to not annoy maintainers
		$tags = checkchangelog($payload);

		if(strpos(strtolower($title), 'logs') !== FALSE || strpos(strtolower($title), 'logging') !== FALSE)
			$tags[] = 'Logging';
		if(strpos(strtolower($title), 'refactor') !== FALSE)
			$tags[] = 'Refactor';
		if(strpos(strtolower($title), 'revert') !== FALSE)
			$tags[] = 'Revert';
		if(strpos(strtolower($title), 'removes') !== FALSE)
			$tags[] = 'Removal';
	}

	$remove = array('Test Merge Candidate');

	$mergeable = $payload['pull_request']['mergeable'];
	if($mergeable === TRUE)	//only look for the false value
		$remove[] = 'Merge Conflict';
	else if ($mergeable === FALSE)
		$tags[] = 'Merge Conflict';

	$treetags = array('_maps' => 'Map Edit', 'tools' => 'Tools', 'SQL' => 'SQL', '.github' => 'GitHub');
	$addonlytags = array('icons' => 'Sprites', 'sound' => 'Sound', 'config' => 'Config Update', 'code/controllers/configuration/entries' => 'Config Update', 'tgui' => 'UI');
	foreach($treetags as $tree => $tag)
		if(has_tree_been_edited($payload, $tree))
			$tags[] = $tag;
		else
			$remove[] = $tag;
	foreach($addonlytags as $tree => $tag)
		if(has_tree_been_edited($payload, $tree))
			$tags[] = $tag;

	check_tag_and_replace($payload, '[dnm]', 'Do Not Merge', $tags);
	check_tag_and_replace($payload, '[no gbp]', 'GBP: No Update', $tags);

	return array($tags, $remove);
}

function remove_ready_for_review($payload, $labels = null){
	if($labels == null)
		$labels = get_labels($payload);
	$index = array_search('Needs Review', $labels);
	if($index !== FALSE)
		unset($labels[$index]);
	$url = $payload['pull_request']['issue_url'] . '/labels';
	github_apisend($url, 'PUT', $labels);
}

function dismiss_review($payload, $id, $reason){
	$content = array('message' => $reason);
	github_apisend($payload['pull_request']['url'] . '/reviews/' . $id . '/dismissals', 'PUT', $content);
}

function get_reviews($payload){
	return json_decode(github_apisend($payload['pull_request']['url'] . '/reviews'), true);
}

function check_dismiss_changelog_review($payload){
	global $require_changelogs;
	global $no_changelog;

	if(!$require_changelogs)
		return;

	if(!$no_changelog)
		checkchangelog($payload);

	$review_message = 'Your changelog for this PR is either malformed or non-existent. Please create one to document your changes.';

	$reviews = get_reviews($payload);
	if($no_changelog){
		//check and see if we've already have this review
		foreach($reviews as $R)
			if($R['body'] == $review_message && strtolower($R['state']) == 'changes_requested')
				return;
		//otherwise make it ourself
		github_apisend($payload['pull_request']['url'] . '/reviews', 'POST', array('body' => $review_message, 'event' => 'REQUEST_CHANGES'));
	}
	else
		//kill previous reviews
		foreach($reviews as $R)
			if($R['body'] == $review_message && strtolower($R['state']) == 'changes_requested')
				dismiss_review($payload, $R['id'], 'Changelog added/fixed.');
}

function is_blacklisted($blacklist, $name) {
	foreach ($blacklist as $pattern) {
		if (preg_match($pattern, $name)) {
			return true;
		}
	}

	return false;
}

function handle_pr($payload) {
	global $discord_announce_blacklist;
	global $no_changelog;
	global $game_announce_whitelist;

	$action = 'opened';
	$validated = validate_user($payload);
	switch ($payload["action"]) {
		case 'opened':
			list($labels, $remove) = tag_pr($payload, true);
			set_labels($payload, $labels, $remove);
			if($no_changelog)
				check_dismiss_changelog_review($payload);
			break;
		case 'edited':
			check_dismiss_changelog_review($payload);
		case 'synchronize':
			list($labels, $remove) = tag_pr($payload, false);
			set_labels($payload, $labels, $remove);
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
				checkchangelog($payload);
				$validated = TRUE; //pr merged events always get announced.
			}
			break;
		default:
			return;
	}

	$pr_flags = 0;
	if (strpos(strtolower($payload['pull_request']['title']), '[s]') !== false) {
		$pr_flags |= F_SECRET_PR;
	}
	if (!$validated) {
		$pr_flags |= F_UNVALIDATED_USER;
	}

	$repo_name = $payload['repository']['name'];

	if (in_array($repo_name, $game_announce_whitelist)) {
		game_announce($action, $payload, $pr_flags);
	}

	if (!is_blacklisted($discord_announce_blacklist, $repo_name)) {
		discord_announce($action, $payload, $pr_flags);
	}
}

function filter_announce_targets($targets, $owner, $repo, $action, $pr_flags) {
	foreach ($targets as $i=>$target) {
		if (isset($target['exclude_events']) && in_array($action, array_map('strtolower', $target['exclude_events']))) {
			unset($targets[$i]);
			continue;
		}

		if (isset($target['announce_secret']) && $target['announce_secret']) {
			if (!($pr_flags & F_SECRET_PR) && $target['announce_secret'] === 'only') {
				unset($targets[$i]);
				continue;
			}
		} else if ($pr_flags & F_SECRET_PR) {
			unset($targets[$i]);
			continue;
		}

		if (isset($target['announce_unvalidated']) && $target['announce_unvalidated']) {
			if (!($pr_flags & F_UNVALIDATED_USER) && $target['announce_unvalidated'] === 'only') {
				unset($targets[$i]);
				continue;
			}
		} else if ($pr_flags & F_UNVALIDATED_USER) {
			unset($targets[$i]);
			continue;
		}

		$wildcard = false;
		if (isset($target['include_repos'])) {
			foreach ($target['include_repos'] as $match_string) {
				$owner_repo_pair = explode('/', strtolower($match_string));
				if (count($owner_repo_pair) != 2) {
					log_error('Bad include repo: `'. $match_string.'`');
					continue;
				}
				if (strtolower($owner) == $owner_repo_pair[0]) {
					if (strtolower($repo) == $owner_repo_pair[1])
						continue 2; //don't parse excludes when we have an exact include match
					if ($owner_repo_pair[1] == '*') {
						$wildcard = true;
						continue; //do parse excludes when we have a wildcard match (but check the other entries for exact matches first)
					}
				}
			}
			if (!$wildcard) {
				unset($targets[$i]);
				continue;
			}
		}

		if (isset($target['exclude_repos']))
			foreach ($target['exclude_repos'] as $match_string) {
				$owner_repo_pair = explode('/', strtolower($match_string));
				if (count($owner_repo_pair) != 2) {
					log_error('Bad exclude repo: `'. $match_string.'`');
					continue;
				}
				if (strtolower($owner) == $owner_repo_pair[0]) {
					if (strtolower($repo) == $owner_repo_pair[1]) {
						unset($targets[$i]);
						continue 2;
					}
					if ($owner_repo_pair[1] == '*') {
						if ($wildcard)
							log_error('Identical wildcard include and exclude: `'.$match_string.'`. Excluding.');
						unset($targets[$i]);
						continue 2;
					}
				}
			}
	}
	return $targets;
}

function game_announce($action, $payload, $pr_flags) {
	global $servers;

	$msg = '['.$payload['pull_request']['base']['repo']['full_name'].'] Pull Request '.$action.' by '.htmlSpecialChars($payload['sender']['login']).': <a href="'.$payload['pull_request']['html_url'].'">'.htmlSpecialChars('#'.$payload['pull_request']['number'].' '.$payload['pull_request']['user']['login'].' - '.$payload['pull_request']['title']).'</a>';

	$game_servers = filter_announce_targets($servers, $payload['pull_request']['base']['repo']['owner']['login'], $payload['pull_request']['base']['repo']['name'], $action, $pr_flags);

	$msg = '?announce='.urlencode($msg).'&payload='.urlencode(json_encode($payload));

	foreach ($game_servers as $serverid => $server) {
		$server_message = $msg;
		if (isset($server['comskey']))
			$server_message .= '&key='.urlencode($server['comskey']);
		game_server_send($server['address'], $server['port'], $server_message);
	}

}

function discord_announce($action, $payload, $pr_flags) {
	global $discordWebHooks;
	$color;
	switch ($action) {
		case 'reopened':
		case 'opened':
			$color = 0x2cbe4e;
			break;
		case 'closed':
			$color = 0xcb2431;
			break;
		case 'merged':
			$color = 0x6f42c1;
			break;
		default:
			return;
	}
	$data = array(
		'username' => 'GitHub',
		'avatar_url' => $payload['pull_request']['base']['user']['avatar_url'],
	);

	$content = 'Pull Request #'.$payload['pull_request']['number'].' *'.$action.'* by '.discord_sanitize($payload['sender']['login'])."\n".discord_sanitize($payload['pull_request']['user']['login']).' - __**'.discord_sanitize($payload['pull_request']['title']).'**__'."\n".'<'.$payload['pull_request']['html_url'].'>';

	$embeds = array(
			array(
				'title' => '__**'.discord_sanitize($payload['pull_request']['title'], S_MARKDOWN).'**__',
				'description' => discord_sanitize(str_replace(array("\r\n", "\n"), array(' ', ' '), substr($payload['pull_request']['body'], 0, 320)), S_HTML_COMMENTS),
				'url' => $payload['pull_request']['html_url'],
				'color' => $color,
				'author' => array(
					'name' => discord_sanitize($payload['pull_request']['user']['login'], S_MARKDOWN),
					'url' => $payload['pull_request']['user']['html_url'],
					'icon_url' => $payload['pull_request']['user']['avatar_url']
				),
				'footer' => array(
					'text' => '#'.$payload['pull_request']['number'].' '.discord_sanitize($payload['pull_request']['base']['repo']['full_name'], S_MARKDOWN).' '.discord_sanitize($payload['pull_request']['head']['ref'], S_MARKDOWN).' -> '.discord_sanitize($payload['pull_request']['base']['ref'], S_MARKDOWN),
					'icon_url' => $payload['pull_request']['base']['user']['avatar_url']
				)
			)
	);
	$discordWebHook_targets = filter_announce_targets($discordWebHooks, $payload['pull_request']['base']['repo']['owner']['login'], $payload['pull_request']['base']['repo']['name'], $action, $pr_flags);
	foreach ($discordWebHook_targets as $discordWebHook) {
		$sending_data = $data;
		if (isset($discordWebHook['embed']) && $discordWebHook['embed']) {
			$sending_data['embeds'] = $embeds;
			if (!isset($discordWebHook['no_text']) || !$discordWebHook['no_text'])
				$sending_data['content'] = $content;
		} else {
			$sending_data['content'] = $content;
		}
		discord_webhook_send($discordWebHook['url'], $sending_data);
	}

}

function discord_sanitize($text, $flags = S_MENTIONS|S_LINK_EMBED|S_MARKDOWN) {
	if ($flags & S_MARKDOWN)
		$text = str_ireplace(array('\\', '*', '_', '~', '`', '|'), (array('\\\\', '\\*', '\\_', '\\~', '\\`', '\\|')), $text);

	if ($flags & S_HTML_COMMENTS)
		$text = preg_replace('/<!--(.*)-->/Uis', '', $text);

	if ($flags & S_MENTIONS)
		$text = str_ireplace(array('@everyone', '@here', '<@'), array('`@everyone`', '`@here`', '@<'), $text);

	if ($flags & S_LINK_EMBED)
		$text = preg_replace("/((https?|ftp|byond)\:\/\/)([a-z0-9-.]*)\.([a-z]{2,3})(\:[0-9]{2,5})?(\/(?:[a-z0-9+\$_-]\.?)+)*\/?(\?[a-z+&\$_.-][a-z0-9;:@&%=+\/\$_.-]*)?(#[a-z_.-][a-z0-9+\$_.-]*)?/mi", '<$0>', $text);

	return $text;
}

//creates a comment on the payload issue
function create_comment($payload, $comment){
	github_apisend($payload['pull_request']['comments_url'], 'POST', json_encode(array('body' => $comment)));
}

//returns the payload issue's labels as a flat array
function get_pr_labels_array($payload){
	$url = $payload['pull_request']['issue_url'] . '/labels';
	$issue = json_decode(github_apisend($url), true);
	$result = array();
	foreach($issue as $l)
		$result[] = $l['name'];
	return $result;
}

function is_maintainer($payload, $author){
	global $maintainer_team_id;
	$repo_is_org = $payload['pull_request']['base']['repo']['owner']['type'] == 'Organization';
	if($maintainer_team_id == null || !$repo_is_org) {
		$collaburl = str_replace('{/collaborator}', '/' . $author, $payload['pull_request']['base']['repo']['collaborators_url']) . '/permission';
		$perms = json_decode(github_apisend($collaburl), true);
		$permlevel = $perms['permission'];
		return $permlevel == 'admin' || $permlevel == 'write';
	}
	else {
		$check_url = 'https://api.github.com/teams/' . $maintainer_team_id . '/memberships/' . $author;
		$result = json_decode(github_apisend($check_url), true);
		return isset($result['state']) && $result['state'] == 'active';
	}
}

$github_diff = null;

function get_diff($payload) {
	global $github_diff;
	if ($github_diff === null && $payload['pull_request']['diff_url']) {
		//go to the diff url
		$url = $payload['pull_request']['diff_url'];
		$github_diff = file_get_contents($url);
	}
	return $github_diff;
}

function auto_update($payload){
	global $enable_live_tracking;
	global $path_to_script;
	global $repoOwnerAndName;
	global $tracked_branch;
	global $github_diff;
	if(!$enable_live_tracking || !has_tree_been_edited($payload, $path_to_script) || $payload['pull_request']['base']['ref'] != $tracked_branch)
		return;

	get_diff($payload);
	$content = file_get_contents('https://raw.githubusercontent.com/' . $repoOwnerAndName . '/' . $tracked_branch . '/'. $path_to_script);
	$content_diff = "### Diff not available. :slightly_frowning_face:";
	if($github_diff && preg_match('/(diff --git a\/' . preg_quote($path_to_script, '/') . '.+?)(?:\Rdiff|$)/s', $github_diff, $matches)) {
		$script_diff = $matches[1];
		if($script_diff) {
			$content_diff = "``" . "`DIFF\n" . $script_diff ."\n``" . "`";
		}
	}
	create_comment($payload, "Edit detected. Self updating... \n<details><summary>Here are my changes:</summary>\n\n" . $content_diff . "\n</details>\n<details><summary>Here is my new code:</summary>\n\n``" . "`HTML+PHP\n" . $content . "\n``" . '`\n</details>');

	$code_file = fopen(basename($path_to_script), 'w');
	fwrite($code_file, $content);
	fclose($code_file);
}

function has_tree_been_edited($payload, $tree){
	global $github_diff;
	get_diff($payload);
	//find things in the _maps/map_files tree
	//e.g. diff --git a/_maps/map_files/Cerestation/cerestation.dmm b/_maps/map_files/Cerestation/cerestation.dmm
	return ($github_diff !== FALSE) && (preg_match('/^diff --git a\/' . preg_quote($tree, '/') . '/m', $github_diff) !== 0);
}

$no_changelog = false;
function checkchangelog($payload) {
	global $no_changelog;
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

	$incltag = false;
	$foundcltag = false;
	foreach ($body as $line) {
		$line = trim($line);
		if (substr($line,0,4) == ':cl:' || substr($line,0,1) == '??') {
			$incltag = true;
			$foundcltag = true;
			continue;
		} else if (substr($line,0,5) == '/:cl:' || substr($line,0,6) == '/ :cl:' || substr($line,0,5) == ':/cl:' || substr($line,0,5) == '/??' || substr($line,0,6) == '/ ??' ) {
			$incltag = false;
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

		// Line is empty
		if (!strlen($firstword)) {
			continue;
		}

		//not a prefix line.
		if (!strlen($firstword) || $firstword[strlen($firstword)-1] != ':') {
			continue;
		}

		$cltype = strtolower(substr($firstword, 0, -1));

		// !!!
		// !!! If you are changing any of these at the bottom, also edit `tools/pull_request_hooks/changelogConfig.js`.
		// !!!

		switch ($cltype) {
			case 'fix':
			case 'fixes':
			case 'bugfix':
				if($item != 'fixed a few things') {
					$tags[] = 'Fix';
				}
				break;
			case 'qol':
				if($item != 'made something easier to use') {
					$tags[] = 'Quality of Life';
				}
				break;
			case 'soundadd':
				if($item != 'added a new sound thingy') {
					$tags[] = 'Sound';
				}
				break;
			case 'sounddel':
				if($item != 'removed an old sound thingy') {
					$tags[] = 'Sound';
					$tags[] = 'Removal';
				}
				break;
			case 'add':
			case 'adds':
			case 'rscadd':
				if($item != 'Added new mechanics or gameplay changes' && $item != 'Added more things') {
					$tags[] = 'Feature';
				}
				break;
			case 'del':
			case 'dels':
			case 'rscdel':
				if($item != 'Removed old things') {
					$tags[] = 'Removal';
				}
				break;
			case 'imageadd':
				if($item != 'added some icons and images') {
					$tags[] = 'Sprites';
				}
				break;
			case 'imagedel':
				if($item != 'deleted some icons and images') {
					$tags[] = 'Sprites';
					$tags[] = 'Removal';
				}
				break;
			case 'typo':
			case 'spellcheck':
				if($item != 'fixed a few typos') {
					$tags[] = 'Grammar and Formatting';
				}
				break;
			case 'balance':
				if($item != 'rebalanced something'){
					$tags[] = 'Balance';
				}
				break;
			case 'code_imp':
			case 'code':
				if($item != 'changed some code'){
					$tags[] = 'Code Improvement';
				}
				break;
			case 'refactor':
				if($item != 'refactored some code'){
					$tags[] = 'Refactor';
				}
				break;
			case 'config':
				if($item != 'changed some config setting'){
					$tags[] = 'Config Update';
				}
				break;
			case 'admin':
				if($item != 'messed with admin stuff'){
					$tags[] = 'Administration';
				}
				break;
		}
	}
	return $tags;
}

function game_server_send($addr, $port, $str) {
	// All queries must begin with a question mark (ie "?players")
	if($str[0] != '?') $str = ('?' . $str);

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
		if($result[0] == "\x00" || $result[1] == "\x83") { // make sure it's the right packet format

			// Actually begin reading the output:
			$sizebytes = unpack('n', $result[2] . $result[3]); // array size of the type identifier and content
			$size = $sizebytes[1] - 1; // size of the string/floating-point (minus the size of the identifier byte)

			if($result[4] == "\x2a") { // 4-byte big-endian floating-point
				$unpackint = unpack('f', $result[5] . $result[6] . $result[7] . $result[8]); // 4 possible bytes: add them up together, unpack them as a floating-point
				return $unpackint[1];
			}
			else if($result[4] == "\x06") { // ASCII string
				$unpackstr = ""; // result string
				$index = 5; // string index

				while($size > 0) { // loop through the entire ASCII string
					$size--;
					$unpackstr .= $result[$index]; // add the string position to return string
					$index++;
				}
				return $unpackstr;
			}
		}
	}
	return "";
}
?>
