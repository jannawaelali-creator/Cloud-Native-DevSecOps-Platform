FROM nginx:alpine

# Copy the static web files into the default Nginx public directory
COPY index.html /usr/share/nginx/html/

# Secure compliance: Adjust folder permissions so Nginx can run without root
RUN chmod -R g+rwx /var/cache/nginx /var/run /var/log/nginx

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]