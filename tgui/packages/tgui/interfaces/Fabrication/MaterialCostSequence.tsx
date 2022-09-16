import { Flex } from '../../components';
import { Design, MaterialMap } from './Types';
import { MaterialIcon } from './MaterialIcon';
import { formatSiUnit } from '../../format';

export type MaterialCostSequenceProps = {
  design: Design;
  amount: number;
  available: MaterialMap;
};

export const MaterialCostSequence = (
  props: MaterialCostSequenceProps,
  context
) => {
  const { design, amount, available } = props;

  return (
    <Flex wrap justify="space-around" align="center">
      {Object.entries(design.cost).map(([material, quantity]) => (
        <Flex.Item key={material} style={{ 'padding': '0.25em' }}>
          <Flex direction={'column'} align="center">
            <Flex.Item>
              <MaterialIcon
                materialName={material}
                amount={amount * quantity}
              />
            </Flex.Item>
            <Flex.Item
              style={{
                color:
                  amount * quantity * 2 < available[material]
                    ? '#fff'
                    : amount * quantity < available['material']
                      ? '#f08f11'
                      : '#db2828',
              }}>
              {formatSiUnit(amount * quantity, 0)}
            </Flex.Item>
          </Flex>
        </Flex.Item>
      ))}
    </Flex>
  );
};
