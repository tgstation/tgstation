import { sortBy } from 'common/collections';
import { useState } from 'react';
import { AnimatedNumber, Button, Flex } from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { classes } from 'tgui-core/react';

import { MaterialIcon } from './MaterialIcon';
import { Material } from './Types';

// by popular demand of discord people (who are always right and never wrong)
// this is completely made up
const MATERIAL_RARITY: Record<string, number> = {
  glass: 0,
  iron: 1,
  plastic: 2,
  titanium: 3,
  plasma: 4,
  silver: 5,
  gold: 6,
  uranium: 7,
  diamond: 8,
  'bluespace crystal': 9,
  bananium: 10,
};

export type MaterialAccessBarProps = {
  /**
   * All materials currently available to the user.
   */
  availableMaterials: Material[];

  /**
   * Definition of how much units 1 sheet has.
   */
  SHEET_MATERIAL_AMOUNT: number;

  /**
   * Invoked when the user requests that a material be ejected.
   */
  onEjectRequested?: (material: Material, quantity: number) => void;
};

/**
 * The formatting function applied to the quantity labels in the bar.
 */
const LABEL_FORMAT = (value: number) => formatSiUnit(value, 0);

/**
 * A bottom-docked bar for viewing and ejecting materials from local storage or
 * the ore silo. Has pop-out docks for each material type for ejecting up to
 * fifty sheets.
 */
export const MaterialAccessBar = (props: MaterialAccessBarProps) => {
  const { availableMaterials, SHEET_MATERIAL_AMOUNT, onEjectRequested } = props;

  return (
    <Flex wrap>
      {sortBy(availableMaterials, (m: Material) => MATERIAL_RARITY[m.name]).map(
        (material) => (
          <Flex.Item grow basis={4.5} key={material.name}>
            <MaterialCounter
              material={material}
              SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
              onEjectRequested={(quantity) =>
                onEjectRequested && onEjectRequested(material, quantity)
              }
            />
          </Flex.Item>
        ),
      )}
    </Flex>
  );
};

type MaterialCounterProps = {
  material: Material;
  SHEET_MATERIAL_AMOUNT: number;
  onEjectRequested: (quantity: number) => void;
};

const MaterialCounter = (props: MaterialCounterProps) => {
  const { material, onEjectRequested, SHEET_MATERIAL_AMOUNT } = props;

  const [hovering, setHovering] = useState(false);

  const sheets = material.amount / SHEET_MATERIAL_AMOUNT;

  return (
    <div
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      className={classes([
        'MaterialDock',
        hovering && 'MaterialDock--active',
        sheets < 1 && 'MaterialDock--disabled',
      ])}
    >
      <Flex direction="column-reverse">
        <Flex
          direction="column"
          textAlign="center"
          onClick={() => onEjectRequested(1)}
          className="MaterialDock__Label"
        >
          <Flex.Item>
            <MaterialIcon materialName={material.name} sheets={sheets} />
          </Flex.Item>
          <Flex.Item>
            <AnimatedNumber value={sheets} format={LABEL_FORMAT} />
          </Flex.Item>
        </Flex>
        {hovering && (
          <div className={'MaterialDock__Dock'}>
            <Flex vertical direction={'column-reverse'}>
              <EjectButton
                sheets={sheets}
                amount={5}
                onEject={onEjectRequested}
              />
              <EjectButton
                sheets={sheets}
                amount={10}
                onEject={onEjectRequested}
              />
              <EjectButton
                sheets={sheets}
                amount={25}
                onEject={onEjectRequested}
              />
              <EjectButton
                sheets={sheets}
                amount={50}
                onEject={onEjectRequested}
              />
            </Flex>
          </div>
        )}
      </Flex>
    </div>
  );
};

type EjectButtonProps = {
  amount: number;
  sheets: number;
  onEject: (quantity: number) => void;
};

const EjectButton = (props: EjectButtonProps) => {
  const { amount, sheets, onEject } = props;

  return (
    <Button
      fluid
      color={'transparent'}
      className={classes([
        'Fabricator__PrintAmount',
        amount > sheets && 'Fabricator__PrintAmount--disabled',
      ])}
      onClick={() => onEject(amount)}
    >
      &times;{amount}
    </Button>
  );
};
