use byond::call::return_to_byond;
use encoding::all::{WINDOWS_1252, ASCII, GB18030};
use encoding::Encoding;
use encoding::label::encoding_from_windows_code_page;
use encoding::types::DecoderTrap;
use libc;
use std::cmp::{max, Ordering};
use std::ffi::CStr;
use std::slice;
use std::ptr::null;

/// Encodes a byte string to UTF-8, using the encoding supplied.
///
/// Arguments are in the order of encoding, bytes.
#[no_mangle]
pub extern "C" fn to_utf8(n: libc::c_int, v: *const *const libc::c_char) -> *const libc::c_char {
    // We do not let the byond crate handle arguments, as we want BYTES directly.
    // Unicode decode could fail on the second argument.
    let text = unsafe {
        let slice = slice::from_raw_parts(v, n as usize);

        decode(&slice)
    };

    return_to_byond(&text).unwrap_or(null())
}

/// Encodes a byte string with a windows encoding, filters bad characters and limits message length.
///
/// Operations like message length are done on Unicode code points!
/// Arguments are in the order of encoding, bytes, cap.
#[no_mangle]
pub extern "C" fn utf8_sanitize(
    n: libc::c_int,
    v: *const *const libc::c_char,
) -> *const libc::c_char {
    // Can't use the BYOND crate again because of unicode conversion failing.
    let text = unsafe {
        let slice = slice::from_raw_parts(v, n as usize);
        let cap = CStr::from_ptr(slice[2])
            .to_str()
            .map(|cap| cap.parse::<usize>().unwrap_or(1024))
            .unwrap_or(1024);

        sanitize(&decode(&slice), cap)
    };

    return_to_byond(&text).unwrap_or(null())
}

/// Removes non-ASCII characters from the input string.
#[no_mangle]
pub extern "C" fn strict_ascii(
    n: libc::c_int,
    v: *const *const libc::c_char,
) -> *const libc::c_char {
    let bytes = unsafe {
        let slice = slice::from_raw_parts(v, n as usize);
        CStr::from_ptr(slice[0]).to_bytes()
    };

    return_to_byond(ASCII.decode(bytes, DecoderTrap::Ignore).unwrap()).unwrap_or(null())
}

/// Returns the length of a UTF-8 string.
byond!(utf8_len: text; {
    format!("{}", text.chars().count())
});

/* You saw nothing.
/// Returns the BYTE length of a UTF-8 string.
byond!(utf8_len_bytes: text; {
    format!("{}", text.len())
});
*/

byond!(utf8_find: haystack, needle, start, end; {
    match byte_bounds(haystack, start, end) {
        Some((start, end)) => {
            let ref sub = haystack[start .. end];
            match sub.find(needle) {
                Some(index) => format!("{}",
                    haystack
                    .char_indices()
                    .position(|x| x.0 == index)
                    .unwrap() + 1),
                None => "0".to_string()
            }
        }
        None => "0".to_string()
    }
});

byond!(utf8_index: text, index; {
    let index = index.parse::<isize>().unwrap_or(1);

    // 0-indexed index for the string, by code points.
    let index = match index.cmp(&0) {
        Ordering::Greater => index - 1,
        // Invalid index.
        Ordering::Equal => return "",
        Ordering::Less => {
            let char_count = text.chars().count() as isize;
            char_count + index
        }
    } as usize;

    // Get the byte bound.
    let mut iter = text.char_indices();
    let byte = match iter.nth(index) {
        Some((i, _)) => i,
        None => return ""
    };

    &text[byte .. iter.next().map(|(i, _)| i).unwrap_or(text.len())]
});

byond!(utf8_copy: text, start, end; {
    match byte_bounds(text, start, end) {
        Some((start, end)) => &text[start .. end],
        None => ""
    }
});

byond!(utf8_replace: text, from, to, start, end; {
    match byte_bounds(text, start, end) {
        Some((start, end)) => {
            let sub = &text[start .. end];
            let mut out = text[.. start].to_owned();
            out.push_str(&sub.replace(from, to));
            out.push_str(&text[end ..]);
            out
        },
        None => text.to_string()
    }
});

byond!(utf8_uppercase: text; {
    text.to_uppercase()
});

byond!(utf8_lowercase: text; {
    text.to_lowercase()
});

byond!(utf8_reverse: text; {
    text.chars().rev().collect::<String>()
});

// Side note: I originally tried to use the left-pad crate on Cargo.
// That crate is hilariously enough broken and doesn't understand what Unicode is.
// 10/10 meme tier.
byond!(utf8_leftpad: text, amount, with; {
    let amount = match amount.parse::<usize>() {
        Ok(a) => a,
        Err(_) => return text.to_owned()
    };

    let with = with.chars().next().unwrap_or(' ');
    let text_len = text.chars().count();

    if amount <= text_len {
        // Nothing would change.
        return text.into();
    }

    let filler_amount = amount - text_len;

    let mut out = String::with_capacity(text_len + filler_amount*with.len_utf8());

    for _ in 0..filler_amount {
        out.push(with);
    }

    out.push_str(text);

    out
});

byond!(utf8_is_whitespace: string; {
    match string.chars().all(|c| c.is_whitespace()) { true => "1", false => "0" }
});

byond!(utf8_trim: string; {
    string.trim()
});

/// Function to get the byte bounds for copytext, findtext and replacetext.
/// Goes by one-indexing and correctly handles negatives.
pub(crate) fn byte_bounds(text: &str, start: &str, end: &str) -> Option<(usize, usize)> {
    // BYOND uses 1-indexing because of course it does...
    // I would've made sick one liners out of this if the negative index stuff weren't a thing.
    let mut start = start.parse::<isize>().unwrap_or(1);
    let mut end = end.parse::<isize>().unwrap_or(0);

    let char_count = text.chars().count() as isize;

    start += if start < 0 { char_count } else { -1 };
    let start = max(start, 0) as usize;

    match end.cmp(&0) {
        Ordering::Greater => {
            end -= 1;
        }
        Ordering::Equal => {
            end = char_count;
        }
        Ordering::Less => {
            end += char_count;
        }
    }

    let end = max(end, 0) as usize;

    if end <= start {
        return None;
    }

    let mut iter = text.char_indices();

    match (iter.nth(start), iter.nth(end - start - 1)) {
        (Some((start, _)), Some((end, _))) => Some((start, end)),
        (Some((start, _)), None) => Some((start, text.len())),
        _ => None,
    }
}

/// See utf8.dm for what the codes correspond to.
pub(crate) unsafe fn decode(args: &[*const libc::c_char]) -> String {
    let bytes = CStr::from_ptr(args[1]).to_bytes();
    CStr::from_ptr(args[0])
        .to_str()
        .map(|e| e.parse::<usize>().unwrap_or(1252))
        .map(|e| match e {
            e @ 874 | e @ 1250...1258 => encoding_from_windows_code_page(e).unwrap_or(WINDOWS_1252),
            2312 => GB18030,
            _ => WINDOWS_1252,
        })
        .unwrap_or(WINDOWS_1252)
        .decode(bytes, DecoderTrap::Replace)
        .unwrap()
}

pub(crate) fn sanitize(text: &str, cap: usize) -> String {
    let mut out = String::with_capacity(text.len());
    let mut count = 0;
    for character in text.chars() {
        match character {
            '\u{0000}'...'\u{001F}' |
            '\u{0080}'...'\u{00A0}' => continue,
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            _ => out.push(character),
        };
        count += 1;
        if count >= cap {
            break;
        };
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use byond::call::test_byond_call_args;
    use std::ffi::CString;

    #[test]
    fn test_sanitize() {
        assert_eq!(sanitize("testing!", 1024), "testing!");
        assert_eq!(sanitize("testing<>!", 1024), "testing&lt;&gt;!");
        assert_eq!(sanitize("testing\n\n\n<>!", 1024), "testing&lt;&gt;!");
        assert_eq!(sanitize("testing\n\u{0088}\n<>!", 1024), "testing&lt;&gt;!");
        assert_eq!(
            sanitize("<script src='hacked.js'></script>icky ocky!\n<>!", 1024),
            "&lt;script src='hacked.js'&gt;&lt;/script&gt;icky ocky!&lt;&gt;!"
        );
        assert_eq!(sanitize("test", 3), "tes");
        assert_eq!(sanitize("\n\n\ntest", 3), "tes");
        assert_eq!(sanitize("\n\n\n>test", 3), "&gt;te");
    }

    #[test]
    fn test_utf8() {
        let encoding = CString::new(b"1252".as_ref()).unwrap();
        let test = CString::new(b"Hi there!".as_ref()).unwrap();
        let both = [encoding.as_ptr(), test.as_ptr()];

        unsafe { assert_eq!(decode(&both), "Hi there!") };


        let encoding = CString::new(b"1252".as_ref()).unwrap();
        let test = CString::new(b"H\xed th\xe9r\xe9!".as_ref()).unwrap();
        let both = [encoding.as_ptr(), test.as_ptr()];

        unsafe { assert_eq!(decode(&both), "Hí théré!") };


        let encoding = CString::new(b"1251".as_ref()).unwrap();
        let both = [encoding.as_ptr(), test.as_ptr()];

        unsafe { assert_eq!(decode(&both), "Hн thйrй!") };

        let encoding = CString::new(b"2312".as_ref()).unwrap();
        let test = CString::new(b"\xDE\xC4".as_ref()).unwrap();
        let both = [encoding.as_ptr(), test.as_ptr()];

        unsafe { assert_eq!(decode(&both), "弈") };
    }

    #[test]
    fn test_byte_bounds() {
        assert_eq!(byte_bounds("abcdefgh", "1", "0"), Some((0, 8)));
        assert_eq!(byte_bounds("abcdefgh", "0", "0"), Some((0, 8)));
        assert_eq!(byte_bounds("abcdefgh", "-2", "0"), Some((6, 8)));
        assert_eq!(byte_bounds("abcdefgh", "-4", "-2"), Some((4, 6)));
        assert_eq!(
            byte_bounds("abcdefghijklmnopwrstuvwxyz", "-4", "-2"),
            Some((22, 24))
        );
        assert_eq!(byte_bounds("abcdefgh", "-20", "-2"), Some((0, 6)));
        assert_eq!(byte_bounds("abcdefgh", "2", "1"), None);
        assert_eq!(byte_bounds("àbçdéfgh", "1", "0"), Some((0, 11)));
        assert_eq!(byte_bounds("àbç👏défgh", "2", "0"), Some((2, 15)));
        assert_eq!(byte_bounds("👏àbç👏défgh", "2", "0"), Some((4, 19)));
        assert_eq!(byte_bounds("abcdefgh", "20", "40"), None);
        assert_eq!(byte_bounds("abcdefgh", "3", "40"), Some((2, 8)));
    }

    #[test]
    fn test_utf8_find() {
        assert_eq!(
            test_byond_call_args(utf8_find, &["abcdefgh", "c", "1", "0"]),
            "3"
        );
        assert_eq!(
            test_byond_call_args(utf8_find, &["abcdefgh", "g", "1", "3"]),
            "0"
        );
        assert_eq!(
            test_byond_call_args(utf8_find, &["abcdefgh", "z", "1", "3"]),
            "0"
        );
    }

    #[test]
    fn test_utf8_len() {
        assert_eq!(test_byond_call_args(utf8_len, &["abc"]), "3");
        assert_eq!(test_byond_call_args(utf8_len, &[""]), "0");
        assert_eq!(
            test_byond_call_args(utf8_len, &["👏àbç👏défgh"]),
            "10"
        );
    }

    #[test]
    fn test_utf8_index() {
        assert_eq!(test_byond_call_args(utf8_index, &["abc", "1"]), "a");
        assert_eq!(test_byond_call_args(utf8_index, &["abc", "3"]), "c");
        assert_eq!(test_byond_call_args(utf8_index, &["abc", "-2"]), "b");
        assert_eq!(test_byond_call_args(utf8_index, &["abc", "-1"]), "c");
        assert_eq!(test_byond_call_args(utf8_index, &["abc", "5"]), "");
        assert_eq!(test_byond_call_args(utf8_index, &["abc", "0"]), "");
        assert_eq!(test_byond_call_args(utf8_index, &["abc", "-10"]), "");
        assert_eq!(test_byond_call_args(utf8_index, &["a👏bc", "3"]), "b");
        assert_eq!(test_byond_call_args(utf8_index, &["a👏bc", "2"]), "👏");
    }

    #[test]
    fn test_utf8_copy() {
        assert_eq!(
            test_byond_call_args(utf8_copy, &["abcdefgh", "1", "5"]),
            "abcd"
        );
        assert_eq!(
            test_byond_call_args(utf8_copy, &["a👏cdefgh", "1", "5"]),
            "a👏cd"
        );
        assert_eq!(
            test_byond_call_args(utf8_copy, &["abcdefgh", "-5", "-1"]),
            "defg"
        );
        assert_eq!(
            test_byond_call_args(utf8_copy, &["abcdefgh", "120", "200"]),
            ""
        );
        assert_eq!(
            test_byond_call_args(utf8_copy, &["abcdefgh", "1", "2000"]),
            "abcdefgh"
        );
        assert_eq!(test_byond_call_args(utf8_copy, &["abcdefgh", "5", "1"]), "");
        assert_eq!(
            test_byond_call_args(utf8_copy, &["abcdefgh", "5", "0"]),
            "efgh"
        );
        assert_eq!(
            test_byond_call_args(utf8_copy, &["abcdefgh", "5", "-2"]),
            "ef"
        )
    }

    #[test]
    fn test_utf8_replace() {
        assert_eq!(
            test_byond_call_args(utf8_replace, &["Hello world!", "o", "z", "1", "0"]),
            "Hellz wzrld!"
        );
        assert_eq!(
            test_byond_call_args(utf8_replace, &["Hello world!", "o", "👏", "1", "0"]),
            "Hell👏 w👏rld!"
        );
        assert_eq!(
            test_byond_call_args(utf8_replace, &["Hell👏 w👏rld!", "👏", "a", "1", "0"]),
            "Hella warld!"
        );
        assert_eq!(
            test_byond_call_args(utf8_replace, &["Hello world!", "👏", "a", "1", "0"]),
            "Hello world!"
        );
        assert_eq!(
            test_byond_call_args(utf8_replace, &["Hello world!", "o", "a", "7", "0"]),
            "Hello warld!"
        );
        assert_eq!(
            test_byond_call_args(utf8_replace, &["Hello world!", "o", "aAa", "7", "0"]),
            "Hello waAarld!"
        );
        assert_eq!(
            test_byond_call_args(utf8_replace, &["Hello world!", "ll", "aAa", "1", "0"]),
            "HeaAao world!"
        );
    }

    #[test]
    fn test_utf8_uppercase() {
        assert_eq!(test_byond_call_args(utf8_uppercase, &["Hello"]), "HELLO");
    }

    #[test]
    fn test_utf8_lowercase() {
        assert_eq!(test_byond_call_args(utf8_lowercase, &["Hello"]), "hello");
    }

    #[test]
    fn test_strict_ascii() {
        assert_eq!(test_byond_call_args(strict_ascii, &["Hello"]), "Hello");
        assert_eq!(test_byond_call_args(strict_ascii, &["Hell👏"]), "Hell");
        assert_eq!(test_byond_call_args(strict_ascii, &["Héllö"]), "Hll");
    }

    #[test]
    fn test_utf8_reverse() {
        assert_eq!(test_byond_call_args(utf8_reverse, &["Hello!"]), "!olleH");
        assert_eq!(
            test_byond_call_args(utf8_reverse, &["Hello!👏"]),
            "👏!olleH"
        );
    }

    #[test]
    fn test_utf8_leftpad() {
        assert_eq!(
            test_byond_call_args(utf8_leftpad, &["Hello!", "10", " "]),
            "    Hello!"
        );
        assert_eq!(
            test_byond_call_args(utf8_leftpad, &["Hello!", "0", " "]),
            "Hello!"
        );
        assert_eq!(
            test_byond_call_args(utf8_leftpad, &["Hello!", "🤔", " "]),
            "Hello!"
        );
        assert_eq!(
            test_byond_call_args(utf8_leftpad, &["Hello!", "10", "🌭"]),
            "🌭🌭🌭🌭Hello!"
        );
        assert_eq!(
            test_byond_call_args(utf8_leftpad, &["He🌭🌭o!", "20", "!"]),
            "!!!!!!!!!!!!!!He🌭🌭o!"
        );
    }

    #[test]
    fn test_utf8_is_whitespace() {
        assert_eq!(test_byond_call_args(utf8_is_whitespace, &[" "]), "1");
        assert_eq!(
            test_byond_call_args(utf8_is_whitespace, &[" \r\n\t\u{A0}"]),
            "1"
        ); // "\u{A0}" is U+00A0 NO-BREAK SPACE, AKA &nbsp;
        assert_eq!(test_byond_call_args(utf8_is_whitespace, &["  hi  "]), "0");
        assert_eq!(
            test_byond_call_args(utf8_is_whitespace, &[" \u{200B} "]),
            "0"
        ); // U+200B ZERO-WIDTH SPACE is NOT whitespace following Unicode.
    }

    #[test]
    fn test_utf8_trim() {
        assert_eq!(test_byond_call_args(utf8_trim, &[" "]), "");
        // "\u{A0}" is U+00A0 NO-BREAK SPACE, AKA &nbsp;
        assert_eq!(test_byond_call_args(utf8_trim, &[" \r\n\t\u{A0}"]), "");
        assert_eq!(test_byond_call_args(utf8_trim, &["  hi  "]), "hi");
        // U+200B ZERO-WIDTH SPACE is NOT whitespace following Unicode.
        assert_eq!(test_byond_call_args(utf8_trim, &[" \u{200B} "]), "\u{200B}");
        assert_eq!(
            test_byond_call_args(utf8_trim, &[" hi there! "]),
            "hi there!"
        );
        assert_eq!(
            test_byond_call_args(utf8_trim, &[" hi\u{A0}there! "]),
            "hi\u{A0}there!"
        );
    }
}
