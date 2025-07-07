# Replit.md - Real-time Customer Support Chat System

## Overview

This is a full-stack customer support chat application built with React + TypeScript on the frontend and Express.js on the backend. The system provides real-time communication between customers and support agents through an embeddable chat widget and an admin dashboard.

## System Architecture

### Frontend Architecture
- **Framework**: React 18 with TypeScript
- **Styling**: Tailwind CSS with shadcn/ui component library
- **State Management**: TanStack Query for server state, React Context for auth
- **Routing**: Wouter for client-side routing
- **Real-time Communication**: WebSockets for live chat functionality

### Backend Architecture
- **Framework**: Express.js with TypeScript
- **Database**: PostgreSQL with Drizzle ORM
- **Authentication**: Passport.js with local strategy and express-session
- **Real-time**: WebSocket server for live messaging
- **Session Storage**: PostgreSQL-backed sessions via connect-pg-simple

### Database Architecture
- **ORM**: Drizzle with PostgreSQL dialect
- **Provider**: Neon Database (@neondatabase/serverless)
- **Schema Location**: `shared/schema.ts` for type sharing between client/server

## Key Components

### Database Schema
The application uses four main entities:
- **Users**: Support agents with authentication and online status
- **Customers**: Chat participants identified by session IDs
- **Conversations**: Chat sessions with status tracking (waiting, active, resolved, closed)
- **Messages**: Individual chat messages with sender identification
- **Widget Configs**: Customizable chat widget settings

### Authentication System
- **Strategy**: Local username/password authentication
- **Session Management**: PostgreSQL-backed sessions with express-session
- **Password Security**: Scrypt-based hashing with salt
- **Authorization**: Route-level protection for agent dashboard

### Real-time Communication
- **WebSocket Integration**: Custom socket handlers for live messaging
- **Connection Management**: Per-conversation and per-user connection tracking
- **Message Broadcasting**: Real-time updates to all connected participants
- **Agent Status**: Live online/offline status updates

### Chat Widget System
- **Embeddable Widget**: Standalone chat interface for customer websites
- **Customization**: Configurable appearance, position, and form fields
- **Session Management**: Automatic customer identification and conversation creation

## Data Flow

### Customer Journey
1. Customer opens chat widget on host website
2. Widget creates anonymous customer record with session ID
3. New conversation created in "waiting" status
4. Real-time connection established via WebSocket
5. Messages flow bidirectionally through WebSocket and REST APIs

### Agent Workflow
1. Agent authenticates through login form
2. Dashboard loads active conversations via REST API
3. WebSocket connection established for real-time updates
4. Agent can claim conversations and respond to messages
5. Conversation status updates (waiting → active → resolved → closed)

### Message Flow
1. Messages sent via WebSocket for immediate delivery
2. Backup REST API calls ensure database persistence
3. TanStack Query manages cache invalidation and refetching
4. Real-time updates broadcast to all connected participants

## External Dependencies

### Core Framework Dependencies
- **@tanstack/react-query**: Server state management and caching
- **wouter**: Lightweight React routing
- **drizzle-orm**: Type-safe database ORM
- **@neondatabase/serverless**: PostgreSQL database provider

### UI and Styling
- **@radix-ui/***: Unstyled, accessible UI primitives
- **tailwindcss**: Utility-first CSS framework
- **shadcn/ui**: Pre-built component library
- **class-variance-authority**: Component variant management

### Authentication and Security
- **passport**: Authentication middleware
- **passport-local**: Username/password strategy
- **express-session**: Session management
- **connect-pg-simple**: PostgreSQL session store

### Real-time Communication
- **ws**: WebSocket implementation for Node.js
- **WebSocket API**: Browser-native WebSocket client

## Deployment Strategy

### Build Process
- **Frontend**: Vite builds React app to `dist/public`
- **Backend**: esbuild bundles Express server to `dist/index.js`
- **Database**: Drizzle migrations in `migrations/` directory

### Environment Requirements
- **NODE_ENV**: Production/development environment flag
- **DATABASE_URL**: PostgreSQL connection string (required)
- **SESSION_SECRET**: Express session signing key (required)

### Development Workflow
- **dev**: Runs development server with tsx and hot reload
- **build**: Creates production bundles for both frontend and backend
- **start**: Runs production server from built files
- **db:push**: Applies schema changes to database

### Production Deployment (Ubuntu 20.04 VPS)
- **Process Manager**: PM2 with cluster mode for high availability
- **Web Server**: Nginx as reverse proxy with SSL/TLS support
- **Database**: PostgreSQL 14+ with optimized configuration
- **Security**: UFW firewall, SSL certificates via Let's Encrypt
- **Monitoring**: PM2 logs, Nginx access/error logs
- **Auto-restart**: PM2 handles application crashes and restarts

### Widget Integration
- **Embeddable Widget**: JavaScript widget available at `/widget.js` and `/widget.css`
- **CORS Support**: Cross-origin requests enabled for widget integration
- **Configuration**: Widget behavior customizable via LiveChatConfig object
- **Real-time**: WebSocket connection for instant messaging

### Production Considerations
- Database migrations should be run before deployment
- Session secret must be consistent across restarts
- WebSocket connections require sticky sessions in load-balanced environments
- Static files served from `dist/public` in production
- Widget files served with CORS headers for cross-domain integration

## Changelog

```
Changelog:
- July 07, 2025. Initial setup with complete chat system
- July 07, 2025. Added widget configuration page with Vietnamese interface
- July 07, 2025. Created comprehensive VPS deployment guide for Ubuntu 20.04
- July 07, 2025. Added embeddable widget files (widget.js, widget.css)
- July 07, 2025. Configured PM2 ecosystem and production deployment files
- July 07, 2025. Created all-in-one deployment script for Ubuntu 20.04 VPS with complete automation
```

## User Preferences

```
Preferred communication style: Simple, everyday language.
```
