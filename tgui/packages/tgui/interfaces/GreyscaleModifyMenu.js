import { useBackend } from '../backend';
import { Button, Icon, Input, LabeledList, Section } from '../components';
import { Window } from '../layouts';

const ColorDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const colors = (data.colors || []);
  return (
    <Section title='Colors'>
      <LabeledList>
        <LabeledList.Item
          key='fullstring'
          label='Full Color String'>
          <Input
            value={colors.map(item => item.value).join('')}
            onChange={(_, value) => act("recolor_from_string", {color_string: value})}
          />
        </LabeledList.Item>
        {colors.map(item => (
          <LabeledList.Item
            key={item.index}
            label={`Color Group ${item.index}`}
            color={item.value}>
            ■ <Button
              content={<Icon name='palette'/>}
              onClick={() => act("pick_color", {color_index: item.index})}
            />
            <Input
              value={item.value}
              onChange={(_, value) => act("recolor", {color_index: item.index, new_color: value})}
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

export const GreyscaleModifyMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    previewId,
    colors
  } = data;
  return (
    <Window title="Greyscale Modification">
      <Window.Content>
        <ColorDisplay/>
        <Button
          content='Refresh Icon File'
          onClick={() => act("refresh_file")}
        /><br/>
        <Button
          content='Apply'
          onClick={() => act("apply")}
        />
      </Window.Content>
    </Window>
  );
};
