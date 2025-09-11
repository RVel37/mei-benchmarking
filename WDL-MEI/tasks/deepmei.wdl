version 1.0

task deepMei {
  input {
    File bam
    File bai
    File refGenomeBwaTar
    String dockerDeepMei
  }

  command <<<

    # unpack reference genome
    mkdir -p refGenome
    tar -zxvf ~{refGenomeBwaTar} -C refGenome
    referenceFasta=$(ls refGenome/*.fasta | head -n1)

    /root/DeepMEI/DeepMEI -i ${bam} -r 38 -w \$(pwd) -o ${bam.baseName}

    if [ -f "\$VCF_FILE" ]; then
        mv "\$VCF_FILE" "${bam.baseName}.deepmei.vcf"
    else
        echo "\nNo VCF found"
    fi

  >>>

  output {
    File? vcf = "~{basename(bam, ".bam")}.deepmei.vcf"
  }

  runtime {
    docker: {dockerDeepMei}
        cpu: cpu
        gpu: false
        memory: "${mem}"
        disks: "local-disk ${disk_gb} SSD"
    }
}