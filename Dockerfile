# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY common/ ./common/
COPY server/pubspec.* ./server/
WORKDIR /app/server
RUN dart pub get

# Copy app source code and AOT compile it.
WORKDIR /app
COPY server/ ./server/
# Ensure packages are still up-to-date if anything has changed
WORKDIR /app/server
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server
RUN ldd /app/server/bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
WORKDIR /app
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server/bin/server /app/bin/
COPY --from=build /app/server/dictionary/ /dictionary/
COPY --from=build /app/server/pubspec.yaml /

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]