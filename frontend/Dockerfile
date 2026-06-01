FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm config set strict-ssl false

# Use legacy OpenSSL provider to avoid GCM cipher failures during npm install
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]