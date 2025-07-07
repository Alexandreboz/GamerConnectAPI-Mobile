FROM ghcr.io/cirruslabs/flutter:3.22.2

WORKDIR /app

COPY . .

RUN flutter pub get

EXPOSE 8080

CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080"]