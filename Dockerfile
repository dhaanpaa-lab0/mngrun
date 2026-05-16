FROM ubuntu:noble

ENV MONGO_URI=mongodb://localhost/dd
RUN apt-get update && apt-get install -y gnupg curl unzip && \
    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
        gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
        https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
        tee /etc/apt/sources.list.d/mongodb-org-8.0.list && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y mongodb-mongosh nodejs && \
    ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then \
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o /tmp/awscliv2.zip; \
    else \
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip; \
    fi && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD ./scripts/runMongoShell.sh .
CMD  ["./runMongoShell.sh"]