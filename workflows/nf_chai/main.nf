/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { softwareVersionsToYAML } from '../../subworkflows/nf-core/utils_nfcore_pipeline'
include { CHAI_1                 } from '../../modules/local/chai_1'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NF_CHAI {

    take:
    fasta_file              //  string: path to fasta file read provided via --input parameter
    weights_dir             //  string: path to model directory read provided via --weights_dir parameter
    msa_dir                 //  string: path to the directory containing multiple sequence alignments (msa)
    num_trunk_recycles      // integer: Number of trunk recycles
    num_diffusion_timesteps // integer: Number of diffusion steps to use
    seed                    // integer: Random seed to be used for Chai-1 calculations
    use_esm_embeddings      // boolean: Use user-provided esm model embeddings

    main:

    ch_versions = Channel.empty()

    // Input channel for FASTA files
    Channel
        .fromPath(fasta_file)
        .map {
            fasta -> [ [ id: fasta.simpleName ], fasta ]
        }
        .set { ch_fasta }

    // Run structure prediction with Chai-1
    CHAI_1 (
        ch_fasta,
        weights_dir ? Channel.fromPath(weights_dir) : [],
        msa_dir ? Channel.fromPath(msa_dir) : [],
        num_trunk_recycles,
        num_diffusion_timesteps,
        seed,
        use_esm_embeddings
    )
    ch_versions = ch_versions.mix(CHAI_1.out.versions)

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  ''  + 'pipeline_software_' +  ''  + 'versions.yml',
            sort: true,
            newLine: true
        )
        .set { ch_collated_versions }

    emit:
    versions = ch_versions // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
