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
    fasta_file       //  string: path to fasta file read provided via --input parameter
    msa_dir          //  string: path to MSA directory read provided via --msa_dir parameter
    constraints_file //  string: path to constraints file read provided via --constraints parameter
    model_dir        //  string: path to model directory read provided via --model_dir parameter

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
        msa_dir ? Channel.fromPath(msa_dir) : [],
        constraints_file ? Channel.fromPath(constraints_file) : []
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
