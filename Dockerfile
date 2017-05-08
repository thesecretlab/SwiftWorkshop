FROM ibmcom/swift-ubuntu:latest

WORKDIR $HOME

# Copy the application source code
COPY . $HOME

# Compile the application
RUN swift build -Xcc -fblocks --configuration release

EXPOSE 8080

CMD .build/release/TodoList
