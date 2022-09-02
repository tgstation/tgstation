import { sortBy } from 'common/collections';
import { Stack, Section, Tabs } from '../../components';

/**
 * A single category in a category tab list.
 */
export interface Category {
  /**
   * The human-readable name of this category.
   */
  displayName?: string;

  /**
   * The key used to identify this category.
   */
  key: string;
}

/**
 * The properties of a category tab list.
 */
export interface CategoryTabsProps {
  /**
   * The current key of the selected category.
   */
  currentCategory: string;

  /**
   * The categories in this list.
   */
  categories: Category[];

  /**
   * Invoked with a category's key when a new category is selected.
   */
  onCategorySelected?: (newCategory: string) => void;
}

/**
 * A tab list used for category selection.
 */
export const CategoryTabs = (props: CategoryTabsProps, context) => {
  const {
    currentCategory,
    categories,
    onCategorySelected: setCategory,
  } = props;

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <Section title="Categories" fitted />
        </Stack.Item>
        <Stack.Item grow>
          <Section fill style={{ 'overflow': 'auto' }}>
            <Tabs vertical>
              {sortBy((c: Category) => c.displayName || c.key)(categories).map(
                (descriptor) => (
                  <Tabs.Tab
                    key={descriptor.key}
                    selected={currentCategory === descriptor.key}
                    onClick={() => {
                      currentCategory !== descriptor.key &&
                        setCategory &&
                        setCategory(descriptor.key);
                    }}
                    fluid
                    color="transparent">
                    {descriptor.displayName || descriptor.key}
                  </Tabs.Tab>
                )
              )}
            </Tabs>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
