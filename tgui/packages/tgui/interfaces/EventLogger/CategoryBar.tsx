import { Box, Button, Stack } from 'tgui-core/components';

import type { Category } from './types';

export type CategoryBarProps = {
  categories: Category[];
  colors: Record<string, string>;
  act: (action: string, params?: object) => void;
};

export function CategoryBar(props: CategoryBarProps) {
  const { categories, colors, act } = props;
  if (!categories.length) {
    return (
      <Box p={0.5} color="label" italic>
        No categories logged yet.
      </Box>
    );
  }
  return (
    <Stack wrap p={0.5}>
      {categories.map((cat) => (
        <Stack.Item key={cat.name}>
          <Button
            selected={cat.enabled}
            style={{ borderLeft: `4px solid ${colors[cat.name] || '#888'}` }}
            onClick={() => act('toggle_category', { name: cat.name })}
          >
            {cat.name}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}
