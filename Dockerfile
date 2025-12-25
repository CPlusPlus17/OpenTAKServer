
FROM docker.io/library/python:3.12

RUN addgroup --gid 1024 ots
RUN adduser --home /app --disabled-password --gecos "" --force-badname --gid 1024 ots
RUN apt update && apt install ffmpeg -y

USER ots

WORKDIR /app

# Copy the current directory contents into the container at /app
COPY --chown=ots:ots . .

RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Install dependencies and the package itself from local source
RUN pip install .

# Initialize the application
# Note: These commands might fail during build if they depend on runtime services (DB), 
# but create-ca should be fine if it just writes files. 
# However, usually init scripts are better in an entrypoint script.
# For now, I will keep create-ca but comment out db upgrade as it was in the original file.
RUN /app/venv/bin/flask --app opentakserver.app ots create-ca

EXPOSE 8081

COPY --chown=ots:ots entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

# Flask will stop gracefully on SIGINT (Ctrl-C).
# Docker compose tries to stop processes using SIGTERM by default, then sends SIGKILL after a delay if the process doesn't stop.
STOPSIGNAL SIGINT

HEALTHCHECK --interval=1m CMD curl --fail http://localhost:8081/api/health || exit 1