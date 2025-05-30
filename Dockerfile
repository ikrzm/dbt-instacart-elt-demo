# Main dbt runner container
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/app/dbt

# Install dbt and dependencies
RUN pip install --no-cache-dir \
    dbt-core==1.7.* \
    dbt-snowflake==1.7.*

# Copy project files
COPY . .

# Install project dependencies if requirements.txt exists
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Create profiles directory and copy profiles
RUN mkdir -p /root/.dbt
COPY scripts/profiles.yml /root/.dbt/profiles.yml

# Make scripts executable
RUN chmod +x scripts/*.sh

# Create target directory for docs
RUN mkdir -p target

# Default command (can be overridden)
CMD ["tail", "-f", "/dev/null"]