#!/usr/bin/env python3

import argparse
from pathlib import Path
from chai_lab.chai1 import run_inference
import torch
import logging

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(
        description="Run Chai-1 structure prediction using a FASTA file and save results to an output directory."
    )
    parser.add_argument(
        "--output-dir",
        required=True,
        type=Path,
        help="Path to the output directory where results will be saved."
    )
    parser.add_argument(
        "--fasta-file",
        required=True,
        type=Path,
        help="Path to the input FASTA file."
    )

    # Parse arguments
    args = parser.parse_args()

    # Validate input FASTA file
    if not args.fasta_file.exists():
        raise FileNotFoundError(f"FASTA file '{args.fasta_file}' does not exist.")

    # Create the output directory if it doesn't exist
    args.output_dir.mkdir(parents=True, exist_ok=True)

    # Set device for PyTorch
    if torch.cuda.is_available():
        logging.info("GPU found, using GPU")
        device = torch.device("cuda")
    else:
        logging.info("No GPU found, using CPU")
        device = "cpu"


    # Run structure prediction
    run_inference(
        fasta_file=args.fasta_file,
        output_dir=args.output_dir,
        num_trunk_recycles=3,
        num_diffn_timesteps=200,
        seed=42,
        device=device,
        use_esm_embeddings=True,
    )

if __name__ == "__main__":
    main()
