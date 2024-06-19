# Managing component state

React has excellent documentation on useState and useEffect. These hooks should be the ways to manage state in TGUI (v5).
[React Hooks](https://react.dev/learn/state-a-components-memory)

You might find usages of useLocalState. This should be considered deprecated and will be removed in the future. In older versions of TGUI, InfernoJS did not have hooks, so these were used to manage state. useSharedState is still used in some places where uis are considered "IC" and user input is shared with all persons at the console/machine/thing.

## A Note on State

Many beginners tend to overuse state (or hooks all together). State is effective when you want to implement user interactivity, or are handling asynchronous data, but if you are simply using state to store a value that is not changing, you should consider using a variable instead.

In previous versions of React, each setState would trigger a re-render, which would cause poorly written components to cascade re-render on each page load. Messy! Though this is no longer the case with batch rendering, it's still worthwhile to point out that you might be overusing it.

## Derived state

One great way to cut back on state usage is by using props or other state as the basis for a variable. You'll see many examples of this in the TGUI codebase. What does this mean? Here's an example:

```tsx
// Bad
const [count, setCount] = useState(0);
const [isEven, setIsEven] = useState(false);

useEffect(() => {
  setIsEven(count % 2 === 0);
}, [count]);

// Good!
const [count, setCount] = useState(0);
const isEven = count % 2 === 0; // Derived state
```
