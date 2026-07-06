import { ImageButton, LabeledList, Section, Stack } from 'tgui-core/components';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Design = {
  name: string;
  icon: string;
};

type Category = {
  cat_name: string;
  designs: Design[];
};

type Data = {
  selected_category: string;
  selected_design: string;
  categories: Category[];
  matter: number;
  max_matter: number;
};

const DecorationCard = (props: {
  design: Design;
  selected: boolean;
  onClick: () => void;
}) => {
  const { design, selected, onClick } = props;

  return (
    <ImageButton
      selected={selected}
      color={'transparent'}
      tooltip={capitalizeAll(design.name)}
      tooltipPosition="bottom"
      imageSize={32}
      asset={['rdd32x32', design.icon]}
      onClick={onClick}
    />
  );
};

export const RapidDecorationDevice = () => {
  const { act, data } = useBackend<Data>();
  const {
    categories = [],
    selected_category,
    selected_design,
    matter,
    max_matter,
  } = data;

  return (
    <Window width={470} height={580}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Units Left">
                  {matter}/{max_matter} Units
                </LabeledList.Item>
                <LabeledList.Item label="Selected">
                  {selected_design ? capitalizeAll(selected_design) : 'None'}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section scrollable fill>
              {categories.map((category) => (
                <Section key={category.cat_name}>
                  <Stack wrap>
                    {category.designs.map((design) => (
                      <Stack.Item key={design.name}>
                        <DecorationCard
                          design={design}
                          selected={
                            design.name === selected_design &&
                            category.cat_name === selected_category
                          }
                          onClick={() =>
                            act('design', {
                              category: category.cat_name,
                              name: design.name,
                            })
                          }
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
