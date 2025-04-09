# --- Stage 1: Build ---
FROM node:23-slim AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json and install dependencies including development ones
COPY package*.json ./
RUN npm ci

# Copy all project files
COPY . .

# Build the NestJS application (ensure your "build" script compiles TypeScript into JavaScript in the "dist" directory)
RUN npm run build

# --- Stage 2: Production ---
FROM node:23-slim

# Set NODE_ENV to production
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json to install only production dependencies
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy the built app and any necessary runtime files from the builder stage
COPY --from=builder /app/dist ./dist

# Expose the application port (adjust if your NestJS app runs on a different port)
EXPOSE 3000

# Start the application
CMD ["node", "dist/main.js"]
