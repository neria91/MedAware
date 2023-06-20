# Use an official Python runtime as the base image
FROM python:3.8-alpine

# Set the working directory in the container
WORKDIR /MAapp

# Create a non-root user to run the application
RUN adduser --system -u 1000 MAuser
RUN chown MAuser /MAapp

# Copy the application files to the container
COPY --chown=MAuser . .

# Install the required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port on which the application will listen
EXPOSE 8000

# Set the user to run the application
USER MAuser

# Specify the default command to run when starting the container
ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:8000"]

# Set the default arguments for the entrypoint
CMD ["--workers", "2", "--log-level", "debug", "app:app"]
