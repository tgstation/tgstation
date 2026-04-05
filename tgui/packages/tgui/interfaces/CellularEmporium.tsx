import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// ==========
// Types
// ==========
type TypePath = string;

type Ability = {
  name: string;
  desc: string;
  helptext: string;
  path: TypePath;
  genetic_point_required: number;
  absorbs_required: number;
  dna_required: number;
  category: string;
};

type CellularEmporiumContext = {
  abilities: Ability[];
  can_readapt: number;
  genetic_points_count: number;
  owned_abilities: TypePath[];
  absorb_count: number;
  dna_count: number;
};

// ==========
// Helper: convert ability name to icon_state
// Example: "Augmented Eyesight" → "augmented_eyesight"
// ==========
const nameToIconState = (name: string): string => {
  return name.toLowerCase().replace(/\s+/g, '_');
};

// ==========
// Main Component
// ==========
export const CellularEmporium = (props) => {
  const { act, data } = useBackend<CellularEmporiumContext>();
  const {
    abilities,
    can_readapt,
    genetic_points_count,
    owned_abilities,
    absorb_count,
    dna_count,
  } = data;

  const [searchText, setSearchText] = useState('');
  const [compactMode, setCompactMode] = useState(false);

  const CATEGORY_ORDER = ['combat', 'stealth', 'utility', 'stings'];
  const allCategories = Array.from(new Set(abilities.map((a) => a.category)));
  const sortedCategories = [
    ...CATEGORY_ORDER.filter((cat) => allCategories.includes(cat)),
    ...allCategories.filter((cat) => !CATEGORY_ORDER.includes(cat)),
  ];
  const [selectedCategory, setSelectedCategory] = useState(
    sortedCategories[0] || 'utility',
  );

  const filteredItems = (
    searchText
      ? abilities.filter((item) =>
          [item.name, item.desc, item.helptext]
            .join(' ')
            .toLowerCase()
            .includes(searchText.toLowerCase()),
        )
      : abilities.filter((item) => item.category === selectedCategory)
  ).sort((a, b) => a.name.localeCompare(b.name));

  const handleBuy = (ability: Ability) => {
    act('evolve', { path: ability.path });
  };

  return (
    <Window width={900} height={520}>
      <Window.Content
        scrollable={false}
        style={{
          backgroundImage: "url('tgui-core/assets/bg-nanotrasen.svg')",
          backgroundSize: 'cover',
          backgroundRepeat: 'no-repeat',
          backgroundColor: '#1A1A1A',
          overflowY: 'auto',
        }}
      >
        <Section
          fill
          scrollable={false}
          title={
            <Stack fill>
              <Stack.Item fontSize="16px" color="#DD66DD" ml={1}>
                <Icon name="dna" /> {genetic_points_count} DNA
              </Stack.Item>
              <Stack.Item grow />
              <Stack.Item>
                <Button
                  icon="undo"
                  color="good"
                  disabled={!can_readapt}
                  tooltip={
                    can_readapt
                      ? 'Un-evolve all abilities and refund genetic points.'
                      : 'Need more DNA to readapt.'
                  }
                  onClick={() => act('readapt')}
                >
                  Readapt ({can_readapt})
                </Button>
              </Stack.Item>
            </Stack>
          }
        >
          <Stack fill>
            <Stack.Item width="180px">
              <Stack vertical fill>
                <Stack.Item>
                  <Input
                    autoFocus
                    value={searchText}
                    placeholder="Search..."
                    onChange={setSearchText}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    lineHeight={2}
                    textAlign="center"
                    icon={compactMode ? 'maximize' : 'minimize'}
                    tooltip={compactMode ? 'Detailed view' : 'Compact view'}
                    onClick={() => setCompactMode(!compactMode)}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Tabs vertical fill>
                    {sortedCategories.map((category) => (
                      <Tabs.Tab
                        key={category}
                        selected={category === selectedCategory}
                        onClick={() => {
                          setSelectedCategory(category);
                          if (searchText) setSearchText('');
                        }}
                        mt={1}
                      >
                        {category.charAt(0).toUpperCase() + category.slice(1)}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item grow>
              <Box height="100%" pr={1} mr={-1}>
                {filteredItems.length === 0 ? (
                  <NoticeBox>
                    {searchText
                      ? 'No abilities found.'
                      : 'No abilities in this category.'}
                  </NoticeBox>
                ) : (
                  <ItemList
                    compactMode={searchText.length > 0 || compactMode}
                    items={filteredItems}
                    owned_abilities={owned_abilities}
                    genetic_points_count={genetic_points_count}
                    absorb_count={absorb_count}
                    dna_count={dna_count}
                    handleBuy={handleBuy}
                  />
                )}
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

// ==========
// ItemList Component
// ==========
type ItemListProps = {
  compactMode: BooleanLike;
  items: Ability[];
  owned_abilities: TypePath[];
  genetic_points_count: number;
  absorb_count: number;
  dna_count: number;
  handleBuy: (item: Ability) => void;
};

const ItemList = (props: ItemListProps) => {
  const {
    compactMode,
    items,
    owned_abilities,
    genetic_points_count,
    absorb_count,
    dna_count,
    handleBuy,
  } = props;

  const iconSize = compactMode ? '32px' : '64px';

  return (
    <Section fill scrollable>
      <Stack vertical mt={compactMode ? 0.5 : 0}>
        {items.map((ability) => {
          const owned = owned_abilities.includes(ability.path);
          const canAfford =
            !owned &&
            ability.genetic_point_required <= genetic_points_count &&
            ability.absorbs_required <= absorb_count &&
            ability.dna_required <= dna_count;

          const requirementTooltip = [
            `${ability.genetic_point_required} DNA`,
            ...(ability.absorbs_required > 0
              ? [`${ability.absorbs_required} absorptions`]
              : []),
            ...(ability.dna_required > 0
              ? [`${ability.dna_required} DNA`]
              : []),
          ].join(', ');

          const costDisplay =
            ability.dna_required > 0
              ? `Cost: ${ability.dna_required} DNA`
              : `Cost: ${ability.genetic_point_required} DNA`;

          const iconState = nameToIconState(ability.name);

          return (
            <Stack.Item key={ability.path} mt={compactMode ? 0.5 : 1}>
              <Section fitted={!!compactMode}>
                <Stack>
                  <Stack.Item>
                    <Box ml={2}>
                      <Box
                        width={iconSize}
                        height={iconSize}
                        position="relative"
                        m={compactMode ? '2px' : 0}
                        mr={1}
                      >
                        <DmIcon
                          position="absolute"
                          top="0"
                          left="0"
                          icon="icons/mob/actions/actions_changeling.dmi"
                          icon_state="bg_changeling"
                          width={iconSize}
                          fallback={null}
                        />
                        <DmIcon
                          position="absolute"
                          top="0"
                          left="0"
                          icon="icons/mob/actions/actions_changeling.dmi"
                          icon_state={iconState}
                          width={iconSize}
                          fallback={<Icon name="question-circle" size={3} />}
                        />
                      </Box>
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    {compactMode ? (
                      <Stack>
                        <Stack.Item
                          bold
                          grow
                          lineHeight="36px"
                          style={{
                            overflow: 'hidden',
                            whiteSpace: 'nowrap',
                            textOverflow: 'ellipsis',
                            opacity: owned ? '0.5' : '1',
                          }}
                        >
                          {owned ? (
                            <Box color="#44bd46">
                              <Icon mr="8px" name="check" />
                              {ability.name}
                            </Box>
                          ) : (
                            ability.name
                          )}
                        </Stack.Item>
                        <Stack.Item>
                          <Tooltip content={ability.helptext || ability.desc}>
                            <Icon name="info-circle" lineHeight="36px" />
                          </Tooltip>
                        </Stack.Item>
                        <Stack.Item>
                          <Tooltip content={requirementTooltip}>
                            <Button
                              m="8px"
                              color={canAfford ? 'average' : 'bad'}
                              disabled={owned || !canAfford}
                              onClick={() => handleBuy(ability)}
                            >
                              {costDisplay}
                            </Button>
                          </Tooltip>
                        </Stack.Item>
                      </Stack>
                    ) : (
                      <Section
                        title={
                          <Box>
                            {ability.name}
                            {owned && (
                              <Box color="#44bd46" inline ml={1}>
                                (Owned)
                              </Box>
                            )}
                          </Box>
                        }
                        buttons={
                          <Tooltip content={requirementTooltip}>
                            <Box mt={-3}>
                              <Button
                                disabled={owned || !canAfford}
                                color={
                                  owned ? 'good' : canAfford ? 'average' : 'bad'
                                }
                                onClick={() => handleBuy(ability)}
                              >
                                {costDisplay}
                              </Button>
                            </Box>
                          </Tooltip>
                        }
                      >
                        <Box opacity={0.8}>{ability.desc}</Box>
                        {ability.helptext && (
                          <Box color="#44bd46" mt={0.5}>
                            {ability.helptext}
                          </Box>
                        )}
                      </Section>
                    )}
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
};
