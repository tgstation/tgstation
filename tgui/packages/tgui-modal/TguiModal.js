import { Section, Input } from 'tgui/components';
import { Window } from './components';

export const TguiModal = (props) => {
  return (
    <Window>
      <Window.Content>
        <Section fill>
          <Input autoFocus fluid />
        </Section>
      </Window.Content>
    </Window>
  );
};
