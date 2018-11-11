FROM node:8-alpine

# Set npm logging default level
ENV NPM_CONFIG_LOGLEVEL warn

# Set node environment to production
ENV NODE_ENV production

# Create new user to run app as instead of root for security
RUN deluser --remove-home node && \
    addgroup -g 1000 web && \
    adduser -u 1000 -G web -s /bin/sh -D web

# Make directory for application and copy package.json AND package-lock.json into it for dependency installation
RUN su -c "mkdir /home/web/app" web
COPY package*.json /home/web/app

# Install dependencies
RUN apk --update add --no-cache make gcc g++ python git && \
    # Make npm global pacakges download in /home/web so that web user has access permissions
    su -c "npm config set prefix '/home/web/.npm-global'" web && \
    # install web app
    su -c "npm install --production -g /home/web/app" web && \
    # install pm2, a process manager that helps with nodejs apps. Important for production apps, in this case just added to show how.
    su -c "npm install --production -g pm2" web && \
    # clean up all of the files in the same layer so that they can be deleted properly and not add to image size
    su -c "npm cache clean --force" web && \
    rm -rf /home/web/.config /home/web/.node-gyp /home/web/.npm && \
    apk --update del make gcc g++ python git

# Run as the new web userID for security
USER web

# Change working directory to the correct directory
WORKDIR /home/web/app

#Add global web module to path to run npm global bin without specifying path
ENV PATH=$PATH:/home/web/.npm-global/bin

# Copy server application to /home/web/app directory
COPY server.js .

# Open port 8080, the port used in app code
EXPOSE 8080

# start application using pm2 as our process manager
CMD [ "pm2-docker", "server.js" ]
