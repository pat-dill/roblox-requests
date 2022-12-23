
export const startsWith = (text: string, val: string): boolean => text.sub(1, val.size()) === val;

export const endsWith = (text: string, val: string): boolean => text.sub(-val.size(), -1) === val;