import {
  Box,
  Button,
  Dimmer,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { Design, FabricatorData, MaterialMap } from './Fabrication/Types';

export const Fabricator = (props) => {
  const { act, data } = useBackend<FabricatorData>();
  const { fabName, onHold, designs, busy, SHEET_MATERIAL_AMOUNT } = data;

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of data.materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title={fabName} width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <DesignBrowser
              busy={!!busy}
              designs={Object.values(designs)}
              availableMaterials={availableMaterials}
              buildRecipeElement={(design, availableMaterials) => (
                <Recipe
                  design={design}
                  available={availableMaterials}
                  SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                />
              )}
            />
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={data.materials ?? []}
                SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                onEjectRequested={(material, amount) =>
                  act('remove_mat', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
        {!!onHold && (
          <Dimmer style={{ fontSize: '2em', textAlign: 'center' }}>
            Mineral access is on hold, please contact the quartermaster.
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};

type PrintButtonProps = {
  design: Design;
  quantity: number;
  SHEET_MATERIAL_AMOUNT: number;
  available: MaterialMap;
};

const PrintButton = (props: PrintButtonProps) => {
  const { act } = useBackend<FabricatorData>();
  const { design, quantity, available, SHEET_MATERIAL_AMOUNT } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount * quantity > (available[material] ?? 0),
  );

  return (
    <Tooltip
      content={
        <MaterialCostSequence
          design={design}
          amount={quantity}
          SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
          available={available}
        />
      }
    >
      <div
        className={classes([
          'FabricatorRecipe__Button',
          !canPrint && 'FabricatorRecipe__Button--disabled',
        ])}
        color={'transparent'}
        onClick={() => act('build', { ref: design.id, amount: quantity })}
      >
        &times;{quantity}
      </div>
    </Tooltip>
  );
};

type CustomPrintProps = {
  design: Design;
  available: MaterialMap;
};

const CustomPrint = (props: CustomPrintProps) => {
  const { act } = useBackend();
  const { design, available } = props;
  let maxMult = Object.entries(design.cost).reduce(
    (accumulator: number, [material, required]) => {
      return Math.min(accumulator, (available[material] || 0) / required);
    },
    Infinity,
  );
  maxMult = Math.min(Math.floor(maxMult), 50);
  const canPrint = maxMult > 0;

  return (
    <div
      className={classes([
        'FabricatorRecipe__Button',
        !canPrint && 'FabricatorRecipe__Button--disabled',
      ])}
    >
      <Button.Input
        color="transparent"
        onCommit={(_e, value: string) =>
          act('build', {
            ref: design.id,
            amount: value,
          })
        }
      >
        [Max: {maxMult}]
      </Button.Input>
    </div>
  );
};

type RecipeProps = {
  design: Design;
  available: MaterialMap;
  SHEET_MATERIAL_AMOUNT: number;
};

const Recipe = (props: RecipeProps) => {
  const { act } = useBackend<FabricatorData>();
  const { design, available, SHEET_MATERIAL_AMOUNT } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] ?? 0),
  );

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
            canPrint && act('build', { ref: design.id, amount: 1 })
          }
        >
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
      <PrintButton
        design={design}
        quantity={5}
        available={available}
        SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
      />
      <PrintButton
        design={design}
        quantity={10}
        available={available}
        SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
      />
      <CustomPrint design={design} available={available} />
    </div>
  );
};
