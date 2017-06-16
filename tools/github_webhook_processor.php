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
 
//Github lets you have it sign the message with a secret that you can validate. This prevents people from faking events.
//This var should match the secret you configured for this webhook on github.
//This is required as otherwise somebody could trick the script into leaking the api key.
$hookSecret = '08ajh0qj93209qj90jfq932j32r';

//Api key for pushing changelogs.
$apiKey = '209ab8d879c0f987d06a09b9d879c0f987d06a09b9d8787d0a089c';

//servers to announce PRs to.
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

//rip bs-12
function tag_pr($payload, $opened) {
	global $apiKey;

	//We need to reget the pull_request part of the payload to actually see the mergeable field populated
	//http://stackoverflow.com/questions/30619549/why-does-github-api-return-an-unknown-mergeable-state-in-a-pull-request
	$scontext = array('http' => array(
		'method'	=> 'GET',
		'header'	=>
			"Content-type: application/json\r\n".
			'Authorization: token ' . $apiKey,
		'ignore_errors' => true,
		'user_agent' 	=> 'tgstation13.org-Github-Automation-Tools'
	));

	$url = $payload['pull_request']['url'];
	$payload['pull_request'] = json_decode(file_get_contents($url, false, stream_context_create($scontext)), true);
	if($payload['pull_request']['mergeable'] == null) {
		//STILL not ready. Give it a bit, then try one more time
		sleep(10);
		$payload['pull_request'] = json_decode(file_get_contents($url, false, stream_context_create($scontext)), true);
	}

	$tags = array();
	$title = $payload['pull_request']['title'];
	if($opened) {	//you only have one shot on these ones so as to not annoy maintainers
		$tags = checkchangelog($payload, true, false);

		if(strpos(strtolower($title), 'refactor') !== FALSE)
			$tags[] = 'Refactor';
	}

	$remove = array();

	$mergeable = $payload['pull_request']['mergeable'];
	if($mergeable === TRUE)	//only look for the false value
		$remove[] = 'Merge Conflict';
	else if ($mergable === FALSE)
		$tags[] = 'Merge Conflict';

	if(has_tree_been_edited($payload, '_maps'))
		$tags[] = 'Map Edit';
	else
		$remove[] = 'Map Edit';

	if(has_tree_been_edited($payload, 'tools'))
		$tags[] = 'Tools';
	else
		$remove[] = 'Tools';

	//only maintners should be able to remove these
	if(strpos($title, '[DNM]') !== FALSE)
		$tags[] = 'Do Not Merge';

	if(strpos($title, '[WIP]') !== FALSE)
		$tags[] = 'Work In Progress';

	$url = $payload['pull_request']['base']['repo']['url'] . '/issues/' . $payload['pull_request']['number'] . '/labels';

	$existing_labels = file_get_contents($url, false, stream_context_create($scontext));
	$existing_labels = json_decode($existing_labels, true);

	$existing = array();
	foreach($existing_labels as $label)
		$existing[] = $label['name'];
	$tags = array_merge($tags, $existing);
	$tags = array_unique($tags);
	$tags = array_diff($tags, $remove);

	$final = array();
	foreach($tags as $t)
		$final[] = $t;

	$scontext['http']['method'] = 'PUT';
	$scontext['http']['content'] = json_encode($final);

	echo file_get_contents($url, false, stream_context_create($scontext));
}

function handle_pr($payload) {
	$action = 'opened';
	switch ($payload["action"]) {
		case 'opened':
			tag_pr($payload, true);
			break;
		case 'edited':
		case 'synchronize':
			tag_pr($payload, false);
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
				checkchangelog($payload, true, true);
			}
			break;
		default:
			return;
	} 
	
	if (strtolower(substr($payload['pull_request']['title'], 0, 3)) == '[s]') {
		echo "PR Announcement Halted; Secret tag detected.\n";
		return;
	}
	
	$msg = '['.$payload['pull_request']['base']['repo']['full_name'].'] Pull Request '.$action.' by '.htmlSpecialChars($payload['sender']['login']).': <a href="'.$payload['pull_request']['html_url'].'">'.htmlSpecialChars('#'.$payload['pull_request']['number'].' '.$payload['pull_request']['user']['login'].' - '.$payload['pull_request']['title']).'</a>';
	sendtoallservers('?announce='.urlencode($msg), $payload);

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
	global $apiKey;
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
	$scontext = array('http' => array(
        'method'	=> 'PUT',
        'header'	=>
			"Content-type: application/json\r\n".
			'Authorization: token ' . $apiKey,
        'content'	=> json_encode($content),
		'ignore_errors' => true,
		'user_agent' 	=> 'tgstation13.org-Github-Automation-Tools'
    ));
	$filename = '/html/changelogs/AutoChangeLog-pr-'.$payload['pull_request']['number'].'.yml';
	echo file_get_contents($payload['pull_request']['base']['repo']['url'].'/contents'.$filename, false, stream_context_create($scontext));
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
