import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type VerbArgument = {
  name: string;
  arg_type: number;
  type_path: string;
  source: string | null;
};

type Verb = {
  type: string;
  name: string;
  description: string;
  category: string;
  arguments: VerbArgument[];
};

type TargetEntry = {
  name: string;
  ref: string;
  ckey?: string;
  job?: string;
};

type TypepathData = {
  parent: string;
  paths: string[];
};

type Data = {
  verbs: Verb[];
  categories: string[];
  targets: TargetEntry[];
  typepaths?: TypepathData;
};

const ARG_TEXT = 1 << 0;
const ARG_NUM = 1 << 1;
const ARG_MESSAGE = 1 << 2;
const ARG_SOUND = 1 << 3;
const ARG_ICON = 1 << 4;
const ARG_MOB = 1 << 5;
const ARG_OBJ = 1 << 6;
const ARG_TURF = 1 << 7;
const ARG_AREA = 1 << 8;
const ARG_TYPEPATH = 1 << 11;

const ARG_ENTITY =
  ARG_MOB | ARG_OBJ | ARG_TURF | ARG_AREA | (1 << 9) | (1 << 10);
const ARG_PRIMITIVE =
  ARG_TEXT | ARG_NUM | ARG_MESSAGE | ARG_SOUND | ARG_ICON | ARG_TYPEPATH;

function isPickableEntityArg(arg: VerbArgument): boolean {
  return (
    (arg.arg_type & ARG_ENTITY) !== 0 &&
    (arg.source === 'world' || arg.source === 'view')
  );
}

function isPrimitiveArg(arg: VerbArgument): boolean {
  return (arg.arg_type & ARG_PRIMITIVE) !== 0;
}

export function AdminVerbPanel() {
  const { act, data } = useBackend<Data>();
  const { verbs = [], categories = [], targets = [] } = data;

  const [searchText, setSearchText] = useState('');
  const [selectedVerb, setSelectedVerb] = useState<Verb | null>(null);
  const [argValues, setArgValues] = useState<Record<string, unknown>>({});
  const [selectedTarget, setSelectedTarget] = useState<string | null>(null);
  const [targetSearch, setTargetSearch] = useState('');

  const filteredVerbs = searchText
    ? verbs.filter((verb) =>
        verb.name.toLowerCase().includes(searchText.toLowerCase()),
      )
    : verbs;

  const filteredTargets = targets.filter((t) =>
    targetSearch
      ? t.name.toLowerCase().includes(targetSearch.toLowerCase()) ||
        (t.ckey?.toLowerCase().includes(targetSearch.toLowerCase()) ?? false)
      : true,
  );

  const selectVerb = (verb: Verb) => {
    setSelectedVerb(verb);
    setArgValues({});
    setSelectedTarget(null);
    act('select_verb', { verb_type: verb.type });
    if (verb.arguments.some((a) => a.arg_type & ARG_TYPEPATH)) {
      act('request_typepaths', { parent: '/datum' });
    }
  };

  const entityArg = selectedVerb?.arguments.find(isPickableEntityArg) ?? null;
  const isMobList = entityArg ? (entityArg.arg_type & ARG_MOB) !== 0 : false;

  const invokeVerb = () => {
    if (!selectedVerb) return;

    const finalArgs = { ...argValues };

    if (selectedTarget && entityArg && !finalArgs[entityArg.name]) {
      finalArgs[entityArg.name] = selectedTarget;
    }

    act('invoke', {
      verb_type: selectedVerb.type,
      args: finalArgs,
    });
  };

  const updateArg = (name: string, value: unknown) => {
    setArgValues((prev) => ({ ...prev, [name]: value }));
  };

  const primitiveArgs = selectedVerb?.arguments.filter(isPrimitiveArg) ?? [];

  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  const matchingCategories = searchText
    ? categories.filter((cat) => filteredVerbs.some((v) => v.category === cat))
    : categories;

  const activeCategory = selectedCategory || '';

  const visibleVerbs = searchText
    ? filteredVerbs.filter(
        (v) => !activeCategory || v.category === activeCategory,
      )
    : verbs.filter((v) => v.category === (activeCategory || categories[0]));

  return (
    <Window title="Admin Verb Panel" width={800} height={520} theme="admin">
      <Window.Content>
        <Stack fill>
          {/* Far left: category list */}
          <Stack.Item basis="140px">
            <Section fill scrollable title="Categories">
              {matchingCategories.map((cat) => (
                <Button
                  key={cat}
                  fluid
                  color={cat === activeCategory ? 'good' : 'transparent'}
                  textAlign="left"
                  onClick={() => {
                    setSelectedCategory(cat);
                    setSelectedVerb(null);
                    setSelectedTarget(null);
                  }}
                >
                  {cat}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Divider />
          {/* Verb list */}
          <Stack.Item basis="180px">
            <Stack fill vertical>
              <Stack.Item>
                <Input
                  fluid
                  placeholder="Search..."
                  value={searchText}
                  onChange={(val: string) => {
                    setSearchText(val);
                    setSelectedCategory(null);
                  }}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Section fill scrollable>
                  {visibleVerbs.map((verb) => (
                    <Button
                      key={verb.type}
                      fluid
                      color={
                        selectedVerb?.type === verb.type
                          ? 'good'
                          : 'transparent'
                      }
                      textAlign="left"
                      onClick={() => selectVerb(verb)}
                    >
                      {verb.name}
                    </Button>
                  ))}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Divider />
          {/* Center + Right */}
          <Stack.Item grow>
            <Stack fill vertical>
              {/* Target picker */}
              {entityArg && (
                <Stack.Item basis="45%">
                  <Section
                    fill
                    scrollable
                    title="Target"
                    buttons={
                      <Input
                        placeholder="Filter..."
                        value={targetSearch}
                        onChange={setTargetSearch}
                        width="120px"
                      />
                    }
                  >
                    <Table>
                      <Table.Row header>
                        <Table.Cell>Name</Table.Cell>
                        {isMobList && <Table.Cell>Job</Table.Cell>}
                        {isMobList && <Table.Cell>CKey</Table.Cell>}
                      </Table.Row>
                      {filteredTargets.map((t) => (
                        <Table.Row
                          key={t.ref}
                          className={
                            selectedTarget === t.ref ? 'candystripe' : undefined
                          }
                          onClick={() => setSelectedTarget(t.ref)}
                        >
                          <Table.Cell>
                            <Box
                              bold={selectedTarget === t.ref}
                              color={
                                selectedTarget === t.ref ? 'good' : undefined
                              }
                            >
                              {t.name}
                            </Box>
                          </Table.Cell>
                          {isMobList && <Table.Cell>{t.job}</Table.Cell>}
                          {isMobList && (
                            <Table.Cell color="label">{t.ckey}</Table.Cell>
                          )}
                        </Table.Row>
                      ))}
                    </Table>
                  </Section>
                </Stack.Item>
              )}
              <Stack.Item grow>
                {selectedVerb ? (
                  <Section
                    fill
                    scrollable={false}
                    title={selectedVerb.name}
                    buttons={
                      <Button icon="play" color="good" onClick={invokeVerb}>
                        Invoke
                      </Button>
                    }
                  >
                    <Stack vertical fill>
                      {selectedVerb.description && (
                        <Stack.Item color="label" mb={1}>
                          {selectedVerb.description}
                        </Stack.Item>
                      )}
                      {primitiveArgs.map((arg) => (
                        <Stack.Item
                          key={arg.name}
                          grow={
                            (arg.arg_type & ARG_TYPEPATH) !== 0 ? 1 : undefined
                          }
                        >
                          <ArgInput
                            arg={arg}
                            value={argValues[arg.name]}
                            onChange={(val) => updateArg(arg.name, val)}
                          />
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Section>
                ) : (
                  <Section fill>
                    <Box color="label">Select a verb from the list.</Box>
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

type ArgInputProps = {
  arg: VerbArgument;
  value: unknown;
  onChange: (value: unknown) => void;
};

function ArgInput(props: ArgInputProps) {
  const { arg, value, onChange } = props;

  if (arg.arg_type & ARG_NUM) {
    return (
      <Stack align="center">
        <Stack.Item basis="100px">{arg.name}</Stack.Item>
        <Stack.Item>
          <NumberInput
            value={(value as number) || 0}
            onChange={onChange}
            width="80px"
          />
        </Stack.Item>
      </Stack>
    );
  }
  if (arg.arg_type & ARG_MESSAGE) {
    return (
      <Stack vertical>
        <Stack.Item>{arg.name}</Stack.Item>
        <Stack.Item>
          <TextArea
            fluid
            height="80px"
            value={(value as string) || ''}
            onChange={onChange}
          />
        </Stack.Item>
      </Stack>
    );
  }
  if (arg.arg_type & ARG_TYPEPATH) {
    return (
      <TypepathInput arg={arg} value={value as string} onChange={onChange} />
    );
  }
  if (arg.arg_type & ARG_TEXT) {
    return (
      <Stack align="center">
        <Stack.Item basis="100px">{arg.name}</Stack.Item>
        <Stack.Item grow>
          <Input
            fluid
            value={(value as string) || ''}
            onChange={onChange}
            placeholder={arg.name}
          />
        </Stack.Item>
      </Stack>
    );
  }
  if (arg.arg_type & ARG_SOUND) {
    return (
      <Stack align="center">
        <Stack.Item basis="100px">{arg.name}</Stack.Item>
        <Stack.Item color="label">Sound input not yet supported</Stack.Item>
      </Stack>
    );
  }
  return (
    <Stack align="center">
      <Stack.Item basis="100px">{arg.name}</Stack.Item>
      <Stack.Item color="label">Unknown arg type</Stack.Item>
    </Stack>
  );
}

type TypepathInputProps = {
  arg: VerbArgument;
  value: string | undefined;
  onChange: (value: unknown) => void;
};

function TypepathInput(props: TypepathInputProps) {
  const { arg, value, onChange } = props;
  const { act, data } = useBackend<Data>();
  const [lastRequested, setLastRequested] = useState('');
  const typepaths = data.typepaths;
  const children = typepaths?.paths || [];
  const inputValue = (value as string) || '';

  const suggestions = inputValue
    ? children.filter((p) =>
        p.toLowerCase().startsWith(inputValue.toLowerCase()),
      )
    : children;

  const handleChange = (val: string) => {
    onChange(val);
    if (val.endsWith('/')) {
      const parent = val.slice(0, -1) || '/datum';
      if (parent !== lastRequested) {
        setLastRequested(parent);
        act('request_typepaths', { parent });
      }
    }
  };

  const selectPath = (path: string) => {
    onChange(path + '/');
    if (path !== lastRequested) {
      setLastRequested(path);
      act('request_typepaths', { parent: path });
    }
  };

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack align="center">
          <Stack.Item basis="100px">{arg.name}</Stack.Item>
          <Stack.Item grow>
            <Input
              fluid
              value={inputValue}
              onChange={handleChange}
              placeholder="/datum/..."
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {suggestions.length > 0 && (
        <Stack.Item grow>
          <Section fill scrollable>
            {suggestions.map((path) => (
              <Button
                key={path}
                fluid
                color="transparent"
                textAlign="left"
                onClick={() => selectPath(path)}
              >
                {path}
              </Button>
            ))}
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
}
