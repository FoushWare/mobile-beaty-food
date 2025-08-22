# Baty Food - Web Development Guidelines with shadcn/ui

## Architecture

### Monorepo Structure (Turborepo)

```
baty-food/
├── apps/
│   ├── web/                    # Next.js customer app
│   ├── admin/                  # Admin dashboard
│
│
├── packages/
│   ├── ui/                     # Shared UI components (shadcn/ui)
│   ├── design-system/          # Design tokens
│   ├── utils/                  # Shared utilities
│   ├── types/                  # TypeScript definitions
│   └── hooks/                  # Shared React hooks
└── turbo.json
```

### Tech Stack

- **Frontend:** Next.js 14 + shadcn/ui + Tailwind CSS
- **State Management:** Zustand
- **Forms:** React Hook Form + Zod + shadcn/ui form components
- **Icons:** Lucide React (included with shadcn/ui)
- **Backend:** Node.js + Express + Supabase
- **Package Manager:** pnpm

## shadcn/ui Integration

### Installation & Setup

```bash
# Install shadcn/ui CLI
pnpm add -D @shadcn/ui

# Initialize shadcn/ui
npx shadcn-ui@latest init

# Add components as needed
npx shadcn-ui@latest add button input card form dialog dropdown-menu table badge avatar calendar progress toast
```

### shadcn/ui Configuration

```typescript
// components.json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "app/globals.css",
    "baseColor": "slate",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils"
  }
}
```

## Atomic Design Implementation with shadcn/ui

### Atoms (Basic Components)

```typescript
// packages/ui/src/atoms/Button/Button.tsx
import { Button as ShadcnButton } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface ButtonProps {
  variant:
    | "default"
    | "destructive"
    | "outline"
    | "secondary"
    | "ghost"
    | "link";
  size: "default" | "sm" | "lg" | "icon";
  children: React.ReactNode;
  disabled?: boolean;
  loading?: boolean;
  onClick?: () => void;
  className?: string;
}

export const Button: React.FC<ButtonProps> = ({
  variant = "default",
  size = "default",
  children,
  disabled = false,
  loading = false,
  onClick,
  className,
}) => {
  return (
    <ShadcnButton
      variant={variant}
      size={size}
      disabled={disabled || loading}
      onClick={onClick}
      className={cn(className)}
    >
      {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
      {children}
    </ShadcnButton>
  );
};
```

### Molecules (Compound Components)

```typescript
// packages/ui/src/molecules/RecipeCard/RecipeCard.tsx
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Star } from "lucide-react";

interface RecipeCardProps {
  recipe: Recipe;
  onAddToCart: (recipe: Recipe) => void;
  onViewDetails: (recipe: Recipe) => void;
  variant: "compact" | "detailed";
  className?: string;
}

export const RecipeCard: React.FC<RecipeCardProps> = ({
  recipe,
  onAddToCart,
  onViewDetails,
  variant = "compact",
  className,
}) => {
  return (
    <Card className={cn("group overflow-hidden", className)}>
      <CardHeader className="p-0">
        <div className="aspect-square overflow-hidden">
          <img
            src={recipe.image}
            alt={recipe.name}
            className="h-full w-full object-cover transition-transform group-hover:scale-105"
          />
        </div>
      </CardHeader>

      <CardContent className="p-4">
        <div className="flex items-start justify-between">
          <div className="space-y-1">
            <h3 className="font-semibold text-lg">{recipe.name}</h3>
            <p className="text-sm text-muted-foreground">{recipe.chef.name}</p>
          </div>
          <Badge variant="secondary">{recipe.category}</Badge>
        </div>

        <div className="mt-2 flex items-center justify-between">
          <div className="flex items-center gap-1">
            <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
            <span className="text-sm">{recipe.rating}</span>
          </div>
          <span className="font-semibold text-primary">${recipe.price}</span>
        </div>
      </CardContent>

      <CardFooter className="p-4 pt-0">
        <div className="flex gap-2 w-full">
          <Button
            variant="outline"
            size="sm"
            onClick={() => onViewDetails(recipe)}
            className="flex-1"
          >
            View Details
          </Button>
          <Button
            variant="default"
            size="sm"
            onClick={() => onAddToCart(recipe)}
          >
            Add to Cart
          </Button>
        </div>
      </CardFooter>
    </Card>
  );
};
```

## Design System with shadcn/ui

### Tailwind Configuration

```javascript
// tailwind.config.js
const { fontFamily } = require("tailwindcss/defaultTheme");

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    "./pages/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./app/**/*.{ts,tsx}",
    "./src/**/*.{ts,tsx}",
    "./packages/**/*.{ts,tsx}",
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      fontFamily: {
        primary: ["Cairo", ...fontFamily.sans],
        secondary: ["Inter", ...fontFamily.sans],
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};
```

### CSS Variables for Baty Food Theme

```css
/* globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 14 100% 60%; /* Baty Food Orange */
    --primary-foreground: 210 40% 98%;
    --secondary: 146 50% 36%; /* Baty Food Green */
    --secondary-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 48 100% 50%; /* Baty Food Gold */
    --accent-foreground: 222.2 84% 4.9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 14 100% 60%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 14 100% 60%;
    --primary-foreground: 222.2 84% 4.9%;
    --secondary: 146 50% 36%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 48 100% 50%;
    --accent-foreground: 222.2 84% 4.9%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 14 100% 60%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground font-primary;
  }
}
```

## State Management

### Cart Store (Zustand)

```typescript
// packages/cart/src/store/cartStore.ts
import { create } from "zustand";
import { persist } from "zustand/middleware";

interface CartItem {
  id: string;
  name: string;
  price: number;
  image: string;
  chefName: string;
  quantity: number;
}

interface CartStore {
  items: CartItem[];
  total: number;
  addItem: (item: Recipe, quantity: number) => void;
  removeItem: (itemId: string) => void;
  clearCart: () => void;
}

export const useCartStore = create<CartStore>()(
  persist(
    (set) => ({
      items: [],
      total: 0,
      addItem: (item, quantity) => {
        set((state) => {
          const existingItem = state.items.find((i) => i.id === item.id);

          if (existingItem) {
            const updatedItems = state.items.map((i) =>
              i.id === item.id ? { ...i, quantity: i.quantity + quantity } : i
            );

            return {
              items: updatedItems,
              total: updatedItems.reduce(
                (sum, item) => sum + item.price * item.quantity,
                0
              ),
            };
          }

          const newItem = { ...item, quantity };
          const updatedItems = [...state.items, newItem];

          return {
            items: updatedItems,
            total: updatedItems.reduce(
              (sum, item) => sum + item.price * item.quantity,
              0
            ),
          };
        });
      },
      removeItem: (itemId) => {
        set((state) => {
          const updatedItems = state.items.filter((i) => i.id !== itemId);
          return {
            items: updatedItems,
            total: updatedItems.reduce(
              (sum, item) => sum + item.price * item.quantity,
              0
            ),
          };
        });
      },
      clearCart: () => {
        set({ items: [], total: 0 });
      },
    }),
    { name: "baty-food-cart" }
  )
);
```

## Next.js App Structure

### App Router Layout

```typescript
// apps/web/src/app/layout.tsx
import { ThemeProvider } from "@/components/theme-provider";
import { Toaster } from "@/components/ui/toaster";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin=""
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="font-primary antialiased">
        <ThemeProvider
          attribute="class"
          defaultTheme="light"
          enableSystem
          disableTransitionOnChange
        >
          {children}
          <Toaster />
        </ThemeProvider>
      </body>
    </html>
  );
}
```

## Turborepo Configuration

### turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^lint"]
    }
  }
}
```

## Development Workflow

### Package.json Scripts

```json
{
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "clean": "turbo run clean",
    "type-check": "turbo run type-check",
    "ui:add": "npx shadcn-ui@latest add"
  }
}
```

## shadcn/ui Components for Baty Food

### Essential Components to Install

```bash
# Core UI components
npx shadcn-ui@latest add button input card form dialog dropdown-menu table badge avatar calendar progress toast sheet tabs select textarea checkbox radio-group switch slider separator skeleton alert alert-dialog popover tooltip scroll-area command breadcrumb pagination data-table navigation-menu menubar context-menu hover-card collapsible accordion carousel aspect-ratio resizable sonner
```

## Performance Optimization

### Code Splitting

```typescript
import dynamic from "next/dynamic";

const HeroSection = dynamic(
  () => import("@baty-food/ui/organisms/HeroSection"),
  {
    loading: () => <div className="h-96 animate-pulse bg-muted rounded-lg" />,
  }
);
```

## Security

### Authentication

```typescript
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  loading: true,
  signIn: async (email, password) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    set({ user: data.user });
  },
}));
```

### Input Validation

```typescript
import { z } from "zod";

export const recipeSchema = z.object({
  name: z.string().min(1, "Recipe name is required"),
  price: z.number().positive("Price must be positive"),
  category: z.enum(["egyptian", "italian", "asian", "desserts"]),
});
```

## Deployment

### Vercel Configuration

```json
{
  "buildCommand": "pnpm build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "env": {
    "NEXT_PUBLIC_SUPABASE_URL": "@supabase-url",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY": "@supabase-anon-key"
  }
}
```

## Quality Assurance

- **ESLint + Prettier:** Code formatting
- **TypeScript:** Type safety
- **Lighthouse:** Performance audits
- **Accessibility:** WCAG compliance with shadcn/ui built-in accessibility

---

**Ready to build Baty Food with shadcn/ui! 🍽️**

Reference: [shadcn/ui](https://ui.shadcn.com/)
