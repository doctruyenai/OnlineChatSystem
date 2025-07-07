# Real-time Customer Support Chat System

## Overview

This is a full-stack customer support chat application built with React + TypeScript on the frontend and Express.js on the backend. The system provides real-time communication between customers and support agents through an embeddable chat widget and a comprehensive agent dashboard.

## System Architecture

### Frontend Architecture
- **Framework**: React 18 with TypeScript
- **Styling**: Tailwind CSS with shadcn/ui component library for consistent design system
- **State Management**: TanStack Query for server state management, React Context for authentication
- **Routing**: Wouter for lightweight client-side routing
- **Real-time Communication**: WebSockets for live chat functionality
- **Build Tool**: Vite for fast development and optimized builds

### Backend Architecture
- **Framework**: Express.js with TypeScript
- **Database**: PostgreSQL with Drizzle ORM for type-safe database operations
- **Authentication**: Passport.js with local strategy and express-session
- **Session Storage**: PostgreSQL-backed sessions via connect-pg-simple
- **Real-time**: WebSocket server for live messaging and status updates
- **Process Management**: PM2 for production deployment with clustering

### Database Architecture
- **ORM**: Drizzle with PostgreSQL dialect for type safety and performance
- **Provider**: Neon Database (@neondatabase/serverless) for cloud PostgreSQL
- **Schema Location**: `shared/schema.ts` for type sharing between client and server
- **Migration System**: Drizzle Kit for database migrations

## Key Components

### Database Schema
The application uses five main entities:
- **Users**: Support agents with authentication, roles, and online status tracking
- **Customers**: Chat participants identified by unique session IDs
- **Conversations**: Chat sessions with status tracking (waiting, active, resolved, closed) and priority levels
- **Messages**: Individual chat messages with sender identification and message types
- **Widget Configs**: Customizable chat widget settings for different domains

### Authentication System
- **Strategy**: Local username/password authentication with Passport.js
- **Session Management**: PostgreSQL-backed sessions for scalability
- **Password Security**: Scrypt-based hashing with salt for secure password storage
- **Authorization**: Route-level protection for agent dashboard access

### Real-time Communication
- **WebSocket Integration**: Custom socket handlers for live messaging and status updates
- **Connection Management**: Per-conversation and per-user connection tracking
- **Message Broadcasting**: Real-time updates to all connected participants in conversations
- **Agent Status**: Live online/offline status updates for support agents

### Chat Widget System
- **Embeddable Widget**: Standalone JavaScript widget for easy website integration
- **Customization**: Configurable appearance, position, colors, and messaging
- **Customer Information**: Form collection for customer details before chat initiation
- **Responsive Design**: Mobile-friendly widget that adapts to different screen sizes

## Data Flow

### Customer Journey
1. Customer visits website with embedded chat widget
2. Widget collects customer information (name, email, phone)
3. New conversation created with "waiting" status
4. Customer messages are stored and broadcast to available agents
5. Agent can claim conversation, changing status to "active"
6. Real-time messaging continues until conversation is resolved/closed

### Agent Workflow
1. Agent logs into dashboard with username/password
2. Dashboard displays list of conversations sorted by priority and status
3. Agent can view conversation details and customer information
4. Real-time notifications for new messages and conversation updates
5. Agent can update conversation status and priority
6. Message history is preserved for future reference

## External Dependencies

### Database
- **Neon Database**: Cloud PostgreSQL provider for production deployments
- **Local PostgreSQL**: For development environment setup

### UI Components
- **shadcn/ui**: Pre-built accessible components based on Radix UI
- **Tailwind CSS**: Utility-first CSS framework for styling
- **Radix UI**: Headless component primitives for accessibility

### Real-time Features
- **WebSocket (ws)**: Native WebSocket implementation for real-time communication
- **No external real-time services required**: Self-contained solution

## Deployment Strategy

### Development
- **Vite Dev Server**: Hot module replacement for fast development
- **Local PostgreSQL**: Database setup with Docker or local installation
- **Environment Variables**: Development configuration in `.env` file

### Production
- **PM2 Process Manager**: Clustering and process management for Node.js
- **Nginx**: Reverse proxy for static files and WebSocket support
- **PostgreSQL**: Production database with connection pooling
- **SSL/TLS**: HTTPS configuration for secure communication

### Deployment Scripts
- **All-in-one Deployment**: Automated script for Ubuntu 20.04 VPS setup
- **Requirements Check**: System validation before deployment
- **Database Setup**: Automated PostgreSQL installation and configuration
- **SSL Certificate**: Automatic Let's Encrypt certificate generation

### Monitoring and Logging
- **PM2 Logs**: Application logging and error tracking
- **Database Logs**: Query performance and error monitoring
- **WebSocket Connection Tracking**: Real-time connection status monitoring

## Changelog

- July 07, 2025. Initial setup

## User Preferences

Preferred communication style: Simple, everyday language.