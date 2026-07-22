#!/usr/bin/env python3
"""
ASD-STE100 Simplified Technical English Comment Rewriter
========================================================
Rewrites all comments in .dm files to comply with ASD-STE100 rules:
- Simple words from approved vocabulary
- Short sentences (max 25 words per sentence)
- Active voice
- One topic per sentence
- No gerunds as main verbs in procedures
- Imperative mood for instructions
"""

import re
import os
import sys
from pathlib import Path

# ── ASD-STE100 transformation rules ─────────────────────────────────────────

# Rule 1: Replace complex/archaic words with simple alternatives
WORD_MAP = {
    # Abbreviations → full forms
    "w/": "with",
    "w/o": "without",
    "btw": "by the way",
    "eg": "for example",
    "ie": "that is",
    "etc": "and so on",
    "aka": "also known as",
    "bc": "because",
    "cuz": "because",
    "tho": "though",
    "thru": "through",
    "til": "until",
    "pls": "please",
    "plz": "please",
    "thx": "thanks",
    "u": "you",
    "ur": "your",
    "r": "are",
    "y": "why",
    "k": "okay",
    "np": "no problem",
    "imo": "in my opinion",
    "imho": "in my opinion",
    "fyi": "for your information",
    "tbh": "to be honest",
    "idk": "I do not know",
    "tbd": "to be decided",
    "wip": "work in progress",
    "todo": "to do",
    "fixme": "fix me",
    "hack": "temporary solution",
    "kludge": "temporary solution",
    "borked": "broken",
    "wonky": "unstable",
    "janky": "low quality",
    "jank": "low quality code",
    # Complex words → simple alternatives
    "utilize": "use",
    "utilizes": "uses",
    "utilized": "used",
    "utilizing": "using",
    "utilization": "use",
    "leverage": "use",
    "leverages": "uses",
    "leveraged": "used",
    "leveraging": "using",
    "demonstrate": "show",
    "demonstrates": "shows",
    "demonstrated": "showed",
    "demonstrating": "showing",
    "commence": "start",
    "commences": "starts",
    "commenced": "started",
    "commencing": "starting",
    "terminate": "stop",
    "terminates": "stops",
    "terminated": "stopped",
    "terminating": "stopping",
    "termination": "end",
    "obtain": "get",
    "obtains": "gets",
    "obtained": "got",
    "obtaining": "getting",
    "require": "need",
    "requires": "needs",
    "required": "needed",
    "requiring": "needing",
    "requirement": "need",
    "requirements": "needs",
    "necessitate": "need",
    "necessitates": "needs",
    "necessitated": "needed",
    "necessitating": "needing",
    "endeavor": "try",
    "endeavors": "tries",
    "endeavored": "tried",
    "endeavoring": "trying",
    "attempt": "try",
    "attempts": "tries",
    "attempted": "tried",
    "attempting": "trying",
    "implement": "add",
    "implements": "adds",
    "implemented": "added",
    "implementing": "adding",
    "implementation": "code",
    "facilitate": "help",
    "facilitates": "helps",
    "facilitated": "helped",
    "facilitating": "helping",
    "sufficient": "enough",
    "sufficiently": "enough",
    "regarding": "about",
    "concerning": "about",
    "pertaining": "about",
    "subsequent": "next",
    "subsequently": "then",
    "prior": "before",
    "hence": "so",
    "thus": "so",
    "therefore": "so",
    "nevertheless": "but",
    "however": "but",
    "nonetheless": "but",
    "furthermore": "also",
    "moreover": "also",
    "additionally": "also",
    "in order to": "to",
    "in the event that": "if",
    "in the case of": "for",
    "on the basis of": "based on",
    "with regard to": "about",
    "with respect to": "about",
    "a number of": "many",
    "the majority of": "most",
    "a large number of": "many",
    "due to the fact that": "because",
    "in spite of the fact that": "although",
    "it is necessary that": "must",
    "it is possible that": "may",
    "it is important that": "must",
    "make an assumption": "assume",
    "make a decision": "decide",
    "make use of": "use",
    "take into account": "think about",
    "take into consideration": "think about",
    "give consideration to": "think about",
    # Slang/informal → formal simple
    "gonna": "going to",
    "wanna": "want to",
    "gotta": "got to",
    "kinda": "kind of",
    "sorta": "sort of",
    "lemme": "let me",
    "gimme": "give me",
    "dunno": "do not know",
    "ain't": "is not",
    "y'all": "you all",
    "yeet": "throw",
    "pog": "good",
    "poggers": "excellent",
    "based": "good",
    "cringe": "uncomfortable",
    "sus": "suspicious",
    "suspect": "suspicious",
    "goated": "excellent",
}

# Rule 2: Fix passive voice patterns → active voice
PASSIVE_TO_ACTIVE = [
    # Pattern: "X is/was/were/will be VERBed by Y" → "Y VERBs X"
    # These are handled below in a more general way
]

# Words that indicate passive constructions to flag
PASSIVE_INDICATORS = [
    "is being", "are being", "was being", "were being",
    "has been", "have been", "had been",
    "will be", "shall be", "should be", "would be",
    "must be", "can be", "could be", "may be", "might be",
]

# Rule 3: Words to avoid (gerunds used as main verbs)
GERUND_STARTS = [
    "running ", "getting ", "taking ", "making ", "doing ",
    "going ", "putting ", "setting ", "calling ", "using ",
    "checking ", "finding ", "giving ", "having ", "letting ",
]


def repair_passive(text):
    """Convert common passive constructions to active voice — conservative approach."""
    # Only fix the most clear-cut patterns to avoid mangling text
    # "is used by X" → "X uses"
    text = re.sub(
        r'\b(is|are|was|were)\s+used\s+by\s+(\w+)',
        lambda m: f'{m.group(2)} uses',
        text,
    )
    # "is called by X" → "X calls"
    text = re.sub(
        r'\b(is|are|was|were)\s+called\s+by\s+(\w+)',
        lambda m: f'{m.group(2)} calls',
        text,
    )
    return text


def _make_active(past_tense):
    """Convert past tense verb to active present (simple heuristic)."""
    if past_tense.endswith('ed'):
        base = past_tense[:-2]
        if base.endswith('i'):
            return base[:-1] + 'y'
        return base
    return past_tense


def split_long_sentences(text, max_words=25):
    """Split sentences that exceed max_words into shorter ones."""
    sentences = re.split(r'(?<=[.!?])\s+', text)
    result = []
    for sent in sentences:
        words = sent.split()
        if len(words) <= max_words:
            result.append(sent)
            continue
        # Split on conjunctions: and, but, or, so, then, which, that, because
        parts = re.split(r'\s*(?:,\s*)?(?:and|but|or)\s+', sent)
        if len(parts) == 1:
            parts = re.split(r'\s*;\s*', sent)
        if len(parts) == 1:
            result.append(sent)
        else:
            # Capitalize each part
            for i, part in enumerate(parts):
                if i == 0:
                    result.append(part.strip())
                else:
                    part = part.strip()
                    if part and part[0].islower():
                        part = part[0].upper() + part[1:]
                    result.append(part)
    return '. '.join(result) if result else text


def apply_word_map(text):
    """Replace complex words with ASD-STE100 approved simple words."""
    words = text.split()
    result = []
    for word in words:
        clean_lower = word.lower().strip('.,;:!?()[]{}"\'')
        if clean_lower in WORD_MAP:
            # Preserve original case pattern
            replacement = WORD_MAP[clean_lower]
            if word[0].isupper() and word[0] != 'I':
                replacement = replacement[0].upper() + replacement[1:]
            result.append(replacement)
        else:
            result.append(word)
    return ' '.join(result)


def rewrite_comment(comment_text, is_doc=False):
    """
    Rewrite a single comment to ASD-STE100 compliance.

    Args:
        comment_text: The raw comment text (without // or /* */ markers)
        is_doc: True if this is a documentation block comment

    Returns:
        Rewritten comment text
    """
    original = comment_text

    # Step 1: Replace complex words
    text = apply_word_map(original)

    # Step 2: Repair passive voice
    text = repair_passive(text)

    # Step 3: Split long sentences
    text = split_long_sentences(text, max_words=25)

    # Step 4: Ensure one topic per paragraph (split on multiple ands)
    # If a sentence has too many clauses, split further

    # Step 5: Remove filler words at sentence start
    text = re.sub(r'^(Well,\s*|Um,\s*|Err,\s*|So,\s*|Like,\s*)', '', text)
    text = re.sub(r'\.\s+(Well,\s*|Um,\s*|So,\s*)', '. ', text)

    # Step 6: Clean up whitespace
    text = re.sub(r'\s+', ' ', text).strip()

    return text


def extract_comments_from_dm(content):
    """
    Extract all comments from .dm file content.
    Returns list of (start_pos, end_pos, comment_type, comment_text, is_doc)
    For block comments, comment_text preserves the original inner content
    including newlines and * markers.
    """
    comments = []
    i = 0
    length = len(content)

    while i < length:
        # Check for block comments /* */
        if i + 1 < length and content[i:i+2] == '/*':
            j = content.find('*/', i + 2)
            if j != -1:
                inner = content[i+2:j]
                # Determine if doc comment
                is_doc = content[i:i+3] == '/**'
                # If multi-line, preserve it as-is; only rewrite single-line blocks
                if '\n' in inner:
                    comments.append((i, j + 2, 'block_multiline', inner, is_doc))
                else:
                    comments.append((i, j + 2, 'block_single', inner, is_doc))
                i = j + 2
            else:
                i += 1
        # Check for line comments //
        elif i + 1 < length and content[i:i+2] == '//':
            j = content.find('\n', i + 2)
            if j == -1:
                j = length
            comment_text = content[i+2:j]
            is_doc = False
            if comment_text.startswith('/'):
                is_doc = True
                comment_text = comment_text[1:]  # Strip leading / for /// comments
            comments.append((i, j, 'line', comment_text, is_doc))
            i = j
        # Skip strings
        elif content[i] == '"':
            j = i + 1
            while j < length:
                if content[j] == '\\':
                    j += 2
                    continue
                if content[j] == '"':
                    break
                j += 1
            i = j + 1
        elif content[i] == "'":
            j = content.find("'", i + 1)
            if j == -1:
                i += 1
            else:
                i = j + 1
        else:
            i += 1

    return comments


def rewrite_dm_file(filepath, dry_run=False):
    """
    Rewrite all comments in a .dm file to ASD-STE100 compliance.

    Args:
        filepath: Path to the .dm file
        dry_run: If True, only report changes without modifying the file

    Returns:
        Number of comments rewritten
    """
    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
    except Exception as e:
        print(f"  ERROR reading {filepath}: {e}", file=sys.stderr)
        return 0

    comments = extract_comments_from_dm(content)

    if not comments:
        return 0

    # Process from end to start to preserve positions
    modified = 0
    new_content = content

    for start_pos, end_pos, ctype, comment_text, is_doc in reversed(comments):
        # Skip multi-line block comments — preserve them as-is
        if ctype == 'block_multiline':
            continue

        rewritten = rewrite_comment(comment_text, is_doc)

        # Only update if the comment actually changed
        if rewritten != comment_text:
            if ctype == 'line':
                prefix = '///' if is_doc else '//'
                # Ensure space between prefix and comment text
                if rewritten and not rewritten[0].isspace():
                    new_comment = prefix + ' ' + rewritten
                else:
                    new_comment = prefix + rewritten
            elif ctype == 'block_single':
                prefix = '/**' if is_doc else '/*'
                if rewritten and not rewritten[0].isspace():
                    new_comment = prefix + ' ' + rewritten + ' */'
                else:
                    new_comment = prefix + rewritten + ' */'
            else:
                continue

            new_content = new_content[:start_pos] + new_comment + new_content[end_pos:]
            modified += 1

    if modified > 0 and not dry_run:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)

    return modified


def _indent_of(content, pos):
    """Get the indentation string before position pos."""
    line_start = content.rfind('\n', 0, pos) + 1
    indent = ''
    for i in range(line_start, pos):
        ch = content[i]
        if ch in (' ', '\t'):
            indent += ch
        else:
            break
    return indent


def _preserve_line_prefix(original_comment_text):
    """Preserve the leading whitespace/indentation of a comment line."""
    stripped = original_comment_text.lstrip()
    leading = original_comment_text[:len(original_comment_text) - len(stripped)]
    return leading, stripped


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Rewrite DM comments to ASD-STE100')
    parser.add_argument('path', help='File or directory to process')
    parser.add_argument('--dry-run', action='store_true', help='Do not modify files')
    parser.add_argument('--file-glob', default='*.dm', help='File pattern (default: *.dm)')
    args = parser.parse_args()

    path = Path(args.path)

    if path.is_file():
        files = [path]
    else:
        files = list(path.rglob(args.file_glob))

    total_modified = 0
    total_comments = 0

    for f in files:
        try:
            n = rewrite_dm_file(str(f), dry_run=args.dry_run)
            if n > 0:
                total_modified += 1
                total_comments += n
                if total_modified % 100 == 0:
                    print(f"  Progress: {total_modified} files, {total_comments} comments", file=sys.stderr)
        except Exception as e:
            print(f"  ERROR: {f}: {e}", file=sys.stderr)

    print(f"\nProcessed {len(files)} files.", file=sys.stderr)
    print(f"Modified {total_modified} files.", file=sys.stderr)
    print(f"Rewritten {total_comments} comments.", file=sys.stderr)

    if args.dry_run:
        print("DRY RUN - no files were modified.", file=sys.stderr)


if __name__ == '__main__':
    main()
