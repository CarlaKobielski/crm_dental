const nextJest = require("next/jest")

const createJestConfig = nextJest({
  dir: "./",
})

const customJestConfig = {
  setupFilesAfterEnv: ["<rootDir>/jest.setup.js"],
  testEnvironment: "jest-environment-jsdom",
  moduleNameMapper: {
    "^@/components/(.*)$": "<rootDir>/components/$1",
    "^@/lib/(.*)$": "<rootDir>/lib/$1",
  },
  testMatch: ["<rootDir>/__tests__/**/*.test.{js,jsx,ts,tsx}", "<rootDir>/__tests__/mobile/**/*.test.{js,jsx,ts,tsx}"],
}

module.exports = createJestConfig(customJestConfig)

