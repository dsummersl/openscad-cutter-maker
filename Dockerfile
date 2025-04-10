FROM python:3.13-slim-bookworm


# Install dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    wget \
    imagemagick \
    gpg \
    potrace

RUN wget -qO- https://files.openscad.org/OBS-Repository-Key.pub | tee /etc/apt/trusted.gpg.d/obs-openscad-nightly.asc \
    && echo "deb https://download.opensuse.org/repositories/home:/t-paul/Debian_12/ /" | tee /etc/apt/sources.list.d/openscad-nightly.list \
    && apt-get update

RUN apt-get install -y \
    openscad-nightly \
    && rm -rf /var/lib/apt/lists/*

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_HOME='/usr/local' \
    POETRY_VERSION=2.0.1

RUN curl -sSL https://install.python-poetry.org | python3 -

ENV OPENSCAD_PATH=/usr/bin/openscad-nightly

WORKDIR /app

COPY pyproject.toml poetry.lock* tasks.py cookie.scad ./

RUN poetry install

# Make /data as a volume for input/output files
VOLUME ["/data"]

# Set the entrypoint to invoke
ENTRYPOINT ["poetry", "run", "invoke"]

# Show help by default
CMD ["help"]
