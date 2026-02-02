FROM n8nio/n8n:stable

USER root

# Update license
# update your license here if needed

# Install libraries
RUN npm install -g @napi-rs/canvas

USER node
