<?php
function replace_extension($filename, $new_extension) {
	$info = pathinfo($filename);
	return $info['filename'] . '.' . $new_extension;
}

function parseTags($tags) {
	$tagCollection = array();
	$ctag = "";
	$inQuotes = false;

	foreach (str_split($tags) as $c) {
		switch ($c) {
			case ' ' :
				if ($inQuotes)
					$ctag .= ' ';
				else {
					$tagCollection[] = $ctag;
					$ctag = "";
				}
				break;
			case '"' :
				if ($inQuotes) {
					$tagCollection[] = $ctag;
					$ctag = "";
					$inQuotes = false;
				} else {
					$inQuotes = true;
				}
				break;
			default :
				$ctag .= $c;
				break;
		}
	}
	if (!empty($ctag)) {
		$tagCollection[] = $ctag;
	}
	return $tagCollection;
}

function startsWith($haystack, $needle) {
	$length = strlen($needle);
	return (substr($haystack, 0, $length) === $needle);
}

function endsWith($haystack, $needle) {
	$length = strlen($needle);
	if ($length == 0) {
		return true;
	}

	return (substr($haystack, -$length) === $needle);
}

function urlFmtTag($tag) {
	if (is_array($tag)) {
		$o = array();
		foreach ($tag as $t) {
			$o[] = urlFmtTag($t);
		}
		return implode(' ', $o);
	}
	return str_replace(' ', '_', $tag);
}

function unfuckTag($tag) {
	return str_replace('_', ' ', $tag);
}

# remove by key:
function array_remove_key() {
	$args = func_get_args();
	return array_diff_key($args[0], array_flip(array_slice($args, 1)));
}

# remove by value:
function array_remove_value() {
	$args = func_get_args();
	return array_diff($args[0], array_slice($args, 1));
}

/**
 * Format URL.
 *
 * @param act The action to invoke
 * @param ...
 */
function fmtURL() {
	$args = func_get_args();
	$o = WEB_ROOT . '/index.php/' . $args[0];
	array_shift($args);
	foreach ($args as $arg) {
		$o .= '/' . $arg;
	}
	return $o;
}

/**
 * Format APIURL.
 *
 * @param act The action to invoke
 * @param ...
 */
function fmtAPIURL() {
	$args = func_get_args();
	$o = WEB_ROOT . '/api.php/' . $args[0];
	array_shift($args);
	foreach ($args as $arg) {
		$o .= '/' . $arg;
	}
	return $o;
}
function dialog($title, $body, $choices) {
	$choiceshtml = '';
	if (count($choices) > 0) {
		foreach ($choices as $choice) {
			$choiceshtml .= '<li>' . $choice . '</li>';
		}
	}
	return "<div class=\"dialog\">" . "<div class=\"dlgTitle\">$title</div>" . "<div class=\"dlgBody\">$body</div>" . "<ul class=\"dlgChoices\">" . $choiceshtml . "</ul></div>";
}

function startwatch($category) {
	global $sw_current, $sw_;
	if (!isset($sw_))
		$sw_ = array();
	if (!isset($sw_[$sw_current[0]]))
		$sw_[$sw_current[0]] = 0;
	$sw_current[0] = $category;
	$sw_current[1] = microtime(true);
}

function stopwatch($category) {
	global $sw_current, $sw_;
	if (!isset($sw_))
		$sw_ = array();
	$elapsed = microtime(true) - $sw_current[1];
	$sw_[$sw_current[0]] += $elapsed;
	return $elapsed;
}

function getMime($file) {
	$finfo = finfo_open(FILEINFO_MIME_TYPE);
	// return mime type ala mimetype extension
	$o = finfo_file($finfo, $file);
	finfo_close($finfo);
	return $o;
}

/**
 * Indents a flat JSON string to make it more human-readable.
 *
 * @param string $json The original JSON string to process.
 *
 * @return string Indented version of the original JSON string.
 */
function indentJSON($json) {

	$result = '';
	$pos = 0;
	$strLen = strlen($json);
	$indentStr = '  ';
	$newLine = "\n";
	$prevChar = '';
	$outOfQuotes = true;

	for ($i = 0; $i <= $strLen; $i++) {

		// Grab the next character in the string.
		$char = substr($json, $i, 1);

		// Are we inside a quoted string?
		if ($char == '"' && $prevChar != '\\') {
			$outOfQuotes = !$outOfQuotes;

			// If this character is the end of an element,
			// output a new line and indent the next line.
		} else if (($char == '}' || $char == ']') && $outOfQuotes) {
			$result .= $newLine;
			$pos--;
			for ($j = 0; $j < $pos; $j++) {
				$result .= $indentStr;
			}
		}

		// Add the character to the result string.
		$result .= $char;

		// If the last character was the beginning of an element,
		// output a new line and indent the next line.
		if (($char == ',' || $char == '{' || $char == '[') && $outOfQuotes) {
			$result .= $newLine;
			if ($char == '{' || $char == '[') {
				$pos++;
			}

			for ($j = 0; $j < $pos; $j++) {
				$result .= $indentStr;
			}
		}

		$prevChar = $char;
	}

	return $result;
}

function doInsertSQL($table, $row) {
	global $db;
	$col = join(',', array_keys($row));
	$qmarks = join(',', array_fill(0, count($row), '?'));
	$sql = "INSERT INTO `$table` ($col) VALUES ($qmarks)";
	$db->Execute($sql, array_values($row));
}


function doReplaceSQL($table, $row) {
	global $db;
	$col = join(',', array_keys($row));
	$qmarks = join(',', array_fill(0, count($row), '?'));
	$sql = "REPLACE INTO `$table` ($col) VALUES ($qmarks)";
	$db->Execute($sql, array_values($row));
}

function doUpdateSQL($table, $row, $where) {
	global $db;
	$sset = array();
	foreach ($row as $key => $val)
		$sset[] = "`$key`=?";
	$set = join(', ', $sset);
	$sql = "UPDATE `$table` SET $set WHERE $where";
	$db->Execute($sql, array_values($row));
}

function file_ext_strip($filename) {
	return preg_replace('/\.[^.]*$/', '', $filename);
}
