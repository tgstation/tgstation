import { Section, Stack } from '../../components';
import { CargoCartButtons } from './CargoButtons';

export function CartHeader(props) {
  return (
    <Section>
      <Stack>
        <Stack.Item mt="4px">Current-Cart</Stack.Item>
        <Stack.Item ml="200px" mt="3px">
          Quantity
        </Stack.Item>
        <Stack.Item ml="72px">
          <CargoCartButtons />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
