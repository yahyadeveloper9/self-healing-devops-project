FROM node:18-alpine
WORKDIR /app
COPY backend/package*.json ./backend/
RUN cd backend && npm install
COPY backend/ ./backend/
COPY frontend/ ./frontend/
WORKDIR /app/backend
ENV PORT=3000
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "server.js"]
