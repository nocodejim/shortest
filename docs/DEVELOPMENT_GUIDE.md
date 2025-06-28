# Shortest Development Guide

Welcome to the Shortest development guide! This document provides comprehensive instructions for setting up your development environment, running the application, writing and running tests, and contributing to the project.

## Table of Contents

- [Project Setup](#project-setup)
- [Environment Configuration](#environment-configuration)
- [Running the Web App Locally](#running-the-web-app-locally)
- [CLI Development](#cli-development)
- [Writing Tests with Shortest](#writing-tests-with-shortest)
- [Running Tests](#running-tests)
- [Local Development with Docker](#local-development-with-docker)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)

---

## Project Setup

This section guides you through the initial setup of the Shortest project on your local machine.

### Prerequisites

Before you begin, ensure you have the following installed:

*   **Node.js**: Shortest is a Node.js project. We recommend using the latest LTS version. You can download it from [nodejs.org](https://nodejs.org/).
*   **pnpm**: We use pnpm for package management. If you don't have it, install it globally via npm:
    ```bash
    npm install -g pnpm
    ```

### Cloning the Repository

1.  Clone the Shortest repository from GitHub:
    ```bash
    git clone https://github.com/antiwork/shortest.git
    ```
2.  Navigate into the cloned directory:
    ```bash
    cd shortest
    ```

### Installing Dependencies

Once you have cloned the repository and navigated into the project directory, install the project dependencies using pnpm:

```bash
pnpm install
```

This command will install all necessary packages defined in the `package.json` and `pnpm-lock.yaml` files, setting up both the main application and the `packages/shortest` CLI tool.

---

## Environment Configuration

Proper environment configuration is crucial for running the Shortest application and its testing framework. Environment variables are managed using a `.env.local` file at the root of the project.

### Creating `.env.local`

1.  Copy the example environment file:
    ```bash
    cp .env.example .env.local
    ```
2.  Alternatively, for a guided setup, especially for the web application's external services, run:
    ```bash
    pnpm run setup
    ```
    This script will help you configure necessary environment variables by asking a series of questions.

### Core Environment Variables (Essential for CLI & Testing)

These variables are fundamental for using the Shortest CLI and running tests:

*   `ANTHROPIC_API_KEY`: Your API key for Anthropic Claude, used by the AI to understand and execute natural language tests.
    *   _Obtain from your [Anthropic dashboard](https://anthropic.com)._
*   `GITHUB_TOTP_SECRET`: (Optional) Your Time-based One-Time Password (TOTP) secret for GitHub if you are testing functionalities that involve GitHub 2FA.
    *   _See the "GitHub 2FA login setup" section in the main README for details on how to obtain this._

You must fill in `ANTHROPIC_API_KEY` in your `.env.local` file to run any tests.

### Web Application Environment Variables (For Full Web App Development)

If you intend to develop or run the full Shortest web application locally (the dashboard, user management, etc.), you'll need to configure additional services. The `pnpm run setup` script is the recommended way to configure these. If you configure them manually, refer to the detailed instructions in the main `README.md` under the "Services configuration" section.

These services include:

*   **Clerk**: For user authentication.
    *   `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
    *   `CLERK_SECRET_KEY`
    *   `NEXT_PUBLIC_CLERK_SIGN_IN_URL`
    *   `NEXT_PUBLIC_CLERK_SIGN_UP_URL`
    *   `NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL`
    *   `NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL`
*   **Vercel Postgres**: For the database.
    *   `POSTGRES_URL`
    *   `POSTGRES_PRISMA_URL`
    *   `POSTGRES_URL_NO_SSL`
    *   `POSTGRES_URL_NON_POOLING`
    *   `POSTGRES_USER`
    *   `POSTGRES_HOST`
    *   `POSTGRES_PASSWORD`
    *   `POSTGRES_DATABASE`
*   **Stripe**: For payment processing (if testing related features).
    *   `STRIPE_SECRET_KEY`
    *   `STRIPE_WEBHOOK_SECRET`
    *   `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
*   **GitHub OAuth**: For Clerk integration with GitHub.
    *   `AUTH_GITHUB_ID`
    *   `AUTH_GITHUB_SECRET`
*   **Mailosaur**: For email testing during authentication flows.
    *   `MAILOSAUR_API_KEY`
    *   `MAILOSAUR_SERVER_ID`

**Note**: For basic CLI usage and test writing/execution against external sites, only `ANTHROPIC_API_KEY` is strictly required. The other variables are for running the Shortest web platform itself.

---

## Running the Web App Locally

If you have configured the necessary environment variables for the web application (see "Web Application Environment Variables" under the Environment Configuration section), you can run the Shortest web app locally.

The web app includes features like a dashboard, user management, and integration with services like Stripe and Clerk.

To start the local development server:

```bash
pnpm dev
```

This command starts the Next.js development server. By default, the application will be accessible at:

[http://localhost:3000](http://localhost:3000)

Open this URL in your browser to see the app in action. Any changes you make to the frontend code (primarily in the `app/` and `components/` directories) should be reflected live in the browser.

### Database Setup (If running the web app)

If you are running the web app and have configured Vercel Postgres, you may need to set up the database schema and seed initial data:

1.  **Generate Migrations (if you've made schema changes)**:
    ```bash
    pnpm drizzle-kit generate
    ```
2.  **Apply Migrations**:
    ```bash
    pnpm db:migrate
    ```
3.  **Seed Database (optional, creates Stripe products, etc.)**:
    ```bash
    pnpm db:seed
    ```

These steps ensure your local database schema is up-to-date.

---

## CLI Development

The Shortest CLI (Command Line Interface) is the core tool for writing, running, and managing your natural language tests. The CLI package is located in `packages/shortest/`.

### Linking the CLI for Local Development

To test changes to the CLI locally as you develop, you should link your local version of the `shortest` package globally. This allows you to run `shortest` commands from anywhere on your system, using your development code.

1.  Navigate to the CLI package directory:
    ```bash
    cd packages/shortest
    ```
2.  Link the package:
    ```bash
    pnpm link --global
    ```
3.  Navigate back to the project root (or any other directory where you might have a test project):
    ```bash
    cd ../..
    ```
4.  (If you are in the main `shortest` project root) Link the global package to the project's local dependencies (optional but good practice if you have scripts in the root `package.json` that use `shortest`):
    ```bash
    pnpm link --global shortest
    ```

Now, when you run `shortest` in your terminal, it will use the code from your `packages/shortest/` directory.

### Building the CLI

To compile the TypeScript code and produce the executable JavaScript files for the CLI:

1.  Ensure you are in the `packages/shortest/` directory or run pnpm with the `--filter` flag from the root:
    ```bash
    pnpm --filter @antiwork/shortest build
    ```
    Or, if you are inside `packages/shortest/`:
    ```bash
    pnpm build
    ```

This typically transpiles TypeScript to JavaScript and places the output in a `dist` or `build` folder within `packages/shortest/`.

### Testing CLI Changes

After linking and building, you can test your CLI changes directly:

```bash
shortest --help
shortest --version
# ... any other CLI commands you are working on
```

### Packing the CLI for Testing in Other Projects

If you want to test your local CLI build as a true package in a separate project (without linking):

1.  Navigate to the CLI package directory:
    ```bash
    cd packages/shortest
    ```
2.  Create a distributable tarball:
    ```bash
    pnpm pack
    ```
    This will create a `.tgz` file (e.g., `antiwork-shortest-0.0.0.tgz`).

3.  In your other test project, you can then install this tarball:
    ```bash
    npm install /path/to/antiwork-shortest-x.y.z.tgz
    # or
    pnpm add /path/to/antiwork-shortest-x.y.z.tgz
    ```
    Then you can run `npx shortest ...` or `pnpm shortest ...` in that project.

---

## Writing Tests with Shortest

Shortest empowers you to write end-to-end tests using natural language. Here's how to get started and structure your tests.

### Initializing Shortest in a Project

For a new or existing project where you want to add Shortest tests, use the `init` command:

```bash
npx @antiwork/shortest init
```
Or if you have linked your local development CLI:
```bash
shortest init
```

This command will:
*   Install `@antiwork/shortest` as a dev dependency if not already present.
*   Create a default `shortest.config.ts` file with boilerplate configuration.
*   Generate a `.env.local` file (if one doesn't exist) with placeholders for required environment variables like `ANTHROPIC_API_KEY`.
*   Add `.env.local` and the `.shortest/` cache directory to your `.gitignore` file.

### Configuration (`shortest.config.ts`)

The `shortest.config.ts` file is the heart of your test setup. Key options include:

```typescript
import type { ShortestConfig } from "@antiwork/shortest";

export default {
  headless: false, // Run browsers in headless mode (true for CI, false for local dev)
  baseUrl: "http://localhost:3000", // Base URL of the application under test
  testPattern: "**/*.test.ts", // Pattern to find test files
  ai: {
    provider: "anthropic", // AI provider (currently only "anthropic" is supported)
    // apiKey: "your_anthropic_api_key", // Optional: directly set API key here, otherwise uses env vars
  },
  browser: { // Optional: Pass Playwright browser context options
    contextOptions: {
      ignoreHTTPSErrors: true,
      // viewport: { width: 1920, height: 1080 }
    },
  },
  // reporter: 'json', // Optional: Specify test reporter (e.g., 'json', 'html')
  // cache: false, // Optional: Disable caching of AI interactions
} satisfies ShortestConfig;
```

*   **`headless`**: Determines if the browser runs visibly or in the background.
*   **`baseUrl`**: The root URL for your application. Relative paths in tests will be appended to this.
*   **`testPattern`**: A glob pattern that Shortest uses to find your test files.
*   **`ai.provider`**: Specifies the AI provider. Currently, "anthropic" is the primary option.
*   **`ai.config.apiKey`**: You can override the environment variable by setting `apiKey` here. It defaults to `SHORTEST_ANTHROPIC_API_KEY` or `ANTHROPIC_API_KEY` from your environment.
*   **`browser.contextOptions`**: Allows you to pass [Playwright browser context options](https://playwright.dev/docs/api/class-browser#browser-new-context) (e.g., `ignoreHTTPSErrors`, `viewport`, `userAgent`).

### Creating Test Files

Create test files matching the `testPattern` in your config (e.g., `login.test.ts`, `user-profile.test.ts`).

#### Basic Test Structure

A simple test looks like this:

```typescript
// example.test.ts
import { shortest } from "@antiwork/shortest";

shortest("Navigate to the homepage and verify the title");

shortest("Login to the app using email and password", {
  // You can pass parameters to the AI
  email: process.env.TEST_USER_EMAIL,
  password: process.env.TEST_USER_PASSWORD,
});
```
The first argument to `shortest` is a natural language description of the test case. The AI will interpret this and attempt to perform the actions in a browser.

#### Callback Functions (`.after()`)

For more complex assertions or actions after the AI has completed its part, use the `.after()` callback:

```typescript
import { shortest } from "@antiwork/shortest";
// Assuming you have db setup for your app, e.g., using Drizzle ORM
// import { db } from "@/lib/db/drizzle";
// import { users } from "@/lib/db/schema";
// import { eq } from "drizzle-orm";

shortest("Register a new user and verify account creation")
  .after(async ({ page, params, context }) => {
    // `page` is the Playwright Page object
    // `params` are the parameters passed to the shortest function (if any)
    // `context` is the Playwright BrowserContext object

    // Example: Check if a success message is visible
    const successMessage = await page.locator(".signup-success-message").textContent();
    expect(successMessage).toContain("Account created successfully!");

    // Example: Verify user data in the database (conceptual)
    // const email = params.email; // If email was passed as a param to shortest()
    // const [user] = await db.select().from(users).where(eq(users.email, email)).limit(1);
    // expect(user).toBeDefined();
    // expect(user.emailVerified).toBe(true);
  });
```

#### Lifecycle Hooks

Shortest provides lifecycle hooks to run code before or after tests:

*   `shortest.beforeAll(async ({ browser, context, page }) => { /* ... */ });`
*   `shortest.beforeEach(async ({ browser, context, page, test }) => { /* ... */ });`
*   `shortest.afterEach(async ({ browser, context, page, test, result }) => { /* ... */ });`
*   `shortest.afterAll(async ({ browser, context, page }) => { /* ... */ });`

Example:

```typescript
import { shortest } from "@antiwork/shortest";

shortest.beforeAll(async () => {
  console.log("Starting test suite...");
  // e.g., Seed database, start a mock server
});

shortest.beforeEach(async ({ page, test }) => {
  console.log(`Starting test: ${test.title}`);
  // e.g., Login user, navigate to a common starting page
  // await page.goto("/login");
  // await page.fill("#username", "testuser");
  // await page.fill("#password", "password");
  // await page.click("button[type='submit']");
});

shortest.afterEach(async ({ result }) => {
  if (result.status === 'failed') {
    console.error(`Test failed: ${result.error?.message}`);
  }
});

shortest.afterAll(async () => {
  console.log("Finished test suite.");
  // e.g., Clean up database, stop mock server
});
```

#### Chaining Tests

You can define a sequence of tests or reusable flows:

```typescript
import { shortest } from "@antiwork/shortest";

// Sequential test chain
shortest([
  "User can login with email and password",
  "User can navigate to their profile page",
  "User can update their profile information",
  "User can logout successfully",
]);

// Reusable test flows
const guestCheckoutFlow = [
  "Search for a product",
  "Add product to cart",
  "Proceed to checkout as guest",
  "Fill shipping information",
  "Complete dummy payment",
  "Verify order confirmation",
];

const loggedInUserCheckoutFlow = [
  "Login with valid credentials",
  ...guestCheckoutFlow, // Spread the common flow
  "Verify order appears in user's order history",
];

shortest(guestCheckoutFlow, { product: "Test Product A" });
shortest(loggedInUserCheckoutFlow, { product: "Test Product B", user: "premium_user" });
```

#### API Testing

Shortest can also be used to test API endpoints using natural language.

**Method 1: Using `APIRequest` helper (if available/preferred)**

```typescript
// import { APIRequest } from "@antiwork/shortest"; // Assuming such a helper exists or you create one
// const req = new APIRequest({ baseURL: "http://localhost:3000/api" });

// shortest(
//   "Fetch active users and ensure only active users are returned",
//   req.fetch({
//     url: "/users",
//     method: "GET",
//     params: { active: true }, // Or new URLSearchParams({ active: "true" })
//   })
// ).after(async ({ response, data }) => { // Assuming response and parsed data are passed
//   expect(response.status).toBe(200);
//   const users = data; // Or await response.json();
//   users.forEach(user => expect(user.isActive).toBe(true));
// });
```
*(Note: The `APIRequest` helper and its exact usage might vary or need to be defined based on the current state of `@antiwork/shortest` API testing features. The example above is based on common patterns.)*

**Method 2: Pure Natural Language for API Tests**

You can describe the API call directly in natural language:

```typescript
shortest(`
  Make a GET request to the API endpoint "/api/v1/items".
  Include a query parameter "category" with value "electronics".
  The response status code should be 200.
  The response body should be a JSON array.
  Each item in the array should have a "name" property and a "price" property.
  At least one item should have the category "electronics".
`);

shortest(`
  Send a POST request to "/api/users" with the JSON body:
  { "name": "Test User", "email": "test@example.com" }.
  Expect a 201 status code.
  The response should include the created user's ID.
`);
```
The AI will attempt to make these HTTP requests and verify the outcomes.

### Examples Directory

For more practical examples, refer to the [`examples/`](../../examples) directory in the main project repository. It contains various test files showcasing different features and use cases.

---

## Running Tests

Once you have written your tests and configured your environment, you can run them using the Shortest CLI.

Make sure you have your `ANTHROPIC_API_KEY` (and any other necessary environment variables for your tests) set in your `.env.local` file or your shell environment.

### Basic Test Execution

*   **Run all tests**:
    To execute all test files matching the `testPattern` in your `shortest.config.ts`:
    ```bash
    pnpm shortest
    ```
    If you have linked the CLI globally and are not in a pnpm workspace that has `shortest` as a direct dependency, you might run:
    ```bash
    shortest
    ```

*   **Run tests in a specific file**:
    ```bash
    pnpm shortest path/to/your/test-file.test.ts
    ```
    Example:
    ```bash
    pnpm shortest examples/google.test.ts
    ```

*   **Run a specific test by line number**:
    If a test file contains multiple `shortest(...)` calls, you can target a specific test by appending its starting line number:
    ```bash
    pnpm shortest path/to/your/test-file.test.ts:42
    ```
    This will run only the test that starts on or near line 42 in that file.

### Running in Headless Mode

By default (`headless: false` in config or no CLI override), tests run with a visible browser window. For CI environments or faster local runs without UI, use headless mode:

*   **Override config with CLI flag**:
    ```bash
    pnpm shortest --headless
    ```
    Or, to force headed mode if config is `headless: true`:
    ```bash
    pnpm shortest --headed # (or --no-headless, check CLI --help for exact flag)
    ```

*   **Set in `shortest.config.ts`**:
    ```typescript
    // shortest.config.ts
    export default {
      headless: true,
      // ... other configs
    };
    ```

### Other Useful CLI Options

The Shortest CLI might offer other options. To see all available commands and flags:

```bash
pnpm shortest --help
```

This can include options for:
*   Specifying a different config file.
*   Controlling verbosity or logging.
*   Generating reports.
*   Managing GitHub 2FA (e.g., `shortest --github-code --secret=<OTP_SECRET>`).

Refer to the output of `pnpm shortest --help` for the most up-to-date list of options.

---

## Local Development with Docker

For a consistent and isolated development environment, you can use Docker and Docker Compose. This setup containerizes the Shortest application and its dependencies, as defined in the `Dockerfile` and `docker-compose.yml` at the project root.

### Benefits

*   **Consistency**: Ensures everyone on the team runs the app in the same environment.
*   **Isolation**: Keeps project dependencies separate from your local machine's setup.
*   **Simplified Setup**: Reduces the need to install specific versions of Node.js or other tools globally.

### Prerequisites

*   **Docker**: Install Docker Desktop (Windows, Mac) or Docker Engine (Linux). Get it from [docker.com](https://www.docker.com/products/docker-desktop).
*   **Docker Compose**: Usually included with Docker Desktop. If not, follow the installation guide on the Docker website.

Ensure Docker daemon is running before proceeding.

### Setup and Usage

1.  **Ensure `.env.local` is Present**:
    The Docker setup relies on your `.env.local` file for environment variables. Make sure it's created and configured as described in the [Environment Configuration](#environment-configuration) section. At a minimum, `ANTHROPIC_API_KEY` should be set.

2.  **Build the Docker Image**:
    Open your terminal in the project root directory and run:
    ```bash
    docker-compose build
    ```
    This command reads the `docker-compose.yml` file and builds the Docker image for the `app` service using the instructions in the `Dockerfile`. This might take a few minutes the first time.

3.  **Start the Development Environment**:
    To start the containerized application:
    ```bash
    docker-compose up
    ```
    Or, to run in detached mode (in the background):
    ```bash
    docker-compose up -d
    ```
    This will:
    *   Start the `app` service.
    *   Mount your local project directory into the container, so code changes are reflected live.
    *   Expose port 3000, making the web application (if configured and running via `pnpm dev`) accessible at `http://localhost:3000`.
    *   Load environment variables from your `.env.local` file into the container.

4.  **Accessing the Web App**:
    If the `pnpm dev` command (default CMD in Dockerfile) starts successfully, you can access the web application at `http://localhost:3000` in your browser.

5.  **Running Shortest Tests**:

    There are two main ways to run Shortest tests with the Docker setup:

    *   **Option 1: From your host machine (Recommended for quick iteration)**
        *   Ensure your local `shortest.config.ts` has `baseUrl: "http://localhost:3000"` (or whatever the containerized app's URL is).
        *   Run `shortest` commands as usual from your host machine's terminal:
            ```bash
            pnpm shortest
            pnpm shortest examples/your-test.test.ts
            ```
        *   This works because the application is exposed on `localhost:3000`, and your local Shortest CLI can interact with it. Your local `.env.local` will be used by the CLI.

    *   **Option 2: Executing tests inside the container**
        *   This method runs the `shortest` CLI that's within the Docker container itself. This can be useful for CI or to ensure tests run in the exact same environment as the app.
        *   Open a new terminal or use Docker Desktop's exec feature to run commands inside the running `app` container:
            ```bash
            docker-compose exec app pnpm shortest
            # Example: Run a specific test file
            docker-compose exec app pnpm shortest examples/google.test.ts
            # Example: Get CLI help
            docker-compose exec app pnpm shortest --help
            ```
        *   The container uses the `.env.local` file that was copied during the build or is available via the volume mount for its environment variables, including `ANTHROPIC_API_KEY`.

6.  **Viewing Logs**:
    *   If running `docker-compose up` in the foreground, logs will stream to your terminal.
    *   If running in detached mode (`-d`), or to view logs from a separate terminal:
        ```bash
        docker-compose logs -f app
        ```
        (Use `Ctrl+C` to stop following logs).

7.  **Stopping the Environment**:
    To stop the running containers:
    ```bash
    docker-compose down
    ```
    This will stop and remove the containers but preserve the built image and volumes unless specified otherwise (e.g., `docker-compose down -v` to remove volumes).

8.  **Rebuilding the Image**:
    If you make changes to `Dockerfile` or need to update dependencies within the image (e.g., after a `pnpm install` that changes `pnpm-lock.yaml` significantly):
    ```bash
    docker-compose build
    # Then restart the containers
    docker-compose up -d
    ```

### Troubleshooting Docker Setup

*   **Port Conflicts**: If `localhost:3000` is already in use on your host, change the port mapping in `docker-compose.yml`. For example, ` "3001:3000" ` would map container port 3000 to host port 3001.
*   **File Permissions**: On Linux, you might encounter file permission issues with volume mounts. Ensure the user specified in the `Dockerfile` (nodejs, uid 1001) has appropriate permissions or adjust as needed.
*   **Slow Performance (Mac/Windows)**: File system synchronization for mounted volumes can sometimes be slow on Docker Desktop for Mac/Windows. Ensure you have enough resources allocated to Docker. For very large projects, consider `.dockerignore` to exclude more files from the build context or volume mounts if they are not needed.
*   **Hot Reloading Not Working**: If hot-reloading (live code changes) isn't working inside the container for the web app, you might need to enable polling for your file watcher. For Next.js (used by the web app), this can sometimes be achieved by setting an environment variable like `WATCHPACK_POLLING=true` in `docker-compose.yml` or your `.env.local` file.

---

## Contributing

We welcome contributions to Shortest! Please refer to the [CONTRIBUTING.md](./packages/shortest/CONTRIBUTING.md) guide located in the `packages/shortest/` directory for details on:

*   Feature implementation process (scoping, building)
*   Development workflow (branches, testing)
*   Pull request guidelines
*   Coding style guide
*   Commit message conventions

## Troubleshooting

*   **`Error: ANTHROPIC_API_KEY is not set`**: Ensure your `ANTHROPIC_API_KEY` is correctly set in your `.env.local` file and that the file is being loaded (especially relevant for Docker setups - check that `env_file` is correctly specified in `docker-compose.yml` and the file exists).
*   **Playwright browser errors (e.g., `browserType.launch: Executable doesn't exist at...`)**:
    *   If running locally (not Docker): Try reinstalling Playwright browsers: `pnpm playwright install`.
    *   If using Docker: This usually indicates an issue with the Docker image build or the base image. Ensure Playwright's dependencies are met by the base Node image. The `Dockerfile` provided attempts to handle this, but if issues arise, you might need to add Playwright installation steps directly into the Dockerfile (e.g., `RUN pnpm playwright install --with-deps`).
*   **CLI command not found (`shortest: command not found`)**:
    *   Ensure you have linked the CLI correctly as per the [CLI Development](#cli-development) section if you're developing it locally.
    *   If you installed it via `npm install -g @antiwork/shortest` or `pnpm add -g @antiwork/shortest`, check your shell's `PATH`.
*   **Docker: Hot reloading not working**: As mentioned in the Docker section, try setting `WATCHPACK_POLLING=true` as an environment variable for the `app` service in your `docker-compose.yml`.
*   **Type errors after pulling changes or switching branches**: Run `pnpm install` to ensure all dependencies are up-to-date and consistent with the `pnpm-lock.yaml` file. Sometimes, cleaning out `node_modules` and reinstalling can help: `rm -rf node_modules && pnpm install`. For workspace projects, you might need to clean `node_modules` in sub-packages too.

If you encounter other issues, please check existing [GitHub Issues](https://github.com/antiwork/shortest/issues) or start a [New Discussion](https://github.com/antiwork/shortest/discussions/new?category=general) on the project repository.
