process CHAI_1 {
    tag "$meta.id"
    label 'process_high'
    conda "${moduleDir}/environment.yml"
    container 'wave.seqera.io/wt/afb7cae43f4f/wave/build:gcc_linux-64-14.1.0_python-3.12_pip_chai_lab-0.3.0--490caee20baecaf1'

    input:
    tuple val(meta), path(fasta)
    path msa_dir
    path constraints

    output:
    tuple val(meta), path("${meta.id}/*.cif"), emit: structures
    tuple val(meta), path("${meta.id}/*.npz"), emit: arrays
    path "versions.yml"                      , emit: versions

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
