# GEO Dataset Transfer Script

This script is designed to transfer GEO datasets from a local directory to an FTP server. It can be useful for archiving or sharing GEO datasets with collaborators.

## Requirements

- Bash shell
- curl
- GNU Parallel (optional, for parallelized file transfer)

## Usage

```bash
./transfer_GEO_dataset.sh LOCAL_DIR REMOTE_DIR SERVER PASSWORD USERNAME
