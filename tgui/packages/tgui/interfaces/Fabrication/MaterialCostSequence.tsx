import { Flex } from '../../components';
import { Design, MaterialMap } from './Types';
import { MaterialIcon } from './MaterialIcon';
import { formatSiUnit } from '../../format';

export type MaterialCostSequenceProps = {
  available?: MaterialMap;
  costMap?: MaterialMap;
  design?: Design;
  amount?: number;
  align?: string;
  justify?: string;
};

export const MaterialCostSequence = (
  props: MaterialCostSequenceProps,
  context
) => {
  let { design, amount, costMap, available, align, justify } = props;

  if (!costMap && !design) {
    return null;
  }

  costMap ??= {};

  if (design) {
    for (const [name, value] of Object.entries(design.cost)) {
      costMap[name] = (costMap[name] || 0) + value;
    }
  }

  return (
    <Flex wrap justify={justify ?? 'space-around'} align={align ?? 'center'}>
      {Object.entries(costMap).map(([material, quantity]) => (
        <Flex.Item key={material} style={{ 'padding': '0.25em' }}>
          <Flex direction={'column'} align="center">
            <Flex.Item>
              <MaterialIcon
                materialName={material}
                amount={(amount || 1) * quantity}
              />
            </Flex.Item>
            <Flex.Item
              style={
                available && {
                  color:
                    (amount || 1) * quantity * 2 <= available[material]
                      ? '#fff'
                      : (amount || 1) * quantity <= available[material]
                        ? '#f08f11'
                        : '#db2828',
                }
              }>
              {formatSiUnit((amount || 1) * quantity, 0)}
            </Flex.Item>
          </Flex>
        </Flex.Item>
      ))}
    </Flex>
  );
};
