import { useBackend } from '../backend';
import { Material } from './Fabrication/Types';
import { Window } from '../layouts';
import { Box, Tooltip, Icon, Stack, Section } from '../components';
import { Design } from './Fabrication/Types';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { MaterialMap } from './Fabrication/Types';
import { classes } from 'common/react';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';

type ComponentPrinterData = {
  designs: Record<string, Design>;
  materials: Material[];
};

export const ComponentPrinter = (props, context) => {
  const { act, data } = useBackend<ComponentPrinterData>(context);
  const { designs, materials } = data;

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of data.materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title={'Component Printer'} width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <DesignBrowser
              designs={Object.values(designs)}
              availableMaterials={availableMaterials}
              buildRecipeElement={(
                design,
                availableMaterials,
                _onPrintDesign
              ) => <Recipe design={design} available={availableMaterials} />}
            />
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={data.materials ?? []}
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

const Recipe = (props: { design: Design; available: MaterialMap }, context) => {
  const { act, data } = useBackend<ComponentPrinterData>(context);
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
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
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
          onClick={() => act('print', { designId: design.id, amount: 1 })}>
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
    </div>
  );
};
