# TypeScript notes

[TypeScript Tutorial](https://www.w3schools.com/typescript/index.php)
[TypeScript: Documentation - TypeScript for JavaScript Programmers](https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes.html)

## 基本用法

```ts
function add(x: number, y: number): number {
    return x + y
}

console.log(add(1, 2))
```

## Configuring the compiler

```sh
# install the compiler
npm install typescript --save-dev
# The compiler is installed in the node_modules directory and can be run with:
npx tsc
# Version 4.5.5
# tsc: The TypeScript Compiler - Version 4.5.5

# create tsconfig.json with the recommended settings with:
npx tsc --init
```
