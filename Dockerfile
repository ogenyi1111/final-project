# Use the official Nginx image as base
FROM nginx:alpine

# Copy the static files and templates
COPY static/ /usr/share/nginx/html/static/
COPY templates/ /usr/share/nginx/html/

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"] 