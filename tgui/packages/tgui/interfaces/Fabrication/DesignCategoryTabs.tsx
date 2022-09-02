import { CategoryTabs } from './CategoryTabs';
import { Design } from './Types';

/**
 * A dummy category that, when selected, renders ALL recipes to the UI.
 */
export const ALL_CATEGORY = '__ALL';

/**
 * Categories present in this object are not rendered to the final fabricator
 * UI.
 */
const BLACKLISTED_CATEGORIES: Record<string, boolean> = {
  'initial': true,
  'core': true,
  'hacked': true,
};

export interface DesignCategoryTabsProps {
  /**
   * The designs to generate categories from.
   */
  designs: Design[];

  /**
   * The currently selected category.
   */
  currentCategory: string;

  /**
   * Invoked when the user selects a new category.
   */
  onCategorySelected?: (newCategory: string) => void;
}

/**
 * A list of tabs generated on the fly from a number of techfab designs.
 */
export const DesignCategoryTabs = (props: DesignCategoryTabsProps, context) => {
  const { designs, currentCategory, onCategorySelected } = props;

  // Find the number of items in each unique category, and the sum total of all
  // printable items.
  const categoryCounts: Record<string, number> = {};
  let totalRecipes = 0;

  for (const design of designs) {
    totalRecipes += 1;

    for (const category of design.categories ?? []) {
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
  }

  // Strip blacklisted categories from the output.
  for (const blacklistedCategory in BLACKLISTED_CATEGORIES) {
    delete categoryCounts[blacklistedCategory];
  }

  const categories = Object.entries(categoryCounts).map(([name, count]) => ({
    key: name,
    displayName: `${name} (${count})`,
  }));

  categories.unshift({
    key: ALL_CATEGORY,
    displayName: `All Recipes (${totalRecipes})`,
  });

  return (
    <CategoryTabs
      currentCategory={currentCategory}
      onCategorySelected={onCategorySelected}
      categories={categories}
    />
  );
};
