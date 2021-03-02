## Jest

You can now write and run unit tests in tgui.

It's quite simple: create a file ending in `.test.ts` or `.spec.ts` (usually with the same filename as the file you're testing), and create a test case:

```js
test('something', () => {
  expect('a').toBe('a');
});
```

To run the tests, type the following into the terminal:

```
bin/tgui --test
```

There is an example test in `packages/common/react.spec.ts`.

You can read more about Jest here: https://jestjs.io/docs/en/getting-started

Note, that there is still no real solution to test UIs for now, even though a lot of the support is here (jest + jsdom). That will come later.
