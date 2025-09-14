version 1.0

task deepMei {
  input {
    File bam
    File bai
    File refGenomeBwaTar
    String dockerDeepMei
  }

  # dynamic instance
  Int disk_gb = ceil( 2* (size(bam, "GiB") + size(refGenomeBwaTar, "GiB")) ) + 2
  String mem = "64 GB"
  Int threads = 16
  Int cpu = (threads)/2

  command <<<

    # unpack reference genome
    mkdir -p ref
    tar -zxvf ~{refGenomeBwaTar} -C ref
    referenceFasta=$(ls ref/*.fasta | head -n1)

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