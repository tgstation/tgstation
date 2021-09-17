export type Department = {
  head?: string;
};

export const Assistant: Department = {
  // "Assistant" is not the head of its own department, as otherwise
  // it would show as large and bold.
};

export const Captain: Department = {
  head: "Captain",
};

export const Cargo: Department = {
  head: "Quartermaster",
};

export const Engineering: Department = {
  head: "Chief Engineer",
};

export const Medical: Department = {
  head: "Chief Medical Officer",
};

export const Security: Department = {
  head: "Head of Security",
};

export const Service: Department = {
  head: "Head of Personnel",
};

export const Science: Department = {
  head: "Research Director",
};

export const Silicon: Department = {
  head: "AI",
};
