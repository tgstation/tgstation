import { useAtomValue } from 'jotai';
import { type KeyboardEvent, useRef, useState } from 'react';
import { type AdminVerb, adminTargetsAtom, adminVerbsAtom } from './atoms';

function toKebab(name: string): string {
  return name.replaceAll(' ', '-');
}

export function AdminCommandBar() {
  const verbs = useAtomValue(adminVerbsAtom);
  const targets = useAtomValue(adminTargetsAtom);
  const [input, setInput] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [selectedVerb, setSelectedVerb] = useState<AdminVerb | null>(null);
  const [filledArgs, setFilledArgs] = useState<string[]>([]);
  const inputRef = useRef<HTMLInputElement>(null);

  // Current token being typed (after verb + filled args)
  const currentToken = selectedVerb
    ? input.slice(
        toKebab(selectedVerb.name).length +
          1 +
          filledArgs.join(' ').length +
          (filledArgs.length > 0 ? 1 : 0),
      )
    : input;

  // Verb suggestions — when no verb is selected
  const verbSuggestions: AdminVerb[] =
    !selectedVerb && input.length > 0
      ? verbs
          .filter((v) =>
            toKebab(v.name).toLowerCase().startsWith(input.toLowerCase()),
          )
          .slice(0, 8)
      : [];

  // Target suggestions — when verb selected and typing an entity arg
  const currentArgIndex = selectedVerb ? filledArgs.length : -1;
  const hasMoreArgs =
    selectedVerb && currentArgIndex < selectedVerb.args.length;
  const targetSuggestions =
    selectedVerb && hasMoreArgs && targets.length > 0
      ? targets
          .filter(
            (t) =>
              currentToken.length === 0 ||
              t.name.toLowerCase().includes(currentToken.toLowerCase()),
          )
          .slice(0, 8)
      : [];

  const suggestions = selectedVerb ? targetSuggestions : verbSuggestions;
  const hasSuggestions = suggestions.length > 0;

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'ArrowDown' && hasSuggestions) {
      e.preventDefault();
      setSelectedIndex((i) => Math.min(i + 1, suggestions.length - 1));
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
        selectVerb(verbSuggestions[selectedIndex]);
      } else if (selectedVerb && targetSuggestions.length > 0) {
        selectTarget(targetSuggestions[selectedIndex]);
      }
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (!selectedVerb && verbSuggestions.length > 0) {
        selectVerb(verbSuggestions[selectedIndex]);
      } else if (selectedVerb && targetSuggestions.length > 0) {
        selectTarget(targetSuggestions[selectedIndex]);
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

    // Detect backspace into verb name — deselect the verb
    if (selectedVerb) {
      const verbPrefix = toKebab(selectedVerb.name) + ' ';
      if (!value.startsWith(verbPrefix)) {
        // User backspaced into or past the verb name
        setSelectedVerb(null);
        setFilledArgs([]);
        // Strip everything after the verb token
        value = value.split(' ')[0] || '';
      }
    }

    setInput(value);
    setSelectedIndex(0);
  };

  const selectVerb = (verb: AdminVerb) => {
    setSelectedVerb(verb);
    setFilledArgs([]);
    setSelectedIndex(0);
    const kebab = toKebab(verb.name);
    if (verb.args.length > 0) {
      setInput(kebab + ' ');
      Byond.sendMessage('admin/request_targets', { verb_type: verb.type });
    } else {
      Byond.sendMessage('admin/command', {
        verb_type: verb.type,
        args: {},
      });
      resetInput();
    }
  };

  const selectTarget = (target: { name: string; ref: string }) => {
    if (!selectedVerb) return;

    const newFilledArgs = [...filledArgs, target.ref];
    setFilledArgs(newFilledArgs);
    setSelectedIndex(0);

    const kebab = toKebab(selectedVerb.name);
    if (newFilledArgs.length < selectedVerb.args.length) {
      setInput(kebab + ' ' + newFilledArgs.join(' ') + ' ');
    } else {
      setInput(kebab + ' ' + newFilledArgs.join(' '));
    }
  };

  const invokeVerb = () => {
    if (!selectedVerb) return;
    const argValues: Record<string, string> = {};
    // Use filled args + whatever is currently typed
    const allArgs = [...filledArgs];
    if (currentToken) {
      allArgs.push(currentToken);
    }
    for (let i = 0; i < selectedVerb.args.length && i < allArgs.length; i++) {
      argValues[selectedVerb.args[i]] = allArgs[i];
    }
    Byond.sendMessage('admin/command', {
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
  };

  const placeholder = selectedVerb
    ? `${toKebab(selectedVerb.name)} ${selectedVerb.args.map((a) => `<${a}>`).join(' ')}`
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
            ? verbSuggestions.map((verb, i) => (
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
                  <span style={{ color: '#6cb6ff' }}>
                    {toKebab(verb.name)}
                  </span>
                  {verb.args.length > 0 && (
                    <span style={{ color: '#666', marginLeft: '8px' }}>
                      {verb.args.map((a) => `<${a}>`).join(' ')}
                    </span>
                  )}
                </div>
              ))
            : targetSuggestions.map((target, i) => (
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
              ))}
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
