import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const ChemPress = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    current_volume,
    product_name,
    pill_style,
    pill_styles = [],
    product,
    min_volume,
    max_volume,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Product">
              <Button.Checkbox
                content="Pills"
                checked={product === "pill"}
                onClick={() => act('change_product', {
                  product: "pill",
                })}
              />
              <Button.Checkbox
                content="Patches"
                checked={product === "patch"}
                onClick={() => act('change_product', {
                  product: "patch",
                })}
              />
              <Button.Checkbox
                content="Bottles"
                checked={product === "bottle"}
                onClick={() => act('change_product', {
                  product: "bottle",
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Volume">
              <NumberInput
                value={current_volume}
                unit="u"
                width="43px"
                minValue={min_volume}
                maxValue={max_volume}
                step={1}
                stepPixelSize={2}
                onChange={(e, value) => act('change_current_volume', {
                  volume: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Name">
              <Input
                value={product_name}
                placeholder={product_name}
                onChange={(e, value) => act('change_product_name', {
                  name: value,
                })} />
              <Box as="span">
                {product}
              </Box>
            </LabeledList.Item>
            {product === "pill" && (
              <LabeledList.Item label="Style">
                {pill_styles.map(pill => (
                  <Button
                    key={pill.id}
                    width="30px"
                    selected={pill.id === pill_style}
                    textAlign="center"
                    color="transparent"
                    onClick={() => act('change_pill_style', {
                      id: pill.id,
                    })}>
                    <Box mx={-1} className={pill.class_name} />
                  </Button>
                ))}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
