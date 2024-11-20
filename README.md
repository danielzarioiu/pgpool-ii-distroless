# Pgpool-II Multi-Architecture Docker Image

Optimized Dockerfile for building lightweight, multi-architecture (AMD64 and ARM64) Docker images of [Pgpool-II](https://www.pgpool.net/). The image is built using a multi-stage approach, ensuring that the runtime includes only the essential libraries, and is based on a distroless image for enhanced security and minimal size.

## Features
- **Multi-Architecture Support**: Build for both AMD64 and ARM64 using Docker Buildx.
- **Lightweight Runtime**: Based on `distroless` for a minimal attack surface.
- **Optimized Build Process**: Includes only the required libraries for Pgpool-II to function.
- **Production-Ready**: Designed for secure, high-performance production environments.

---

## How It Works
This Dockerfile uses a multi-stage build process:
1. **Build Stage**: 
   - Installs Pgpool-II and all necessary libraries using `apt`.
   - The installation is isolated to keep the runtime clean.
2. **Runtime Stage**:
   - Copies only the required binaries and libraries from the build stage.
   - Uses a `distroless` image to minimize the runtime footprint.

---

## Usage

### Build the Image
Use Docker Buildx to build the image for multiple architectures:
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t your-repo/pgpool:latest --push .
```

### Run the Container
Start the container using the built image:
```bash
docker run -d \
  --name pgpool \
  -v $(pwd)/configs/pgpool.conf:/etc/pgpool/pgpool.conf \
  -p 9999:9999 \
  your-repo/pgpool:latest
```

### Verify the Running Container
Check the status of the container:
```bash
docker ps
```

Inspect the logs:
```bash
docker logs pgpool
```

---

## Configuration

### Custom Configuration File
You can provide your own `pgpool.conf` by mounting it into the container:
```bash
docker run -d \
  -v /path/to/your/pgpool.conf:/etc/pgpool/pgpool.conf \
  your-repo/pgpool:latest
```

### Environment Variables
If needed, set environment variables for additional customization:
```bash
docker run -d \
  -e PGPOOL_USER=your_user \
  -e PGPOOL_PASSWORD=your_password \
  your-repo/pgpool:latest
```

---

## Example Commands

### Enter the Container
For debugging or manual interaction:
```bash
docker exec -it pgpool /bin/sh
```

### Stop the Container
```bash
docker stop pgpool
```

### Remove the Container
```bash
docker rm pgpool
```

---

## Development Notes

### Adding Missing Libraries
If the runtime reports missing libraries, add them in the build stage and copy them to the runtime stage. Use `ldd` to check dependencies:
```bash
ldd /path/to/pgpool
```

Add the necessary libraries to the Dockerfile using:
```dockerfile
RUN apt-get install -y <library_name>
COPY --from=builder /usr/lib/*-linux-gnu/<library_name> /usr/lib/
```

---

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests for improvements or bug fixes.

---

## License
This project is licensed under the [MIT License](LICENSE).
