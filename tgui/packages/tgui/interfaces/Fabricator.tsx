import { useBackend, useSharedState } from '../backend';
import { Stack, Section, Button, Input, Icon, Tabs, Dimmer } from '../components';
import { Window } from '../layouts';
import { Material, MaterialAmount, MaterialFormatting, Materials, MATERIAL_KEYS } from './common/Materials';

type Design = {
  name: string;
  desc: string;
  cost: { [K in keyof typeof MATERIAL_KEYS]: number };
  id: string;
  categories?: string[];
  maxstack: number;
  icon: string;
};

type FabricatorData = {
  materials: Material[];
  fab_name: string;
  on_hold: boolean;
  designs: { [K: string]: Design };
  busy: boolean;
};

type AvailableMaterials = { [K in keyof typeof MATERIAL_KEYS]?: number };

export const Fabricator = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { materials, fab_name, on_hold, designs, busy } = data;
  const sortedDesigns = Object.values(designs).sort((a, b) =>
    a.name > b.name ? 1 : 0
  );
  const categoryCounts: { [K: string]: number } = {};
  const [selectedCategory, setSelectedCategory] = useSharedState(
    context,
    'selected_category',
    '__ALL'
  );
  const [searchText, setSearchText] = useSharedState(
    context,
    'search_text',
    ''
  );
  const [displayMatCost, setDisplayMatCost] = useSharedState(
    context,
    'display_material_cost',
    true
  );
  let recipeCount = 0;

  Object.values(sortedDesigns).map((design) => {
    Object.values(design.categories || []).map((name) => {
      categoryCounts[name] = (categoryCounts[name] || 0) + 1;
    });

    recipeCount += 1;
  });

  const availableMaterials = Object.values(data.materials || []).reduce(
    (state, value) => {
      state[value.name] = state[value.name] || 0 + value.amount;
      return state;
    },
    {}
  ) as AvailableMaterials;
  const sortedMaterials = (data.materials || [])
    .splice(0)
    .sort((a, b) => (a.name > b.name ? 1 : 0));

  // This smells. You got a better idea?
  delete categoryCounts['initial'];
  delete categoryCounts['core'];

  const namedCategories = Object.keys(categoryCounts).sort((a, b) =>
    a > b ? 1 : 0
  );

  return (
    <Window title={data.fab_name} width={768} height={750}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item>
                <Section fill title="Categories">
                  <Tabs vertical>
                    <Tabs.Tab
                      fluid
                      selected={selectedCategory === '__ALL'}
                      onClick={() => setSelectedCategory('__ALL')}
                      color="transparent">
                      All Recipes ({recipeCount})
                    </Tabs.Tab>

                    {Object.values(namedCategories).map((categoryName) => (
                      <Tabs.Tab
                        key={categoryName}
                        selected={selectedCategory === categoryName}
                        onClick={() => setSelectedCategory(categoryName)}
                        fluid
                        color="transparent">
                        {categoryName} ({categoryCounts[categoryName]})
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  fill
                  scrollable
                  title="Recipes"
                  buttons={
                    <span>
                      <Button.Checkbox
                        onClick={() => setDisplayMatCost(!displayMatCost)}
                        checked={displayMatCost}>
                        Display Material Costs
                      </Button.Checkbox>
                      <Button
                        content="R&D Sync"
                        onClick={() => act('sync_rnd')}
                      />
                    </span>
                  }>
                  <Stack vertical>
                    <Stack.Item>
                      <Stack align="baseline">
                        <Stack.Item>
                          <Icon name="search" />
                        </Stack.Item>
                        <Stack.Item grow>
                          <Input
                            fluid
                            placeholder="Search for..."
                            onInput={(_e: unknown, v: string) =>
                              setSearchText(v.toLowerCase())
                            }
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Section>
                        {Object.values(sortedDesigns)
                          .filter(
                            (design) =>
                              selectedCategory === '__ALL' ||
                              design.categories?.indexOf(selectedCategory) !==
                                -1
                          )
                          .filter(
                            (design) =>
                              design.name.toLowerCase().indexOf(searchText) !==
                              -1
                          )
                          .map((design) => (
                            <Recipe
                              key={design.name}
                              design={design}
                              available={availableMaterials}
                            />
                          ))}
                      </Section>
                    </Stack.Item>
                  </Stack>
                </Section>
                {busy ? (
                  <Dimmer style={{ 'font-size': '2em' }}>
                    <Icon name="cog" spin />
                    {' Building items...'}
                  </Dimmer>
                ) : undefined}
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Materials
                materials={sortedMaterials}
                onEject={(ref, amount) => act('remove_mat', { ref, amount })}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialCost = (
  props: { design: Design; amount: number; available: AvailableMaterials },
  context
) => {
  const { design, amount, available } = props;

  return (
    <Stack>
      {Object.entries(design.cost).map(([material, cost]) => (
        <Stack.Item key={material}>
          <MaterialAmount
            name={material as keyof typeof MATERIAL_KEYS}
            amount={cost * amount}
            formatting={MaterialFormatting.SIUnits}
            color={
              cost * amount > available[material]
                ? 'bad'
                : cost * (amount + 1) > available['material']
                  ? 'danger'
                  : 'normal'
            }
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const PrintButton = (
  props: { design: Design; amount: number; available: AvailableMaterials },
  context
) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { design, amount, available } = props;

  const [displayMatCost] = useSharedState(
    context,
    'display_material_cost',
    false
  );
  const cantPrint = Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] || 0) * amount
  );

  return (
    <Button
      className={`Fabricator__PrintAmount ${
        cantPrint ? 'Fabricator__PrintAmount--disabled' : ''
      }`}
      tooltip={
        displayMatCost && (
          <MaterialCost design={design} amount={amount} available={available} />
        )
      }
      color={'transparent'}
      onClick={() => act('build', { ref: design.id, amount })}>
      x{amount}
    </Button>
  );
};

const Recipe = (
  props: { design: Design; available: AvailableMaterials },
  context
) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { design, available } = props;

  const [displayMatCost] = useSharedState(
    context,
    'display_material_cost',
    false
  );
  const cantPrint = Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] || 0)
  );

  return (
    <div class="Fabricator__Recipe">
      <Stack justify="space-between" align="stretch">
        <Stack.Item grow>
          <Button
            color={'transparent'}
            className={`Fabricator__Button ${
              cantPrint ? 'Fabricator__Button--disabled' : ''
            }`}
            fluid
            tooltip={
              displayMatCost && (
                <MaterialCost
                  design={design}
                  amount={1}
                  available={available}
                />
              )
            }
            onClick={() => act('build', { ref: design.id, amount: 1 })}>
            {design.name}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <PrintButton design={design} amount={5} available={available} />
        </Stack.Item>
        <Stack.Item>
          <PrintButton design={design} amount={10} available={available} />
        </Stack.Item>
      </Stack>
    </div>
  );
};

/*
<Materials
                vertical
                materials={data.materials || []}
                onEject={(ref, amount) => {
                  act('remove_mat', {
                    ref: ref,
                    amount: amount,
                  });
                }}
              />
              */
