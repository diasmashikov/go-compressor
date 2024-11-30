# Go Compressor

A powerful and scalable solution for **image compression**, supporting both **lossless compression** with the standard library (`pkg/image`) and **lossy compression** using `pngquant`. The project is designed with future enhancements in mind, including:

- **Batch Processing**: Enable efficient compression of large-scale image datasets, ranging from gigabytes to terabytes.
- **Open API Integration**: Provide a public API endpoint for seamless image compression task automation.
- **Extended File Format Support**: Expand compression capabilities to include JPEG and other popular image formats.
- **Microservice Architecture**: Build a modular architecture to support additional services, such as high-performance video compression.


## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Technologies Used](#technologies-used)
4. [Infrastructure](#infrastructure)
7. [Examples](#examples)
8. [Performance](#performance)

---

### Introduction
The project aims to utilize Go's as the server to process image compression tasks at scale in the most efficient way using Google Cloud Platform

### Features

#### Multiple Compression Strategies
- **Lossless Compression:**
  - Utilizes the standard library for PNG compression.
- **Lossy Compression:**
  - Integrates with PNGQuant for lossy compression with quality control.

#### Web Service Architecture
- **RESTful API:**
  - Provides an endpoint for image compression tasks.
- **CORS Support:**
  - Allows cross-origin requests from specified domains.
- **Health Check Endpoint:**
  - Ensures the server is running and operational.

#### Load Testing
- **K6 Integration:**
  - Implements load testing using `k6` to ensure high performance and reliability under heavy traffic.
- **Custom Scenarios:**
  - Simulates real-world API usage by uploading test PNG images for compression.
- **Results Tracking:**
  - Tracks response time, status codes, and throughput during load tests.

### Infrastructure

The project leverages a lean and efficient setup on **Google Cloud Platform (GCP)** to support scalable and high-performance image compression. Below are the major infrastructure components:

#### Compute
- **Google Compute Engine (GCE):**
  - Virtual machines running the Go server to process image compression tasks.
  - Managed Instance Groups (MIGs) for automatic scaling based on workload demand.

#### Networking
- **Virtual Private Cloud (VPC):**
  - Provides secure network isolation for backend services.
  - Configured with public and private subnets to separate external-facing components and internal services.
- **Load Balancer:**
  - HTTP/HTTPS load balancer to distribute incoming requests across backend servers.
  - Handles SSL termination for secure client-server communication.
- **Cloud NAT:**
  - Enables outbound internet access for private backend services.

#### Security
- **Cloud Armor:**
  - Protects against DDoS attacks and malicious traffic using Web Application Firewall (WAF) policies.
  - Implements rate limiting and IP filtering for additional security.
- **Firewall Rules:**
  - Restricts access to backend instances, allowing traffic only from the load balancer and health checks.
- **IAM (Identity and Access Management):**
  - Ensures secure access to GCP resources with fine-grained permission controls.

#### Containerization
- **Docker:**
  - The Go application is containerized for consistent and portable deployments.

#### Artifact Management
- **Artifact Registry:**
  - Stores Docker container images for versioned deployments on Compute Engine.


### Technologies Used
- **Programming Languages**: Go
- **Libraries**: 
  - `pkg/image` for lossless compression
  - `pngquant` for lossy compression
  - `net/http` for server-side
- **Other Tools**: Docker, Google Cloud Platform, K6, Grafana, InfluxDB

### Examples 

<img width="800" alt="Screenshot 2024-11-30 at 11 36 32" src="https://github.com/user-attachments/assets/7697bcb0-b14e-4c25-91da-a32f907f9ba6">


### Performance

- **Compression Speed:**
  - Handles up to **[auto-scalable] images per second** due to Google Cloud's managed instance groups.
  - Compression time for a 1 MB image ranges from **1 to 3 seconds**, depending on the region.
  - Ongoing work to expand region support for better global performance.

- **File Size Reduction:**
  - **Lossy Compression (PNGQuant):**
    - Achieves an average size reduction of **80%**.
    - Compression speed is approximately **2x faster** than lossless compression.
  - **Lossless Compression (using `pkg/image`):**
    - Achieves an average size reduction of **20%**.

- **Scalability:**
  - Compression tasks are **auto-scalable** using managed instance groups, ensuring performance remains consistent under varying workloads.




