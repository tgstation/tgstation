import {
  Box,
  Button,
  Collapsible,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { BooleanLike, classes } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { Design, MaterialMap } from './Fabrication/Types';
import { Material } from './Fabrication/Types';

type AutolatheDesign = Design & {
  customMaterials: BooleanLike;
};

type AutolatheData = {
  materials: Material[];
  materialtotal: number;
  materialsmax: number;
  SHEET_MATERIAL_AMOUNT: number;
  designs: AutolatheDesign[];
  active: BooleanLike;
};

export const Autolathe = (props) => {
  const { data } = useBackend<AutolatheData>();
  const {
    materialtotal,
    materialsmax,
    materials,
    designs,
    active,
    SHEET_MATERIAL_AMOUNT,
  } = data;

  const filteredMaterials = materials.filter((material) => material.amount > 0);

  const availableMaterials: MaterialMap = {};

  for (const material of filteredMaterials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title="Autolathe" width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Total Materials">
              <LabeledList>
                <LabeledList.Item label="Total Materials">
                  <ProgressBar
                    value={materialtotal}
                    minValue={0}
                    maxValue={materialsmax}
                    ranges={{
                      good: [materialsmax * 0.85, materialsmax],
                      average: [materialsmax * 0.25, materialsmax * 0.85],
                      bad: [0, materialsmax * 0.25],
                    }}
                  >
                    {materialtotal / SHEET_MATERIAL_AMOUNT +
                      '/' +
                      materialsmax / SHEET_MATERIAL_AMOUNT +
                      ' sheets'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item>
                  {filteredMaterials.length > 0 && (
                    <Collapsible title="Materials">
                      <LabeledList>
                        {filteredMaterials.map((material) => (
                          <LabeledList.Item
                            key={material.name}
                            label={capitalize(material.name)}
                          >
                            <ProgressBar
                              style={{
                                transform: 'scaleX(-1) scaleY(1)',
                              }}
                              value={materialsmax - material.amount}
                              maxValue={materialsmax}
                              backgroundColor={material.color}
                              color="black"
                            >
                              <div style={{ transform: 'scaleX(-1)' }}>
                                {material.amount / SHEET_MATERIAL_AMOUNT +
                                  ' sheets'}
                              </div>
                            </ProgressBar>
                          </LabeledList.Item>
                        ))}
                      </LabeledList>
                    </Collapsible>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <DesignBrowser
              busy={!!active}
              designs={designs}
              availableMaterials={availableMaterials}
              buildRecipeElement={(
                design,
                availableMaterials,
                _onPrintDesign,
              ) => (
                <AutolatheRecipe
                  design={design}
                  SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                  availableMaterials={availableMaterials}
                />
              )}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type PrintButtonProps = {
  design: Design;
  quantity: number;
  availableMaterials: MaterialMap;
  SHEET_MATERIAL_AMOUNT: number;
  maxmult: number;
};

const PrintButton = (props: PrintButtonProps) => {
  const { act } = useBackend<AutolatheData>();
  const {
    design,
    quantity,
    availableMaterials,
    SHEET_MATERIAL_AMOUNT,
    maxmult,
  } = props;

  const canPrint = maxmult >= quantity;
  return (
    <Tooltip
      content={
        <MaterialCostSequence
          design={design}
          amount={quantity}
          SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
          available={availableMaterials}
        />
      }
    >
      <div
        className={classes([
          'FabricatorRecipe__Button',
          !canPrint && 'FabricatorRecipe__Button--disabled',
        ])}
        color={'transparent'}
        onClick={() =>
          canPrint && act('make', { id: design.id, multiplier: quantity })
        }
      >
        &times;{quantity}
      </div>
    </Tooltip>
  );
};

type AutolatheRecipeProps = {
  design: AutolatheDesign;
  availableMaterials: MaterialMap;
  SHEET_MATERIAL_AMOUNT: number;
};

const AutolatheRecipe = (props: AutolatheRecipeProps) => {
  const { act } = useBackend<AutolatheData>();
  const { design, availableMaterials, SHEET_MATERIAL_AMOUNT } = props;

  let maxmult = 0;
  if (design.customMaterials) {
    const largest_mat =
      Object.entries(availableMaterials).reduce(
        (accumulator: number, [material, amount]) => {
          return Math.max(accumulator, amount);
        },
        0,
      ) || 0;

    if (largest_mat > 0) {
      maxmult = Object.entries(design.cost).reduce(
        (accumulator: number, [material, required]) => {
          return Math.min(accumulator, largest_mat / required);
        },
        Infinity,
      );
    } else {
      maxmult = 0;
    }
  } else {
    maxmult = Object.entries(design.cost).reduce(
      (accumulator: number, [material, required]) => {
        return Math.min(
          accumulator,
          (availableMaterials[material] || 0) / required,
        );
      },
      Infinity,
    );
  }
  maxmult = Math.min(Math.floor(maxmult), 50);
  const canPrint = maxmult > 0;

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
            available={availableMaterials}
          />
        }
      >
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() =>
            canPrint && act('make', { id: design.id, multiplier: 1 })
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
        SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
        availableMaterials={availableMaterials}
        maxmult={maxmult}
      />

      <PrintButton
        design={design}
        quantity={10}
        SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
        availableMaterials={availableMaterials}
        maxmult={maxmult}
      />

      <div
        className={classes([
          'FabricatorRecipe__Button',
          !canPrint && 'FabricatorRecipe__Button--disabled',
        ])}
      >
        <Button.Input
          color="transparent"
          buttonText={`[Max: ${maxmult}]`}
          onCommit={(value) =>
            act('make', {
              id: design.id,
              multiplier: value,
            })
          }
        />
      </div>
    </div>
  );
};
