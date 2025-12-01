import { Box, Icon, Section, Stack, Tooltip } from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import type { Design, Material, MaterialMap } from './Fabrication/Types';

type Data = {
  debug: BooleanLike;
  designs: Record<string, Design>;
  materials: Material[];
  SHEET_MATERIAL_AMOUNT: number;
};

export function ComponentPrinter(props) {
  const { act, data } = useBackend<Data>();
  const { materials = [], designs, SHEET_MATERIAL_AMOUNT, debug } = data;

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window
      title={`${debug && 'Debug '}Component Printer`}
      width={670}
      height={600}
      theme={debug ? 'admin' : undefined}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <DesignBrowser
              designs={Object.values(designs)}
              availableMaterials={availableMaterials}
              buildRecipeElement={(
                design,
                availableMaterials,
                _onPrintDesign,
              ) => <Recipe design={design} available={availableMaterials} />}
            />
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={materials}
                SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
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
}

type RecipeProps = {
  available: MaterialMap;
  design: Design;
};

function Recipe(props: RecipeProps) {
  const { available, design } = props;

  const { act, data } = useBackend<Data>();
  const { SHEET_MATERIAL_AMOUNT, debug } = data;

  const costs = Object.entries(design.cost);

  const canPrint =
    debug ||
    !costs.some(([material, amount]) => {
      const have = available[material];

      return !have || amount > have;
    });

  return (
    <div className="FabricatorRecipe">
      <Tooltip content={design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}
        >
          <Icon name="question-circle" />
        </div>
      </Tooltip>
      <Tooltip
        content={
          <MaterialCostSequence
            design={design}
            amount={1}
            SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
            available={available}
          />
        }
      >
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() =>
            canPrint && act('print', { designId: design.id, amount: 1 })
          }
        >
          <div className="FabricatorRecipe__Icon">
            <Box
              width="32px"
              height="32px"
              className={classes(['design32x32', design.icon])}
            />
          </div>
          <div className="FabricatorRecipe__Label">{design.name}</div>
        </div>
      </Tooltip>
    </div>
  );
}
