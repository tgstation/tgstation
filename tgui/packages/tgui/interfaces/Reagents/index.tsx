import { useState } from 'react';
import { Section, Stack } from 'tgui-core/components';

import { Window } from '../../layouts';
import { Lookup } from './Lookup';
import { RecipeLibrary } from './RecipeLibrary';
import { TagBox } from './TagBox';
import { Reaction } from './types';

export const bookmarkedReactions = new Set<Reaction>();

export function Reagents(props) {
  const pageState = useState(1);

  return (
    <Window width={720} height={850}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Lookup />
          </Stack.Item>
          <Stack.Item>
            <Section title="Tags">
              <TagBox pageState={pageState} />
            </Section>
          </Stack.Item>
          <Stack.Item grow={2} basis={0}>
            <RecipeLibrary pageState={pageState} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
