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
    # Add optional arguments with current defaults
    parser.add_argument(
        "--num-trunk-recycles",
        type=int,
        default=3,
        help="Number of trunk recycles (default: 3)"
    )
    parser.add_argument(
        "--num-diffn-timesteps",
        type=int,
        default=200,
        help="Number of diffusion timesteps (default: 200)"
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Random seed for reproducibility (default: 42)"
    )
    parser.add_argument(
        "--use-esm-embeddings",
        action="store_true",
        default=True,
        help="Use ESM embeddings (enabled by default)"
    )
    parser.add_argument(
        "--msa-dir",
        type=str,
        default=None,
        help="Directory containing precomputed multiple sequence alignments (MSA)."
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
        device = torch.device("cpu")

    # Run structure prediction
    run_inference(
        fasta_file=args.fasta_file,
        output_dir=args.output_dir,
        num_trunk_recycles=args.num_trunk_recycles,
        num_diffn_timesteps=args.num_diffn_timesteps,
        seed=args.seed,
        device=device,
        use_esm_embeddings=args.use_esm_embeddings,
        msa_directory=Path(args.msa_dir) if args.msa_dir else None,
    )

if __name__ == "__main__":
    main()
