import { useAtomValue } from 'jotai';
import { type KeyboardEvent, useEffect, useRef, useState } from 'react';
import {
  type AdminVerb,
  adminTargetsAtom,
  adminVerbsAtom,
  typepathsAtom,
  type VerbArg,
} from './atoms';

const ARG_TYPE_TEXT = 1 << 0;
const ARG_TYPE_NUM = 1 << 1;
const ARG_TYPE_MESSAGE = 1 << 2;
const ARG_TYPE_MOB = 1 << 5;
const ARG_TYPE_OBJ = 1 << 6;
const ARG_TYPE_TURF = 1 << 7;
const ARG_TYPE_AREA = 1 << 8;
const ARG_TYPE_DATUM = 1 << 9;
const ARG_TYPE_ATOM = 1 << 10;
const ARG_TYPE_TYPEPATH = 1 << 11;
const ARG_TYPE_ENTITY =
  ARG_TYPE_MOB | ARG_TYPE_OBJ | ARG_TYPE_TURF | ARG_TYPE_AREA | ARG_TYPE_DATUM | ARG_TYPE_ATOM;

function toKebab(name: string): string {
  return name.replaceAll(' ', '-');
}

function isTypepathArg(arg: VerbArg): boolean {
  return (arg.arg_type & ARG_TYPE_TYPEPATH) !== 0;
}

function isEntityArg(arg: VerbArg): boolean {
  return (arg.arg_type & ARG_TYPE_ENTITY) !== 0;
}

function isTextArg(arg: VerbArg): boolean {
  return (arg.arg_type & (ARG_TYPE_TEXT | ARG_TYPE_MESSAGE)) !== 0;
}

function parseArgs(raw: string): string[] {
  const result: string[] = [];
  let i = 0;
  while (i < raw.length) {
    if (raw[i] === ' ') {
      i++;
      continue;
    }
    if (raw[i] === '"') {
      const end = raw.indexOf('"', i + 1);
      if (end === -1) {
        result.push(raw.slice(i + 1));
        break;
      }
      result.push(raw.slice(i + 1, end));
      i = end + 1;
    } else {
      const end = raw.indexOf(' ', i);
      if (end === -1) {
        result.push(raw.slice(i));
        break;
      }
      result.push(raw.slice(i, end));
      i = end;
    }
  }
  return result;
}

function isInQuotedArg(raw: string): boolean {
  let inQuote = false;
  for (let i = 0; i < raw.length; i++) {
    if (raw[i] === '"') {
      inQuote = !inQuote;
    }
  }
  return inQuote;
}

const MODES = ['Command', 'Say', 'Whisper', 'Me', 'OOC'] as const;
type Mode = (typeof MODES)[number];

const MODE_COLORS: Record<Mode, string> = {
  Command: '#888',
  Say: '#a3d977',
  Whisper: '#a89ccc',
  Me: '#d4a44a',
  OOC: '#6cb6ff',
};

export function CommandBar() {
  const verbs = useAtomValue(adminVerbsAtom);
  const targets = useAtomValue(adminTargetsAtom);
  const typepaths = useAtomValue(typepathsAtom);
  const [input, setInput] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [selectedVerb, setSelectedVerb] = useState<AdminVerb | null>(null);
  const [filledArgs, setFilledArgs] = useState<string[]>([]);
  const [lastTypepathRequest, setLastTypepathRequest] = useState('');
  const [mode, setMode] = useState<Mode>('Command');
  const inputRef = useRef<HTMLInputElement>(null);

  const verbArgs = selectedVerb?.args || [];
  const currentArgIndex = selectedVerb ? filledArgs.length : -1;
  const currentArg: VerbArg | null =
    currentArgIndex >= 0 && currentArgIndex < verbArgs.length
      ? verbArgs[currentArgIndex]
      : null;
  const isCurrentArgTypepath = currentArg ? isTypepathArg(currentArg) : false;

  useEffect(() => {
    Byond.sendMessage('verbs/request_verbs');
  }, []);

  // Raw arg portion after verb name
  const argPortion = selectedVerb
    ? input.slice(toKebab(selectedVerb.name).length + 1)
    : '';
  // Parse filled + current token from the arg portion
  const parsedArgs = selectedVerb ? parseArgs(argPortion) : [];
  const currentToken =
    parsedArgs.length > filledArgs.length
      ? parsedArgs[filledArgs.length]
      : '';
  const inQuotedArg = selectedVerb ? isInQuotedArg(argPortion) : false;

  // Verb suggestions — prefix matches first, then substring matches, sorted by name length
  const verbSuggestions: AdminVerb[] = (() => {
    if (selectedVerb || input.length === 0) return [];
    const query = input.toLowerCase();
    const prefix: AdminVerb[] = [];
    const substring: AdminVerb[] = [];
    for (const v of verbs) {
      if (!v.name) continue;
      const kebab = toKebab(v.name).toLowerCase();
      if (kebab.startsWith(query)) {
        prefix.push(v);
      } else if (kebab.includes(query)) {
        substring.push(v);
      }
    }
    prefix.sort((a, b) => a.name.length - b.name.length);
    substring.sort((a, b) => a.name.length - b.name.length);
    return [...prefix, ...substring].slice(0, 8);
  })();

  // Typepath suggestions
  const typepathSuggestions =
    selectedVerb && isCurrentArgTypepath
      ? typepaths
          .filter(
            (p) =>
              currentToken.length === 0 ||
              p.toLowerCase().startsWith(currentToken.toLowerCase()),
          )
          .slice(0, 8)
      : [];

  // Target suggestions — only for entity-type args
  const isCurrentArgEntity = currentArg ? isEntityArg(currentArg) : false;
  const targetSuggestions =
    selectedVerb && isCurrentArgEntity && targets.length > 0
      ? targets
          .filter(
            (t) =>
              currentToken.length === 0 ||
              t.name.toLowerCase().includes(currentToken.toLowerCase()),
          )
          .slice(0, 8)
      : [];

  const allSuggestions = isCurrentArgTypepath
    ? typepathSuggestions
    : selectedVerb
      ? targetSuggestions
      : verbSuggestions;
  const hasSuggestions = allSuggestions.length > 0;

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'ArrowDown' && hasSuggestions) {
      e.preventDefault();
      setSelectedIndex((i) => Math.min(i + 1, allSuggestions.length - 1));
    } else if (e.key === 'ArrowUp' && hasSuggestions) {
      e.preventDefault();
      setSelectedIndex((i) => Math.max(i - 1, 0));
    } else if (e.key === ' ' && !inQuotedArg) {
      // Space outside quotes: autocomplete verb or prevent double spaces
      if (!selectedVerb) {
        e.preventDefault();
        if (verbSuggestions.length > 0) {
          selectVerb(verbSuggestions[selectedIndex]);
        }
      } else if (input.endsWith(' ')) {
        // Prevent multiple consecutive spaces
        e.preventDefault();
      }
    } else if (e.key === 'Tab') {
      e.preventDefault();
      if (!selectedVerb && verbSuggestions.length > 0) {
        selectVerb(verbSuggestions[selectedIndex]);
      } else if (isCurrentArgTypepath && typepathSuggestions.length > 0) {
        selectTypepath(typepathSuggestions[selectedIndex] as string);
      } else if (selectedVerb && targetSuggestions.length > 0) {
        // Autocomplete the target into the current arg
        selectTarget(
          targetSuggestions[selectedIndex] as { name: string; ref: string },
        );
      }
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (!selectedVerb && verbSuggestions.length > 0) {
        const verb = verbSuggestions[selectedIndex];
        if (verb.args.length === 0) {
          Byond.sendMessage('verbs/invoke', {
            verb_type: verb.type,
            args: {},
          });
          if (mode !== 'Command') {
            enterChatMode(mode);
          } else {
            resetInput();
          }
        } else {
          selectVerb(verb);
        }
      } else if (isCurrentArgTypepath && typepathSuggestions.length > 0) {
        selectTypepath(typepathSuggestions[selectedIndex] as string);
      } else if (isCurrentArgTypepath && currentToken) {
        // Accept what's typed as a typepath directly
        fillArg(currentToken);
      } else if (selectedVerb && targetSuggestions.length > 0) {
        selectTarget(
          targetSuggestions[selectedIndex] as { name: string; ref: string },
        );
      } else if (selectedVerb) {
        invokeVerb();
      }
    } else if (e.key === 'Escape') {
      e.preventDefault();
      if (mode !== 'Command') {
        enterChatMode(mode);
      } else {
        resetInput();
      }
    }
  };

  const enterChatMode = (chatMode: Mode) => {
    const verb = verbs.find((v) => v.name === chatMode);
    if (!verb) return;
    setSelectedVerb(verb);
    setFilledArgs([]);
    setSelectedIndex(0);
    setLastTypepathRequest('');
    const kebab = toKebab(verb.name);
    if (verb.args.length > 0 && isTextArg(verb.args[0])) {
      setInput(kebab + ' "');
    } else if (verb.args.length > 0) {
      setInput(kebab + ' ');
    } else {
      setInput(kebab);
    }
  };

  const cycleMode = () => {
    const nextIndex = (MODES.indexOf(mode) + 1) % MODES.length;
    const nextMode = MODES[nextIndex];
    setMode(nextMode);
    if (nextMode === 'Command') {
      setInput('');
      setSelectedVerb(null);
      setFilledArgs([]);
      setSelectedIndex(0);
      setLastTypepathRequest('');
    } else {
      enterChatMode(nextMode);
    }
    inputRef.current?.focus();
  };

  const handleChange = (value: string) => {
    if (!selectedVerb) {
      value = value.replaceAll(' ', '');
    }

    if (selectedVerb) {
      const verbPrefix = toKebab(selectedVerb.name) + ' ';
      if (!value.startsWith(verbPrefix)) {
        setSelectedVerb(null);
        setFilledArgs([]);
        if (mode !== 'Command') {
          setMode('Command');
        }
        value = value.split(' ')[0] || '';
      }
    }

    setInput(value);
    setSelectedIndex(0);

    // When closing quote typed, fill the text arg
    if (selectedVerb && currentArg && isTextArg(currentArg)) {
      const afterVerb = value.slice(toKebab(selectedVerb.name).length + 1);
      const parsed = parseArgs(afterVerb);
      if (parsed.length > filledArgs.length && !isInQuotedArg(afterVerb)) {
        const completedValue = parsed[filledArgs.length];
        const newFilled = [...filledArgs, completedValue];
        setFilledArgs(newFilled);

        const kebab = toKebab(selectedVerb.name);
        const serialized = newFilled
          .map((a, i) => {
            const arg = verbArgs[i];
            if (arg && isTextArg(arg)) return `"${a}"`;
            return a;
          })
          .join(' ');

        if (newFilled.length < verbArgs.length) {
          const nextArg = verbArgs[newFilled.length];
          if (nextArg && isTextArg(nextArg)) {
            setInput(kebab + ' ' + serialized + ' "');
          } else {
            setInput(kebab + ' ' + serialized + ' ');
          }
        }
      }
    }

    // For typepath args, request children when user types /
    if (selectedVerb && isCurrentArgTypepath) {
      const token = selectedVerb
        ? value.slice(
            toKebab(selectedVerb.name).length +
              1 +
              filledArgs.join(' ').length +
              (filledArgs.length > 0 ? 1 : 0),
          )
        : '';
      if (token.endsWith('/') && token !== lastTypepathRequest) {
        setLastTypepathRequest(token);
        Byond.sendMessage('verbs/request_typepaths', {
          parent: token.slice(0, -1) || '/datum',
        });
      }
    }
  };

  const selectVerb = (verb: AdminVerb) => {
    setSelectedVerb(verb);
    setFilledArgs([]);
    setSelectedIndex(0);
    setLastTypepathRequest('');
    const kebab = toKebab(verb.name);
    if (verb.args.length > 0) {
      const firstArg = verb.args[0];
      if (isTextArg(firstArg)) {
        setInput(kebab + ' "');
      } else {
        setInput(kebab + ' ');
      }
      if (isTypepathArg(firstArg)) {
        Byond.sendMessage('verbs/request_typepaths', { parent: '/datum' });
        setLastTypepathRequest('/');
      } else if (isEntityArg(firstArg)) {
        Byond.sendMessage('verbs/request_targets', { verb_type: verb.type });
      }
    } else {
      setInput(kebab);
    }
  };

  const selectTypepath = (path: string) => {
    // Request children of this path for further drilling
    Byond.sendMessage('verbs/request_typepaths', { parent: path });
    setLastTypepathRequest(path + '/');

    // Update input to show the selected path with trailing /
    if (!selectedVerb) return;
    const kebab = toKebab(selectedVerb.name);
    setInput(
      kebab +
        ' ' +
        filledArgs.join(' ') +
        (filledArgs.length > 0 ? ' ' : '') +
        path +
        '/',
    );
    setSelectedIndex(0);
  };

  const selectTarget = (target: { name: string; ref: string }) => {
    fillArg(target.ref);
  };

  const fillArg = (value: string) => {
    if (!selectedVerb) return;
    const newFilledArgs = [...filledArgs, value];
    setFilledArgs(newFilledArgs);
    setSelectedIndex(0);

    const kebab = toKebab(selectedVerb.name);
    const serializedArgs = newFilledArgs
      .map((a, i) => {
        const arg = verbArgs[i];
        if (arg && isTextArg(arg)) return `"${a}"`;
        return a;
      })
      .join(' ');

    if (newFilledArgs.length < verbArgs.length) {
      const nextArg = verbArgs[newFilledArgs.length];
      if (nextArg && isTextArg(nextArg)) {
        setInput(kebab + ' ' + serializedArgs + ' "');
      } else {
        setInput(kebab + ' ' + serializedArgs + ' ');
      }
    } else {
      setInput(kebab + ' ' + serializedArgs);
    }
  };

  const invokeVerb = () => {
    if (!selectedVerb) return;
    const argValues: Record<string, string> = {};
    const allArgs = [...filledArgs];
    if (currentToken) {
      allArgs.push(currentToken);
    }
    for (let i = 0; i < verbArgs.length && i < allArgs.length; i++) {
      argValues[verbArgs[i].name] = allArgs[i];
    }
    Byond.sendMessage('verbs/invoke', {
      verb_type: selectedVerb.type,
      args: argValues,
    });
    if (mode !== 'Command') {
      enterChatMode(mode);
    } else {
      resetInput();
    }
  };

  const resetInput = () => {
    setInput('');
    setSelectedVerb(null);
    setFilledArgs([]);
    setSelectedIndex(0);
    setLastTypepathRequest('');
  };

  const placeholder = selectedVerb
    ? `${toKebab(selectedVerb.name)} ${verbArgs.map((a) => `<${a.name}>`).join(' ')}`
    : 'Type a command...';

  return (
    <div className="CommandBar">
      <div className="CommandBar__input-wrap">
        {hasSuggestions && (
          <div className="CommandBar__suggestions">
            {!selectedVerb
              ? verbSuggestions.map((verb, i) => (
                  <div
                    key={verb.type}
                    className={`CommandBar__suggestion${i === selectedIndex ? ' CommandBar__suggestion--selected' : ''}`}
                    onMouseEnter={() => setSelectedIndex(i)}
                    onClick={() => selectVerb(verb)}
                  >
                    <span className="CommandBar__verb-name">
                      {toKebab(verb.name)}
                    </span>
                    {verb.args.length > 0 && (
                      <span className="CommandBar__verb-args">
                        {verb.args.map((a) => `<${a.name}>`).join(' ')}
                      </span>
                    )}
                  </div>
                ))
              : isCurrentArgTypepath
                ? (typepathSuggestions as string[]).map((path, i) => (
                    <div
                      key={path}
                      className={`CommandBar__suggestion${i === selectedIndex ? ' CommandBar__suggestion--selected' : ''}`}
                      onMouseEnter={() => setSelectedIndex(i)}
                      onClick={() => selectTypepath(path)}
                    >
                      <span className="CommandBar__typepath">{path}</span>
                    </div>
                  ))
                : (targetSuggestions as { name: string; ref: string }[]).map(
                    (target, i) => (
                      <div
                        key={target.ref}
                        className={`CommandBar__suggestion${i === selectedIndex ? ' CommandBar__suggestion--selected' : ''}`}
                        onMouseEnter={() => setSelectedIndex(i)}
                        onClick={() => selectTarget(target)}
                      >
                        <span className="CommandBar__target">
                          {target.name}
                        </span>
                      </div>
                    ),
                  )}
          </div>
        )}
        <input
          ref={inputRef}
          className="CommandBar__input"
          type="text"
          value={input}
          placeholder={placeholder}
          onChange={(e) => handleChange(e.target.value)}
          onKeyDown={handleKeyDown}
        />
      </div>
      <button
        className="CommandBar__mode-button"
        onClick={cycleMode}
        type="button"
        style={{ color: MODE_COLORS[mode] }}
      >
        {mode}
      </button>
    </div>
  );
}
