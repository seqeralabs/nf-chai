process CHAI_1 {
    tag "$meta.id"
    label 'process_high'
    conda "${moduleDir}/environment.yml"

    input:
    tuple val(meta), path(fasta)
    path msa_dir
    path constraints

    output:
    tuple val(meta), path("${meta.id}/ranked_*.cif")     , emit: structures
    tuple val(meta), path("${meta.id}/ranking_data.json"), emit: rankings
    tuple val(meta), path("${meta.id}/msa_coverage.png") , emit: msa_plot, optional: true
    path "versions.yml"                                  , emit: versions

    script:
    """
    CHAI_DOWNLOADS_DIR=./downloads \\
    run_chai_1.py \\
        --output-dir ${meta.id} \\
        --fasta-file ${fasta}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        chai_lab: \$(python -c "import chai_lab; print(chai_lab.__version__)")
        torch: \$(python -c "import torch; print(torch.__version__)")
    END_VERSIONS
    """

    stub:
    """
    mkdir -p ${meta.id}
    touch ${meta.id}/ranked_*.cif")
    touch ${meta.id}/ranking_data.json
    touch ${meta.id}/msa_coverage.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        chai_lab: \$(python -c "import chai_lab; print(chai_lab.__version__)")
        torch: \$(python -c "import torch; print(torch.__version__)")
    END_VERSIONS
    """
}
// # Create versions file
// with open("versions.yml", "w") as f:
//     f.write('"${task.process}":\\n')
//     f.write('    python: "' + sys.version.split()[0] + '"\\n')
//     f.write('    torch: "' + torch.__version__ + '"\\n')
