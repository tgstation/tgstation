import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Material, MaterialAmount, MaterialFormatting, Materials, MATERIAL_KEYS } from './common/Materials';
import { Window } from '../layouts';
import { Button, Input, Section, Stack, Tabs } from '../components';

const CATEGORY_ALL = "All";

const searchFor = searchText => createSearch(
  searchText,
  ([_, thing]) => thing.name + thing.description,
);

const getCategory = (category: string[]) => {
  return category[0] === "Circuitry" ? category[1] : category[0];
};

type Design = {
  name: string,
  description: string,
  materials: Record<keyof typeof MATERIAL_KEYS, number>,
  categories: string[],
}

type ComponentPrinterData = {
  designs: Record<string, Design>,
  materials: Material[],
};

const canProduce = (
  designMaterials: Design["materials"],
  storedMaterials: Material[],
) => {
  for (const material of storedMaterials) {
    const amountNeeded = designMaterials[material.name];

    if (amountNeeded && amountNeeded > material.amount) {
      return false;
    }
  }

  return true;
};

const MaterialCost = (props: {
  materials: Design["materials"],
}) => {
  return (
    <Stack>
      {Object.entries(props.materials)
        .map(([material, amount]) => {
          return (
            <Stack.Item key={material} mr={1}>
              <MaterialAmount
                name={material as keyof typeof MATERIAL_KEYS}
                amount={amount}
                formatting={MaterialFormatting.Locale}
                style={{
                  transform: 'scale(0.75) translate(0%, 10%)',
                }}
              />
            </Stack.Item>
          );
        })}
    </Stack>
  );
};

export const ComponentPrinter = (props, context) => {
  const { act, data } = useBackend<ComponentPrinterData>(context);

  const [currentCategory, setCurrentCategory] = useLocalState(context, "category", CATEGORY_ALL);
  const [searchText, setSearchText] = useLocalState(context, "searchText", "");

  return (
    <Window title="Component Printer" width={900} height={700}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section title="Materials">
              <Materials
                materials={data.materials || []}
                onEject={(ref, amount) => {
                  act("remove_mat", {
                    ref: ref,
                    amount: amount,
                  });
                }}
              />
            </Section>

            <Stack fill>
              <Stack.Item>
                <Section fill title="Categories">
                  <Tabs vertical>
                    {Object.values(data.designs)
                      .reduce<string[]>((categories, design) => {
                        const category = getCategory(design.categories);
                        if (categories.indexOf(category) === -1) {
                          return [category, ...categories];
                        } else {
                          return categories;
                        }
                      }, [CATEGORY_ALL]).sort().map(category => {
                        return (
                          <Tabs.Tab key={category}
                            onClick={() => setCurrentCategory(category)}
                            selected={category === currentCategory}
                            fluid
                          >
                            {category}
                          </Tabs.Tab>
                        );
                      })}
                  </Tabs>
                </Section>
              </Stack.Item>

              <Stack.Item fill grow>
                <Section fill title="Parts">
                  <Stack fill vertical>
                    <Stack.Item>
                      <Input
                        placeholder="Search..."
                        autoFocus
                        fluid
                        value={searchText}
                        onInput={(_, value) => setSearchText(value)} />
                    </Stack.Item>

                    {Object.entries(data.designs)
                      .filter(([_, design]) => currentCategory === CATEGORY_ALL
                        || design.categories.indexOf(currentCategory) !== -1)
                      .filter(searchFor(searchText))
                      .map(([designId, design]) => {
                        return (
                          <Stack.Item key={designId}>
                            <Section title={design.name} buttons={(
                              <Button
                                onClick={() => {
                                  act("print", {
                                    designId,
                                  });
                                }}
                                disabled={
                                  !canProduce(design.materials, data.materials)
                                }
                                px={1.5}
                              >
                                Print
                              </Button>
                            )}>
                              {design.description}

                              <MaterialCost materials={design.materials} />
                            </Section>
                          </Stack.Item>
                        );
                      })}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
