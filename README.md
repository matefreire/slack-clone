# Slack Clone

A Slack-inspired chat application built with [Next.js](https://nextjs.org) App Router, TypeScript, Tailwind CSS v4, and [shadcn/ui](https://ui.shadcn.com).

## Getting Started

This app uses [Next.js](https://nextjs.org) and [Convex](https://convex.dev). You need a Convex account and a one-time CLI login before the backend sync works.

### Convex login (once)

```bash
npx convex login
```

Credentials are stored in `~/.convex` on the host (on Windows: `%USERPROFILE%\.convex`). Docker and the Dev Container mount that folder so you do not need to log in again inside the container.

### Local (no Docker)

```bash
npm install
npm run dev:stack
```

`dev:stack` runs `convex dev` and Next.js together. Alternatively, use two terminals:

```bash
npx convex dev
npm run dev
```

Open [http://localhost:3000](http://localhost:3000). On the first run, `convex dev` writes `NEXT_PUBLIC_CONVEX_URL` to `.env.local`. If the Next process started before that file existed, restart it once.

### Dev Container (Cursor / VS Code)

**Prerequisites:** Docker Desktop and Dev Containers support in the editor.

1. Open the repo and choose **Reopen in Container** (or **Dev Containers: Reopen in Container**).
2. Wait for `postCreateCommand` (`npm install`). The container starts as root, fixes workspace ownership for the `node` user, then your terminal runs as `node`.
3. In the integrated terminal:

```bash
npm run dev:stack
```

The app is forwarded to [http://localhost:3000](http://localhost:3000).

Or use separate terminals: `npx convex dev` and `npm run dev:docker`.

### Docker Compose

**Prerequisites:** Docker Engine and Docker Compose v2, plus `npx convex login` on the host (see above).

From the repository root:

```bash
docker compose -f docker/docker-compose.yml up
```

Alternatively:

```bash
cd docker
docker compose up
```

This runs `npm install` and `npm run dev:stack` (Convex + Next). The app is at [http://localhost:3000](http://localhost:3000).

If the Convex project is not linked yet and the CLI asks for interactive input:

```bash
docker compose -f docker/docker-compose.yml run --rm -it app npx convex login
docker compose -f docker/docker-compose.yml run --rm -it app npx convex dev
```

Then start with `up` as usual.

**What happens under the hood:**

- Build context is the repository root; the Dockerfile lives in `docker/Dockerfile`.
- `dev:stack` runs `convex dev` and `dev:docker` via `concurrently`.
- `dev:docker` binds to all interfaces (`--hostname 0.0.0.0`) so the app is reachable from outside the container.
- Source code is mounted from the host (`..:/app`).
- Host Convex credentials are mounted at `/root/.convex` (override with `CONVEX_CREDS_PATH` if needed).
- Optional `../.env.local` is loaded when present (`env_file`, `required: false`).
- `node_modules` and `.next` use named volumes to avoid cross-platform conflicts.
- File-watching uses polling for reliable hot reload on mounted volumes (`WATCHPACK_POLLING`, `CHOKIDAR_USEPOLLING`, `CHOKIDAR_INTERVAL`).
- `next.config.ts` sets `watchOptions.pollIntervalMs: 500`, aligned with the Docker polling interval.

**Useful commands:**

```bash
# Stop containers
docker compose -f docker/docker-compose.yml down

# Rebuild after Dockerfile changes
docker compose -f docker/docker-compose.yml up --build
```

> **Note:** `.env` files are excluded from the Docker build context (`.dockerignore`). Runtime env comes from the optional `env_file` and from `convex dev` writing `.env.local` into the mounted workspace.

## Contributing

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
.devcontainer/        # Cursor / VS Code Dev Container
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
