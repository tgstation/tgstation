import { storage } from 'common/storage';
import {
  filterTypepaths,
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
  hotkeysAtom,
  initializeCommandBarAtom,
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

const MODES = ['Command', 'Say', 'Me', 'OOC'] as const;
type Mode = (typeof MODES)[number];

const MODE_COLORS: Record<Mode, string> = {
  Command: '#888',
  Say: '#a3d977',

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
      ? filterTypepaths(typepaths, currentToken, 8)
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
  const hotkeys = useAtomValue(hotkeysAtom);
  const initializeSignal = useAtomValue(initializeCommandBarAtom);
  const [input, setInput] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [selectedVerb, setSelectedVerb] = useState<Verb | null>(null);
  const [filledArgs, setFilledArgs] = useState<string[]>([]);
  const [mode, setMode] = useState<Mode>('Say');
  const inputRef = useRef<HTMLInputElement>(null);
  const historyRef = useRef<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);

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
    const loadStoredValues = async () => {
      const storedMode = await storage.get('tgui-commandbar-mode');
      if (storedMode !== undefined) setMode(storedMode);
    };
    loadStoredValues();
  }, []);

  useEffect(() => {
    Byond.sendMessage('verbs/request_verbs');
  }, []);

  useEffect(() => {
    if (mode !== 'Command') {
      enterChatMode(mode);
    }
  }, [initializeSignal]);

  useEffect(() => {
    if (focusSignal > 0) {
      inputRef.current?.focus();
    }
  }, [focusSignal]);

  useEffect(() => {
    if (!hotkeys) {
      inputRef.current?.focus();
    }
  }, [hotkeys]);

  useEffect(() => {
    if (clearSignal > 0) {
      resetState();
    }
  }, [clearSignal]);

  const pushHistory = (entry: string) => {
    const history = historyRef.current;
    if (entry && history[0] !== entry) {
      history.unshift(entry);
      if (history.length > 10) history.pop();
    }
    setHistoryIndex(-1);
  };

  const restoreFromHistory = (entry: string) => {
    const firstSpace = entry.indexOf(' ');
    const verbName = firstSpace >= 0 ? entry.slice(0, firstSpace) : entry;
    const verb = verbs.find((v) => toKebab(v.name) === verbName);
    if (verb) {
      setSelectedVerb(verb);
      const argPart = entry.slice(toKebab(verb.name).length + 1);
      setFilledArgs(parseArgs(argPart));
    } else {
      setSelectedVerb(null);
      setFilledArgs([]);
    }
    setSelectedIndex(0);
    setInput(entry);
  };

  const resetState = () => {
    setInput('');
    setSelectedVerb(null);
    setFilledArgs([]);
    setSelectedIndex(0);
  };

  const enterChatMode = (chatMode: Mode) => {
    const verb = verbs.find((v) => v.name === chatMode);
    if (!verb) return;
    setSelectedVerb(verb);
    setFilledArgs([]);
    setSelectedIndex(0);
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
    storage.set('tgui-commandbar-mode', nextMode);
    inputRef.current?.focus();
  };

  const selectVerb = (verb: Verb) => {
    setSelectedVerb(verb);
    setFilledArgs([]);
    setSelectedIndex(0);
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
    pushHistory(input);
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

  const heldKeysRef = useRef<Set<string>>(new Set());

  const forwardKeyDown = (key: string) => {
    if (heldKeysRef.current.has(key)) return;
    heldKeysRef.current.add(key);
    Byond.command(`KeyDown "${key}" 0 0 0 0`);
  };

  const forwardKeyUp = (key: string) => {
    if (!heldKeysRef.current.has(key)) return;
    heldKeysRef.current.delete(key);
    Byond.command(`KeyUp "${key}" 0 0 0 0`);
  };

  const blurToMap = () => {
    if (!hotkeys) return;
    inputRef.current?.blur();
    Byond.winset('map', { focus: true });
  };

  const dismissOrReset = () => {
    mode !== 'Command' ? enterChatMode(mode) : resetState();
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    switch (e.key) {
      case 'ArrowDown':
        if (e.ctrlKey) {
          e.preventDefault();
          if (historyIndex > 0) {
            const newIndex = historyIndex - 1;
            setHistoryIndex(newIndex);
            restoreFromHistory(historyRef.current[newIndex]);
          } else if (historyIndex === 0) {
            setHistoryIndex(-1);
            resetState();
          }
        } else if (hasSuggestions) {
          e.preventDefault();
          setSelectedIndex((i) => Math.min(i + 1, allSuggestions.length - 1));
        } else {
          e.preventDefault();
          forwardKeyDown('South');
        }
        return;
      case 'ArrowUp':
        if (e.ctrlKey) {
          e.preventDefault();
          if (historyIndex < historyRef.current.length - 1) {
            const newIndex = historyIndex + 1;
            setHistoryIndex(newIndex);
            restoreFromHistory(historyRef.current[newIndex]);
          }
        } else if (hasSuggestions) {
          e.preventDefault();
          setSelectedIndex((i) => Math.max(i - 1, 0));
        } else {
          e.preventDefault();
          forwardKeyDown('North');
        }
        return;
      case 'ArrowLeft':
        if (!e.ctrlKey) {
          e.preventDefault();
          forwardKeyDown('West');
        }
        return;
      case 'ArrowRight':
        if (!e.ctrlKey) {
          e.preventDefault();
          forwardKeyDown('East');
        }
        return;
      case ' ':
        if (inQuotedArg) return;
        if (selectedVerb && hasSuggestions) {
          e.preventDefault();
          selectCurrentSuggestion();
          return;
        }
        if (!selectedVerb && verbSuggestions.length > 0) {
          e.preventDefault();
          if (selectedIndex > 0) {
            selectVerb(verbSuggestions[selectedIndex]);
            return;
          }
          const query = input.toLowerCase();
          const prefixMatches = verbSuggestions.filter((v) =>
            toKebab(v.name).toLowerCase().startsWith(query),
          );
          if (prefixMatches.length === 1) {
            selectVerb(prefixMatches[0]);
            return;
          }
          if (prefixMatches.length > 1) {
            const kebabs = prefixMatches.map((v) =>
              toKebab(v.name).toLowerCase(),
            );
            let common = kebabs[0];
            for (const k of kebabs) {
              while (!k.startsWith(common)) common = common.slice(0, -1);
            }
            if (common.length > input.length) {
              setInput(common);
              setSelectedIndex(0);
            }
          }
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
            pushHistory(input);
            Byond.sendMessage('verbs/invoke', {
              verb_type: verb.type,
              args: {},
            });
            dismissOrReset();
          } else {
            selectVerb(verb);
          }
        } else if (selectedVerb && hasSuggestions && !isCurrentArgTypepath) {
          selectCurrentSuggestion();
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

  const ARROW_TO_BYOND: Record<string, string> = {
    ArrowUp: 'North',
    ArrowDown: 'South',
    ArrowLeft: 'West',
    ArrowRight: 'East',
  };

  const handleKeyUp = (e: KeyboardEvent<HTMLInputElement>) => {
    const byondKey = ARROW_TO_BYOND[e.key];
    if (byondKey) {
      forwardKeyUp(byondKey);
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
          onChange={(e) => {
            setHistoryIndex(-1);
            handleChange(e.target.value);
          }}
          onKeyDown={handleKeyDown}
          onKeyUp={handleKeyUp}
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
