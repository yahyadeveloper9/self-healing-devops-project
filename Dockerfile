FROM node:18-alpine
WORKDIR /opt/resume-platform/website/backend
COPY website/backend/package*.json ./
RUN npm install
COPY website/backend/ ./
COPY website/frontend/ /opt/resume-platform/website/frontend/
ENV PORT=3000
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "server.js"]
