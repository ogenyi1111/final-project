# Use the official Nginx image as base
FROM nginx:alpine

# Add version information
ARG VERSION
ARG BUILD_NUMBER
ARG BUILD_DATE

# Add labels for version tracking
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${BUILD_NUMBER}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.description="Final Project Web Application"

# Create version info file
RUN echo "Version: ${VERSION}" > /usr/share/nginx/html/version.txt && \
    echo "Build Number: ${BUILD_NUMBER}" >> /usr/share/nginx/html/version.txt && \
    echo "Build Date: ${BUILD_DATE}" >> /usr/share/nginx/html/version.txt

# Create necessary directories
RUN mkdir -p /usr/share/nginx/html/static

# Copy the static files and templates
COPY static/* /usr/share/nginx/html/static/
COPY templates/* /usr/share/nginx/html/

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"] 