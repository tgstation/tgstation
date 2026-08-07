import {
  isEntityArg,
  isListArg,
  isTextArg,
  isTypepathArg,
} from 'common/verb-constants';
import { useAtomValue } from 'jotai';
import { type KeyboardEvent, useEffect, useRef, useState } from 'react';

import {
  adminTargetsAtom,
  adminVerbsAtom,
  clearCommandBarAtom,
  focusCommandBarAtom,
  typepathsAtom,
  type Verb,
  type VerbArg,
} from './atoms';

function toKebab(name: string): string {
  return name.replaceAll(' ', '-');
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

function serializeInput(verb: Verb, filled: string[], suffix = ''): string {
  const kebab = toKebab(verb.name);
  if (filled.length === 0) return kebab + suffix;
  const parts = filled.map((a, i) => {
    const arg = verb.args[i];
    return arg && isTextArg(arg) ? `"${a}"` : a;
  });
  return `${kebab} ${parts.join(' ')}${suffix}`;
}

function suffixForArg(arg: VerbArg | undefined): string {
  if (!arg) return '';
  if (isTextArg(arg)) return ' "';
  return ' ';
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

type SuggestionState = {
  verbSuggestions: Verb[];
  typepathSuggestions: string[];
  targetSuggestions: { name: string; ref: string }[];
  listSuggestions: string[];
  allSuggestions: unknown[];
};

function useSuggestions(
  input: string,
  selectedVerb: Verb | null,
  currentArg: VerbArg | null,
  currentToken: string,
): SuggestionState {
  const verbs = useAtomValue(adminVerbsAtom);
  const targets = useAtomValue(adminTargetsAtom);
  const typepaths = useAtomValue(typepathsAtom);

  const isCurrentTypepath = currentArg ? isTypepathArg(currentArg) : false;
  const isCurrentEntity = currentArg ? isEntityArg(currentArg) : false;
  const isCurrentList = currentArg ? isListArg(currentArg) : false;

  const verbSuggestions: Verb[] = (() => {
    if (selectedVerb || input.length === 0) return [];
    const query = input.toLowerCase();
    const prefix: Verb[] = [];
    const substring: Verb[] = [];
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

  const typepathSuggestions =
    selectedVerb && isCurrentTypepath && currentToken.startsWith('/')
      ? typepaths
          .filter((p) =>
            p.toLowerCase().startsWith(currentToken.toLowerCase()),
          )
          .slice(0, 8)
      : [];

  const targetSuggestions =
    selectedVerb && isCurrentEntity && targets.length > 0
      ? targets
          .filter(
            (t) =>
              currentToken.length === 0 ||
              t.name.toLowerCase().includes(currentToken.toLowerCase()),
          )
          .slice(0, 8)
      : [];

  const listSuggestions =
    selectedVerb && isCurrentList && currentArg?.options
      ? currentArg.options.filter(
          (o) =>
            currentToken.length === 0 ||
            o.toLowerCase().startsWith(currentToken.toLowerCase()),
        )
      : [];

  const allSuggestions = isCurrentTypepath
    ? typepathSuggestions
    : isCurrentList
      ? listSuggestions
      : selectedVerb
        ? targetSuggestions
        : verbSuggestions;

  return {
    verbSuggestions,
    typepathSuggestions,
    targetSuggestions,
    listSuggestions,
    allSuggestions,
  };
}

export function CommandBar() {
  const verbs = useAtomValue(adminVerbsAtom);
  const focusSignal = useAtomValue(focusCommandBarAtom);
  const clearSignal = useAtomValue(clearCommandBarAtom);
  const [input, setInput] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [selectedVerb, setSelectedVerb] = useState<Verb | null>(null);
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

  const argPortion = selectedVerb
    ? input.slice(toKebab(selectedVerb.name).length + 1)
    : '';
  const parsedArgs = selectedVerb ? parseArgs(argPortion) : [];
  const currentToken =
    parsedArgs.length > filledArgs.length ? parsedArgs[filledArgs.length] : '';
  const inQuotedArg = selectedVerb ? isInQuotedArg(argPortion) : false;

  const {
    verbSuggestions,
    typepathSuggestions,
    targetSuggestions,
    listSuggestions,
    allSuggestions,
  } = useSuggestions(input, selectedVerb, currentArg, currentToken);
  const hasSuggestions = allSuggestions.length > 0;
  const isCurrentArgTypepath = currentArg ? isTypepathArg(currentArg) : false;
  const isCurrentArgList = currentArg ? isListArg(currentArg) : false;

  useEffect(() => {
    Byond.sendMessage('verbs/request_verbs');
  }, []);

  useEffect(() => {
    if (focusSignal > 0) {
      inputRef.current?.focus();
    }
  }, [focusSignal]);

  useEffect(() => {
    if (clearSignal > 0) {
      if (mode !== 'Command') {
        enterChatMode(mode);
      } else {
        resetState();
      }
    }
  }, [clearSignal]);

  const resetState = () => {
    setInput('');
    setSelectedVerb(null);
    setFilledArgs([]);
    setSelectedIndex(0);
    setLastTypepathRequest('');
  };

  const enterChatMode = (chatMode: Mode) => {
    const verb = verbs.find((v) => v.name === chatMode);
    if (!verb) return;
    setSelectedVerb(verb);
    setFilledArgs([]);
    setSelectedIndex(0);
    setLastTypepathRequest('');
    setInput(serializeInput(verb, [], suffixForArg(verb.args[0])));
  };

  const cycleMode = () => {
    const nextIndex = (MODES.indexOf(mode) + 1) % MODES.length;
    const nextMode = MODES[nextIndex];
    setMode(nextMode);
    if (nextMode === 'Command') {
      resetState();
    } else {
      enterChatMode(nextMode);
    }
    inputRef.current?.focus();
  };

  const selectVerb = (verb: Verb) => {
    setSelectedVerb(verb);
    setFilledArgs([]);
    setSelectedIndex(0);
    setLastTypepathRequest('');
    setInput(serializeInput(verb, [], suffixForArg(verb.args[0])));
    const firstArg = verb.args[0];
    if (firstArg && isEntityArg(firstArg)) {
      Byond.sendMessage('verbs/request_targets', { verb_type: verb.type });
    }
  };

  const fillArg = (value: string) => {
    if (!selectedVerb) return;
    const newFilled = [...filledArgs, value];
    setFilledArgs(newFilled);
    setSelectedIndex(0);
    const nextArg = verbArgs[newFilled.length];
    setInput(serializeInput(selectedVerb, newFilled, suffixForArg(nextArg)));
  };

  const selectTypepath = (path: string) => {
    Byond.sendMessage('verbs/request_typepaths', { parent: path });
    setLastTypepathRequest(`${path}/`);
    if (!selectedVerb) return;
    const prefix = filledArgs.length > 0 ? `${filledArgs.join(' ')} ` : '';
    setInput(`${toKebab(selectedVerb.name)} ${prefix}${path}/`);
    setSelectedIndex(0);
  };

  const invokeVerb = () => {
    if (!selectedVerb) return;
    const argValues: Record<string, string> = {};
    for (let i = 0; i < verbArgs.length && i < parsedArgs.length; i++) {
      let val = parsedArgs[i];
      if (isTypepathArg(verbArgs[i])) {
        val = val.replace(/\/+$/, '');
      }
      argValues[verbArgs[i].name] = val;
    }
    Byond.sendMessage('verbs/invoke', {
      verb_type: selectedVerb.type,
      args: argValues,
    });
    if (mode !== 'Command') {
      enterChatMode(mode);
    } else {
      resetState();
    }
  };

  const selectCurrentSuggestion = (): boolean => {
    if (!selectedVerb && verbSuggestions.length > 0) {
      selectVerb(verbSuggestions[selectedIndex]);
      return true;
    }
    if (isCurrentArgTypepath && typepathSuggestions.length > 0) {
      selectTypepath(typepathSuggestions[selectedIndex]);
      return true;
    }
    if (isCurrentArgList && listSuggestions.length > 0) {
      fillArg(listSuggestions[selectedIndex]);
      return true;
    }
    if (selectedVerb && targetSuggestions.length > 0) {
      fillArg(
        (targetSuggestions[selectedIndex] as { name: string; ref: string }).ref,
      );
      return true;
    }
    return false;
  };

  const blurToMap = () => {
    inputRef.current?.blur();
    Byond.winset('map', { focus: true });
  };

  const dismissOrReset = () => {
    mode !== 'Command' ? enterChatMode(mode) : resetState();
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    switch (e.key) {
      case 'ArrowDown':
        if (!hasSuggestions) return;
        e.preventDefault();
        setSelectedIndex((i) => Math.min(i + 1, allSuggestions.length - 1));
        return;
      case 'ArrowUp':
        if (!hasSuggestions) return;
        e.preventDefault();
        setSelectedIndex((i) => Math.max(i - 1, 0));
        return;
      case ' ':
        if (inQuotedArg) return;
        e.preventDefault();
        if (!selectedVerb && verbSuggestions.length > 0) {
          selectVerb(verbSuggestions[selectedIndex]);
        }
        return;
      case 'Tab':
        e.preventDefault();
        if (!hasSuggestions || !selectCurrentSuggestion()) {
          blurToMap();
        }
        return;
      case 'Enter': {
        e.preventDefault();
        if (!selectedVerb && verbSuggestions.length > 0) {
          const verb = verbSuggestions[selectedIndex];
          if (verb.args.length === 0) {
            Byond.sendMessage('verbs/invoke', {
              verb_type: verb.type,
              args: {},
            });
            dismissOrReset();
          } else {
            selectVerb(verb);
          }
        } else if (selectedVerb) {
          invokeVerb();
        }
        return;
      }
      case 'Escape':
        e.preventDefault();
        dismissOrReset();
        return;
    }
  };

  const handleChange = (value: string) => {
    if (!selectedVerb) {
      value = value.replaceAll(' ', '');
    }

    if (selectedVerb) {
      const verbPrefix = `${toKebab(selectedVerb.name)} `;
      if (!value.startsWith(verbPrefix)) {
        setSelectedVerb(null);
        setFilledArgs([]);
        value = value.split(' ')[0] || '';
      }
    }

    setInput(value);
    setSelectedIndex(0);

    if (selectedVerb && currentArg && isTextArg(currentArg)) {
      const afterVerb = value.slice(toKebab(selectedVerb.name).length + 1);
      const parsed = parseArgs(afterVerb);
      if (parsed.length > filledArgs.length && !isInQuotedArg(afterVerb)) {
        const newFilled = [...filledArgs, parsed[filledArgs.length]];
        setFilledArgs(newFilled);
        const nextArg = verbArgs[newFilled.length];
        if (nextArg) {
          setInput(
            serializeInput(selectedVerb, newFilled, suffixForArg(nextArg)),
          );
        }
      }
    }

    if (selectedVerb && isCurrentArgTypepath) {
      const token = value.slice(
        toKebab(selectedVerb.name).length +
          1 +
          filledArgs.join(' ').length +
          (filledArgs.length > 0 ? 1 : 0),
      );
      const lastSlash = token.lastIndexOf('/');
      if (lastSlash >= 0) {
        const parentPrefix = token.slice(0, lastSlash + 1);
        if (parentPrefix !== lastTypepathRequest) {
          setLastTypepathRequest(parentPrefix);
          Byond.sendMessage('verbs/request_typepaths', {
            parent: token.slice(0, lastSlash) || '/datum',
          });
        }
      }
    }
  };

  const placeholder = selectedVerb
    ? `${toKebab(selectedVerb.name)} ${verbArgs.map((a) => `<${a.name}>`).join(' ')}`
    : '';

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
                ? typepathSuggestions.map((path, i) => (
                    <div
                      key={path}
                      className={`CommandBar__suggestion${i === selectedIndex ? ' CommandBar__suggestion--selected' : ''}`}
                      onMouseEnter={() => setSelectedIndex(i)}
                      onClick={() => selectTypepath(path)}
                    >
                      <span className="CommandBar__typepath">{path}</span>
                    </div>
                  ))
                : isCurrentArgList
                  ? listSuggestions.map((option, i) => (
                      <div
                        key={option}
                        className={`CommandBar__suggestion${i === selectedIndex ? ' CommandBar__suggestion--selected' : ''}`}
                        onMouseEnter={() => setSelectedIndex(i)}
                        onClick={() => fillArg(option)}
                      >
                        {option}
                      </div>
                    ))
                  : targetSuggestions.map((target, i) => (
                      <div
                        key={target.ref}
                        className={`CommandBar__suggestion${i === selectedIndex ? ' CommandBar__suggestion--selected' : ''}`}
                        onMouseEnter={() => setSelectedIndex(i)}
                        onClick={() => fillArg(target.ref)}
                      >
                        <span className="CommandBar__target">
                          {target.name}
                        </span>
                      </div>
                    ))}
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
        onMouseDown={(e) => e.preventDefault()}
        type="button"
        style={{ color: MODE_COLORS[mode] }}
      >
        {mode}
      </button>
    </div>
  );
}
