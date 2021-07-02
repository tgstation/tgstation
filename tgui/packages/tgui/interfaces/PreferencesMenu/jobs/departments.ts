export type Department = {
  color: string;
  head?: string;
};

export const Assistant: Department = {
  color: "white",

  // "Assistant" is not the head of its own department, as otherwise
  // it would show as large and bold.
};

export const Captain: Department = {
  color: "blue",
  head: "Captain",
};

export const Cargo: Department = {
  color: "brown",
  head: "Quartermaster",
};

export const Engineering: Department = {
  color: "yellow",
  head: "Chief Engineer",
};

export const Medical: Department = {
  color: "teal",
  head: "Chief Medical Officer",
};

export const Security: Department = {
  color: "red",
  head: "Head of Security",
};

export const Service: Department = {
  color: "olive",
  head: "Head of Personnel",
};

export const Science: Department = {
  color: "violet",
  head: "Research Director",
};

export const Silicon: Department = {
  color: "grey",
  head: "AI",
};
