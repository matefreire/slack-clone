# Slack Clone

A Slack-inspired chat application built with [Next.js](https://nextjs.org) App Router, TypeScript, Tailwind CSS v4, and [shadcn/ui](https://ui.shadcn.com).

## Getting Started

Install dependencies and run the development server locally:

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Contributing

### Running with Docker

**Prerequisites:** Docker Engine and Docker Compose v2.

Start the development environment from the repository root:

```bash
docker compose -f docker/docker-compose.yml up
```

Alternatively:

```bash
cd docker
docker compose up
```

The app will be available at [http://localhost:3000](http://localhost:3000).

**What happens under the hood:**

- Build context is the repository root; the Dockerfile lives in `docker/Dockerfile`.
- The container runs `npm install && npm run dev:docker`.
- The `dev:docker` script binds to all interfaces (`--hostname 0.0.0.0`) so the app is reachable from outside the container.
- Source code is mounted from the host (`..:/app`).
- `node_modules` and `.next` use named volumes (`slack_clone_node_modules`, `slack_clone_next`) to avoid cross-platform conflicts between the host and the container.
- File-watching uses polling for reliable hot reload on mounted volumes (`WATCHPACK_POLLING`, `CHOKIDAR_USEPOLLING`, `CHOKIDAR_INTERVAL`).
- `next.config.ts` sets `watchOptions.pollIntervalMs: 500`, aligned with the Docker polling interval.

**Useful commands:**

```bash
# Stop containers
docker compose -f docker/docker-compose.yml down

# Rebuild after Dockerfile changes
docker compose -f docker/docker-compose.yml up --build
```

> **Note:** `.env` files are excluded from the Docker build context (`.dockerignore`). If environment variables are needed, configure them via `env_file` in `docker-compose.yml` or a bind mount.

### Commit Conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification).

**Format:**

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Allowed types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

**Rules:**

- Write the subject in English, imperative mood, lowercase, with no trailing period.
- Scope is optional but recommended for project areas (`auth`, `ui`, `api`, etc.).
- Use the body to explain *why*, not to repeat the diff line by line.
- For breaking changes, append `!` after the type/scope or add a `BREAKING CHANGE:` footer.

**Examples:**

```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.
```

```
feat(auth): add sign-in card
```

```
fix(ui)!: remove deprecated button variants

BREAKING CHANGE: Button variant="ghost" no longer supported
```

### Folder Structure

This project uses the Next.js App Router with a feature-based layout under `src/`:

```
src/
├── app/              # App Router: layouts, pages, globals.css
├── components/
│   └── ui/           # shadcn/ui primitives (Button, Card, Input…)
├── features/
│   └── <feature>/    # Domain modules (components, types, hooks…)
│       ├── components/
│       └── types.ts
├── lib/              # Shared utilities (e.g. cn())
└── hooks/            # Shared hooks (alias configured; folder may be empty)
public/               # Static assets
docker/               # Dockerfile and compose
```

**Organization rules:**

- Routes and layouts go in `src/app/` (Server Components by default).
- Generic, reusable UI primitives go in `src/components/ui/` (added via the shadcn CLI).
- Domain-specific screens and logic go in `src/features/<feature>/`.
- Shared utilities go in `src/lib/`.
- Import alias `@/*` maps to `./src/*` (see `tsconfig.json`).

Example: `src/app/page.tsx` imports `@/features/auth/components/auth-screen`.

### Components and Tailwind Patterns

#### Server vs Client Components

- Default to Server Components (no `"use client"` directive).
- Add `"use client"` only when the component uses hooks, state, or event handlers (e.g. `src/features/auth/components/auth-screen.tsx`).

#### UI Primitives (shadcn/ui)

- Location: `src/components/ui/`
- Style: `radix-nova`, React Server Components enabled (see `components.json`)
- Variants defined with `class-variance-authority` (`cva`) — see `src/components/ui/button.tsx`
- Conditional classes merged with `cn()` from `src/lib/utils.ts`
- shadcn primitives use `data-slot` attributes
- Add new primitives: `npx shadcn@latest add <component>`

#### Feature Components

- Named export in PascalCase — e.g. `export const SignInCard`
- File name in kebab-case — e.g. `sign-in-card.tsx`
- Compose from `@/components/ui/*` primitives; do not duplicate base styles
- Feature-specific types live in `src/features/<feature>/types.ts`

#### Tailwind CSS v4

- Central configuration in `src/app/globals.css`: `@import "tailwindcss"`, design tokens via CSS variables, `@theme inline`
- Prefer semantic tokens (`bg-primary`, `text-muted-foreground`, `border-border`) over hardcoded color values
- Class scanning via `@source "../**/*.{ts,tsx}"`
- Responsive layouts use Tailwind breakpoint utilities (`md:`, `lg:`, etc.)
- Extra `className` props passed to UI primitives should be merged with `cn()` inside the component
