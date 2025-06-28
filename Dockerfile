# Use an official Node.js runtime as a parent image
FROM node:20-slim

# Install pnpm
RUN npm install -g pnpm

# Set the working directory in the container
WORKDIR /usr/src/app

# Create a non-root user and group
RUN groupadd --gid 1001 nodejs && \
    useradd --uid 1001 --gid nodejs --shell /bin/bash --create-home nodejs

# Copy package.json, pnpm-lock.yaml, and pnpm-workspace.yaml to leverage Docker cache
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml* ./
# pnpm-workspace.yaml might not exist, so add '*' to make it optional if it doesn't.
# If it's crucial, ensure it's always present or handle its absence.

# Copy packages directory for workspace dependencies
COPY packages/ packages/

# Install app dependencies using pnpm
# Use --frozen-lockfile for reproducible installs
# Use --recursive to install for all workspace packages
RUN pnpm install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the CLI package
# This ensures the CLI is ready to be used if needed within the container or for testing
RUN pnpm --filter @antiwork/shortest build

# Change ownership of the app directory to the non-root user
RUN chown -R nodejs:nodejs /usr/src/app

# Switch to the non-root user
USER nodejs

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the app
CMD ["pnpm", "dev"]
