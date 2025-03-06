import { Button, LabeledList, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ColorItem } from './RapidPipeDispenser';

type Data = {
  has_cap: BooleanLike;
  can_change_colour: BooleanLike;
  drawables: Drawable[];
  is_capped: BooleanLike;
  selected_stencil: string;
  is_literate_user: BooleanLike;
  text_buffer: string;
};

type Drawable = {
  items: { item: string }[];
  name: string;
};

export const Crayon = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    has_cap,
    can_change_colour,
    drawables = [],
    is_capped,
    selected_stencil,
    is_literate_user,
    text_buffer,
  } = data;
  const capOrChanges = has_cap || can_change_colour;

  return (
    <Window width={600} height={600}>
      <Window.Content scrollable>
        {!!capOrChanges && (
          <Section title="Basic">
            <LabeledList>
              <LabeledList.Item label="Cap">
                <Button
                  icon={is_capped ? 'power-off' : 'times'}
                  content={is_capped ? 'On' : 'Off'}
                  selected={is_capped}
                  onClick={() => act('toggle_cap')}
                />
              </LabeledList.Item>
              <ColorItem />
              <LabeledList.Item>
                <Button
                  content="Custom color"
                  onClick={() => act('custom_color')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
        <Section title="Stencil">
          <LabeledList>
            {drawables.map((drawable) => {
              const items = drawable.items || [];
              return (
                <LabeledList.Item key={drawable.name} label={drawable.name}>
                  {items.map((item) => (
                    <Button
                      key={item.item}
                      content={item.item}
                      selected={item.item === selected_stencil}
                      onClick={() =>
                        act('select_stencil', {
                          item: item.item,
                        })
                      }
                    />
                  ))}
                </LabeledList.Item>
              );
            })}
          </LabeledList>
        </Section>
        {!!is_literate_user && (
          <Section title="Text">
            <LabeledList>
              <LabeledList.Item label="Current Buffer">
                {text_buffer}
              </LabeledList.Item>
            </LabeledList>
            <Button content="New Text" onClick={() => act('enter_text')} />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
