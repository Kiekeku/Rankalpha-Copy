'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from '@/components/ui/navigation-menu'
import { ThemeToggle } from '@/components/theme-toggle'

const navigation = [
  { name: 'Overview', href: '/' },
  { name: 'Rankings', href: '/rankings' },
  { name: 'AI Analysis', href: '/ai-analysis' },
  { name: 'Screener', href: '/screener/consensus' },
]

export function MainNav() {
  const pathname = usePathname()

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/80 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-14 items-center">
        <div className="mr-4 flex items-center gap-4">
          <Link href="/" className="mr-2 flex items-center space-x-2">
            <span className="font-bold text-xl tracking-tight text-primary">RankAlpha</span>
          </Link>
          <NavigationMenu>
            <NavigationMenuList>
              {navigation.map((item) => (
                <NavigationMenuItem key={item.href}>
                  <Link href={item.href} legacyBehavior passHref>
                    <NavigationMenuLink
                      className={cn(
                        navigationMenuTriggerStyle(),
                        pathname === item.href && 'bg-accent'
                      )}
                    >
                      {item.name}
                    </NavigationMenuLink>
                  </Link>
                </NavigationMenuItem>
              ))}
            </NavigationMenuList>
          </NavigationMenu>
        </div>
        <div className="ml-auto flex items-center gap-3 text-sm text-muted-foreground">
          <span className="hidden md:inline">Market</span>
          <span className="rounded-md border px-2 py-1 font-medium text-foreground">US</span>
          <ThemeToggle />
        </div>
      </div>
    </header>
  )
}
