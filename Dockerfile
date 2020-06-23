FROM dreamfactorysoftware/df-base-img:php7.2

# Configure Nginx
COPY dreamfactory.conf /etc/nginx/sites-available/dreamfactory.conf

# Get DreamFactory
RUN git clone --branch 4.2.2 https://github.com/dreamfactorysoftware/dreamfactory.git /opt/dreamfactory

WORKDIR /opt/dreamfactory

# Uncomment lines 12 & 22 if you would like to upgrade your environment while replacing the License Key value with your issued Key
COPY composer.* /opt/dreamfactory/
# RUN echo "DF_LICENSE_KEY=84de3bd3f12be252f793396f348b894f" >> .env

# Install packages
RUN composer global require hirak/prestissimo && \
    composer install --no-dev --ignore-platform-reqs && \
    php artisan df:env --db_connection=sqlite --df_install=Docker && \
    chown -R www-data:www-data /opt/dreamfactory && \
    rm /etc/nginx/sites-enabled/default
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Set proper permission to docker-entrypoint.sh script and forward error logs to docker log collector
RUN chmod +x /docker-entrypoint.sh && ln -sf /dev/stderr /var/log/nginx/error.log && rm -rf /var/lib/apt/lists/*

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
