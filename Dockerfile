FROM alpine
WORKDIR /app
RUN apk --no-cache add postgresql16-client curl jq
COPY clean.sql .
COPY run.sh .
RUN chmod +x run.sh
CMD ["sh", "run.sh"]
