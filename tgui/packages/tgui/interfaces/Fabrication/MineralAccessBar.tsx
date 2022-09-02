import { sortBy } from 'common/collections';
import { useLocalState } from '../../backend';
import { Flex, Button, Stack } from '../../components';
import { Material, MaterialIcon } from '../common/Materials';
import { AnimatedQuantityLabel } from './AnimatedQuantityLabel';
import { MaterialName } from './Types';

// by popular demand of discord people (who are always right and never wrong)
// this is completely made up
const MINERAL_RARITY: Record<MaterialName, number> = {
  'iron': 1,
  'glass': 0,
  'silver': 5,
  'gold': 6,
  'diamond': 8,
  'plasma': 4,
  'uranium': 7,
  'bananium': 10,
  'titanium': 3,
  'bluespace crystal': 9,
  'plastic': 2,
};

export interface MineralAccessBarProps {
  /**
   * All materials currently available to the user.
   */
  availableMaterials: Material[];

  /**
   * Invoked when the user requests that a material be ejected.
   */
  onEjectRequested?: (material: Material, quantity: number) => void;
}

/**
 * A bottom-docked bar for viewing and ejecting materials from local storage or
 * the ore silo. Has pop-out docks for each material type for ejecting up to
 * fifty sheets.
 */
export const MineralAccessBar = (props: MineralAccessBarProps, context) => {
  const { availableMaterials, onEjectRequested } = props;

  return (
    <Flex wrap>
      {sortBy((m: Material) => MINERAL_RARITY[m.name])(availableMaterials).map(
        (material) => (
          <Flex.Item key={material.name} grow={1} shrink={1}>
            <MineralCounter
              material={material}
              onEjectRequested={(quantity) =>
                onEjectRequested && onEjectRequested(material, quantity)
              }
            />
          </Flex.Item>
        )
      )}
    </Flex>
  );
};

interface MineralCounterProps {
  material: Material;
  onEjectRequested: (quantity: number) => void;
}

const MineralCounter = (props: MineralCounterProps, context) => {
  const { material, onEjectRequested } = props;

  const [hovering, setHovering] = useLocalState(
    context,
    `MaterialCounter__${material.name}`,
    false
  );

  return (
    <div
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      className={`MaterialDock ${hovering ? 'MaterialDock--active' : ''}`}>
      <Stack vertial direction={'column-reverse'}>
        <Flex
          direction="column"
          textAlign="center"
          onClick={() => onEjectRequested(1)}>
          <Flex.Item>
            <MaterialIcon material={material.name} />
          </Flex.Item>
          <Flex.Item>
            <AnimatedQuantityLabel targetValue={material.amount} />
          </Flex.Item>
        </Flex>
        {hovering && (
          <div className={'MaterialDock__Dock'}>
            <Flex vertical direction={'column-reverse'}>
              <EjectButton
                material={material}
                available={material.amount}
                amount={5}
                onEject={onEjectRequested}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={10}
                onEject={onEjectRequested}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={25}
                onEject={onEjectRequested}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={50}
                onEject={onEjectRequested}
              />
            </Flex>
          </div>
        )}
      </Stack>
    </div>
  );
};

interface EjectButtonProps {
  material: Material;
  available: number;
  amount: number;
  onEject: (quantity: number) => void;
}

const EjectButton = (props: EjectButtonProps, context) => {
  const { amount, available, material, onEject } = props;

  return (
    <Button
      fluid
      color={'transparent'}
      className={`Fabricator__PrintAmount ${
        amount * 2_000 > available ? 'Fabricator__PrintAmount--disabled' : ''
      }`}
      onClick={() => onEject(amount)}>
      &times;{amount}
    </Button>
  );
};
