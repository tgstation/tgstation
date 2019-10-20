import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section } from '../components';

export const Crayon = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const capOrChanges = data.has_cap || data.can_change_colour;
  const drawables = data.drawables || [];
  return (
    <Fragment>
      {!!capOrChanges && (
        <Section title="Basic">
          <LabeledList>
            <LabeledList.Item label="Cap">
              <Button
                icon={data.is_capped ? 'power-off' : 'times'}
                content={data.is_capped ? 'On' : 'Off'}
                selected={data.is_capped}
                onClick={() => act(ref, 'toggle_cap')} />
            </LabeledList.Item>
          </LabeledList>
          <Button
            content="Select New Color"
            onClick={() => act(ref, 'select_colour')} />
        </Section>
      )}
      <Section title="Stencil">
        <LabeledList>
          {drawables.map(drawable => {
            const items = drawable.items || [];
            return (
              <LabeledList.Item
                key={drawable.name}
                label={drawable.name}>
                {items.map(item => (
                  <Button
                    key={item.item}
                    content={item.item}
                    selected={item.item === data.selected_stencil}
                    onClick={() => act(ref, 'select_stencil', {
                      item: item.item,
                    })} />
                ))}
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Section>
      <Section title="Text">
        <LabeledList>
          <LabeledList.Item label="Current Buffer">
            {data.text_buffer}
          </LabeledList.Item>
        </LabeledList>
        <Button
          content="New Text"
          onClick={() => act(ref, 'enter_text')} />
      </Section>
    </Fragment>
  );
};
