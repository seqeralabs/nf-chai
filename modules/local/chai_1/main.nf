process CHAI_1 {
    tag "$meta.id"
    label 'process_high'
    conda "${moduleDir}/environment.yml"
    container 'drpatelh/chai_lab:0.3.0'

    input:
    tuple val(meta), path(fasta)
    path weights_dir
    val num_trunk_recycles
    val num_diffn_timesteps
    val seed
    val use_esm_embeddings

    output:
    tuple val(meta), path("${meta.id}/*.cif"), emit: structures
    tuple val(meta), path("${meta.id}/*.npz"), emit: arrays
    path "versions.yml"                      , emit: versions

    script:
    def args = task.ext.args ?: ''
    def esm_flag = use_esm_embeddings ? '--use-esm-embeddings' : ''
    """
    run_chai_1.py \\
        --fasta-file ${fasta} \\
        --output-dir . \\
        --num-trunk-recycles ${num_trunk_recycles} \\
        --num-diffn-timesteps ${num_diffn_timesteps} \\
        --seed ${seed} \\
        ${esm_flag} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        chai_lab: \$(python -c "import chai_lab; print(chai_lab.__version__)")
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
