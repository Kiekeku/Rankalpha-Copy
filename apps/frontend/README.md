# RankAlpha Frontend Application

## Purpose
The Frontend application provides a modern, responsive web interface for the RankAlpha financial analysis platform. It delivers real-time market insights, stock grading visualizations, signal analysis, and backtesting capabilities through an intuitive user experience.

## Technologies & Tools

### Core Framework
- **Next.js 14**: React framework with App Router for server-side rendering and routing
- **React 18**: Component-based UI library with hooks
- **TypeScript**: Type-safe development with compile-time checking

### UI & Styling
- **Tailwind CSS**: Utility-first CSS framework for rapid styling
- **Radix UI**: Unstyled, accessible component primitives
- **shadcn/ui**: Pre-built component library built on Radix UI
- **Class Variance Authority (CVA)**: Component variant management
- **Lucide Icons**: Comprehensive icon library

### Data Management
- **TanStack Query (React Query)**: Server state management and caching
- **Axios**: HTTP client for API communication
- **OpenAPI TypeScript**: Auto-generated types from API schema

### Data Visualization
- **Recharts**: Composable charting library for React
- **Lightweight Charts**: High-performance financial charts (TradingView)
- **TanStack Table**: Powerful data table with sorting/filtering

### Development Tools
- **ESLint**: Code linting and style enforcement
- **TypeScript Compiler**: Type checking
- **Next.js Dev Server**: Hot module replacement

## Design Principles

### 1. **Component-Based Architecture**
- Reusable UI components with clear separation of concerns
- Composition over inheritance
- Single responsibility principle for each component

### 2. **Type Safety First**
- TypeScript throughout the codebase
- Auto-generated API types from OpenAPI schema
- Runtime validation for critical data flows

### 3. **Server-Side Rendering (SSR)**
- Improved SEO and initial page load performance
- Dynamic metadata generation
- Server Components for reduced client bundle size

### 4. **Responsive Design**
- Mobile-first approach
- Breakpoint-based layouts
- Touch-friendly interactions

### 5. **Performance Optimization**
- Code splitting and lazy loading
- Image optimization with Next.js Image component
- Efficient re-rendering with React Query caching
- Automatic data refresh on backend updates

## Project Structure

### Directory Layout
```
src/
├── app/                    # Next.js App Router pages
│   ├── layout.tsx         # Root layout with providers
│   ├── page.tsx          # Home page
│   ├── ai-analysis/      # AI analysis list + detail routes
│   │   ├── page.tsx      # List & filters (latest analyses)
│   │   ├── [symbol]/     # Latest analysis by symbol
│   │   └── id/[id]/      # Specific analysis by UUID
│   ├── screener/
│   │   └── consensus/    # Latest-day screener consensus (per-symbol)
│   ├── grades/           # Grading system pages
│   ├── signals/          # Signal analysis pages
│   ├── backtest/         # Backtesting interface
│   └── pipeline/         # Pipeline monitoring
├── components/           # Reusable React components
│   ├── ui/              # Base UI components (shadcn)
│   ├── charts/          # Chart components
│   ├── tables/          # Data table components
│   └── layout/          # Layout components
├── lib/                 # Utility functions and helpers
│   ├── api.ts          # API client configuration
│   ├── utils.ts        # Common utilities
│   └── hooks/          # Custom React hooks
└── types/              # TypeScript type definitions
    └── api.ts          # Auto-generated API types
```

### Core Features

#### Overview Dashboard
- **Pipeline Health**: Real-time status of data processing components
- **Top Performers**: Highest-rated stocks with grade explanations
- **Key Metrics**: Market trends and summary statistics
- **Data Freshness**: Last update timestamps and refresh controls

#### Signals Leaderboard
- **Multi-Signal Analysis**: Compare momentum, value, and sentiment signals
- **Sortable Rankings**: Dynamic sorting by any signal or metric
- **Sector Filtering**: Filter by industry sectors
- **Export Capabilities**: Download data in CSV/Excel formats

#### Asset Detail Pages
- **Comprehensive Analysis**: Individual stock deep-dive
- **Interactive Charts**: Price history with technical indicators
- **Sentiment Timeline**: Historical sentiment with catalysts
- **Peer Comparison**: Compare against sector peers
 - **AI Analysis (new)**: Dedicated pages under `/ai-analysis` to list and view AI outputs
   - `/ai-analysis` – filters + pagination over `vw_ai_analysis_full`
   - `/ai-analysis/[symbol]` – latest for a symbol
   - `/ai-analysis/id/[analysis_id]` – specific record

#### Screener Consensus (new)
- **Consensus View**: `/screener/consensus` shows the latest-day per‑symbol aggregation across styles/sources
- **Filters**: Min appearances, min styles, symbol
- **Sort**: Implicit by `consensus_score` descending

#### Backtest Tool
- **Strategy Builder**: Visual strategy configuration
- **Performance Metrics**: Sharpe ratio, max drawdown, returns
- **Comparison Mode**: Test multiple strategies simultaneously
- **Historical Simulation**: Test strategies on past data

### Custom Hooks

#### `useDataRefresh`
```typescript
// Automatic data refresh when backend updates
const { lastRefresh, isRefreshing } = useDataRefresh({
  pollingInterval: 60000, // Check every minute
  onNewData: () => toast.success("New data available!")
});
```

#### `useManualRefresh`
```typescript
// Manual refresh trigger for user-initiated updates
const { refresh, isRefreshing } = useManualRefresh();
```

#### `useApi`
```typescript
// Type-safe API wrapper
const { data, isLoading, error } = useApi<GradeResponse>({
  endpoint: '/grades',
  params: { symbol: 'AAPL' }
});
```

## State Management

### Server State (React Query)
```typescript
// Query configuration with smart caching
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      refetchOnWindowFocus: false,
    },
  },
});
```

## Running the Application

### Local Development
```bash
cd apps/frontend
pnpm install
pnpm dev
# Opens at http://localhost:3000
```

### Production Build
```bash
pnpm build
pnpm start
```

### Docker Deployment
```bash
# Multi-stage build for optimized image
docker build -t rankalpha-frontend .
docker run -p 3000:3000 -e NEXT_PUBLIC_API_URL=http://localhost:6080 rankalpha-frontend
```

### Type Generation
```bash
# Generate TypeScript types from OpenAPI schema
pnpm generate-types
```

## Backend APIs used
- `GET /api/v1/ai-analysis` (and `/id/{analysis_id}`, `/{symbol}`)
- `GET /api/v1/screener/consensus`

### Code Quality Checks
```bash
# Type checking
pnpm type-check

# Linting
pnpm lint
```

## Environment Configuration

### Required Variables
```env
NEXT_PUBLIC_API_URL=http://localhost:6080
```

### Optional Variables
```env
NEXT_PUBLIC_WS_URL=ws://localhost:6080
NEXT_PUBLIC_ENABLE_DEVTOOLS=true
```

## Performance Features

### Data Refresh System
- **Automatic Polling**: Checks `/api/refresh-data` every minute
- **Smart Cache Invalidation**: Only refetches changed data
- **User Notifications**: Toast messages for new data
- **Manual Override**: Force refresh button for immediate updates

### Optimization Strategies
- **Code Splitting**: Dynamic imports reduce initial bundle
- **Image Optimization**: Next.js Image component with lazy loading
- **React Query Cache**: Intelligent caching with background refetch
- **Bundle Analysis**: Regular monitoring of JavaScript bundle size

## Security Considerations

- **Content Security Policy**: Strict CSP headers
- **XSS Protection**: React's automatic escaping
- **HTTPS Enforcement**: SSL/TLS in production
- **Input Sanitization**: Validation on all user inputs
- **Secure Authentication**: JWT tokens with refresh mechanism

## Browser Support

- Chrome/Edge (latest 2 versions)
- Firefox (latest 2 versions)
- Safari (latest 2 versions)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Future Enhancements

### Planned Features
- WebSocket integration for real-time updates
- Advanced charting with drawing tools
- Portfolio management interface
- Mobile app using React Native
- Offline support with service workers
- Multi-language internationalization
- Advanced data export with templates
- Collaborative analysis features

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Verify API is running on port 6080
   - Check NEXT_PUBLIC_API_URL in environment
   - Ensure CORS is configured on backend

2. **Type Generation Error**
   - Confirm API is accessible
   - Check OpenAPI endpoint (/openapi.json)
   - Verify network connectivity

3. **Build Failures**
   - Clear .next directory
   - Run `pnpm type-check` to find issues
   - Check all dependencies are installed

## Contributing

### Development Standards
- Use functional components with TypeScript
- Follow existing component patterns
- Add unit tests for new features
- Update types when API changes
- Document complex logic with comments
- Ensure accessibility compliance
