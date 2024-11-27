process CHAI_1 {
    tag "$meta.id"
    label 'process_high'
    conda "${moduleDir}/environment.yml"
    container 'drpatelh/chai_lab:0.3.0'

    input:
    tuple val(meta), path(fasta)
    path weights_dir

    output:
    tuple val(meta), path("${meta.id}/*.cif"), emit: structures
    tuple val(meta), path("${meta.id}/*.npz"), emit: arrays
    path "versions.yml"                      , emit: versions

    script:
    def downloads_dir = weights_dir ?: './downloads'
    """
    CHAI_DOWNLOADS_DIR=$downloads_dir \\
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
    touch ${meta.id}/pred.model_idx_0.cif
    touch ${meta.id}/pred.model_idx_1.cif
    touch ${meta.id}/scores.model_idx_0.npz
    touch ${meta.id}/scores.model_idx_1.npz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        chai_lab: \$(python -c "import chai_lab; print(chai_lab.__version__)")
        torch: \$(python -c "import torch; print(torch.__version__)")
    END_VERSIONS
    """
}
