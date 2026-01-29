FROM node:18-alpine AS Builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY src ./src

#======= Final Stage ======
FROM node:18-alpine as Final

WORKDIR /app

#Build Arguments
ARG BUILD_DATE
ARG VCF_REF
ARG VERSION

#Labels for image metadata
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.description="My DevOps Project"

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY package.json .

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

#HealthCheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !==200) throw new Error(r.statusCode)})"

CMD ["node", "src/app.js"]

