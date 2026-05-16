FROM ubuntu:noble

ENV MONGO_URL=mongodb://localhost/dd
RUN apt-get update && apt-get install -y gnupg curl && \
    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
        gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
        https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
        tee /etc/apt/sources.list.d/mongodb-org-8.0.list && \
    apt-get update && \
    apt-get install -y mongodb-mongosh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD ./scripts/runMongoShell.sh .
CMD  ["./runMongoShell.sh"]