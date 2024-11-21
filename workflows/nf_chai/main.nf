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
    fasta_chunk_size // integer: chunk FASTA file with this number of sequences per split
    
    main:

    ch_versions = Channel.empty()

    // Input channel for FASTA files
    // Channel
    //     .fromPath(fasta_file)
    //     .map { 
    //         fasta -> [ [ id: fasta.simpleName ], fasta ] 
    //     }
    //     .set { ch_fasta }

    Channel
        .fromPath(fasta_file)
        .splitFasta( by: fasta_chunk_size, record: [ id: true, seqString: true ] )
        .map {
            record ->
                def regex = /\|namek=(.+)$/
                def matcher = record.id =~ regex
                def new_record = [:]
                if (matcher.find()) {
                    new_record = [ id: matcher.group(1), seqString: record.seqString ]
                } else {
                    error("Please check header format in input FASTA file. 'name' not found for sequence\n${record.id}")
                }
                return new_record
        }
    //     .collectFile( name: 'result.fa', sort: { v -> v.size() } ) {
    //     v -> v.sequence
    // }
    // .view { fa -> fa.text }

    // // Run structure prediction with Chai-1
    // CHAI_1 (
    //     ch_fasta,
    //     msa_dir ? Channel.fromPath(msa_dir) : [],
    //     constraints_file ? Channel.fromPath(constraints_file) : []
    // )
    // ch_versions = ch_versions.mix(CHAI_1.out.versions)

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
