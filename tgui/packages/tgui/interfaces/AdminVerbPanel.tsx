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

type Data = {
  verbs: Verb[];
  categories: string[];
  targets: TargetEntry[];
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

const ARG_ENTITY = ARG_MOB | ARG_OBJ | ARG_TURF | ARG_AREA | (1 << 9) | (1 << 10);
const ARG_PRIMITIVE = ARG_TEXT | ARG_NUM | ARG_MESSAGE | ARG_SOUND | ARG_ICON;

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

  return (
    <Window title="Admin Verb Panel" width={750} height={520} theme="admin">
      <Window.Content>
        <Stack fill>
          {/* Left: command list with collapsible categories */}
          <Stack.Item basis="200px">
            <Stack fill vertical>
              <Stack.Item>
                <Input
                  fluid
                  placeholder="Search..."
                  value={searchText}
                  onChange={setSearchText}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Section fill scrollable>
                  {searchText
                    ? filteredVerbs.map((verb) => (
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
                      ))
                    : categories.map((cat, index) => (
                        <CategoryGroup
                          key={cat}
                          category={cat}
                          verbs={verbs.filter((v) => v.category === cat)}
                          selectedVerb={selectedVerb}
                          onSelectVerb={selectVerb}
                          defaultOpen={index === 0}
                        />
                      ))}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Divider />
          {/* Center + Right */}
          <Stack.Item grow>
            <Stack fill vertical>
              {/* Target picker — adapts based on entity arg type */}
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
                            selectedTarget === t.ref
                              ? 'candystripe'
                              : undefined
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
              {/* Args + invoke */}
              <Stack.Item grow>
                {selectedVerb ? (
                  <Section
                    fill
                    title={selectedVerb.name}
                    buttons={
                      <Button icon="play" color="good" onClick={invokeVerb}>
                        Invoke
                      </Button>
                    }
                  >
                    <Stack vertical>
                      {selectedVerb.description && (
                        <Stack.Item color="label" mb={1}>
                          {selectedVerb.description}
                        </Stack.Item>
                      )}
                      {primitiveArgs.map((arg) => (
                        <Stack.Item key={arg.name}>
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

type CategoryGroupProps = {
  category: string;
  verbs: Verb[];
  selectedVerb: Verb | null;
  onSelectVerb: (verb: Verb) => void;
  defaultOpen: boolean;
};

function CategoryGroup(props: CategoryGroupProps) {
  const { category, verbs, selectedVerb, onSelectVerb, defaultOpen } = props;
  const [open, setOpen] = useState(defaultOpen);

  return (
    <>
      <Button
        fluid
        icon={open ? 'chevron-down' : 'chevron-right'}
        color="transparent"
        bold
        onClick={() => setOpen(!open)}
      >
        {category}
      </Button>
      {open &&
        verbs.map((verb) => (
          <Button
            key={verb.type}
            fluid
            color={
              selectedVerb?.type === verb.type ? 'good' : 'transparent'
            }
            textAlign="left"
            style={{ paddingLeft: '1.5em' }}
            onClick={() => onSelectVerb(verb)}
          >
            {verb.name}
          </Button>
        ))}
    </>
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
