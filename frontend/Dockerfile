FROM nginx:alpine

# Copy static frontend files to Nginx default public directory
COPY index.html style.css app.js /usr/share/nginx/html/

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

