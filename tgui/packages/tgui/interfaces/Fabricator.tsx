import { useBackend, useSharedState } from '../backend';
import { Stack, Section, Icon, Dimmer, Box, Tooltip } from '../components';
import { Window } from '../layouts';
import { Material } from './common/Materials';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { sortBy } from 'common/collections';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { SearchBar } from './Fabrication/SearchBar';
import { FabricatorData, Design, MaterialMap } from './Fabrication/Types';
import { classes } from 'common/react';

/**
 * A dummy category that, when selected, renders ALL recipes to the UI.
 */
const ALL_CATEGORY = '__ALL';

export const Fabricator = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { fab_name, on_hold, designs, busy } = data;

  const [selectedCategory, setSelectedCategory] = useSharedState(
    context,
    'selected_category',
    ALL_CATEGORY
  );
  const [searchText, setSearchText] = useSharedState(
    context,
    'search_text',
    ''
  );

  const categoryCounts: Record<string, number> = {};
  const categorySubs: Record<string, Record<string, number>> = {};
  let totalRecipes = 0;

  // Sort the designs by name.
  const sortedDesigns = sortBy((design: Design) => design.name)(
    Object.values(designs)
  );

  for (const design of sortedDesigns) {
    totalRecipes += 1;

    for (const category of design.categories) {
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    for (const [category, subcategory] of Object.entries(
      design.subcategories
    )) {
      if (!categorySubs[category]) {
        categorySubs[category] = {};
      }

      categorySubs[category][subcategory] =
        (categorySubs[category]![subcategory] ?? 0) + 1;
    }
  }

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of data.materials) {
    availableMaterials[material.name] = material.amount;
  }

  const visibleDesigns = sortedDesigns
    .filter(
      (design) =>
        selectedCategory === ALL_CATEGORY ||
        design.categories?.indexOf(selectedCategory) !== -1
    )
    .filter((design) =>
      design.name.toLowerCase().includes(searchText.toLowerCase())
    );

  const subcategories: Record<string, Design[]> = {};

  for (const design of visibleDesigns) {
    const subcategory =
      design.subcategories[selectedCategory] || 'Uncategorized';

    if (!subcategories[subcategory]) {
      subcategories[subcategory] = [];
    }

    subcategories[subcategory]!.push(design);
  }

  return (
    <Window title={fab_name} width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width={'200px'}>
                <Section fill>
                  <Stack vertical fill>
                    <Stack.Item>
                      <Section title="Categories" fitted />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Section fill style={{ 'overflow': 'auto' }}>
                        <div className="FabricatorTabs">
                          <div
                            className={classes([
                              'FabricatorTabs__Tab',
                              selectedCategory === ALL_CATEGORY &&
                                'FabricatorTabs__Tab--active',
                            ])}
                            onClick={() => setSelectedCategory(ALL_CATEGORY)}>
                            <div className="FabricatorTabs__Label">
                              <div className="FabricatorTabs__CategoryName">
                                All Designs
                              </div>
                              <div className="FabricatorTabs__CategoryCount">
                                ({totalRecipes})
                              </div>
                            </div>
                          </div>
                          {sortBy(
                            (_: [categoryName: string, count: number]) => _[0]
                          )(Object.entries(categoryCounts)).map(
                            ([categoryName, categoryQuantity]) => (
                              <div
                                className={classes([
                                  'FabricatorTabs__Tab',
                                  selectedCategory === categoryName &&
                                    'FabricatorTabs__Tab--active',
                                ])}
                                onClick={() =>
                                  setSelectedCategory(categoryName)
                                }
                                key={categoryName}>
                                <div className="FabricatorTabs__Label">
                                  <div className="FabricatorTabs__CategoryName">
                                    {categoryName}
                                  </div>
                                  <div className="FabricatorTabs__CategoryCount">
                                    ({categoryQuantity})
                                  </div>
                                </div>
                                {selectedCategory === categoryName &&
                                  categorySubs[categoryName] && (
                                    <div className="FabricatorTabs">
                                      {sortBy(
                                        (pair: [string, number]) => pair[0]
                                      )(
                                        Object.entries(
                                          categorySubs[categoryName]
                                        )
                                      ).map(([subcategory, count]) => (
                                        <div
                                          key={subcategory}
                                          className="FabricatorTabs__Tab"
                                          onClick={() =>
                                            document
                                              .getElementById(
                                                subcategory.replace(/ /g, '')
                                              )!
                                              .scrollIntoView(true)
                                          }>
                                          <div
                                            className={'FabricatorTabs__Label'}>
                                            <div className="FabricatorTabs__CategoryName">
                                              {subcategory}
                                            </div>
                                          </div>
                                        </div>
                                      ))}
                                    </div>
                                  )}
                              </div>
                            )
                          )}
                        </div>
                      </Section>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  title={
                    selectedCategory === ALL_CATEGORY
                      ? 'All Designs'
                      : selectedCategory
                  }
                  fill>
                  <Stack vertical fill>
                    <Stack.Item>
                      <Section>
                        <SearchBar
                          searchText={searchText}
                          onSearchTextChanged={setSearchText}
                          hint={'Search this category...'}
                        />
                      </Section>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Section fill style={{ 'overflow': 'auto' }}>
                        {Object.keys(subcategories)
                          .sort()
                          .map((categoryName) => (
                            <Section
                              title={categoryName}
                              key={categoryName}
                              id={categoryName.replace(/ /g, '')}>
                              {subcategories[categoryName]!.map((design) => (
                                <Recipe
                                  key={design.name}
                                  design={design}
                                  available={availableMaterials}
                                />
                              ))}
                            </Section>
                          ))}
                      </Section>
                      {!!busy && (
                        <Dimmer
                          style={{
                            'font-size': '2em',
                            'text-align': 'center',
                          }}>
                          <Icon name="cog" spin />
                          {' Building items...'}
                        </Dimmer>
                      )}
                    </Stack.Item>
                  </Stack>
                </Section>
                {!!on_hold && (
                  <Dimmer
                    style={{ 'font-size': '2em', 'text-align': 'center' }}>
                    Mineral access is on hold, please contact the quartermaster.
                  </Dimmer>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={sortBy((a: Material) => a.name)(
                  data.materials ?? []
                )}
                onEjectRequested={(material, amount) =>
                  act('remove_mat', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type PrintButtonProps = {
  design: Design;
  quantity: number;
  available: MaterialMap;
};

const PrintButton = (props: PrintButtonProps, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { design, quantity, available } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount * quantity > (available[material] ?? 0)
  );

  return (
    <Tooltip
      content={
        <MaterialCostSequence
          design={design}
          amount={quantity}
          available={available}
        />
      }>
      <div
        className={classes([
          'FabricatorRecipe__Button',
          !canPrint && 'FabricatorRecipe__Button--disabled',
        ])}
        color={'transparent'}
        onClick={() => act('build', { ref: design.id, amount: quantity })}>
        &times;{quantity}
      </div>
    </Tooltip>
  );
};

const Recipe = (props: { design: Design; available: MaterialMap }, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { design, available } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] ?? 0)
  );

  return (
    <div className="FabricatorRecipe">
      <Tooltip content={design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__About',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}>
          <Icon name="question-circle" />
        </div>
      </Tooltip>
      <Tooltip
        content={
          <MaterialCostSequence
            design={design}
            amount={1}
            available={available}
          />
        }>
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() => act('build', { ref: design.id, amount: 1 })}>
          <div className="FabricatorRecipe__Icon">
            <Box
              width={'32px'}
              height={'32px'}
              className={classes(['design32x32', design.icon])}
            />
          </div>
          <div className="FabricatorRecipe__Label">{design.name}</div>
        </div>
      </Tooltip>
      <PrintButton design={design} quantity={5} available={available} />
      <PrintButton design={design} quantity={10} available={available} />
    </div>
  );
};
