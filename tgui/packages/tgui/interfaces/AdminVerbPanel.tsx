import { storage } from 'common/storage';
import { useCallback, useEffect, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
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

const STORAGE_FAVOURITES = 'adminverbpanel-favourites';
const STORAGE_USER_CATEGORIES = 'adminverbpanel-user-categories';

type VerbArgument = {
  name: string;
  arg_type: number;
  type_path: string;
  source: string | null;
  options?: string[];
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
const ARG_SOURCE_LIST = 'list';
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

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if (e.key === '`') {
      e.preventDefault();
      Byond.winset(Byond.windowId, { 'is-visible': false });
    }
  }, []);

  useEffect(() => {
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  const [searchText, setSearchText] = useState('');
  const [selectedVerb, setSelectedVerb] = useState<Verb | null>(null);
  const [argValues, setArgValues] = useState<Record<string, unknown>>({});
  const [selectedTarget, setSelectedTarget] = useState<string | null>(null);
  const [targetSearch, setTargetSearch] = useState('');

  const [favourites, setFavourites] = useState<Record<string, string>>({});
  const [userCategories, setUserCategories] = useState<string[]>([]);
  const [newCategoryName, setNewCategoryName] = useState('');

  useEffect(() => {
    const load = async () => {
      const storedFavs = await storage.get(STORAGE_FAVOURITES);
      const storedCats = await storage.get(STORAGE_USER_CATEGORIES);
      if (storedFavs && typeof storedFavs === 'object') {
        setFavourites(storedFavs);
      }
      if (Array.isArray(storedCats)) {
        setUserCategories(storedCats);
      }
    };
    load();
  }, []);

  const persistFavourites = (next: Record<string, string>) => {
    setFavourites(next);
    storage.set(STORAGE_FAVOURITES, next);
  };

  const persistUserCategories = (next: string[]) => {
    setUserCategories(next);
    storage.set(STORAGE_USER_CATEGORIES, next);
  };

  const toggleFavourite = (verbType: string) => {
    const next = { ...favourites };
    if (verbType in next) {
      delete next[verbType];
    } else {
      next[verbType] = '';
    }
    persistFavourites(next);
  };

  const assignVerbCategory = (verbType: string, category: string) => {
    persistFavourites({ ...favourites, [verbType]: category });
  };

  const addUserCategory = () => {
    const name = newCategoryName.trim();
    if (!name || userCategories.includes(name)) return;
    persistUserCategories([...userCategories, name]);
    setNewCategoryName('');
  };

  const removeUserCategory = (name: string) => {
    persistUserCategories(userCategories.filter((c) => c !== name));
    const next = { ...favourites };
    for (const [verbType, cat] of Object.entries(next)) {
      if (cat === name) {
        next[verbType] = '';
      }
    }
    persistFavourites(next);
  };

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

  const hasFavourites = Object.keys(favourites).length > 0;
  const uncategorizedFavs = Object.entries(favourites)
    .filter(([, cat]) => !cat)
    .map(([type]) => type);
  const populatedUserCategories = userCategories.filter((cat) =>
    Object.values(favourites).includes(cat),
  );

  const isUserCategorySelected =
    selectedCategory !== null && userCategories.includes(selectedCategory);
  const isFavouritesSelected = selectedCategory === '\0favourites';

  const matchingCategories = searchText
    ? categories.filter((cat) => filteredVerbs.some((v) => v.category === cat))
    : categories;

  const activeCategory =
    isUserCategorySelected || isFavouritesSelected
      ? ''
      : selectedCategory || '';

  const getVisibleVerbs = (): Verb[] => {
    if (searchText) {
      if (isFavouritesSelected) {
        return filteredVerbs.filter(
          (v) => v.type in favourites && !favourites[v.type],
        );
      }
      if (isUserCategorySelected) {
        return filteredVerbs.filter(
          (v) => favourites[v.type] === selectedCategory,
        );
      }
      return filteredVerbs.filter(
        (v) => !activeCategory || v.category === activeCategory,
      );
    }
    if (isFavouritesSelected) {
      return verbs.filter((v) => v.type in favourites && !favourites[v.type]);
    }
    if (isUserCategorySelected) {
      return verbs.filter((v) => favourites[v.type] === selectedCategory);
    }
    return verbs.filter(
      (v) => v.category === (activeCategory || categories[0]),
    );
  };

  const visibleVerbs = getVisibleVerbs();

  return (
    <Window title="Admin Verb Panel" width={800} height={520} theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="140px">
            <Section fill scrollable title="Categories">
              {userCategories.map((cat) => (
                <Stack key={cat} align="center">
                  <Stack.Item grow>
                    <Button
                      fluid
                      color={selectedCategory === cat ? 'good' : 'transparent'}
                      textAlign="left"
                      onClick={() => {
                        setSelectedCategory(cat);
                        setSelectedVerb(null);
                        setSelectedTarget(null);
                      }}
                    >
                      {cat}
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="times"
                      color="transparent"
                      onClick={() => removeUserCategory(cat)}
                    />
                  </Stack.Item>
                </Stack>
              ))}
              {uncategorizedFavs.length > 0 && (
                <Button
                  fluid
                  icon="star"
                  color={isFavouritesSelected ? 'good' : 'transparent'}
                  textAlign="left"
                  onClick={() => {
                    setSelectedCategory('\0favourites');
                    setSelectedVerb(null);
                    setSelectedTarget(null);
                  }}
                >
                  Favourites
                </Button>
              )}
              {(hasFavourites || userCategories.length > 0) && (
                <Box mb={0.5} mt={0.5}>
                  <hr
                    style={{
                      border: 'none',
                      borderTop: '1px solid rgba(255,255,255,0.1)',
                      margin: 0,
                    }}
                  />
                </Box>
              )}
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
              <Box mt={1}>
                <Stack>
                  <Stack.Item grow>
                    <Input
                      fluid
                      placeholder="New category..."
                      value={newCategoryName}
                      onChange={setNewCategoryName}
                      onEnter={addUserCategory}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="plus"
                      disabled={!newCategoryName.trim()}
                      onClick={addUserCategory}
                    />
                  </Stack.Item>
                </Stack>
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item basis="200px">
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
                    <div key={verb.type} style={{ display: 'flex' }}>
                      <Button
                        fluid
                        ellipsis
                        color={
                          selectedVerb?.type === verb.type
                            ? 'good'
                            : 'transparent'
                        }
                        textAlign="left"
                        onClick={() => selectVerb(verb)}
                        style={{ flex: '1 1 0', minWidth: 0 }}
                      >
                        {verb.name}
                      </Button>
                      <Button
                        icon="star"
                        color={
                          verb.type in favourites ? 'yellow' : 'transparent'
                        }
                        onClick={(e) => {
                          e.stopPropagation();
                          toggleFavourite(verb.type);
                        }}
                        style={{ flex: '0 0 auto' }}
                      />
                    </div>
                  ))}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow>
            <Stack fill vertical>
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
                      <>
                        {selectedVerb.type in favourites &&
                          userCategories.length > 0 && (
                            <span
                              style={{
                                display: 'inline-block',
                                marginRight: '4px',
                              }}
                            >
                              <Dropdown
                                options={['None', ...userCategories]}
                                selected={
                                  favourites[selectedVerb.type] || 'None'
                                }
                                onSelected={(val: string) =>
                                  assignVerbCategory(
                                    selectedVerb.type,
                                    val === 'None' ? '' : val,
                                  )
                                }
                                width="100px"
                              />
                            </span>
                          )}
                        <Button
                          icon="star"
                          color={
                            selectedVerb.type in favourites
                              ? 'yellow'
                              : 'transparent'
                          }
                          onClick={() => toggleFavourite(selectedVerb.type)}
                          mr={0.5}
                        />
                        <Button icon="play" color="good" onClick={invokeVerb} />
                      </>
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
  if (arg.source === ARG_SOURCE_LIST && arg.options) {
    return (
      <Stack align="center">
        <Stack.Item basis="100px">{arg.name}</Stack.Item>
        <Stack.Item grow>
          <Dropdown
            options={arg.options}
            selected={value as string}
            onSelected={onChange}
            width="100%"
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
