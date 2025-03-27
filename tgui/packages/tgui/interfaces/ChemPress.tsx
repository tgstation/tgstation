import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Product = {
  ref: string;
  class_name: string;
};

type Category = {
  cat_name: string;
  products: Product[];
};

type Data = {
  current_volume: number;
  product_name: string;
  min_volume: number;
  max_volume: number;
  packaging_category: string;
  packaging_types: Category[];
  packaging_type: string;
};

export const ChemPress = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    current_volume,
    product_name,
    min_volume,
    max_volume,
    packaging_category,
    packaging_types,
    packaging_type,
  } = data;
  const [categoryName, setCategoryName] = useState(packaging_category);
  const shownCategory =
    packaging_types.find((category) => category.cat_name === categoryName) ||
    packaging_types[0];
  return (
    <Window width={300} height={330}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Product">
              {packaging_types.map((category, i) => (
                <Button.Checkbox
                  key={category.cat_name}
                  content={capitalizeAll(category.cat_name)}
                  checked={category.cat_name === shownCategory.cat_name}
                  onClick={() => setCategoryName(category.cat_name)}
                />
              ))}
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
                onChange={(value) =>
                  act('change_current_volume', {
                    volume: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Name">
              <Input
                value={product_name}
                placeholder={product_name}
                onChange={(e, value) =>
                  act('change_product_name', {
                    name: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Styles">
              {shownCategory.products.map((design, j) => (
                <Button
                  key={j}
                  selected={design.ref === packaging_type}
                  color="transparent"
                  onClick={() =>
                    act('change_product', {
                      ref: design.ref,
                    })
                  }
                >
                  <Box
                    className={design.class_name}
                    style={{
                      transform: 'scale(1.5)',
                    }}
                  />
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
