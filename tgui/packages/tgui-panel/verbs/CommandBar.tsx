import { useAtomValue } from 'jotai';
import { type KeyboardEvent, useEffect, useRef, useState } from 'react';
import {
  type AdminVerb,
  adminTargetsAtom,
  adminVerbsAtom,
  typepathsAtom,
  type VerbArg,
} from './atoms';

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

export function CommandBar() {
  const verbs = useAtomValue(adminVerbsAtom);
  const targets = useAtomValue(adminTargetsAtom);
  const typepaths = useAtomValue(typepathsAtom);
  const [input, setInput] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [selectedVerb, setSelectedVerb] = useState<AdminVerb | null>(null);
  const [filledArgs, setFilledArgs] = useState<string[]>([]);
  const [lastTypepathRequest, setLastTypepathRequest] = useState('');
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

  // Current token being typed
  const currentToken = selectedVerb
    ? input.slice(
        toKebab(selectedVerb.name).length +
          1 +
          filledArgs.join(' ').length +
          (filledArgs.length > 0 ? 1 : 0),
      )
    : input;

  // Verb suggestions
  const verbSuggestions: AdminVerb[] =
    !selectedVerb && input.length > 0
      ? verbs
          .filter(
            (v) =>
              v.name &&
              toKebab(v.name).toLowerCase().startsWith(input.toLowerCase()),
          )
          .slice(0, 8)
      : [];

  // Typepath suggestions
  const typepathSuggestions =
    selectedVerb && isCurrentArgTypepath
      ? typepaths
          .filter(
            (p) =>
              currentToken.length === 0 ||
              p.toLowerCase().startsWith(currentToken.toLowerCase()),
          )
          .slice(0, 12)
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
    } else if (e.key === ' ' && !selectedVerb) {
      e.preventDefault();
      if (verbSuggestions.length > 0) {
        selectVerb(verbSuggestions[selectedIndex]);
      }
    } else if (e.key === 'Tab') {
      e.preventDefault();
      if (!selectedVerb && verbSuggestions.length > 0) {
        // Autocomplete the verb name into the input without executing
        setInput(toKebab(verbSuggestions[selectedIndex].name));
        setSelectedIndex(0);
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
        selectVerb(verbSuggestions[selectedIndex]);
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
      resetInput();
    }
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
        value = value.split(' ')[0] || '';
      }
    }

    setInput(value);
    setSelectedIndex(0);

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
      setInput(kebab + ' ');
      const firstArg = verb.args[0];
      if (isTypepathArg(firstArg)) {
        Byond.sendMessage('verbs/request_typepaths', { parent: '/datum' });
        setLastTypepathRequest('/');
      } else {
        Byond.sendMessage('verbs/request_targets', { verb_type: verb.type });
      }
    } else {
      Byond.sendMessage('verbs/invoke', {
        verb_type: verb.type,
        args: {},
      });
      resetInput();
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
    if (newFilledArgs.length < verbArgs.length) {
      setInput(kebab + ' ' + newFilledArgs.join(' ') + ' ');
    } else {
      setInput(kebab + ' ' + newFilledArgs.join(' '));
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
    resetInput();
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
    <div style={{ position: 'relative' }}>
      {hasSuggestions && (
        <div
          style={{
            position: 'absolute',
            bottom: '100%',
            left: 0,
            right: 0,
            background: 'rgba(30, 30, 40, 0.95)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            borderBottom: 'none',
            maxHeight: '200px',
            overflowY: 'auto',
          }}
        >
          {!selectedVerb
            ? (verbSuggestions as AdminVerb[]).map((verb, i) => (
                <div
                  key={verb.type}
                  style={{
                    padding: '4px 8px',
                    cursor: 'pointer',
                    background:
                      i === selectedIndex
                        ? 'rgba(255, 255, 255, 0.1)'
                        : 'transparent',
                    fontSize: '12px',
                    fontFamily: 'monospace',
                  }}
                  onMouseEnter={() => setSelectedIndex(i)}
                  onClick={() => selectVerb(verb)}
                >
                  <span style={{ color: '#6cb6ff' }}>{toKebab(verb.name)}</span>
                  {verb.args.length > 0 && (
                    <span style={{ color: '#666', marginLeft: '8px' }}>
                      {verb.args.map((a) => `<${a.name}>`).join(' ')}
                    </span>
                  )}
                </div>
              ))
            : isCurrentArgTypepath
              ? (typepathSuggestions as string[]).map((path, i) => (
                  <div
                    key={path}
                    style={{
                      padding: '4px 8px',
                      cursor: 'pointer',
                      background:
                        i === selectedIndex
                          ? 'rgba(255, 255, 255, 0.1)'
                          : 'transparent',
                      fontSize: '12px',
                      fontFamily: 'monospace',
                    }}
                    onMouseEnter={() => setSelectedIndex(i)}
                    onClick={() => selectTypepath(path)}
                  >
                    <span style={{ color: '#d4a' }}>{path}</span>
                  </div>
                ))
              : (targetSuggestions as { name: string; ref: string }[]).map(
                  (target, i) => (
                    <div
                      key={target.ref}
                      style={{
                        padding: '4px 8px',
                        cursor: 'pointer',
                        background:
                          i === selectedIndex
                            ? 'rgba(255, 255, 255, 0.1)'
                            : 'transparent',
                        fontSize: '12px',
                        fontFamily: 'monospace',
                      }}
                      onMouseEnter={() => setSelectedIndex(i)}
                      onClick={() => selectTarget(target)}
                    >
                      <span style={{ color: '#a3d977' }}>{target.name}</span>
                    </div>
                  ),
                )}
        </div>
      )}
      <input
        ref={inputRef}
        type="text"
        value={input}
        placeholder={placeholder}
        onChange={(e) => handleChange(e.target.value)}
        onKeyDown={handleKeyDown}
        style={{
          width: '100%',
          boxSizing: 'border-box',
          padding: '6px 8px',
          background: 'rgba(0, 0, 0, 0.4)',
          border: '1px solid rgba(255, 255, 255, 0.1)',
          color: '#fff',
          fontSize: '12px',
          fontFamily: 'monospace',
          outline: 'none',
        }}
      />
    </div>
  );
}
