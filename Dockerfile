# Use a small, official Nginx image
FROM nginx:alpine

# Remove default Nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy our custom nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Copy Flutter web build output into the container
COPY build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Add a simple health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
