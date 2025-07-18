import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Divider,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { GroupTitle } from '../GroupTitle';
import { findIcon } from '../helpers';
import { type CraftingData, type Diet, MODE, type Recipe } from '../types';
import { AtomContent } from './AtomContent';
import { FoodtypeContent } from './FoodtypeContent';
import { ToolContent } from './ToolContent';

type Props = {
  busy: BooleanLike;
  craftable: boolean;
  item: Recipe;
  mode: BooleanLike;
};

export function RecipeContentCompact(props: Props) {
  const { item, craftable, busy, mode } = props;
  const { act, data } = useBackend<CraftingData>();

  return (
    <Section>
      <Stack my={-0.75}>
        <Stack.Item>
          <Box className={findIcon(item.id, data)} />
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box mb={0.5} bold style={{ textTransform: 'capitalize' }}>
                {item.name}
              </Box>
              <Box style={{ textTransform: 'capitalize' }} color="gray">
                {Array.from(
                  Object.keys(item.reqs).map((id) => {
                    const atom_id = Number(id);

                    const name = data.atom_data[atom_id - 1]?.name;
                    const is_reagent = data.atom_data[atom_id - 1]?.is_reagent;
                    const amount = item.reqs[atom_id];
                    return is_reagent
                      ? `${name}\xa0${amount}u`
                      : amount > 1
                        ? `${name}\xa0${amount}x`
                        : name;
                  }),
                ).join(', ')}

                {item.chem_catalysts &&
                  ', ' +
                    Object.keys(item.chem_catalysts)
                      .map((id) => {
                        const atom_id = Number(id);

                        const name = data.atom_data[atom_id - 1]?.name;
                        const is_reagent =
                          data.atom_data[atom_id - 1]?.is_reagent;
                        const amount = item.chem_catalysts[atom_id];
                        return is_reagent
                          ? `${name}\xa0${amount}u`
                          : amount > 1
                            ? `${name}\xa0${amount}x`
                            : name;
                      })
                      .join(', ')}

                {item.tool_paths &&
                  ', ' +
                    item.tool_paths
                      .map((item) => data.atom_data[Number(item) - 1]?.name)
                      .join(', ')}
                {item.machinery &&
                  ', ' +
                    item.machinery
                      .map((item) => data.atom_data[Number(item) - 1]?.name)
                      .join(', ')}
                {item.structures &&
                  ', ' +
                    item.structures
                      .map((item) => data.atom_data[Number(item) - 1]?.name)
                      .join(', ')}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!item.non_craftable ? (
                <Box>
                  {!!item.tool_behaviors && (
                    <Tooltip
                      content={`Tools: ${item.tool_behaviors.join(', ')}`}
                    >
                      <Icon p={1} name="screwdriver-wrench" />
                    </Tooltip>
                  )}
                  <Button
                    my={0.3}
                    lineHeight={2.5}
                    align="center"
                    disabled={!craftable || busy}
                    icon={
                      busy
                        ? 'circle-notch'
                        : mode === MODE.cooking
                          ? 'utensils'
                          : 'hammer'
                    }
                    iconSpin={!!busy}
                    onClick={() =>
                      act('make', {
                        recipe: item.ref,
                      })
                    }
                  >
                    Make
                  </Button>
                  {!!item.mass_craftable && (
                    <Button
                      my={0.3}
                      lineHeight={2.5}
                      width="32px"
                      align="center"
                      tooltip="Repeat this craft until you run out of ingredients."
                      tooltipPosition="top"
                      disabled={!craftable || busy}
                      icon="repeat"
                      iconSpin={!!busy}
                      onClick={() =>
                        act('make_mass', {
                          recipe: item.ref,
                        })
                      }
                    />
                  )}
                </Box>
              ) : (
                item.steps && (
                  <Tooltip
                    content={item.steps.map((step) => (
                      <Box key={step}>{step}</Box>
                    ))}
                  >
                    <Box fontSize={1.5} p={1}>
                      <Icon name="circle-question-o" />
                    </Box>
                  </Tooltip>
                )
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type FullProps = Props & {
  diet: Diet;
};

export function RecipeContent(props: FullProps) {
  const { item, craftable, busy, mode, diet } = props;
  const { act, data } = useBackend<CraftingData>();

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Box width="64px" height="64px" mr={1}>
            <Box
              style={{
                transform: 'scale(1.5)',
              }}
              m="16px"
              className={findIcon(item.id, data)}
            />
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow={5}>
              <Box mb={1} bold style={{ textTransform: 'capitalize' }}>
                {item.name}
              </Box>
              {item.desc && <Box color="gray">{item.desc}</Box>}
              {!!item.has_food_effect && (
                <Box my={2} color="pink">
                  <Icon name="wand-magic-sparkles" mr={1} />
                  Special effect on consumption.
                </Box>
              )}
              <Box style={{ textTransform: 'capitalize' }}>
                {item.reqs && (
                  <Box>
                    <GroupTitle
                      title={
                        mode === MODE.cooking ? 'Ingredients' : 'Materials'
                      }
                    />
                    {Object.keys(item.reqs).map((atom_id) => (
                      <AtomContent
                        key={atom_id}
                        atom_id={atom_id}
                        amount={item.reqs[atom_id]}
                      />
                    ))}
                  </Box>
                )}
                {item.chem_catalysts && (
                  <Box>
                    <GroupTitle title="Catalysts" />
                    {Object.keys(item.chem_catalysts).map((atom_id) => (
                      <AtomContent
                        key={atom_id}
                        atom_id={atom_id}
                        amount={item.chem_catalysts[atom_id]}
                      />
                    ))}
                  </Box>
                )}
                {(item.tool_paths || item.tool_behaviors) && (
                  <Box>
                    <GroupTitle title="Tools" />
                    {item.tool_paths?.map((tool) => (
                      <AtomContent key={tool} atom_id={tool} amount={1} />
                    ))}
                    {item.tool_behaviors?.map((tool) => (
                      <ToolContent key={tool} tool={tool} />
                    ))}
                  </Box>
                )}
                {item.machinery && (
                  <Box>
                    <GroupTitle title="Machinery" />
                    {item.machinery.map((atom_id) => (
                      <AtomContent key={atom_id} atom_id={atom_id} amount={1} />
                    ))}
                  </Box>
                )}
                {item.structures && (
                  <Box>
                    <GroupTitle title="Structures" />
                    {item.structures.map((atom_id) => (
                      <AtomContent key={atom_id} atom_id={atom_id} amount={1} />
                    ))}
                  </Box>
                )}
              </Box>
              {!!item.steps?.length && (
                <Box>
                  <GroupTitle title="Steps" />
                  <ul style={{ paddingLeft: '20px' }}>
                    {item.steps.map((step) => (
                      <li key={step}>{step}</li>
                    ))}
                  </ul>
                </Box>
              )}
            </Stack.Item>
            <Stack.Item pl={1} grow={2}>
              <Stack vertical>
                <Stack.Item>
                  {!item.non_craftable && (
                    <Stack>
                      <Stack.Item grow>
                        <Button
                          lineHeight={2.5}
                          align="center"
                          fluid
                          disabled={!craftable || busy}
                          icon={
                            busy
                              ? 'circle-notch'
                              : mode === MODE.cooking
                                ? 'utensils'
                                : 'hammer'
                          }
                          iconSpin={!!busy}
                          onClick={() =>
                            act('make', {
                              recipe: item.ref,
                            })
                          }
                        >
                          Make
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        {!!item.mass_craftable && (
                          <Button
                            minWidth="30px"
                            lineHeight={2.5}
                            align="center"
                            tooltip="Repeat this craft until you run out of ingredients."
                            tooltipPosition="top"
                            disabled={!craftable || busy}
                            icon="repeat"
                            iconSpin={!!busy}
                            onClick={() =>
                              act('make_mass', {
                                recipe: item.ref,
                              })
                            }
                          />
                        )}
                      </Stack.Item>
                    </Stack>
                  )}
                </Stack.Item>
                <Stack.Item>
                  {!!item.complexity && (
                    <Box color="gray" width="104px" lineHeight={1.5} mt={1}>
                      Complexity: {item.complexity}
                    </Box>
                  )}
                  {item.foodtypes?.length > 0 && (
                    <Box color="gray" width="104px" lineHeight={1.5} mt={1}>
                      <Divider />
                      {item.foodtypes.map((foodtype) => (
                        <FoodtypeContent
                          key={item.ref + foodtype}
                          type={foodtype}
                          diet={diet}
                        />
                      ))}
                    </Box>
                  )}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
