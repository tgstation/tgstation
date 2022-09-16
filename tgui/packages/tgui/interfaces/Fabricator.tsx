import { useBackend, useSharedState } from '../backend';
import { Stack, Section, Button, Icon, Dimmer, Box, Tooltip } from '../components';
import { Window } from '../layouts';
import { Material } from './common/Materials';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { sortBy } from 'common/collections';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { SearchBar } from './Fabrication/SearchBar';
import { DesignCategoryTabs } from './Fabrication/DesignCategoryTabs';
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

  // Sort the designs by name.
  const sortedDesigns = sortBy((design: Design) => design.name)(
    Object.values(designs)
  );

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
                <DesignCategoryTabs
                  currentCategory={selectedCategory}
                  onCategorySelected={(category) => {
                    setSelectedCategory(category);
                    setSearchText('');
                  }}
                  designs={sortedDesigns}
                />
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
                            <Section title={categoryName} key={categoryName}>
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
    <Button
      className={classes([
        'Fabricator__PrintAmount',
        !canPrint && 'Fabricator__PrintAmount--disabled',
      ])}
      tooltip={
        <MaterialCostSequence
          design={design}
          amount={quantity}
          available={available}
        />
      }
      color={'transparent'}
      onClick={() => act('build', { ref: design.id, amount: quantity })}>
      &times;{quantity}
    </Button>
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
        <div className="FabricatorRecipe__About">
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
          className="FabricatorRecipe__Title"
          onClick={() => act('build', { ref: design.id, amount: 1 })}>
          <div className="FabricatorRecipe__Icon">
            <Box
              width={'32px'}
              height={'32px'}
              className={classes([
                'Fabricator__Icon',
                'design32x32',
                design.icon,
              ])}
            />
          </div>
          <div className="FabricatorRecipe__Label">{design.name}</div>
        </div>
      </Tooltip>
      <Tooltip
        content={
          <MaterialCostSequence
            design={design}
            amount={5}
            available={available}
          />
        }>
        <div
          className="FabricatorRecipe__Button"
          onClick={() => act('build', { ref: design.id, amount: 5 })}>
          &times;5
        </div>
      </Tooltip>
      <Tooltip
        content={
          <MaterialCostSequence
            design={design}
            amount={10}
            available={available}
          />
        }>
        <div
          className="FabricatorRecipe__Button"
          onClick={() => act('build', { ref: design.id, amount: 10 })}>
          &times;10
        </div>
      </Tooltip>
    </div>
    // <div className="Fabricator__Recipe">
    //   <Flex justify={'space-between'} align={'stretch'}>
    //     <Flex.Item grow={1}>
    //       <Button
    //         color={'transparent'}
    //         className={classes([
    //           'Fabricator__Button',
    //           !canPrint && 'Fabricator__Button--disabled',
    //         ])}
    //         fluid
    //         tooltip={
    //           <MaterialCostSequence
    //             design={design}
    //             amount={1}
    //             available={available}
    //           />
    //         }
    //         onClick={() => act('build', { ref: design.id, amount: 1 })}>
    //         <Flex align={'center'}>
    //           <Flex.Item>
    //             <Box
    //               width={'32px'}
    //               height={'32px'}
    //               className={classes([
    //                 'Fabricator__Icon',
    //                 'design32x32',
    //                 design.icon,
    //               ])}
    //             />
    //           </Flex.Item>
    //           <Flex.Item>{design.name}</Flex.Item>
    //         </Flex>
    //       </Button>
    //     </Flex.Item>
    //     <Flex.Item>
    //       <PrintButton design={design} quantity={5} available={available} />
    //     </Flex.Item>
    //     <Flex.Item>
    //       <PrintButton design={design} quantity={10} available={available} />
    //     </Flex.Item>
    //   </Flex>
    // </div>
  );
};
